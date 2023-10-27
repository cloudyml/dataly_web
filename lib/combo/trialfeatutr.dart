import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudyml_app2/fun.dart';
import 'package:cloudyml_app2/globals.dart';
import 'package:cloudyml_app2/models/course_details.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../widgets/pay_nowfeature.dart';
import 'non_trial_course_paynowbtsheet.dart';

class NewFeature extends StatefulWidget {
  final List<dynamic>? courses;
  final String? id;
  final String? courseName;
  final String? cID;
  final String? courseP;
  const NewFeature({Key? key, this.cID, this.courses, this.id, this.courseName, this.courseP})
      : super(key: key);

  @override
  State<NewFeature> createState() => _NewFeatureState();
}

class _NewFeatureState extends State<NewFeature> {
  List<CourseDetails> featuredCourse = [];

  setFeaturedCourse(List<CourseDetails> course) {
    featuredCourse.clear();

    course.forEach((element) {
      print(' $element ');
      if (element.courseDocumentId == widget.cID) {
        featuredCourse.add(element);
        // featuredCourse.add(element.courses);

        print('element ${featuredCourse[0].findex} ');
      }
    });
    print('function ');
  }

  List<String> listNameOfButton = [
    "Home",
    "My Courses",
    "Reviews",
    "Blog",
    "About Us"
  ];

  getAllPaidCourses() async {
    await FirebaseFirestore.instance
        .collection("Users_dataly")
        .doc()
        .get()
        .then((value) {
      print(value);
    });
  }

  var coursePercent = {};
  var courseData = null;
  // getPercentageOfCourse() async {
  //   var data = await FirebaseFirestore.instance
  //       .collection("courseprogress_dataly")
  //       .doc(FirebaseAuth.instance.currentUser!.uid)
  //       .get();
  //   setState(() {
  //     courseData = data.data();
  //   });
  //   print("GETDATA $courseData");
  //   print(widget.courses);
  //   print(courseData![widget.courses![2] + "percentage"]);
  // }

  Map<String, dynamic> numberOfCourseHours = {};
  late VideoPlayerController _controller;
  Duration totalDurationOfCourse = Duration.zero;

  /*---- parse Duration srinivas -----*/
  Duration parseDuration(String s) {
    int hours = 0;
    int minutes = 0;
    int micros;
    List<String> parts = s.split(':');
    if (parts.length > 2) {
      hours = int.parse(parts[parts.length - 3]);
    }
    if (parts.length > 1) {
      minutes = int.parse(parts[parts.length - 2]);
    }
    micros = (double.parse(parts[parts.length - 1]) * 1000000).round();
    return Duration(hours: hours, minutes: minutes, microseconds: micros);
  }
  /*------- total duration of course -------*/

  // getTheDurationOfCourse()
  // async{
  //   // VideoPlayerController playerController = await VideoPlayerController.network("https://media.publit.io/file/kaggleCourse/8-reviewing-a-notebook.mp4"
  //   //   // value.docs.first.data()["curriculum1"][value.docs.first
  //   //   //     .data()["name"]][j]["videos"][k]["url"].toString()
  //   // );
  //   // await playerController.initialize().then((value) {
  //   //   print(playerController.value.duration.inSeconds);
  //   // });
  //   // print("112Seconds  ${await playerController.value.duration.inMinutes}");
  //   for(int i=0;i<widget.courses!.length;i++)
  //   {
  //     await FirebaseFirestore.instance.collection("courses").where("id",isEqualTo: widget.courses![i].toString()).get().then((value) async{
  //       print("length--------- ${value.docs.first.data()["curriculum1"][value.docs.first.data()["name"]].length} ${value.docs.first.data()["name"]}");
  //       for(int j=0;j<value.docs.first.data()["curriculum1"][value.docs.first.data()["name"]].length;j++)
  //       {
  //         for(int k=0;k<value.docs.first.data()["curriculum1"][value.docs.first.data()["name"]][j]["videos"].length;k++)
  //         {
  //           print("video-- ${value.docs.first.data()["curriculum1"][value.docs.first.data()["name"]][j]["videos"][k]["url"]}");
  //           if(value.docs.first.data()["curriculum1"][value.docs.first.data()["name"]][j]["videos"][k]["type"]=="video") {
  //             // _controller = await VideoPlayerController.network(
  //             //   // "https://media.publit.io/file/kaggleCourse/8-reviewing-a-notebook.mp4"
  //             //     value.docs.first.data()["curriculum1"][value.docs.first
  //             //         .data()["name"]][j]["videos"][k]["url"].toString()
  //             // );
  //
  //             // value.docs.first.data()["curriculum1"][value.docs.first.data()["name"]][j]["videos"][k]["duration"]!=null?
  //             // totalDurationOfCourse = value.docs.first.data()["curriculum1"][value.docs.first.data()["name"]][j]["videos"][k]["duration"]+totalDurationOfCourse:null;
  //             if(value.docs.first.data()["curriculum1"][value.docs.first.data()["name"]][j]["videos"][k]["duration"]!=null) {
  //                  Duration duration = parseDuration(value.docs.first.data()["curriculum1"][value.docs.first.data()["name"]][j]["videos"][k]["duration"].toString());
  //                  totalDurationOfCourse += duration;
  //             }
  //             // await _controller.initialize().then((value) {
  //             //   print("Seconds  ${_controller.value.duration.inSeconds}");
  //             // });
  //             // ..initialize();
  //           }
  //         }
  //       }
  //     });
  //   }
  // }

  static final _stateStreamController = StreamController<List>.broadcast();
  static StreamSink<List> get counterSink => _stateStreamController.sink;
  static Stream<List> get counterStream => _stateStreamController.stream;

  getTheStreamData() async {
    print("calling...");
    await FirebaseFirestore.instance.collection("courses").get().then((value) {
      print("0000000 $value");
      counterSink.add(value.docs);
    });
  }
  Map<String, dynamic> comboMap = {};

 var international;
  void getCourseName() async {
    print('this idd ${widget.cID}');
    await FirebaseFirestore.instance
        .collection('courses')
        .doc(widget.cID)
        .get()
        .then((value) {
      comboMap = value.data()!;
      setState(() {
        comboMap = value.data()!;
        international = value.data()!['international'];
        print('cid is ${comboMap['trialCourse']} ${int.parse(widget.id!)}');

      });
    });
  }


    void url_del() {
    FirebaseFirestore.instance.collection('Notice')
      ..doc("gMAzwcnKV1o7zVwUdLV0_datalyfeature1")
          .update({'url': ""}).whenComplete(() {
        print('New feature Deleted');
      });
  }

  Map userMap = Map<String, dynamic>();

    void dbCheckerForPayInParts() async {
    try {
      DocumentSnapshot userDocs = await FirebaseFirestore.instance
          .collection("Users_dataly")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      // print(map['payInPartsDetails'][id]['outStandingAmtPaid']);
      // setState(() {
      userMap = userDocs.data() as Map<String, dynamic>;
      // whetherSubScribedToPayInParts =
      //     !(!(map['payInPartsDetails']['outStandingAmtPaid'] == null));
      // });
    } catch (e) {
      print("ggggggggggg $e");
    }
  }

    void checkl() async {
    CollectionReference users = FirebaseFirestore.instance.collection("Users_dataly");
    var doc = await users.doc(FirebaseAuth.instance.currentUser!.uid).get();
    if (doc.exists) {
      Map<String, dynamic>? map = doc.data() as Map<String, dynamic>?;
      if (map!.containsKey('trialCourseList')) {
        // Replace field by the field you want to check.
        var valueOfField = map['trialCourseList'];
        print('i am in main if');

      } else {
        FirebaseFirestore.instance
            .collection("Users_dataly")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({
          'trialCourseList': "",
        });

        print('i am in main else');
      }
    }
  }

