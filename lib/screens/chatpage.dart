import 'dart:convert';
import 'dart:async';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
//import 'package:flutter_sound_lite/public/flutter_sound_recorder.dart';
import 'package:microphone/microphone.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'getunread.dart';
import 'utils.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:record/record.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:video_player/video_player.dart';

class ChatPage extends StatefulWidget {
//  const ChatPage({Key key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

final List<String> items = List.generate(20, (index) => 'Item ${index + 1}');
Future<void> handlePasteEvent() async {
  final data = await html.window.navigator.clipboard!.read();
  if (data.files != null && data.files!.isNotEmpty) {
    for (final file in data.files!) {
      if (file.type.startsWith('image/')) {
        final reader = html.FileReader();
        reader.readAsDataUrl(file);
        await reader.onLoad.first;

        final pickedImage = XFile(reader.result as String);

        // Upload the image to Firebase Storage
        final imageReference =
            firebase_storage.FirebaseStorage.instance.ref().child(
                  'chats/${DateTime.now().millisecondsSinceEpoch}.png',
                );
        final uploadTask = imageReference.putFile(File(pickedImage.path));
        final snapshot = await uploadTask;
        final imageUrl = await snapshot.ref.getDownloadURL();

        // Save the image URL to Firestore
        FirebaseFirestore.instance.collection('chats').add({
          'imageUrl': imageUrl,
          'timestamp': Timestamp.now(),
        });
      }
    }
  }
}

class _ChatPageState extends State<ChatPage> {
  late RawKeyboard _keyboard;
  final GetUnread unread = GetUnread();
  final _textController = TextEditingController();
  bool _isRecording = false;
  final FocusNode _focusNode = FocusNode();
  String id = FirebaseAuth.instance.currentUser!.uid;
  String? idcurr;
  MicrophoneRecorder? _recorder;
  String namecurrent =
      FirebaseAuth.instance.currentUser!.displayName.toString().split(" ")[0];
  String selectedTileIndex = "";
  String name = "";
  String time = "";
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  //FirebaseFirestore _firestore = FirebaseFirestore.instance;
  //final _textController = TextEditingController();
  //late IO.Socket _socket;
  Record record = Record();
  Directory? appStorage;
  // bool _isRecording = false;
  //FlutterSoundRecorder _audioRecorder = FlutterSoundRecorder();

  File? pickedFile;

  String? pickedFileName;
  bool isLoading = false;
  //TextEditingController _searchController = TextEditingController();
  String role = "";
  List<dynamic> coursecode = [];
  List<String> coursename = [];
  List<String> cname = [];
  //List<DateTime> time = [];
  Set<String> _updatedDocuments = {};
  Set<String> newdocuments = {};
  bool played = false;
  //String? pickedFileName;
  void _initRecorder() {
    played == true ? _recorder?.dispose() : null;

    _recorder = MicrophoneRecorder()
      ..init()
      ..addListener(() {
        setState(() {
          played = true;
        });
      });
  }

  void _cancelRecording() async {
    if (_isRecording) {
      setState(_initRecorder);
      // await _soundRecorder.stopRecorder();
      // await _soundRecorder.closeAudioSession();

      setState(() {
        _isRecording = false;
      });
    }
  }

  void _onSearchTextChanged(String searchText) {
    setState(() {
      if (searchText != "") {
        _collectionStream = FirebaseFirestore.instance
            .collection('groups')
            .where('student_name', isEqualTo: searchText)
            .orderBy('time', descending: true)
            .limit(500)
            .snapshots();
      } else {
        _collectionStream = FirebaseFirestore.instance
            .collection('groups')
            .orderBy('time', descending: true)
            .limit(500)
            .snapshots();
      }
    });
  }

  bool isURL(String string) {
    // Regular expression pattern to match a URL
    // Regular expression pattern to match a URL
    return (string.contains('http', 0) ||
        string.contains('www') ||
        string.contains('https', 0) ||
        string.contains('.com'));
  }

  //FirebaseFirestore _firestore = FirebaseFirestore.instance;
  void _sendMessage() async {
    if (_textController.text.isNotEmpty) {
      _focusNode.unfocus();
      String data = await _textController.text.toString();
      _textController.clear();
      DateTime time1 = await fetchTimeInIndia();

      print(time);
      print(time1.toString());
      updatelast();
      updatetime(time1, data);
      final post = await _firestore
          .collection("groups_dataly")
          .doc(idcurr)
          .collection("chats")
          .add({
        'message': data,
        'role': role,
        'sendBy': namecurrent,
        'time': time1,
        'studentid': id,
        'type': 'text'
      });
    }
  }

