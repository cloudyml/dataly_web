import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:toast/toast.dart';

import 'global_variable.dart' as globals;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudyml_app2/Providers/UserProvider.dart';
import 'package:cloudyml_app2/api/firebase_api.dart';
import 'package:cloudyml_app2/authentication/firebase_auth.dart';
import 'package:cloudyml_app2/models/course_details.dart';
import 'package:cloudyml_app2/router/login_state_check.dart';
import 'package:cloudyml_app2/screens/exlusive_offer/seasons_offer_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloudyml_app2/fun.dart';
import 'package:cloudyml_app2/models/firebase_file.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hive/hive.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:cloudyml_app2/globals.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:star_rating/star_rating.dart';
import 'Services/code_generator.dart';
import 'Services/deeplink_service.dart';
import 'catalogue_screen.dart';
import 'combo/combo_course.dart';
import 'combo/combo_store.dart';
import 'global_variable.dart';
import 'models/referal_model.dart';
import 'module/pdf_course.dart';
// import 'package:showcaseview/src/showcase.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:html' as html;
import 'module/video_screen.dart';

var rewardCount = 0;
String? linkMessage;

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Future<List<FirebaseFile>> futureFiles;
  late Future<List<FirebaseFile>> futurefilesComboCourseReviews;
  late Future<List<FirebaseFile>> futurefilesSocialMediaReviews;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<dynamic> courses = [];
  bool? load = true;
  Map userMap = Map<String, dynamic>();

  String? name = '';

  getCourseName() async {
    try {
      await FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .get()
          .then((value) {
        setState(() {
          name = value.data()!['name'];
          print('ufbufb--$name');
          print('ufbufb--$courseId');
        });
      });
    } catch (e) {
      print("llooooooooooooo$e");
    }
  }

  void addCoursetoUser(String id) async {
    await FirebaseFirestore.instance
        .collection("Users_dataly")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'paidCourseNames': FieldValue.arrayUnion([id])
    });
  }

  List<Icon> list = [];

  bool navigateToCatalogueScreen(String id) {
    if (userMap['payInPartsDetails'][id] != null) {
      final daysLeft = (DateTime.parse(
              userMap['payInPartsDetails'][id]['endDateOfLimitedAccess'])
          .difference(DateTime.now())
          .inDays);
      print(daysLeft);
      return daysLeft < 1;
    } else {
      return false;
    }
  }

  bool statusOfPayInParts(String id) {
    if (!(userMap['payInPartsDetails'][id] == null)) {
      if (userMap['payInPartsDetails'][id]['outStandingAmtPaid']) {
        return false;
      } else {
        return true;
      }
    } else {
      return false;
    }
  }

  void dbCheckerForPayInParts() async {
    try {
      DocumentSnapshot userDocs = await FirebaseFirestore.instance
          .collection("Users_dataly")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      // print(map['payInPartsDetails'][id]['outStandingAmtPaid']);
      setState(() {
        userMap = userDocs.data() as Map<String, dynamic>;
        // whetherSubScribedToPayInParts =
        //     !(!(map['payInPartsDetails']['outStandingAmtPaid'] == null));
      });
    } catch (e) {
      print("ggggggggggg $e");
    }
  }

  late ScrollController _controller;
  final notificationBox = Hive.box('NotificationBox');
  bool menuClicked = false;

  // showNotification() async {
  //   final provider = Provider.of<UserProvider>(context, listen: false);
  //   if (notificationBox.isEmpty) {
  //     notificationBox.put(1, {"count": 0});
  //     provider
  //         .showNotificationHomeScreen(notificationBox.values.first["count"]);
  //   } else {
  //     provider
  //         .showNotificationHomeScreen(notificationBox.values.first["count"]);
  //   }
  // }

  List<CourseDetails> featuredCourse = [];

  setFeaturedCourse(List<CourseDetails> course) {
    featuredCourse.clear();
    course.forEach((element) {
      if (element.dataly_FcSerialNumber!.isNotEmpty &&
          element.dataly_FcSerialNumber != null &&
          element.isItComboCourse == true) {
        featuredCourse.add(element);
      }
    });
    featuredCourse.sort((a, b) {
      return int.parse(a.dataly_FcSerialNumber!).compareTo(int.parse(b.dataly_FcSerialNumber!));
    });
  }

  Future fetchCourses() async {
    try {
      await FirebaseFirestore.instance
          .collection("Users_dataly")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get()
          .then((value) {
        setState(() {
          if (value.data()!['paidCourseNames'] == null ||
              value.data()!['paidCourseNames'] == []) {
            courses = [];
          } else {
            courses = value.data()!['paidCourseNames'];
            getPercentageOfCourse();
          }
          load = false;
        });
      });
      print('user enrolled in number of courses ${courses.length}');
    } catch (e) {
      print("kkkk $e}");
    }
  }

  var coursePercent = {};

  getPercentageOfCourse() async {
    if (courses.length != 0) {
      try {
        await FirebaseFirestore.instance
            .collection("Users_dataly")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get()
            .then((value) async {
          try {
            courses = value.data()!['paidCourseNames'];
          } catch (e) {
            print('donggg ${e.toString()}');
          }
        });
      } catch (e) {
        print(e.toString());
      }
      var getData;
      try {
        var data = await FirebaseFirestore.instance
            .collection("courseprogress_dataly")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get()
            .then((value) {
          getData = value.data();
        }).catchError((e) => print(e.toString()));

        for (var courseId in courses) {
          print("ID = = ${courseId}");
          int count = 0;
          try {
            await FirebaseFirestore.instance
                .collection("courses")
                .where("id", isEqualTo: courseId)
                .get()
                .then((value) async {
              if (value.docs.first.exists) {
                var coursesName = value.docs.first.data()["courses"];
                if (coursesName != null) {
                  print("name");
                  for (var Id in coursesName) {
                    double num = (getData![Id + "percentage"] != null)
                        ? getData[Id + "percentage"]
                        : 0;
                    count += num.toInt();
                    print("Count = $count");
                    coursePercent[courseId] =
                        count ~/ (value.docs.first.data()["courses"].length);
                  }
                } else {
                  print("yy");
                  print(getData![value.docs.first.data()["id"].toString() +
                          "percentage"]
                      .toString());
                  coursePercent[courseId] = getData[
                              value.docs.first.data()["id"].toString() +
                                  "percentage"] !=
                          null
                      ? getData[value.docs.first.data()["id"].toString() +
                          "percentage"]
                      : 0;
                }
              }
            }).catchError((err) => print("${err.toString()} Error"));
          } catch (err) {
            print(err);
          }
        }
      } catch (e) {
        print('my courses error ${e.toString()}');
      }

      print("done");
      setState(() {
        coursePercent;
      });
      print(coursePercent);
    }
  }

  bool isShow = false;

  _wpshow() async {
    await FirebaseFirestore.instance
        .collection('Notice')
        .doc('rLwaS5rDufmCQ7Gv5vMI')
        .get()
        .then((value) {
      setState(() {
        isShow = value.data()!['show'];
      });

      print("show is===$isShow");
    });
  }

  _launchWhatsapp() async {
    var note = await FirebaseFirestore.instance
        .collection('Notice')
        .doc('rLwaS5rDufmCQ7Gv5vMI')
        .get()
        .then((value) {
      return value.data()!['msg']; // Access your after your get the data
    });

    print("the msg is====$note");
    print("the show is====$isShow");

    var whatsApp1 = await FirebaseFirestore.instance
        .collection('Notice')
        .doc('rLwaS5rDufmCQ7Gv5vMI')
        .get()
        .then((value) {
      return value.data()!['number']; // Access your after your get the data
    });

    print("the number is====$whatsApp1");

    var whatsapp = "+918902530551";
    var whatsappAndroid =
        Uri.parse("whatsapp://send?phone=$whatsApp1&text=$note");
    if (await canLaunchUrl(whatsappAndroid)) {
      await launchUrl(whatsappAndroid);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("WhatsApp is not installed on the device"),
        ),
      );
    }
  }

  var textStyle = TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.white,
    fontSize: 14,
    fontFamily: "Semibold",
  );

  var ref;
  var userDocData;
  userData() async {
    try {
      ref = await FirebaseFirestore.instance
          .collection("Users_dataly")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      print('uid is ${FirebaseAuth.instance.currentUser!.uid}');

      print(ref.data()!["role"].toString());
      userDocData = ref.data()!;
    } catch (e) {
      print("kkkkkkk${e}");
    }
  }

  void getuserdetails() async {
    final deepLinkRepo = await DeepLinkService.instance;
    var referralCode = await deepLinkRepo?.referrerCode.value;

    print(
        "sddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd $referralCode ddd");
    await FirebaseFirestore.instance
        .collection("Users_dataly")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) async {
      print(value.data());
      print(FirebaseAuth.instance.currentUser!.uid);

      try {
        linkMessage = await value.data()!['refer_link'];
        rewardCount = await value.data()!['reward'];
        setState(() {
          rewardCount;
        });
      } catch (e) {
        print(e);
        linkMessage = '';
      }
      print(linkMessage);
      print('1');
      if (linkMessage == '' || linkMessage == null) {
        print('2');
        print(linkMessage);
        updateReferaldata();
      } else {}
      ;
    });
  }

  checkrewardexpiry() async {
    var rewardvalidfrom;
    var rewardexpireindays;
    try {
      await FirebaseFirestore.instance
          .collection("Users_dataly")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get()
          .then((value) {
        globals.role = value.data()!["role"];
        rewardvalidfrom = value.data()!['rewardvalidfrom'];
      });
      await FirebaseFirestore.instance
          .collection("Controllers")
          .doc("variables")
          .get()
          .then((value) {
        rewardexpireindays = value.data()!['rewardexpireindays'];
      });
    } catch (e) {
      print(e.toString());
    }
    if (rewardexpireindays == null) {
      rewardexpireindays = 7;
    }
    if (rewardvalidfrom != null) {
      var data = DateTime.now().difference(rewardvalidfrom.toDate());
      if (data.inDays >= rewardexpireindays) {
        await FirebaseFirestore.instance
            .collection("Users_dataly")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({"reward": 0}).whenComplete(() {
          print('success');
        }).onError((error, stackTrace) => print(error));
      }
    }
  }

  void updateReferaldata() async {
    try {
      // print('4');
      // final deepLinkRepo = await DeepLinkService.instance;
      // var referralCode = await deepLinkRepo?.referrerCode.value;
      // print(
      //     "sddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd ${referralCode}");
      // final referCode = await CodeGenerator().generateCode('refer');
      // final referLink =
      // await DeepLinkService.instance?.createReferLink(referCode);
      // setState(() {
      //   if (referralCode != '') {
      //     rewardCount = 50;
      //   } else {
      //     rewardCount = 0;
      //   }
      //   linkMessage = referLink;
      //   print(linkMessage);
      // });

      // await FirebaseFirestore.instance
      //     .collection("Users_dataly")
      //     .doc(FirebaseAuth.instance.currentUser!.uid)
      //     .update({
      //   'refer_link': referLink,
      //   'refer_code': referCode,
      //   "referral_code": referralCode,
      //   'reward': rewardCount,
      // }).whenComplete(() =>
      //     print("send data to firebase uid: ${FirebaseAuth.instance.currentUser!.uid}"));

      // Future<ReferalModel> getReferrerUser(String referCode) async {
      //   print("iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii ${referCode}");
      //   final docSnapshots = await FirebaseFirestore.instance
      //       .collection("Users_dataly")
      //       .where('refer_code', isEqualTo: referCode)
      //       .get();

      //   final userSnapshot = docSnapshots.docs.first;
      //   print(
      //       "iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii ${userSnapshot.exists}");
      //   if (userSnapshot.exists) {
      //     print(userSnapshot.data());
      //     return ReferalModel.fromJson(userSnapshot.data());
      //   } else {
      //     return ReferalModel.empty();
      //   }
      // }

      // Future<void> rewardUser(
      //     String currentUserUID, String referrerCode) async {
      //   try {
      //     if (referrerCode.toString().substring(0, 11) != "moneyreward") {
      //       final referer = await getReferrerUser(referrerCode);
      //       print(
      //           "iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii ${referer.id}");

      //       final checkIfUserAlreadyExist = await FirebaseFirestore.instance
      //           .collection("Users_dataly")
      //           .doc(referer.id)
      //           .collection('referrers')
      //           .doc(currentUserUID)
      //           .get();

      //       if (!checkIfUserAlreadyExist.exists) {
      //         await FirebaseFirestore.instance
      //             .collection("Users_dataly")
      //             .doc(referer.id)
      //             .collection('referrers')
      //             .doc(currentUserUID)
      //             .set({
      //           "uid": currentUserUID,
      //           "createdAt": DateTime.now(),
      //         });

      //         await FirebaseFirestore.instance
      //             .collection("Users_dataly")
      //             .doc(referer.id)
      //             .update({
      //           "reward": FieldValue.increment(50),
      //           "rewardvalidfrom": DateTime.now()
      //         });
      //       }
      //     }
      //   } catch (e) {
      //     debugPrint(e.toString());
      //   }
      // }

      // if (referralCode != "") {
      //   print("iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii ${referralCode}");
      //   await rewardUser(FirebaseAuth.instance.currentUser!.uid, referralCode!);
      // }
      // ;
    } catch (e) {
      print(
          "................................................................................................................................${e}");
    }
  }

  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;

  void loadCourses(String fID) async {
    await _firestore.collection("courses").doc(fID).get().then((value) {
      print(_auth.currentUser!.displayName);
      Map<String, dynamic> groupData = {
        "name": value.data()!['name'],
        "icon": value.data()!["image_url"],
        "mentors": value.data()!["mentors"],
        "student_id": _auth.currentUser!.uid,
        "student_name": _auth.currentUser!.displayName,
        'groupChatCountNew': {
          'jbG4j36JiihVuZmpoLov2lhrWF02': 0,
          'QVtxxzHyc6az2LPpvH210lUOeXl1': 0,
          "2AS3AK7WVQaAMY999D3xf5ycG3h1": 0,
          'a2WWgtY2ikS8xjCxra0GEfRft5N2': 0,
          'BX9662ZGi4MfO4C9CvJm4u2JFo63': 0,
          '6RsvdRETWmXf1pyVGqCUl0qEDmF2': 0,
          'jeYDhaZCRWW4EC9qZ0YTHKz4PH63': 0,
          'I6uXWtzpimTYxtGqEXcM9AXcoAi2': 0,
          'Kr4pX5EZ6CfigOd5C1xjdIYzMml2': 0,
          'XhcpQzd6cjXF43gCmna1agAfS2A2': 0,
          'fKHHbDBbbySVJZu2NMAVVIYZZpu2': 0,
          'oQQ9CrJ8FkP06OoGdrtcwSwY89q1': 0,
          'rR0oKFMCaOYIlblKzrjYoYMW3Vl1': 0,
          'v66PnlwqWERgcCDA6ZZLbI0mHPF2': 0,
          'TOV5h3ezQhWGTb5cCVvBPca1Iqh1': 0,
          [_auth.currentUser!.uid]: 0
        },
      };
      _firestore.collection("groups_dataly").add(groupData);
    });
  }

  void startTimer() {
    countDownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setCountDown();
    });
  }

  void stopTimer() {
    setState(() {
      countDownTimer!.cancel();
    });
  }

  void resetTimer() {
    stopTimer();
    setState(() {
      myDuration = Duration(days: 5);
    });
  }

  setCountDown() {
    final reduceSecs = 1;
    setState(() {
      final seconds = myDuration.inSeconds - reduceSecs;
      if (seconds < 0) {
        countDownTimer!.cancel();
      } else {
        myDuration = Duration(seconds: seconds);
      }
    });
  }

  String strDigits(int n) => n.toString().padLeft(2, '0');

  void saveLoginOutState(BuildContext context) {
    Provider.of<LoginState>(context, listen: false).loggedIn = false;
  }

  var authorizationToken;
  void insertToken() async {
    print("insertToken");
    final token = await FirebaseMessaging.instance.getToken();
    await FirebaseFirestore.instance
        .collection("Users_dataly")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({"token": token});
    authorizationToken = await FirebaseAuth.instance.currentUser!.getIdToken();
  }

  bool isAnnounceMent = false;
  String announcementMsg = '';
  void getAnnouncement() async {
    await FirebaseFirestore.instance.collection('Notice').get().then((value) {
      setState(() {
        announcementMsg = value.docs[2].get('Message');
        isAnnounceMent = value.docs[2].get('show');
      });
    });
  }

  @override
  void initState() {
    // print('this is url ${html.window.location.href}');
    // print('this is path ${Uri.base.path}');
    // showNotification();

    _controller = ScrollController();
    super.initState();
    futureFiles = FirebaseApi.listAll('reviews/recent_review');
    futurefilesComboCourseReviews =
        FirebaseApi.listAll('reviews/combo_course_review');
    futurefilesSocialMediaReviews =
        FirebaseApi.listAll('reviews/social_media_review');
    getCourseName();
    print("wiefosefwefww");
    fetchCourses();
    dbCheckerForPayInParts();
    userData();
    startTimer();
    // getuserdetails();
    checkrewardexpiry();
  }

  Timer? countDownTimer;
  Duration myDuration = Duration(days: 5);

  @override
  Widget build(BuildContext context) {
    final days = strDigits(myDuration.inDays);
    final hours = strDigits(myDuration.inHours.remainder(24));
    final minutes = strDigits(myDuration.inMinutes.remainder(60));
    final seconds = strDigits(myDuration.inSeconds.remainder(60));
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;
    final providerNotification =
        Provider.of<UserProvider>(context, listen: false);
    List<CourseDetails> course = Provider.of<List<CourseDetails>>(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    var verticalScale = screenHeight / mockUpHeight;
    var horizontalScale = screenWidth / mockUpWidth;
    setFeaturedCourse(course);
    return Scaffold(
      key: _scaffoldKey,
      drawer: customDrawer(context),
      // floatingActionButton: floatingButton(context),
      body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth >= 650) {
          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: screenWidth,
                  height: screenHeight,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/homepage/newBGImage.png'),
                        fit: BoxFit.fill),
                  ),
                  child: Stack(
                    children: [
                      Row(
                        children: [
                          IconButton(
                              onPressed: () {
                                Scaffold.of(context).openDrawer();
                                menuClicked = true;
                              },
                              icon: Icon(
                                Icons.menu,
                                color: Colors.white,
                                size: 30,
                              )),
                          SizedBox(
                            width: horizontalScale * 15,
                          ),
                          SizedBox(
                            width: Adaptive.w(18.5),
                            child: Stack(
                              children: [
                                Image.asset(
                                  'assets/logo.png',
                                  height: 75,
                                  width: 110,
                                  cacheWidth: 82,
                                  cacheHeight: 56,
                                ),
                              ],
                            ),
                          ),
                          Spacer(),
                          ElevatedButton(
                              onPressed: () {
                                logOut(context);
                                saveLoginOutState(context);
                                GoRouter.of(context).go('/login');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: HexColor("8346E1"),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                              child: Text("Log out", style: textStyle)),
                        ],
                      ),
                      Positioned(
                        top: 50,
                        right: 75,
                        child: Container(
                            height: screenHeight / 1.5,
                            width: screenWidth / 2.8,
                            child: Image.asset(
                              'assets/homepage/Webgraphics21.png',
                              fit: BoxFit.fill,
                            )),
                      ),
                      Positioned(
                        top: 125,
                        left: 75,
                        child: Container(
                            height: screenHeight / 2.5,
                            width: screenWidth / 2.0,
                            child: Image.network(
                              'https://firebasestorage.googleapis.com/v0/b/cloudyml-app.appspot.com/o/test_developer%2FGroup%20162.png?alt=media&token=6e3f0646-61b4-4897-ae9d-9ef3600676e1',
                              fit: BoxFit.fill,
                            )),
                      ),
                      Positioned(
                        top: 435,
                        left: 75,
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () {
                                launch(
                                    'https://apps.apple.com/app/cloudyml-data-science-course/id6444130328');
                              },
                              child: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.apple_outlined,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          'Download our IOS app from',
                                          style: TextStyle(
                                              color: Colors.white, fontSize: 8),
                                        ),
                                        Text('APPLE STORE',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            InkWell(
                              onTap: () {
                                launch(
                                    'https://play.google.com/store/apps/details?id=com.cloudyml.cloudymlapp');
                              },
                              child: Container(
                                padding: EdgeInsets.only(
                                  right: 15,
                                  top: 10,
                                  bottom: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.play_arrow,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          'Download our Android app from',
                                          style: TextStyle(
                                              color: Colors.white, fontSize: 8),
                                        ),
                                        Text('GOOGLE PLAY',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // TextButton(
                      //   onPressed: () {
                      //
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(
                      //         builder: (context) => SeasonOffer(
                      //           days: days,
                      //         hours: hours,
                      //         minutes: minutes,
                      //         seconds: seconds,)
                      //       ),
                      //     );
                      //
                      //   },
                      //   child: Text('Offer'),
                      // ),
                    ],
                  ),
                ),
                Container(
                  child: Column(
                    children: [
                      Center(
                          child: Padding(
                        padding: const EdgeInsets.only(bottom: 15.0),
                        child: Text(
                          "My Enrolled Courses",
                          style: TextStyle(
                              fontFamily: 'Medium',
                              color: Colors.black,
                              fontSize: 22,
                              fontWeight: FontWeight.bold),
                        ),
                      )),
                      courses.length > 0
                          ? Container(
                              width: courses.length == 1
                                  ? screenWidth / 2.5
                                  : screenWidth / 1.2,
                              height: screenHeight / 5,
                              color: Colors.transparent,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                // shrinkWrap: true,
                                itemCount: course.length,
                                itemBuilder: (BuildContext context, int index) {
                                  if (course[index].courseName == "null") {
                                    return Container();
                                  }
                                  if (courses
                                      .contains(course[index].courseId)) {
                                    return Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        InkWell(
                                          onTap: (() async {
                                            // setModuleId(snapshot.data!.docs[index].id);
                                            await getCourseName();
                                            if (navigateToCatalogueScreen(
                                                    course[index].courseId) &&
                                                !(userMap['payInPartsDetails']
                                                        [course[index].courseId]
                                                    ['outStandingAmtPaid'])) {
                                              if (!course[index]
                                                  .isItComboCourse) {
                                                GoRouter.of(context).pushNamed(
                                                    'videoScreen',
                                                    queryParams: {
                                                      'courseName':
                                                          course[index]
                                                              .courseName,
                                                      'cID': course[index]
                                                          .courseDocumentId,
                                                    });

                                                // Navigator.push(
                                                //   context,
                                                //   PageTransition(
                                                //     duration: Duration(
                                                //         milliseconds: 400),
                                                //     curve:
                                                //     Curves.bounceInOut,
                                                //     type: PageTransitionType
                                                //         .rightToLeftWithFade,
                                                //     child: VideoScreen(
                                                //       isDemo: true,
                                                //       courseName:
                                                //       course[index]
                                                //           .courseName,
                                                //       sr: 1,
                                                //     ),
                                                //   ),
                                                // );
                                              } else {
                                                final id = index.toString();
                                                final courseName =
                                                    course[index].courseName;
                                                context.goNamed('comboStore',
                                                    queryParams: {
                                                      'courseName': courseName,
                                                      'id': id
                                                    });

                                                // Navigator.push(
                                                //   context,
                                                //   PageTransition(
                                                //     duration: Duration(
                                                //         milliseconds: 100),
                                                //     curve:
                                                //     Curves.bounceInOut,
                                                //     type: PageTransitionType
                                                //         .rightToLeftWithFade,
                                                //     child: ComboStore(
                                                //       courses: course[index]
                                                //           .courses,
                                                //     ),
                                                //   ),
                                                // );
                                              }
                                            } else {
                                              if (!course[index]
                                                  .isItComboCourse) {
                                                if (course[index]
                                                        .courseContent ==
                                                    'pdf') {
                                                  Navigator.push(
                                                    context,
                                                    PageTransition(
                                                      duration: Duration(
                                                          milliseconds: 400),
                                                      curve: Curves.bounceInOut,
                                                      type: PageTransitionType
                                                          .rightToLeftWithFade,
                                                      child: PdfCourseScreen(
                                                        curriculum:
                                                            course[index]
                                                                    .curriculum
                                                                as Map<String,
                                                                    dynamic>,
                                                      ),
                                                    ),
                                                  );
                                                } else {
                                                  GoRouter.of(context)
                                                      .pushNamed('videoScreen',
                                                          queryParams: {
                                                        'courseName':
                                                            course[index]
                                                                .courseName,
                                                        'cID': course[index]
                                                            .courseDocumentId,
                                                      });
                                                  // Navigator.push(
                                                  //   context,
                                                  //   PageTransition(
                                                  //     duration: Duration(
                                                  //         milliseconds:
                                                  //         400),
                                                  //     curve: Curves
                                                  //         .bounceInOut,
                                                  //     type: PageTransitionType
                                                  //         .rightToLeftWithFade,
                                                  //     child: VideoScreen(
                                                  //       isDemo: true,
                                                  //       courseName:
                                                  //       course[index]
                                                  //           .courseName,
                                                  //       sr: 1,
                                                  //     ),
                                                  //   ),
                                                  // );
                                                }
                                              } else {
                                                ComboCourse.comboId.value =
                                                    course[index].courseId;

                                                mainCourseId =
                                                    course[index].courseId;

                                                final id = index.toString();
                                                final courseName =
                                                    course[index].courseName;

                                                // GoRouter.of(context).pushNamed('newcomboCourse',
                                                //     queryParams: {'id': id, 'courseName': courseName});
                                                GoRouter.of(context).pushNamed(
                                                    'NewComboCourseScreen',
                                                    queryParams: {
                                                      'courseId': course[index]
                                                          .courseId,
                                                      'courseName': courseName,
                                                    });
                                                // Navigator.push(
                                                //   context,
                                                //   PageTransition(
                                                //     duration: Duration(
                                                //         milliseconds: 400),
                                                //     curve:
                                                //     Curves.bounceInOut,
                                                //     type: PageTransitionType
                                                //         .rightToLeftWithFade,
                                                //     child: ComboCourse(
                                                //       courses: course[index]
                                                //           .courses,
                                                //     ),
                                                //   ),
                                                // );
                                              }
                                            }
                                            setState(() {
                                              courseId = course[index]
                                                  .courseDocumentId;
                                            });
                                          }),
                                          child: Container(
                                            width: screenWidth / 2.8,
                                            height: screenHeight / 5.5,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              // boxShadow: [
                                              //   BoxShadow(
                                              //       color: Colors.black26,
                                              //       offset: Offset(
                                              //         2, // Move to right 10  horizontally
                                              //         2.0, // Move to bottom 10 Vertically
                                              //       ),
                                              //       blurRadius: 40)
                                              // ],
                                              border: Border.all(
                                                color: HexColor('440F87'),
                                                width: 1.5,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Stack(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        width: 60 *
                                                            horizontalScale,
                                                        height:
                                                            screenHeight / 5.5,
                                                        decoration:
                                                            BoxDecoration(
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .transparent),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5),
                                                                image:
                                                                    DecorationImage(
                                                                        image:
                                                                            CachedNetworkImageProvider(
                                                                          course[index]
                                                                              .courseImageUrl,
                                                                        ),
                                                                        fit: BoxFit
                                                                            .fill)),
                                                      ),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      Container(
                                                        width:
                                                            screenWidth / 5.6,
                                                        height:
                                                            screenHeight / 5.5,
                                                        child: Align(
                                                          alignment: Alignment
                                                              .topCenter,
                                                          child: Column(
                                                            children: [
                                                              Align(
                                                                alignment:
                                                                    Alignment
                                                                        .topLeft,
                                                                child: Text(
                                                                  course[index]
                                                                      .courseName,
                                                                  maxLines: 2,
                                                                  style:
                                                                      TextStyle(
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    color: Colors
                                                                        .black,
                                                                    fontFamily:
                                                                        'Medium',
                                                                    fontSize:
                                                                        16,
                                                                    height:
                                                                        0.95,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                              ),
                                                              // Align(
                                                              //   alignment:
                                                              //   Alignment
                                                              //       .topLeft,
                                                              //   child: Text(
                                                              //     "${course[index].numOfVideos} Videos",
                                                              //     style: TextStyle(
                                                              //         color: HexColor(
                                                              //             "2C2C2C"),
                                                              //         fontFamily:
                                                              //         'Medium',
                                                              //         fontSize:
                                                              //         12,
                                                              //         fontWeight: FontWeight
                                                              //             .w500,
                                                              //         height:
                                                              //         1),
                                                              //   ),
                                                              // ),
                                                              SizedBox(
                                                                height: 10,
                                                              ),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        right:
                                                                            5.0),
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          20,
                                                                      width: 25,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(5.0),
                                                                        color: HexColor(
                                                                            '440F87'),
                                                                      ),
                                                                      child:
                                                                          Center(
                                                                        child:
                                                                            Text(
                                                                          course[index].reviews.isNotEmpty
                                                                              ? course[index].reviews
                                                                              : '5.0',
                                                                          style: TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.white,
                                                                              fontWeight: FontWeight.normal),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        right:
                                                                            5.0),
                                                                    child:
                                                                        StarRating(
                                                                      length: 5,
                                                                      rating: course[index]
                                                                              .reviews
                                                                              .isNotEmpty
                                                                          ? double.parse(
                                                                              course[index].reviews)
                                                                          : 5.0,
                                                                      color: HexColor(
                                                                          '440F87'),
                                                                      starSize:
                                                                          20,
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .start,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                height: 5,
                                                              ),
                                                              courses.length !=
                                                                          0 &&
                                                                      coursePercent !=
                                                                          {}
                                                                  ? Container(
                                                                      height:
                                                                          15,
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          Container(
                                                                            height:
                                                                                5 * horizontalScale,
                                                                            width:
                                                                                150 * verticalScale,
                                                                            child:
                                                                                LinearProgressIndicator(
                                                                              value: coursePercent[course[index].courseId.toString()] != null ? coursePercent[course[index].courseId] / 100 : 0,
                                                                              color: HexColor("8346E1"),
                                                                              backgroundColor: HexColor('E3E3E3'),
                                                                            ),
                                                                          ),
                                                                          Spacer(),
                                                                          Text(
                                                                            "${coursePercent[course[index].courseId.toString()] != null ? coursePercent[course[index].courseId] : 0}%",
                                                                            style:
                                                                                TextStyle(fontSize: 10),
                                                                          )
                                                                        ],
                                                                      ),
                                                                    )
                                                                  : SizedBox(),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: 25,
                                        ),
                                      ],
                                    );
                                  } else {
                                    return Container();
                                  }
                                },
                              ),
                            )
                          : Container(
                              width: screenWidth / 2.5,
                              height: screenHeight / 5.5,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                                border:
                                    Border.all(color: Colors.black, width: 1.0),
                              ),
                              child: Center(
                                  child: Text('There are zero courses.')),
                            ),
                      SizedBox(height: verticalScale * 40),
                      // Padding(
                      //   padding: const EdgeInsets.all(15.0),
                      //   child: Container(
                      //     child: ElevatedButton(
                      //         onPressed: () {}, child: Text("View More")),
                      //   ),
                      // ),
                    ],
                  ),
                ),
                Container(
                  height: screenHeight / 1.8,
                  width: screenWidth,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                      stops: [0, 0.4, 0.9],
                      colors: [
                        HexColor("FFFFFF"),
                        HexColor("B079FF"),
                        HexColor("FFFFFF"),
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Reviews',
                            style: TextStyle(
                              fontSize: 24,
                              fontFamily: 'Poppins',
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FutureBuilder<List<FirebaseFile>>(
                            future: futureFiles,
                            builder: (context, snapshot) {
                              try {
                                switch (snapshot.connectionState) {
                                  case ConnectionState.waiting:
                                    return Center(
                                        child: CircularProgressIndicator());
                                  default:
                                    if (snapshot.hasError) {
                                      return Center(
                                          child: Text(
                                        'Some error occurred!',
                                        textScaleFactor:
                                            min(horizontalScale, verticalScale),
                                      ));
                                    } else {
                                      final files = snapshot.data!;
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          height: screenHeight / 2.3,
                                          width: screenWidth / 3.5,
                                          child: CarouselSlider.builder(
                                              options: CarouselOptions(
                                                autoPlay: true,
                                                enableInfiniteScroll: true,
                                                enlargeCenterPage: false,
                                                viewportFraction: 1,
                                                aspectRatio: 2.0,
                                                initialPage: 0,
                                                autoPlayCurve:
                                                    Curves.fastOutSlowIn,
                                                autoPlayAnimationDuration:
                                                    Duration(
                                                        milliseconds: 1000),
                                              ),
                                              itemCount: files.length,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index, int pageNo) {
                                                return ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    child: InkWell(
                                                      onTap: () {
                                                        final file =
                                                            files[index];
                                                        showDialog(
                                                            context: context,
                                                            builder: (context) =>
                                                                GestureDetector(
                                                                    onTap: () =>
                                                                        Navigator.pop(
                                                                            context),
                                                                    child:
                                                                        Container(
                                                                      alignment:
                                                                          Alignment
                                                                              .center,
                                                                      color: Colors
                                                                          .transparent,
                                                                      height:
                                                                          400,
                                                                      width:
                                                                          300,
                                                                      child:
                                                                          AlertDialog(
                                                                        shape: RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(15.0),
                                                                            side: BorderSide.none),
                                                                        scrollable:
                                                                            true,
                                                                        content:
                                                                            Container(
                                                                          height:
                                                                              240,
                                                                          width:
                                                                              320,
                                                                          child:
                                                                              ClipRRect(
                                                                            borderRadius:
                                                                                BorderRadius.circular(20),
                                                                            child:
                                                                                CachedNetworkImage(
                                                                              errorWidget: (context, url, error) => Icon(Icons.error),
                                                                              imageUrl: file.url,
                                                                              fit: BoxFit.fill,
                                                                              placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    )));
                                                      },
                                                      child: Image.network(
                                                          files[index].url),
                                                    ));
                                              }),
                                        ),
                                      );
                                    }
                                }
                              } catch (e) {
                                print("jjkkjkjkkkkjkjjjjjjjjkkk${e}");

                                Toast.show(e.toString());
                                return Center(
                                    child: Text(
                                  'Some error occurred!',
                                  textScaleFactor:
                                      min(horizontalScale, verticalScale),
                                ));
                              }
                            },
                          ),
                          FutureBuilder<List<FirebaseFile>>(
                            future: futurefilesComboCourseReviews,
                            builder: (context, snapshot) {
                              try {
                                switch (snapshot.connectionState) {
                                  case ConnectionState.waiting:
                                    return Center(
                                        child: CircularProgressIndicator());
                                  default:
                                    if (snapshot.hasError) {
                                      return Center(
                                          child: Text(
                                        'Some error occurred!',
                                        textScaleFactor:
                                            min(horizontalScale, verticalScale),
                                      ));
                                    } else {
                                      final files = snapshot.data!;
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          height: screenHeight / 2.3,
                                          width: screenWidth / 3.5,
                                          child: CarouselSlider.builder(
                                              options: CarouselOptions(
                                                autoPlay: true,
                                                enableInfiniteScroll: true,
                                                enlargeCenterPage: false,
                                                viewportFraction: 1,
                                                aspectRatio: 2.0,
                                                initialPage: 4,
                                                autoPlayCurve:
                                                    Curves.fastOutSlowIn,
                                                autoPlayAnimationDuration:
                                                    Duration(
                                                        milliseconds: 2000),
                                              ),
                                              itemCount: files.length,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index, int pageNo) {
                                                return ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    child: InkWell(
                                                      onTap: () {
                                                        final file =
                                                            files[index];
                                                        showDialog(
                                                            context: context,
                                                            builder: (context) =>
                                                                GestureDetector(
                                                                    onTap: () =>
                                                                        Navigator.pop(
                                                                            context),
                                                                    child:
                                                                        Container(
                                                                      alignment:
                                                                          Alignment
                                                                              .center,
                                                                      color: Colors
                                                                          .transparent,
                                                                      height:
                                                                          400,
                                                                      width:
                                                                          300,
                                                                      child:
                                                                          AlertDialog(
                                                                        shape: RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(15.0),
                                                                            side: BorderSide.none),
                                                                        scrollable:
                                                                            true,
                                                                        content:
                                                                            Container(
                                                                          height:
                                                                              240,
                                                                          width:
                                                                              320,
                                                                          child:
                                                                              ClipRRect(
                                                                            borderRadius:
                                                                                BorderRadius.circular(20),
                                                                            child:
                                                                                CachedNetworkImage(
                                                                              errorWidget: (context, url, error) => Icon(Icons.error),
                                                                              imageUrl: file.url,
                                                                              fit: BoxFit.fill,
                                                                              placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    )));
                                                      },
                                                      child: Image.network(
                                                          files[index].url),
                                                    ));
                                              }),
                                        ),
                                      );
                                    }
                                }
                              } catch (e) {
                                print("jjkkjkjkkkkjkjjjjjjjjkkk${e}");

                                Toast.show(e.toString());
                                return Center(
                                    child: Text(
                                  'Some error occurred!',
                                  textScaleFactor:
                                      min(horizontalScale, verticalScale),
                                ));
                              }
                            },
                          ),
                          FutureBuilder<List<FirebaseFile>>(
                            future: futurefilesSocialMediaReviews,
                            builder: (context, snapshot) {
                              try {
                                switch (snapshot.connectionState) {
                                  case ConnectionState.waiting:
                                    return Center(
                                        child: CircularProgressIndicator());
                                  default:
                                    if (snapshot.hasError) {
                                      return Center(
                                          child: Text(
                                        'Some error occurred!',
                                        textScaleFactor:
                                            min(horizontalScale, verticalScale),
                                      ));
                                    } else {
                                      final files = snapshot.data!;
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          height: screenHeight / 2.3,
                                          width: screenWidth / 3.5,
                                          child: CarouselSlider.builder(
                                              options: CarouselOptions(
                                                autoPlay: true,
                                                enableInfiniteScroll: true,
                                                enlargeCenterPage: false,
                                                viewportFraction: 1,
                                                aspectRatio: 2.0,
                                                initialPage: 7,
                                                autoPlayCurve:
                                                    Curves.fastOutSlowIn,
                                                autoPlayAnimationDuration:
                                                    Duration(
                                                        milliseconds: 3000),
                                              ),
                                              itemCount: files.length,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index, int pageNo) {
                                                return ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    child: InkWell(
                                                      onTap: () {
                                                        final file =
                                                            files[index];
                                                        showDialog(
                                                            context: context,
                                                            builder: (context) =>
                                                                GestureDetector(
                                                                    onTap: () =>
                                                                        Navigator.pop(
                                                                            context),
                                                                    child:
                                                                        Container(
                                                                      alignment:
                                                                          Alignment
                                                                              .center,
                                                                      color: Colors
                                                                          .transparent,
                                                                      height:
                                                                          400,
                                                                      width:
                                                                          300,
                                                                      child:
                                                                          AlertDialog(
                                                                        shape: RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(15.0),
                                                                            side: BorderSide.none),
                                                                        scrollable:
                                                                            true,
                                                                        content:
                                                                            Container(
                                                                          height:
                                                                              240,
                                                                          width:
                                                                              320,
                                                                          child:
                                                                              ClipRRect(
                                                                            borderRadius:
                                                                                BorderRadius.circular(20),
                                                                            child:
                                                                                CachedNetworkImage(
                                                                              errorWidget: (context, url, error) => Icon(Icons.error),
                                                                              imageUrl: file.url,
                                                                              fit: BoxFit.fill,
                                                                              placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    )));
                                                      },
                                                      child: Image.network(
                                                          files[index].url),
                                                    ));
                                              }),
                                        ),
                                      );
                                    }
                                }
                              } catch (e) {
                                print("jjkkjkjkkkkjkjjjjjjjjkkk${e}");

                                Toast.show(e.toString());
                                return Center(
                                    child: Text(
                                  'Some error occurred!',
                                  textScaleFactor:
                                      min(horizontalScale, verticalScale),
                                ));
                              }
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                Container(
                  width: screenWidth,
                  height: screenHeight / 1.25,
                  color: Colors.white,
                  child: Stack(
                    children: [
                      Image.network(
                        'https://firebasestorage.googleapis.com/v0/b/cloudyml-app.appspot.com/o/test_developer%2FfeatureBG.png?alt=media&token=f350c99d-a928-48b6-9eff-983ad8797de9',
                        fit: BoxFit.fill,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 30.0),
                        child: Align(
                            alignment: Alignment.topCenter,
                            child: Text(
                              "Feature Courses",
                              style: TextStyle(
                                fontSize: 20,
                                fontFamily: 'Poppins',
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 75, bottom: 50),
                        height: screenHeight / 2,
                        child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: featuredCourse.length,
                            itemBuilder: (BuildContext context, index) {
                              if (featuredCourse[index].courseName == "null") {
                                return Container();
                              }
                              // if (course[index].isItComboCourse == true)

                              return InkWell(
                                  onTap: () {
                                    setState(() {
                                      courseId = featuredCourse[index]
                                          .courseDocumentId;
                                    });
                                    print(courseId);
                                    if (featuredCourse[index].isItComboCourse) {
                                      print(featuredCourse[index].courses);

                                      final id = index.toString();
                                      final cID = featuredCourse[index]
                                          .courseDocumentId;
                                      final courseName =
                                          featuredCourse[index].courseName;
                                      final courseP =
                                          featuredCourse[index].coursePrice;
                                      GoRouter.of(context).pushNamed(
                                          'featuredCourses',
                                          queryParams: {
                                            'cID': cID,
                                            'courseName': courseName,
                                            'id': id,
                                            'coursePrice': courseP
                                          });

                                      // Navigator.push(
                                      //   context,
                                      //   MaterialPageRoute(
                                      //     builder: (context) =>
                                      //         ComboStore(
                                      //           courses:
                                      //           course[index].courses,
                                      //         ),
                                      //   ),
                                      // );
                                    } else {
                                      final id = index.toString();
                                      GoRouter.of(context).pushNamed(
                                          'catalogue',
                                          queryParams: {'id': id});
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Container(
                                      height: screenHeight / 2.25,
                                      width: screenWidth / 5,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        // boxShadow: [
                                        //   BoxShadow(
                                        //     color: Colors.black26,
                                        //     offset: Offset(0, 2),
                                        //     blurRadius: 40,
                                        //   ),
                                        // ],
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(
                                            width: 0.5,
                                            color: HexColor("440F87")),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: screenWidth / 5,
                                            height: screenHeight / 5.5,
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(15),
                                                  topRight:
                                                      Radius.circular(15)),
                                              child: Image.network(
                                                featuredCourse[index]
                                                    .courseImageUrl,
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 5.0, right: 5),
                                            child: Container(
                                              height: screenHeight / 5.5,
                                              padding: EdgeInsets.only(left: 5),
                                              child: Column(
                                                children: [
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  Align(
                                                    alignment:
                                                        Alignment.topLeft,
                                                    child: Text(
                                                      featuredCourse[index]
                                                          .courseName,
                                                      maxLines: 2,
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontFamily: 'Medium',
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          height: 1),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: verticalScale * 5,
                                                  ),
                                                  Align(
                                                    alignment:
                                                        Alignment.topLeft,
                                                    child: Text(
                                                      "- ${featuredCourse[index].numOfVideos} Videos",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black,
                                                          fontSize: 10),
                                                    ),
                                                  ),
                                                  Align(
                                                    alignment:
                                                        Alignment.topLeft,
                                                    child: Text(
                                                      "- Lifetime Access",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black,
                                                          fontSize: 10),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                right: 5.0),
                                                        child: Container(
                                                          height: 20,
                                                          width: 25,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5.0),
                                                            color: HexColor(
                                                                '440F87'),
                                                          ),
                                                          child: Center(
                                                            child: Text(
                                                              featuredCourse[
                                                                          index]
                                                                      .reviews
                                                                      .isNotEmpty
                                                                  ? featuredCourse[
                                                                          index]
                                                                      .reviews
                                                                  : '5.0',
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                right: 5.0),
                                                        child: StarRating(
                                                          length: 5,
                                                          rating: featuredCourse[
                                                                      index]
                                                                  .reviews
                                                                  .isNotEmpty
                                                              ? double.parse(
                                                                  featuredCourse[
                                                                          index]
                                                                      .reviews)
                                                              : 5.0,
                                                          color: HexColor(
                                                              '440F87'),
                                                          starSize: 20,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: Container(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 10.0,
                                                            left: 10),
                                                    child: Row(
                                                      children: [
                                                        ElevatedButton(
                                                            onPressed: () {
                                                              setState(() {
                                                                courseId =
                                                                    featuredCourse[
                                                                            index]
                                                                        .courseDocumentId;
                                                              });
                                                              print(courseId);
                                                              if (featuredCourse[
                                                                      index]
                                                                  .isItComboCourse) {
                                                                final id = index
                                                                    .toString();
                                                                final courseName =
                                                                    featuredCourse[
                                                                            index]
                                                                        .courseName;
                                                                final courseP =
                                                                    featuredCourse[
                                                                            index]
                                                                        .coursePrice;
                                                                GoRouter.of(
                                                                        context)
                                                                    .pushNamed(
                                                                        'newcomboStore',
                                                                        queryParams: {
                                                                      'courseName':
                                                                          courseName,
                                                                      'id': id,
                                                                      'coursePrice':
                                                                          courseP,
                                                                      'courses':
                                                                          featuredCourse[index]
                                                                              .courses
                                                                    });

                                                                // Navigator.push(
                                                                //   context,
                                                                //   MaterialPageRoute(
                                                                //     builder: (context) =>
                                                                //         ComboStore(
                                                                //           courses:
                                                                //           course[index].courses,
                                                                //         ),
                                                                //   ),
                                                                // );
                                                              } else {
                                                                final id = index
                                                                    .toString();
                                                                GoRouter.of(
                                                                        context)
                                                                    .pushNamed(
                                                                        'catalogue',
                                                                        queryParams: {
                                                                      'id': id,
                                                                    });
                                                              }
                                                            },
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              backgroundColor:
                                                                  HexColor(
                                                                      "8346E1"),
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              5)),
                                                            ),
                                                            child: Text(
                                                              "₹${featuredCourse[index].coursePrice}/-",
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            )),
                                                        //                         featuredCourse[index].trialCourse! ? SizedBox(width: 15) : Container(),
                                                        //             featuredCourse[index].trialCourse! ? SizedBox(
                                                        //               width: screenWidth/12,
                                                        //               child: ElevatedButton(
                                                        //                   onPressed: () {
                                                        //                     showDialog(
                                                        //                       context: context,
                                                        //                         builder: (context) {
                                                        //                         return AlertDialog(
                                                        //                           backgroundColor: Colors.deepPurpleAccent[700],
                                                        //                           title: Text('This course is available for ${featuredCourse[index].trialDays} days trial.',
                                                        //                             style: TextStyle(color: Colors.white),),
                                                        //                           content: Container(
                                                        //                             height: screenHeight/3.5,
                                                        //                             width: screenWidth/2.5,
                                                        //                             child: Column(
                                                        //                               mainAxisAlignment: MainAxisAlignment.center,
                                                        //                               children: [
                                                        //                                 Container(
                                                        //                                   height: screenHeight/5.2,
                                                        //                                   width: screenWidth/3.5,
                                                        //                                   decoration: BoxDecoration(
                                                        //                                     borderRadius: BorderRadius.circular(10),
                                                        //                                     border: Border.all(color: Colors.white, width: 0.5),
                                                        //                                     color: Colors.white,
                                                        //                                   ),
                                                        //                                   child: Column(
                                                        //                                     mainAxisAlignment: MainAxisAlignment.center,
                                                        //                                     children: [
                                                        //                                       Row(
                                                        //                                         children: [
                                                        //                                           Expanded(
                                                        //                                             flex: 1,
                                                        //                                             child: Container(
                                                        //                                               child: ClipRRect(
                                                        //                                                 borderRadius: BorderRadius.only(
                                                        //                                                     topLeft: Radius
                                                        //                                                         .circular(
                                                        //                                                         15),
                                                        //                                                     topRight: Radius
                                                        //                                                         .circular(
                                                        //                                                         15)),
                                                        //                                                 child:
                                                        //                                                 Image.network(
                                                        //                                                   featuredCourse[index].courseImageUrl,
                                                        //                                                   fit: BoxFit.fill,
                                                        //                                                 ),
                                                        //                                               ),
                                                        //                                             ),
                                                        //                                           ),
                                                        //                                           Expanded(
                                                        //                                             child: Container(
                                                        //                                               child: Text(featuredCourse[index].courseName,
                                                        //                                                   style: TextStyle(fontWeight: FontWeight.bold) ),
                                                        //                                             ),
                                                        //                                           ),
                                                        //                                         ],
                                                        //                                       )
                                                        //                                     ],
                                                        //                                   )
                                                        //                                 ),
                                                        //                                 SizedBox(height: 15),
                                                        //                                 Row(
                                                        //                                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        //                                   children: [
                                                        //                                     Container(
                                                        //                                       decoration: BoxDecoration(
                                                        //                                         borderRadius: BorderRadius.circular(10),
                                                        //                                         border: Border.all(color: Colors.white, width: 0.5),
                                                        //                                       ),
                                                        //                                       child: TextButton(
                                                        //                                         onPressed: () {
                                                        // print('this is condition ${userMap['paidCourseNames'].contains(featuredCourse[index].courseId)}');
                                                        //                                         Navigator.of(context).pop();
                                                        //                                       },
                                                        //                                         child: Text('Close',
                                                        //                                         style: TextStyle(
                                                        //                                             color: Colors.white
                                                        //                                         ),
                                                        //                                       ),
                                                        //                                       ),
                                                        //                                     ),
                                                        //                                     Container(
                                                        //                                       decoration: BoxDecoration(
                                                        //                                         borderRadius: BorderRadius.circular(10),
                                                        //                                         border: Border.all(color: Colors.white, width: 0.5),
                                                        //                                       ),
                                                        //                                       child: TextButton(
                                                        //                                           onPressed: () {
                                                        //                                              if (userMap['paidCourseNames'].contains(featuredCourse[index].courseId)) {
                                                        //                                               // AlertDialog(
                                                        //                                               //   content: Container(
                                                        //                                               //     child: Text('This course already exist in your trial course...'),
                                                        //                                               //   ),
                                                        //                                               // );
                                                        //                                               Fluttertoast.showToast(msg: 'This course already exist in your trial course...');
                                                        //                                               Navigator.of(context).pop();
                                                        //                                             } else {
                                                        //                                               print('paidCourseNames before ${userMap['paidCourseNames']}');
                                                        //                                               setState(() {
                                                        //                                                 userMap['paidCourseNames'].add(featuredCourse[index].courseId);
                                                        //                                                 FirebaseFirestore.instance.collection("Users_dataly")
                                                        //                                                     .doc(FirebaseAuth.instance.currentUser!.uid)
                                                        //                                                     .update({
                                                        //                                                   'paidCourseNames': userMap['paidCourseNames'],
                                                        //                                                 });
                                                        //                                                 loadCourses(featuredCourse[index].courseId);
                                                        //                                                 Fluttertoast.showToast(msg: 'Congrats!! Course is now available in enrolled courses for ${featuredCourse[index].trialDays}...');
                                                        //                                               });
                                                        //                                               Timer(
                                                        //                                                   Duration(seconds: 1),
                                                        //                                                       () => GoRouter.of(context).pushReplacementNamed('myCourses')
                                                        //
                                                        //                                                 //     Navigator.pushReplacement(
                                                        //                                                 // context, MaterialPageRoute(builder: (context) => Authenticate()))
                                                        //
                                                        //                                               );
                                                        //                                               print('paidCourseNames ${userMap['paidCourseNames']}');
                                                        //                                             }
                                                        //                                           },
                                                        //                                           child: Text('Start your free trial',
                                                        //                                             style: TextStyle(
                                                        //                                             color: Colors.white
                                                        //                                           ),
                                                        //                                           ),
                                                        //                                       ),
                                                        //                                     ),
                                                        //
                                                        //                                   ],
                                                        //                                 ),
                                                        //                               ],
                                                        //                             ),
                                                        //                           ),
                                                        //                         );
                                                        //                     });
                                                        //                   },
                                                        //                   child: Text('${featuredCourse[index].trialDays} days trial')),
                                                        //             ) : Container(),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ));
                              return Container();
                            }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: screenWidth,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                          color: Color.fromRGBO(
                            0,
                            0,
                            0,
                            0.35,
                          ),
                          offset: Offset(5, 5),
                          blurRadius: 52)
                    ],
                  ),
                  child: Stack(
                    children: [
                      Container(
                        width: 414 * horizontalScale,
                        height: 280 * verticalScale,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(15),
                            bottomRight: Radius.circular(15),
                          ),
                        ),
                        child: Image.network(
                          'https://firebasestorage.googleapis.com/v0/b/cloudyml-app.appspot.com/o/test_developer%2Fh1.png?alt=media&token=e51a6697-9b1d-467b-8443-b4251181830e',
                          fit: BoxFit.fill,
                        ),
                      ),
                      Positioned(
                        right: 5,
                        child: IconButton(
                            onPressed: () {
                              logOut(context);
                              saveLoginOutState(context);
                            },
                            icon: Icon(Icons.logout_rounded)),
                      ),
                      Positioned(
                        left: 5,
                        child: IconButton(
                            onPressed: () {
                              Scaffold.of(context).openDrawer();
                            },
                            icon: Icon(Icons.menu)),
                      ),
                      Positioned(
                        top: 7,
                        left: 45,
                        child: Row(
                          children: [
                            // Image.asset(
                            //   "assets/DATALY Logo.png",
                            //   width: 25,
                            //   height: 20,
                            // ),
                            Text(
                              "CloudyML",
                              style: textStyle,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 38,
                  width: screenWidth,
                  color: Colors.deepPurpleAccent[300],
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 10.0,
                      bottom: 4,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            launch(
                                'https://apps.apple.com/app/cloudyml-data-science-course/id6444130328');
                          },
                          child: Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.apple_outlined,
                                  color: Colors.white,
                                  size: 12,
                                ),
                                Column(
                                  children: [
                                    Text(
                                      'Download our IOS app from',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 4),
                                    ),
                                    Text('APPLE STORE',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 6)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 50,
                        ),
                        InkWell(
                          onTap: () {
                            launch(
                                'https://play.google.com/store/apps/details?id=com.cloudyml.cloudymlapp');
                          },
                          child: Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.play_arrow,
                                  color: Colors.black,
                                  size: 12,
                                ),
                                Column(
                                  children: [
                                    Text(
                                      'Download our Android app from',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 4),
                                    ),
                                    Text('GOOGLE PLAY',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 6)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      left: 20 * horizontalScale,
                      top: 20 * verticalScale,
                      bottom: 5),
                  child: Text(
                    'What make us different?',
                    textScaleFactor: min(horizontalScale, verticalScale),
                    style: TextStyle(
                      color: Color.fromRGBO(0, 0, 0, 1),
                      fontFamily: 'Poppins',
                      fontSize: 23,
                      letterSpacing:
                          0 /*percentages not used in flutter. defaulting to zero*/,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Container(
                  height: 130,
                  width: width,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage(
                          "assets/UII.png",
                        )),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                          // left: (width-150)/12,
                          left: width * 0.082,
                          top: 20,
                          child: Container(
                            alignment: Alignment.center,
                            height: 90,
                            // width: (width-150)/4.2,
                            width: width * 0.24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              "100% paid internship after combo course completion",
                              style: TextStyle(
                                fontSize: 8,
                                fontFamily: 'Bold',
                              ),
                              maxLines: 5,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )),
                      Positioned(
                          // left: (width-150)/12,
                          left: width * 0.18,
                          top: 6.8,
                          child: Container(
                            alignment: Alignment.center,
                            height: 15,
                            // width: (width-150)/4.2,
                            width: 15,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: HexColor("#592CA4")),
                            child: Text(
                              "1",
                              style: TextStyle(
                                  fontSize: 8,
                                  fontFamily: 'Bold',
                                  color: Colors.white),
                              maxLines: 5,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )),
                      Positioned(
                          // left: (width-150)/12,
                          left: width * 0.38,
                          top: 20,
                          child: Container(
                            alignment: Alignment.center,
                            height: 90,
                            // width: (width-150)/4.2,
                            width: width * 0.24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              "We provide \n hands on learning experience",
                              style: TextStyle(
                                fontSize: 8,
                                fontFamily: 'Bold',
                              ),
                              maxLines: 5,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )),
                      Positioned(
                          // left: (width-150)/12,
                          left: width * 0.48,
                          top: 6.8,
                          child: Container(
                            alignment: Alignment.center,
                            height: 15,
                            // width: (width-150)/4.2,
                            width: 15,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: HexColor("#592CA4")),
                            child: Text(
                              "2",
                              style: TextStyle(
                                  fontSize: 8,
                                  fontFamily: 'Bold',
                                  color: Colors.white),
                              maxLines: 5,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )),
                      Positioned(
                          // left: (width-150)/12,
                          left: width * 0.68,
                          top: 19,
                          // top:height* 0.018,
                          child: Container(
                            alignment: Alignment.center,
                            height: 90,
                            // width: (width-150)/4.2,
                            // height: height * 0.13,
                            width: width * 0.24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              "1-1 teaching assistants for doubt clearance",
                              style: TextStyle(
                                fontSize: 8,
                                fontFamily: 'Bold',
                              ),
                              maxLines: 5,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )),
                      Positioned(
                          // left: (width-150)/12,
                          left: width * 0.79,
                          top: 6.8,
                          child: Container(
                            alignment: Alignment.center,
                            height: 15,
                            // width: (width-150)/4.2,
                            width: 15,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: HexColor("#592CA4")),
                            child: Text(
                              "3",
                              style: TextStyle(
                                  fontSize: 8,
                                  fontFamily: 'Bold',
                                  color: Colors.white),
                              maxLines: 5,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )),
                    ],
                  ),
                ),

                isAnnounceMent
                    ? Padding(
                        padding: EdgeInsets.only(
                            left: 20 * horizontalScale,
                            right: 20 * horizontalScale,
                            bottom: 4
                            // top: 20 * verticalScale,
                            ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Announcements 📣',
                              textScaleFactor:
                                  min(horizontalScale, verticalScale),
                              style: TextStyle(
                                color: Color.fromRGBO(0, 0, 0, 1),
                                fontFamily: 'Poppins',
                                fontSize: 23,
                                letterSpacing:
                                    0 /*percentages not used in flutter. defaulting to zero*/,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              padding: EdgeInsets.only(
                                left: 10 * horizontalScale,
                                right: 10 * horizontalScale,
                                top: 15 * verticalScale,
                                bottom: 15 * verticalScale,

                                // top: 20 * verticalScale,
                              ),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.deepPurple.withOpacity(0.12)),
                              child: Center(
                                child: Text(
                                  announcementMsg,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    : SizedBox(),

                SizedBox(
                  height: 10,
                ),
                courses.length > 0
                    ? Padding(
                        padding: EdgeInsets.only(
                            left: 20 * horizontalScale, bottom: 4
                            // top: 20 * verticalScale,
                            ),
                        child: Text(
                          'My Courses',
                          textScaleFactor: min(horizontalScale, verticalScale),
                          style: TextStyle(
                            color: Color.fromRGBO(0, 0, 0, 1),
                            fontFamily: 'Poppins',
                            fontSize: 23,
                            letterSpacing:
                                0 /*percentages not used in flutter. defaulting to zero*/,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    : SizedBox(),
                courses.length > 0
                    ? Container(
                        width: width,
                        height: 130,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: EdgeInsets.only(top: 2, bottom: 7, left: 10),
                        child: MediaQuery.removePadding(
                          context: context,
                          removeTop: true,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            // shrinkWrap: true,
                            itemCount: course.length,
                            itemBuilder: (BuildContext context, int index) {
                              if (course[index].courseName == "null") {
                                return Container();
                              }
                              if (courses.contains(course[index].courseId)) {
                                return InkWell(
                                  onTap: (() {
                                    // setModuleId(snapshot.data!.docs[index].id);
                                    getCourseName();
                                    if (navigateToCatalogueScreen(
                                            course[index].courseId) &&
                                        !(userMap['payInPartsDetails']
                                                [course[index].courseId]
                                            ['outStandingAmtPaid'])) {
                                      if (!course[index].isItComboCourse) {
                                        Navigator.push(
                                          context,
                                          PageTransition(
                                            duration:
                                                Duration(milliseconds: 400),
                                            curve: Curves.bounceInOut,
                                            type: PageTransitionType
                                                .rightToLeftWithFade,
                                            child: VideoScreen(
                                              isDemo: true,
                                              courseName:
                                                  course[index].courseName,
                                              sr: 1,
                                            ),
                                          ),
                                        );
                                      } else {
                                        Navigator.push(
                                          context,
                                          PageTransition(
                                            duration:
                                                Duration(milliseconds: 100),
                                            curve: Curves.bounceInOut,
                                            type: PageTransitionType
                                                .rightToLeftWithFade,
                                            child: ComboStore(
                                              courses: course[index].courses,
                                            ),
                                          ),
                                        );
                                      }
                                    } else {
                                      if (!course[index].isItComboCourse) {
                                        if (course[index].courseContent ==
                                            'pdf') {
                                          Navigator.push(
                                            context,
                                            PageTransition(
                                              duration:
                                                  Duration(milliseconds: 400),
                                              curve: Curves.bounceInOut,
                                              type: PageTransitionType
                                                  .rightToLeftWithFade,
                                              child: PdfCourseScreen(
                                                curriculum:
                                                    course[index].curriculum
                                                        as Map<String, dynamic>,
                                              ),
                                            ),
                                          );
                                        } else {
                                          Navigator.push(
                                            context,
                                            PageTransition(
                                              duration:
                                                  Duration(milliseconds: 400),
                                              curve: Curves.bounceInOut,
                                              type: PageTransitionType
                                                  .rightToLeftWithFade,
                                              child: VideoScreen(
                                                isDemo: true,
                                                courseName:
                                                    course[index].courseName,
                                                sr: 1,
                                              ),
                                            ),
                                          );
                                        }
                                      } else {
                                        ComboCourse.comboId.value =
                                            course[index].courseId;
                                        mainCourseId = course[index].courseId;
                                        final id = index.toString();
                                        final courseName =
                                            course[index].courseName;

                                        // GoRouter.of(context).pushNamed('newcomboCourse', queryParams: {'id': id, 'courseName': courseName});
                                        GoRouter.of(context).pushNamed(
                                            'NewComboCourseScreen',
                                            queryParams: {
                                              'courseId':
                                                  course[index].courseId,
                                              'courseName': courseName
                                            });
                                      }
                                    }
                                    setState(() {
                                      courseId = course[index].courseDocumentId;
                                    });
                                  }),
                                  child: Container(
                                      height: 150,
                                      width: 320,
                                      margin: EdgeInsets.only(right: 10),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: Color(0xFFE9E1FC)),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              width: 200,
                                              height: 150,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(5)),
                                              child: Container(
                                                margin: EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(10),
                                                    topRight:
                                                        Radius.circular(10),
                                                    bottomLeft:
                                                        Radius.circular(10),
                                                    bottomRight:
                                                        Radius.circular(10),
                                                  ),
                                                  image: DecorationImage(
                                                      image:
                                                          CachedNetworkImageProvider(
                                                        course[index]
                                                            .courseImageUrl,
                                                      ),
                                                      fit: BoxFit.fitHeight),
                                                ),
                                              ),
                                            ),
                                            flex: 1,
                                          ),
                                          Expanded(
                                              child: Container(
                                                  width: 200,
                                                  height: 150,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        course[index]
                                                                .isItComboCourse
                                                            ? Row(
                                                                children: [
                                                                  Container(
                                                                    width: 70,
                                                                    height: 37,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10),
                                                                      // gradient: gradient,
                                                                      color: Color(
                                                                          0xFF7860DC),
                                                                    ),
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          Text(
                                                                        'COMBO',
                                                                        style:
                                                                            const TextStyle(
                                                                          fontFamily:
                                                                              'Bold',
                                                                          fontSize:
                                                                              10,
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          color:
                                                                              Colors.white,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  )
                                                                ],
                                                              )
                                                            : Container(),
                                                        Container(
                                                          child: Text(
                                                            course[index]
                                                                .courseName,
                                                            style: TextStyle(
                                                                color: Color
                                                                    .fromRGBO(
                                                                  0,
                                                                  0,
                                                                  0,
                                                                  1,
                                                                ),
                                                                fontFamily:
                                                                    'Poppins',
                                                                fontSize: 13,
                                                                letterSpacing:
                                                                    0 /*percentages not used in flutter. defaulting to zero*/,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                height: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis),
                                                            // overflow: TextOverflow.ellipsis,
                                                            maxLines: 2,
                                                          ),
                                                        ),
                                                        course[index]
                                                                    .isItComboCourse &&
                                                                statusOfPayInParts(
                                                                    course[index]
                                                                        .courseId)
                                                            ? Container(
                                                                child: !navigateToCatalogueScreen(
                                                                        course[index]
                                                                            .courseId)
                                                                    ? Container(
                                                                        height: MediaQuery.of(context).size.width *
                                                                            0.08 *
                                                                            verticalScale,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          borderRadius:
                                                                              BorderRadius.circular(
                                                                            10,
                                                                          ),
                                                                          color:
                                                                              Color(
                                                                            0xFFC0AAF5,
                                                                          ),
                                                                        ),
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceEvenly,
                                                                          children: [
                                                                            SizedBox(
                                                                              width: 10,
                                                                            ),
                                                                            Text(
                                                                              'Access ends in days : ',
                                                                              textScaleFactor: min(horizontalScale, verticalScale),
                                                                              style: TextStyle(
                                                                                color: Colors.white,
                                                                                fontSize: 13,
                                                                                fontWeight: FontWeight.bold,
                                                                              ),
                                                                            ),
                                                                            Container(
                                                                              decoration: BoxDecoration(
                                                                                borderRadius: BorderRadius.circular(10),
                                                                                color: Colors.grey.shade100,
                                                                              ),
                                                                              width: 30 * min(horizontalScale, verticalScale),
                                                                              height: 30 * min(horizontalScale, verticalScale),
                                                                              // color:
                                                                              //     Color(0xFFaefb2a),
                                                                              child: Center(
                                                                                child: Text(
                                                                                  '${(DateTime.parse(userMap['payInPartsDetails'][course[index].courseId]['endDateOfLimitedAccess']).difference(DateTime.now()).inDays)}',
                                                                                  textScaleFactor: min(horizontalScale, verticalScale),
                                                                                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold
                                                                                      // fontSize: 16,
                                                                                      ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      )
                                                                    : Container(
                                                                        height: MediaQuery.of(context).size.width *
                                                                            0.08,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          borderRadius:
                                                                              BorderRadius.circular(10),
                                                                          color:
                                                                              Color(0xFFC0AAF5),
                                                                        ),
                                                                        child:
                                                                            Center(
                                                                          child:
                                                                              Text(
                                                                            'Limited access expired !',
                                                                            textScaleFactor:
                                                                                min(horizontalScale, verticalScale),
                                                                            style:
                                                                                TextStyle(
                                                                              color: Colors.deepOrange[600],
                                                                              fontSize: 13,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                              )
                                                            : SizedBox(),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Container(
                                                              child: Text(
                                                                course[index]
                                                                        .courseLanguage +
                                                                    "  ||",
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'Medium',
                                                                    color: Colors
                                                                        .black
                                                                        .withOpacity(
                                                                            0.4),
                                                                    fontSize:
                                                                        10,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 6,
                                                            ),
                                                            Container(
                                                              child: Center(
                                                                child: Text(
                                                                  '${course[index].numOfVideos} videos',
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          'Medium',
                                                                      color: Colors
                                                                          .black
                                                                          .withOpacity(
                                                                              0.7),
                                                                      fontSize:
                                                                          10),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ])))
                                        ],
                                      )),
                                );
                              } else {
                                return Container();
                              }
                            },
                          ),
                        ),
                      )
                    : SizedBox(),
                Padding(
                  padding: EdgeInsets.only(
                    left: 20 * horizontalScale,
                    // top: 20 * verticalScale,
                  ),
                  child: Text(
                    'Feature Courses',
                    textScaleFactor: min(horizontalScale, verticalScale),
                    style: TextStyle(
                      color: Color.fromRGBO(0, 0, 0, 1),
                      fontFamily: 'Poppins',
                      fontSize: 23,
                      letterSpacing:
                          0 /*percentages not used in flutter. defaulting to zero*/,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Container(
                  width: screenWidth,
                  height: 190,
                  margin: EdgeInsets.only(top: 10, bottom: 5),
                  child: MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    removeBottom: true,
                    removeLeft: true,
                    removeRight: true,
                    child: ListView.builder(
                      // physics: NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      itemCount: featuredCourse.length,
                      itemBuilder: (BuildContext context, index) {
                        return InkWell(
                          onTap: () {
                            setState(() {
                              courseId = featuredCourse[index].courseDocumentId;
                            });
                            print(courseId);
                            if (featuredCourse[index].isItComboCourse) {
                              print(featuredCourse[index].courses);

                              final id = index.toString();
                              final cID =
                                  featuredCourse[index].courseDocumentId;
                              final courseName =
                                  featuredCourse[index].courseName;
                              final courseP = featuredCourse[index].coursePrice;
                              GoRouter.of(context).pushNamed('featuredCourses',
                                  queryParams: {
                                    'cID': cID,
                                    'courseName': courseName,
                                    'id': id,
                                    'coursePrice': courseP
                                  });

                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) =>
                              //         ComboStore(
                              //           courses:
                              //           course[index].courses,
                              //         ),
                              //   ),
                              // );
                            } else {
                              final id = index.toString();
                              GoRouter.of(context).pushNamed('catalogue',
                                  queryParams: {'id': id});
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [
                                  HexColor("#2C004F"),
                                  HexColor("#8024C9")
                                ]),
                                boxShadow: [
                                  BoxShadow(
                                    color: HexColor("#8024C9"),
                                    blurRadius: 1.5, offset: Offset(1, 2),
                                    // spreadRadius: 0.3
                                  )
                                ],
                                borderRadius: BorderRadius.circular(20)),
                            margin:
                                EdgeInsets.only(left: 15, top: 5, bottom: 5),
                            padding: EdgeInsets.only(
                                left: 15, right: 5, top: 15, bottom: 15),
                            width: 300,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Padding(
                                    padding: EdgeInsets.only(right: 10),
                                    child: Text(
                                        "${featuredCourse[index].courseName}",
                                        style: TextStyle(
                                            fontSize: 17,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            overflow: TextOverflow.ellipsis,
                                            fontFamily: 'Bold'),
                                        maxLines: 1),
                                  ),
                                ),
                                Expanded(
                                  flex: 8,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 5,
                                        child: Column(
                                          children: [
                                            Expanded(
                                              child: SizedBox(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          RatingBarIndicator(
                                                            rating: 5.0,
                                                            itemBuilder:
                                                                (context,
                                                                        index) =>
                                                                    Icon(
                                                              Icons.star,
                                                              color: HexColor(
                                                                  "#31D198"),
                                                            ),
                                                            itemCount: 5,
                                                            itemSize: 15.0,
                                                            direction:
                                                                Axis.horizontal,
                                                            unratedColor:
                                                                Colors.purple,
                                                          ),
                                                          SizedBox(
                                                            width: 10,
                                                          ),
                                                          Text(
                                                            "5.0",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 13),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    Expanded(
                                                        child: Text(
                                                      "English  ||  ${featuredCourse[index].numOfVideos} Videos",
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          color: Colors.white),
                                                    ))
                                                  ],
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 8,
                                            ),
                                            Expanded(
                                              child: Column(
                                                children: [
                                                  Expanded(
                                                      child: Align(
                                                    alignment:
                                                        Alignment.topLeft,
                                                    child: RichText(
                                                      text: TextSpan(children: [
                                                        // TextSpan(text:"3599/-  ",style: TextStyle(color: Colors.white,fontSize: 16,overflow: TextOverflow.ellipsis),),
                                                        TextSpan(
                                                          text:
                                                              "₹${featuredCourse[index].coursePrice}/-",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontFamily:
                                                                  'Poppins',
                                                              fontSize: 20,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis),
                                                        )
                                                      ]),
                                                    ),
                                                  )),
                                                  Expanded(
                                                    child: Align(
                                                      alignment:
                                                          Alignment.bottomLeft,
                                                      child: ElevatedButton(
                                                        style: ButtonStyle(
                                                            backgroundColor:
                                                                MaterialStateProperty
                                                                    .all(HexColor(
                                                                        "#2FBF8B")),
                                                            shape: MaterialStateProperty
                                                                .all<
                                                                    RoundedRectangleBorder>(
                                                              RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            18.0),
                                                              ),
                                                            )),
                                                        onPressed: () async {
                                                          print("Curriculum");
                                                          setState(() {
                                                            courseId =
                                                                featuredCourse[
                                                                        index]
                                                                    .courseDocumentId;
                                                          });
                                                          // print(await course[index].curriculum);
                                                          // await Navigator.push(
                                                          //   context,
                                                          //   MaterialPageRoute(
                                                          //     builder: (context) => Curriculam(courseDetail: course[index])
                                                          //   ),
                                                          // );
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  const CatelogueScreen(),
                                                            ),
                                                          );
                                                        },
                                                        child: Text(
                                                          "Enroll now",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontFamily:
                                                                  'Regular',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 14),
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        flex: 4,
                                        child: Column(
                                          children: [
                                            Expanded(
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                child: CachedNetworkImage(
                                                  imageUrl: course[index]
                                                      .courseImageUrl,
                                                  placeholder: (context, url) =>
                                                      Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                    heightFactor: 30,
                                                    widthFactor: 30,
                                                  ),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          Icon(Icons.error),
                                                  fit: BoxFit.fill,
                                                  height: 100 * verticalScale,
                                                  width: 127 * horizontalScale,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: 20,
                    top: 10,
                  ),
                  child: Text(
                    'Success Stories',
                    textScaleFactor: min(horizontalScale, verticalScale),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color.fromRGBO(0, 0, 0, 1),
                        fontFamily: 'Poppins',
                        fontSize: 23,
                        letterSpacing:
                            0 /*percentages not used in flutter. defaulting to zero*/,
                        fontWeight: FontWeight.w500,
                        height: 1),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  // height: screenHeight * 0.81 * verticalScale,
                  height: 200,
                  width: screenWidth,
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: FutureBuilder<List<FirebaseFile>>(
                    future: futureFiles,
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          return Center(child: CircularProgressIndicator());
                        default:
                          if (snapshot.hasError) {
                            return Center(
                                child: Text(
                              'Some error occurred!',
                              textScaleFactor:
                                  min(horizontalScale, verticalScale),
                            ));
                          } else {
                            final files = snapshot.data!;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    // physics: NeverScrollableScrollPhysics(),
                                    itemCount: files.length,
                                    itemBuilder: (context, index) {
                                      final file = files[index];
                                      return Container(
                                          decoration: BoxDecoration(
                                              color: HexColor("#FFFFFF"),
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              boxShadow: [
                                                BoxShadow(
                                                    color: Colors.grey,
                                                    blurRadius: 5,
                                                    offset: Offset(0, 1))
                                              ]),
                                          margin: EdgeInsets.only(
                                              left: 15, top: 5, bottom: 5),
                                          padding: EdgeInsets.only(
                                              left: 15,
                                              right: 15,
                                              top: 12,
                                              bottom: 10),
                                          height: 200,
                                          width: 300,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            child: CachedNetworkImage(
                                              placeholder: (context, url) => Center(
                                                  child:
                                                      CircularProgressIndicator()),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Icon(Icons.error),
                                              imageUrl: file.url,
                                              fit: BoxFit.cover,
                                            ),
                                          ));
                                      // buildFile(context, file);
                                    },
                                  ),
                                ),
                              ],
                            );
                          }
                      }
                    },
                  ),
                ),
                //SizedBox(height: 15,),
                Container(
                  width: 414 * horizontalScale,
                  height: 250 * verticalScale,
                  child: Image.network(
                      'https://firebasestorage.googleapis.com/v0/b/cloudyml-app.appspot.com/o/test_developer%2Fhomeimage2.png?alt=media&token=cc13e37f-63d7-4036-a0ad-338becea925e',
                      fit: BoxFit.fill),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: 20,
                    top: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'About Me',
                        textScaleFactor: min(horizontalScale, verticalScale),
                        style: TextStyle(
                            color: Color.fromRGBO(0, 0, 0, 1),
                            fontFamily: 'Poppins',
                            fontSize: 25,
                            letterSpacing:
                                0 /*percentages not used in flutter. defaulting to zero*/,
                            fontWeight: FontWeight.w500,
                            height: 1),
                      ),
                      Container(
                        width: 60 * horizontalScale,
                        child: Divider(
                            color: Color.fromRGBO(156, 91, 255, 1),
                            thickness: 2),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 20, top: 10, bottom: 20),
                  child: Text(
                    'I have transitioned my career from Manual Tester to Data Scientist by upskilling myself on my own from various online resources and doing lots of Hands-on practice. For internal switch I sent around 150 mails to different project managers, interviewed in 20 and got selected in 10 projects.\nWhen it came to changing company I put papers with NO offers in hand. And in the notice period I struggled to get a job. First 2 months were very difficult but in the last month things started changing miraculously.\nI attended 40+ interviews in span of 3 months with the help of Naukri and LinkedIn profile Optimizations and got offer by 8 companies.\n Based on my career transition and industrial experience, I have designed this course so anyone from any background can learn Data Science and become Job-Ready at affordable price.',
                  ),
                ),
              ],
            ),
          );
        }
      }),
    );
  }

  int numberOfDays = 3;
}
