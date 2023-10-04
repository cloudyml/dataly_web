import 'dart:async';
import 'dart:html' as html;
import 'dart:convert';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudyml_app2/services/local_notificationservice.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import '../authentication/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';
import 'package:g_recaptcha_v3/g_recaptcha_v3.dart';
import '../global_variable.dart' as globals;

class splash extends StatefulWidget {
  const splash({Key? key}) : super(key: key);

  @override
  State<splash> createState() => _splashState();
}

class _splashState extends State<splash> {
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final myBox = Hive.box('myBox');



  @override
  void initState() {
    // TODO:implement initState
    super.initState();
    GRecaptchaV3.hideBadge();
    Timer(Duration(seconds: 0), () => GoRouter.of(context).push('/login')

        //     Navigator.pushReplacement(
        // context, MaterialPageRoute(builder: (context) => Authenticate()))

        );

    //listnerNotifications();
    //gives you the message on which user taps and opens
    //the app from terminated state
    FirebaseMessaging.instance.getInitialMessage().then(
      (message) {
        print("FirebaseMessaging.instance.getInitialMessage");
        if (message != null) {
          print("New Notification");
          // if (message.data['_id'] != null) {
          //   Navigator.of(context).push(
          //     MaterialPageRoute(
          //       builder: (context) => DemoScreen(
          //         id: message.data['_id'],
          //       ),
          //     ),
          //   );
          // }
        }
      },
    );

    ////foreground notification
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      await FirebaseFirestore.instance
          .collection("Users_dataly")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get()
          .then((value) {
        globals.role = value.data()!['role'];
      });
      if (message.data["SenderId"] != null || message.data["SenderId"] != "") {
        print(message.notification!.title);
        print(message.notification!.body);

        var expression = true;
        print(await myBox.values.toString() + "ppppppp");
        final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        var data = {
          "ID": id,
          "student_id": FirebaseAuth.instance.currentUser!.uid,
          "senderID": message.data["SenderId"],
          "DocumentId": message.data["DocumentId"],
          "count": 1
        };
        var dataValues = await myBox.values;
        int count;
        if (dataValues.isNotEmpty) {
          for (var i in dataValues) {
            if (i["senderID"] == data["senderID"]) {
              expression = false;
              count = i["count"] + 1;
              removeNotification(i["ID"]);
              await LocalNotificationService.display(message, "", id, count);
              data = {
                "ID": id,
                "student_id": FirebaseAuth.instance.currentUser!.uid,
                "senderID": i["senderID"],
                "DocumentId": i["DocumentId"],
                "count": count
              };
              await myBox.put(data["ID"], data);
            }
          }
          if (expression) {
            await LocalNotificationService.display(message, "", id, 1);
            await myBox.put(data["ID"], data);
          }
        } else {
          await LocalNotificationService.display(message, "", id, 1);
          await myBox.put(data["ID"], data);
        }
      } else {
        LocalNotificationService.createanddisplaynotification(message);
      }
    });

    ////app is background but opened and user taps on the notification
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      // String imageUrl = message.notification!.android!.imageUrl??'';
      // _firestore.collection('Notifications')
      //     .add({
      //   'title':message.notification!.title,
      //   'description':message.notification!.body,
      //   'icon':imageUrl
      // });
      final routeFromMessage = message.data["route"];
      print("route = " + routeFromMessage);
      Navigator.of(context).pushNamed(routeFromMessage);
    });
    getcoursemodulename();
  }

  List coursenamelist = [];
  List moduelnamelist = [];
  Map coursemodule = {};
  List tempmodulelist = [];

  getcoursemodulename() async {
    //feteching list of courses
    try {
      await FirebaseFirestore.instance
          .collection("courses")
          .get()
          .then((value) {
        for (var i in value.docs) {
          coursenamelist.add(i['name']);
        }
        print("coursenamelist: ${coursenamelist}");
      }).whenComplete(() async {
        for (var i in coursenamelist) {
          try {
            await FirebaseFirestore.instance
                .collection("courses")
                .where("name", isEqualTo: i)
                .get()
                .then((value) {
              var data = value.docs.first.data()['curriculum1'][i];
              for (var j in data) {
                moduelnamelist.add(j['modulename']);
              }
              setState(() {
                coursemodule[i] = moduelnamelist;
              });
              moduelnamelist = [];
            });
          } catch (e) {
            print(e.toString());
          }
        }
      });
    } catch (e) {
      print("error while getting coursename: ${e.toString()}");
    }
    void prints(var s1) {
      String s = s1.toString();
      final pattern = RegExp('.{1,800}');
      pattern.allMatches(s).forEach((match) => print("${match.group(0)}\n"));
    }
    globals.moduleList = moduelnamelist;
    globals.courseList = coursenamelist;
    globals.coursemoduelmap = coursemodule;
  }

  // StreamSubscription<String?> listnerNotifications(){
  //   return LocalNotificationService.onNotifications.stream.listen(onClickedNotification);
  // }
  // void onClickedNotification(String? payload) {
  //   //dispose();
  //   if(!mounted){
  //     // setState((){
  //       Navigator.of(context).pushNamed('account');
  //     //});
  //   }
  // }

  removeNotification(ID) async {
    await _flutterLocalNotificationsPlugin.cancel(ID);
    await myBox.delete(ID);
  }

  void pushToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Authenticate(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;
    return Scaffold(
      body: Center(
          child: Image.network(
              "https://firebasestorage.googleapis.com/v0/b/cloudyml-app.appspot.com/o/test_developer%2Fnewone.gif?alt=media&token=c9254df1-d4a1-4557-842d-032355c3ac66",
              fit: BoxFit.fill)
          // SpinKitCircle(
          //   color: Colors.deepPurpleAccent,
          //   size: 150,
          //   duration: Duration(milliseconds: 200),
          // ),
          ),
      // body: Container(
      //   decoration: BoxDecoration(
      //       gradient: LinearGradient(
      //           begin: Alignment.bottomLeft,
      //           end: Alignment.topRight,
      //           colors: [
      //             Color(0xFF7860DC),
      //             // Color(0xFFC0AAF5),
      //             // Color(0xFFDDD2FB),
      //             Color.fromARGB(255, 158, 2, 148),
      //             // Color.fromARGB(255, 5, 2, 180),
      //             // Color.fromARGB(255, 3, 193, 218)
      //           ])),
      //   child: Column(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     crossAxisAlignment: CrossAxisAlignment.stretch,
      //     mainAxisSize: MainAxisSize.max,
      //     children: [
      //       SizedBox(
      //           height: 350,
      //           width: 150,
      //           child: Image.asset("assets/splashMainImage.png")),
      //       // DropShadowImage(
      //       //   image: Image.asset(
      //       //     'assets/DP_png.png',
      //       //     width: width * .45,
      //       //     height: height * .2,
      //       //   ),
      //       //   offset: const Offset(3, 8),
      //       //   scale: .9,
      //       //   blurRadius: 10,
      //       //   borderRadius: 0,
      //       // ),
      //       SizedBox(height: 10),
      //       Flexible(
      //         child: DefaultTextStyle(
      //           style: TextStyle(
      //             fontSize: 40,
      //             fontWeight:
      //             FontWeight.lerp(FontWeight.w900, FontWeight.w900, 10.5),
      //             color: Colors.white,
      //             shadows: [
      //               Shadow(
      //                 blurRadius: 0.5,
      //                 color: Colors.black,
      //                 offset: Offset(0, 8),
      //               ),
      //             ],
      //           ),
      //           child: Text('CloudyML', textAlign: TextAlign.center),
      //           // child: AnimatedTextKit(
      //           //   animatedTexts: [
      //           //     ColorizeAnimatedText(
      //           //       'CloudyML',
      //           //       textAlign: TextAlign.center,
      //           //       colors: [
      //           //         Colors.white,
      //           //         Color.fromARGB(255, 245, 245, 245),
      //           //         Colors.purple,
      //           //         Color.fromARGB(255, 79, 3, 210),
      //           //         Colors.pinkAccent,
      //           //         Colors.amber,
      //           //         Colors.teal,
      //           //         // Colors.red,
      //           //       ],
      //           //       textStyle: TextStyle(fontSize: 50),
      //           //       speed: Duration(milliseconds: 500),
      //           //     ),
      //           //   ],
      //           //   pause: Duration(milliseconds: 1500),
      //           //   totalRepeatCount: 1,
      //           //   isRepeatingAnimation: true,
      //           // ),
      //         ),
      //       ),
      //       SizedBox(height: 10),
      //       Flexible(
      //         child: DefaultTextStyle(
      //           style: TextStyle(
      //             fontSize: 30,
      //             fontWeight: FontWeight.bold,
      //             color: Colors.white,
      //             shadows: [
      //               Shadow(
      //                 blurRadius: .5,
      //                 color: Colors.black,
      //                 offset: Offset(0, 7),
      //               ),
      //             ],
      //           ),
      //           child: RichText(
      //               textAlign: TextAlign.center,
      //               text: TextSpan(
      //                   text: '#Learn',
      //                   style: TextStyle(
      //                       fontWeight: FontWeight.bold,
      //                       fontSize: 18,
      //                       color: Colors.white),
      //                   children: <TextSpan>[
      //                     TextSpan(
      //                         text: 'By',
      //                         style: TextStyle(
      //                             fontWeight: FontWeight.bold,
      //                             fontSize: 18,
      //                             color: Colors.yellow)),
      //                     TextSpan(
      //                         text: 'Doing ',
      //                         style: TextStyle(
      //                             fontWeight: FontWeight.bold,
      //                             fontSize: 18,
      //                             color: Colors.white))
      //                   ])),
      //           // child: AnimatedTextKit(
      //           //     pause: Duration(seconds: 1),
      //           //     animatedTexts: [
      //           //       TyperAnimatedText('#LearnByDoing',
      //           //           textAlign: TextAlign.center,
      //           //           speed: Duration(milliseconds: 300),
      //           //           curve: Curves.bounceInOut),
      //           //     ],
      //           //     totalRepeatCount: 1,
      //           //     isRepeatingAnimation: true,
      //           //     onFinished: () {
      //           //       pushToHome();
      //           //     }),
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
    );
  }
}