  Future<void> _pickFilePhoto() async {
    print("good1");
    final html.FileUploadInputElement uploadInput =
        html.FileUploadInputElement();
    uploadInput.accept =
        'image/*'; // Specify the accepted file types (e.g., images)
    uploadInput.click();

    uploadInput.onChange.listen((e) async {
      final List<html.File> files = uploadInput.files!;
      if (files.isNotEmpty) {
        final html.File file = files.first;
        final html.FileReader reader = html.FileReader();
        reader.readAsDataUrl(file);

        reader.onLoadEnd.listen((e) async {
          final String? fileDataUrl = reader.result as String?;
          if (fileDataUrl != null) {
            // Convert the data URL to bytes
            final commaIndex = fileDataUrl.indexOf(',');
            if (commaIndex != -1) {
              final String base64Data = fileDataUrl.substring(commaIndex + 1);
              final Uint8List fileBytes = base64Decode(base64Data);

              final fileName = file.name;
              // Upload the file to Firebase Storage
              final storageRef =
                  FirebaseStorage.instance.ref().child('files/$fileName');
              final UploadTask uploadTask = storageRef.putData(
                  fileBytes, SettableMetadata(contentType: file.type));
              final TaskSnapshot snapshot = await uploadTask;
              final downloadUrl = await snapshot.ref.getDownloadURL();
              final time = DateTime.now();
              // Add message to Firestore
              updatelast();
              DateTime time1 = await fetchTimeInIndia();

              print(time);
              print(time1.toString());
              updatelast();
              updatetime(time1, "image");
              _firestore
                  .collection("groups_dataly")
                  .doc(idcurr)
                  .collection("chats")
                  .add({
                'message': fileName,
                'role': role,
                'sendBy': namecurrent,
                'link': downloadUrl,
                'time': time1,
                'studentid': id,
                'type': 'image'
              });
            }
          }
        });
      }
    });
  }

  Future<void> _pickFilevideo() async {
    final html.FileUploadInputElement uploadInput =
        html.FileUploadInputElement();
    uploadInput.accept =
        'video/*'; // Specify the accepted file types (e.g., videos)
    uploadInput.click();

    uploadInput.onChange.listen((e) async {
      final List<html.File> files = uploadInput.files!;
      if (files.isNotEmpty) {
        final html.File file = files.first;
        final html.FileReader reader = html.FileReader();
        reader.readAsDataUrl(file);

        reader.onLoadEnd.listen((e) async {
          final String? fileDataUrl = reader.result as String?;
          if (fileDataUrl != null) {
            // Convert the data URL to bytes
            final commaIndex = fileDataUrl.indexOf(',');
            if (commaIndex != -1) {
              final String base64Data = fileDataUrl.substring(commaIndex + 1);
              final Uint8List fileBytes = base64Decode(base64Data);

              final fileName = file.name;
              // Upload the file to Firebase Storage
              final storageRef =
                  FirebaseStorage.instance.ref().child('files/$fileName');
              final UploadTask uploadTask = storageRef.putData(
                  fileBytes, SettableMetadata(contentType: file.type));
              final TaskSnapshot snapshot = await uploadTask;
              final downloadUrl = await snapshot.ref.getDownloadURL();
              final time = DateTime.now();
              // Add message to Firestore
              DateTime time1 = await fetchTimeInIndia();

              print(time);
              print(time1.toString());
              updatelast();
              updatetime(time1, "video");

              _firestore
                  .collection("groups_dataly")
                  .doc(idcurr)
                  .collection("chats")
                  .add({
                'message': fileName,
                'role': role,
                'sendBy': namecurrent,
                'link': downloadUrl,
                'time': time1,
                'studentid': id,
                'type': 'video'
              });
            }
          }
        });
      }
    });
  }

  Future<void> _pickFileany() async {
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.multiple = false;
    uploadInput.accept =
        ''; // Modify the accepted file types as needed
    uploadInput.click();

    uploadInput.onChange.listen((e) async {
      final List<html.File>? files = uploadInput.files;
      if (files != null && files.isNotEmpty) {
        final html.File file = files.first;
        final html.FileReader reader = html.FileReader();
        reader.readAsArrayBuffer(file);

        reader.onLoadEnd.listen((e) async {
          final Uint8List? fileBytes = reader.result as Uint8List?;
          if (fileBytes != null) {
            final fileName = file.name;
            // Upload the file to Firebase Storage
            final storageRef =
                FirebaseStorage.instance.ref().child('files/$fileName');
            final UploadTask uploadTask = storageRef.putData(
                fileBytes,
                SettableMetadata(
                    contentType:
                        'application/pdf')); // Modify the content type as needed
            final TaskSnapshot snapshot = await uploadTask;
            final downloadUrl = await snapshot.ref.getDownloadURL();
            final time = DateTime.now();
            DateTime time1 = await fetchTimeInIndia();

            print(time);
            print(time1.toString());
            updatelast();
            updatetime(time1, "file");
            _firestore
                .collection("groups_dataly")
                .doc(idcurr)
                .collection("chats")
                .add({
              'message': fileName,
              'role': role,
              'sendBy': namecurrent,
              'link': downloadUrl,
              'time': time1,
              'studentid': id,
              'type': 'file'
            });
          }
        });
      }
    });
  }

  bool notificationShown = false;

  void displayWebNotification(String title, String body, String icon) {
    if (!notificationShown && html.Notification.supported) {
      html.Notification.requestPermission().then((permission) {
        if (permission == 'granted') {
          html.Notification(title, body: body, icon: icon);
          notificationShown = true;
        }
      });
    }
  }

//  void updatetime(DateTime time, String message) {
//     _firestore.collection("groups_dataly").doc(widget.groupId).update({'time': time});
//     _firestore
//         .collection("groups_dataly")
//         .doc(widget.groupId)
//         .update({'lastmessage': message});
//   }
  void updatetime(DateTime time, String message) {
    _firestore.collection("groups_dataly").doc(idcurr).update({'time': time});
    _firestore
        .collection("groups_dataly")
        .doc(idcurr)
        .update({'lastmessage': message});
  }

