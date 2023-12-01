import 'package:cloudyml_app2/Services/local_notificationservice.dart';
import 'package:cloudyml_app2/screens/chatscreen.dart';
import 'package:cloudyml_app2/screens/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:sizer/sizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ntp/ntp.dart';

class GroupPage extends StatefulWidget { 
  Map<String, dynamic>? groupData;
  Map? userData;
  GroupPage({this.groupData, this.userData});
  @override
  State<GroupPage> createState() => _GroupPageState();
}

final int _pageSize = 100;
String? _lastVisibleIndex;
DateTime now = DateTime.now();
List<dynamic> names = [];
List<dynamic> images = [];
List<String> groupIds = [];
List<String> names1 = [];
List<String> images1 = [];
List<String> groupIds1 = [];

class _GroupPageState extends State<GroupPage> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = false;
  String name =
      FirebaseAuth.instance.currentUser!.displayName.toString().split(" ")[0];
  TextEditingController _searchController = TextEditingController();
  String role = "";
  List<dynamic> coursecode = [];
  List<String> coursename = [];
  List<String> cname = [];
  List<DateTime> time = [];
  Set<String> _updatedDocuments = {};
  Set<String> newdocuments = {};

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
  Future<List<String>> loadcoursedata() async {
    names1.clear();

    final snapshot = await FirebaseFirestore.instance
        .collection('groups')
        .orderBy('time', descending: true)
        .get();
    snapshot.docs.forEach((doc) {
      final name = doc.data()['name'];
      cname.add(name);
    });
    snapshot.docs.forEach((doc) {
      final name = doc.data()['student_name'];
      names1.add(name);
    });
    snapshot.docs.forEach((doc) {
      groupIds1.add(doc.id);
    });
    snapshot.docs.forEach((doc) {
      final name = doc.data()['icon'];
      images1.add(name);
    });

    snapshot.docs.forEach((doc) {
      final Timestamp name = doc.data()['time'];
      if (name == null) {
        time.add(DateTime.now());
      } else {
        time.add(name.toDate());
      }
    });
    print(names1.length);
    print(groupIds1.length);
    print(images1.length);
    print(cname.length);
    print(name);

    return names1;
  }

  Future<List<dynamic>> loadCourses() async {
    setState(() {
      isLoading = true;
    });

    final snapshot = await _firestore
        .collection("Users_dataly")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    final QuerySnapshot groupQuerySnapshot = await FirebaseFirestore.instance
        .collection('groups')
        .where('student_id', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();

    names = groupQuerySnapshot.docs.map((doc) => doc['name']).toList();
    images = groupQuerySnapshot.docs.map((doc) => doc['icon']).toList();
    for (final DocumentSnapshot documentSnapshot in groupQuerySnapshot.docs) {
      groupIds.add(documentSnapshot.id);
    }

    print(groupIds);
    final data = snapshot.data();
    final arrayData = List<String>.from(data!['paidCourseNames']);
    name = data["name"].toString().split(" ")[0];
    role = data["role"];
    print(FirebaseAuth.instance.currentUser!.uid);
    print(arrayData);

    print('courselist is--$data');
    return names;
  }

  void listenToFirestoreChanges() async {
    final snapshot = await _firestore
        .collection("Users_dataly")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    final data = snapshot.data();
    role = data!["role"];
    if (role != "student") {
      //  _filteredStream = _collectionStream;
      name = data!["name"].split(" ")[0];
      ;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? myList = prefs.getStringList('myList');
      if (myList != null) {
        _updatedDocuments = myList.toSet();
      } else {
        _updatedDocuments = Set<String>();
      }
      _collectionStream.listen((snapshot) async {
        //List<String> updatedDocuments = [];
        snapshot.docChanges.forEach((change) {
          if (change.type == DocumentChangeType.modified &&
              Configuration.docid != change.doc.id) {
            DocumentSnapshot changedDoc = change.doc;
            Map<String, dynamic> changedData =
                changedDoc.data() as Map<String, dynamic>;
            if (changedData.containsKey("last")) {
              if (change.doc["last"].toString() ==
                  FirebaseAuth.instance.currentUser!.uid.toString()) {
              } else {
                _updatedDocuments.add(change.doc.id);
                print(_updatedDocuments);
                LocalNotificationService.createanddisplaynotificationmessage(
                    "${change.doc["student_name"]} has a new message",changedData.containsKey("lastmessage")?(change.doc['lastmessage']):"new feature included");
              }
            } else {
              _updatedDocuments.add(change.doc.id);
              print(_updatedDocuments);
               LocalNotificationService.createanddisplaynotificationmessage(
                    "${change.doc["student_name"]} has a new message",changedData.containsKey("lastmessage")?(change.doc['lastmessage']):"new feature included");
              }
          } else if (change.type == DocumentChangeType.added) {
            newdocuments.add(change.doc.id);
          }
        });
        if (_updatedDocuments.isNotEmpty) {
          await prefs.setStringList('myList', _updatedDocuments.toList());
        }
      });

      setState(() {
        isLoading = false;
      });
    }
  }

  void listenToFirestoreChanges1() async {
    final snapshot = await _firestore
        .collection("Users_dataly")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    final data = snapshot.data();
    role = data!["role"];

    if (role == "student") {
      //   _filteredStream = _collectionStream1;
      name = data!["name"];
      SharedPreferences prefs = await SharedPreferences.getInstance();
      print(FirebaseAuth.instance.currentUser!.uid);
      List<String>? myList = prefs.getStringList('myList');
      if (myList != null) {
        _updatedDocuments = myList.toSet();
      } else {
        _updatedDocuments = Set<String>();
      }
      _collectionStream1.listen((snapshot) async {
        //List<String> updatedDocuments = [];
        snapshot.docChanges.forEach((change) {
          if ((change.type == DocumentChangeType.modified &&
              Configuration.docid != change.doc.id)) {
            DocumentSnapshot changedDoc = change.doc;
            Map<String, dynamic> changedData =
                changedDoc.data() as Map<String, dynamic>;
            if (changedData.containsKey("last")) {
              if (change.doc["last"].toString() ==
                  FirebaseAuth.instance.currentUser!.uid.toString()) {
              } else {
                _updatedDocuments.add(change.doc.id);
                print(_updatedDocuments);
                LocalNotificationService.createanddisplaynotificationmessage(
                    "${change.doc["student_name"]} has a new message",changedData.containsKey("lastmessage")?(change.doc['lastmessage']):"new feature included");
              }
            } else {
              _updatedDocuments.add(change.doc.id);
              print(_updatedDocuments);
                LocalNotificationService.createanddisplaynotificationmessage(
                    "${change.doc["student_name"]} has a new message",changedData.containsKey("lastmessage")?(change.doc['lastmessage']):"new feature included");
              }
          }
        });
        if (_updatedDocuments.isNotEmpty) {
          await prefs.setStringList('myList', _updatedDocuments.toList());
        }
      });

      setState(() {
        isLoading = false;
      });
    }
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
  Future<void> checkDeviceTime() async {
    try {
      final now = DateTime.now();
      final ntpTime = await NTP.now();
      final timeDifference = ntpTime.difference(now).inSeconds.abs();

      // Define a threshold for time difference (e.g., 30 seconds) to consider as incorrect.
      final timeThreshold = 30;

      if (timeDifference > timeThreshold) {
        // Device time is incorrect, show a popup to correct it.
        showTimeCorrectionPopup();
      }
    } catch (e) {
      print('Error checking device time: $e');
    }
  }

  void showTimeCorrectionPopup() {
    Fluttertoast.showToast(
      msg: 'Your device time is incorrect. Please correct it.',
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  void showPopup(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return PopupBox(message: message);
    },
  );
}
  bool _isSearching = false;
  @override
  void initState() {
    super.initState();
    //loadrole();
    Configuration.docid = "";
    print("iwejoiweofwoiefwf");
    checkDeviceTime();
    listenToFirestoreChanges();
    listenToFirestoreChanges1();
  }

  @override
  void dispose() {
    // _timer?.cancel(); // cancel the timer to avoid memory leaks
    _collectionStream.drain();
    _collectionStream1.drain();
    super.dispose();
  }

  void _toggleSearchBar() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();

        _collectionStream = FirebaseFirestore.instance
            .collection('groups')
            //  .where('student_id', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            //.where('student_name', isEqualTo: searchText)
            .orderBy('time', descending: true)

            // .where('student_name', isLessThan: csearchText + 'z')
            .limit(500)
            .snapshots();
        ;
      }
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: role != "student"
          ? FloatingActionButton(
              onPressed: _toggleSearchBar,
              child: Icon(Icons.search),
              backgroundColor: Colors.purple,
            )
          : null,
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                        width: 100.w,
                        child: Image.asset(
                          "images/bgimg.png",
                          fit: BoxFit.fitWidth,
                        )),
                    Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 10.h, left: 6.w),
                          child: Row(
                            children: [
                              Text(
                                "Welcome back ,",
                                style: TextStyle(
                                  shadows: <Shadow>[
                                    Shadow(
                                      offset: Offset(2.0, 2.0),
                                      blurRadius: 6.0,
                                      color: Color.fromARGB(100, 0, 0, 0),
                                    ),
                                  ],
                                  fontFamily: 'Inter',
                                  fontSize: 16.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w100,
                                ),
                              ),
                              Text(
                                "$name 👍",
                                style: TextStyle(
                                  shadows: <Shadow>[
                                    Shadow(
                                      offset: Offset(2.0, 2.0),
                                      blurRadius: 6.0,
                                      color: Color.fromARGB(100, 0, 0, 0),
                                    ),
                                  ],
                                  fontFamily: 'Inter',
                                  fontSize: 18.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              left: 4.w, right: 4.w, top: 4.h, bottom: 1.h),
                          child: Text(
                            "You can ask assignment related doubts here\n 6pm- midnight(IST).",
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
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                  
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 27.h),
                      child: Container(
                          height: 75.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(40.sp),
                                topRight: Radius.circular(40.sp)),
                            color: Colors.white,
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset('images/rectangle.png'),
                              ),
                              Padding(
                                padding:
                                    EdgeInsets.only(left: 3.w, bottom: 2.h),
                                child: Container(
                                    height: 70.h,
                                    child: StreamBuilder<QuerySnapshot>(
                                      stream: role == "student"
                                          ? _collectionStream1
                                          : _collectionStream,
                                      builder: (BuildContext context,
                                          AsyncSnapshot<QuerySnapshot>
                                              snapshot) {
                                        if (snapshot.hasError) {
                                          return Text(
                                              'Error: ${snapshot.error}');
                                        }

                                        switch (snapshot.connectionState) {
                                          case ConnectionState.waiting:
                                            return Center(
                                              child: Image.asset(
                                                  "images/loader.gif"),
                                            );
                                          default:
                                            return ListView.builder(
                                              itemCount:
                                                  snapshot.data!.docs.length,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                DocumentSnapshot document =
                                                    snapshot.data!.docs[index];
                                                bool isUpdated =
                                                    _updatedDocuments
                                                        .contains(document.id);
                                                bool isnew = newdocuments
                                                    .contains(document.id);

                                                return InkWell(
                                                  onTap: () async {
                                                    Configuration.docid =
                                                        document.id;
                                                    if (isUpdated) {
                                                      SharedPreferences prefs =
                                                          await SharedPreferences
                                                              .getInstance();
                                                      setState(() {
                                                        _updatedDocuments
                                                            .remove(
                                                                document.id);
                                                      });
                                                      await prefs.setStringList(
                                                          'myList',
                                                          _updatedDocuments
                                                              .toList());
                                                    }
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    ChatScreen(
                                                                      id: FirebaseAuth
                                                                          .instance
                                                                          .currentUser!
                                                                          .uid,
                                                                      groupId:
                                                                          document
                                                                              .id,
                                                                      role:
                                                                          role,
                                                                      name:
                                                                          name,
                                                                      title: role ==
                                                                              "student"
                                                                          ? document[
                                                                              "name"]
                                                                          : document[
                                                                              "student_name"],
                                                                      icon: document[
                                                                          "icon"],
                                                                    )));
                                                  },
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                        bottom: 3.0),
                                                    //padding: const EdgeInsets.all(8.0),
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            CircleAvatar(
                                                              radius: 21.sp,
                                                              backgroundColor:
                                                                  Colors.black,
                                                              child:
                                                                  CircleAvatar(
                                                                radius: 20.sp,
                                                                backgroundImage:
                                                                    AssetImage(
                                                                        "images/icon.jpeg"),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                width: 5.w),
                                                            Column(
                                                              children: [
                                                                Container(
                                                                  width: 40.w,
                                                                  child: Text(
                                                                    "${document["name"]}",
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    maxLines: 1,
                                                                    style:
                                                                        TextStyle(
                                                                      shadows: <
                                                                          Shadow>[
                                                                        Shadow(
                                                                          offset: Offset(
                                                                              2.0,
                                                                              2.0),
                                                                          blurRadius:
                                                                              6.0,
                                                                          color: Color.fromARGB(
                                                                              100,
                                                                              0,
                                                                              0,
                                                                              0),
                                                                        ),
                                                                      ],
                                                                      fontFamily:
                                                                          'Inter',
                                                                      fontSize:
                                                                          8.sp,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                    ),
                                                                  ),
                                                                ),
                                                                role == "mentor"
                                                                    ? Container(
                                                                        width:
                                                                            40.w,
                                                                        child:
                                                                            Text(
                                                                          "${document["student_name"]}",
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          maxLines:
                                                                              1,
                                                                          style:
                                                                              TextStyle(
                                                                            shadows: <Shadow>[
                                                                              Shadow(
                                                                                offset: Offset(2.0, 2.0),
                                                                                blurRadius: 6.0,
                                                                                color: Color.fromARGB(100, 0, 0, 0),
                                                                              ),
                                                                            ],
                                                                            fontFamily:
                                                                                'Inter',
                                                                            fontSize:
                                                                                8.sp,
                                                                            color:
                                                                                Colors.black,
                                                                            fontWeight:
                                                                                FontWeight.w300,
                                                                          ),
                                                                        ),
                                                                      )
                                                                    : SizedBox(),
                                                              ],
                                                            ),
                                                            SizedBox(
                                                                width: 5.w),
                                                            Column(
                                                              children: [
                                                                Container(
                                                                  width: 20.w,
                                                                  child: Text(
                                                                    (document["time"].toDate().day == now.day) &&
                                                                            (document["time"].toDate().month ==
                                                                                now.month) &&
                                                                            (document["time"].toDate().year == now.year)
                                                                        ? "Today"
                                                                        : (document["time"].toDate().day == (now.day - 1)) && (document["time"].toDate().month == now.month) && (document["time"].toDate().year == now.year)
                                                                            ? "Yesterday"
                                                                            : "${document["time"].toDate().day}/${document["time"].toDate().month}/${document["time"].toDate().year}",
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    maxLines: 1,
                                                                    style:
                                                                        TextStyle(
                                                                      shadows: <
                                                                          Shadow>[
                                                                        Shadow(
                                                                          offset: Offset(
                                                                              2.0,
                                                                              2.0),
                                                                          blurRadius:
                                                                              6.0,
                                                                          color: Color.fromARGB(
                                                                              100,
                                                                              0,
                                                                              0,
                                                                              0),
                                                                        ),
                                                                      ],
                                                                      fontFamily:
                                                                          'Inter',
                                                                      fontSize:
                                                                          8.sp,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                    ),
                                                                  ),
                                                                ),
                                                                Container(
                                                                  width: 20.w,
                                                                  child: Text(
                                                                    '${document["time"].toDate().hour}:${document["time"].toDate().minute}',
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    maxLines: 1,
                                                                    style:
                                                                        TextStyle(
                                                                      shadows: <
                                                                          Shadow>[
                                                                        Shadow(
                                                                          offset: Offset(
                                                                              2.0,
                                                                              2.0),
                                                                          blurRadius:
                                                                              6.0,
                                                                          color: Color.fromARGB(
                                                                              100,
                                                                              0,
                                                                              0,
                                                                              0),
                                                                        ),
                                                                      ],
                                                                      fontFamily:
                                                                          'Inter',
                                                                      fontSize:
                                                                          8.sp,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w300,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            isUpdated
                                                                ? Container(
                                                                    width: 10.w,
                                                                    //  decoration: BoxDecoration(
                                                                    child: Image
                                                                        .asset(
                                                                            "assets/greendot.gif")
                                                                    //  ),

                                                                    )
                                                                // : isnew?Container(
                                                                //   width: 10.w,
                                                                //   //  decoration: BoxDecoration(
                                                                //   child:Text("NEW",style: TextStyle(color: Colors.purple),)

                                                                //   )
                                                                : SizedBox()
                                                          ],
                                                        ),
                                                        Divider(
                                                            thickness: 0.2,
                                                            color: Colors.black)
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                        }
                                      },
                                    )),
                              ),
                              //  ),
                            ],
                          )),
                    ),
                    _isSearching && role != "student"
                        ? Positioned(
                            top: 5.h,
                            left: 10.w,
                            right: 10.w,
                            child: Container(
                              width: 80.w,
                              color: Colors.grey[200],
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.arrow_back),
                                    onPressed: _toggleSearchBar,
                                  ),
                                  Expanded(
                                    child: TextField(
                                      controller: _searchController,
                                      decoration: InputDecoration(
                                        hintText: 'Search by student name',
                                        hintStyle:
                                            TextStyle(color: Colors.grey),
                                        border: InputBorder.none,
                                      ),
                                      onChanged: _onSearchTextChanged,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      _collectionStream = FirebaseFirestore
                                          .instance
                                          .collection('groups')
                                          .orderBy('time', descending: true)
                                          .limit(500)
                                          .snapshots();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Container(),
                  ],
                )
              ],
            )),
    );
  }
}
class PopupBox extends StatelessWidget {
  final String message;

