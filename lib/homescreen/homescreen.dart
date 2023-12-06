import 'dart:async';
import 'dart:math';
import 'package:cloudyml_app2/homescreen/clipper.dart';
import 'package:cloudyml_app2/widgets/notification_popup.dart';

import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
// import 'package:showcaseview/showcaseview.dart';
import 'package:html/dom.dart' as dom;
import 'package:package_info_plus/package_info_plus.dart';
import '../Services/deeplink_service.dart';
import '../combo/combo_course.dart';
import '../combo/combo_store.dart';
import '../global_variable.dart';
import '../module/pdf_course.dart';
import '../module/video_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudyml_app2/Providers/UserProvider.dart';
import 'package:cloudyml_app2/api/firebase_api.dart';
import 'package:cloudyml_app2/authentication/firebase_auth.dart';
import 'package:cloudyml_app2/models/course_details.dart';
import 'package:cloudyml_app2/router/login_state_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloudyml_app2/fun.dart';
import 'package:cloudyml_app2/models/firebase_file.dart';
import 'package:go_router/go_router.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hive/hive.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:cloudyml_app2/globals.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:star_rating/star_rating.dart';
// import 'package:showcaseview/src/showcase.dart';
import 'package:cloudyml_app2/global_variable.dart' as globals;
import 'package:url_launcher/url_launcher.dart';
import 'dart:html' as html;

import '../payment/stripe/checkout.dart';


var rewardCount = 0;
String? linkMessage;

class LandingScreen extends StatefulWidget {
  const LandingScreen({Key? key}) : super(key: key);

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  late Future<List<FirebaseFile>> futureFiles;
  late Future<List<FirebaseFile>> futurefilesComboCourseReviews;
  late Future<List<FirebaseFile>> futurefilesSocialMediaReviews;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<dynamic> courses = [];
  bool? load = true;
  Map userMap = Map<String, dynamic>();
  final GlobalKey gbkey1 = GlobalKey();

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

  void refreshPage() {
    print('owjofewoijeow');
    html.window.location.reload();
  }