  @override
  void initState() {

    checkl();
    dbCheckerForPayInParts();

    // getTheStreamData();
    getCourseName();
    // getTheDurationOfCourse();
    getAllPaidCourses();
    // getPercentageOfCourse();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<CourseDetails> course = Provider.of<List<CourseDetails>>(context);
    setFeaturedCourse(course);
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    url_del();

    return Scaffold(
      bottomSheet:
      fromMultiCombo? null :
      comboMap['trialCourse']! != null && comboMap['trialCourse']!
          ? PayNowBottomSheetfeature(
        coursePrice: comboMap['dataly_discounted_price'] != null ? 'CAD ${comboMap['dataly_discounted_price']}' :  international != null && international == true ? '\$${((double.parse(comboMap['Course Price'])/82)+5).round().toString()}/-' : '₹${widget.courseP!}/-',
        international: international == null ||  international == false ? false : international,
        map: comboMap,
        isItComboCourse: true,
        cID: widget.cID!,
        // id: widget.id!,
        usermap:userMap as Map<String, dynamic>
      )
          : NonTrialCourseBottomSheet(
        coursePrice: international != null && international == true ? '\$${((double.parse(comboMap['Course Price'])/82)+5).round().toString()}/-' : '₹${widget.courseP!}/-',
        map: comboMap,
        international: international == null ||  international == false ? false : international,
        isItComboCourse: true,
        cID: widget.cID!,
      ),

      body: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: NetworkImage("https://firebasestorage.googleapis.com/v0/b/cloudyml-app.appspot.com/o/test_developer%2FbackGroundImage.jpg?alt=media&token=c7282af8-222d-4761-89b0-35fa206f0ac1"),
                    fit: BoxFit.fill),
                color: HexColor("#fef0ff"),
              ),
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                      InkWell(
                                onTap: () {
                                GoRouter.of(context)
                                          .pushReplacementNamed('home');
                                },
                                child: Container(
                                    child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(50, 0, 0, 0),
                                        child: Icon(Icons.arrow_back_rounded),
                                      ),
                                      Text(
                                        'Back',
                                        style: TextStyle(
                                          fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      )
                                    ],
                                  ),
                                )),
                              ),
                    RichText(
                      text: TextSpan(children: [
                        TextSpan(
                            text: "Welcome to ",
                            style: TextStyle(
                                fontWeight: FontWeight.w200,
                                fontSize: width < 850
                                    ? width < 430
                                        ? 25
                                        : 30
                                    : 40,
                                color: Colors.black)),
                        TextSpan(
                            text: "${widget.courseName}",
                            style: TextStyle(
                                fontSize: width < 850
                                    ? width < 430
                                        ? 25
                                        : 30
                                    : 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.black))
                      ]),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 10,
                    ),
             Padding(
               padding: constraints.maxWidth>=630?
                EdgeInsets.fromLTRB(240, 0, 240, 0):EdgeInsets.fromLTRB(0, 0, 0, 0),
               child: Container(
                        width: constraints.maxWidth,
                        height: MediaQuery.of(context).size.height,
                        child: ListView.builder(
                            itemCount: course.length,
                            itemBuilder: (BuildContext context, index) {
                              List courseList = [];
                              for (var i in featuredCourse[0].courses) {
                                for (var j in course) {
                                  if (i == j.courseId) {
                                    courseList.add(j);
                                  }
                                }
                              }
                              if (course[index].courseName == "null") {
                                return Container();
                              }
                              if (courseList.length != 0) {
                                print('listtto ${courseList.length}');
                                print('listtto $courseList');

                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    padding: EdgeInsets.all(8),
                                    margin: EdgeInsets.only(bottom: 15),
                                    width: width < 1700
                                        ? width < 1300
                                        ? width < 850
                                        ? constraints.maxWidth - 20
                                        : constraints.maxWidth - 200
                                        : constraints.maxWidth - 400
                                        : constraints.maxWidth - 700,
                                    height: width > 700
                                        ? 230
                                        : width < 300
                                        ? 190
                                        : 210,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                        BorderRadius.circular(20),
                                        color: Colors.white),
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          courseId = courseList[index].courseDocumentId;
                                        });
                                        // final id = index.toString();
                                        // GoRouter.of(context).pushNamed('catalogue',
                                        //     queryParams: {'id': id, 'cID': courseId});
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: [
                                          // Expanded(
                                          //   flex: width <= 630 ? 6: 2,
                                          //   child: Padding(
                                          //     padding: EdgeInsets.all(3),
                                          //     child: ClipRRect(
                                          //       // borderRadius:
                                          //       // BorderRadius.circular(
                                          //       //     25),
                                          //       child: 
                                          //       Container(
                                          //         // width: 130,
                                          //         // height: constraints.maxWidth>=630?250:190,
                                          //         child: CachedNetworkImage(
                                          //           imageUrl:
                                          //           courseList[index]
                                          //               .courseImageUrl,
                                          //               fit: BoxFit.fill,
                                          //           placeholder: (context,
                                          //               url) =>
                                          //               Center(
                                          //                   child:
                                          //                   CircularProgressIndicator()),
                                          //           errorWidget: (context,
                                          //               url, error) =>
                                          //               Icon(Icons.error),
                                          //         ),
                                          //       ),
                                          //     ),
                                          //   ),
                                          // ),
                                         SizedBox(width: 15,),
                                          Expanded(
                                              flex: width < 600 ? 6 : 4,
                                              child: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                // mainAxisAlignment:
                                                // width>700?
                                                // MainAxisAlignment
                                                    // .spaceAround,
                                                // :MainAxisAlignment.start,
                                                children: [
                                                  SizedBox(height: width>750?0:10,),
                                                  SizedBox(
                                                        height: 50,
                                                      ),
                                                  Container(
                                                    // margin: EdgeInsets.only(top: 3),
                                                    padding:
                                                    EdgeInsets.all(5),
                                                    decoration: BoxDecoration(
                                                        color: Colors.purple,
                                                        borderRadius:
                                                        BorderRadius
                                                            .circular(
                                                            10)),
                                                    child: Text(
                                                      "Module : $index",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 10),
                                                    ),
                                                  ),
                                                  // SizedBox(height: width>750?0:10,),
                                                  // SizedBox(height: 8,),
                                                  SizedBox(
                                                        height: 13,
                                                      ),
                                                  Column(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .start,
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,
                                                    children: [
                                                      Text(
                                                        courseList[index]
                                                            .courseName,
                                                        style: TextStyle(
                                                            height: 1,
                                                            fontWeight:
                                                            FontWeight
                                                                .bold,
                                                            fontSize: width >
                                                                700
                                                                ? 25
                                                                : width < 540
                                                                ? 12
                                                                : 14),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 4,
                                                      ),
                                                      SizedBox(
                                                        height: 13,
                                                      ),
                                                      Text(
                                                        "Estimated Learning Time :${courseList[index].duration}",
                                                        style: TextStyle( fontWeight: FontWeight.w700,
                                                                              fontSize: width < 540
                                                                                  ? width < 420
                                                                                  ? 11
                                                                                  : 13
                                                                                  : 14),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 4,
                                                        
                                                      ),
                                                      // SizedBox(height: width>750?0:10,),
                                                      // Row(
                                                      //   mainAxisAlignment:
                                                      //   MainAxisAlignment
                                                      //       .spaceBetween,
                                                      //   crossAxisAlignment:
                                                      //   CrossAxisAlignment
                                                      //       .start,
                                                      //   children: [
                                                      //     Expanded(
                                                      //         child: Column(
                                                      //           crossAxisAlignment:
                                                      //           CrossAxisAlignment
                                                      //               .start,
                                                      //           mainAxisAlignment:
                                                      //           MainAxisAlignment
                                                      //               .start,
                                                      //           children: [
                                                      //             Text(
                                                      //                 "Estimates learning time: ",
                                                      //                     // "${courseList[index].duration == null ? "0" : courseList[index].duration}",
                                                      //                 overflow:
                                                      //                 TextOverflow
                                                      //                     .ellipsis,
                                                      //                 style: TextStyle(
                                                      //                     fontSize: width < 540
                                                      //                         ? width < 420
                                                      //                         ? 11
                                                      //                         : 13
                                                      //                         : 14)
                                                      //                         ),
                                                      //             SizedBox(
                                                      //               height: 3,
                                                      //             ),
                                                      //             Text(
                                                      //                 "Started on: Jan 01,2023",
                                                      //                 overflow:
                                                      //                 TextOverflow
                                                      //                     .ellipsis,
                                                      //                 style: TextStyle(
                                                      //                     fontSize: width < 540
                                                      //                         ? width < 420
                                                      //                         ? 11
                                                      //                         : 13
                                                      //                         : 14)),
                                                      //             SizedBox(
                                                      //               height: 3,
                                                      //             ),
                                                      //             Text(
                                                      //                 "Completed on: Jan 01,2023",
                                                      //                 overflow:
                                                      //                 TextOverflow
                                                      //                     .ellipsis,
                                                      //                 style: TextStyle(
                                                      //                     fontSize: width < 540
                                                      //                         ? width < 420
                                                      //                         ? 11
                                                      //                         : 13
                                                      //                         : 14)),
                                                      //             SizedBox(
                                                      //               height: 15,
                                                      //             ),
                                                      //             // SizedBox(
                                                      //             //   width: width <
                                                      //             //       400
                                                      //             //       ? 160
                                                      //             //       : 190,
                                                      //             //   child:
                                                      //             //   MaterialButton(
                                                      //             //     height: width >
                                                      //             //         700
                                                      //             //         ? 50
                                                      //             //         : 40,
                                                      //             //     shape:
                                                      //             //     RoundedRectangleBorder(
                                                      //             //       borderRadius:
                                                      //             //       BorderRadius.circular(
                                                      //             //           20),
                                                      //             //     ),
                                                      //             //     padding:
                                                      //             //     EdgeInsets
                                                      //             //         .all(8),
                                                      //             //     minWidth:
                                                      //             //     width > 700
                                                      //             //         ? 100
                                                      //             //         : 60,
                                                      //             //     onPressed:
                                                      //             //         () {
                                                      //             //
                                                      //             //     },
                                                      //             //     child: Row(
                                                      //             //       children: [
                                                      //             //         SizedBox(
                                                      //             //           width:
                                                      //             //           5,
                                                      //             //         ),
                                                      //             //         Expanded(
                                                      //             //             flex:
                                                      //             //             1,
                                                      //             //             child:
                                                      //             //             Icon(
                                                      //             //               Icons.play_arrow,
                                                      //             //               color: Colors.white,
                                                      //             //               size: width < 200 ? 2 : null,
                                                      //             //             )),
                                                      //             //         Expanded(
                                                      //             //             flex:
                                                      //             //             3,
                                                      //             //             child:
                                                      //             //             Text(
                                                      //             //               "Resume learning",
                                                      //             //               style: TextStyle(color: Colors.white, fontSize: width < 500 ? 10 : null),
                                                      //             //               overflow: TextOverflow.ellipsis,
                                                      //             //             ))
                                                      //             //       ],
                                                      //             //     ),
                                                      //             //     color: Colors
                                                      //             //         .purple,
                                                      //             //   ),
                                                      //             // )
                                                      //           ],
                                                      //         )),
                                                      //     SizedBox(
                                                      //       width: 5,
                                                      //     ),
                                                      //     width < 700
                                                      //         ?
                                                      //     // Expanded(
                                                      //     //   child:
                                                      //     Column(
                                                      //       mainAxisAlignment: width > 700
                                                      //           ? MainAxisAlignment
                                                      //           .center
                                                      //           : MainAxisAlignment
                                                      //           .end,
                                                      //       children: [
                                                      //         SizedBox(
                                                      //           height:
                                                      //           25,
                                                      //         ),
                                                      //
                                                      //         // CircularPercentIndicator(
                                                      //         //   radius: width <
                                                      //         //       700
                                                      //         //       ? width < 500
                                                      //         //       ? 20
                                                      //         //       : 30
                                                      //         //       : 70,
                                                      //         //   lineWidth: width >
                                                      //         //       700
                                                      //         //       ? 10.0
                                                      //         //       : 4.0,
                                                      //         //   animation:
                                                      //         //   true,
                                                      //         //   percent: courseData !=
                                                      //         //       null
                                                      //         //       ? courseData[widget.courses![index] + "percentage"] != null
                                                      //         //       ? (courseData[widget.courses![index] + "percentage"]) / 100 > 1
                                                      //         //       ? 100 / 100
                                                      //         //       : courseData[widget.courses![index] + "percentage"] / 100
                                                      //         //       : 0 / 100
                                                      //         //       : 0,
                                                      //         //   center: courseData !=
                                                      //         //       null
                                                      //         //       ? courseData[widget.courses![index] + "percentage"] != null
                                                      //         //       ? Text(
                                                      //         //     courseData[widget.courses![index] + "percentage"] > 100 ? "100%" : courseData[widget.courses![index] + "percentage"].toString() + "%",
                                                      //         //     style: TextStyle(
                                                      //         //         fontSize: width > 700
                                                      //         //             ? 20.0
                                                      //         //             : width < 500
                                                      //         //             ? 8
                                                      //         //             : 14,
                                                      //         //         fontWeight: FontWeight.w600,
                                                      //         //         color: Colors.black),
                                                      //         //   )
                                                      //         //       : Text(
                                                      //         //     0.toString() + "%",
                                                      //         //     style: TextStyle(
                                                      //         //         fontSize: width > 700
                                                      //         //             ? 20.0
                                                      //         //             : width < 500
                                                      //         //             ? 8
                                                      //         //             : 14,
                                                      //         //         fontWeight: FontWeight.w600,
                                                      //         //         color: Colors.black),
                                                      //         //   )
                                                      //         //       : SizedBox(),
                                                      //         //   backgroundColor:
                                                      //         //   Colors.black12,
                                                      //         //   circularStrokeCap:
                                                      //         //   CircularStrokeCap.round,
                                                      //         //   progressColor:
                                                      //         //   Colors.green,
                                                      //         // ),
                                                      //
                                                      //
                                                      //         SizedBox(
                                                      //           height: width <
                                                      //               500
                                                      //               ? 3
                                                      //               : 5,
                                                      //         ),
                                                      //
                                                      //         // courseData !=
                                                      //         //     null
                                                      //         //     ? Text(
                                                      //         //   courseData[widget.courses![index] + "percentage"] != null
                                                      //         //       ? courseData[widget.courses![index] + "percentage"] > 100
                                                      //         //       ? "100%"
                                                      //         //       : courseData[widget.courses![index] + "percentage"].toString() + "%"
                                                      //         //       : "0%",
                                                      //         //   style: TextStyle(fontSize: 7, fontWeight: FontWeight.bold),
                                                      //         // )
                                                      //         //     : SizedBox(),
                                                      //
                                                      //
                                                      //         // SizedBox(height: 15,),
                                                      //         // Text("10%")
                                                      //       ],
                                                      //     )
                                                      //     // ,
                                                      //     // )
                                                      //         : SizedBox(),
                                                      //     SizedBox(
                                                      //       width: 5,
                                                      //     )
                                                      //   ],
                                                      // ),
                                                    ],
                                                  )
                                                ],
                                              )),
                                          // SizedBox(width: 10,),


                                          // width > 700
                                          //     ? Expanded(
                                          //   flex: 2,
                                          //   // color: Colors.green,
                                          //   child: Column(
                                          //     mainAxisAlignment:
                                          //     width > 700
                                          //         ? MainAxisAlignment
                                          //         .center
                                          //         : MainAxisAlignment
                                          //         .end,
                                          //     children: [
                                          //       CircularPercentIndicator(
                                          //         radius: width > 700
                                          //             ? 70.0
                                          //             : 40.0,
                                          //         lineWidth: 10.0,
                                          //         animation: true,
                                          //         percent: courseData !=
                                          //             null
                                          //             ? courseData[widget.courses![
                                          //         index] +
                                          //             "percentage"] !=
                                          //             null
                                          //             ? courseData[widget
                                          //             .courses![index] +
                                          //             "percentage"] /
                                          //             100
                                          //             : 0 / 100
                                          //             : 0,
                                          //         center: courseData !=
                                          //             null
                                          //             ? courseData[widget.courses![
                                          //         index] +
                                          //             "percentage"] !=
                                          //             null
                                          //             ? Text(
                                          //           courseData[widget.courses![index] + "percentage"]
                                          //               .toString() +
                                          //               "%",
                                          //           style: TextStyle(
                                          //               fontSize:
                                          //               20.0,
                                          //               fontWeight: FontWeight
                                          //                   .w600,
                                          //               color:
                                          //               Colors.black),
                                          //         )
                                          //             : Text(
                                          //             0.toString() +
                                          //                 '%',
                                          //             style: TextStyle(
                                          //                 fontSize:
                                          //                 20.0,
                                          //                 fontWeight: FontWeight
                                          //                     .w600,
                                          //                 color:
                                          //                 Colors.black))
                                          //             : SizedBox(),
                                          //         backgroundColor:
                                          //         Colors.black12,
                                          //         circularStrokeCap:
                                          //         CircularStrokeCap
                                          //             .round,
                                          //         progressColor:
                                          //         Colors.green,
                                          //       ),
                                          //       SizedBox(
                                          //         height: 15,
                                          //       ),
                                          //       courseData != null
                                          //           ? Text(courseData[widget.courses![
                                          //       index] +
                                          //           "percentage"] !=
                                          //           null
                                          //           ? courseData[widget.courses![index] +
                                          //           "percentage"]
                                          //           .toString() +
                                          //           "%"
                                          //           : "0%")
                                          //           : SizedBox(),
                                          //     ],
                                          //   ),
                                          // )
                                          //     : SizedBox()



                                          // Column(
                                          //   mainAxisAlignment: width>700?MainAxisAlignment.center:MainAxisAlignment.end,
                                          //   children: [
                                          //     CircularPercentIndicator(
                                          //       radius: width>700?70.0:30.0,
                                          //       lineWidth: width>700?10.0:5.0,
                                          //       animation: true,
                                          //       percent: 10/100,
                                          //       center: Text(
                                          //         10.toString() + "%",
                                          //         style: TextStyle(
                                          //             fontSize: width>700?20.0:14,
                                          //             fontWeight: FontWeight.w600,
                                          //             color: Colors.black),
                                          //       ),
                                          //       backgroundColor: Colors.black12,
                                          //       circularStrokeCap: CircularStrokeCap.round,
                                          //       progressColor: Colors.green,
                                          //     ),
                                          //     SizedBox(height: 15,),
                                          //     Text("10%")
                                          //   ],
                                          // ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return Container();
                            }),
                      ),
             ),

                  ],
                ),
              )
              // Stack(
              //   children: [
              //     Column(
              //       crossAxisAlignment: CrossAxisAlignment.stretch,
              //       children: [
              //         customMenuBar(context),
              //         Container(
              //           height: constraints.maxHeight-50,
              //           child: SingleChildScrollView(
              //             child: Column(
              //               mainAxisAlignment: MainAxisAlignment.center,
              //               crossAxisAlignment: CrossAxisAlignment.stretch,
              //               children: [
              //                 SizedBox(height: 10,),
              //                 RichText(text: TextSpan(
              //                     children: [
              //                       TextSpan(text: "welcome to ",style: TextStyle(fontWeight: FontWeight.w200,fontSize: width<850?width<430?25:30:40,color: Colors.black)),
              //                       TextSpan(text: "Data Science and \n Analytics Combo Course",style: TextStyle(fontSize: width<850?width<430?25:30:40,fontWeight: FontWeight.bold,color: Colors.black))
              //                     ]
              //                 ),textAlign: TextAlign.center,),
              //                 SizedBox(height: 10,),
              //                 StreamBuilder(
              //                     stream:counterStream,
              //                     // FirebaseFirestore.instance
              //                     //     .collection('courses')
              //                     //     .snapshots(),
              //                     builder: (context,snapshot){
              //                       if(snapshot.hasData && widget.courses!=null)
              //                       {
              //                         List courseList = [];
              //                         for (var i in widget.courses!) {
              //                           for (var j in course) {
              //                             if (i == j.courseId) {
              //                               courseList.add(j);
              //                             }
              //                           }
              //                         }
              //                         print("listoooo $courseList");
              //                         return Column(
              //                           children: List.generate(courseList.length, (index) {
              //                             print("snapdatassss");
              //                             print(snapshot.data);
              //                             // print("Courses list ${courseList}");
              //                             if (courseList.length > index)  {
              //                               print("Duration ${courseList[index].duration}");
              //                               return
              //                                 Container(
              //                                   padding: EdgeInsets.all(8),
              //                                   margin: EdgeInsets.only(bottom: 15),
              //                                   width: width<1700?width<1300?width<850?constraints.maxWidth-20:constraints.maxWidth-200:constraints.maxWidth-400:constraints.maxWidth-700,
              //                                   height: width>700?230:width<300?190:210,
              //                                   decoration: BoxDecoration(
              //                                       borderRadius: BorderRadius.circular(20),
              //                                       color: Colors.white
              //                                   ),
              //                                   child: InkWell(
              //                                     onTap: ()
              //                                     {
              //                                       setState(() {
              //                                         courseId = courseList[index].courseDocumentId;
              //                                       });
              //                                       GoRouter.of(context).pushNamed('comboVideoScreen',
              //                                           queryParams: {
              //                                             'courseName': courseList[index].courseName,
              //                                             'cID': courseList[index].courseDocumentId,
              //                                           });
              //                                     },
              //                                     child: Row(
              //                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //                                       children: [
              //                                         Expanded(flex:width<600?4:3,child:
              //                                         Padding(
              //                                           padding: EdgeInsets.all(5),
              //                                           child: ClipRRect(
              //                                             borderRadius:
              //                                             BorderRadius.circular(25),
              //                                             child: Container(
              //                                               // width: 130,
              //                                               // height: 95,
              //                                               decoration: BoxDecoration(
              //                                                   borderRadius:
              //                                                   BorderRadius.only(
              //                                                     topLeft: Radius.circular(15),
              //                                                     topRight: Radius.circular(15),
              //                                                     bottomLeft: Radius.circular(15),
              //                                                     bottomRight:
              //                                                     Radius.circular(15),
              //                                                   )),
              //                                               child: CachedNetworkImage(
              //                                                 imageUrl:courseList[index].courseImageUrl,
              //                                                 placeholder: (context, url) =>
              //                                                     Center(child: CircularProgressIndicator()),
              //                                                 errorWidget:
              //                                                     (context, url, error) =>
              //                                                     Icon(Icons.error),
              //                                               ),
              //                                             ),
              //                                           ),
              //                                         )),
              //
              //                                         Expanded(flex: width<600?6:4,
              //                                             child:  Column(
              //                                               crossAxisAlignment: CrossAxisAlignment.start,
              //                                               mainAxisAlignment:
              //                                               // width>700?
              //                                               MainAxisAlignment.spaceAround,
              //                                               // :MainAxisAlignment.start,
              //                                               children: [
              //
              //                                                 // SizedBox(height: width>750?0:10,),
              //                                                 Container(
              //                                                   // margin: EdgeInsets.only(top: 3),
              //                                                   padding: EdgeInsets.all(7),
              //                                                   decoration: BoxDecoration(
              //                                                       color: Colors.purple,
              //                                                       borderRadius: BorderRadius.circular(10)
              //                                                   ),
              //                                                   child: Text("Module 1",style: TextStyle(color: Colors.white,fontSize: 12),),
              //                                                 ),
              //                                                 // SizedBox(height: width>750?0:10,),
              //                                                 // SizedBox(height: 8,),
              //                                                 Column(
              //                                                   mainAxisAlignment: MainAxisAlignment.start,
              //                                                   crossAxisAlignment: CrossAxisAlignment.start,
              //                                                   children: [
              //                                                     Text(
              //                                                       courseList[index].courseName,style:
              //                                                     TextStyle(height: 1,fontWeight: FontWeight.bold,fontSize: width>700?25:width<540?15:16),
              //                                                       overflow: TextOverflow.ellipsis,maxLines: 1,),
              //                                                     SizedBox(height: 15,),
              //                                                     // SizedBox(height: width>750?0:10,),
              //                                                     Row(
              //                                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //                                                       crossAxisAlignment: CrossAxisAlignment.start,
              //                                                       children: [
              //                                                         Expanded(child: Column(
              //                                                           crossAxisAlignment: CrossAxisAlignment.start,
              //                                                           mainAxisAlignment: MainAxisAlignment.start,
              //                                                           children: [
              //                                                             Text("Estimates learning time: ${courseList[index].duration==null?"0":courseList[index].duration} Hr",overflow: TextOverflow.ellipsis,style: TextStyle(fontSize:  width<540?width<420?11:13:14)),
              //                                                             SizedBox(height: 3,),
              //                                                             Text("Started on: Jan 01,2023",overflow: TextOverflow.ellipsis,style: TextStyle(fontSize:  width<540?width<420?11:13:14)),
              //                                                             SizedBox(height: 3,),
              //                                                             Text("Completed on: Jan 01,2023",overflow: TextOverflow.ellipsis,style: TextStyle(fontSize:  width<540?width<420?11:13:14)),
              //                                                             SizedBox(height: 15,),
              //                                                             SizedBox(
              //                                                               width: width<400?160:190,
              //                                                               child:
              //                                                               MaterialButton(
              //                                                                 height: width>700?50:40,
              //                                                                 shape: RoundedRectangleBorder(
              //                                                                   borderRadius: BorderRadius.circular(20),
              //                                                                 ),
              //                                                                 padding: EdgeInsets.all(8),
              //                                                                 minWidth: width>700?100:60,
              //                                                                 onPressed: (){},
              //                                                                 child: Row(
              //                                                                   children: [
              //                                                                     SizedBox(width: 5,),
              //                                                                     Expanded(
              //                                                                         flex:1,
              //                                                                         child:
              //                                                                         Icon(Icons.play_arrow,color: Colors.white,size: width<200?2:null,)),
              //                                                                     Expanded(
              //                                                                         flex:3,
              //                                                                         child:
              //                                                                         Text("Resume learning",style: TextStyle(color: Colors.white,fontSize: width<500?10:null),overflow: TextOverflow.ellipsis,))
              //                                                                   ],
              //                                                                 ),color: Colors.purple,),
              //                                                             )
              //
              //                                                           ],
              //                                                         )),
              //                                                         SizedBox(width: 5,),
              //                                                         width<700?
              //                                                         // Expanded(
              //                                                         //   child:
              //                                                         Column(
              //                                                           mainAxisAlignment: width>700?MainAxisAlignment.center:MainAxisAlignment.end,
              //                                                           children: [
              //                                                             SizedBox(height: 25,),
              //                                                             CircularPercentIndicator(
              //                                                               radius: width<700?width<500?20:30:70,
              //                                                               lineWidth: width>700?10.0:4.0,
              //                                                               animation: true,
              //                                                               percent: courseData!=null?courseData[widget.courses![index]+"percentage"]!=null?courseData[widget.courses![index]+"percentage"]/100:0/100:0,
              //                                                               center: courseData!=null?
              //                                                               courseData[widget.courses![index]+"percentage"]!=null?Text(
              //                                                                 courseData[widget.courses![index]+"percentage"].toString()+ "%",
              //                                                                 style: TextStyle(
              //                                                                     fontSize: width>700?20.0:width<500?8:14,
              //                                                                     fontWeight: FontWeight.w600,
              //                                                                     color: Colors.black),
              //                                                               ):Text(
              //                                                                 0.toString() + "%",
              //                                                                 style: TextStyle(
              //                                                                     fontSize: width>700?20.0:width<500?8:14,
              //                                                                     fontWeight: FontWeight.w600,
              //                                                                     color: Colors.black),
              //                                                               ):SizedBox(),
              //                                                               backgroundColor: Colors.black12,
              //                                                               circularStrokeCap: CircularStrokeCap.round,
              //                                                               progressColor: Colors.green,
              //                                                             ),
              //                                                             SizedBox(height: width<500?3:5,),
              //                                                             courseData!=null?
              //                                                             Text(
              //                                                               courseData[widget.courses![index]+"percentage"]!=null?courseData[widget.courses![index]+"percentage"].toString()+"%":"0%",style: TextStyle(fontSize: 7,fontWeight: FontWeight.bold),):SizedBox()
              //                                                             // SizedBox(height: 15,),
              //                                                             // Text("10%")
              //                                                           ],
              //                                                         )
              //                                                         // ,
              //                                                         // )
              //                                                             :SizedBox(),
              //                                                         SizedBox(width: 5,)
              //                                                       ],
              //                                                     ),
              //                                                   ],
              //                                                 )
              //                                               ],
              //                                             )),
              //                                         // SizedBox(width: 10,),
              //                                         width>700?Expanded(flex:2,
              //                                           // color: Colors.green,
              //                                           child: Column(
              //                                             mainAxisAlignment: width>700?MainAxisAlignment.center:MainAxisAlignment.end,
              //                                             children: [
              //                                               CircularPercentIndicator(
              //                                                 radius: width>700?70.0:40.0,
              //                                                 lineWidth: 10.0,
              //                                                 animation: true,
              //                                                 percent: courseData!=null?courseData[widget.courses![index]+"percentage"]!=null?courseData[widget.courses![index]+"percentage"]/100:0/100:0,
              //                                                 center: courseData!=null?
              //                                                 courseData[widget.courses![index]+"percentage"]!=null?Text(
              //                                                   courseData[widget.courses![index]+"percentage"].toString() + "%",
              //                                                   style: TextStyle(
              //                                                       fontSize: 20.0,
              //                                                       fontWeight: FontWeight.w600,
              //                                                       color: Colors.black),
              //                                                 ):Text(0.toString()+'%',style: TextStyle(
              //                                                     fontSize: 20.0,
              //                                                     fontWeight: FontWeight.w600,
              //                                                     color: Colors.black)):SizedBox(),
              //                                                 backgroundColor: Colors.black12,
              //                                                 circularStrokeCap: CircularStrokeCap.round,
              //                                                 progressColor: Colors.green,
              //                                               ),
              //                                               SizedBox(height: 15,),
              //                                               courseData!=null?Text(
              //                                                   courseData[widget.courses![index]+"percentage"]!=null?courseData[widget.courses![index]+"percentage"].toString()+"%":"0%"):SizedBox()
              //                                             ],
              //                                           ),):
              //                                         SizedBox()
              //                                         // Column(
              //                                         //   mainAxisAlignment: width>700?MainAxisAlignment.center:MainAxisAlignment.end,
              //                                         //   children: [
              //                                         //     CircularPercentIndicator(
              //                                         //       radius: width>700?70.0:30.0,
              //                                         //       lineWidth: width>700?10.0:5.0,
              //                                         //       animation: true,
              //                                         //       percent: 10/100,
              //                                         //       center: Text(
              //                                         //         10.toString() + "%",
              //                                         //         style: TextStyle(
              //                                         //             fontSize: width>700?20.0:14,
              //                                         //             fontWeight: FontWeight.w600,
              //                                         //             color: Colors.black),
              //                                         //       ),
              //                                         //       backgroundColor: Colors.black12,
              //                                         //       circularStrokeCap: CircularStrokeCap.round,
              //                                         //       progressColor: Colors.green,
              //                                         //     ),
              //                                         //     SizedBox(height: 15,),
              //                                         //     Text("10%")
              //                                         //   ],
              //                                         // ),
              //                                       ],
              //                                     ),
              //                                   ),
              //                                 );
              //                             } else {
              //                               return Container();
              //                             }
              //                           },),
              //                         );
              //                       }
              //                       else{
              //                         return Container();
              //                       }
              //
              //                     })
              //               ],
              //             ),
              //           ),
              //         )
              //         // SingleChildScrollView(
              //         //   child: Column(
              //         //     mainAxisAlignment: MainAxisAlignment.center,
              //         //     crossAxisAlignment: CrossAxisAlignment.stretch,
              //         //     children: [
              //         //       SizedBox(height: 10,),
              //         //       RichText(text: TextSpan(
              //         //           children: [
              //         //             TextSpan(text: "welcome to ",style: TextStyle(fontWeight: FontWeight.w200,fontSize: width<850?width<430?25:30:40,color: Colors.black)),
              //         //             TextSpan(text: "Data Science and \n Analytics Combo Course",style: TextStyle(fontSize: width<850?width<430?25:30:40,fontWeight: FontWeight.bold,color: Colors.black))
              //         //           ]
              //         //       ),textAlign: TextAlign.center,),
              //         //       SizedBox(height: 10,),
              //         //       StreamBuilder(
              //         //           stream:counterStream,
              //         //           // FirebaseFirestore.instance
              //         //           //     .collection('courses')
              //         //           //     .snapshots(),
              //         //           builder: (context,snapshot){
              //         //             if(snapshot.hasData && widget.courses!=null)
              //         //             {
              //         //               List courseList = [];
              //         //               for (var i in widget.courses!) {
              //         //                 for (var j in course) {
              //         //                   if (i == j.courseId) {
              //         //                     courseList.add(j);
              //         //                   }
              //         //                 }
              //         //               }
              //         //               print("listoooo $courseList");
              //         //               return Column(
              //         //                 children: List.generate(courseList.length, (index) {
              //         //                   print("snapdatassss");
              //         //                   print(snapshot.data);
              //         //                   // print("Courses list ${courseList}");
              //         //                   if (courseList.length > index)  {
              //         //                     print("Duration ${courseList[index].duration}");
              //         //                     return
              //         //                       Container(
              //         //                         padding: EdgeInsets.all(8),
              //         //                         margin: EdgeInsets.only(bottom: 15),
              //         //                         width: width<1700?width<1300?width<850?constraints.maxWidth-20:constraints.maxWidth-200:constraints.maxWidth-400:constraints.maxWidth-700,
              //         //                         height: width>700?230:width<300?190:210,
              //         //                         decoration: BoxDecoration(
              //         //                             borderRadius: BorderRadius.circular(20),
              //         //                             color: Colors.white
              //         //                         ),
              //         //                         child: InkWell(
              //         //                           onTap: ()
              //         //                           {
              //         //                             setState(() {
              //         //                               courseId = courseList[index].courseDocumentId;
              //         //                             });
              //         //                             GoRouter.of(context).pushNamed('comboVideoScreen',
              //         //                                 queryParams: {
              //         //                                   'courseName': courseList[index].courseName,
              //         //                                   'cID': courseList[index].courseDocumentId,
              //         //                                 });
              //         //                           },
              //         //                           child: Row(
              //         //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //         //                             children: [
              //         //                               Expanded(flex:width<600?4:3,child:
              //         //                               Padding(
              //         //                                 padding: EdgeInsets.all(5),
              //         //                                 child: ClipRRect(
              //         //                                   borderRadius:
              //         //                                   BorderRadius.circular(25),
              //         //                                   child: Container(
              //         //                                     // width: 130,
              //         //                                     // height: 95,
              //         //                                     decoration: BoxDecoration(
              //         //                                         borderRadius:
              //         //                                         BorderRadius.only(
              //         //                                           topLeft: Radius.circular(15),
              //         //                                           topRight: Radius.circular(15),
              //         //                                           bottomLeft: Radius.circular(15),
              //         //                                           bottomRight:
              //         //                                           Radius.circular(15),
              //         //                                         )),
              //         //                                     child: CachedNetworkImage(
              //         //                                       imageUrl:courseList[index].courseImageUrl,
              //         //                                       placeholder: (context, url) =>
              //         //                                           Center(child: CircularProgressIndicator()),
              //         //                                       errorWidget:
              //         //                                           (context, url, error) =>
              //         //                                           Icon(Icons.error),
              //         //                                     ),
              //         //                                   ),
              //         //                                 ),
              //         //                               )),
              //         //
              //         //                               Expanded(flex: width<600?6:4,
              //         //                                   child:  Column(
              //         //                                     crossAxisAlignment: CrossAxisAlignment.start,
              //         //                                     mainAxisAlignment:
              //         //                                     // width>700?
              //         //                                     MainAxisAlignment.spaceAround,
              //         //                                     // :MainAxisAlignment.start,
              //         //                                     children: [
              //         //
              //         //                                       // SizedBox(height: width>750?0:10,),
              //         //                                       Container(
              //         //                                         // margin: EdgeInsets.only(top: 3),
              //         //                                         padding: EdgeInsets.all(7),
              //         //                                         decoration: BoxDecoration(
              //         //                                             color: Colors.purple,
              //         //                                             borderRadius: BorderRadius.circular(10)
              //         //                                         ),
              //         //                                         child: Text("Module 1",style: TextStyle(color: Colors.white,fontSize: 12),),
              //         //                                       ),
              //         //                                       // SizedBox(height: width>750?0:10,),
              //         //                                       // SizedBox(height: 8,),
              //         //                                       Column(
              //         //                                         mainAxisAlignment: MainAxisAlignment.start,
              //         //                                         crossAxisAlignment: CrossAxisAlignment.start,
              //         //                                         children: [
              //         //                                           Text(
              //         //                                             courseList[index].courseName,style:
              //         //                                           TextStyle(height: 1,fontWeight: FontWeight.bold,fontSize: width>700?25:width<540?15:16),
              //         //                                             overflow: TextOverflow.ellipsis,maxLines: 1,),
              //         //                                           SizedBox(height: 15,),
              //         //                                           // SizedBox(height: width>750?0:10,),
              //         //                                           Row(
              //         //                                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //         //                                             crossAxisAlignment: CrossAxisAlignment.start,
              //         //                                             children: [
              //         //                                               Expanded(child: Column(
              //         //                                                 crossAxisAlignment: CrossAxisAlignment.start,
              //         //                                                 mainAxisAlignment: MainAxisAlignment.start,
              //         //                                                 children: [
              //         //                                                   Text("Estimates learning time: ${courseList[index].duration==null?"0":courseList[index].duration} Hr",overflow: TextOverflow.ellipsis,style: TextStyle(fontSize:  width<540?width<420?11:13:14)),
              //         //                                                   SizedBox(height: 3,),
              //         //                                                   Text("Started on: Jan 01,2023",overflow: TextOverflow.ellipsis,style: TextStyle(fontSize:  width<540?width<420?11:13:14)),
              //         //                                                   SizedBox(height: 3,),
              //         //                                                   Text("Completed on: Jan 01,2023",overflow: TextOverflow.ellipsis,style: TextStyle(fontSize:  width<540?width<420?11:13:14)),
              //         //                                                   SizedBox(height: 15,),
              //         //                                                   SizedBox(
              //         //                                                     width: width<400?160:190,
              //         //                                                     child:
              //         //                                                     MaterialButton(
              //         //                                                       height: width>700?50:40,
              //         //                                                       shape: RoundedRectangleBorder(
              //         //                                                         borderRadius: BorderRadius.circular(20),
              //         //                                                       ),
              //         //                                                       padding: EdgeInsets.all(8),
              //         //                                                       minWidth: width>700?100:60,
              //         //                                                       onPressed: (){},
              //         //                                                       child: Row(
              //         //                                                         children: [
              //         //                                                           SizedBox(width: 5,),
              //         //                                                           Expanded(
              //         //                                                               flex:1,
              //         //                                                               child:
              //         //                                                               Icon(Icons.play_arrow,color: Colors.white,size: width<200?2:null,)),
              //         //                                                           Expanded(
              //         //                                                               flex:3,
              //         //                                                               child:
              //         //                                                               Text("Resume learning",style: TextStyle(color: Colors.white,fontSize: width<500?10:null),overflow: TextOverflow.ellipsis,))
              //         //                                                         ],
              //         //                                                       ),color: Colors.purple,),
              //         //                                                   )
              //         //
              //         //                                                 ],
              //         //                                               )),
              //         //                                               SizedBox(width: 5,),
              //         //                                               width<700?
              //         //                                               // Expanded(
              //         //                                               //   child:
              //         //                                               Column(
              //         //                                                 mainAxisAlignment: width>700?MainAxisAlignment.center:MainAxisAlignment.end,
              //         //                                                 children: [
              //         //                                                   SizedBox(height: 25,),
              //         //                                                   CircularPercentIndicator(
              //         //                                                     radius: width<700?width<500?20:30:70,
              //         //                                                     lineWidth: width>700?10.0:4.0,
              //         //                                                     animation: true,
              //         //                                                     percent: courseData!=null?courseData[widget.courses![index]+"percentage"]!=null?courseData[widget.courses![index]+"percentage"]/100:0/100:0,
              //         //                                                     center: courseData!=null?
              //         //                                                     courseData[widget.courses![index]+"percentage"]!=null?Text(
              //         //                                                       courseData[widget.courses![index]+"percentage"].toString()+ "%",
              //         //                                                       style: TextStyle(
              //         //                                                           fontSize: width>700?20.0:width<500?8:14,
              //         //                                                           fontWeight: FontWeight.w600,
              //         //                                                           color: Colors.black),
              //         //                                                     ):Text(
              //         //                                                       0.toString() + "%",
              //         //                                                       style: TextStyle(
              //         //                                                           fontSize: width>700?20.0:width<500?8:14,
              //         //                                                           fontWeight: FontWeight.w600,
              //         //                                                           color: Colors.black),
              //         //                                                     ):SizedBox(),
              //         //                                                     backgroundColor: Colors.black12,
              //         //                                                     circularStrokeCap: CircularStrokeCap.round,
              //         //                                                     progressColor: Colors.green,
              //         //                                                   ),
              //         //                                                   SizedBox(height: width<500?3:5,),
              //         //                                                   courseData!=null?
              //         //                                                   Text(
              //         //                                                     courseData[widget.courses![index]+"percentage"]!=null?courseData[widget.courses![index]+"percentage"].toString()+"%":"0%",style: TextStyle(fontSize: 7,fontWeight: FontWeight.bold),):SizedBox()
              //         //                                                   // SizedBox(height: 15,),
              //         //                                                   // Text("10%")
              //         //                                                 ],
              //         //                                               )
              //         //                                               // ,
              //         //                                               // )
              //         //                                                   :SizedBox(),
              //         //                                               SizedBox(width: 5,)
              //         //                                             ],
              //         //                                           ),
              //         //                                         ],
              //         //                                       )
              //         //                                     ],
              //         //                                   )),
              //         //                               // SizedBox(width: 10,),
              //         //                               width>700?Expanded(flex:2,
              //         //                                 // color: Colors.green,
              //         //                                 child: Column(
              //         //                                   mainAxisAlignment: width>700?MainAxisAlignment.center:MainAxisAlignment.end,
              //         //                                   children: [
              //         //                                     CircularPercentIndicator(
              //         //                                       radius: width>700?70.0:40.0,
              //         //                                       lineWidth: 10.0,
              //         //                                       animation: true,
              //         //                                       percent: courseData!=null?courseData[widget.courses![index]+"percentage"]!=null?courseData[widget.courses![index]+"percentage"]/100:0/100:0,
              //         //                                       center: courseData!=null?
              //         //                                       courseData[widget.courses![index]+"percentage"]!=null?Text(
              //         //                                         courseData[widget.courses![index]+"percentage"].toString() + "%",
              //         //                                         style: TextStyle(
              //         //                                             fontSize: 20.0,
              //         //                                             fontWeight: FontWeight.w600,
              //         //                                             color: Colors.black),
              //         //                                       ):Text(0.toString()+'%',style: TextStyle(
              //         //                                           fontSize: 20.0,
              //         //                                           fontWeight: FontWeight.w600,
              //         //                                           color: Colors.black)):SizedBox(),
              //         //                                       backgroundColor: Colors.black12,
              //         //                                       circularStrokeCap: CircularStrokeCap.round,
              //         //                                       progressColor: Colors.green,
              //         //                                     ),
              //         //                                     SizedBox(height: 15,),
              //         //                                     courseData!=null?Text(
              //         //                                         courseData[widget.courses![index]+"percentage"]!=null?courseData[widget.courses![index]+"percentage"].toString()+"%":"0%"):SizedBox()
              //         //                                   ],
              //         //                                 ),):
              //         //                               SizedBox()
              //         //                               // Column(
              //         //                               //   mainAxisAlignment: width>700?MainAxisAlignment.center:MainAxisAlignment.end,
              //         //                               //   children: [
              //         //                               //     CircularPercentIndicator(
              //         //                               //       radius: width>700?70.0:30.0,
              //         //                               //       lineWidth: width>700?10.0:5.0,
              //         //                               //       animation: true,
              //         //                               //       percent: 10/100,
              //         //                               //       center: Text(
              //         //                               //         10.toString() + "%",
              //         //                               //         style: TextStyle(
              //         //                               //             fontSize: width>700?20.0:14,
              //         //                               //             fontWeight: FontWeight.w600,
              //         //                               //             color: Colors.black),
              //         //                               //       ),
              //         //                               //       backgroundColor: Colors.black12,
              //         //                               //       circularStrokeCap: CircularStrokeCap.round,
              //         //                               //       progressColor: Colors.green,
              //         //                               //     ),
              //         //                               //     SizedBox(height: 15,),
              //         //                               //     Text("10%")
              //         //                               //   ],
              //         //                               // ),
              //         //                             ],
              //         //                           ),
              //         //                         ),
              //         //                       );
              //         //                   } else {
              //         //                     return Container();
              //         //                   }
              //         //                 },),
              //         //               );
              //         //             }
              //         //             else{
              //         //               return Container();
              //         //             }
              //         //
              //         //           })
              //         //     ],
              //         //   ),
              //         // )
              //       ],
              //     ),
              //
              //   ],
              // )
              ///
              // SingleChildScrollView(
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.center,
              //     children: [
              //       SizedBox(height: 10,),
              //       RichText(text: TextSpan(
              //           children: [
              //             TextSpan(text: "welcome to ",style: TextStyle(fontWeight: FontWeight.w200,fontSize: width<850?width<430?25:30:55,color: Colors.black)),
              //             TextSpan(text: "Data Science and \n Analytics Combo Course",style: TextStyle(fontSize: width<850?width<430?25:30:60,fontWeight: FontWeight.bold,color: Colors.black))
              //           ]
              //       ),textAlign: TextAlign.center,),
              //       SizedBox(height: 10,),
              //       StreamBuilder(
              //         stream: FirebaseFirestore.instance
              //             .collection('courses')
              //             .snapshots(),
              //           builder: (context,snapshot){
              //           if(snapshot.hasData)
              //             {
              //               return Column(
              //                 children: List.generate(widget.courses!.length, (index) => Container(
              //                   padding: EdgeInsets.all(8),
              //                   margin: EdgeInsets.only(bottom: 10),
              //                   width: width<1700?width<1300?width<850?constraints.maxWidth-20:constraints.maxWidth-200:constraints.maxWidth-400:constraints.maxWidth-700,
              //                   height: width>700?240:195,
              //                   decoration: BoxDecoration(
              //                       borderRadius: BorderRadius.circular(20),
              //                       color: Colors.white
              //                   ),
              //                   child: Row(
              //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //                     children: [
              //                       Expanded(flex:width<600?4:3,child: Padding(
              //                         padding: EdgeInsets.all(5),
              //                         child: Image.asset("assets/DATALY Logo.png"),
              //                       )),
              //
              //                       Expanded(flex: width<600?6:4,
              //                           child:  Column(
              //                             crossAxisAlignment: CrossAxisAlignment.start,
              //                             mainAxisAlignment:
              //                             // width>700?
              //                             MainAxisAlignment.spaceAround,
              //                             // :MainAxisAlignment.start,
              //                             children: [
              //
              //                               // SizedBox(height: width>750?0:10,),
              //                               Container(
              //                                 // margin: EdgeInsets.only(top: 3),
              //                                 padding: EdgeInsets.all(7),
              //                                 decoration: BoxDecoration(
              //                                     color: Colors.purple,
              //                                     borderRadius: BorderRadius.circular(10)
              //                                 ),
              //                                 child: Text("Module 1",style: TextStyle(color: Colors.white,fontSize: 12),),
              //                               ),
              //                               // SizedBox(height: width>750?0:10,),
              //                               // SizedBox(height: 8,),
              //                               Column(
              //                                 mainAxisAlignment: MainAxisAlignment.start,
              //                                 crossAxisAlignment: CrossAxisAlignment.start,
              //                                 children: [
              //                                   Text("Python for Data Science",style:
              //                                   TextStyle(height: 1,fontWeight: FontWeight.bold,fontSize: width>700?25:width<540?15:16),
              //                                     overflow: TextOverflow.ellipsis,maxLines: 2,),
              //                                   SizedBox(height: 15,),
              //                                   // SizedBox(height: width>750?0:10,),
              //                                   Row(
              //                                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //                                     crossAxisAlignment: CrossAxisAlignment.start,
              //                                     children: [
              //                                       Expanded(child: Column(
              //                                         crossAxisAlignment: CrossAxisAlignment.start,
              //                                         mainAxisAlignment: MainAxisAlignment.start,
              //                                         children: [
              //                                           Text("Estimates learning time: 10 Hr",overflow: TextOverflow.ellipsis,style: TextStyle(fontSize:  width<540?width<420?11:13:14)),
              //                                           SizedBox(height: 3,),
              //                                           Text("Started on: Jan 01,2023",overflow: TextOverflow.ellipsis,style: TextStyle(fontSize:  width<540?width<420?11:13:14)),
              //                                           SizedBox(height: 3,),
              //                                           Text("Completed on: Jan 01,2023",overflow: TextOverflow.ellipsis,style: TextStyle(fontSize:  width<540?width<420?11:13:14)),
              //                                           SizedBox(height: 15,),
              //                                           SizedBox(
              //                                             width: width<400?160:190,
              //                                             child:
              //                                             MaterialButton(
              //                                               height: width>700?50:40,
              //                                               shape: RoundedRectangleBorder(
              //                                                 borderRadius: BorderRadius.circular(20),
              //                                               ),
              //                                               padding: EdgeInsets.all(8),
              //                                               minWidth: width>700?100:60,
              //                                               onPressed: (){},
              //                                               child: Row(
              //                                                 children: [
              //                                                   SizedBox(width: 5,),
              //                                                   Expanded(
              //                                                       flex:1,
              //                                                       child:
              //                                                       Icon(Icons.play_arrow,color: Colors.white,size: width<200?2:null,)),
              //                                                   Expanded(
              //                                                       flex:3,
              //                                                       child:
              //                                                       Text("Resume learning",style: TextStyle(color: Colors.white,fontSize: width<500?10:null),overflow: TextOverflow.ellipsis,))
              //                                                 ],
              //                                               ),color: Colors.purple,),
              //                                           )
              //
              //                                         ],
              //                                       )),
              //                                       SizedBox(width: 5,),
              //                                       width<700?
              //                                       // Expanded(
              //                                       //   child:
              //                                       Column(
              //                                         mainAxisAlignment: width>700?MainAxisAlignment.center:MainAxisAlignment.end,
              //                                         children: [
              //                                           SizedBox(height: 25,),
              //                                           CircularPercentIndicator(
              //                                             radius: width<700?width<500?20:30:70,
              //                                             lineWidth: width>700?10.0:4.0,
              //                                             animation: true,
              //                                             percent: 10/100,
              //                                             center: Text(
              //                                               10.toString() + "%",
              //                                               style: TextStyle(
              //                                                   fontSize: width>700?20.0:width<500?8:14,
              //                                                   fontWeight: FontWeight.w600,
              //                                                   color: Colors.black),
              //                                             ),
              //                                             backgroundColor: Colors.black12,
              //                                             circularStrokeCap: CircularStrokeCap.round,
              //                                             progressColor: Colors.green,
              //                                           ),
              //                                           SizedBox(height: width<500?3:5,),
              //                                           Text("progress",style: TextStyle(fontSize: 7,fontWeight: FontWeight.bold),)
              //                                           // SizedBox(height: 15,),
              //                                           // Text("10%")
              //                                         ],
              //                                       )
              //                                       // ,
              //                                       // )
              //                                           :SizedBox(),
              //                                       SizedBox(width: 5,)
              //                                     ],
              //                                   ),
              //                                 ],
              //                               )
              //                             ],
              //                           )),
              //                       // SizedBox(width: 10,),
              //                       width>700?Expanded(flex:2,
              //                         // color: Colors.green,
              //                         child: Column(
              //                           mainAxisAlignment: width>700?MainAxisAlignment.center:MainAxisAlignment.end,
              //                           children: [
              //                             CircularPercentIndicator(
              //                               radius: width>700?70.0:40.0,
              //                               lineWidth: 10.0,
              //                               animation: true,
              //                               percent: 10/100,
              //                               center: Text(
              //                                 10.toString() + "%",
              //                                 style: TextStyle(
              //                                     fontSize: 20.0,
              //                                     fontWeight: FontWeight.w600,
              //                                     color: Colors.black),
              //                               ),
              //                               backgroundColor: Colors.black12,
              //                               circularStrokeCap: CircularStrokeCap.round,
              //                               progressColor: Colors.green,
              //                             ),
              //                             SizedBox(height: 15,),
              //                             Text("10%")
              //                           ],
              //                         ),):
              //                       SizedBox()
              //                       // Column(
              //                       //   mainAxisAlignment: width>700?MainAxisAlignment.center:MainAxisAlignment.end,
              //                       //   children: [
              //                       //     CircularPercentIndicator(
              //                       //       radius: width>700?70.0:30.0,
              //                       //       lineWidth: width>700?10.0:5.0,
              //                       //       animation: true,
              //                       //       percent: 10/100,
              //                       //       center: Text(
              //                       //         10.toString() + "%",
              //                       //         style: TextStyle(
              //                       //             fontSize: width>700?20.0:14,
              //                       //             fontWeight: FontWeight.w600,
              //                       //             color: Colors.black),
              //                       //       ),
              //                       //       backgroundColor: Colors.black12,
              //                       //       circularStrokeCap: CircularStrokeCap.round,
              //                       //       progressColor: Colors.green,
              //                       //     ),
              //                       //     SizedBox(height: 15,),
              //                       //     Text("10%")
              //                       //   ],
              //                       // ),
              //                     ],
              //                   ),
              //                 ),),
              //               );
              //             }
              //           else{
              //             return Container();
              //           }
              //
              //       }),
              //       // Container(
              //       //   padding: EdgeInsets.all(8),
              //       //   width: width<1700?width<1300?width<850?constraints.maxWidth-20:constraints.maxWidth-200:constraints.maxWidth-400:constraints.maxWidth-700,
              //       //   height: width>700?240:195,
              //       //   decoration: BoxDecoration(
              //       //       borderRadius: BorderRadius.circular(20),
              //       //       color: Colors.white
              //       //   ),
              //       //   child: Row(
              //       //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //       //     children: [
              //       //       Expanded(flex:width<600?4:3,child: Padding(
              //       //         padding: EdgeInsets.all(5),
              //       //         child: Image.asset("assets/DATALY Logo.png"),
              //       //       )),
              //       //
              //       //       Expanded(flex: width<600?6:4,
              //       //           child:  Column(
              //       //             crossAxisAlignment: CrossAxisAlignment.start,
              //       //             mainAxisAlignment:
              //       //             // width>700?
              //       //             MainAxisAlignment.spaceAround,
              //       //             // :MainAxisAlignment.start,
              //       //             children: [
              //       //
              //       //               // SizedBox(height: width>750?0:10,),
              //       //               Container(
              //       //                 // margin: EdgeInsets.only(top: 3),
              //       //                 padding: EdgeInsets.all(7),
              //       //                 decoration: BoxDecoration(
              //       //                     color: Colors.purple,
              //       //                     borderRadius: BorderRadius.circular(10)
              //       //                 ),
              //       //                 child: Text("Module 1",style: TextStyle(color: Colors.white,fontSize: 12),),
              //       //               ),
              //       //               // SizedBox(height: width>750?0:10,),
              //       //               // SizedBox(height: 8,),
              //       //               Column(
              //       //                 mainAxisAlignment: MainAxisAlignment.start,
              //       //                 crossAxisAlignment: CrossAxisAlignment.start,
              //       //                 children: [
              //       //                   Text("Python for Data Science",style:
              //       //                   TextStyle(height: 1,fontWeight: FontWeight.bold,fontSize: width>700?25:width<540?15:16),
              //       //                     overflow: TextOverflow.ellipsis,maxLines: 2,),
              //       //                   SizedBox(height: 15,),
              //       //                   // SizedBox(height: width>750?0:10,),
              //       //                   Row(
              //       //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //       //                     crossAxisAlignment: CrossAxisAlignment.start,
              //       //                     children: [
              //       //                       Expanded(child: Column(
              //       //                         crossAxisAlignment: CrossAxisAlignment.start,
              //       //                         mainAxisAlignment: MainAxisAlignment.start,
              //       //                         children: [
              //       //                           Text("Estimates learning time: 10 Hr",overflow: TextOverflow.ellipsis,style: TextStyle(fontSize:  width<540?width<420?11:13:14)),
              //       //                           SizedBox(height: 3,),
              //       //                           Text("Started on: Jan 01,2023",overflow: TextOverflow.ellipsis,style: TextStyle(fontSize:  width<540?width<420?11:13:14)),
              //       //                           SizedBox(height: 3,),
              //       //                           Text("Completed on: Jan 01,2023",overflow: TextOverflow.ellipsis,style: TextStyle(fontSize:  width<540?width<420?11:13:14)),
              //       //                           SizedBox(height: 15,),
              //       //                           SizedBox(
              //       //                             width: width<400?160:190,
              //       //                             child:
              //       //                             MaterialButton(
              //       //                               height: width>700?50:40,
              //       //                               shape: RoundedRectangleBorder(
              //       //                                 borderRadius: BorderRadius.circular(20),
              //       //                               ),
              //       //                               padding: EdgeInsets.all(8),
              //       //                               minWidth: width>700?100:60,
              //       //                               onPressed: (){},
              //       //                               child: Row(
              //       //                                 children: [
              //       //                                   SizedBox(width: 5,),
              //       //                                   Expanded(
              //       //                                       flex:1,
              //       //                                       child:
              //       //                                       Icon(Icons.play_arrow,color: Colors.white,size: width<200?2:null,)),
              //       //                                   Expanded(
              //       //                                       flex:3,
              //       //                                       child:
              //       //                                       Text("Resume learning",style: TextStyle(color: Colors.white,fontSize: width<500?10:null),overflow: TextOverflow.ellipsis,))
              //       //                                 ],
              //       //                               ),color: Colors.purple,),
              //       //                           )
              //       //
              //       //                         ],
              //       //                       )),
              //       //                       SizedBox(width: 5,),
              //       //                       width<700?
              //       //                       // Expanded(
              //       //                       //   child:
              //       //                       Column(
              //       //                         mainAxisAlignment: width>700?MainAxisAlignment.center:MainAxisAlignment.end,
              //       //                         children: [
              //       //                           SizedBox(height: 25,),
              //       //                           CircularPercentIndicator(
              //       //                             radius: width<700?width<500?20:30:70,
              //       //                             lineWidth: width>700?10.0:4.0,
              //       //                             animation: true,
              //       //                             percent: 10/100,
              //       //                             center: Text(
              //       //                               10.toString() + "%",
              //       //                               style: TextStyle(
              //       //                                   fontSize: width>700?20.0:width<500?8:14,
              //       //                                   fontWeight: FontWeight.w600,
              //       //                                   color: Colors.black),
              //       //                             ),
              //       //                             backgroundColor: Colors.black12,
              //       //                             circularStrokeCap: CircularStrokeCap.round,
              //       //                             progressColor: Colors.green,
              //       //                           ),
              //       //                           SizedBox(height: width<500?3:5,),
              //       //                           Text("progress",style: TextStyle(fontSize: 7,fontWeight: FontWeight.bold),)
              //       //                           // SizedBox(height: 15,),
              //       //                           // Text("10%")
              //       //                         ],
              //       //                       )
              //       //                       // ,
              //       //                       // )
              //       //                           :SizedBox(),
              //       //                       SizedBox(width: 5,)
              //       //                     ],
              //       //                   ),
              //       //                 ],
              //       //               )
              //       //             ],
              //       //           )),
              //       //       // SizedBox(width: 10,),
              //       //       width>700?Expanded(flex:2,
              //       //         // color: Colors.green,
              //       //         child: Column(
              //       //           mainAxisAlignment: width>700?MainAxisAlignment.center:MainAxisAlignment.end,
              //       //           children: [
              //       //             CircularPercentIndicator(
              //       //               radius: width>700?70.0:40.0,
              //       //               lineWidth: 10.0,
              //       //               animation: true,
              //       //               percent: 10/100,
              //       //               center: Text(
              //       //                 10.toString() + "%",
              //       //                 style: TextStyle(
              //       //                     fontSize: 20.0,
              //       //                     fontWeight: FontWeight.w600,
              //       //                     color: Colors.black),
              //       //               ),
              //       //               backgroundColor: Colors.black12,
              //       //               circularStrokeCap: CircularStrokeCap.round,
              //       //               progressColor: Colors.green,
              //       //             ),
              //       //             SizedBox(height: 15,),
              //       //             Text("10%")
              //       //           ],
              //       //         ),):
              //       //       SizedBox()
              //       //       // Column(
              //       //       //   mainAxisAlignment: width>700?MainAxisAlignment.center:MainAxisAlignment.end,
              //       //       //   children: [
              //       //       //     CircularPercentIndicator(
              //       //       //       radius: width>700?70.0:30.0,
              //       //       //       lineWidth: width>700?10.0:5.0,
              //       //       //       animation: true,
              //       //       //       percent: 10/100,
              //       //       //       center: Text(
              //       //       //         10.toString() + "%",
              //       //       //         style: TextStyle(
              //       //       //             fontSize: width>700?20.0:14,
              //       //       //             fontWeight: FontWeight.w600,
              //       //       //             color: Colors.black),
              //       //       //       ),
              //       //       //       backgroundColor: Colors.black12,
              //       //       //       circularStrokeCap: CircularStrokeCap.round,
              //       //       //       progressColor: Colors.green,
              //       //       //     ),
              //       //       //     SizedBox(height: 15,),
              //       //       //     Text("10%")
              //       //       //   ],
              //       //       // ),
              //       //     ],
              //       //   ),
              //       // ),
              //       // Container(
              //       //   padding: EdgeInsets.all(8),
              //       //   width: width<1700?width<1300?width<850?constraints.maxWidth-20:constraints.maxWidth-200:constraints.maxWidth-400:constraints.maxWidth-700,
              //       //   height: width>700?240:195,
              //       //   decoration: BoxDecoration(
              //       //       borderRadius: BorderRadius.circular(20),
              //       //       color: Colors.white
              //       //   ),
              //       //   child: Row(
              //       //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //       //     children: [
              //       //       Expanded(flex:width<600?4:3,child: Padding(
              //       //         padding: EdgeInsets.all(5),
              //       //         child: Image.asset("assets/DATALY Logo.png"),
              //       //       )),
              //       //
              //       //       Expanded(flex: width<600?6:4,
              //       //           child:  Column(
              //       //             crossAxisAlignment: CrossAxisAlignment.start,
              //       //             mainAxisAlignment:
              //       //             // width>700?
              //       //             MainAxisAlignment.spaceAround,
              //       //             // :MainAxisAlignment.start,
              //       //             children: [
              //       //
              //       //               // SizedBox(height: width>750?0:10,),
              //       //               Container(
              //       //                 // margin: EdgeInsets.only(top: 3),
              //       //                 padding: EdgeInsets.all(7),
              //       //                 decoration: BoxDecoration(
              //       //                     color: Colors.purple,
              //       //                     borderRadius: BorderRadius.circular(10)
              //       //                 ),
              //       //                 child: Text("Module 1",style: TextStyle(color: Colors.white,fontSize: 12),),
              //       //               ),
              //       //               // SizedBox(height: width>750?0:10,),
              //       //               // SizedBox(height: 8,),
              //       //               Column(
              //       //                 mainAxisAlignment: MainAxisAlignment.start,
              //       //                 crossAxisAlignment: CrossAxisAlignment.start,
              //       //                 children: [
              //       //                   Text("Python for Data Science",style:
              //       //                   TextStyle(height: 1,fontWeight: FontWeight.bold,fontSize: width>700?25:width<540?15:16),
              //       //                     overflow: TextOverflow.ellipsis,maxLines: 2,),
              //       //                   SizedBox(height: 15,),
              //       //                   // SizedBox(height: width>750?0:10,),
              //       //                   Row(
              //       //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //       //                     crossAxisAlignment: CrossAxisAlignment.start,
              //       //                     children: [
              //       //                       Expanded(child: Column(
              //       //                         crossAxisAlignment: CrossAxisAlignment.start,
              //       //                         mainAxisAlignment: MainAxisAlignment.start,
              //       //                         children: [
              //       //                           Text("Estimates learning time: 10 Hr",overflow: TextOverflow.ellipsis,style: TextStyle(fontSize:  width<540?width<420?11:13:14)),
              //       //                           SizedBox(height: 3,),
              //       //                           Text("Started on: Jan 01,2023",overflow: TextOverflow.ellipsis,style: TextStyle(fontSize:  width<540?width<420?11:13:14)),
              //       //                           SizedBox(height: 3,),
              //       //                           Text("Completed on: Jan 01,2023",overflow: TextOverflow.ellipsis,style: TextStyle(fontSize:  width<540?width<420?11:13:14)),
              //       //                           SizedBox(height: 15,),
              //       //                           SizedBox(
              //       //                             width: width<400?160:190,
              //       //                             child:
              //       //                             MaterialButton(
              //       //                               height: width>700?50:40,
              //       //                               shape: RoundedRectangleBorder(
              //       //                                 borderRadius: BorderRadius.circular(20),
              //       //                               ),
              //       //                               padding: EdgeInsets.all(8),
              //       //                               minWidth: width>700?100:60,
              //       //                               onPressed: (){},
              //       //                               child: Row(
              //       //                                 children: [
              //       //                                   SizedBox(width: 5,),
              //       //                                   Expanded(
              //       //                                       flex:1,
              //       //                                       child:
              //       //                                       Icon(Icons.play_arrow,color: Colors.white,size: width<200?2:null,)),
              //       //                                   Expanded(
              //       //                                       flex:3,
              //       //                                       child:
              //       //                                       Text("Resume learning",style: TextStyle(color: Colors.white,fontSize: width<500?10:null),overflow: TextOverflow.ellipsis,))
              //       //                                 ],
              //       //                               ),color: Colors.purple,),
              //       //                           )
              //       //
              //       //                         ],
              //       //                       )),
              //       //                       SizedBox(width: 5,),
              //       //                       width<700?
              //       //                       // Expanded(
              //       //                       //   child:
              //       //                       Column(
              //       //                         mainAxisAlignment: width>700?MainAxisAlignment.center:MainAxisAlignment.end,
              //       //                         children: [
              //       //                           SizedBox(height: 25,),
              //       //                           CircularPercentIndicator(
              //       //                             radius: width<700?width<500?20:30:70,
              //       //                             lineWidth: width>700?10.0:4.0,
              //       //                             animation: true,
              //       //                             percent: 10/100,
              //       //                             center: Text(
              //       //                               10.toString() + "%",
              //       //                               style: TextStyle(
              //       //                                   fontSize: width>700?20.0:width<500?8:14,
              //       //                                   fontWeight: FontWeight.w600,
              //       //                                   color: Colors.black),
              //       //                             ),
              //       //                             backgroundColor: Colors.black12,
              //       //                             circularStrokeCap: CircularStrokeCap.round,
              //       //                             progressColor: Colors.green,
              //       //                           ),
              //       //                           SizedBox(height: width<500?3:5,),
              //       //                           Text("progress",style: TextStyle(fontSize: 7,fontWeight: FontWeight.bold),)
              //       //                           // SizedBox(height: 15,),
              //       //                           // Text("10%")
              //       //                         ],
              //       //                       )
              //       //                       // ,
              //       //                       // )
              //       //                           :SizedBox(),
              //       //                       SizedBox(width: 5,)
              //       //                     ],
              //       //                   ),
              //       //                 ],
              //       //               )
              //       //             ],
              //       //           )),
              //       //       // SizedBox(width: 10,),
              //       //       width>700?Expanded(flex:2,
              //       //         // color: Colors.green,
              //       //         child: Column(
              //       //           mainAxisAlignment: width>700?MainAxisAlignment.center:MainAxisAlignment.end,
              //       //           children: [
              //       //             CircularPercentIndicator(
              //       //               radius: width>700?70.0:40.0,
              //       //               lineWidth: 10.0,
              //       //               animation: true,
              //       //               percent: 10/100,
              //       //               center: Text(
              //       //                 10.toString() + "%",
              //       //                 style: TextStyle(
              //       //                     fontSize: 20.0,
              //       //                     fontWeight: FontWeight.w600,
              //       //                     color: Colors.black),
              //       //               ),
              //       //               backgroundColor: Colors.black12,
              //       //               circularStrokeCap: CircularStrokeCap.round,
              //       //               progressColor: Colors.green,
              //       //             ),
              //       //             SizedBox(height: 15,),
              //       //             Text("10%")
              //       //           ],
              //       //         ),):
              //       //       SizedBox()
              //       //       // Column(
              //       //       //   mainAxisAlignment: width>700?MainAxisAlignment.center:MainAxisAlignment.end,
              //       //       //   children: [
              //       //       //     CircularPercentIndicator(
              //       //       //       radius: width>700?70.0:30.0,
              //       //       //       lineWidth: width>700?10.0:5.0,
              //       //       //       animation: true,
              //       //       //       percent: 10/100,
              //       //       //       center: Text(
              //       //       //         10.toString() + "%",
              //       //       //         style: TextStyle(
              //       //       //             fontSize: width>700?20.0:14,
              //       //       //             fontWeight: FontWeight.w600,
              //       //       //             color: Colors.black),
              //       //       //       ),
              //       //       //       backgroundColor: Colors.black12,
              //       //       //       circularStrokeCap: CircularStrokeCap.round,
              //       //       //       progressColor: Colors.green,
              //       //       //     ),
              //       //       //     SizedBox(height: 15,),
              //       //       //     Text("10%")
              //       //       //   ],
              //       //       // ),
              //       //     ],
              //       //   ),
              //       // ),
              //       // Container(
              //       //   padding: EdgeInsets.all(8),
              //       //   width: width<1700?width<1300?width<850?constraints.maxWidth-20:constraints.maxWidth-200:constraints.maxWidth-400:constraints.maxWidth-700,
              //       //   height: width>700?240:195,
              //       //   decoration: BoxDecoration(
              //       //       borderRadius: BorderRadius.circular(20),
              //       //       color: Colors.white
              //       //   ),
              //       //   child: Row(
              //       //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //       //     children: [
              //       //       Expanded(flex:width<600?4:3,child: Padding(
              //       //         padding: EdgeInsets.all(5),
              //       //         child: Image.asset("assets/DATALY Logo.png"),
              //       //       )),
              //       //
              //       //       Expanded(flex: width<600?6:4,
              //       //           child:  Column(
              //       //             crossAxisAlignment: CrossAxisAlignment.start,
              //       //             mainAxisAlignment:
              //       //             // width>700?
              //       //             MainAxisAlignment.spaceAround,
              //       //             // :MainAxisAlignment.start,
              //       //             children: [
              //       //
              //       //               // SizedBox(height: width>750?0:10,),
              //       //               Container(
              //       //                 // margin: EdgeInsets.only(top: 3),
              //       //                 padding: EdgeInsets.all(7),
              //       //                 decoration: BoxDecoration(
              //       //                     color: Colors.purple,
              //       //                     borderRadius: BorderRadius.circular(10)
              //       //                 ),
              //       //                 child: Text("Module 1",style: TextStyle(color: Colors.white,fontSize: 12),),
              //       //               ),
              //       //               // SizedBox(height: width>750?0:10,),
              //       //               // SizedBox(height: 8,),
              //       //               Column(
              //       //                 mainAxisAlignment: MainAxisAlignment.start,
              //       //                 crossAxisAlignment: CrossAxisAlignment.start,
              //       //                 children: [
              //       //                   Text("Python for Data Science",style:
              //       //                   TextStyle(height: 1,fontWeight: FontWeight.bold,fontSize: width>700?25:width<540?15:16),
              //       //                     overflow: TextOverflow.ellipsis,maxLines: 2,),
              //       //                   SizedBox(height: 15,),
              //       //                   // SizedBox(height: width>750?0:10,),
              //       //                   Row(
              //       //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //       //                     crossAxisAlignment: CrossAxisAlignment.start,
              //       //                     children: [
              //       //                       Expanded(child: Column(
              //       //                         crossAxisAlignment: CrossAxisAlignment.start,
              //       //                         mainAxisAlignment: MainAxisAlignment.start,
              //       //                         children: [
              //       //                           Text("Estimates learning time: 10 Hr",overflow: TextOverflow.ellipsis,style: TextStyle(fontSize:  width<540?width<420?11:13:14)),
              //       //                           SizedBox(height: 3,),
              //       //                           Text("Started on: Jan 01,2023",overflow: TextOverflow.ellipsis,style: TextStyle(fontSize:  width<540?width<420?11:13:14)),
              //       //                           SizedBox(height: 3,),
              //       //                           Text("Completed on: Jan 01,2023",overflow: TextOverflow.ellipsis,style: TextStyle(fontSize:  width<540?width<420?11:13:14)),
              //       //                           SizedBox(height: 15,),
              //       //                           SizedBox(
              //       //                             width: width<400?160:190,
              //       //                             child:
              //       //                             MaterialButton(
              //       //                               height: width>700?50:40,
              //       //                               shape: RoundedRectangleBorder(
              //       //                                 borderRadius: BorderRadius.circular(20),
              //       //                               ),
              //       //                               padding: EdgeInsets.all(8),
              //       //                               minWidth: width>700?100:60,
              //       //                               onPressed: (){},
              //       //                               child: Row(
              //       //                                 children: [
              //       //                                   SizedBox(width: 5,),
              //       //                                   Expanded(
              //       //                                       flex:1,
              //       //                                       child:
              //       //                                       Icon(Icons.play_arrow,color: Colors.white,size: width<200?2:null,)),
              //       //                                   Expanded(
              //       //                                       flex:3,
              //       //                                       child:
              //       //                                       Text("Resume learning",style: TextStyle(color: Colors.white,fontSize: width<500?10:null),overflow: TextOverflow.ellipsis,))
              //       //                                 ],
              //       //                               ),color: Colors.purple,),
              //       //                           )
              //       //
              //       //                         ],
              //       //                       )),
              //       //                       SizedBox(width: 5,),
              //       //                       width<700?
              //       //                       // Expanded(
              //       //                       //   child:
              //       //                       Column(
              //       //                         mainAxisAlignment: width>700?MainAxisAlignment.center:MainAxisAlignment.end,
              //       //                         children: [
              //       //                           SizedBox(height: 25,),
              //       //                           CircularPercentIndicator(
              //       //                             radius: width<700?width<500?20:30:70,
              //       //                             lineWidth: width>700?10.0:4.0,
              //       //                             animation: true,
              //       //                             percent: 10/100,
              //       //                             center: Text(
              //       //                               10.toString() + "%",
              //       //                               style: TextStyle(
              //       //                                   fontSize: width>700?20.0:width<500?8:14,
              //       //                                   fontWeight: FontWeight.w600,
              //       //                                   color: Colors.black),
              //       //                             ),
              //       //                             backgroundColor: Colors.black12,
              //       //                             circularStrokeCap: CircularStrokeCap.round,
              //       //                             progressColor: Colors.green,
              //       //                           ),
              //       //                           SizedBox(height: width<500?3:5,),
              //       //                           Text("progress",style: TextStyle(fontSize: 7,fontWeight: FontWeight.bold),)
              //       //                           // SizedBox(height: 15,),
              //       //                           // Text("10%")
              //       //                         ],
              //       //                       )
              //       //                       // ,
              //       //                       // )
              //       //                           :SizedBox(),
              //       //                       SizedBox(width: 5,)
              //       //                     ],
              //       //                   ),
              //       //                 ],
              //       //               )
              //       //             ],
              //       //           )),
              //       //       // SizedBox(width: 10,),
              //       //       width>700?Expanded(flex:2,
              //       //         // color: Colors.green,
              //       //         child: Column(
              //       //           mainAxisAlignment: width>700?MainAxisAlignment.center:MainAxisAlignment.end,
              //       //           children: [
              //       //             CircularPercentIndicator(
              //       //               radius: width>700?70.0:40.0,
              //       //               lineWidth: 10.0,
              //       //               animation: true,
              //       //               percent: 10/100,
              //       //               center: Text(
              //       //                 10.toString() + "%",
              //       //                 style: TextStyle(
              //       //                     fontSize: 20.0,
              //       //                     fontWeight: FontWeight.w600,
              //       //                     color: Colors.black),
              //       //               ),
              //       //               backgroundColor: Colors.black12,
              //       //               circularStrokeCap: CircularStrokeCap.round,
              //       //               progressColor: Colors.green,
              //       //             ),
              //       //             SizedBox(height: 15,),
              //       //             Text("10%")
              //       //           ],
              //       //         ),):
              //       //       SizedBox()
              //       //       // Column(
              //       //       //   mainAxisAlignment: width>700?MainAxisAlignment.center:MainAxisAlignment.end,
              //       //       //   children: [
              //       //       //     CircularPercentIndicator(
              //       //       //       radius: width>700?70.0:30.0,
              //       //       //       lineWidth: width>700?10.0:5.0,
              //       //       //       animation: true,
              //       //       //       percent: 10/100,
              //       //       //       center: Text(
              //       //       //         10.toString() + "%",
              //       //       //         style: TextStyle(
              //       //       //             fontSize: width>700?20.0:14,
              //       //       //             fontWeight: FontWeight.w600,
              //       //       //             color: Colors.black),
              //       //       //       ),
              //       //       //       backgroundColor: Colors.black12,
              //       //       //       circularStrokeCap: CircularStrokeCap.round,
              //       //       //       progressColor: Colors.green,
              //       //       //     ),
              //       //       //     SizedBox(height: 15,),
              //       //       //     Text("10%")
              //       //       //   ],
              //       //       // ),
              //       //     ],
              //       //   ),
              //       // ),
              //       // Container(
              //       //   padding: EdgeInsets.all(8),
              //       //   width: width<1700?width<1300?width<850?constraints.maxWidth-20:constraints.maxWidth-200:constraints.maxWidth-400:constraints.maxWidth-700,
              //       //   height: width>700?240:195,
              //       //   decoration: BoxDecoration(
              //       //       borderRadius: BorderRadius.circular(20),
              //       //       color: Colors.white
              //       //   ),
              //       //   child: Row(
              //       //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //       //     children: [
              //       //       Expanded(flex:width<600?4:3,child: Padding(
              //       //         padding: EdgeInsets.all(5),
              //       //         child: Image.asset("assets/DATALY Logo.png"),
              //       //       )),
              //       //
              //       //       Expanded(flex: width<600?6:4,
              //       //           child:  Column(
              //       //             crossAxisAlignment: CrossAxisAlignment.start,
              //       //             mainAxisAlignment:
              //       //             // width>700?
              //       //             MainAxisAlignment.spaceAround,
              //       //             // :MainAxisAlignment.start,
              //       //             children: [
              //       //
              //       //               // SizedBox(height: width>750?0:10,),
              //       //               Container(
              //       //                 // margin: EdgeInsets.only(top: 3),
              //       //                 padding: EdgeInsets.all(7),
              //       //                 decoration: BoxDecoration(
              //       //                     color: Colors.purple,
              //       //                     borderRadius: BorderRadius.circular(10)
              //       //                 ),
              //       //                 child: Text("Module 1",style: TextStyle(color: Colors.white,fontSize: 12),),
              //       //               ),
              //       //               // SizedBox(height: width>750?0:10,),
              //       //               // SizedBox(height: 8,),
              //       //               Column(
              //       //                 mainAxisAlignment: MainAxisAlignment.start,
              //       //                 crossAxisAlignment: CrossAxisAlignment.start,
              //       //                 children: [
              //       //                   Text("Python for Data Science",style:
              //       //                   TextStyle(height: 1,fontWeight: FontWeight.bold,fontSize: width>700?25:width<540?15:16),
              //       //                     overflow: TextOverflow.ellipsis,maxLines: 2,),
              //       //                   SizedBox(height: 15,),
              //       //                   // SizedBox(height: width>750?0:10,),
              //       //                   Row(
              //       //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //       //                     crossAxisAlignment: CrossAxisAlignment.start,
              //       //                     children: [
              //       //                       Expanded(child: Column(
              //       //                         crossAxisAlignment: CrossAxisAlignment.start,
              //       //                         mainAxisAlignment: MainAxisAlignment.start,
              //       //                         children: [
              //       //                           Text("Estimates learning time: 10 Hr",overflow: TextOverflow.ellipsis,style: TextStyle(fontSize:  width<540?width<420?11:13:14)),
              //       //                           SizedBox(height: 3,),
              //       //                           Text("Started on: Jan 01,2023",overflow: TextOverflow.ellipsis,style: TextStyle(fontSize:  width<540?width<420?11:13:14)),
              //       //                           SizedBox(height: 3,),
              //       //                           Text("Completed on: Jan 01,2023",overflow: TextOverflow.ellipsis,style: TextStyle(fontSize:  width<540?width<420?11:13:14)),
              //       //                           SizedBox(height: 15,),
              //       //                           SizedBox(
              //       //                             width: width<400?160:190,
              //       //                             child:
              //       //                             MaterialButton(
              //       //                               height: width>700?50:40,
              //       //                               shape: RoundedRectangleBorder(
              //       //                                 borderRadius: BorderRadius.circular(20),
              //       //                               ),
              //       //                               padding: EdgeInsets.all(8),
              //       //                               minWidth: width>700?100:60,
              //       //                               onPressed: (){},
              //       //                               child: Row(
              //       //                                 children: [
              //       //                                   SizedBox(width: 5,),
              //       //                                   Expanded(
              //       //                                       flex:1,
              //       //                                       child:
              //       //                                       Icon(Icons.play_arrow,color: Colors.white,size: width<200?2:null,)),
              //       //                                   Expanded(
              //       //                                       flex:3,
              //       //                                       child:
              //       //                                       Text("Resume learning",style: TextStyle(color: Colors.white,fontSize: width<500?10:null),overflow: TextOverflow.ellipsis,))
              //       //                                 ],
              //       //                               ),color: Colors.purple,),
              //       //                           )
              //       //
              //       //                         ],
              //       //                       )),
              //       //                       SizedBox(width: 5,),
              //       //                       width<700?
              //       //                       // Expanded(
              //       //                       //   child:
              //       //                       Column(
              //       //                         mainAxisAlignment: width>700?MainAxisAlignment.center:MainAxisAlignment.end,
              //       //                         children: [
              //       //                           SizedBox(height: 25,),
              //       //                           CircularPercentIndicator(
              //       //                             radius: width<700?width<500?20:30:70,
              //       //                             lineWidth: width>700?10.0:4.0,
              //       //                             animation: true,
              //       //                             percent: 10/100,
              //       //                             center: Text(
              //       //                               10.toString() + "%",
              //       //                               style: TextStyle(
              //       //                                   fontSize: width>700?20.0:width<500?8:14,
              //       //                                   fontWeight: FontWeight.w600,
              //       //                                   color: Colors.black),
              //       //                             ),
              //       //                             backgroundColor: Colors.black12,
              //       //                             circularStrokeCap: CircularStrokeCap.round,
              //       //                             progressColor: Colors.green,
              //       //                           ),
              //       //                           SizedBox(height: width<500?3:5,),
              //       //                           Text("progress",style: TextStyle(fontSize: 7,fontWeight: FontWeight.bold),)
              //       //                           // SizedBox(height: 15,),
              //       //                           // Text("10%")
              //       //                         ],
              //       //                       )
              //       //                       // ,
              //       //                       // )
              //       //                           :SizedBox(),
              //       //                       SizedBox(width: 5,)
              //       //                     ],
              //       //                   ),
              //       //                 ],
              //       //               )
              //       //             ],
              //       //           )),
              //       //       // SizedBox(width: 10,),
              //       //       width>700?Expanded(flex:2,
              //       //         // color: Colors.green,
              //       //         child: Column(
              //       //           mainAxisAlignment: width>700?MainAxisAlignment.center:MainAxisAlignment.end,
              //       //           children: [
              //       //             CircularPercentIndicator(
              //       //               radius: width>700?70.0:40.0,
              //       //               lineWidth: 10.0,
              //       //               animation: true,
              //       //               percent: 10/100,
              //       //               center: Text(
              //       //                 10.toString() + "%",
              //       //                 style: TextStyle(
              //       //                     fontSize: 20.0,
              //       //                     fontWeight: FontWeight.w600,
              //       //                     color: Colors.black),
              //       //               ),
              //       //               backgroundColor: Colors.black12,
              //       //               circularStrokeCap: CircularStrokeCap.round,
              //       //               progressColor: Colors.green,
              //       //             ),
              //       //             SizedBox(height: 15,),
              //       //             Text("10%")
              //       //           ],
              //       //         ),):
              //       //       SizedBox()
              //       //       // Column(
              //       //       //   mainAxisAlignment: width>700?MainAxisAlignment.center:MainAxisAlignment.end,
              //       //       //   children: [
              //       //       //     CircularPercentIndicator(
              //       //       //       radius: width>700?70.0:30.0,
              //       //       //       lineWidth: width>700?10.0:5.0,
              //       //       //       animation: true,
              //       //       //       percent: 10/100,
              //       //       //       center: Text(
              //       //       //         10.toString() + "%",
              //       //       //         style: TextStyle(
              //       //       //             fontSize: width>700?20.0:14,
              //       //       //             fontWeight: FontWeight.w600,
              //       //       //             color: Colors.black),
              //       //       //       ),
              //       //       //       backgroundColor: Colors.black12,
              //       //       //       circularStrokeCap: CircularStrokeCap.round,
              //       //       //       progressColor: Colors.green,
              //       //       //     ),
              //       //       //     SizedBox(height: 15,),
              //       //       //     Text("10%")
              //       //       //   ],
              //       //       // ),
              //       //     ],
              //       //   ),
              //       // ),
              //       // Container(
              //       //   padding: EdgeInsets.all(8),
              //       //   width: width<1700?width<1300?width<850?constraints.maxWidth-20:constraints.maxWidth-200:constraints.maxWidth-400:constraints.maxWidth-700,
              //       //   height: width>700?240:195,
              //       //   decoration: BoxDecoration(
              //       //       borderRadius: BorderRadius.circular(20),
              //       //       color: Colors.white
              //       //   ),
              //       //   child: Row(
              //       //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //       //     children: [
              //       //       Expanded(flex:width<600?4:3,child: Padding(
              //       //         padding: EdgeInsets.all(5),
              //       //         child: Image.asset("assets/DATALY Logo.png"),
              //       //       )),
              //       //
              //       //       Expanded(flex: width<600?6:4,
              //       //           child:  Column(
              //       //             crossAxisAlignment: CrossAxisAlignment.start,
              //       //             mainAxisAlignment:
              //       //             // width>700?
              //       //             MainAxisAlignment.spaceAround,
              //       //             // :MainAxisAlignment.start,
              //       //             children: [
              //       //
              //       //               // SizedBox(height: width>750?0:10,),
              //       //               Container(
              //       //                 // margin: EdgeInsets.only(top: 3),
              //       //                 padding: EdgeInsets.all(7),
              //       //                 decoration: BoxDecoration(
              //       //                     color: Colors.purple,
              //       //                     borderRadius: BorderRadius.circular(10)
              //       //                 ),
              //       //                 child: Text("Module 1",style: TextStyle(color: Colors.white,fontSize: 12),),
              //       //               ),
              //       //               // SizedBox(height: width>750?0:10,),
              //       //               // SizedBox(height: 8,),
              //       //               Column(
              //       //                 mainAxisAlignment: MainAxisAlignment.start,
              //       //                 crossAxisAlignment: CrossAxisAlignment.start,
              //       //                 children: [
              //       //                   Text("Python for Data Science",style:
              //       //                   TextStyle(height: 1,fontWeight: FontWeight.bold,fontSize: width>700?25:width<540?15:16),
              //       //                     overflow: TextOverflow.ellipsis,maxLines: 2,),
              //       //                   SizedBox(height: 15,),
              //       //                   // SizedBox(height: width>750?0:10,),
              //       //                   Row(
              //       //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //       //                     crossAxisAlignment: CrossAxisAlignment.start,
              //       //                     children: [
              //       //                       Expanded(child: Column(
              //       //                         crossAxisAlignment: CrossAxisAlignment.start,
              //       //                         mainAxisAlignment: MainAxisAlignment.start,
              //       //                         children: [
              //       //                           Text("Estimates learning time: 10 Hr",overflow: TextOverflow.ellipsis,style: TextStyle(fontSize:  width<540?width<420?11:13:14)),
              //       //                           SizedBox(height: 3,),
              //       //                           Text("Started on: Jan 01,2023",overflow: TextOverflow.ellipsis,style: TextStyle(fontSize:  width<540?width<420?11:13:14)),
              //       //                           SizedBox(height: 3,),
              //       //                           Text("Completed on: Jan 01,2023",overflow: TextOverflow.ellipsis,style: TextStyle(fontSize:  width<540?width<420?11:13:14)),
              //       //                           SizedBox(height: 15,),
              //       //                           SizedBox(
              //       //                             width: width<400?160:190,
              //       //                             child:
              //       //                             MaterialButton(
              //       //                               height: width>700?50:40,
              //       //                               shape: RoundedRectangleBorder(
              //       //                                 borderRadius: BorderRadius.circular(20),
              //       //                               ),
              //       //                               padding: EdgeInsets.all(8),
              //       //                               minWidth: width>700?100:60,
              //       //                               onPressed: (){},
              //       //                               child: Row(
              //       //                                 children: [
              //       //                                   SizedBox(width: 5,),
              //       //                                   Expanded(
              //       //                                       flex:1,
              //       //                                       child:
              //       //                                       Icon(Icons.play_arrow,color: Colors.white,size: width<200?2:null,)),
              //       //                                   Expanded(
              //       //                                       flex:3,
              //       //                                       child:
              //       //                                       Text("Resume learning",style: TextStyle(color: Colors.white,fontSize: width<500?10:null),overflow: TextOverflow.ellipsis,))
              //       //                                 ],
              //       //                               ),color: Colors.purple,),
              //       //                           )
              //       //
              //       //                         ],
              //       //                       )),
              //       //                       SizedBox(width: 5,),
              //       //                       width<700?
              //       //                       // Expanded(
              //       //                       //   child:
              //       //                       Column(
              //       //                         mainAxisAlignment: width>700?MainAxisAlignment.center:MainAxisAlignment.end,
              //       //                         children: [
              //       //                           SizedBox(height: 25,),
              //       //                           CircularPercentIndicator(
              //       //                             radius: width<700?width<500?20:30:70,
              //       //                             lineWidth: width>700?10.0:4.0,
              //       //                             animation: true,
              //       //                             percent: 10/100,
              //       //                             center: Text(
              //       //                               10.toString() + "%",
              //       //                               style: TextStyle(
              //       //                                   fontSize: width>700?20.0:width<500?8:14,
              //       //                                   fontWeight: FontWeight.w600,
              //       //                                   color: Colors.black),
              //       //                             ),
              //       //                             backgroundColor: Colors.black12,
              //       //                             circularStrokeCap: CircularStrokeCap.round,
              //       //                             progressColor: Colors.green,
              //       //                           ),
              //       //                           SizedBox(height: width<500?3:5,),
              //       //                           Text("progress",style: TextStyle(fontSize: 7,fontWeight: FontWeight.bold),)
              //       //                           // SizedBox(height: 15,),
              //       //                           // Text("10%")
              //       //                         ],
              //       //                       )
              //       //                       // ,
              //       //                       // )
              //       //                           :SizedBox(),
              //       //                       SizedBox(width: 5,)
              //       //                     ],
              //       //                   ),
              //       //                 ],
              //       //               )
              //       //             ],
              //       //           )),
              //       //       // SizedBox(width: 10,),
              //       //       width>700?Expanded(flex:2,
              //       //         // color: Colors.green,
              //       //         child: Column(
              //       //           mainAxisAlignment: width>700?MainAxisAlignment.center:MainAxisAlignment.end,
              //       //           children: [
              //       //             CircularPercentIndicator(
              //       //               radius: width>700?70.0:40.0,
              //       //               lineWidth: 10.0,
              //       //               animation: true,
              //       //               percent: 10/100,
              //       //               center: Text(
              //       //                 10.toString() + "%",
              //       //                 style: TextStyle(
              //       //                     fontSize: 20.0,
              //       //                     fontWeight: FontWeight.w600,
              //       //                     color: Colors.black),
              //       //               ),
              //       //               backgroundColor: Colors.black12,
              //       //               circularStrokeCap: CircularStrokeCap.round,
              //       //               progressColor: Colors.green,
              //       //             ),
              //       //             SizedBox(height: 15,),
              //       //             Text("10%")
              //       //           ],
              //       //         ),):
              //       //       SizedBox()
              //       //       // Column(
              //       //       //   mainAxisAlignment: width>700?MainAxisAlignment.center:MainAxisAlignment.end,
              //       //       //   children: [
              //       //       //     CircularPercentIndicator(
              //       //       //       radius: width>700?70.0:30.0,
              //       //       //       lineWidth: width>700?10.0:5.0,
              //       //       //       animation: true,
              //       //       //       percent: 10/100,
              //       //       //       center: Text(
              //       //       //         10.toString() + "%",
              //       //       //         style: TextStyle(
              //       //       //             fontSize: width>700?20.0:14,
              //       //       //             fontWeight: FontWeight.w600,
              //       //       //             color: Colors.black),
              //       //       //       ),
              //       //       //       backgroundColor: Colors.black12,
              //       //       //       circularStrokeCap: CircularStrokeCap.round,
              //       //       //       progressColor: Colors.green,
              //       //       //     ),
              //       //       //     SizedBox(height: 15,),
              //       //       //     Text("10%")
              //       //       //   ],
              //       //       // ),
              //       //     ],
              //       //   ),
              //       // ),
              //       // Container(
              //       //   padding: EdgeInsets.all(8),
              //       //   width: width<1700?width<1300?width<850?constraints.maxWidth-20:constraints.maxWidth-200:constraints.maxWidth-400:constraints.maxWidth-700,
              //       //   height: width>700?240:195,
              //       //   decoration: BoxDecoration(
              //       //       borderRadius: BorderRadius.circular(20),
              //       //       color: Colors.white
              //       //   ),
              //       //   child: Row(
              //       //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //       //     children: [
              //       //       Expanded(flex:width<600?4:3,child: Padding(
              //       //         padding: EdgeInsets.all(5),
              //       //         child: Image.asset("assets/DATALY Logo.png"),
              //       //       )),
              //       //
              //       //       Expanded(flex: width<600?6:4,
              //       //           child:  Column(
              //       //             crossAxisAlignment: CrossAxisAlignment.start,
              //       //             mainAxisAlignment:
              //       //             // width>700?
              //       //             MainAxisAlignment.spaceAround,
              //       //             // :MainAxisAlignment.start,
              //       //             children: [
              //       //
              //       //               // SizedBox(height: width>750?0:10,),
              //       //               Container(
              //       //                 // margin: EdgeInsets.only(top: 3),
              //       //                 padding: EdgeInsets.all(7),
              //       //                 decoration: BoxDecoration(
              //       //                     color: Colors.purple,
              //       //                     borderRadius: BorderRadius.circular(10)
              //       //                 ),
              //       //                 child: Text("Module 1",style: TextStyle(color: Colors.white,fontSize: 12),),
              //       //               ),
              //       //               // SizedBox(height: width>750?0:10,),
              //       //               // SizedBox(height: 8,),
              //       //               Column(
              //       //                 mainAxisAlignment: MainAxisAlignment.start,
              //       //                 crossAxisAlignment: CrossAxisAlignment.start,
              //       //                 children: [
              //       //                   Text("Python for Data Science",style:
              //       //                   TextStyle(height: 1,fontWeight: FontWeight.bold,fontSize: width>700?25:width<540?15:16),
              //       //                     overflow: TextOverflow.ellipsis,maxLines: 2,),
              //       //                   SizedBox(height: 15,),
              //       //                   // SizedBox(height: width>750?0:10,),
              //       //                   Row(
              //       //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //       //                     crossAxisAlignment: CrossAxisAlignment.start,
              //       //                     children: [
              //       //                       Expanded(child: Column(
              //       //                         crossAxisAlignment: CrossAxisAlignment.start,
              //       //                         mainAxisAlignment: MainAxisAlignment.start,
              //       //                         children: [
              //       //                           Text("Estimates learning time: 10 Hr",overflow: TextOverflow.ellipsis,style: TextStyle(fontSize:  width<540?width<420?11:13:14)),
              //       //                           SizedBox(height: 3,),
              //       //                           Text("Started on: Jan 01,2023",overflow: TextOverflow.ellipsis,style: TextStyle(fontSize:  width<540?width<420?11:13:14)),
              //       //                           SizedBox(height: 3,),
              //       //                           Text("Completed on: Jan 01,2023",overflow: TextOverflow.ellipsis,style: TextStyle(fontSize:  width<540?width<420?11:13:14)),
              //       //                           SizedBox(height: 15,),
              //       //                           SizedBox(
              //       //                             width: width<400?160:190,
              //       //                             child:
              //       //                             MaterialButton(
              //       //                               height: width>700?50:40,
              //       //                               shape: RoundedRectangleBorder(
              //       //                                 borderRadius: BorderRadius.circular(20),
              //       //                               ),
              //       //                               padding: EdgeInsets.all(8),
              //       //                               minWidth: width>700?100:60,
              //       //                               onPressed: (){},
              //       //                               child: Row(
              //       //                                 children: [
              //       //                                   SizedBox(width: 5,),
              //       //                                   Expanded(
              //       //                                       flex:1,
              //       //                                       child:
              //       //                                       Icon(Icons.play_arrow,color: Colors.white,size: width<200?2:null,)),
              //       //                                   Expanded(
              //       //                                       flex:3,
              //       //                                       child:
              //       //                                       Text("Resume learning",style: TextStyle(color: Colors.white,fontSize: width<500?10:null),overflow: TextOverflow.ellipsis,))
              //       //                                 ],
              //       //                               ),color: Colors.purple,),
              //       //                           )
              //       //
              //       //                         ],
              //       //                       )),
              //       //                       SizedBox(width: 5,),
              //       //                       width<700?
              //       //                       // Expanded(
              //       //                       //   child:
              //       //                       Column(
              //       //                         mainAxisAlignment: width>700?MainAxisAlignment.center:MainAxisAlignment.end,
              //       //                         children: [
              //       //                           SizedBox(height: 25,),
              //       //                           CircularPercentIndicator(
              //       //                             radius: width<700?width<500?20:30:70,
              //       //                             lineWidth: width>700?10.0:4.0,
              //       //                             animation: true,
              //       //                             percent: 10/100,
              //       //                             center: Text(
              //       //                               10.toString() + "%",
              //       //                               style: TextStyle(
              //       //                                   fontSize: width>700?20.0:width<500?8:14,
              //       //                                   fontWeight: FontWeight.w600,
              //       //                                   color: Colors.black),
              //       //                             ),
              //       //                             backgroundColor: Colors.black12,
              //       //                             circularStrokeCap: CircularStrokeCap.round,
              //       //                             progressColor: Colors.green,
              //       //                           ),
              //       //                           SizedBox(height: width<500?3:5,),
              //       //                           Text("progress",style: TextStyle(fontSize: 7,fontWeight: FontWeight.bold),)
              //       //                           // SizedBox(height: 15,),
              //       //                           // Text("10%")
              //       //                         ],
              //       //                       )
              //       //                       // ,
              //       //                       // )
              //       //                           :SizedBox(),
              //       //                       SizedBox(width: 5,)
              //       //                     ],
              //       //                   ),
              //       //                 ],
              //       //               )
              //       //             ],
              //       //           )),
              //       //       // SizedBox(width: 10,),
              //       //       width>700?Expanded(flex:2,
              //       //         // color: Colors.green,
              //       //         child: Column(
              //       //           mainAxisAlignment: width>700?MainAxisAlignment.center:MainAxisAlignment.end,
              //       //           children: [
              //       //             CircularPercentIndicator(
              //       //               radius: width>700?70.0:40.0,
              //       //               lineWidth: 10.0,
              //       //               animation: true,
              //       //               percent: 10/100,
              //       //               center: Text(
              //       //                 10.toString() + "%",
              //       //                 style: TextStyle(
              //       //                     fontSize: 20.0,
              //       //                     fontWeight: FontWeight.w600,
              //       //                     color: Colors.black),
              //       //               ),
              //       //               backgroundColor: Colors.black12,
              //       //               circularStrokeCap: CircularStrokeCap.round,
              //       //               progressColor: Colors.green,
              //       //             ),
              //       //             SizedBox(height: 15,),
              //       //             Text("10%")
              //       //           ],
              //       //         ),):
              //       //       SizedBox()
              //       //       // Column(
              //       //       //   mainAxisAlignment: width>700?MainAxisAlignment.center:MainAxisAlignment.end,
              //       //       //   children: [
              //       //       //     CircularPercentIndicator(
              //       //       //       radius: width>700?70.0:30.0,
              //       //       //       lineWidth: width>700?10.0:5.0,
              //       //       //       animation: true,
              //       //       //       percent: 10/100,
              //       //       //       center: Text(
              //       //       //         10.toString() + "%",
              //       //       //         style: TextStyle(
              //       //       //             fontSize: width>700?20.0:14,
              //       //       //             fontWeight: FontWeight.w600,
              //       //       //             color: Colors.black),
              //       //       //       ),
              //       //       //       backgroundColor: Colors.black12,
              //       //       //       circularStrokeCap: CircularStrokeCap.round,
              //       //       //       progressColor: Colors.green,
              //       //       //     ),
              //       //       //     SizedBox(height: 15,),
              //       //       //     Text("10%")
              //       //       //   ],
              //       //       // ),
              //       //     ],
              //       //   ),
              //       // ),
              //       // Container(
              //       //   padding: EdgeInsets.all(8),
              //       //   width: width<1700?width<1300?width<850?constraints.maxWidth-20:constraints.maxWidth-200:constraints.maxWidth-400:constraints.maxWidth-700,
              //       //   height: width>700?240:195,
              //       //   decoration: BoxDecoration(
              //       //       borderRadius: BorderRadius.circular(20),
              //       //       color: Colors.white
              //       //   ),
              //       //   child: Row(
              //       //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //       //     children: [
              //       //       Expanded(flex:width<600?4:3,child: Padding(
              //       //         padding: EdgeInsets.all(5),
              //       //         child: Image.asset("assets/DATALY Logo.png"),
              //       //       )),
              //       //
              //       //       Expanded(flex: width<600?6:4,
              //       //           child:  Column(
              //       //             crossAxisAlignment: CrossAxisAlignment.start,
              //       //             mainAxisAlignment:
              //       //             // width>700?
              //       //             MainAxisAlignment.spaceAround,
              //       //             // :MainAxisAlignment.start,
              //       //             children: [
              //       //
              //       //               // SizedBox(height: width>750?0:10,),
              //       //               Container(
              //       //                 // margin: EdgeInsets.only(top: 3),
              //       //                 padding: EdgeInsets.all(7),
              //       //                 decoration: BoxDecoration(
              //       //                     color: Colors.purple,
              //       //                     borderRadius: BorderRadius.circular(10)
              //       //                 ),
              //       //                 child: Text("Module 1",style: TextStyle(color: Colors.white,fontSize: 12),),
              //       //               ),
              //       //               // SizedBox(height: width>750?0:10,),
              //       //               // SizedBox(height: 8,),
              //       //               Column(
              //       //                 mainAxisAlignment: MainAxisAlignment.start,
              //       //                 crossAxisAlignment: CrossAxisAlignment.start,
              //       //                 children: [
              //       //                   Text("Python for Data Science",style:
              //       //                   TextStyle(height: 1,fontWeight: FontWeight.bold,fontSize: width>700?25:width<540?15:16),
              //       //                     overflow: TextOverflow.ellipsis,maxLines: 2,),
              //       //                   SizedBox(height: 15,),
              //       //                   // SizedBox(height: width>750?0:10,),
              //       //                   Row(
              //       //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //       //                     crossAxisAlignment: CrossAxisAlignment.start,
              //       //                     children: [
              //       //                       Expanded(child: Column(
              //       //                         crossAxisAlignment: CrossAxisAlignment.start,
              //       //                         mainAxisAlignment: MainAxisAlignment.start,
              //       //                         children: [
              //       //                           Text("Estimates learning time: 10 Hr",overflow: TextOverflow.ellipsis,style: TextStyle(fontSize:  width<540?width<420?11:13:14)),
              //       //                           SizedBox(height: 3,),
              //       //                           Text("Started on: Jan 01,2023",overflow: TextOverflow.ellipsis,style: TextStyle(fontSize:  width<540?width<420?11:13:14)),
              //       //                           SizedBox(height: 3,),
              //       //                           Text("Completed on: Jan 01,2023",overflow: TextOverflow.ellipsis,style: TextStyle(fontSize:  width<540?width<420?11:13:14)),
              //       //                           SizedBox(height: 15,),
              //       //                           SizedBox(
              //       //                             width: width<400?160:190,
              //       //                             child:
              //       //                             MaterialButton(
              //       //                               height: width>700?50:40,
              //       //                               shape: RoundedRectangleBorder(
              //       //                                 borderRadius: BorderRadius.circular(20),
              //       //                               ),
              //       //                               padding: EdgeInsets.all(8),
              //       //                               minWidth: width>700?100:60,
              //       //                               onPressed: (){},
              //       //                               child: Row(
              //       //                                 children: [
              //       //                                   SizedBox(width: 5,),
              //       //                                   Expanded(
              //       //                                       flex:1,
              //       //                                       child:
              //       //                                       Icon(Icons.play_arrow,color: Colors.white,size: width<200?2:null,)),
              //       //                                   Expanded(
              //       //                                       flex:3,
              //       //                                       child:
              //       //                                       Text("Resume learning",style: TextStyle(color: Colors.white,fontSize: width<500?10:null),overflow: TextOverflow.ellipsis,))
              //       //                                 ],
              //       //                               ),color: Colors.purple,),
              //       //                           )
              //       //
              //       //                         ],
              //       //                       )),
              //       //                       SizedBox(width: 5,),
              //       //                       width<700?
              //       //                       // Expanded(
              //       //                       //   child:
              //       //                       Column(
              //       //                         mainAxisAlignment: width>700?MainAxisAlignment.center:MainAxisAlignment.end,
              //       //                         children: [
              //       //                           SizedBox(height: 25,),
              //       //                           CircularPercentIndicator(
              //       //                             radius: width<700?width<500?20:30:70,
              //       //                             lineWidth: width>700?10.0:4.0,
              //       //                             animation: true,
              //       //                             percent: 10/100,
              //       //                             center: Text(
              //       //                               10.toString() + "%",
              //       //                               style: TextStyle(
              //       //                                   fontSize: width>700?20.0:width<500?8:14,
              //       //                                   fontWeight: FontWeight.w600,
              //       //                                   color: Colors.black),
              //       //                             ),
              //       //                             backgroundColor: Colors.black12,
              //       //                             circularStrokeCap: CircularStrokeCap.round,
              //       //                             progressColor: Colors.green,
              //       //                           ),
              //       //                           SizedBox(height: width<500?3:5,),
              //       //                           Text("progress",style: TextStyle(fontSize: 7,fontWeight: FontWeight.bold),)
              //       //                           // SizedBox(height: 15,),
              //       //                           // Text("10%")
              //       //                         ],
              //       //                       )
              //       //                       // ,
              //       //                       // )
              //       //                           :SizedBox(),
              //       //                       SizedBox(width: 5,)
              //       //                     ],
              //       //                   ),
              //       //                 ],
              //       //               )
              //       //             ],
              //       //           )),
              //       //       // SizedBox(width: 10,),
              //       //       width>700?Expanded(flex:2,
              //       //         // color: Colors.green,
              //       //         child: Column(
              //       //           mainAxisAlignment: width>700?MainAxisAlignment.center:MainAxisAlignment.end,
              //       //           children: [
              //       //             CircularPercentIndicator(
              //       //               radius: width>700?70.0:40.0,
              //       //               lineWidth: 10.0,
              //       //               animation: true,
              //       //               percent: 10/100,
              //       //               center: Text(
              //       //                 10.toString() + "%",
              //       //                 style: TextStyle(
              //       //                     fontSize: 20.0,
              //       //                     fontWeight: FontWeight.w600,
              //       //                     color: Colors.black),
              //       //               ),
              //       //               backgroundColor: Colors.black12,
              //       //               circularStrokeCap: CircularStrokeCap.round,
              //       //               progressColor: Colors.green,
              //       //             ),
              //       //             SizedBox(height: 15,),
              //       //             Text("10%")
              //       //           ],
              //       //         ),):
              //       //       SizedBox()
              //       //       // Column(
              //       //       //   mainAxisAlignment: width>700?MainAxisAlignment.center:MainAxisAlignment.end,
              //       //       //   children: [
              //       //       //     CircularPercentIndicator(
              //       //       //       radius: width>700?70.0:30.0,
              //       //       //       lineWidth: width>700?10.0:5.0,
              //       //       //       animation: true,
              //       //       //       percent: 10/100,
              //       //       //       center: Text(
              //       //       //         10.toString() + "%",
              //       //       //         style: TextStyle(
              //       //       //             fontSize: width>700?20.0:14,
              //       //       //             fontWeight: FontWeight.w600,
              //       //       //             color: Colors.black),
              //       //       //       ),
              //       //       //       backgroundColor: Colors.black12,
              //       //       //       circularStrokeCap: CircularStrokeCap.round,
              //       //       //       progressColor: Colors.green,
              //       //       //     ),
              //       //       //     SizedBox(height: 15,),
              //       //       //     Text("10%")
              //       //       //   ],
              //       //       // ),
              //       //     ],
              //       //   ),
              //       // ),
              //       // Container(
              //       //   padding: EdgeInsets.all(8),
              //       //   width: width<1700?width<1300?width<850?constraints.maxWidth-20:constraints.maxWidth-200:constraints.maxWidth-400:constraints.maxWidth-700,
              //       //   height: width>700?240:195,
              //       //   decoration: BoxDecoration(
              //       //       borderRadius: BorderRadius.circular(20),
              //       //       color: Colors.white
              //       //   ),
              //       //   child: Row(
              //       //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //       //     children: [
              //       //       Expanded(flex:width<600?4:3,child: Padding(
              //       //         padding: EdgeInsets.all(5),
              //       //         child: Image.asset("assets/DATALY Logo.png"),
              //       //       )),
              //       //
              //       //       Expanded(flex: width<600?6:4,
              //       //           child:  Column(
              //       //             crossAxisAlignment: CrossAxisAlignment.start,
              //       //             mainAxisAlignment:
              //       //             // width>700?
              //       //             MainAxisAlignment.spaceAround,
              //       //             // :MainAxisAlignment.start,
              //       //             children: [
              //       //
              //       //               // SizedBox(height: width>750?0:10,),
              //       //               Container(
              //       //                 // margin: EdgeInsets.only(top: 3),
              //       //                 padding: EdgeInsets.all(7),
              //       //                 decoration: BoxDecoration(
              //       //                     color: Colors.purple,
              //       //                     borderRadius: BorderRadius.circular(10)
              //       //                 ),
              //       //                 child: Text("Module 1",style: TextStyle(color: Colors.white,fontSize: 12),),
              //       //               ),
              //       //               // SizedBox(height: width>750?0:10,),
              //       //               // SizedBox(height: 8,),
              //       //               Column(
              //       //                 mainAxisAlignment: MainAxisAlignment.start,
              //       //                 crossAxisAlignment: CrossAxisAlignment.start,
              //       //                 children: [
              //       //                   Text("Python for Data Science",style:
              //       //                   TextStyle(height: 1,fontWeight: FontWeight.bold,fontSize: width>700?25:width<540?15:16),
              //       //                     overflow: TextOverflow.ellipsis,maxLines: 2,),
              //       //                   SizedBox(height: 15,),
              //       //                   // SizedBox(height: width>750?0:10,),
              //       //                   Row(
              //       //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //       //                     crossAxisAlignment: CrossAxisAlignment.start,
              //       //                     children: [
              //       //                       Expanded(child: Column(
              //       //                         crossAxisAlignment: CrossAxisAlignment.start,
              //       //                         mainAxisAlignment: MainAxisAlignment.start,
              //       //                         children: [
              //       //                           Text("Estimates learning time: 10 Hr",overflow: TextOverflow.ellipsis,style: TextStyle(fontSize:  width<540?width<420?11:13:14)),
              //       //                           SizedBox(height: 3,),
              //       //                           Text("Started on: Jan 01,2023",overflow: TextOverflow.ellipsis,style: TextStyle(fontSize:  width<540?width<420?11:13:14)),
              //       //                           SizedBox(height: 3,),
              //       //                           Text("Completed on: Jan 01,2023",overflow: TextOverflow.ellipsis,style: TextStyle(fontSize:  width<540?width<420?11:13:14)),
              //       //                           SizedBox(height: 15,),
              //       //                           SizedBox(
              //       //                             width: width<400?160:190,
              //       //                             child:
              //       //                             MaterialButton(
              //       //                               height: width>700?50:40,
              //       //                               shape: RoundedRectangleBorder(
              //       //                                 borderRadius: BorderRadius.circular(20),
              //       //                               ),
              //       //                               padding: EdgeInsets.all(8),
              //       //                               minWidth: width>700?100:60,
              //       //                               onPressed: (){},
              //       //                               child: Row(
              //       //                                 children: [
              //       //                                   SizedBox(width: 5,),
              //       //                                   Expanded(
              //       //                                       flex:1,
              //       //                                       child:
              //       //                                       Icon(Icons.play_arrow,color: Colors.white,size: width<200?2:null,)),
              //       //                                   Expanded(
              //       //                                       flex:3,
              //       //                                       child:
              //       //                                       Text("Resume learning",style: TextStyle(color: Colors.white,fontSize: width<500?10:null),overflow: TextOverflow.ellipsis,))
              //       //                                 ],
              //       //                               ),color: Colors.purple,),
              //       //                           )
              //       //
              //       //                         ],
              //       //                       )),
              //       //                       SizedBox(width: 5,),
              //       //                       width<700?
              //       //                       // Expanded(
              //       //                       //   child:
              //       //                       Column(
              //       //                         mainAxisAlignment: width>700?MainAxisAlignment.center:MainAxisAlignment.end,
              //       //                         children: [
              //       //                           SizedBox(height: 25,),
              //       //                           CircularPercentIndicator(
              //       //                             radius: width<700?width<500?20:30:70,
              //       //                             lineWidth: width>700?10.0:4.0,
              //       //                             animation: true,
              //       //                             percent: 10/100,
              //       //                             center: Text(
              //       //                               10.toString() + "%",
              //       //                               style: TextStyle(
              //       //                                   fontSize: width>700?20.0:width<500?8:14,
              //       //                                   fontWeight: FontWeight.w600,
              //       //                                   color: Colors.black),
              //       //                             ),
              //       //                             backgroundColor: Colors.black12,
              //       //                             circularStrokeCap: CircularStrokeCap.round,
              //       //                             progressColor: Colors.green,
              //       //                           ),
              //       //                           SizedBox(height: width<500?3:5,),
              //       //                           Text("progress",style: TextStyle(fontSize: 7,fontWeight: FontWeight.bold),)
              //       //                           // SizedBox(height: 15,),
              //       //                           // Text("10%")
              //       //                         ],
              //       //                       )
              //       //                       // ,
              //       //                       // )
              //       //                           :SizedBox(),
              //       //                       SizedBox(width: 5,)
              //       //                     ],
              //       //                   ),
              //       //                 ],
              //       //               )
              //       //             ],
              //       //           )),
              //       //       // SizedBox(width: 10,),
              //       //       width>700?Expanded(flex:2,
              //       //         // color: Colors.green,
              //       //         child: Column(
              //       //           mainAxisAlignment: width>700?MainAxisAlignment.center:MainAxisAlignment.end,
              //       //           children: [
              //       //             CircularPercentIndicator(
              //       //               radius: width>700?70.0:40.0,
              //       //               lineWidth: 10.0,
              //       //               animation: true,
              //       //               percent: 10/100,
              //       //               center: Text(
              //       //                 10.toString() + "%",
              //       //                 style: TextStyle(
              //       //                     fontSize: 20.0,
              //       //                     fontWeight: FontWeight.w600,
              //       //                     color: Colors.black),
              //       //               ),
              //       //               backgroundColor: Colors.black12,
              //       //               circularStrokeCap: CircularStrokeCap.round,
              //       //               progressColor: Colors.green,
              //       //             ),
              //       //             SizedBox(height: 15,),
              //       //             Text("10%")
              //       //           ],
              //       //         ),):
              //       //       SizedBox()
              //       //       // Column(
              //       //       //   mainAxisAlignment: width>700?MainAxisAlignment.center:MainAxisAlignment.end,
              //       //       //   children: [
              //       //       //     CircularPercentIndicator(
              //       //       //       radius: width>700?70.0:30.0,
              //       //       //       lineWidth: width>700?10.0:5.0,
              //       //       //       animation: true,
              //       //       //       percent: 10/100,
              //       //       //       center: Text(
              //       //       //         10.toString() + "%",
              //       //       //         style: TextStyle(
              //       //       //             fontSize: width>700?20.0:14,
              //       //       //             fontWeight: FontWeight.w600,
              //       //       //             color: Colors.black),
              //       //       //       ),
              //       //       //       backgroundColor: Colors.black12,
              //       //       //       circularStrokeCap: CircularStrokeCap.round,
              //       //       //       progressColor: Colors.green,
              //       //       //     ),
              //       //       //     SizedBox(height: 15,),
              //       //       //     Text("10%")
              //       //       //   ],
              //       //       // ),
              //       //     ],
              //       //   ),
              //       // ),
              //
              //     ],
              //   ),
              // ),
              );
        },
      ),
    );
  }
}