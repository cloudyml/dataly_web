import 'package:cloudyml_app2/authentication/onboardbg.dart';
import 'package:cloudyml_app2/screens/config.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:record/record.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

//import 'package:flutter_sound/flutter_sound.dart';

class ChatScreen extends StatefulWidget {
  final String id;
  final String groupId;
  final String role;
  final String name;
  final String icon;
  final String title;
  // final String number;

  ChatScreen({
    required this.id,
    required this.groupId,
    required this.role,
    required this.name,
    required this.title,
    required this.icon,
    //  required this.number ,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FocusNode _focusNode = FocusNode();
  File? _selectedFile;
  String? _downloadUrl;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  final _textController = TextEditingController();
  late IO.Socket _socket;
  Record record = Record();
  Directory? appStorage;
  bool _isRecording = false;
  //FlutterSoundRecorder _audioRecorder = FlutterSoundRecorder();
  String _audioPath = 'path/to/audio/file.mp3';
  final _firebaseStorage = FirebaseStorage.instance;

  File? pickedFile;

  String? pickedFileName;

  void _getAppStorageDir() async {
    appStorage = await getApplicationDocumentsDirectory();
  }

  bool containsSingleURL(String input) {
    final regex = RegExp(
        r"(https?://(?:www\.)?[^\s]+)", // Regular expression to match URLs
        caseSensitive: false);

    final matches = regex.allMatches(input);
    final urls = matches.map((match) => match.group(0)!).toList();

    return urls.length == 1;
  }

  Future<void> _startRecording() async {
    _getAppStorageDir();
    print("REcording....");
    if (await Record().hasPermission()) {
      setState(() {
        _isRecording = true;
      });

      await record.start(
        path: appStorage!.path.toString() +
            "/audio_${DateTime.now().millisecondsSinceEpoch}.m4a",
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        samplingRate: 44100,
      );
    }
  }

  void _stopRecording() async {
    if (_isRecording) {
      var filePath = await Record().stop();
      print("The audio file path is $filePath");
      pickedFile = File(filePath!);
      pickedFileName = filePath.split("/").last;
      setState(() {
        _isRecording = false;
      });

      _uploadRecording(pickedFile!);
    }
  }

  void _cancelRecording() async {
    if (_isRecording) {
      var filePath = await Record().stop();
      var recordedFile = File(filePath.toString());
      if (await recordedFile.exists()) {
        await recordedFile.delete();
      }
      setState(() {
        _isRecording = false;
      });
    }
  }

  void updatetime(DateTime time, String message) {
    _firestore.collection("groups_dataly").doc(widget.groupId).update({'time': time});
    _firestore
        .collection("groups_dataly")
        .doc(widget.groupId)
        .update({'lastmessage': message});
  }

  void updatelast() {
    _firestore
        .collection("groups_dataly")
        .doc(widget.groupId)
        .update({'last': FirebaseAuth.instance.currentUser!.uid.toString()});
  }

  Future<String> _uploadRecording(File recording) async {
    final storageRef =
        _firebaseStorage.ref().child('audio/${DateTime.now()}.mp3');

    try {
      await storageRef.putFile(recording);
      final downloadUrl = await storageRef.getDownloadURL();
      print('File uploaded: $downloadUrl');
      final time = DateTime.now();
      // Add message to Firestore

     // DateTime time1 = await fetchTimeInIndia();

      print(time);
      //print(time1.toString());
      updatelast();
      updatetime(time, "audio recieved");
      _firestore
          .collection("groups_dataly")
          .doc(widget.groupId)
          .collection("chats")
          .add({
        'message': '${DateTime.now()}.mp3',
        'role': widget.role,
        'sendBy': widget.name,
        'link': downloadUrl,
        'studentid': widget.id,
        'time': time,
        'type': 'audio'
      });

      return downloadUrl;
    } catch (e) {
      print('Error uploading file: $e');
      throw 'Failed to upload recording';
    }
  }

  Widget _buildMicButton() {
    return IconButton(
      icon: Icon(Icons.mic_none_rounded, color: Colors.purple),
      onPressed: _startRecording,
    );
  }

  bool checktext(String string) {
    final links = ['http://', 'https://'];
    int count = 0;
    
    for (final link in links) {
      int index = string.indexOf(link);
      while (index != -1) {
        count++;
        index = string.indexOf(link, index + link.length);
      }
    }
    print(count);
    return count == 1 || count == 0;

//  final regex = RegExp(r'(http[s]?:\/\/)?(www\.)?[^\s(["<,>]*\.[^\s[",><]*)');
//   final matches = regex.allMatches(string);
//  // return matches.length;
//     return matches.length == 1 || matches.length == 0;
    // RegExp urlRegex = RegExp(r'(https?://\S+)');
    // List<String> urls =
    //     urlRegex.allMatches(string).map((match) => match.group(0)!).toList();
    // return (urls.length == 1 || urls.length == 0);
  }

  bool isURL(String string) {
    bool containsURL = string.contains('http', 0) ||
        string.contains('www') ||
        string.contains('https', 0) ||
        string.contains('.com');

    return containsURL;
  }

  Future<DateTime> fetchTimeInIndia() async {
    final response = await http
        .get(Uri.parse('http://worldtimeapi.org/api/timezone/Asia/Kolkata'));
    final jsonData = json.decode(response.body);
    final datetime = jsonData['datetime'];
    final offset = jsonData['utc_offset'];
    final parsedDateTime = DateTime.parse(datetime).toUtc();
    return parsedDateTime;
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

  error() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Text copied to clipboard')),
    );
  }

  Widget _buildAudioPlayer() {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.play_arrow_rounded, color: Colors.purple),
          onPressed: () {
            // logic for playing the audio file
          },
        ),
        IconButton(
            icon: Icon(Icons.send, color: Colors.purple),
            onPressed: containsSingleURL(_textController.text)
                ? _sendMessage
                : error()),
      ],
    );
  }

  Future<void> _pickFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });

      // Upload the file to Firebase Storage
      Reference ref =
          FirebaseStorage.instance.ref().child('files/${_selectedFile!.path}');
      UploadTask uploadTask = ref.putFile(_selectedFile!);
      TaskSnapshot snapshot = await uploadTask;
      _downloadUrl = await snapshot.ref.getDownloadURL();
      final time = DateTime.now();
      // Add message to Firestore

     // DateTime time1 = await fetchTimeInIndia();

      print(time);
     // print(time1.toString());
      updatelast();
      updatetime(time, "image recieved");

      _firestore
          .collection("groups_dataly")
          .doc(widget.groupId)
          .collection("chats")
          .add({
        'message': _selectedFile!.path.split('/').last,
        'role': widget.role,
        'sendBy': widget.name,
        'link': _downloadUrl,
        'studentid': widget.id,
        'time': time,
        'type': 'image'
      });
    }
  }

  Future<void> _pickFilePhoto() async {
    final imagePicker = ImagePicker();

    final pickedFile = await imagePicker.getImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _selectedFile = File(pickedFile.path);
      });

      // Upload the file to Firebase Storage
      Reference ref =
          FirebaseStorage.instance.ref().child('files/${_selectedFile!.path}');
      UploadTask uploadTask = ref.putFile(_selectedFile!);
      TaskSnapshot snapshot = await uploadTask;
      _downloadUrl = await snapshot.ref.getDownloadURL();
      final time = DateTime.now();
      // Add message to Firestore

      //DateTime time1 = await fetchTimeInIndia();

      print(time);
      //print(time1.toString());
      updatelast();
      updatetime(time, "image recieved");

      _firestore
          .collection("groups_dataly")
          .doc(widget.groupId)
          .collection("chats")
          .add({
        'message': _selectedFile!.path.split('/').last,
        'role': widget.role,
        'sendBy': widget.name,
        'link': _downloadUrl,
        'studentid': widget.id,
        'time': time,
        'type': 'image'
      });
    }
  }

  Future<void> _pickFileRecord() async {
    final imagePicker = ImagePicker();

    final pickedFile = await imagePicker.getVideo(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _selectedFile = File(pickedFile.path);
      });

      // Upload the file to Firebase Storage
      Reference ref =
          FirebaseStorage.instance.ref().child('files/${_selectedFile!.path}');
      UploadTask uploadTask = ref.putFile(_selectedFile!);
      TaskSnapshot snapshot = await uploadTask;
      _downloadUrl = await snapshot.ref.getDownloadURL();
      final time = DateTime.now();
      // Add message to Firestore

    //  DateTime time1 = await fetchTimeInIndia();

      print(time);
      //print(time1.toString());
      updatelast();
      updatetime(time, "video recieved");

      _firestore
          .collection("groups_dataly")
          .doc(widget.groupId)
          .collection("chats")
          .add({
        'message': _selectedFile!.path.split('/').last,
        'role': widget.role,
        'sendBy': widget.name,
        'link': _downloadUrl,
        'studentid': widget.id,
        'time': time,
        'type': 'video'
      });
    }
  }

  Future<void> _pickFilevideo() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.video);

    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });

      // Upload the file to Firebase Storage
      Reference ref =
          FirebaseStorage.instance.ref().child('files/${_selectedFile!.path}');
      UploadTask uploadTask = ref.putFile(_selectedFile!);
      TaskSnapshot snapshot = await uploadTask;
      _downloadUrl = await snapshot.ref.getDownloadURL();
      final time = DateTime.now();
      // Add message to Firestore

    //  DateTime time1 = await fetchTimeInIndia();

      print(time);
    //  print(time1.toString());
      updatelast();
      updatetime(time, "video recieved");

      _firestore
          .collection("groups_dataly")
          .doc(widget.groupId)
          .collection("chats")
          .add({
        'message': _selectedFile!.path.split('/').last,
        'role': widget.role,
        'sendBy': widget.name,
        'link': _downloadUrl,
        'studentid': widget.id,
        'time': time,
        'type': 'video'
      });
    }
  }

  Future<void> _pickFileany() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: [
        'doc',
        'docx',
        'pdf',
        'txt',
        'ppt',
        'pptx',
        'xls',
        'xlsx',
        'csv',
        'tsv',
        'json',
        'xml',
        'yaml',
        'sql',
        'r',
        'py',
        'ipynb',
        'mp3',
        'wav',
        'flac',
        'ogg',
        'aac',
        'wma',
        'm4a',
        'opus',
        'mid',
        'amr',
        'aiff',
        'ape',
        'caf',
        'mka',
        'pcm',
        'ac3',
        'alac',
        'au',
        'dts',
        'eac3',
        'gsm',
        'mp1',
        'mp2',
        'mpa',
        'ra',
        'tta',
        'wv',
        'webm',
        '3ga',
        '3gpa',
        '3gp',
        'aif',
        'oga',
        'oma',
        'spx',
        'xmf',
        'mogg',
        'mod',
        'mo3',
        'mtm',
        'umx',
        'it',
        's3m',
        'xm',
        'sid',
      ],
    );

    if (result != null) {
      for (var file in result.files) {
        setState(() {
          _selectedFile = File(file.path!);
        });

        // Upload the file to Firebase Storage
        Reference ref = FirebaseStorage.instance
            .ref()
            .child('files/${_selectedFile!.path}');
        UploadTask uploadTask = ref.putFile(_selectedFile!);
        TaskSnapshot snapshot = await uploadTask;
        _downloadUrl = await snapshot.ref.getDownloadURL();
        final time = DateTime.now();
        // Add message to Firestore

       // DateTime time1 = await fetchTimeInIndia();

        print(time);
      //  print(time1.toString());
        updatelast();
        updatetime(time, "file recieved");
        _firestore
            .collection("groups_dataly")
            .doc(widget.groupId)
            .collection("chats")
            .add({
          'message': _selectedFile!.path.split('/').last,
          'role': widget.role,
          'sendBy': widget.name,
          'link': _downloadUrl,
          'studentid': widget.id,
          'time': time,
          'type': 'file'
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // _socket = IO.io('http://3.110.108.153:8000/');
    _connectToServer();
    print(loadata());
  }

  @override
  void dispose() {
    // disconnect from the socket server
    Configuration.docid = '';
    _socket.disconnect();
    super.dispose();
  }

  void _connectToServer() {
    _socket =
        IO.io("http://3.110.108.153:8000/student-namespace", <String, dynamic>{
      "transports": ["websocket"],
      "autoConnect": false,
    });
    _socket.connect();
    var userData = {'userId': widget.id, 'groupId': widget.groupId};
    //_socket.emit("signin", widget.sourchat.id);
    _socket.emit('join', userData);
    _socket.on('join', (data) {
      print(
          "socket sucessfully connected and socket id is ${data['socketID']}");
    });
  }

  void sendtext() {}
  void _handleNewMessage(data) {
    var userDatawithmessage = {
      "userID": widget.id,
      "groupID": widget.groupId,
      "message": data
    };
    _socket.emit('sendMessage', userDatawithmessage);
  }

  void _sendMessage() async {
    String message =
        _textController.text.trim(); // Trim leading and trailing spaces
    if (!checktext(_textController.text.toString())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please send one link at a time')),
      );
    } else if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Message cannot be empty')),
      );
    } else {
      String data = _textController.text;

      _focusNode.unfocus();
      String id = widget.groupId; // mentor Id
      String student_id = widget.id;
      _textController.clear();
      // here student_id will come from frontEnd  socket.handshake.auth.student_id4
     // DateTime time1 = await fetchTimeInIndia();
      final time = DateTime.now();
      print(time);
     // print(time1.toString());
      updatelast();
      updatetime(time, _textController.text);
      final post = await _firestore
          .collection("groups_dataly")
          .doc(id)
          .collection("chats")
          .add({
        'message': data,
        'role': widget.role,
        'sendBy': widget.name,
        'studentid': widget.id,
        'time': time,
        'type': 'text'
      });

      //   });
      // } else {}
      // _socket.emit('message', {
      //   'text': _textController.text,
      //   'sender': widget.id,
      //   'groupId': widget.groupId,
      // });
    }
  }

  Stream<QuerySnapshot> loadata() {
    return FirebaseFirestore.instance
        .collection("groups_dataly")
        .doc(widget.groupId)
        .collection("chats")
        .orderBy('timestamp')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> _collectionStream = FirebaseFirestore.instance
        .collection("groups_dataly")
        .doc(widget.groupId)
        .collection("chats")
        .orderBy('time', descending: true)
        .limit(100)
        .snapshots();
    return Scaffold(
      body: Stack(
        children: [
          Container(
              width: 100.w,
              child: Image.asset(
                "images/bgimg.png",
                fit: BoxFit.fitWidth,
              )),
          Padding(
            padding: EdgeInsets.only(top: 7.h, left: 6.w),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 2.w),
                  child: SizedBox(
                    width: 15.w,
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        weight: 500,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
                CircleAvatar(
                  radius: 22.sp,
                  backgroundColor: Colors.black,
                  child: CircleAvatar(
                    radius: 20.sp,
                    backgroundImage: AssetImage("images/icon.jpeg"),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 5.w),
                  child: SizedBox(
                    width: 55.w,
                    child: Text(
                      "${widget.title}",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                      style: TextStyle(
                        shadows: <Shadow>[
                          Shadow(
                            offset: Offset(2.0, 2.0),
                            blurRadius: 6.0,
                            color: Color.fromARGB(100, 0, 0, 0),
                          ),
                        ],
                        fontFamily: 'Inter',
                        fontSize: 10.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 15.h),
            child: Container(
              width: 100.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40.sp),
                    topRight: Radius.circular(40.sp)),
                color: Colors.white,
              ),
              child: Column(
                children: [
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _collectionStream,
                      builder: (context, snapshot) {
                        print(
                          FirebaseFirestore.instance
                              .collection("groups_dataly")
                              .doc(widget.groupId)
                              .collection("chats")
                              .orderBy('time', descending: true)
                              .snapshots(),
                        );
                        if (snapshot.hasError) {
                          print("snaphot.error");
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

                        print('Number of documents: ${messages.length}');
                        List<MessageBubble> messageBubbles = [];
                        for (var message in messages) {
                          final data = message.data() as Map<String, dynamic>;
                          final messageText = message['message'];
                          final messageSender = message['sendBy'];
                          final messageType = message['type'];
                          final messagetime = message['time'];
                          final currentUser = widget.id;
                          final mid = message.id;
                          final gid = widget.groupId;
                          final messageid = data.containsKey('studentid')
                              ? message['studentid']
                              : "old message";
                              
                          final link = messageType == "image" ||
                                  messageType == "audio" ||
                                  messageType == "video" ||
                                  messageType == "file"
                              ? message["link"]
                              : "";

                          final messageBubble = MessageBubble(
                              message: messageText,
                              sender: messageSender,
                              timestamp: messagetime,
                              mid: mid,
                              gid: gid,
                              isMe: (messageSender == widget.name) &&
                                  (messageid == "old message"
                                      ? true
                                      : messageid == currentUser
                                          ? true
                                          : false),
                              link: link,
                              type: messageType,
                              isURL: isURL(messageText));
                          messageBubbles.add(messageBubble);
                        }
                        return SingleChildScrollView(
                          child: Padding(
                            padding: EdgeInsets.only(
                                top: 5.h,
                                bottom: _focusNode.hasFocus ? 30.h : 100.h),
                            child: Column(
                              children: [
                                Container(
                                  height: 70.h,
                                  width: 100.h,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(40.sp),
                                        topRight: Radius.circular(40.sp)),
                                    color: Colors.white,
                                  ),
                                  // child:
                                  //     Padding(
                                  //       padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom,),
                                  child: ListView(
                                    reverse: true,
                                    children: messageBubbles,
                                  ),
                                ),

                                //),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        _isRecording
                            ? _buildStopRecordingButton()
                            : _buildMicButton(),
                        _isRecording
                            ? _buildCancelButton()
                            : Expanded(
                                child: LimitedBox(
                                  maxHeight: 4 *
                                          TextField().maxLines!.toInt() *
                                          (TextStyle().fontSize ?? 14.0) +
                                      16.0,
                                  child: TextField(
                                    maxLines: null,
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
                                ),
                              ),
                        _isRecording
                            ? SizedBox()
                            : Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.attachment_outlined,
                                        color: Colors.purple),
                                    onPressed: _pickFileany,
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.add_a_photo_rounded,
                                        color: Colors.purple),
                                    onPressed: _selectimage,
                                  ),
                                ],
                              ),
                        _isRecording
                            ? SizedBox()
                            : IconButton(
                                icon: Icon(Icons.send, color: Colors.purple),
                                onPressed: _sendMessage,
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
                title: Text('Click Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFilePhoto();
                },
              ),
              ListTile(
                leading: Icon(Icons.image),
                title: Text('Record Video'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFileRecord();
                },
              ),
              ListTile(
                leading: Icon(Icons.image),
                title: Text('Select Image'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFile();
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
}

class MessageBubble extends StatefulWidget {
  final String message;
  final String sender;
  final bool isMe;
  final String type;
  final Timestamp timestamp;
  final String link;
  final bool isURL;
  final String mid;
  final String gid;

  MessageBubble(
      {required this.message,
      required this.sender,
      required this.isMe,
      required this.type,
      required this.link,
      required this.mid,
      required this.timestamp,
      required this.isURL,
      required this.gid});

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  bool _isPlaying = false; // <-- track whether the audio is playing
  AudioPlayer _audioPlayer =
      AudioPlayer(); // <-- create an instance of AudioPlayer
  void copyText(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Text copied to clipboard')),
    );
  }

  bool isurl = false;
  bool isURL(String string) {
    // Regular expression pattern to match a URL
    // Regular expression pattern to match a URL
    return (string.contains('http', 0) ||
        string.contains('www') ||
        string.contains('https', 0) ||
        string.contains('.com'));
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void initState() {
    super.initState();
    isURL(widget.message);
  }

  Future<void> _downloadAndOpenVideo(String url) async {
    final cacheManager = DefaultCacheManager();
    final file = await cacheManager.getSingleFile(url);

    final appDocDir = await getTemporaryDirectory();
    final filePath = '${appDocDir.path}/video.mp4';
    await file.copy(filePath);
    OpenFilex.open(filePath);
    //  OpenFile.open(filePath);
  }

  Future<void> downloadAndOpenFile(String url, String fileName) async {
    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/$fileName';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      OpenFilex.open(filePath);
      // await OpenFile.open(filePath);
    }
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

    String extractURL(String input) {
      final words = input.split(' ');
      for (final word in words) {
        if (word.startsWith('http://') ||
            word.startsWith('https://') ||
            word.startsWith('www.')) {
          return word;
        }
      }
      return words[0];
    }

    return Column(
      crossAxisAlignment:
          widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          "${DateFormat('MMMM d, y').format(widget.timestamp.toDate())}",
          style: TextStyle(
            color: Colors.grey,
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
                    ? Color.fromRGBO(255, 137, 51, 0.6)
                    : Color.fromRGBO(255, 199, 0, 0.6),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                  bottomLeft:
                      widget.isMe ? Radius.circular(12) : Radius.circular(0),
                  bottomRight:
                      widget.isMe ? Radius.circular(0) : Radius.circular(12),
                ),
              ),
              //constraints: BoxConstraints(maxWidth: 300),
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
                                Container(
                                  width: 300,
                                  child: Column(children: [
                                    Container(
                                      height: 300,
                                      child: InAppWebView(
                                        initialUrlRequest: URLRequest(
                                          url: Uri.parse(
                                              extractURL(widget.message)),
                                        ),
                                        initialOptions:
                                            InAppWebViewGroupOptions(
                                          crossPlatform: InAppWebViewOptions(
                                            useShouldOverrideUrlLoading: true,
                                            mediaPlaybackRequiresUserGesture:
                                                false,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () {
                                              launch(widget.message);
                                            },
                                            child: HighlightedText(
                                                text: widget.message,
                                                highlight:
                                                    extractURL(widget.message)),
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
                                  ]),
                                ),
                              ],
                            )
                          : Container(
                              constraints:
                                  BoxConstraints(maxWidth: 300, minWidth: 0),
                              //  width: 300,
                              child: Row(
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
                                        )
                                      : SizedBox(),
                                ],
                              ),
                            )
                      : widget.type == 'image'
                          ? Container(
                              width: 300,
                              child: Column(
                                children: [
                                  GestureDetector(
                                    onTap: () async {
                                      setState(() {
                                        _showMaximizedImage(widget.link);
                                      });
                                    },
                                    child: CachedNetworkImage(
                                      width: 300,
                                      height: 300,
                                      imageUrl: widget.link,
                                      placeholder: (context, url) =>
                                          CircularProgressIndicator(),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ),
                                  SizedBox(height: 8.0),
                                  Center(
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 100),
                                          child: TextButton(
                                            child: Text('View in Gallery'),
                                            onPressed: () {
                                              downloadAndOpenFile(
                                                  widget.link, widget.message);
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
                                                  deletemessage(widget.mid);
                                                },
                                              )
                                            : SizedBox(),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : widget.type == 'audio'
                              ? Row(
                                  children: [
                                    AudioPlayerWidget(
                                        audioUrl: widget.link,
                                        mid: widget.mid,
                                        gid: widget.gid,
                                        isMe: widget.isMe
                                        ),
                                  ],
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
                                      ),
                                    )
                                  : SizedBox(
                                      width: 300,
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
                  Row(
                    children: [
                      Text(
                        "${DateFormat('h:mm a').format(widget.timestamp.toDate())}",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  void deletemessage(String messageid) {
    FirebaseFirestore.instance
        .collection("groups_dataly")
        .doc(widget.gid)
        .collection("chats")
        .doc(messageid)
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
  const AudioPlayerWidget(
      {Key? key, required this.audioUrl, required this.mid, required this.gid,required this.isMe})
      : super(key: key);

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

    _totalDuration = (await _audioPlayer.getDuration())!;

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
        videoPlayerController: _videoPlayerController,
        autoInitialize: true,
        looping: false,
        autoPlay: false,
        showOptions: false,
        allowPlaybackSpeedChanging: false);
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

class HighlightedText extends StatefulWidget {
  final String text;
  final String highlight;

  const HighlightedText({required this.text, required this.highlight});

  @override
  State<HighlightedText> createState() => _HighlightedTextState();
}

class _HighlightedTextState extends State<HighlightedText> {
  @override
  Widget build(BuildContext context) {
    final TextStyle highlightedStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18,
      color: Colors.blue, // Customize the highlighting color
    );

    final List<TextSpan> textSpans = [];

    final List<String> words = widget.text.split(' ');

    for (String word in words) {
      if (word.contains(widget.highlight)) {
        textSpans.add(
          TextSpan(
            text: word,
            style: highlightedStyle,
          ),
        );
      } else {
        textSpans.add(
          TextSpan(
              text: word, style: TextStyle(color: Colors.black, fontSize: 17)),
        );
      }
      textSpans.add(TextSpan(text: ' '));
    }

    return RichText(
      text: TextSpan(
        children: textSpans,
      ),
    );
  }
}