  PopupBox({required this.message});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Points to Ponder',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
             "How you can learn better?",
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
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                     decoration: TextDecoration.underline,
                                  ),
            ),
            Text("It's a good idea to google once about your doubt and see what stackoverflow suggest and how others solved the same kind of doubt by looking at documentation once."
             ,style: TextStyle(
                          
                                    shadows: <Shadow>[
                                      Shadow(
                                        offset: Offset(2.0, 2.0),
                                        blurRadius: 6.0,
                                        color: Color.fromARGB(100, 0, 0, 0),
                                      ),
                                    ],
                                    fontFamily: 'Inter',
                                    fontSize: 8.sp,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400,
                                     decoration: TextDecoration.underline,
                                  ),),
             Text("Note : "
               ,style: TextStyle(
                          
                                    shadows: <Shadow>[
                                      Shadow(
                                        offset: Offset(2.0, 2.0),
                                        blurRadius: 6.0,
                                        color: Color.fromARGB(100, 0, 0, 0),
                                      ),
                                    ],
                                    fontFamily: 'Inter',
                                    fontSize: 10.sp,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                     decoration: TextDecoration.underline,
                                  ),),
              Text(" If you see late response(more than 5 minutes or max more than 10 minutes ) from mentor multiple times during 6pm - midnight , then tag me and raise the concern. "
               ,style: TextStyle(
                          
                                    shadows: <Shadow>[
                                      Shadow(
                                        offset: Offset(2.0, 2.0),
                                        blurRadius: 6.0,
                                        color: Color.fromARGB(100, 0, 0, 0),
                                      ),
                                    ],
                                    fontFamily: 'Inter',
                                    fontSize: 8.sp,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400,
                                     decoration: TextDecoration.underline,
                                  ),),
               Text("Assignment note : "
                , style: TextStyle(
                          
                                    shadows: <Shadow>[
                                      Shadow(
                                        offset: Offset(2.0, 2.0),
                                        blurRadius: 6.0,
                                        color: Color.fromARGB(100, 0, 0, 0),
                                      ),
                                    ],
                                    fontFamily: 'Inter',
                                    fontSize: 10.sp,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                     decoration: TextDecoration.underline,
                                  ),
               ),
                Text("Assignments are self evaluated. After submission, there's a solution link provided, go through it and self evaluate."
                 ,style: TextStyle(
                          
                                    shadows: <Shadow>[
                                      Shadow(
                                        offset: Offset(2.0, 2.0),
                                        blurRadius: 6.0,
                                        color: Color.fromARGB(100, 0, 0, 0),
                                      ),
                                    ],
                                    fontFamily: 'Inter',
                                    fontSize: 8.sp,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400,
                                     decoration: TextDecoration.underline,
                                  ),
                ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}