  Future<DateTime> fetchTimeInIndia() async {
    final response = await http
        .get(Uri.parse('https://worldtimeapi.org/api/timezone/Asia/Kolkata'));
    final jsonData = json.decode(response.body);
    final datetime = jsonData['datetime'];
    final offset = jsonData['utc_offset'];
    final parsedDateTime = DateTime.parse(datetime).toUtc();
    return parsedDateTime;
  }

  void updatelast() {
    _firestore
        .collection("groups_dataly")
        .doc(idcurr)
        .update({'last': FirebaseAuth.instance.currentUser!.uid.toString()});
  }

  void _stopRecording() async {
    if (_isRecording) {
      await _recorder!.stop();
      endtime = DateTime.now();

      setState(() {
        _isRecording = false;
      });
      _uploadRecording();
    }
  }

  Duration _calculateDuration() {
    final duration = endtime!.difference(starttime!);
    return duration;
  }

//  void _getAppStorageDir() {
//   final appStorage = html.window.localStorage;
//   // Use appStorage as needed
// }
  Future<String> _uploadRecording() async {
    if (namecurrent != null) {
      final storageRef =
          FirebaseStorage.instance.ref().child('audio/${DateTime.now()}.mp3');
//  final fb.UploadTaskSnapshot uploadTaskSnapshot = await storageRef.put(filePath).future;
      try {
        await storageRef.putData(await _recorder!.toBytes());
        final downloadUrl = await storageRef.getDownloadURL();
        print('File uploaded: $downloadUrl');
        // final time = DateTime.now();
        // Add message to Firestore

        DateTime time1 = await fetchTimeInIndia();
        Duration tt = await _calculateDuration();
        //  print(time);
        print(time1.toString());
        updatelast();
        updatetime(time1, "audio note");
        _firestore.collection("groups_dataly").doc(idcurr).collection("chats").add({
          'message': '${DateTime.now()}.mp3',
          'role': role,
          'sendBy': namecurrent,
          'link': downloadUrl,
          'time': time1,
          'studentid': id,
          'duration':
              '${tt.inHours}:${tt.inMinutes.remainder(60)}:${tt.inSeconds.remainder(60)}',
          'type': 'audio'
        });

        return downloadUrl;
      } catch (e) {
        print('Error uploading file: $e');
        throw 'Failed to upload recording';
      }
    }
    else{
      return "not valid";
    }
  }

  DateTime? starttime;
  DateTime? endtime;
  // FlutterSoundRecorder _soundRecorder = FlutterSoundRecorder();
  void _startRecording() async {
    _initRecorder();
    // starttime=DateTime.
    print("Recording....");
    if (await Record().hasPermission()) {
      setState(() {
        _isRecording = true;
      });

      // await _initRecorder();

      _recorder!.start();
      starttime = DateTime.now();
      //   await _soundRecorder.openAudioSession();
      //   await _soundRecorder.startRecorder(
      //     // toFile: '${appStorage!.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a',
      //  //   codec: opusWebM,
      //     sampleRate: 44100,
      //     bitRate: 128000,
      //   );
    }
  }

  Widget _buildMicButton() {
    return IconButton(
      icon: Icon(Icons.mic_none_rounded, color: Colors.purple),
      onPressed: _startRecording,
    );
  }

  Widget _buildStopRecordingButton() {
    return IconButton(
      icon: Icon(Icons.stop_rounded, color: Colors.red),
      onPressed: _stopRecording,
    );
  }

  Widget _buildCancelButton() {
    return IconButton(
      icon: Icon(Icons.cancel_rounded, color: Colors.grey),
      onPressed: _cancelRecording,
    );
  }