  checkifupdatedversionisavailable() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    try {
      print('efjowoiejfwo');
      FirebaseFirestore.instance
          .collection('Controllers')
          .doc('variables')
          .get()
          .then((value) {
        String version = packageInfo.version;
        String buildNumber = packageInfo.buildNumber;
        print('efjowoiejfwo1');
        print(version + buildNumber);
        print(value.data()!['webversion']);
        if (value.data()!['webversion'] != "$version+$buildNumber") {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('New version available'),
                  content: Text('Please update the app to continue using it'),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Continue')),
                    TextButton(
                        onPressed: () {
                          refreshPage();
                        },
                        child: Text('Update'))
                  ],
                );
              });
        }
      });
    } catch (e) {
      print('error in checking version $e');
    }
  }

  // void addCoursetoUser(String id) async {
  //   await FirebaseFirestore.instance
  //       .collection("Users_dataly")
  //       .doc(FirebaseAuth.instance.currentUser!.uid)
  //       .update({
  //     'paidCourseNames': FieldValue.arrayUnion([id])
  //   });
  // }

  setNotification() async {
    var time;
    final DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('Notice')
        .doc('UcQl27Kl9hEEr1g2s0CK')
        .get();
    time = doc['time'].toDate();
    if (DateTime.now().isAfter(time)) {
      if (!notificationList.contains(doc['Msg'].toString())) {
        print('Notification settted');
        print('Notification ${notificationList.length}');
        setState(() {
          notificationList.add(doc['Msg'].toString());
        });
      }
    } else {
      notificationList.clear();
    }
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
        globals.quiztrack = userMap['quiztrack'];
        // whetherSubScribedToPayInParts =
        //     !(!(map['payInPartsDetails']['outStandingAmtPaid'] == null));
      });
    } catch (e) {
      print("ggggggggggg $e");
    }
  }

  late ScrollController _controller;
  final notificationBox = Hive.box('NotificationBox');

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
      if (element.dataly_FcSerialNumber!.isNotEmpty && element.dataly_FcSerialNumber != null) {
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

  var ref;
  var userDocData;
  String numberOfLearners = '';
  var sessionExpiryDays;
  userData() async {
    try {
      ref = await FirebaseFirestore.instance
          .collection("Users_dataly")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      var learners = await FirebaseFirestore.instance
          .collection('Notice')
          .doc('sessionExpiryDays')
          .get();
      numberOfLearners = learners['dataly_numberOfLearners'];
      sessionExpiryDays = learners['sessionExpiryDays'];
      print('uid is ${FirebaseAuth.instance.currentUser!.uid}');

      print(ref.data()!["role"].toString());
      userDocData = ref.data()!;

      var userSessionExpiryTime = ref.data()!["sessionExpiryTime"];

      if (userSessionExpiryTime == null) {
        DateTime now = DateTime.now();
        DateTime updatedTime = now.add(Duration(days: sessionExpiryDays));
        await FirebaseFirestore.instance
            .collection("Users_dataly")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({
          'sessionExpiryTime': Timestamp.fromDate(updatedTime),
        });
      }

      print('userSessionExpiryTime $userSessionExpiryTime');
      Timestamp timeStamp = userSessionExpiryTime;
      DateTime dateTime = timeStamp.toDate();
      print('converted dateTime $dateTime');

      if (DateTime.now().isAfter(dateTime)) {
        DateTime now = DateTime.now();
        DateTime updatedTime = now.add(Duration(days: sessionExpiryDays));

        await FirebaseFirestore.instance
            .collection("Users_dataly")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({
          'sessionExpiryTime': Timestamp.fromDate(updatedTime),
        });
        print('I am afterlife');
        saveLoginOutState(context);
        logOut(context);
      }
    } catch (e) {
      print("kkkkkkk ${e}");
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
    // try {
    //   print('4');
    //   final deepLinkRepo = await DeepLinkService.instance;
    //   var referralCode = await deepLinkRepo?.referrerCode.value;
    //   print(
    //       "sddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd ${referralCode}");
    //   final referCode = await CodeGenerator().generateCode('refer');
    //   final referLink =
    //       await DeepLinkService.instance?.createReferLink(referCode);
    //   setState(() {
    //     if (referralCode != '') {
    //       rewardCount = 50;
    //     } else {
    //       rewardCount = 0;
    //     }
    //     linkMessage = referLink;
    //     print(linkMessage);
    //   });

    //   await FirebaseFirestore.instance
    //       .collection("Users_dataly")
    //       .doc(FirebaseAuth.instance.currentUser!.uid)
    //       .update({
    //     'refer_link': referLink,
    //     'refer_code': referCode,
    //     "referral_code": referralCode,
    //     'reward': rewardCount,
    //   }).whenComplete(() => print(
    //           "send data to firebase uid: ${FirebaseAuth.instance.currentUser!.uid}"));

    //   Future<ReferalModel> getReferrerUser(String referCode) async {
    //     print("iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii ${referCode}");
    //     final docSnapshots = await FirebaseFirestore.instance
    //         .collection("Users_dataly")
    //         .where('refer_code', isEqualTo: referCode)
    //         .get();

    //     final userSnapshot = docSnapshots.docs.first;
    //     print(
    //         "iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii ${userSnapshot.exists}");
    //     if (userSnapshot.exists) {
    //       print(userSnapshot.data());
    //       return ReferalModel.fromJson(userSnapshot.data());
    //     } else {
    //       return ReferalModel.empty();
    //     }
    //   }

    //   Future<void> rewardUser(
    //       String currentUserUID, String referrerCode) async {
    //     try {
    //       if (referrerCode.toString().substring(0, 11) != "moneyreward") {
    //         final referer = await getReferrerUser(referrerCode);
    //         print(
    //             "iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii ${referer.id}");

    //         final checkIfUserAlreadyExist = await FirebaseFirestore.instance
    //             .collection("Users_dataly")
    //             .doc(referer.id)
    //             .collection('referrers')
    //             .doc(currentUserUID)
    //             .get();

    //         if (!checkIfUserAlreadyExist.exists) {
    //           await FirebaseFirestore.instance
    //               .collection("Users_dataly")
    //               .doc(referer.id)
    //               .collection('referrers')
    //               .doc(currentUserUID)
    //               .set({
    //             "uid": currentUserUID,
    //             "createdAt": DateTime.now(),
    //           });

    //           await FirebaseFirestore.instance
    //               .collection("Users_dataly")
    //               .doc(referer.id)
    //               .update({
    //             "reward": FieldValue.increment(50),
    //             "rewardvalidfrom": DateTime.now()
    //           });
    //         }
    //       }
    //     } catch (e) {
    //       debugPrint(e.toString());
    //     }
    //   }

    //   if (referralCode != "") {
    //     print("iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii ${referralCode}");
    //     await rewardUser(FirebaseAuth.instance.currentUser!.uid, referralCode!);
    //   }
    //   ;
    // } catch (e) {
    //   print(
    //       "................................................................................................................................${e}");
    // }
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

  // void startTimer() {
  //   countDownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
  //     setCountDown();
  //   });
  // }
  //
  // void stopTimer() {
  //   setState(() {
  //     countDownTimer!.cancel();
  //   });
  // }
  //
  // void resetTimer() {
  //   stopTimer();
  //   setState(() {
  //     myDuration = Duration(days: 5);
  //   });
  // }

  // setCountDown() {
  //   final reduceSecs = 1;
  //   setState(() {
  //     final seconds = myDuration.inSeconds - reduceSecs;
  //     if (seconds < 0) {
  //       countDownTimer!.cancel();
  //     } else {
  //       myDuration = Duration(seconds: seconds);
  //     }
  //   });
  // }

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

  getQuizDataAndUpdateScores() async {
    try {
      await FirebaseFirestore.instance
          .collection("Users_dataly")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get()
          .then((value) async {
        var data = value.data()!['quiztrack'];
        print('qizzzz data.length ${data.length}');
        for (var i = 0; i < data.length; i++) {
          var myMap = data[i];
          // for (var myMap in data) {
          try {
            if (myMap.containsKey('quizScore') && myMap['quizScore'] != null) {
              print('quizScore is there.');
            } else {
              num correctint = 0;
              for (var k in myMap['quizdata']) {
                if (k['answeredValue'] == k['answerIndex'][0]) {
                  correctint += 1;
                }
              }
              num total = (correctint / myMap['quizdata'].length) * 100;

              myMap['quizScore'] = total.round();

              print('nohu1 ${data.length}');

              await FirebaseFirestore.instance
                  .collection("Users_dataly")
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .update({'quiztrack': FieldValue.arrayUnion(data)});
            }
          } catch (e) {
            print('dataError $e');
          }
          // }
        }
      });

      await FirebaseFirestore.instance
          .collection("Users_dataly")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get()
          .then((value) async {
        List data2 = value.data()!['quiztrack'];
        print('data2.length ${data2.length}');

        data2.removeWhere((element) => element['quizScore'] == null);

        print('qizzzz data.length ${data2.length}');

        await FirebaseFirestore.instance
            .collection("Users_dataly")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({'quiztrack': data2});
      });
    } catch (e) {
      print('getQuizdataAndUpdateScores $e');
    }
  }

  bool viewAll = false;

  @override
  void initState() {
    getQuizDataAndUpdateScores();
    super.initState();
    // print('this is url ${html.window.location.href}');
    // print('this is path ${Uri.base.path}');
    // showNotification();
    _controller = ScrollController();

    futureFiles = FirebaseApi.listAll('reviews/recent_review');
    futurefilesComboCourseReviews =
        FirebaseApi.listAll('reviews/combo_course_review');
    futurefilesSocialMediaReviews =
        FirebaseApi.listAll('reviews/social_media_review');
    getCourseName();
    print('wefjwejfowjfe');
    fetchCourses();
    // checkifupdatedversionisavailable();
    dbCheckerForPayInParts();
    userData();
    // startTimer();
    // getuserdetails();
    checkrewardexpiry();
  }

  // void refreshPage() {
  //   print('owjofewoijeow');
  //   html.window.location.reload();
  // }

  // checkifupdatedversionisavailable() async {
  //   PackageInfo packageInfo = await PackageInfo.fromPlatform();
  //   try {
  //     print('efjowoiejfwo');
  //     FirebaseFirestore.instance
  //         .collection('Controllers')
  //         .doc('variables')
  //         .get()
  //         .then((value) {
  //       String version = packageInfo.version;
  //       String buildNumber = packageInfo.buildNumber;
  //       print('efjowoiejfwo1');
  //       print(version + buildNumber);
  //       print(value.data()!['webversion']);
  //       if (value.data()!['webversion'] != "$version+$buildNumber") {
  //         showDialog(
  //             context: context,
  //             builder: (context) {
  //               return AlertDialog(
  //                 title: Text('New version available'),
  //                 content: Text('Please update the app to continue using it'),
  //                 actions: [
  //                   TextButton(
  //                       onPressed: () {
  //                         Navigator.pop(context);
  //                       },
  //                       child: Text('Continue')),
  //                   TextButton(
  //                       onPressed: () {
  //                         refreshPage();
  //                       },
  //                       child: Text('Update'))
  //                 ],
  //               );
  //             });
  //       }
  //     });
  //   } catch (e) {
  //     print('error in checking version $e');
  //   }
  // }

  Timer? countDownTimer;
  Duration myDuration = Duration(days: 5);
  bool showToolTip = true;

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
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
    setNotification();
    return Scaffold(
            // resizeToAvoidBottomInset: false,
            key: _scaffoldKey,
      
            drawer: //kIsWeb ? Container() :
                customDrawer(context),
            floatingActionButton: Device.screenType == ScreenType.mobile
                ? Container(
                    height: showToolTip ? 52.sp : 36.sp,
                    width: 60.sp,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        showToolTip
                            ? Stack(
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        height: 32.sp,
                                        width: 60.sp,
                                        padding: EdgeInsets.only(left: 15),
                                        decoration: BoxDecoration(
                                            color: HexColor('#6a5acd')
                                                .withOpacity(0.95),
                                            borderRadius:
                                                BorderRadius.circular(50.sp)),
                                        child: Center(
                                            child: InkWell(
                                          onTap: () => refreshPage(),
                                          child: Text(
                                            'Hey, Chat with your Teaching Assistance(TA) for your Doubt Clearance from 6pm to 12 midnight.',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 13.sp,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        )),
                                      ),
                                      SizedBox(
                                        height: 18.sp,
                                      )
                                    ],
                                  ),
                                  Positioned(
                                    right: 20.sp,
                                    bottom: 5.sp,
                                    child: ClipPath(
                                      clipper: TriangleClipper(),
                                      child: Container(
                                        color: HexColor('#6a5acd')
                                            .withOpacity(0.55),
                                        height: 40,
                                        width: 20,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 16.sp,
                                    top: 8.sp,
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          showToolTip = false;
                                        });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius:
                                                BorderRadius.circular(5.sp)),
                                        height: 15.sp,
                                        width: 15.sp,
                                        child: Icon(
                                          Icons.close,
                                          size: 13.sp,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Container(),
                        Container(
                          width: 50.sp,
                          child: FloatingActionButton(
                            backgroundColor: Colors.purple,
                            onPressed: () {
                              GoRouter.of(context).push('/mobilechat');
                              // showDialog(
                              //     context: context,
                              //     builder: (BuildContext context) {
                              //       return AlertDialog(
                              //         backgroundColor: Colors.white,
                              //         title: Center(
                              //           child: Text('Contact Support'),
                              //         ),
                              //         content: Container(
                              //           height: 30.sp,
                              //           child: Column(
                              //             children: [
                              //               SelectableText(
                              //                   'Please email us at app.support@cloudyml.com'),
                              //               SelectableText(' or call on +91 85879 11971.'),
                              //             ],
                              //           ),
                              //         ),
                              //       );
                              //     });
                            },
                            child: Container(
                                child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.support_agent,
                                  size: 22.sp,
                                ),
                                SizedBox(
                                  width: 10.sp,
                                ),
                                Text(
                                  'Chat With TA',
                                  style: TextStyle(fontSize: 14.sp),
                                ),
                              ],
                            )),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.sp)),
                            isExtended: true,
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(
                    height: showToolTip ? 44.sp : 24.sp,
                    width: 60.sp,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        showToolTip
                            ? Stack(
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        height: 32.sp,
                                        width: 50.sp,
                                        padding: EdgeInsets.only(left: 15),
                                        decoration: BoxDecoration(
                                            color: HexColor('#6a5acd')
                                                .withOpacity(0.95),
                                            borderRadius:
                                                BorderRadius.circular(50.sp)),
                                        child: Center(
                                            child: InkWell(
                                          onTap: () => refreshPage(),
                                          child: Text(
                                            'Hey, Chat with your Teaching Assistance(TA) for your Doubt Clearance from 6pm to 12 midnight..',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 11.sp,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        )),
                                      ),
                                      SizedBox(
                                        height: 18.sp,
                                      )
                                    ],
                                  ),
                                  Positioned(
                                    right: 20.sp,
                                    bottom: 5.sp,
                                    child: ClipPath(
                                      clipper: TriangleClipper(),
                                      child: Container(
                                        color: HexColor('#6a5acd')
                                            .withOpacity(0.55),
                                        height: 35,
                                        width: 20,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 16.sp,
                                    top: 8.sp,
                                    child: InkWell(
                                      onTap: ()
                                      
                                      {
                                        setState(() {
                                          showToolTip = false;
                                        });
        
                                      
                                     },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius:
                                                BorderRadius.circular(5.sp)),
                                        height: 12.5.sp,
                                        width: 12.5.sp,
                                        child: Icon(
                                          Icons.close,
                                          size: 10.sp,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Container(),
                        Container(
                          width: 42.sp,
                          child: FloatingActionButton(
                            backgroundColor: Colors.purple,
                            onPressed: () {
                              GoRouter.of(context).push('/mychat');
                              // showDialog(
                              //     context: context,
                              //     builder: (BuildContext context) {
                              //       return AlertDialog(
                              //         backgroundColor: Colors.white,
                              //         title: Center(
                              //           child: Text('Contact Support'),
                              //         ),
                              //         content: Container(
                              //           height: 30.sp,
                              //           child: Column(
                              //             children: [
                              //               SelectableText(
                              //                   'Please email us at app.support@cloudyml.com'),
                              //               SelectableText(' or call on +91 85879 11971.'),
                              //             ],
                              //           ),
                              //         ),
                              //       );
                              //     });
                            },
                            child: Container(
                                child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.support_agent,
                                  size: 19.sp,
                                ),
                                SizedBox(
                                  width: 7.sp,
                                ),
                                Text(
                                  'Chat With TA',
                                  style: TextStyle(fontSize: 12.sp),
                                ),
                              ],
                            )),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(17.sp)),
                            isExtended: true,
                          ),
                        ),
                      ],
                    ),
                  ),
            body: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
              if (constraints.maxWidth >= 650) {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: screenWidth,
                            height: screenHeight * 2,
                            color: HexColor('F3EBFF'),
                          ),
                          Positioned(
                            bottom: 0,
                            child: Container(
                              width: screenWidth,
                              height: screenHeight * 1.2,
                              child: Image.network(
                                  'https://firebasestorage.googleapis.com/v0/b/cloudyml-app.appspot.com/o/test_developer%2FGroup%20Lines.png?alt=media&token=19ebd446-f667-492b-96ba-c28c5054718f',
                                  fit: BoxFit.fill,
                                  cacheHeight: 350,
                                  cacheWidth: 350,
                                  height: screenHeight,
                                  width: screenWidth),
                            ),
                          ),
                          // home background
                          Container(
                            width: screenWidth,
                            height: screenHeight,
                            child: CachedNetworkImage(
                              memCacheWidth: 350,
                              memCacheHeight: 350,
                              placeholder: (context, url) => Container(
                                color: HexColor('0C001B'),
                              ),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                              imageUrl:
                                  'https://firebasestorage.googleapis.com/v0/b/cloudyml-app.appspot.com/o/test_developer%2Fwebbg.png?alt=media&token=04326232-0b38-44f3-9722-3dfc1a89e052',
                              fit: BoxFit.fill,
                            ),
                          ),
                          // picture of CEO
                          Positioned(
                            top: 75,
                            right: 170,
                            child: Container(
                              width: 450,
                              height: 550,
                              child: CachedNetworkImage(
                                memCacheHeight: 400,
                                memCacheWidth: 400,
                                placeholder: (context, url) =>
                                    Center(child: CircularProgressIndicator()),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                                imageUrl:
                                    'https://firebasestorage.googleapis.com/v0/b/cloudyml-app.appspot.com/o/test_developer%2Fceopic.png?alt=media&token=27a120b5-b4be-486c-b087-271b4f5e8faa',
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                          Positioned(
                            left: 75,
                            top: 125,
                            child: Container(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Learn ',
                                        style: TextStyle(
                                          color: HexColor('FFFFFF'),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 64 * verticalScale,
                                          fontFamily: 'Barlow',
                                        ),
                                      ),
                                      Text(
                                        'Data Science',
                                        style: TextStyle(
                                          color: HexColor('7B4DFF'),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 64 * verticalScale,
                                          fontFamily: 'Barlow',
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    'By Doing It!',
                                    style: TextStyle(
                                      color: HexColor('FFFFFF'),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 64 * verticalScale,
                                      fontFamily: 'Barlow',
                                    ),
                                  ),
                                  SizedBox(
                                    height: 25.sp,
                                  ),
                                  Container(
                                    height: 40.sp,
                                    width: screenWidth / 2.6,
                                    child: Text(
                                      'Get Complete Hands-on Practical Learning Experience with CloudyML and become Job-Ready Data Scientist, Data Analyst, Data Engineer, Business Analyst, Research Analyst and ML Engineer.',
                                      // maxLines: 3,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14.sp,
                                        fontFamily: 'Barlow Semi Condensed',
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Stack(
                                        children: [
                                          Positioned.fill(
                                              child: Container(
                                            margin: EdgeInsets.all(6),
                                            color: Colors.white,
                                          )),
                                          Icon(
                                            Icons.check_circle,
                                            color: Colors.deepPurpleAccent,
                                            size: 25,
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text('Trusted by $numberOfLearners',
                                          style: TextStyle(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.normal,
                                              color: Colors.white)),
                                      SizedBox(
                                        width: 15 * horizontalScale,
                                      ),
                                      Stack(
                                        children: [
                                          Positioned.fill(
                                              child: Container(
                                            margin: EdgeInsets.all(6),
                                            color: Colors.white,
                                          )),
                                          Icon(
                                            Icons.check_circle,
                                            color: Colors.deepPurpleAccent,
                                            size: 25,
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        'Learn from industry experts',
                                        style: TextStyle(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                  // SizedBox(
                                  //   height: 40 * verticalScale,
                                  // ),
                                ],
                              ),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.only(top: 8.0, right: 5),
                            child: customMenuBar(context),
                          ),
                          // Positioned(
                          //   top: verticalScale * 475,
                          //   left: 20 * horizontalScale,
                          //   child: Row(
                          //     children: [
                          //       Stack(
                          //         children: [
                          //           Positioned.fill(
                          //               child: Container(
                          //             margin: EdgeInsets.all(6),
                          //             color: Colors.white,
                          //           )),
                          //           Icon(
                          //             Icons.check_circle,
                          //             color: Colors.deepPurpleAccent,
                          //             size: 25,
                          //           ),
                          //         ],
                          //       ),
                          //       SizedBox(
                          //         width: 5,
                          //       ),
                          //       Text('Trusted by $numberOfLearners',
                          //           style: TextStyle(
                          //               fontSize: 12,
                          //               fontWeight: FontWeight.normal,
                          //               color: Colors.white)),
                          //       SizedBox(
                          //         width: 15 * horizontalScale,
                          //       ),
                          //       Stack(
                          //         children: [
                          //           Positioned.fill(
                          //               child: Container(
                          //             margin: EdgeInsets.all(6),
                          //             color: Colors.white,
                          //           )),
                          //           Icon(
                          //             Icons.check_circle,
                          //             color: Colors.deepPurpleAccent,
                          //             size: 25,
                          //           ),
                          //         ],
                          //       ),
                          //       SizedBox(
                          //         width: 5,
                          //       ),
                          //       Text(
                          //         'Learn from industry experts',
                          //         style: TextStyle(
                          //             fontSize: 12,
                          //             fontWeight: FontWeight.normal,
                          //             color: Colors.white),
                          //       ),
                          //     ],
                          //   ),
                          // ),

                          // Positioned(
                          //     top: verticalScale * 540,
                          //     left: 50,
                          //     child: SizedBox(
                          //       height: 75 * verticalScale,
                          //       child: ElevatedButton(
                          //         style: ElevatedButton.styleFrom(
                          //           backgroundColor: HexColor('8346E1'),
                          //           shape: RoundedRectangleBorder(
                          //             borderRadius:
                          //                 BorderRadius.circular(12), // <-- Radius
                          //           ),
                          //         ),
                          //         onPressed: () {
                          //           GoRouter.of(context).pushNamed('store');
                          //         },
                          //         child: Padding(
                          //           padding: const EdgeInsets.all(8.0),
                          //           child: Row(
                          //             children: [
                          //               Text(
                          //                 'View Courses',
                          //                 style: TextStyle(fontSize: 16),
                          //               ),
                          //               SizedBox(
                          //                 width: 5 * horizontalScale,
                          //               ),
                          //               CircleAvatar(
                          //                   maxRadius: 12,
                          //                   backgroundColor: Colors.white,
                          //                   child: Center(
                          //                     child: Icon(
                          //                       Icons.arrow_forward_rounded,
                          //                       color: Colors.black,
                          //                       size: 17,
                          //                     ),
                          //                   ))
                          //             ],
                          //           ),
                          //         ),
                          //       ),
                          //     )),
                          courses.length > 0
                              ? Positioned(
                                  top: verticalScale * 700,
                                  left: 50,
                                  child: Container(
                                    width: screenWidth * 0.9,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'My Enrolled Courses',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 36 * verticalScale),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            GoRouter.of(context)
                                                .pushReplacementNamed(
                                                    'myCourses');
                                          },
                                          child: Row(
                                            children: [
                                              Text(
                                                'See all',
                                                style: TextStyle(
                                                    color: HexColor('2369F0'),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize:
                                                        24 * verticalScale),
                                              ),
                                              Icon(
                                                Icons.arrow_forward_rounded,
                                                color: HexColor('2369F0'),
                                                size: 30 * verticalScale,
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ))
                              : Container(),
                          Positioned(
                              top: verticalScale * 785,
                              child: courses.length > 0
                                  ? Container(
                                      width: screenWidth,
                                      height: screenHeight / 4,
                                      child: Container(
                                        height: screenHeight / 4,
                                        width: screenWidth / 2.5,
                                        child: Center(
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            // shrinkWrap: true,
                                            itemCount: course.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              if (course[index].courseName ==
                                                  "null") {
                                                return Container();
                                              }
                                              if (courses.contains(
                                                  course[index].courseId)) {
                                                return InkWell(
                                                  onTap: (() async {
                                                    // setModuleId(snapshot.data!.docs[index].id);
                                                    await getCourseName();
                                                    if (navigateToCatalogueScreen(
                                                            course[index]
                                                                .courseId) &&
                                                        !(userMap['payInPartsDetails']
                                                                [course[index]
                                                                    .courseId][
                                                            'outStandingAmtPaid'])) {
                                                      if (course[index]
                                                              .multiCombo ==
                                                          true) {
                                                        fromcombo = 'no';
                                                        mainCourseId =
                                                            course[index]
                                                                .courseId;
                                                        GoRouter.of(context)
                                                            .pushNamed(
                                                                'MultiComboCourseScreen',
                                                                queryParams: {
                                                              'courseName':
                                                                  course[index]
                                                                      .courseName
                                                                      .toString(),
                                                              'id':
                                                                  course[index]
                                                                      .courseId,
                                                            });
                                                      } else if (!course[index]
                                                          .isItComboCourse) {
                                                        GoRouter.of(context)
                                                            .pushNamed(
                                                                'videoScreen',
                                                                queryParams: {
                                                              'courseName':
                                                                  course[index]
                                                                      .curriculum
                                                                      .keys
                                                                      .toList()
                                                                      .first
                                                                      .toString(),
                                                              'cID': course[
                                                                      index]
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
                                                        final id =
                                                            index.toString();
                                                        final courseName =
                                                            course[index]
                                                                .courseName;
                                                        context.goNamed(
                                                            'comboStore',
                                                            queryParams: {
                                                              'courseName':
                                                                  courseName,
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
                                                      if (course[index]
                                                              .multiCombo ==
                                                          true) {
                                                        fromcombo = 'no';
                                                        mainCourseId =
                                                            course[index]
                                                                .courseId;
                                                        GoRouter.of(context)
                                                            .pushNamed(
                                                                'MultiComboCourseScreen',
                                                                queryParams: {
                                                              'courseName':
                                                                  course[index]
                                                                      .courseName
                                                                      .toString(),
                                                              'id':
                                                                  course[index]
                                                                      .courseId,
                                                            });
                                                      } else if (!course[index]
                                                          .isItComboCourse) {
                                                        if (course[index]
                                                                .courseContent ==
                                                            'pdf') {
                                                          Navigator.push(
                                                            context,
                                                            PageTransition(
                                                              duration: Duration(
                                                                  milliseconds:
                                                                      400),
                                                              curve: Curves
                                                                  .bounceInOut,
                                                              type: PageTransitionType
                                                                  .rightToLeftWithFade,
                                                              child:
                                                                  PdfCourseScreen(
                                                                curriculum: course[
                                                                            index]
                                                                        .curriculum
                                                                    as Map<
                                                                        String,
                                                                        dynamic>,
                                                              ),
                                                            ),
                                                          );
                                                        } else {
                                                          GoRouter.of(context)
                                                              .pushNamed(
                                                                  'videoScreen',
                                                                  queryParams: {
                                                                'courseName': course[
                                                                        index]
                                                                    .curriculum
                                                                    .keys
                                                                    .toList()
                                                                    .first
                                                                    .toString(),
                                                                'cID': course[
                                                                        index]
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
                                                        await FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                "courses")
                                                            .doc(course[index]
                                                                .courseDocumentId)
                                                            .update({
                                                          'fIndex':
                                                              index.toString(),
                                                        });

                                                        ComboCourse
                                                                .comboId.value =
                                                            course[index]
                                                                .courseId;
                                                        final id =
                                                            index.toString();
                                                        final courseName =
                                                            course[index]
                                                                .courseName;
                                                        mainCourseId =
                                                            course[index]
                                                                .courseId;
                                                        GoRouter.of(context)
                                                            .pushNamed(
                                                                'NewComboCourseScreen',
                                                                queryParams: {
                                                              'courseId':
                                                                  course[index]
                                                                      .courseId,
                                                              'courseName':
                                                                  courseName
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
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 20.0),
                                                    child: Container(
                                                      width: screenWidth / 2.2,
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          color: Colors.white),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 8.0,
                                                                right: 8),
                                                        child: Row(
                                                          children: [
                                                            Container(
                                                              width:
                                                                  screenWidth /
                                                                      6,
                                                              height:
                                                                  screenHeight /
                                                                      5,
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            15),
                                                              ),
                                                              child:
                                                                  CachedNetworkImage(
                                                                placeholder: (context,
                                                                        url) =>
                                                                    Center(
                                                                        child:
                                                                            CircularProgressIndicator()),
                                                                memCacheHeight:
                                                                    80,
                                                                memCacheWidth:
                                                                    80,
                                                                errorWidget: (context,
                                                                        url,
                                                                        error) =>
                                                                    Icon(Icons
                                                                        .error),
                                                                imageUrl: course[
                                                                        index]
                                                                    .courseImageUrl,
                                                                fit:
                                                                    BoxFit.fill,
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left: 8.0,
                                                                      top: 15),
                                                              child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    // course[index]
                                                                    //     .isItComboCourse
                                                                    //     ? Row(
                                                                    //   children: [
                                                                    //     Container(
                                                                    //       width: 70,
                                                                    //       height: 37,
                                                                    //       decoration:
                                                                    //       BoxDecoration(
                                                                    //         borderRadius:
                                                                    //         BorderRadius.circular(
                                                                    //             10),
                                                                    //         // gradient: gradient,
                                                                    //         color: Color(
                                                                    //             0xFF7860DC),
                                                                    //       ),
                                                                    //       child:
                                                                    //       Center(
                                                                    //         child:
                                                                    //         Text(
                                                                    //           'COMBO',
                                                                    //           style:
                                                                    //           const TextStyle(
                                                                    //             fontFamily:
                                                                    //             'Bold',
                                                                    //             fontSize:
                                                                    //             10,
                                                                    //             fontWeight:
                                                                    //             FontWeight.w500,
                                                                    //             color:
                                                                    //             Colors.white,
                                                                    //           ),
                                                                    //         ),
                                                                    //       ),
                                                                    //     )
                                                                    //   ],
                                                                    // )
                                                                    //     : Container(),
                                                                    Container(
                                                                      height:
                                                                          screenHeight /
                                                                              19.7,
                                                                      width:
                                                                          screenWidth /
                                                                              4.3,
                                                                      child:
                                                                          Text(
                                                                        course[index]
                                                                            .courseName,
                                                                        maxLines:
                                                                            2,
                                                                        style: TextStyle(
                                                                            color: HexColor(
                                                                                '2C2C2C'),
                                                                            fontFamily:
                                                                                'Barlow',
                                                                            fontSize: 13.sp,
                                                                            letterSpacing:
                                                                                0 /*percentages not used in flutter. defaulting to zero*/,
                                                                            fontWeight: FontWeight
                                                                                .bold,
                                                                            height:
                                                                                1,
                                                                            overflow:
                                                                                TextOverflow.ellipsis),
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      width:
                                                                          screenWidth /
                                                                              4.3,
                                                                      child:
                                                                          Text(
                                                                        course[index]
                                                                            .courseDescription,
                                                                        maxLines:
                                                                            2,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        style: TextStyle(
                                                                            fontFamily:
                                                                                'Medium',
                                                                            color: HexColor(
                                                                                '585858'),
                                                                            fontSize: 11.sp,
                                                                            fontWeight:
                                                                                FontWeight.w500),
                                                                      ),
                                                                    ),
                                                                    Row(
                                                                      children: [
                                                                        Container(
                                                                          child:
                                                                              Text(
                                                                            course[index].courseLanguage +
                                                                                "  ||",
                                                                            style: TextStyle(
                                                                                fontFamily: 'Medium',
                                                                                color: HexColor('585858'),
                                                                                fontSize: 10 * verticalScale,
                                                                                fontWeight: FontWeight.w500),
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              6,
                                                                        ),
                                                                        Container(
                                                                          child:
                                                                              Center(
                                                                            child:
                                                                                Text(
                                                                              '${course[index].numOfVideos} videos',
                                                                              style: TextStyle(fontFamily: 'Medium', color: HexColor('585858'), fontSize: 10 * verticalScale),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    SizedBox(
                                                                      height: 10 *
                                                                          verticalScale,
                                                                    ),
                                                                    Container(
                                                                      width:
                                                                          screenWidth /
                                                                              4.3,
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Container(
                                                                            width:
                                                                                screenWidth / 6.5,
                                                                            child: ElevatedButton(
                                                                                style: ElevatedButton.styleFrom(
                                                                                    backgroundColor: HexColor('8346E1'),
                                                                                    shape: RoundedRectangleBorder(
                                                                                      borderRadius: BorderRadius.circular(15),
                                                                                    ),
                                                                                    padding: EdgeInsets.all(0)),
                                                                                onPressed: (() async {
                                                                                  // setModuleId(snapshot.data!.docs[index].id);
                                                                                  await getCourseName();
                                                                                  if (navigateToCatalogueScreen(course[index].courseId) && !(userMap['payInPartsDetails'][course[index].courseId]['outStandingAmtPaid'])) {
                                                                                    if (course[index].multiCombo == true) {
                                                                                      fromcombo = 'no';
                                                                                      mainCourseId = course[index].courseId;
                                                                                      GoRouter.of(context).pushNamed('MultiComboCourseScreen', queryParams: {
                                                                                        'courseName': course[index].courseName.toString(),
                                                                                        'id': course[index].courseId,
                                                                                      });
                                                                                    } else if (!course[index].isItComboCourse) {
                                                                                      GoRouter.of(context).pushNamed('videoScreen', queryParams: {
                                                                                        'courseName': course[index].curriculum.keys.toList().first.toString(),
                                                                                        'cID': course[index].courseDocumentId,
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
                                                                                      final courseName = course[index].courseName;
                                                                                      context.goNamed('comboStore', queryParams: {
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
                                                                                    fromcombo = 'no';
                                                                                    mainCourseId = course[index].courseId;
                                                                                    if (course[index].multiCombo == true) {
                                                                                      GoRouter.of(context).pushNamed('MultiComboCourseScreen', queryParams: {
                                                                                        'courseName': course[index].courseName.toString(),
                                                                                        'id': course[index].courseId,
                                                                                      });
                                                                                    } else if (!course[index].isItComboCourse) {
                                                                                      if (course[index].courseContent == 'pdf') {
                                                                                        Navigator.push(
                                                                                          context,
                                                                                          PageTransition(
                                                                                            duration: Duration(milliseconds: 400),
                                                                                            curve: Curves.bounceInOut,
                                                                                            type: PageTransitionType.rightToLeftWithFade,
                                                                                            child: PdfCourseScreen(
                                                                                              curriculum: course[index].curriculum as Map<String, dynamic>,
                                                                                            ),
                                                                                          ),
                                                                                        );
                                                                                      } else {
                                                                                        GoRouter.of(context).pushNamed('videoScreen', queryParams: {
                                                                                          'courseName': course[index].curriculum.keys.toList().first.toString(),
                                                                                          'cID': course[index].courseDocumentId,
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
                                                                                      ComboCourse.comboId.value = course[index].courseId;

                                                                                      final id = index.toString();
                                                                                      final courseName = course[index].courseName;
                                                                                      mainCourseId = course[index].courseId;
                                                                                      GoRouter.of(context).pushNamed('NewComboCourseScreen', queryParams: {
                                                                                        'courseId': course[index].courseId,
                                                                                        'courseName': courseName
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
                                                                                    courseId = course[index].courseDocumentId;
                                                                                  });
                                                                                }),
                                                                                child: Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                                  children: [
                                                                                    Icon(
                                                                                      Icons.play_arrow_rounded,
                                                                                      size: 40 * verticalScale,
                                                                                    ),
                                                                                    FittedBox(
                                                                                        fit: BoxFit.fitWidth,
                                                                                        child: Text(
                                                                                          'Resume Learning',
                                                                                          style: TextStyle(fontSize: 16 * verticalScale),
                                                                                        )),
                                                                                  ],
                                                                                )),
                                                                          ),
                                                                          CircularPercentIndicator(
                                                                            radius:
                                                                                58,
                                                                            circularStrokeCap:
                                                                                CircularStrokeCap.round,
                                                                            percent: coursePercent[course[index].courseId.toString()] != null
                                                                                ? coursePercent[course[index].courseId] / 100
                                                                                : 0 / 100,
                                                                            progressColor:
                                                                                HexColor("31D198"),
                                                                            lineWidth:
                                                                                4,
                                                                            center:
                                                                                Text(
                                                                              "${coursePercent[course[index].courseId.toString()] != null ? coursePercent[course[index].courseId] : 0}%",
                                                                              style: TextStyle(fontSize: 8),
                                                                            ),
                                                                            // footer: FittedBox(
                                                                            // fit: BoxFit.fitWidth,
                                                                            // child: Text('Progress', style: TextStyle(fontSize: 12 * verticalScale),)),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ]),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                return Container();
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    )
                                  : Container()
                              // Container(
                              //     width: screenWidth,
                              //     height: screenHeight / 4.5,
                              //     child: Center(
                              //       child: Container(
                              //         width: screenWidth / 2,
                              //         height: screenHeight / 5.5,
                              //         decoration: BoxDecoration(
                              //           color: Colors.white,
                              //           boxShadow: [
                              //             BoxShadow(
                              //                 color: Colors.black26,
                              //                 offset: Offset(
                              //                   2, // Move to right 10  horizontally
                              //                   2.0, // Move to bottom 10 Vertically
                              //                 ),
                              //                 blurRadius: 40)
                              //           ],
                              //           // border: Border.all(
                              //           //   color: HexColor('440F87'),
                              //           //   width: 1.5,
                              //           // ),
                              //           borderRadius: BorderRadius.circular(15),
                              //         ),
                              //         child: Center(
                              //             child: Text(
                              //           'There are zero courses. Please enroll.',
                              //         )),
                              //       ),
                              //     ),
                              //   )
                              ),

                          // Positioned(
                          //     bottom: verticalScale * 1150,
                          //     left: 50,
                          //     child: Container(
                          //       width: screenWidth * 0.9,
                          //       child: Row(
                          //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //         children: [
                          //           Text(
                          //             'Reviews',
                          //             style: TextStyle(
                          //                 color: HexColor('231F20'),
                          //                 fontWeight: FontWeight.bold,
                          //                 fontSize: 36 * verticalScale),
                          //           ),
                          //           InkWell(
                          //             onTap: () {
                          //               GoRouter.of(context).pushNamed('reviews');
                          //             },
                          //             child: Row(
                          //               children: [
                          //                 Text(
                          //                   'See all',
                          //                   style: TextStyle(
                          //                       color: HexColor('2369F0'),
                          //                       fontWeight: FontWeight.bold,
                          //                       fontSize: 24 * verticalScale),
                          //                 ),
                          //                 Icon(
                          //                   Icons.arrow_forward_rounded,
                          //                   color: HexColor('2369F0'),
                          //                   size: 30 * verticalScale,
                          //                 )
                          //               ],
                          //             ),
                          //           ),
                          //         ],
                          //       ),
                          //     )),
                          // Positioned(
                          //   bottom: verticalScale * 700,
                          //   left: 50,
                          //   child: Row(
                          //     mainAxisSize: MainAxisSize.min,
                          //     children: [
                          //       FutureBuilder<List<FirebaseFile>>(
                          //         future: futureFiles,
                          //         builder: (context, snapshot) {
                          //           try {
                          //             switch (snapshot.connectionState) {
                          //               case ConnectionState.waiting:
                          //                 return Center(
                          //                     child: CircularProgressIndicator());
                          //               default:
                          //                 if (snapshot.hasError) {
                          //                   return Center(
                          //                       child: Text(
                          //                     'Some error occurred!',
                          //                     textScaleFactor:
                          //                         min(horizontalScale, verticalScale),
                          //                   ));
                          //                 } else {
                          //                   final files = snapshot.data!;
                          //                   return Padding(
                          //                     padding: const EdgeInsets.all(8.0),
                          //                     child: Container(
                          //                       height: screenHeight / 2.3,
                          //                       width: screenWidth / 3.5,
                          //                       decoration: BoxDecoration(
                          //                         color: Colors.white,
                          //                         borderRadius:
                          //                             BorderRadius.circular(15),
                          //                       ),
                          //                       child: CarouselSlider.builder(
                          //                           options: CarouselOptions(
                          //                             autoPlay: true,
                          //                             enableInfiniteScroll: true,
                          //                             enlargeCenterPage: false,
                          //                             viewportFraction: 1,
                          //                             aspectRatio: 2.0,
                          //                             initialPage: 0,
                          //                             autoPlayCurve:
                          //                                 Curves.fastOutSlowIn,
                          //                             autoPlayAnimationDuration:
                          //                                 Duration(
                          //                                     milliseconds: 1000),
                          //                           ),
                          //                           itemCount: files.length,
                          //                           itemBuilder:
                          //                               (BuildContext context,
                          //                                   int index, int pageNo) {
                          //                             return ClipRRect(
                          //                                 borderRadius:
                          //                                     BorderRadius.circular(
                          //                                         12),
                          //                                 child: InkWell(
                          //                                   onTap: () {
                          //                                     final file =
                          //                                         files[index];
                          //                                     showDialog(
                          //                                         context: context,
                          //                                         builder: (context) =>
                          //                                             GestureDetector(
                          //                                                 onTap: () =>
                          //                                                     Navigator.pop(
                          //                                                         context),
                          //                                                 child:
                          //                                                     Container(
                          //                                                   alignment:
                          //                                                       Alignment
                          //                                                           .center,
                          //                                                   color: Colors
                          //                                                       .transparent,
                          //                                                   height:
                          //                                                       400,
                          //                                                   width:
                          //                                                       300,
                          //                                                   child:
                          //                                                       AlertDialog(
                          //                                                     shape: RoundedRectangleBorder(
                          //                                                         borderRadius:
                          //                                                             BorderRadius.circular(15.0),
                          //                                                         side: BorderSide.none),
                          //                                                     scrollable:
                          //                                                         true,
                          //                                                     content:
                          //                                                         Container(
                          //                                                       height:
                          //                                                           500,
                          //                                                       width:
                          //                                                           500,
                          //                                                       child:
                          //                                                           ClipRRect(
                          //                                                         borderRadius:
                          //                                                             BorderRadius.circular(20),
                          //                                                         child:
                          //                                                             CachedNetworkImage(
                          //                                                           errorWidget: (context, url, error) => Icon(Icons.error),
                          //                                                           imageUrl: file.url,
                          //                                                           fit: BoxFit.fill,
                          //                                                           placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                          //                                                         ),
                          //                                                       ),
                          //                                                     ),
                          //                                                   ),
                          //                                                 )));
                          //                                   },
                          //                                   child: Image.network(
                          //                                       files[index].url),
                          //                                 ));
                          //                           }),
                          //                     ),
                          //                   );
                          //                 }
                          //             }
                          //           } catch (e) {
                          //             print("jjkkjkjkkkkjkjjjjjjjjkkk${e}");
                          //
                          //             Toast.show(e.toString());
                          //             return Center(
                          //                 child: Text(
                          //               'Some error occurred!',
                          //               textScaleFactor:
                          //                   min(horizontalScale, verticalScale),
                          //             ));
                          //           }
                          //         },
                          //       ),
                          //       FutureBuilder<List<FirebaseFile>>(
                          //         future: futurefilesComboCourseReviews,
                          //         builder: (context, snapshot) {
                          //           try {
                          //             switch (snapshot.connectionState) {
                          //               case ConnectionState.waiting:
                          //                 return Center(
                          //                     child: CircularProgressIndicator());
                          //               default:
                          //                 if (snapshot.hasError) {
                          //                   return Center(
                          //                       child: Text(
                          //                     'Some error occurred!',
                          //                     textScaleFactor:
                          //                         min(horizontalScale, verticalScale),
                          //                   ));
                          //                 } else {
                          //                   final files = snapshot.data!;
                          //                   return Padding(
                          //                     padding: const EdgeInsets.all(8.0),
                          //                     child: Container(
                          //                       height: screenHeight / 2.3,
                          //                       width: screenWidth / 3.5,
                          //                       decoration: BoxDecoration(
                          //                         color: Colors.white,
                          //                         borderRadius:
                          //                             BorderRadius.circular(15),
                          //                       ),
                          //                       child: CarouselSlider.builder(
                          //                           options: CarouselOptions(
                          //                             autoPlay: true,
                          //                             enableInfiniteScroll: true,
                          //                             enlargeCenterPage: false,
                          //                             viewportFraction: 1,
                          //                             aspectRatio: 2.0,
                          //                             initialPage: 4,
                          //                             autoPlayCurve:
                          //                                 Curves.fastOutSlowIn,
                          //                             autoPlayAnimationDuration:
                          //                                 Duration(
                          //                                     milliseconds: 2000),
                          //                           ),
                          //                           itemCount: files.length,
                          //                           itemBuilder:
                          //                               (BuildContext context,
                          //                                   int index, int pageNo) {
                          //                             return ClipRRect(
                          //                                 borderRadius:
                          //                                     BorderRadius.circular(
                          //                                         12),
                          //                                 child: InkWell(
                          //                                   onTap: () {
                          //                                     final file =
                          //                                         files[index];
                          //                                     showDialog(
                          //                                         context: context,
                          //                                         builder: (context) =>
                          //                                             GestureDetector(
                          //                                                 onTap: () =>
                          //                                                     Navigator.pop(
                          //                                                         context),
                          //                                                 child:
                          //                                                     Container(
                          //                                                   alignment:
                          //                                                       Alignment
                          //                                                           .center,
                          //                                                   color: Colors
                          //                                                       .transparent,
                          //                                                   height:
                          //                                                       400,
                          //                                                   width:
                          //                                                       300,
                          //                                                   child:
                          //                                                       AlertDialog(
                          //                                                     shape: RoundedRectangleBorder(
                          //                                                         borderRadius:
                          //                                                             BorderRadius.circular(15.0),
                          //                                                         side: BorderSide.none),
                          //                                                     scrollable:
                          //                                                         true,
                          //                                                     content:
                          //                                                         Container(
                          //                                                       height:
                          //                                                           500,
                          //                                                       width:
                          //                                                           500,
                          //                                                       child:
                          //                                                           ClipRRect(
                          //                                                         borderRadius:
                          //                                                             BorderRadius.circular(20),
                          //                                                         child:
                          //                                                             CachedNetworkImage(
                          //                                                           errorWidget: (context, url, error) => Icon(Icons.error),
                          //                                                           imageUrl: file.url,
                          //                                                           fit: BoxFit.fill,
                          //                                                           placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                          //                                                         ),
                          //                                                       ),
                          //                                                     ),
                          //                                                   ),
                          //                                                 )));
                          //                                   },
                          //                                   child: Image.network(
                          //                                       files[index].url),
                          //                                 ));
                          //                           }),
                          //                     ),
                          //                   );
                          //                 }
                          //             }
                          //           } catch (e) {
                          //             print("jjkkjkjkkkkjkjjjjjjjjkkk${e}");
                          //
                          //             Toast.show(e.toString());
                          //             return Center(
                          //                 child: Text(
                          //               'Some error occurred!',
                          //               textScaleFactor:
                          //                   min(horizontalScale, verticalScale),
                          //             ));
                          //           }
                          //         },
                          //       ),
                          //       FutureBuilder<List<FirebaseFile>>(
                          //         future: futurefilesSocialMediaReviews,
                          //         builder: (context, snapshot) {
                          //           try {
                          //             switch (snapshot.connectionState) {
                          //               case ConnectionState.waiting:
                          //                 return Center(
                          //                     child: CircularProgressIndicator());
                          //               default:
                          //                 if (snapshot.hasError) {
                          //                   return Center(
                          //                       child: Text(
                          //                     'Some error occurred!',
                          //                     textScaleFactor:
                          //                         min(horizontalScale, verticalScale),
                          //                   ));
                          //                 } else {
                          //                   final files = snapshot.data!;
                          //                   return Padding(
                          //                     padding: const EdgeInsets.all(8.0),
                          //                     child: Container(
                          //                       height: screenHeight / 2.3,
                          //                       width: screenWidth / 3.5,
                          //                       decoration: BoxDecoration(
                          //                         color: Colors.white,
                          //                         borderRadius:
                          //                             BorderRadius.circular(15),
                          //                       ),
                          //                       child: CarouselSlider.builder(
                          //                           options: CarouselOptions(
                          //                             autoPlay: true,
                          //                             enableInfiniteScroll: true,
                          //                             enlargeCenterPage: false,
                          //                             viewportFraction: 1,
                          //                             aspectRatio: 2.0,
                          //                             initialPage: 7,
                          //                             autoPlayCurve:
                          //                                 Curves.fastOutSlowIn,
                          //                             autoPlayAnimationDuration:
                          //                                 Duration(
                          //                                     milliseconds: 3000),
                          //                           ),
                          //                           itemCount: files.length,
                          //                           itemBuilder:
                          //                               (BuildContext context,
                          //                                   int index, int pageNo) {
                          //                             return ClipRRect(
                          //                                 borderRadius:
                          //                                     BorderRadius.circular(
                          //                                         12),
                          //                                 child: InkWell(
                          //                                   onTap: () {
                          //                                     final file =
                          //                                         files[index];
                          //                                     showDialog(
                          //                                         context: context,
                          //                                         builder: (context) =>
                          //                                             GestureDetector(
                          //                                                 onTap: () =>
                          //                                                     Navigator.pop(
                          //                                                         context),
                          //                                                 child:
                          //                                                     Container(
                          //                                                   alignment:
                          //                                                       Alignment
                          //                                                           .center,
                          //                                                   color: Colors
                          //                                                       .transparent,
                          //                                                   height:
                          //                                                       400,
                          //                                                   width:
                          //                                                       300,
                          //                                                   child:
                          //                                                       AlertDialog(
                          //                                                     shape: RoundedRectangleBorder(
                          //                                                         borderRadius:
                          //                                                             BorderRadius.circular(15.0),
                          //                                                         side: BorderSide.none),
                          //                                                     scrollable:
                          //                                                         true,
                          //                                                     content:
                          //                                                         Container(
                          //                                                       height:
                          //                                                           500,
                          //                                                       width:
                          //                                                           500,
                          //                                                       child:
                          //                                                           ClipRRect(
                          //                                                         borderRadius:
                          //                                                             BorderRadius.circular(20),
                          //                                                         child:
                          //                                                             CachedNetworkImage(
                          //                                                           errorWidget: (context, url, error) => Icon(Icons.error),
                          //                                                           imageUrl: file.url,
                          //                                                           fit: BoxFit.fill,
                          //                                                           placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                          //                                                         ),
                          //                                                       ),
                          //                                                     ),
                          //                                                   ),
                          //                                                 )));
                          //                                   },
                          //                                   child: Image.network(
                          //                                       files[index].url),
                          //                                 ));
                          //                           }),
                          //                     ),
                          //                   );
                          //                 }
                          //             }
                          //           } catch (e) {
                          //             print("jjkkjkjkkkkjkjjjjjjjjkkk${e}");
                          //
                          //             Toast.show(e.toString());
                          //             return Center(
                          //                 child: Text(
                          //               'Some error occurred!',
                          //               textScaleFactor:
                          //                   min(horizontalScale, verticalScale),
                          //             ));
                          //           }
                          //         },
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          Positioned(
                              bottom: verticalScale * 110,
                              // left: 50,
                              child: Container(
                                width: screenWidth,
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          height: screenHeight / 3.5,
                                          width: screenWidth / 2.4,
                                          padding: EdgeInsets.only(
                                              left: 40 * verticalScale,
                                              top: 50 * verticalScale),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              gradient: LinearGradient(
                                                  colors: [
                                                    HexColor('683AB0'),
                                                    HexColor('230454'),
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight)),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    'Our',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w200,
                                                        fontFamily: 'SemiBold',
                                                        fontSize:
                                                            36 * verticalScale,
                                                        height: 1,
                                                        color: Colors.white),
                                                  ),
                                                  Text(
                                                    ' Special',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w200,
                                                        fontFamily: 'SemiBold',
                                                        fontSize:
                                                            36 * verticalScale,
                                                        height: 1,
                                                        color:
                                                            HexColor('FFDB1B')),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 15 * verticalScale,
                                              ),
                                              Text('Features for you',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w200,
                                                      fontFamily: 'SemiBold',
                                                      fontSize:
                                                          36 * verticalScale,
                                                      height: 1,
                                                      color: Colors.white)),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(left: 40.0),
                                          child: Container(
                                            height: screenHeight / 3.2,
                                            width: screenWidth / 5.5,
                                            padding: EdgeInsets.all(
                                                25 * verticalScale),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              color: Colors.white,
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  height: 75 * verticalScale,
                                                  width: 20 * horizontalScale,
                                                  child: Image.network(
                                                    'https://firebasestorage.googleapis.com/v0/b/cloudyml-app.appspot.com/o/test_developer%2FV1.png?alt=media&token=c3c352fc-ae1e-4960-8f14-77307f4f94d9',
                                                    fit: BoxFit.fill,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 15 * verticalScale,
                                                ),
                                                Text(
                                                  'Hands-On Learning',
                                                  style: TextStyle(
                                                    fontSize:
                                                        18 * verticalScale,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 5 * verticalScale,
                                                ),
                                                Text(
                                                  'Get Complete Hands-on Practical Learning Experience through Assignments & Projects for Proper Confidence Building',
                                                  style: TextStyle(
                                                    fontSize:
                                                        12 * verticalScale,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: 25.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            height: screenHeight / 3.2,
                                            width: screenWidth / 5.5,
                                            padding: EdgeInsets.all(
                                                25 * verticalScale),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              color: Colors.white,
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  height: 75 * verticalScale,
                                                  width: 20 * horizontalScale,
                                                  child: Image.network(
                                                    'https://firebasestorage.googleapis.com/v0/b/cloudyml-app.appspot.com/o/test_developer%2FV2.png?alt=media&token=67c2dedc-c53b-4ee7-af04-4ab36ceea2c7',
                                                    fit: BoxFit.fill,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 15 * verticalScale,
                                                ),
                                                Text(
                                                  'Doubt clearance support',
                                                  style: TextStyle(
                                                    fontSize:
                                                        18 * verticalScale,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 5 * verticalScale,
                                                ),
                                                Text(
                                                  'Get Complete Hands-on Practical Learning Experience through Assignments & Projects for Proper Confidence Building',
                                                  style: TextStyle(
                                                    fontSize:
                                                        12 * verticalScale,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                EdgeInsets.only(left: 50.0),
                                            child: Container(
                                              height: screenHeight / 3.2,
                                              width: screenWidth / 5.5,
                                              padding: EdgeInsets.all(
                                                  25 * verticalScale),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                color: Colors.white,
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    height: 75 * verticalScale,
                                                    width: 20 * horizontalScale,
                                                    child: Image.network(
                                                      'https://firebasestorage.googleapis.com/v0/b/cloudyml-app.appspot.com/o/test_developer%2FV3.png?alt=media&token=66b62e70-8c7b-4410-a883-b97e23cbccff',
                                                      fit: BoxFit.fill,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 15 * verticalScale,
                                                  ),
                                                  Text(
                                                    'Lifetime Access',
                                                    style: TextStyle(
                                                      fontSize:
                                                          18 * verticalScale,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 5 * verticalScale,
                                                  ),
                                                  Text(
                                                    'Get Complete Hands-on Practical Learning Experience through Assignments & Projects for Proper Confidence Building',
                                                    style: TextStyle(
                                                      fontSize:
                                                          12 * verticalScale,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                EdgeInsets.only(left: 50.0),
                                            child: Container(
                                              height: screenHeight / 3.2,
                                              width: screenWidth / 5.5,
                                              padding: EdgeInsets.all(
                                                  25 * verticalScale),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                color: Colors.white,
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    height: 75 * verticalScale,
                                                    width: 20 * horizontalScale,
                                                    child: Image.network(
                                                      'https://firebasestorage.googleapis.com/v0/b/cloudyml-app.appspot.com/o/test_developer%2FV4.png?alt=media&token=236df98e-1d4d-477d-9d55-720210caa64a',
                                                      fit: BoxFit.fill,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 15 * verticalScale,
                                                  ),
                                                  Text(
                                                    'Industrial Internship',
                                                    style: TextStyle(
                                                      fontSize:
                                                          18 * verticalScale,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 5 * verticalScale,
                                                  ),
                                                  Text(
                                                    'Get Complete Hands-on Practical Learning Experience through Assignments & Projects for Proper Confidence Building',
                                                    style: TextStyle(
                                                      fontSize:
                                                          12 * verticalScale,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              )),
                        ],
                      ),
                      Container(
                        height: screenHeight,
                        width: screenWidth,
                        color: HexColor('130329'),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 25.0),
                              child: Text(
                                'Most Popular Courses',
                                style: TextStyle(
                                    fontSize: 42 * verticalScale,
                                    color: Colors.white,
                                    fontFamily: 'SemiBold',
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 75, bottom: 50),
                              height: screenHeight / 1.65,
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: featuredCourse.length,
                                  itemBuilder: (BuildContext context, index) {
                                    if (featuredCourse[index].courseName ==
                                        "null") {
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
                                          if (featuredCourse[index]
                                              .isItComboCourse) {
                                            print(
                                                featuredCourse[index].courses);

                                            final id = index.toString();
                                            final cID = featuredCourse[index]
                                                .courseDocumentId;
                                            final courseName =
                                                featuredCourse[index]
                                                    .courseName;
                                            final courseP =
                                                featuredCourse[index]
                                                    .coursePrice;
                                            // GoRouter.of(context).pushNamed(
                                            //     'featuredCourses',
                                            //     queryParams: {
                                            //       'cID': cID,
                                            //       'courseName': courseName,
                                            //       'id': id,
                                            //       'coursePrice': courseP
                                            //     });

                                            //  final id = index.toString();
                                            //       final cID = featuredCourse[index].courseDocumentId;
                                            //       final courseName = featuredCourse[index].courseName;
                                            //       final courseP = featuredCourse[index].coursePrice;
                                            GoRouter.of(context).pushNamed(
                                                'NewFeature',
                                                queryParams: {
                                                  'cID': cID,
                                                  'courseName': courseName,
                                                  'id': id,
                                                  'coursePrice': featuredCourse[
                                                                      index]
                                                                  .international !=
                                                              null &&
                                                          featuredCourse[index]
                                                                  .international ==
                                                              true
                                                      ? ((double.parse(
                                                                      courseP) /
                                                                  82) +
                                                              5)
                                                          .toString()
                                                      : courseP
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
                                          } else if (featuredCourse[index]
                                                  .multiCombo ==
                                              true) {
                                            GoRouter.of(context)
                                                .pushReplacementNamed(
                                                    'multiComboFeatureScreen',
                                                    queryParams: {
                                                  'cID': featuredCourse[index]
                                                      .courseDocumentId,
                                                  'courseName':
                                                      featuredCourse[index]
                                                          .courseName,
                                                  'id': featuredCourse[index]
                                                      .courseId,
                                                  'coursePrice':
                                                      featuredCourse[index]
                                                          .coursePrice
                                                });
                                          } else {
                                            final id = index.toString();
                                            GoRouter.of(context).pushNamed(
                                                'catalogue',
                                                queryParams: {
                                                  'id': id,
                                                  'cID': courseId,
                                                });
                                          }
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Container(
                                            height: screenHeight / 1.65,
                                            width: screenWidth / 2.9,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              // boxShadow: [
                                              //   BoxShadow(
                                              //     color: Colors.black26,
                                              //     offset: Offset(0, 2),
                                              //     blurRadius: 40,
                                              //   ),
                                              // ],
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              // border: Border.all(
                                              //     width: 0.5,
                                              //     color: HexColor("440F87"),
                                              // ),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  // width: screenWidth / 5,
                                                  // height: screenHeight / 3.5,
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.only(
                                                            topLeft: Radius
                                                                .circular(15),
                                                            topRight:
                                                                Radius.circular(
                                                                    15)),
                                                    child: CachedNetworkImage(
                                                      memCacheHeight: 80,
                                                      memCacheWidth: 80,
                                                      placeholder: (context,
                                                              url) =>
                                                          Center(
                                                              child:
                                                                  CircularProgressIndicator()),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          Icon(Icons.error),
                                                      imageUrl:
                                                          featuredCourse[index]
                                                              .courseImageUrl,
                                                      fit: BoxFit.fill,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  height: 100 * verticalScale,
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 10.0,
                                                          right: 10.0),
                                                  child: Center(
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      right:
                                                                          5.0),
                                                              child: StarRating(
                                                                length: 1,
                                                                rating: featuredCourse[
                                                                            index]
                                                                        .reviews
                                                                        .isNotEmpty
                                                                    ? double.parse(
                                                                        featuredCourse[index]
                                                                            .reviews)
                                                                    : 5.0,
                                                                color: HexColor(
                                                                    '31D198'),
                                                                starSize: 20,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      right:
                                                                          5.0),
                                                              child: Container(
                                                                height: 20,
                                                                width: 25,
                                                                child: Center(
                                                                  child: Text(
                                                                    featuredCourse[index]
                                                                            .reviews
                                                                            .isNotEmpty
                                                                        ? featuredCourse[index]
                                                                            .reviews
                                                                        : '5.0',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        color: HexColor(
                                                                            '585858'),
                                                                        fontWeight:
                                                                            FontWeight.normal),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          height: 5,
                                                        ),
                                                        Text(
                                                          featuredCourse[index]
                                                              .courseName,
                                                          maxLines: 2,
                                                          style: TextStyle(
                                                            color: HexColor(
                                                                '2C2C2C'),
                                                            fontFamily:
                                                                'Medium',
                                                            fontSize: 20 *
                                                                verticalScale,
                                                            height: 1,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 12),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                    children: [
                                                      ElevatedButton(
                                                          onPressed: () {
                                                            setState(() {
                                                              courseId = featuredCourse[
                                                              index]
                                                                  .courseDocumentId;
                                                            });
                                                            print(courseId);
                                                            if (featuredCourse[
                                                            index]
                                                                .isItComboCourse) {
                                                              print(featuredCourse[
                                                              index]
                                                                  .courses);

                                                              final id = index
                                                                  .toString();
                                                              final cID = featuredCourse[
                                                              index]
                                                                  .courseDocumentId;
                                                              final courseName =
                                                                  featuredCourse[
                                                                  index]
                                                                      .courseName;
                                                              final courseP =
                                                                  featuredCourse[
                                                                  index]
                                                                      .coursePrice;
                                                              // GoRouter.of(context).pushNamed(
                                                              //     'featuredCourses',
                                                              //     queryParams: {
                                                              //       'cID': cID,
                                                              //       'courseName': courseName,
                                                              //       'id': id,
                                                              //       'coursePrice': courseP
                                                              //     });

                                                              //  final id = index.toString();
                                                              //       final cID = featuredCourse[index].courseDocumentId;
                                                              //       final courseName = featuredCourse[index].courseName;
                                                              //       final courseP = featuredCourse[index].coursePrice;
                                                              GoRouter.of(
                                                                  context)
                                                                  .pushNamed(
                                                                  'NewFeature',
                                                                  queryParams: {
                                                                    'cID':
                                                                    cID,
                                                                    'courseName':
                                                                    courseName,
                                                                    'id':
                                                                    id,
                                                                    'coursePrice': featuredCourse[index].international != null &&
                                                                        featuredCourse[index].international == true
                                                                        ? ((double.parse(courseP) / 82) + 5).toString()
                                                                        : courseP
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
                                                            } else if (featuredCourse[
                                                            index]
                                                                .multiCombo ==
                                                                true) {
                                                              GoRouter.of(
                                                                  context)
                                                                  .pushReplacementNamed(
                                                                  'multiComboFeatureScreen',
                                                                  queryParams: {
                                                                    'cID': featuredCourse[index]
                                                                        .courseDocumentId,
                                                                    'courseName':
                                                                    featuredCourse[index].courseName,
                                                                    'id': featuredCourse[index]
                                                                        .courseId,
                                                                    'coursePrice':
                                                                    featuredCourse[index].coursePrice
                                                                  });
                                                            } else {
                                                              final id = index
                                                                  .toString();
                                                              GoRouter.of(
                                                                  context)
                                                                  .pushNamed(
                                                                  'catalogue',
                                                                  queryParams: {
                                                                    'id':
                                                                    id,
                                                                    'cID':
                                                                    courseId,
                                                                  });
                                                            }
                                                          },
                                                          style:
                                                          ElevatedButton
                                                              .styleFrom(
                                                            backgroundColor:
                                                            HexColor(
                                                                "8346E1"),
                                                            padding: EdgeInsets
                                                                .only(
                                                                right:
                                                                15,
                                                                left:
                                                                15),
                                                            shape: RoundedRectangleBorder(
                                                                side: BorderSide(
                                                                    color: Colors
                                                                        .black,
                                                                    width:
                                                                    1),
                                                                borderRadius:
                                                                BorderRadius.circular(
                                                                    15)),
                                                          ),
                                                          child: Text(
                                                            "Learn More",
                                                            style: TextStyle(
                                                                fontSize: 18 *
                                                                    verticalScale,
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                          )),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ));
                                    return Container();
                                  }),
                            ),
                            // Container(
                            //   width: 60 * horizontalScale,
                            //   decoration: BoxDecoration(
                            //       borderRadius: BorderRadius.circular(25),
                            //       border: Border.all(color: Colors.white, width: 1)),
                            //   child: TextButton(
                            //       onPressed: () {
                            //         GoRouter.of(context).pushNamed('store');
                            //       },
                            //       child: Text(
                            //         'View All',
                            //         style: TextStyle(
                            //             fontSize: 26 * verticalScale,
                            //             color: Colors.white,
                            //             fontFamily: 'SemiBold',
                            //             fontWeight: FontWeight.bold),
                            //       )),
                            // ),
                            SizedBox(
                              height: 25 * verticalScale,
                            ),
                            // Container(
                            //   // height: 38,
                            //   width: screenWidth,
                            //   color: Colors.deepPurpleAccent[300],
                            //   child: Padding(
                            //     padding: const EdgeInsets.only(
                            //       top: 10.0,
                            //       bottom: 4,
                            //     ),
                            //     child: Row(
                            //       mainAxisAlignment: MainAxisAlignment.center,
                            //       children: [
                            //         InkWell(
                            //           onTap: () {
                            //             launch(
                            //                 'https://apps.apple.com/app/cloudyml-data-science-course/id6444130328');
                            //           },
                            //           child: Container(
                            //             padding: EdgeInsets.all(5),
                            //             decoration: BoxDecoration(
                            //               color: Colors.black,
                            //               borderRadius:
                            //                   BorderRadius.circular(10),
                            //             ),
                            //             child: Row(
                            //               children: [
                            //                 Icon(
                            //                   Icons.apple_outlined,
                            //                   color: Colors.white,
                            //                   size: 40,
                            //                 ),
                            //                 Column(
                            //                   children: [
                            //                     Text(
                            //                       'Download our IOS app from',
                            //                       style: TextStyle(
                            //                           color: Colors.white,
                            //                           fontSize: 15),
                            //                     ),
                            //                     Text('APPLE STORE',
                            //                         style: TextStyle(
                            //                             color: Colors.white,
                            //                             fontSize: 12)),
                            //                   ],
                            //                 ),
                            //               ],
                            //             ),
                            //           ),
                            //         ),
                            //         SizedBox(
                            //           width: 25,
                            //         ),
                            //         InkWell(
                            //           onTap: () {
                            //             launch(
                            //                 'https://play.google.com/store/apps/details?id=com.cloudyml.cloudymlapp');
                            //           },
                            //           child: Container(
                            //             padding: EdgeInsets.all(5),
                            //             decoration: BoxDecoration(
                            //               color: Colors.black,
                            //               borderRadius:
                            //                   BorderRadius.circular(10),
                            //             ),
                            //             child: Row(
                            //               children: [
                            //                 Icon(
                            //                   Icons.play_arrow,
                            //                   color: Colors.white,
                            //                   size: 40,
                            //                 ),
                            //                 Column(
                            //                   children: [
                            //                     Text(
                            //                       'Download our Android app from',
                            //                       style: TextStyle(
                            //                           color: Colors.white,
                            //                           fontSize: 15),
                            //                     ),
                            //                     Text('GOOGLE PLAY',
                            //                         style: TextStyle(
                            //                             color: Colors.white,
                            //                             fontSize: 12)),
                            //                   ],
                            //                 ),
                            //               ],
                            //             ),
                            //           ),
                            //         ),
                            //       ],
                            //     ),
                            //   ),
                            // ),
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
                              width: screenWidth,
                              height: screenHeight,
                              child: Image.network(
                                  'https://firebasestorage.googleapis.com/v0/b/cloudyml-app.appspot.com/o/test_developer%2Fwebbg.png?alt=media&token=04326232-0b38-44f3-9722-3dfc1a89e052',
                                  fit: BoxFit.fill,
                                  height: screenHeight,
                                  width: screenWidth),
                            ),
                            Positioned(
                              bottom: -10,
                              right: 25,
                              left: 25,
                              child: Container(
                                width: 350,
                                height: 500,
                                child: Image.network(
                                  'https://firebasestorage.googleapis.com/v0/b/cloudyml-app.appspot.com/o/test_developer%2Fceopic.png?alt=media&token=27a120b5-b4be-486c-b087-271b4f5e8faa',
                                  fit: BoxFit.fitWidth,
                                ),
                              ),
                            ),
                            Container(
                              height: 78,
                              width: double.infinity,
                              color: HexColor('440F87'),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding:
                                    EdgeInsets.only(top: 15 * verticalScale),
                                child: SizedBox(
                                  width: Adaptive.w(35),
                                  child: Stack(
                                    children: [
                                      Image.asset(
                                        'assets/logo.png',
                                        height: 50,
                                        width: 80,
                                        cacheWidth: 82,
                                        cacheHeight: 56,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 25,
                              top: 5,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: IconButton(
                                    onPressed: () {
                                      print('its opened');
                                      Scaffold.of(context).openDrawer();
                                    },
                                    icon: Icon(
                                      Icons.menu,
                                      color: Colors.white,
                                      size: 50 * verticalScale,
                                    )),
                              ),
                            ),
                            Positioned(
                              top: 125,
                              child: Container(
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Learn ',
                                          style: TextStyle(
                                            color: HexColor('FFFFFF'),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 32 * verticalScale,
                                            fontFamily: 'Barlow',
                                          ),
                                        ),
                                        Text(
                                          'Data Science',
                                          style: TextStyle(
                                            color: HexColor('7B4DFF'),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 32 * verticalScale,
                                            fontFamily: 'Barlow',
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      'By Doing It!',
                                      style: TextStyle(
                                        color: HexColor('FFFFFF'),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 32 * verticalScale,
                                        fontFamily: 'Barlow',
                                      ),
                                    ),
                                    SizedBox(
                                      height: 25 * verticalScale,
                                    ),
                                    Container(
                                      height: 60,
                                      width: screenWidth / 1.5,
                                      child: Text(
                                        'Get Complete Hands-on Practical Learning Experience with CloudyML and become Job-Ready Data Scientist, Data Analyst, Data Engineer, Business Analyst, Research Analyst and ML Engineer.',
                                        maxLines: 3,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 8 * verticalScale,
                                          fontFamily: 'Barlow Semi Condensed',
                                        ),
                                      ),
                                    ),
                                    Container(
                                      height: 50 * verticalScale,
                                      width: screenWidth,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Stack(
                                                  children: [
                                                    Positioned.fill(
                                                        child: Container(
                                                      margin: EdgeInsets.all(6),
                                                      color: Colors.white,
                                                    )),
                                                    Icon(
                                                      Icons.check_circle,
                                                      color: Colors
                                                          .deepPurpleAccent,
                                                      size: 25,
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  width: 5 * verticalScale,
                                                ),
                                                Text(
                                                    'Trusted by $numberOfLearners',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color: Colors.white)),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 5 * horizontalScale,
                                          ),
                                          Expanded(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Stack(
                                                  children: [
                                                    Positioned.fill(
                                                        child: Container(
                                                      margin: EdgeInsets.all(6),
                                                      color: Colors.white,
                                                    )),
                                                    Icon(
                                                      Icons.check_circle,
                                                      color: Colors
                                                          .deepPurpleAccent,
                                                      size: 25,
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  width: 5 * verticalScale,
                                                ),
                                                Text(
                                                  'Learn from industry experts',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color: Colors.white),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 25 * verticalScale,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: screenHeight * 1.9,
                        width: screenWidth,
                        child: Stack(
                          children: [
                            Container(
                              width: screenWidth,
                              height: screenHeight * 1.9,
                              child: Image.network(
                                'https://firebasestorage.googleapis.com/v0/b/cloudyml-app.appspot.com/o/test_developer%2FLanding%20Page.jpg?alt=media&token=c820b5f5-c177-4de8-a5da-e26afc4a8c28',
                                fit: BoxFit.fill,
                              ),
                            ),
                            // Positioned(
                            //   top: -1,
                            //   child: Container(
                            //     width: screenWidth,
                            //     child: Divider(
                            //       color: Colors.purple,
                            //       height: 1,
                            //       thickness: 1,
                            //     ),
                            //   ),
                            // ),
                            Positioned(
                                top: verticalScale * 30,
                                left: 15 * horizontalScale,
                                child: Container(
                                  width: screenWidth * 0.9,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'My Enrolled Courses',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20 * verticalScale),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          GoRouter.of(context)
                                              .pushReplacementNamed(
                                                  'myCourses');
                                        },
                                        child: Row(
                                          children: [
                                            Text(
                                              'See all',
                                              style: TextStyle(
                                                  color: HexColor('2369F0'),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20 * verticalScale),
                                            ),
                                            Icon(
                                              Icons.arrow_forward_rounded,
                                              color: HexColor('2369F0'),
                                              size: 30 * verticalScale,
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                            Positioned(
                              top: 115 * verticalScale,
                              child: Container(
                                height: screenHeight / 3,
                                width: screenWidth,
                                child: courses.length > 0
                                    ? Container(
                                        height: screenHeight / 2.8,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          // shrinkWrap: true,
                                          itemCount: course.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            if (course[index].courseName ==
                                                "null") {
                                              return Container();
                                            }
                                            if (courses.contains(
                                                course[index].courseId)) {
                                              return InkWell(
                                                onTap: (() {
                                                  // setModuleId(snapshot.data!.docs[index].id);
                                                  getCourseName();
                                                  if (navigateToCatalogueScreen(
                                                          course[index]
                                                              .courseId) &&
                                                      !(userMap['payInPartsDetails']
                                                              [course[index]
                                                                  .courseId][
                                                          'outStandingAmtPaid'])) {
                                                    if (course[index]
                                                            .multiCombo ==
                                                        true) {
                                                      fromcombo = 'no';
                                                      mainCourseId =
                                                          course[index]
                                                              .courseId;
                                                      GoRouter.of(context)
                                                          .pushNamed(
                                                              'MultiComboCourseScreen',
                                                              queryParams: {
                                                            'courseName':
                                                                course[index]
                                                                    .courseName
                                                                    .toString(),
                                                            'id': course[index]
                                                                .courseId,
                                                          });
                                                    } else if (!course[index]
                                                        .isItComboCourse) {
                                                      Navigator.push(
                                                        context,
                                                        PageTransition(
                                                          duration: Duration(
                                                              milliseconds:
                                                                  400),
                                                          curve: Curves
                                                              .bounceInOut,
                                                          type: PageTransitionType
                                                              .rightToLeftWithFade,
                                                          child: VideoScreen(
                                                            isDemo: true,
                                                            courseName:
                                                                course[index]
                                                                    .curriculum
                                                                    .keys
                                                                    .toList()
                                                                    .first
                                                                    .toString(),
                                                            sr: 1,
                                                          ),
                                                        ),
                                                      );
                                                    } else {
                                                      Navigator.push(
                                                        context,
                                                        PageTransition(
                                                          duration: Duration(
                                                              milliseconds:
                                                                  100),
                                                          curve: Curves
                                                              .bounceInOut,
                                                          type: PageTransitionType
                                                              .rightToLeftWithFade,
                                                          child: ComboStore(
                                                            courses:
                                                                course[index]
                                                                    .courses,
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  } else {
                                                    if (course[index]
                                                            .multiCombo ==
                                                        true) {
                                                      fromcombo = 'no';
                                                      mainCourseId =
                                                          course[index]
                                                              .courseId;
                                                      GoRouter.of(context)
                                                          .pushNamed(
                                                              'MultiComboCourseScreen',
                                                              queryParams: {
                                                            'courseName':
                                                                course[index]
                                                                    .courseName
                                                                    .toString(),
                                                            'id': course[index]
                                                                .courseId,
                                                          });
                                                    } else if (!course[index]
                                                        .isItComboCourse) {
                                                      if (course[index]
                                                              .courseContent ==
                                                          'pdf') {
                                                        Navigator.push(
                                                          context,
                                                          PageTransition(
                                                            duration: Duration(
                                                                milliseconds:
                                                                    400),
                                                            curve: Curves
                                                                .bounceInOut,
                                                            type: PageTransitionType
                                                                .rightToLeftWithFade,
                                                            child:
                                                                PdfCourseScreen(
                                                              curriculum: course[
                                                                          index]
                                                                      .curriculum
                                                                  as Map<String,
                                                                      dynamic>,
                                                            ),
                                                          ),
                                                        );
                                                      } else {
                                                        Navigator.push(
                                                          context,
                                                          PageTransition(
                                                            duration: Duration(
                                                                milliseconds:
                                                                    400),
                                                            curve: Curves
                                                                .bounceInOut,
                                                            type: PageTransitionType
                                                                .rightToLeftWithFade,
                                                            child: VideoScreen(
                                                              isDemo: true,
                                                              courseName: course[
                                                                      index]
                                                                  .curriculum
                                                                  .keys
                                                                  .toList()
                                                                  .first
                                                                  .toString(),
                                                              sr: 1,
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                    } else {
                                                      // ComboCourse.comboId.value =
                                                      //     course[index].courseId;
                                                      // Navigator.push(
                                                      //   context,
                                                      //   PageTransition(
                                                      //     duration: Duration(
                                                      //         milliseconds: 400),
                                                      //     curve: Curves.bounceInOut,
                                                      //     type: PageTransitionType
                                                      //         .rightToLeftWithFade,
                                                      //     child: ComboCourse(
                                                      //       courses:
                                                      //       course[index].courses,
                                                      //     ),
                                                      //   ),
                                                      // );
                                                      ComboCourse
                                                              .comboId.value =
                                                          course[index]
                                                              .courseId;
                                                      final id =
                                                          index.toString();
                                                      final courseName =
                                                          course[index]
                                                              .courseName;
                                                      mainCourseId =
                                                          course[index]
                                                              .courseId;
                                                      GoRouter.of(context)
                                                          .pushNamed(
                                                              'NewComboCourseScreen',
                                                              queryParams: {
                                                            'courseId':
                                                                course[index]
                                                                    .courseId,
                                                            'courseName':
                                                                courseName
                                                          });
                                                    }
                                                  }
                                                  setState(() {
                                                    courseId = course[index]
                                                        .courseDocumentId;
                                                  });
                                                }),
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 20.0),
                                                  child: Container(
                                                    height: screenHeight / 2.5,
                                                    width: screenWidth / 2,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        color: Colors.white),
                                                    child: Column(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(10.0),
                                                          child: Container(
                                                            // width: screenWidth / 3.3,
                                                            height:
                                                                screenHeight /
                                                                    6.5,
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          15),
                                                              image:
                                                                  DecorationImage(
                                                                      image:
                                                                          CachedNetworkImageProvider(
                                                                        course[index]
                                                                            .courseImageUrl,
                                                                      ),
                                                                      fit: BoxFit
                                                                          .fill),
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 8.0,
                                                                  right: 8),
                                                          child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceEvenly,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                // course[index]
                                                                //     .isItComboCourse
                                                                //     ? Row(
                                                                //   children: [
                                                                //     Container(
                                                                //       width: 70,
                                                                //       height: 37,
                                                                //       decoration:
                                                                //       BoxDecoration(
                                                                //         borderRadius:
                                                                //         BorderRadius.circular(
                                                                //             10),
                                                                //         // gradient: gradient,
                                                                //         color: Color(
                                                                //             0xFF7860DC),
                                                                //       ),
                                                                //       child:
                                                                //       Center(
                                                                //         child:
                                                                //         Text(
                                                                //           'COMBO',
                                                                //           style:
                                                                //           const TextStyle(
                                                                //             fontFamily:
                                                                //             'Bold',
                                                                //             fontSize:
                                                                //             10,
                                                                //             fontWeight:
                                                                //             FontWeight.w500,
                                                                //             color:
                                                                //             Colors.white,
                                                                //           ),
                                                                //         ),
                                                                //       ),
                                                                //     )
                                                                //   ],
                                                                // )
                                                                //     : Container(),
                                                                Container(
                                                                  height:
                                                                      screenHeight /
                                                                          20,
                                                                  child: Text(
                                                                    course[index]
                                                                        .courseName,
                                                                    style: TextStyle(
                                                                        color: HexColor(
                                                                            '2C2C2C'),
                                                                        fontFamily:
                                                                            'Barlow',
                                                                        fontSize: 18 *
                                                                            verticalScale,
                                                                        letterSpacing:
                                                                            0 /*percentages not used in flutter. defaulting to zero*/,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        height:
                                                                            1,
                                                                        overflow:
                                                                            TextOverflow.ellipsis),
                                                                    // overflow: TextOverflow.ellipsis,
                                                                    maxLines: 2,
                                                                  ),
                                                                ),
                                                                course[index]
                                                                            .isItComboCourse &&
                                                                        statusOfPayInParts(
                                                                            course[index].courseId)
                                                                    ? Container(
                                                                        child: !navigateToCatalogueScreen(course[index].courseId)
                                                                            ? Container(
                                                                                height: MediaQuery.of(context).size.width * 0.08 * verticalScale,
                                                                                decoration: BoxDecoration(
                                                                                  borderRadius: BorderRadius.circular(
                                                                                    10,
                                                                                  ),
                                                                                  color: Color(
                                                                                    0xFFC0AAF5,
                                                                                  ),
                                                                                ),
                                                                                child: Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                                                                height: MediaQuery.of(context).size.width * 0.08,
                                                                                decoration: BoxDecoration(
                                                                                  borderRadius: BorderRadius.circular(10),
                                                                                  color: Color(0xFFC0AAF5),
                                                                                ),
                                                                                child: Center(
                                                                                  child: Text(
                                                                                    'Limited access expired !',
                                                                                    textScaleFactor: min(horizontalScale, verticalScale),
                                                                                    style: TextStyle(
                                                                                      color: Colors.deepOrange[600],
                                                                                      fontSize: 13,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                      )
                                                                    : SizedBox(),
                                                                Container(
                                                                  child: Text(
                                                                    course[index]
                                                                        .courseDescription,
                                                                    maxLines: 2,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style: TextStyle(
                                                                        fontFamily:
                                                                            'Medium',
                                                                        color: HexColor(
                                                                            '585858'),
                                                                        fontSize: 8 *
                                                                            verticalScale,
                                                                        fontWeight:
                                                                            FontWeight.w500),
                                                                  ),
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    Container(
                                                                      child:
                                                                          Text(
                                                                        course[index].courseLanguage +
                                                                            "  ||",
                                                                        style: TextStyle(
                                                                            fontFamily:
                                                                                'Medium',
                                                                            color: HexColor(
                                                                                '585858'),
                                                                            fontSize: 10 *
                                                                                verticalScale,
                                                                            fontWeight:
                                                                                FontWeight.w500),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      width: 6,
                                                                    ),
                                                                    Container(
                                                                      child:
                                                                          Center(
                                                                        child:
                                                                            Text(
                                                                          '${course[index].numOfVideos} videos',
                                                                          style: TextStyle(
                                                                              fontFamily: 'Medium',
                                                                              color: HexColor('585858'),
                                                                              fontSize: 10 * verticalScale),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ]),
                                                        ),
                                                        SizedBox(
                                                          height: 10 *
                                                              verticalScale,
                                                        ),
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 8.0,
                                                                  right: 8),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Column(
                                                                children: [
                                                                  Container(
                                                                    width:
                                                                        screenWidth /
                                                                            3.5,
                                                                    child: ElevatedButton(
                                                                        style: ElevatedButton.styleFrom(
                                                                            backgroundColor: HexColor('8346E1'),
                                                                            shape: RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.circular(15),
                                                                            ),
                                                                            padding: EdgeInsets.all(0)),
                                                                        onPressed: (() async {
                                                                          // setModuleId(snapshot.data!.docs[index].id);
                                                                          await getCourseName();

                                                                          if (navigateToCatalogueScreen(course[index].courseId) &&
                                                                              !(userMap['payInPartsDetails'][course[index].courseId]['outStandingAmtPaid'])) {
                                                                            if (course[index].multiCombo ==
                                                                                true) {
                                                                              fromcombo = 'no';
                                                                              mainCourseId = course[index].courseId;
                                                                              GoRouter.of(context).pushNamed('MultiComboCourseScreen', queryParams: {
                                                                                'courseName': course[index].courseName.toString(),
                                                                                'id': course[index].courseId,
                                                                              });
                                                                            } else if (!course[index].isItComboCourse) {
                                                                              GoRouter.of(context).pushNamed('videoScreen', queryParams: {
                                                                                'courseName': course[index].curriculum.keys.toList().first.toString(),
                                                                                'cID': course[index].courseDocumentId,
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
                                                                              final courseName = course[index].courseName;
                                                                              context.goNamed('comboStore', queryParams: {
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
                                                                            if (course[index].multiCombo ==
                                                                                true) {
                                                                              fromcombo = 'no';
                                                                              mainCourseId = course[index].courseId;
                                                                              GoRouter.of(context).pushNamed('MultiComboCourseScreen', queryParams: {
                                                                                'courseName': course[index].courseName.toString(),
                                                                                'id': course[index].courseId,
                                                                              });
                                                                            } else if (!course[index].isItComboCourse) {
                                                                              if (course[index].courseContent == 'pdf') {
                                                                                Navigator.push(
                                                                                  context,
                                                                                  PageTransition(
                                                                                    duration: Duration(milliseconds: 400),
                                                                                    curve: Curves.bounceInOut,
                                                                                    type: PageTransitionType.rightToLeftWithFade,
                                                                                    child: PdfCourseScreen(
                                                                                      curriculum: course[index].curriculum as Map<String, dynamic>,
                                                                                    ),
                                                                                  ),
                                                                                );
                                                                              } else {
                                                                                GoRouter.of(context).pushNamed('videoScreen', queryParams: {
                                                                                  'courseName': course[index].curriculum.keys.toList().first.toString(),
                                                                                  'cID': course[index].courseDocumentId,
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
                                                                              ComboCourse.comboId.value = course[index].courseId;

                                                                              final id = index.toString();
                                                                              final courseName = course[index].courseName;

                                                                              GoRouter.of(context).pushNamed('NewScreen', queryParams: {
                                                                                'id': id,
                                                                                'courseName': courseName
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
                                                                          setState(
                                                                              () {
                                                                            courseId =
                                                                                course[index].courseDocumentId;
                                                                          });
                                                                        }),
                                                                        child: Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          children: [
                                                                            Icon(
                                                                              Icons.play_arrow_rounded,
                                                                              size: 15 * verticalScale,
                                                                            ),
                                                                            FittedBox(
                                                                                fit: BoxFit.fitWidth,
                                                                                child: Text(
                                                                                  'Resume Learning',
                                                                                  style: TextStyle(fontSize: 10 * verticalScale),
                                                                                )),
                                                                          ],
                                                                        )),
                                                                  )
                                                                ],
                                                              ),
                                                              Column(
                                                                children: [
                                                                  CircularPercentIndicator(
                                                                    radius: 35,
                                                                    circularStrokeCap:
                                                                        CircularStrokeCap
                                                                            .round,
                                                                    percent: coursePercent[course[index].courseId.toString()] !=
                                                                            null
                                                                        ? coursePercent[course[index].courseId] /
                                                                            100
                                                                        : 0 /
                                                                            100,
                                                                    progressColor:
                                                                        HexColor(
                                                                            "31D198"),
                                                                    lineWidth:
                                                                        4,
                                                                    center:
                                                                        Text(
                                                                      "${coursePercent[course[index].courseId.toString()] != null ? coursePercent[course[index].courseId] : 0}%",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              8),
                                                                    ),
                                                                    // footer: FittedBox(
                                                                    // fit: BoxFit.fitWidth,
                                                                    // child: Text('Progress', style: TextStyle(fontSize: 12 * verticalScale),)),
                                                                  ),
                                                                ],
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            } else {
                                              return Container();
                                            }
                                          },
                                        ),
                                      )
                                    : Padding(
                                        padding: const EdgeInsets.all(15.0),
                                        child: Container(
                                          width: screenWidth,
                                          height: screenHeight / 3,
                                          padding: EdgeInsets.all(5.0),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(25),
                                          ),
                                          child: Center(
                                              child: Text(
                                            'There are no courses. Please enroll.',
                                            style: TextStyle(
                                              fontSize: 18 * verticalScale,
                                              fontWeight: FontWeight.bold,
                                              height: 1,
                                            ),
                                          )),
                                        ),
                                      ),
                              ),
                            ),
                            // Positioned(
                            //     top: verticalScale * 450,
                            //     left: 15 * horizontalScale,
                            //     child: Container(
                            //       width: screenWidth * 0.9,
                            //       child: Row(
                            //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //         children: [
                            //           Text(
                            //             'Course Reviews',
                            //             style: TextStyle(
                            //                 color: Colors.black,
                            //                 fontWeight: FontWeight.bold,
                            //                 fontSize: 20 * verticalScale),
                            //           ),
                            //           InkWell(
                            //             onTap: () {
                            //               GoRouter.of(context)
                            //                   .pushReplacementNamed('reviews');
                            //             },
                            //             child: Row(
                            //               children: [
                            //                 Text(
                            //                   'See all',
                            //                   style: TextStyle(
                            //                       color: HexColor('2369F0'),
                            //                       fontWeight: FontWeight.bold,
                            //                       fontSize: 20 * verticalScale),
                            //                 ),
                            //                 Icon(
                            //                   Icons.arrow_forward_rounded,
                            //                   color: HexColor('2369F0'),
                            //                   size: 30 * verticalScale,
                            //                 )
                            //               ],
                            //             ),
                            //           ),
                            //         ],
                            //       ),
                            //     )),
                            // Positioned(
                            //   top: verticalScale * 525,
                            //   left: 30 * verticalScale,
                            //   child: Column(
                            //     children: [
                            //       Row(
                            //         mainAxisAlignment: MainAxisAlignment.center,
                            //         children: [
                            //           FutureBuilder<List<FirebaseFile>>(
                            //             future: futureFiles,
                            //             builder: (context, snapshot) {
                            //               try {
                            //                 switch (snapshot.connectionState) {
                            //                   case ConnectionState.waiting:
                            //                     return Center(
                            //                         child:
                            //                             CircularProgressIndicator());
                            //                   default:
                            //                     if (snapshot.hasError) {
                            //                       return Center(
                            //                           child: Text(
                            //                         'Some error occurred!',
                            //                         textScaleFactor: min(
                            //                             horizontalScale,
                            //                             verticalScale),
                            //                       ));
                            //                     } else {
                            //                       final files = snapshot.data!;
                            //                       return Padding(
                            //                         padding:
                            //                             const EdgeInsets.all(5.0),
                            //                         child: Container(
                            //                           height: screenHeight / 5,
                            //                           width: screenWidth / 2.5,
                            //                           decoration: BoxDecoration(
                            //                             color: Colors.white,
                            //                             borderRadius:
                            //                                 BorderRadius.circular(15),
                            //                           ),
                            //                           child: CarouselSlider.builder(
                            //                               options: CarouselOptions(
                            //                                 autoPlay: true,
                            //                                 enableInfiniteScroll:
                            //                                     true,
                            //                                 enlargeCenterPage: false,
                            //                                 viewportFraction: 1,
                            //                                 aspectRatio: 2.0,
                            //                                 initialPage: 0,
                            //                                 autoPlayCurve:
                            //                                     Curves.fastOutSlowIn,
                            //                                 autoPlayAnimationDuration:
                            //                                     Duration(
                            //                                         milliseconds:
                            //                                             1000),
                            //                               ),
                            //                               itemCount: files.length,
                            //                               itemBuilder:
                            //                                   (BuildContext context,
                            //                                       int index,
                            //                                       int pageNo) {
                            //                                 return ClipRRect(
                            //                                     borderRadius:
                            //                                         BorderRadius
                            //                                             .circular(12),
                            //                                     child: InkWell(
                            //                                       onTap: () {
                            //                                         final file =
                            //                                             files[index];
                            //                                         showDialog(
                            //                                             context:
                            //                                                 context,
                            //                                             builder: (context) =>
                            //                                                 GestureDetector(
                            //                                                     onTap: () => Navigator.pop(
                            //                                                         context),
                            //                                                     child:
                            //                                                         Container(
                            //                                                       alignment:
                            //                                                           Alignment.center,
                            //                                                       color:
                            //                                                           Colors.transparent,
                            //                                                       height:
                            //                                                           400,
                            //                                                       width:
                            //                                                           300,
                            //                                                       child:
                            //                                                           AlertDialog(
                            //                                                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0), side: BorderSide.none),
                            //                                                         scrollable: true,
                            //                                                         content: Container(
                            //                                                           height: 240,
                            //                                                           width: 320,
                            //                                                           child: ClipRRect(
                            //                                                             borderRadius: BorderRadius.circular(20),
                            //                                                             child: CachedNetworkImage(
                            //                                                               errorWidget: (context, url, error) => Icon(Icons.error),
                            //                                                               imageUrl: file.url,
                            //                                                               fit: BoxFit.fill,
                            //                                                               placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                            //                                                             ),
                            //                                                           ),
                            //                                                         ),
                            //                                                       ),
                            //                                                     )));
                            //                                       },
                            //                                       child:
                            //                                           Image.network(
                            //                                               files[index]
                            //                                                   .url),
                            //                                     ));
                            //                               }),
                            //                         ),
                            //                       );
                            //                     }
                            //                 }
                            //               } catch (e) {
                            //                 print("jjkkjkjkkkkjkjjjjjjjjkkk${e}");
                            //
                            //                 Toast.show(e.toString());
                            //                 return Center(
                            //                     child: Text(
                            //                   'Some error occurred!',
                            //                   textScaleFactor:
                            //                       min(horizontalScale, verticalScale),
                            //                 ));
                            //               }
                            //             },
                            //           ),
                            //           FutureBuilder<List<FirebaseFile>>(
                            //             future: futurefilesComboCourseReviews,
                            //             builder: (context, snapshot) {
                            //               try {
                            //                 switch (snapshot.connectionState) {
                            //                   case ConnectionState.waiting:
                            //                     return Center(
                            //                         child:
                            //                             CircularProgressIndicator());
                            //                   default:
                            //                     if (snapshot.hasError) {
                            //                       return Center(
                            //                           child: Text(
                            //                         'Some error occurred!',
                            //                         textScaleFactor: min(
                            //                             horizontalScale,
                            //                             verticalScale),
                            //                       ));
                            //                     } else {
                            //                       final files = snapshot.data!;
                            //                       return Padding(
                            //                         padding:
                            //                             const EdgeInsets.all(5.0),
                            //                         child: Container(
                            //                           height: screenHeight / 5,
                            //                           width: screenWidth / 2.5,
                            //                           decoration: BoxDecoration(
                            //                             color: Colors.white,
                            //                             borderRadius:
                            //                                 BorderRadius.circular(15),
                            //                           ),
                            //                           child: CarouselSlider.builder(
                            //                               options: CarouselOptions(
                            //                                 autoPlay: true,
                            //                                 enableInfiniteScroll:
                            //                                     true,
                            //                                 enlargeCenterPage: false,
                            //                                 viewportFraction: 1,
                            //                                 aspectRatio: 2.0,
                            //                                 initialPage: 4,
                            //                                 autoPlayCurve:
                            //                                     Curves.fastOutSlowIn,
                            //                                 autoPlayAnimationDuration:
                            //                                     Duration(
                            //                                         milliseconds:
                            //                                             2000),
                            //                               ),
                            //                               itemCount: files.length,
                            //                               itemBuilder:
                            //                                   (BuildContext context,
                            //                                       int index,
                            //                                       int pageNo) {
                            //                                 return ClipRRect(
                            //                                     borderRadius:
                            //                                         BorderRadius
                            //                                             .circular(12),
                            //                                     child: InkWell(
                            //                                       onTap: () {
                            //                                         final file =
                            //                                             files[index];
                            //                                         showDialog(
                            //                                             context:
                            //                                                 context,
                            //                                             builder: (context) =>
                            //                                                 GestureDetector(
                            //                                                     onTap: () => Navigator.pop(
                            //                                                         context),
                            //                                                     child:
                            //                                                         Container(
                            //                                                       alignment:
                            //                                                           Alignment.center,
                            //                                                       color:
                            //                                                           Colors.transparent,
                            //                                                       height:
                            //                                                           400,
                            //                                                       width:
                            //                                                           300,
                            //                                                       child:
                            //                                                           AlertDialog(
                            //                                                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0), side: BorderSide.none),
                            //                                                         scrollable: true,
                            //                                                         content: Container(
                            //                                                           height: 240,
                            //                                                           width: 320,
                            //                                                           child: ClipRRect(
                            //                                                             borderRadius: BorderRadius.circular(20),
                            //                                                             child: CachedNetworkImage(
                            //                                                               errorWidget: (context, url, error) => Icon(Icons.error),
                            //                                                               imageUrl: file.url,
                            //                                                               fit: BoxFit.fill,
                            //                                                               placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                            //                                                             ),
                            //                                                           ),
                            //                                                         ),
                            //                                                       ),
                            //                                                     )));
                            //                                       },
                            //                                       child:
                            //                                           Image.network(
                            //                                               files[index]
                            //                                                   .url),
                            //                                     ));
                            //                               }),
                            //                         ),
                            //                       );
                            //                     }
                            //                 }
                            //               } catch (e) {
                            //                 print("jjkkjkjkkkkjkjjjjjjjjkkk${e}");
                            //
                            //                 Toast.show(e.toString());
                            //                 return Center(
                            //                     child: Text(
                            //                   'Some error occurred!',
                            //                   textScaleFactor:
                            //                       min(horizontalScale, verticalScale),
                            //                 ));
                            //               }
                            //             },
                            //           ),
                            //         ],
                            //       ),
                            //       FutureBuilder<List<FirebaseFile>>(
                            //         future: futurefilesSocialMediaReviews,
                            //         builder: (context, snapshot) {
                            //           try {
                            //             switch (snapshot.connectionState) {
                            //               case ConnectionState.waiting:
                            //                 return Center(
                            //                     child: CircularProgressIndicator());
                            //               default:
                            //                 if (snapshot.hasError) {
                            //                   return Center(
                            //                       child: Text(
                            //                     'Some error occurred!',
                            //                     textScaleFactor: min(
                            //                         horizontalScale, verticalScale),
                            //                   ));
                            //                 } else {
                            //                   final files = snapshot.data!;
                            //                   return Padding(
                            //                     padding: const EdgeInsets.all(5.0),
                            //                     child: Container(
                            //                       height: screenHeight / 5,
                            //                       width: screenWidth / 2.5,
                            //                       decoration: BoxDecoration(
                            //                         color: Colors.white,
                            //                         borderRadius:
                            //                             BorderRadius.circular(15),
                            //                       ),
                            //                       child: CarouselSlider.builder(
                            //                           options: CarouselOptions(
                            //                             autoPlay: true,
                            //                             enableInfiniteScroll: true,
                            //                             enlargeCenterPage: false,
                            //                             viewportFraction: 1,
                            //                             aspectRatio: 2.0,
                            //                             initialPage: 7,
                            //                             autoPlayCurve:
                            //                                 Curves.fastOutSlowIn,
                            //                             autoPlayAnimationDuration:
                            //                                 Duration(
                            //                                     milliseconds: 3000),
                            //                           ),
                            //                           itemCount: files.length,
                            //                           itemBuilder:
                            //                               (BuildContext context,
                            //                                   int index, int pageNo) {
                            //                             return ClipRRect(
                            //                                 borderRadius:
                            //                                     BorderRadius.circular(
                            //                                         12),
                            //                                 child: InkWell(
                            //                                   onTap: () {
                            //                                     final file =
                            //                                         files[index];
                            //                                     showDialog(
                            //                                         context: context,
                            //                                         builder: (context) =>
                            //                                             GestureDetector(
                            //                                                 onTap: () =>
                            //                                                     Navigator.pop(
                            //                                                         context),
                            //                                                 child:
                            //                                                     Container(
                            //                                                   alignment:
                            //                                                       Alignment.center,
                            //                                                   color: Colors
                            //                                                       .transparent,
                            //                                                   height:
                            //                                                       400,
                            //                                                   width:
                            //                                                       300,
                            //                                                   child:
                            //                                                       AlertDialog(
                            //                                                     shape: RoundedRectangleBorder(
                            //                                                         borderRadius: BorderRadius.circular(15.0),
                            //                                                         side: BorderSide.none),
                            //                                                     scrollable:
                            //                                                         true,
                            //                                                     content:
                            //                                                         Container(
                            //                                                       height:
                            //                                                           240,
                            //                                                       width:
                            //                                                           320,
                            //                                                       child:
                            //                                                           ClipRRect(
                            //                                                         borderRadius: BorderRadius.circular(20),
                            //                                                         child: CachedNetworkImage(
                            //                                                           errorWidget: (context, url, error) => Icon(Icons.error),
                            //                                                           imageUrl: file.url,
                            //                                                           fit: BoxFit.fill,
                            //                                                           placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                            //                                                         ),
                            //                                                       ),
                            //                                                     ),
                            //                                                   ),
                            //                                                 )));
                            //                                   },
                            //                                   child: Image.network(
                            //                                       files[index].url),
                            //                                 ));
                            //                           }),
                            //                     ),
                            //                   );
                            //                 }
                            //             }
                            //           } catch (e) {
                            //             print("jjkkjkjkkkkjkjjjjjjjjkkk${e}");
                            //
                            //             Toast.show(e.toString());
                            //             return Center(
                            //                 child: Text(
                            //               'Some error occurred!',
                            //               textScaleFactor:
                            //                   min(horizontalScale, verticalScale),
                            //             ));
                            //           }
                            //         },
                            //       ),
                            //     ],
                            //   ),
                            // ),
                            Positioned(
                                bottom: verticalScale * 900,
                                // left: 50,
                                child: Container(
                                  width: screenWidth,
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            height: screenHeight / 6,
                                            width: screenWidth / 1.75,
                                            padding: EdgeInsets.only(
                                                left: 15 * verticalScale,
                                                top: 35 * verticalScale),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                gradient: LinearGradient(
                                                    colors: [
                                                      HexColor('683AB0'),
                                                      HexColor('230454'),
                                                    ],
                                                    begin: Alignment.topLeft,
                                                    end:
                                                        Alignment.bottomRight)),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      'Our',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w200,
                                                          fontFamily:
                                                              'SemiBold',
                                                          fontSize: 18 *
                                                              verticalScale,
                                                          height: 1,
                                                          color: Colors.white),
                                                    ),
                                                    Text(
                                                      ' Special',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w200,
                                                          fontFamily:
                                                              'SemiBold',
                                                          fontSize: 18 *
                                                              verticalScale,
                                                          height: 1,
                                                          color: HexColor(
                                                              'FFDB1B')),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 10 * verticalScale,
                                                ),
                                                Text('Features for you',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w200,
                                                        fontFamily: 'SemiBold',
                                                        fontSize:
                                                            18 * verticalScale,
                                                        height: 1,
                                                        color: Colors.white)),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                EdgeInsets.only(left: 10.0),
                                            child: Container(
                                              height: screenHeight / 6,
                                              width: screenWidth / 3.5,
                                              padding: EdgeInsets.all(
                                                  10 * verticalScale),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                color: Colors.white,
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    height: 30 * verticalScale,
                                                    width: 25 * horizontalScale,
                                                    child: Image.network(
                                                      'https://firebasestorage.googleapis.com/v0/b/cloudyml-app.appspot.com/o/test_developer%2FV1.png?alt=media&token=c3c352fc-ae1e-4960-8f14-77307f4f94d9',
                                                      fit: BoxFit.fill,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 10 * verticalScale,
                                                  ),
                                                  Text(
                                                    'Hands-On Learning',
                                                    style: TextStyle(
                                                      fontSize:
                                                          10 * verticalScale,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 5 * verticalScale,
                                                  ),
                                                  Text(
                                                    'Get Complete Hands-on Practical Learning Experience through Assignments & Projects for Proper Confidence Building',
                                                    style: TextStyle(
                                                      fontSize:
                                                          6 * verticalScale,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(top: 25.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              height: screenHeight / 6,
                                              width: screenWidth / 3.5,
                                              padding: EdgeInsets.all(
                                                  10 * verticalScale),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                color: Colors.white,
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    height: 30 * verticalScale,
                                                    width: 25 * horizontalScale,
                                                    child: Image.network(
                                                      'https://firebasestorage.googleapis.com/v0/b/cloudyml-app.appspot.com/o/test_developer%2FV2.png?alt=media&token=67c2dedc-c53b-4ee7-af04-4ab36ceea2c7',
                                                      fit: BoxFit.fill,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 10 * verticalScale,
                                                  ),
                                                  Text(
                                                    'Doubt clearance support',
                                                    style: TextStyle(
                                                      fontSize:
                                                          10 * verticalScale,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 5 * verticalScale,
                                                  ),
                                                  Text(
                                                    'Get Complete Hands-on Practical Learning Experience through Assignments & Projects for Proper Confidence Building',
                                                    style: TextStyle(
                                                      fontSize:
                                                          6 * verticalScale,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(left: 10.0),
                                              child: Container(
                                                height: screenHeight / 6,
                                                width: screenWidth / 3.5,
                                                padding: EdgeInsets.all(
                                                    10 * verticalScale),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  color: Colors.white,
                                                ),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      height:
                                                          30 * verticalScale,
                                                      width:
                                                          25 * horizontalScale,
                                                      child: Image.network(
                                                        'https://firebasestorage.googleapis.com/v0/b/cloudyml-app.appspot.com/o/test_developer%2FV3.png?alt=media&token=66b62e70-8c7b-4410-a883-b97e23cbccff',
                                                        fit: BoxFit.fill,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height:
                                                          10 * verticalScale,
                                                    ),
                                                    Text(
                                                      'Lifetime Access',
                                                      style: TextStyle(
                                                        fontSize:
                                                            10 * verticalScale,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 5 * verticalScale,
                                                    ),
                                                    Text(
                                                      'Get Complete Hands-on Practical Learning Experience through Assignments & Projects for Proper Confidence Building',
                                                      style: TextStyle(
                                                        fontSize:
                                                            6 * verticalScale,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(left: 10.0),
                                              child: Container(
                                                height: screenHeight / 6,
                                                width: screenWidth / 3.5,
                                                padding: EdgeInsets.all(
                                                    10 * verticalScale),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  color: Colors.white,
                                                ),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      height:
                                                          30 * verticalScale,
                                                      width:
                                                          25 * horizontalScale,
                                                      child: Image.network(
                                                        'https://firebasestorage.googleapis.com/v0/b/cloudyml-app.appspot.com/o/test_developer%2FV4.png?alt=media&token=236df98e-1d4d-477d-9d55-720210caa64a',
                                                        fit: BoxFit.fill,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height:
                                                          10 * verticalScale,
                                                    ),
                                                    Text(
                                                      'Industrial Internship',
                                                      style: TextStyle(
                                                        fontSize:
                                                            10 * verticalScale,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 5 * verticalScale,
                                                    ),
                                                    Text(
                                                      'Get Complete Hands-on Practical Learning Experience through Assignments & Projects for Proper Confidence Building',
                                                      style: TextStyle(
                                                        fontSize:
                                                            6 * verticalScale,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                )),
                            Positioned(
                              bottom: 250 * verticalScale,
                              child: Container(
                                height: screenHeight / 1.5,
                                width: screenWidth,
                                color: HexColor('130329'),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 25.0),
                                      child: Text(
                                        'Most Popular Courses',
                                        style: TextStyle(
                                            fontSize: 24 * verticalScale,
                                            color: Colors.white,
                                            fontFamily: 'SemiBold',
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 25 * verticalScale,
                                    ),
                                    Container(
                                      height: screenHeight / 2.2,
                                      child: ListView.builder(
                                          shrinkWrap: true,
                                          scrollDirection: Axis.horizontal,
                                          itemCount: featuredCourse.length,
                                          itemBuilder:
                                              (BuildContext context, index) {
                                            if (featuredCourse[index]
                                                    .courseName ==
                                                "null") {
                                              return Container();
                                            }
                                            // if (course[index].isItComboCourse == true)
                                            return InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    courseId =
                                                        featuredCourse[index]
                                                            .courseDocumentId;
                                                  });
                                                  print(courseId);
                                                  if (featuredCourse[index]
                                                      .isItComboCourse) {
                                                    print(featuredCourse[index]
                                                        .courses);

                                                    final id = index.toString();
                                                    final cID =
                                                        featuredCourse[index]
                                                            .courseDocumentId;
                                                    final courseName =
                                                        featuredCourse[index]
                                                            .courseName;
                                                    final courseP =
                                                        featuredCourse[index]
                                                            .coursePrice;
                                                    GoRouter.of(context)
                                                        .pushNamed('NewFeature',
                                                            queryParams: {
                                                          'cID': cID,
                                                          'courseName':
                                                              courseName,
                                                          'id': id,
                                                          'coursePrice': featuredCourse[
                                                                              index]
                                                                          .international !=
                                                                      null &&
                                                                  featuredCourse[
                                                                              index]
                                                                          .international ==
                                                                      true
                                                              ? ((double.parse(
                                                                              courseP) /
                                                                          82) +
                                                                      5)
                                                                  .toString()
                                                              : courseP
                                                        });

                                                    // GoRouter.of(context).pushNamed(
                                                    //     'NewComboCourse',
                                                    //     queryParams: {
                                                    //       'courseName': courseName,
                                                    //       'id': id,
                                                    //     });

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
                                                  } else if (featuredCourse[
                                                              index]
                                                          .multiCombo ==
                                                      true) {
                                                    GoRouter.of(context)
                                                        .pushReplacementNamed(
                                                            'multiComboFeatureScreen',
                                                            queryParams: {
                                                          'cID': featuredCourse[
                                                                  index]
                                                              .courseDocumentId,
                                                          'courseName':
                                                              featuredCourse[
                                                                      index]
                                                                  .courseName,
                                                          'id': featuredCourse[
                                                                  index]
                                                              .courseId,
                                                          'coursePrice':
                                                              featuredCourse[
                                                                      index]
                                                                  .coursePrice
                                                        });
                                                  } else {
                                                    final id = index.toString();
                                                    GoRouter.of(context)
                                                        .pushNamed('catalogue',
                                                            queryParams: {
                                                          'id': id,
                                                          'cID': courseId,
                                                        });
                                                  }
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      10.0),
                                                  child: Container(
                                                    height: screenHeight / 3.5,
                                                    width: screenWidth / 1.75,
                                                    decoration: BoxDecoration(
                                                      // boxShadow: [
                                                      //   BoxShadow(
                                                      //     color: Colors.black26,
                                                      //     offset: Offset(0, 2),
                                                      //     blurRadius: 40,
                                                      //   ),
                                                      // ],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),

                                                      // border: Border.all(
                                                      //     width: 0.5,
                                                      //     color: HexColor("440F87"),
                                                      // ),
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Container(
                                                          // width: screenWidth / 5,
                                                          height: screenHeight /
                                                              4.5,
                                                          child: ClipRRect(
                                                            borderRadius: BorderRadius.only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        20),
                                                                topRight: Radius
                                                                    .circular(
                                                                        15)),
                                                            child:
                                                                CachedNetworkImage(
                                                              memCacheHeight:
                                                                  80,
                                                              memCacheWidth: 80,
                                                              placeholder: (context,
                                                                      url) =>
                                                                  Center(
                                                                      child:
                                                                          CircularProgressIndicator()),
                                                              errorWidget: (context,
                                                                      url,
                                                                      error) =>
                                                                  Icon(Icons
                                                                      .error),
                                                              imageUrl:
                                                                  featuredCourse[
                                                                          index]
                                                                      .courseImageUrl,
                                                              fit: BoxFit.fill,
                                                            ),
                                                          ),
                                                        ),
                                                        Container(
                                                          height: 100 *
                                                              verticalScale,
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 10.0,
                                                                  right: 10.0),
                                                          child: Center(
                                                            child: Column(
                                                              children: [
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
                                                                          StarRating(
                                                                        length:
                                                                            1,
                                                                        rating: featuredCourse[index].reviews.isNotEmpty
                                                                            ? double.parse(featuredCourse[index].reviews)
                                                                            : 5.0,
                                                                        color: HexColor(
                                                                            '31D198'),
                                                                        starSize:
                                                                            20,
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.start,
                                                                      ),
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .only(
                                                                          right:
                                                                              5.0),
                                                                      child:
                                                                          Container(
                                                                        height:
                                                                            20,
                                                                        width:
                                                                            25,
                                                                        child:
                                                                            Center(
                                                                          child:
                                                                              Text(
                                                                            featuredCourse[index].reviews.isNotEmpty
                                                                                ? featuredCourse[index].reviews
                                                                                : '5.0',
                                                                            style: TextStyle(
                                                                                fontSize: 12,
                                                                                color: Colors.white,
                                                                                fontWeight: FontWeight.normal),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                SizedBox(
                                                                  height: 5,
                                                                ),
                                                                Text(
                                                                  featuredCourse[
                                                                          index]
                                                                      .courseName,
                                                                  maxLines: 4,
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors.white,
                                                                    // HexColor(
                                                                    //     '2C2C2C'),
                                                                    fontFamily:
                                                                        'Medium',
                                                                    fontSize: 15 *
                                                                        verticalScale,
                                                                    height: 1,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    left: 8.0),
                                                            child: Container(
                                                              height: 45 *
                                                                  verticalScale,
                                                              width:
                                                                  screenWidth /
                                                                      2.8,
                                                              child:
                                                                  ElevatedButton(
                                                                      onPressed:
                                                                          () {
                                                                        setState(
                                                                            () {
                                                                          courseId =
                                                                              featuredCourse[index].courseDocumentId;
                                                                        });
                                                                        print(
                                                                            courseId);
                                                                        if (featuredCourse[index]
                                                                            .isItComboCourse) {
                                                                          print(
                                                                              featuredCourse[index].courses);

                                                                          final id =
                                                                              index.toString();
                                                                          final cID =
                                                                              featuredCourse[index].courseDocumentId;
                                                                          final courseName =
                                                                              featuredCourse[index].courseName;
                                                                          final courseP =
                                                                              featuredCourse[index].coursePrice;
                                                                          // GoRouter.of(context).pushNamed(
                                                                          //     'featuredCourses',
                                                                          //     queryParams: {
                                                                          //       'cID': cID,
                                                                          //       'courseName': courseName,
                                                                          //       'id': id,
                                                                          //       'coursePrice': courseP
                                                                          //     });

                                                                          //  final id = index.toString();
                                                                          //       final cID = featuredCourse[index].courseDocumentId;
                                                                          //       final courseName = featuredCourse[index].courseName;
                                                                          //       final courseP = featuredCourse[index].coursePrice;
                                                                          GoRouter.of(context).pushNamed(
                                                                              'NewFeature',
                                                                              queryParams: {
                                                                                'cID': cID,
                                                                                'courseName': courseName,
                                                                                'id': id,
                                                                                'coursePrice': featuredCourse[index].international != null && featuredCourse[index].international == true ? ((double.parse(courseP) / 82) + 5).toString() : courseP
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
                                                                        } else if (featuredCourse[index].multiCombo ==
                                                                            true) {
                                                                          GoRouter.of(context).pushReplacementNamed(
                                                                              'multiComboFeatureScreen',
                                                                              queryParams: {
                                                                                'cID': featuredCourse[index].courseDocumentId,
                                                                                'courseName': featuredCourse[index].courseName,
                                                                                'id': featuredCourse[index].courseId,
                                                                                'coursePrice': featuredCourse[index].coursePrice
                                                                              });
                                                                        } else {
                                                                          final id =
                                                                              index.toString();
                                                                          GoRouter.of(context).pushNamed(
                                                                              'catalogue',
                                                                              queryParams: {
                                                                                'id': id,
                                                                                'cID': courseId,
                                                                              });
                                                                        }
                                                                      },
                                                                      style: ElevatedButton
                                                                          .styleFrom(
                                                                        backgroundColor:
                                                                            HexColor("8346E1"),
                                                                        padding: EdgeInsets.only(
                                                                            right:
                                                                                15,
                                                                            left:
                                                                                15),
                                                                        shape: RoundedRectangleBorder(
                                                                            side:
                                                                                BorderSide(color: Colors.black, width: 1),
                                                                            borderRadius: BorderRadius.circular(25)),
                                                                      ),
                                                                      child:
                                                                          Text(
                                                                        "Learn More",
                                                                        style: TextStyle(
                                                                            fontSize: 18 *
                                                                                verticalScale,
                                                                            color:
                                                                                Colors.white,
                                                                            fontWeight: FontWeight.bold),
                                                                      )),
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
                                    // Container(
                                    //   width: 60 * horizontalScale,
                                    //   decoration: BoxDecoration(
                                    //       borderRadius: BorderRadius.circular(25),
                                    //       border: Border.all(color: Colors.white, width: 1)),
                                    //   child: TextButton(
                                    //       onPressed: () {
                                    //         viewAll = !viewAll;
                                    //       },
                                    //       child: Text(
                                    //         viewAll ? 'View less' : 'View All',
                                    //         style: TextStyle(
                                    //             fontSize: 18 * verticalScale,
                                    //             color: Colors.white,
                                    //             fontFamily: 'SemiBold',
                                    //             fontWeight: FontWeight.bold),
                                    //       )),
                                    // ),
                                    SizedBox(
                                      height: 25 * verticalScale,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Positioned(
                            //   bottom: 70,
                            //   left: 15,
                            //   right: 15,
                            //   child: Container(
                            //     height: 75 * verticalScale,
                            //     width: screenWidth,
                            //     color: Colors.deepPurpleAccent[300],
                            //     child: Padding(
                            //       padding: const EdgeInsets.only(
                            //         top: 15.0,
                            //         bottom: 4,
                            //       ),
                            //       child: Row(
                            //         mainAxisAlignment: MainAxisAlignment.center,
                            //         children: [
                            //           InkWell(
                            //             onTap: () {
                            //               launch(
                            //                   'https://apps.apple.com/app/cloudyml-data-science-course/id6444130328');
                            //             },
                            //             child: Container(
                            //               padding: EdgeInsets.all(5),
                            //               decoration: BoxDecoration(
                            //                 color: Colors.black,
                            //                 borderRadius:
                            //                     BorderRadius.circular(10),
                            //               ),
                            //               child: Row(
                            //                 children: [
                            //                   Icon(
                            //                     Icons.apple_outlined,
                            //                     color: Colors.white,
                            //                     size: 25,
                            //                   ),
                            //                   Column(
                            //                     children: [
                            //                       Text(
                            //                         'Download our IOS app from',
                            //                         style: TextStyle(
                            //                             color: Colors.white,
                            //                             fontSize: 8),
                            //                       ),
                            //                       Text('APPLE STORE',
                            //                           style: TextStyle(
                            //                               color: Colors.white,
                            //                               fontSize: 12)),
                            //                     ],
                            //                   ),
                            //                 ],
                            //               ),
                            //             ),
                            //           ),
                            //           SizedBox(
                            //             width: 10 * horizontalScale,
                            //           ),
                            //           InkWell(
                            //             onTap: () {
                            //               launch(
                            //                   'https://play.google.com/store/apps/details?id=com.cloudyml.cloudymlapp');
                            //             },
                            //             child: Container(
                            //               padding: EdgeInsets.all(5),
                            //               decoration: BoxDecoration(
                            //                 color: Colors.black,
                            //                 borderRadius:
                            //                     BorderRadius.circular(10),
                            //               ),
                            //               child: Row(
                            //                 children: [
                            //                   Icon(
                            //                     Icons.play_arrow,
                            //                     color: Colors.white,
                            //                     size: 25,
                            //                   ),
                            //                   Column(
                            //                     children: [
                            //                       Text(
                            //                         'Download our Android app from',
                            //                         style: TextStyle(
                            //                             color: Colors.white,
                            //                             fontSize: 8),
                            //                       ),
                            //                       Text('GOOGLE PLAY',
                            //                           style: TextStyle(
                            //                               color: Colors.white,
                            //                               fontSize: 12)),
                            //                     ],
                            //                   ),
                            //                 ],
                            //               ),
                            //             ),
                            //           ),
                            //         ],
                            //       ),
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }
            }),
          );
  }
}