  Stream<QuerySnapshot> _collectionStream = FirebaseFirestore.instance
      .collection('groups')
      .orderBy('time', descending: true)
      .limit(500)
      .snapshots();
  Stream<QuerySnapshot> _collectionStream1 = FirebaseFirestore.instance
      .collection('groups')
      .where('student_id', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .orderBy('time', descending: true)
      .limit(500)
      .snapshots();
  Stream<QuerySnapshot>? _messageStream;
  void listenToFirestoreChanges() async {
    final snapshot = await _firestore
        .collection("Users_dataly")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    final data = snapshot.data();
    role = data!["role"];
    namecurrent = data["name"].split(" ")[0];
    ;
    _updatedDocuments = Set<String>();
    role == "student"
        ? _collectionStream1.listen((snapshot) async {
            snapshot.docChanges.forEach((change) {
              if (change.type == DocumentChangeType.modified) {
                DocumentSnapshot changedDoc = change.doc;
                Map<String, dynamic> changedData =
                    changedDoc.data() as Map<String, dynamic>;
                if (changedData.containsKey("last")) {
                  if (change.doc["last"].toString() ==
                      FirebaseAuth.instance.currentUser!.uid.toString()) {
                  } else {
                    _updatedDocuments.add(change.doc.id);
                    print(_updatedDocuments);
                    displayWebNotification(
                        "${change.doc["student_name"]} has a new message",
                        changedData.containsKey('lastmessage')
                            ? "message: ${change.doc["lastmessage"]}"
                            : "message: new feature is working",
                        "assets/icon.jpeg");
                  }
                  notificationShown = true;
                } else {
                  _updatedDocuments.add(change.doc.id);
                  print(_updatedDocuments);
                }
              } else if (change.type == DocumentChangeType.added) {
                newdocuments.add(change.doc.id);
              }
            });
            if (_updatedDocuments.isNotEmpty) {
              await unread.saveunread(_updatedDocuments);
            }
          })
        : _collectionStream.listen((snapshot) async {
            snapshot.docChanges.forEach((change) {
              if (change.type == DocumentChangeType.modified) {
                DocumentSnapshot changedDoc = change.doc;
                Map<String, dynamic> changedData =
                    changedDoc.data() as Map<String, dynamic>;
                if (changedData.containsKey("last")) {
                  if (change.doc["last"].toString() ==
                      FirebaseAuth.instance.currentUser!.uid.toString()) {
                  } else {
                    _updatedDocuments.add(change.doc.id);
                    print(_updatedDocuments);
                    displayWebNotification(
                        "New Message",
                        "${change.doc["student_name"]} has a new message",
                        "assets/icon.jpeg");
                  }
                  notificationShown = true;
                } else {
                  _updatedDocuments.add(change.doc.id);
                  print(_updatedDocuments);
                }
              } else if (change.type == DocumentChangeType.added) {
                newdocuments.add(change.doc.id);
              }
            });
            if (_updatedDocuments.isNotEmpty) {
              await unread.saveunread(_updatedDocuments);
            }
          });

    setState(() {
      isLoading = false;
    });
  }

  void _selectimage() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.image),
                title: Text('Select Image'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFilePhoto();
                },
              ),
              ListTile(
                leading: Icon(Icons.video_library),
                title: Text('Select Video'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFilevideo();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future readunread() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();

    if (_prefs.containsKey("myList")) {
    } else {}
  }

  Future<String> loadrole() async {
    final snapshot = await _firestore
        .collection("Users_dataly")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    final data = snapshot.data();
    role = data!["role"];
    // name = data["name"].toString().split(" ")[0];
    print(FirebaseAuth.instance.currentUser!.uid);
    print(role);
    // print(name);
    return role;
  }

  List<String>? myList;
  @override
  void initState() {
    super.initState();
    _keyboard = RawKeyboard.instance;
    _keyboard.addListener(_handleKeyPress);
    loadrole();

    // _initRecorder();
    //Configuration.docid = "";
    print("iwejoiweofwoiefwf");
    readunread();
    if (myList != null) {
      _updatedDocuments = myList!.toSet();
    } else {
      _updatedDocuments = Set<String>();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      listenToFirestoreChanges();
    });
  }

  void _handleKeyPress(RawKeyEvent event) {
    if (event is RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.enter) {
      // Trigger your function here
      _sendMessage();
    }
  }

  @override
  void dispose() {
    _keyboard.removeListener(_handleKeyPress);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 1280;
    double fem = 100.w / baseWidth;
    double ffem = fem * 0.97;
    DateTime now = DateTime.now();
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        child: Row(
          children: [
            Container(
              width: 30.w,
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 0),
                    width: double.infinity,
                    height: 10.h,
                    child: Row(
                      children: [
                        // Padding(
                        //   padding:
                        //       const EdgeInsets.only(top: 0, left: 1, right: 1),
                        //   child: Container(
                        //     child: Image.asset(
                        //       'assets/page-1/images/vector.png',
                        //       height: 5.h,
                        //       width: 3.h,
                        //     ),
                        //   ),
                        // ),
                        Padding(
                          padding: EdgeInsets.only(left: 2.w, right: 0.5.w),
                          child: Container(
                            width: 22.w,
                            height: 4.h,
                            padding: EdgeInsets.only(left: 1.w),
                            decoration: BoxDecoration(
                              color: Color(0xfff5f5f5),
                              borderRadius: BorderRadius.circular(22.h),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  child: Image.asset(
                                    'assets/page-1/images/search.png',
                                    height: 5.h,
                                    width: 3.h,
                                  ),
                                ),
                                SizedBox(width: 1.w),
                                Expanded(
                                  child: TextField(
                                    onChanged: _onSearchTextChanged,
                                    decoration: InputDecoration(
                                      hintText: "Search",
                                      border: InputBorder.none,
                                    ),
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xff707991),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                    stream: role == "student"
                        ? _collectionStream1
                        : _collectionStream,
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }

                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          return Center(
                            child:
                                Image.asset("assets/page-1/images/loader.gif"),
                          );
                        default:
                          return ListView.builder(
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (BuildContext context, int index) {
                              DocumentSnapshot document =
                                  snapshot.data!.docs[index];
                              Map<String, dynamic> data =
                                  document.data() as Map<String, dynamic>;

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _messageStream = FirebaseFirestore.instance
                                        .collection("groups_dataly")
                                        .doc(document.id)
                                        .collection("chats")
                                        .orderBy('time', descending: true)
                                        .snapshots();
                                    selectedTileIndex = document.id;
                                    idcurr = document.id;
                                    name = document["name"].toString();
                                    time = document["student_name"].toString();
                                    if (_updatedDocuments
                                        .contains(document.id)) {
                                      setState(() {
                                        _updatedDocuments.remove(document.id);
                                      });
                                    }
                                  });
                                },
                                child: Padding(
                                  padding:
                                      EdgeInsets.only(left: 0.w, right: 0.w),
                                  child: Container(
                                    width: 30.w,
                                    padding: EdgeInsets.fromLTRB(
                                        1.w, 0.2.h, 0.w, 0.2.h),
                                    color: _updatedDocuments
                                            .contains(document.id)
                                        ? Color.fromARGB(255, 157, 239, 159)
                                        : selectedTileIndex == document.id
                                            ? Color.fromARGB(255, 237, 213, 248)
                                            : Colors.transparent,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.fromLTRB(
                                              0 * fem, 0 * fem, 2.h, 0 * fem),
                                          width: 4.w,
                                          height: 4.w,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(100.sp),
                                            child: Image.asset(
                                              'assets/icon.jpeg',
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: 23.w,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      width: 16.w,
                                                      child: Text(
                                                        "${document["name"]}",
                                                        style: TextStyle(
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          fontFamily: 'Inter',
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color:
                                                              Color(0xff011627),
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 1.w),
                                                      child: Text(
                                                        (document["time"]
                                                                        .toDate()
                                                                        .day ==
                                                                    now.day) &&
                                                                (document["time"]
                                                                        .toDate()
                                                                        .month ==
                                                                    now
                                                                        .month) &&
                                                                (document["time"]
                                                                        .toDate()
                                                                        .year ==
                                                                    now.year)
                                                            ? "Today"
                                                            : (document["time"]
                                                                            .toDate()
                                                                            .day ==
                                                                        (now.day -
                                                                            1)) &&
                                                                    (document["time"]
                                                                            .toDate()
                                                                            .month ==
                                                                        now
                                                                            .month) &&
                                                                    (document["time"]
                                                                            .toDate()
                                                                            .year ==
                                                                        now.year)
                                                                ? "Yesterday"
                                                                : "${document["time"].toDate().day}/${document["time"].toDate().month}/${document["time"].toDate().year}",
                                                        style: TextStyle(
                                                          fontFamily: 'Inter',
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color:
                                                              Color(0xff707991),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    "${document["student_name"]}",
                                                    style: TextStyle(
                                                      fontFamily: 'Inter',
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Color(0xff707991),
                                                    ),
                                                  ),
                                                  Spacer(),
                                                  !(data.containsKey('last'))
                                                      ? Text(
                                                          "NEW!!!",
                                                          style: TextStyle(
                                                            fontFamily: 'Inter',
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    144,
                                                                    5,
                                                                    149),
                                                          ),
                                                        )
                                                      : Spacer(),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                      }
                    },
                  ))
                ],
              ),
            ),
            Container(
              width: 70.w,
              child: Column(
                children: [
                  name == ""
                      ? Container()
                      : Container(
                          width: double.infinity,
                          height: 10.h,
                          child: Container(
                            // topbartFx (1:345)
                            padding: EdgeInsets.fromLTRB(2.w, 1.h, 2.w, 0),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(color: Color(0xffd9dce0)),
                              color: Color(0xffffffff),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  // otherusera8n (1:346)
                                  padding: EdgeInsets.fromLTRB(0, 0, 2.h, 0),
                                  height: 10.h,
                                  decoration: BoxDecoration(
                                    color: Color(0xffffffff),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 0.5.h),
                                        child: Container(
                                          // avatarJ4n (1:347)
                                          margin:
                                              EdgeInsets.fromLTRB(0, 0, 1.w, 0),
                                          width: 5.w,
                                          height: 5.w,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                                100 * fem),
                                            child: Image.asset(
                                              'assets/icon.jpeg',
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        // textszCW (1:348)
                                        height: double.infinity,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              // datascienceanalyticswdY (1:350)
                                              margin: EdgeInsets.fromLTRB(
                                                  0 * fem,
                                                  0 * fem,
                                                  0 * fem,
                                                  4 * fem),
                                              child: Text(
                                                '$name',
                                                style: SafeGoogleFont(
                                                  'Inter',
                                                  fontSize: 16 * ffem,
                                                  fontWeight: FontWeight.w600,
                                                  height: 1.25 * ffem / fem,
                                                  color: Color(0xff011627),
                                                ),
                                              ),
                                            ),
                                            Text(
                                              // lastmessage5minsagoeXx (1:352)
                                              '$time',
                                              style: SafeGoogleFont(
                                                'Inter',
                                                fontSize: 14 * ffem,
                                                fontWeight: FontWeight.w400,
                                                height:
                                                    1.2857142857 * ffem / fem,
                                                color: Color(0xff707991),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 8 * fem,
                                ),
                                SizedBox(
                                  width: 8 * fem,
                                ),
                                Container(
                                  // callicon5NN (1:356)
                                  width: 40 * fem,
                                  height: 40 * fem,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(100 * fem),
                                  ),
                                ),
                                SizedBox(
                                  width: 8 * fem,
                                )
                              ],
                            ),
                          ),
                        ),
                  name == ""
                      ? Container(
                          width: 70.w,
                          height: 100.h,
                          color: Color(0xFFB27ECA),
                          //  height: double.infinity,
                          child: Image.asset(
                            "assets/page-1/images/bg-1.png",
                            fit: BoxFit.cover,
                          ),
                        )
                      : Container(
                          width: 70.w,
                          height: 90.h,
                          decoration: BoxDecoration(
                            color: Color(0xFFB27ECA),
                            image: DecorationImage(
                              image: AssetImage(
                                  "assets/page-1/images/bg-1.png"), // Replace with your image path
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 70.w,
                                height: 75.h,
                                child: StreamBuilder<QuerySnapshot>(
                                  stream: _messageStream,
                                  builder: (context, snapshot) {
                                    if (snapshot.hasError) {
                                      print("snapshot.error");
                                      return CircularProgressIndicator(
                                        color: Colors.yellow,
                                      );
                                    }

                                    if (!snapshot.hasData) {
                                      return Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                    final messages = snapshot.data!.docs;
                                    print(
                                        'Number of documents: ${messages.length}');
                                    List<MessageBubble> messageBubbles = [];
                                    for (var message in messages) {
                                      final data = message.data()
                                          as Map<String, dynamic>;
                                      final messageText = message['message'];
                                      final messageSender = message['sendBy'];
                                      final messageType = message['type'];
                                      final messagetime = message['time'];
                                        final mid = message.id;
                                      final gid = idcurr;
                                      final messageid =
                                          data.containsKey('studentid')
                                              ? message['studentid']
                                              : "old message";
                                      final link = messageType == "image" ||
                                              messageType == "audio" ||
                                              messageType == "video" ||
                                              messageType == "file"
                                          ? message["link"]
                                          : "";

                                      final messageBubble = MessageBubble(
                                         mid: mid,
                              gid: gid!,
                                        message: messageText,
                                        sender: messageSender,
                                        timestamp: messagetime,
                                        isMe: messageSender == namecurrent,
                                        link: link,
                                        //  recording: recording,
                                        type: messageType,
                                        isURL: isURL(messageText),
                                      );
                                      messageBubbles.add(messageBubble);
                                    }
                                    return Container(
                                      height: 80.h,
                                      width: 65.w,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(40.sp),
                                          topRight: Radius.circular(40.sp),
                                        ),
                                        // color: Colors.white,
                                      ),
                                      child: ListView(
                                        reverse: true,
                                        children: messageBubbles,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Divider(),
                              Padding(
                                padding: EdgeInsets.all(1.h),
                                child: Container(
                                  height: 8.h,
                                  color: Colors.white,
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 1.w,
                                      ),
                                      _isRecording
                                          ? _buildStopRecordingButton()
                                          : _buildMicButton(),
                                      _isRecording
                                          ? _buildCancelButton()
                                          : Expanded(
                                              child: TextField(
                                                maxLines: 1,
                                                controller: _textController,
                                                onTap: () {
                                                  _focusNode.requestFocus();
                                                },
                                                onTapOutside: (event) {
                                                  _focusNode.unfocus();
                                                },
                                                focusNode: _focusNode,
                                                decoration: InputDecoration(
                                                  hintText: 'Type a message...',
                                                ),
                                              ),
                                              // ),
                                            ),
                                      _isRecording
                                          ? SizedBox()
                                          : Row(
                                              children: [
                                                IconButton(
                                                  icon: Icon(
                                                      Icons.attachment_outlined,
                                                      color: Colors.purple),
                                                  onPressed: _pickFileany,
                                                ),
                                                IconButton(
                                                  icon: Icon(
                                                      Icons.add_a_photo_rounded,
                                                      color: Colors.purple),
                                                  onPressed: _selectimage,
                                                ),
                                                IconButton(
                                                  icon: Icon(Icons.send,
                                                      color: Colors.purple),
                                                  onPressed: _sendMessage,
                                                ),
                                              ],
                                            ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class MessageBubble extends StatefulWidget {
  final String message;
  final String sender;
  final bool isMe;
  final String type;
  final Timestamp timestamp;
  final String link;
    final String mid;
  final String gid;
  //final Duration recording;
  final bool isURL;

  MessageBubble(
      {required this.message,
      required this.sender,
      required this.isMe,
      required this.type,
      required this.link,
      required this.mid,
      required this.gid,
      //  required this.recording,
      required this.timestamp,
      required this.isURL});

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  // late VideoPlayerController _videoPlayerController;
  // late ChewieController _chewieController;

  // bool _isPlaying = false; // <-- track whether the audio is playing
  // AudioPlayer _audioPlayer =
  //     AudioPlayer(); // <-- create an instance of AudioPlayer
  void copyText(String text) async {
    FlutterClipboard.copy(text).then((value) => print('copied'));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Text copied to clipboard')),
    );
  }

  bool isurl = false;
  bool isURL(String string) {
    return (string.contains('http', 0) ||
        string.contains('www') ||
        string.contains('https', 0) ||
        string.contains('.com'));
  }

  @override
  void dispose() {
    super.dispose();
    // _audioPlayer.dispose();
    if (widget.type == "video") {
      // _chewieController.dispose();
      // _videoPlayerController.dispose();
    }
  }

  @override
  void initState() {
    super.initState();
    isURL(widget.message);
    // if (widget.type == "video") {
    //   _videoPlayerController = VideoPlayerController.network(widget.link);
    //   _chewieController = ChewieController(
    //     videoPlayerController: _videoPlayerController,
    //     autoInitialize: true,
    //     looping: false,
    //     autoPlay: false,
    //   );
    // }
  }

  Future<void> _downloadAndOpenVideo(String url) async {
    final anchorElement = html.AnchorElement(href: url);

    // Set the download attribute to specify the filename
    anchorElement.download = '';
     anchorElement.target = '_blank';

    // Simulate a click on the anchor element to trigger the download
    anchorElement.click();
  }

  Future<void> downloadAndOpenFile(String url, String fileName) async {
    final anchorElement = html.AnchorElement(href: url);

    // Set the download attribute to specify the filename
    anchorElement.download = '';
     anchorElement.target = '_blank';

    // Simulate a click on the anchor element to trigger the download
    anchorElement.click();
  }

  @override
  Widget build(BuildContext context) {
    void _showMaximizedImage(url) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: InteractiveViewer(
              boundaryMargin: EdgeInsets.all(20),
              minScale: 0.5,
              maxScale: 4.0,
              child: CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ).then((value) {
        setState(() {
          //  _isMaximized = false;
        });
      });
    }

    return Column(
      crossAxisAlignment:
          widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          "${DateFormat('MMMM d, y').format(widget.timestamp.toDate())}",
          style: TextStyle(
            color: Colors.black,
            fontSize: 12,
          ),
        ),
        Row(
          mainAxisAlignment:
              widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: widget.isMe
                    ? Color.fromARGB(255, 254, 161, 84)
                    : Color.fromRGBO(252, 207, 45, 0.988),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                  bottomLeft:
                      widget.isMe ? Radius.circular(12) : Radius.circular(0),
                  bottomRight:
                      widget.isMe ? Radius.circular(0) : Radius.circular(12),
                ),
              ),
              constraints: BoxConstraints(maxWidth: 300),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: Column(
                crossAxisAlignment: widget.isMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.sender,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  widget.type == 'text'
                      ? widget.isURL
                          ? Column(
                              children: [
                                // Container(
                                //   height: 300,
                                //   child: HtmlElementView(
                                //     viewType: 'webview-type',
                                //     key: UniqueKey(),
                                //   ),
                                // ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextButton(
                                        onPressed: () {
                                          if (widget.message
                                              .contains('https://')) {
                                            html.window
                                                .open(widget.message, '_blank');
                                          } else {
                                            html.window.open(
                                                'https://' + widget.message,
                                                '_blank');
                                          }
                                        },
                                        child: Text(
                                          widget.message,
                                          style: TextStyle(
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.copy),
                                      onPressed: () {
                                        copyText(widget.message);
                                      },
                                    ),
                                     IconButton(
                                          icon: Icon(
                                            Icons.delete,
                                            color: Colors.red[700],
                                          ),
                                          onPressed: () {
                                           deletemessage(widget.mid);
                                          },
                                        ),
                                  ],
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    widget.message,
                                    style: TextStyle(
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  iconSize: 10,
                                  icon: Icon(Icons.copy),
                                  onPressed: () {
                                    copyText(widget.message);
                                  },
                                ),
                                   widget.isMe
                                      ? IconButton(
                                          icon: Icon(
                                            Icons.delete,
                                            color: Colors.red[700],
                                          ),
                                          onPressed: () {
                                       deletemessage(widget.mid);
                                          },
                                        ):
                                        SizedBox()
                              ],
                            )
                      : widget.type == 'image'
                          ? Column(
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    setState(() {
                                      _showMaximizedImage(widget.link);
                                    });
                                  },
                                  child: CachedNetworkImage(
                                    imageUrl: widget.link,
                                    placeholder: (context, url) =>
                                        CircularProgressIndicator(),
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.error),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(height: 8.0),
                                Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 100),
                                                child: TextButton(
                                                  child:
                                                      Text('View in Gallery'),
                                                  onPressed: () {
                                                    _downloadAndOpenVideo(
                                                        widget.link);
                                                  },
                                                ),
                                              ),
                                              widget.isMe
                                                  ? IconButton(
                                                      icon: Icon(
                                                        Icons.delete,
                                                        color: Colors.red[700],
                                                      ),
                                                      onPressed: () {
                                                        deletemessage(
                                                            widget.mid);
                                                      },
                                                    )
                                                  : SizedBox()
                                            ],
                                          ),
                              ],
                            )
                          : widget.type == 'audio'
                              ? Container(
                                  width: 300,
                                  child: AudioPlayerWidget(
                                      isMe: widget.isMe,
                                     mid: widget.mid,
                                        gid: widget.gid,
                                    audioUrl: widget.link,
                                    //     recording: widget.recording
                                  ),
                                )
                              : widget.type == 'video'
                                  ? Container(
                                      width: 300,
                                      child: Column(
                                        children: [
                                          SizedBox(
                                              height: 300,
                                              child: VideoPlayerWidget(
                                                link: widget.link,
                                              )),
                                          SizedBox(height: 8.0),
                                          TextButton(
                                            child: Text('View in Gallery'),
                                            onPressed: () {
                                              _downloadAndOpenVideo(
                                                  widget.link);
                                            },
                                          ),
                                             widget.isMe
                                                  ? IconButton(
                                                      icon: Icon(
                                                        Icons.delete,
                                                        color: Colors.red[700],
                                                      ),
                                                      onPressed: () {
                                                        deletemessage(
                                                            widget.mid);
                                                      },
                                                    )
                                                  : SizedBox()
                                        ],
                                      ),
                                    )
                                  // ? Column(
                                  //     children: [
                                  //       SizedBox(
                                  //         height: 300,
                                  //         width: 314,
                                  //         child: Chewie(
                                  //           controller: _chewieController,
                                  //         ),
                                  //       ),
                                  //       SizedBox(height: 8.0),
                                  //       TextButton(
                                  //         child: Text('View in Gallery'),
                                  //         onPressed: () {
                                  //           _downloadAndOpenVideo(widget.link);
                                  //         },
                                  //       ),
                                  //     ],
                                  //   )
                                  : SizedBox(
                                      // height: 20,
                                      //  width: 50,
                                      child: Column(
                                        children: [
                                          TextButton(
                                            child: Text(
                                              '${widget.message} - View file',
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            onPressed: () {
                                              downloadAndOpenFile(
                                                  widget.link, widget.message);
                                            },
                                          ),
                                           widget.isMe
                                                  ? IconButton(
                                                      icon: Icon(
                                                        Icons.delete,
                                                        color: Colors.red[700],
                                                      ),
                                                      onPressed: () {
                                                        deletemessage(
                                                            widget.mid);
                                                      },
                                                    )
                                                  : SizedBox()
                                        ],
                                      ),
                                    ),
                  SizedBox(height: 4),
                  Text(
                    "${DateFormat('h:mm a').format(widget.timestamp.toDate())}",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
   void deletemessage(String mid) {
    FirebaseFirestore.instance
        .collection("groups_dataly")
        .doc(widget.gid)
        .collection("chats")
        .doc(mid)
        .delete();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Message Deleted')),
    );
  }

}

class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;
   final String mid;
  final String gid;
  final bool isMe;
  //final Duration recording;
  const AudioPlayerWidget({
    Key? key,
    required this.audioUrl,
     required this.mid, required this.gid,required this.isMe
    
    //required this.recording
  }) : super(key: key);

  @override
  _AudioPlayerWidgetState createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _audioPlayer;
  Duration _totalDuration = Duration.zero;
  Duration _currentPosition = Duration.zero;
  bool _isPlaying = false;
  bool first = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initializeAudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _initializeAudioPlayer() async {
    await _audioPlayer.setSourceUrl(widget.audioUrl);

    _audioPlayer.onPositionChanged.listen((event) {
      setState(() {
        _currentPosition = event;
      });
    });
    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        first = false;
        _isPlaying = false;
      });
    });
    _totalDuration =
            // widget.recording==Duration.zero?
            (await _audioPlayer.getDuration())!
        // !:widget.recording
        ;
    print(_totalDuration);
    // _audioPlayer.onPlayerStateChanged.listen((event) {
    //   setState(() {
    //     _isPlaying = event == PlayerState.PLAYING;
    //   });
    // });
  }

  Future<void> _togglePlayback() async {
    if (first) {
      if (_isPlaying) {
        await _audioPlayer.pause();
        _isPlaying = !_isPlaying;
      } else {
        await _audioPlayer.resume();
        _isPlaying = !_isPlaying;
      }
    } else {
      _audioPlayer.play(UrlSource(widget.audioUrl));
      first = true;
      _isPlaying = true;
    }
  }

  Future<void> _stop() async {
    await _audioPlayer.stop();
    setState(() {
      _currentPosition = Duration.zero;
      first = false;
    });
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                    onPressed: _togglePlayback,
                  ),
                  IconButton(
                    icon: Icon(Icons.stop),
                    onPressed: _stop,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_formatDuration(_currentPosition)),
                  SizedBox(width: 10),
                  Text('/'),
                  SizedBox(width: 10),
                  Text(_formatDuration(_totalDuration)),
                        widget.isMe
                  ? IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: Colors.red[700],
                       // size: 10,
                      ),
                      onPressed: () {
                        deletemessage(widget.mid);
                      },
                    )
                  : SizedBox()
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                value: _totalDuration != Duration.zero
                    ? _currentPosition.inMilliseconds /
                        _totalDuration.inMilliseconds
                    : 0.0,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                backgroundColor: Colors.grey[300],
              ),
            ),
          ),
        ],
      ),
    );
  }
   void deletemessage(String mid) {
    FirebaseFirestore.instance
        .collection("groups_dataly")
        .doc(widget.gid)
        .collection("chats")
        .doc(mid)
        .delete();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Message Deleted')),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String link;
  const VideoPlayerWidget({Key? key, required this.link}) : super(key: key);

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;

  @override
  void initState() {
    _videoPlayerController = VideoPlayerController.network(widget.link);
    _chewieController = ChewieController(
      showOptions: false,
      videoPlayerController: _videoPlayerController,
      autoInitialize: true,
      looping: false,
      autoPlay: false,
    );
  }

  @override
  void dispose() {
    super.dispose();

    _chewieController.dispose();
    _videoPlayerController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Chewie(controller: _chewieController);
  }
}
