import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudyml_app2/combo/combo_course.dart';
import 'package:cloudyml_app2/combo/combo_store.dart';
import 'package:cloudyml_app2/fun.dart';
import 'package:cloudyml_app2/globals.dart';
import 'package:cloudyml_app2/models/course_details.dart';
import 'package:cloudyml_app2/module/video_screen.dart';
import 'package:cloudyml_app2/screens/review_screen/review_screen.dart';
import 'package:cloudyml_app2/store.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:star_rating/star_rating.dart';
import 'MyAccount/myaccount.dart';
import 'Providers/UserProvider.dart';
import 'authentication/firebase_auth.dart';
import 'catalogue_screen.dart';
import 'home.dart';
import 'module/pdf_course.dart';

import 'dart:html' as html;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String searchString = "";
final Scrollcontroller = ScrollController();
  
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  // bool? whetherSubScribedToPayInParts = false;

  String id = "";

  // String daysLeftOfLimitedAccess = "";
  List<dynamic> courses = [];

  Map userMap = Map<String, dynamic>();

  bool load = true;

  fetchCourses() async {
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
      print("dddddd ${e.toString()}");
    }
  }

  String name = '';

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
      print("ddddinggg$e");
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
      print(e.toString());
    }
  }

  bool navigateToCatalogueScreen(String id) {
    try {
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
    } catch (e) {
      print('dipdipdip ${e.toString()}');
      return false;
    }
  }

  bool statusOfPayInParts(String id) {
    try {
      if (!(userMap['payInPartsDetails'][id] == null)) {
        if (userMap['payInPartsDetails'][id]['outStandingAmtPaid']) {
          return false;
        } else {
          return true;
        }
      } else {
        return false;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
      return false;
    }
  }

  var ref;

  userData() async {
    try {
      ref = await FirebaseFirestore.instance
          .collection("Users_dataly")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      print(ref.data()!["role"]);
    } catch (e) {
      print("ddddd${e}");
    }
  }

  // static final FlutterLocalNotificationsPlugin
  //     _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

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
            .collection("courseprogress")
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

  var textStyle = TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.white,
    fontSize: 14,
    fontFamily: "Semibold",
  );

  @override
  void initState() {
    fetchCourses();
    dbCheckerForPayInParts();
    getCourseName();
    userData();
    print('user enrolled in number of courses ${courses.length}');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<CourseDetails> course = Provider.of<List<CourseDetails>>(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    var verticalScale = screenHeight / mockUpHeight;
    var horizontalScale = screenWidth / mockUpWidth;

    return Scaffold(
        key: _scaffoldKey,
        drawer: customDrawer(context),
        // floatingActionButton: floatingButton(context),
        body: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          if (constraints.maxWidth >= 515) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    // height: 45,
                    color: HexColor("440F87"),
                    padding: const EdgeInsets.only(top: 8.0, right: 5),
                    child: customMenuBar(context),
                  ),
                  ref.data()!["name"] == null
                      ? Container()
                      : Container(
                          padding:
                              EdgeInsets.only(left: 60, right: 60, top: 40),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              ref.data()!["name"] == null
                                  ? ''
                                  : "Welcome back ${ref.data()!["name"]}, Continue learning",
                              style: TextStyle(
                                  color: HexColor("231F20"),
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'SemiBold'),
                            ),
                          ),
                        ),
                  Container(
                    padding: EdgeInsets.only(left: 60, right: 60, top: 10),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text("Enrolled Courses",
                          style: TextStyle(
                            color: HexColor("231F20"),
                            fontSize: 22,
                          )),
                    ),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  courses.length > 0
                      ? Scrollbar(
                          thumbVisibility: true,
                          child: Container(
                            // width: courses.length == 1
                            //     ? screenWidth / 2.5
                            //     : screenWidth / 1.2,
                            width: screenWidth,
                            height: screenHeight / 1.75,
                            color: Colors.transparent,
                            child: ListView.builder(
                              scrollDirection: Axis.vertical,
                              // shrinkWrap: true,
                              itemCount: course.length,
                              itemBuilder: (BuildContext context, int index) {
                                if (course[index].courseName == "null") {
                                  return Container();
                                }
                                if (courses.contains(course[index].courseId)) {
                                  return Column(
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
                                            if (course[index].multiCombo ==
                                                true) {
                                              GoRouter.of(context).pushNamed(
                                                  'MultiComboCourseScreen',
                                                  queryParams: {
                                                    'courseName': course[index]
                                                        .courseName
                                                        .toString(),
                                                    'id':
                                                        course[index].courseId,
                                                  });
                                            } else if (!course[index]
                                                .isItComboCourse) {
                                              GoRouter.of(context).pushNamed(
                                                  'videoScreen',
                                                  queryParams: {
                                                    'courseName': course[index]
                                                        .curriculum
                                                        .keys
                                                        .toList()
                                                        .first
                                                        .toString(),
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
                                            if (course[index].multiCombo ==
                                                true) {
                                              GoRouter.of(context).pushNamed(
                                                  'MultiComboCourseScreen',
                                                  queryParams: {
                                                    'courseName': course[index]
                                                        .courseName
                                                        .toString(),
                                                    'id':
                                                        course[index].courseId,
                                                  });
                                            } else if (!course[index]
                                                .isItComboCourse) {
                                              if (course[index].courseContent ==
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
                                                      curriculum: course[index]
                                                              .curriculum
                                                          as Map<String,
                                                              dynamic>,
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                GoRouter.of(context).pushNamed(
                                                  'videoScreen',
                                                  queryParams: {
                                                    'courseName': course[index]
                                                        .curriculum
                                                        .keys
                                                        .toList()
                                                        .first
                                                        .toString(),
                                                    'cID': course[index]
                                                        .courseDocumentId,
                                                  },
                                                );
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

                                              final id = index.toString();
                                              final courseName =
                                                  course[index].courseName;
                                              GoRouter.of(context).pushNamed(
                                                  'NewComboCourseScreen',
                                                  queryParams: {
                                                    'courseId':
                                                        course[index].courseId,
                                                    'courseName': courseName
                                                  });

                                              // GoRouter.of(context).pushNamed(
                                              //     'newcomboCourse',
                                              //     queryParams: {
                                              //       'id': id,
                                              //       'courseName': courseName
                                              //     });
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
                                            courseId =
                                                course[index].courseDocumentId;
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
                                                      width:
                                                          60 * horizontalScale,
                                                      height:
                                                          screenHeight / 5.5,
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                              color: Colors
                                                                  .transparent),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
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
                                                      width: screenWidth / 5.6,
                                                      height:
                                                          screenHeight / 5.5,
                                                      child: Align(
                                                        alignment:
                                                            Alignment.topCenter,
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
                                                                  fontSize: 16,
                                                                  height: 0.95,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ),
                                                            // SizedBox(height: 5,),
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
                                                              height: 5,
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
                                                                    height: 20,
                                                                    width: 25,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5.0),
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
                                                                            fontSize:
                                                                                12,
                                                                            color:
                                                                                Colors.white,
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
                                                                    height: 15,
                                                                    child: Row(
                                                                      children: [
                                                                        Container(
                                                                          height:
                                                                              5,
                                                                          width:
                                                                              120,
                                                                          child:
                                                                              LinearProgressIndicator(
                                                                            value: coursePercent[course[index].courseId.toString()] != null
                                                                                ? coursePercent[course[index].courseId] / 100
                                                                                : 0,
                                                                            color:
                                                                                HexColor("8346E1"),
                                                                            backgroundColor:
                                                                                HexColor('E3E3E3'),
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
                                        height: 25,
                                      ),
                                    ],
                                  );
                                } else {
                                  return Container();
                                }
                              },
                            ),
                          ),
                        )
                      : Container(
                          child: Text('There are zero courses. Please enroll.'),
                        ),
                  Container(
                    padding: EdgeInsets.only(top: 20),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                          "Please Click On The Course Name To Access Your Course Content",
                          style: TextStyle(
                            color: HexColor("231F20"),
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                          )),
                    ),
                  ),
                  Container(
                    height: 20,
                  ),
                ],
              ),
            );
          } else {
            return Stack(
              children: [
                Positioned(
                  top: -147 * verticalScale,
                  left: 2.4e-7 * horizontalScale,
                  child: Container(
                    width: 414 * horizontalScale,
                    height: 414 * verticalScale,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                      color: Color.fromRGBO(122, 98, 222, 1),
                    ),
                  ),
                ),
                Positioned(
                  top: 137 * verticalScale,
                  left: 348 * horizontalScale,
                  child: Container(
                    width: 162 * min(horizontalScale, verticalScale),
                    height: 162 * min(horizontalScale, verticalScale),
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(126, 106, 228, 1),
                      borderRadius:
                          BorderRadius.all(Radius.elliptical(162, 162)),
                    ),
                  ),
                ),
                Positioned(
                  top: -105 * verticalScale,
                  left: -91 * horizontalScale,
                  child: Container(
                    width: 162 * min(horizontalScale, verticalScale),
                    height: 162 * min(horizontalScale, verticalScale),
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(126, 106, 228, 1),
                      borderRadius:
                          BorderRadius.all(Radius.elliptical(162, 162)),
                    ),
                  ),
                ),
                Positioned(
                  top: 102 * verticalScale,
                  left: 102 * horizontalScale,
                  child: Text(
                    'My Courses',
                    textAlign: TextAlign.center,
                    textScaleFactor: min(horizontalScale, verticalScale),
                    style: TextStyle(
                      color: Color.fromRGBO(255, 255, 255, 1),
                      fontFamily: 'Poppins',
                      fontSize: 35,
                      letterSpacing:
                          0 /*percentages not used in flutter. defaulting to zero*/,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                  ),
                ),
                courses.length > 0
                    ? Positioned(
                        top: 0 * verticalScale,
                        left: 0 * horizontalScale,
                        child: Container(
                          width: screenWidth,
                          height: screenHeight,
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
                                      if (course[index].multiCombo == true) {
                                        GoRouter.of(context).pushNamed(
                                            'MultiComboCourseScreen',
                                            queryParams: {
                                              'courseName': course[index]
                                                  .courseName
                                                  .toString(),
                                              'id': course[index].courseId,
                                            });
                                      } else if (!course[index]
                                          .isItComboCourse) {
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
                                              courseName: course[index]
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
                                      if (course[index].multiCombo == true) {
                                        GoRouter.of(context).pushNamed(
                                            'MultiComboCourseScreen',
                                            queryParams: {
                                              'courseName': course[index]
                                                  .courseName
                                                  .toString(),
                                              'id': course[index].courseId,
                                            });
                                      } else if (!course[index]
                                          .isItComboCourse) {
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
                                                courseName: course[index]
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
                                        ComboCourse.comboId.value =
                                            course[index].courseId;
                                        final id = index.toString();
                                        final courseName =
                                            course[index].courseName;

                                        GoRouter.of(context).pushNamed(
                                            'NewComboCourseScreen',
                                            queryParams: {
                                              'courseId':
                                                  course[index].courseId,
                                              'courseName': courseName
                                            });

                                        // GoRouter.of(context).pushNamed(
                                        //     'newcomboCourse',
                                        //     queryParams: {
                                        //       'id': id,
                                        //       'courseName': courseName
                                        //     });
                                      }
                                    }
                                    setState(() {
                                      courseId = course[index].courseDocumentId;
                                    });
                                  }),
                                  child: Stack(
                                    children: [
                                      Column(
                                        children: [
                                          SizedBox(
                                            height: 230 * verticalScale,
                                          ),
                                          Row(
                                            children: [
                                              SizedBox(
                                                width: 20,
                                              ),
                                              Container(
                                                width: 177 * horizontalScale,
                                                height: 92 * verticalScale,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(25),
                                                    topRight:
                                                        Radius.circular(25),
                                                    bottomLeft:
                                                        Radius.circular(0),
                                                    bottomRight:
                                                        Radius.circular(0),
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: Color.fromRGBO(
                                                            29, 28, 31, 0.3),
                                                        offset: Offset(2, 2),
                                                        blurRadius: 47)
                                                  ],
                                                  image: DecorationImage(
                                                      image:
                                                          CachedNetworkImageProvider(
                                                        course[index]
                                                            .courseImageUrl,
                                                      ),
                                                      fit: BoxFit.fitWidth),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              SizedBox(
                                                width: 20,
                                              ),
                                              Stack(
                                                children: [
                                                  Container(
                                                    width:
                                                        177 * horizontalScale,
                                                    height:
                                                        200 * verticalScale / 2,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                        bottomLeft:
                                                            Radius.circular(25),
                                                        bottomRight:
                                                            Radius.circular(25),
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                            color:
                                                                Color.fromRGBO(
                                                              29,
                                                              28,
                                                              31,
                                                              0.3,
                                                            ),
                                                            offset:
                                                                Offset(2, 2),
                                                            blurRadius: 47)
                                                      ],
                                                      color: Color.fromRGBO(
                                                        255,
                                                        255,
                                                        255,
                                                        1,
                                                      ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: 5 * verticalScale,
                                                    left: 10 * horizontalScale,
                                                    right: 10 * horizontalScale,
                                                    child: Container(
                                                      child: Text(
                                                        course[index]
                                                            .courseName,
                                                        textScaleFactor:
                                                            horizontalScale,
                                                        style: TextStyle(
                                                            color:
                                                                Color.fromRGBO(
                                                              0,
                                                              0,
                                                              0,
                                                              1,
                                                            ),
                                                            fontFamily:
                                                                'Poppins',
                                                            fontSize: 15,
                                                            letterSpacing:
                                                                0 /*percentages not used in flutter. defaulting to zero*/,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            height: 1),
                                                        // overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                  course[index]
                                                              .isItComboCourse &&
                                                          statusOfPayInParts(
                                                              course[index]
                                                                  .courseId)
                                                      ? Positioned(
                                                          top: 35 *
                                                              verticalScale,
                                                          left: 10 *
                                                              horizontalScale,
                                                          child: Container(
                                                            child: !navigateToCatalogueScreen(
                                                                    course[index]
                                                                        .courseId)
                                                                ? Container(
                                                                    height: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.08 *
                                                                        verticalScale,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .circular(
                                                                        10,
                                                                      ),
                                                                      color:
                                                                          Color(
                                                                        0xFFC0AAF5,
                                                                      ),
                                                                    ),
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceEvenly,
                                                                      children: [
                                                                        SizedBox(
                                                                          width:
                                                                              10,
                                                                        ),
                                                                        Text(
                                                                          'Access ends in days : ',
                                                                          textScaleFactor: min(
                                                                              horizontalScale,
                                                                              verticalScale),
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontSize:
                                                                                13,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                        Container(
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            borderRadius:
                                                                                BorderRadius.circular(10),
                                                                            color:
                                                                                Colors.grey.shade100,
                                                                          ),
                                                                          width:
                                                                              30 * min(horizontalScale, verticalScale),
                                                                          height:
                                                                              30 * min(horizontalScale, verticalScale),
                                                                          // color:
                                                                          //     Color(0xFFaefb2a),
                                                                          child:
                                                                              Center(
                                                                            child:
                                                                                Text(
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
                                                                    height: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.08,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10),
                                                                      color: Color(
                                                                          0xFFC0AAF5),
                                                                    ),
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          Text(
                                                                        'Limited access expired !',
                                                                        textScaleFactor: min(
                                                                            horizontalScale,
                                                                            verticalScale),
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Colors.deepOrange[600],
                                                                          fontSize:
                                                                              13,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                          ),
                                                        )
                                                      : Container(),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          SizedBox(
                                            height: 395 * verticalScale,
                                          ),
                                          course[index].isItComboCourse
                                              ? Row(
                                                  children: [
                                                    SizedBox(
                                                      width:
                                                          30 * horizontalScale,
                                                    ),
                                                    Stack(
                                                      children: [
                                                        Positioned(
                                                          // top: 70 * verticalScale,
                                                          // left: 10 * horizontalScale,
                                                          child: Container(
                                                            width: 60 *
                                                                horizontalScale,
                                                            height: 40 *
                                                                verticalScale,
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              color: Color(
                                                                  0xFF7860DC),
                                                            ),
                                                            child: Center(
                                                              child: Text(
                                                                'COMBO',
                                                                textScaleFactor: min(
                                                                    horizontalScale,
                                                                    verticalScale),
                                                                style:
                                                                    const TextStyle(
                                                                  fontFamily:
                                                                      'Bold',
                                                                  fontSize: 13,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ],
                                                )
                                              : Container(),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                return Container();
                              }
                            },
                          ),
                        ))
                    : Container(),
                Positioned(
                  top: 498 * verticalScale,
                  // left: 36 * horizontalScale,
                  child: SizedBox(
                    width: 400,
                    child: Text(
                      'Please Click On The Course Name To Access Your Course Content',
                      maxLines: 3,
                      textAlign: TextAlign.center,
                      textScaleFactor: min(horizontalScale, verticalScale),
                      style: TextStyle(
                          color: Color.fromRGBO(0, 0, 0, 1),
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                          fontSize: 22,
                          letterSpacing:
                              0 /*percentages not used in flutter. defaulting to zero*/,
                          height: 1),
                    ),
                  ),
                ),
                // Positioned(
                //   top: 530 * verticalScale,
                //   child: Padding(
                //     padding: EdgeInsets.only(top: 8.0 * verticalScale),
                //     child: Container(
                //       width: screenWidth,
                //       height: screenHeight * 0.4,
                //       child: MediaQuery.removePadding(
                //         context: context,
                //         removeTop: true,
                //         child: ListView.builder(
                //           shrinkWrap: true,
                //           scrollDirection: Axis.vertical,
                //           itemCount: course.length,
                //           itemBuilder: (BuildContext context, index) {
                //             if (course[index].courseName == "null") {
                //               return Container();
                //             }
                //             return Padding(
                //               padding: const EdgeInsets.only(bottom: 18.0),
                //               child: InkWell(
                //                 onTap: () {
                //                   setState(() {
                //                     courseId = course[index].courseDocumentId;
                //                   });

                //                   print(courseId);
                //                   if (course[index].isItComboCourse) {
                //                     Navigator.push(
                //                       context,
                //                       MaterialPageRoute(
                //                         builder: (context) => ComboStore(
                //                           courses: course[index].courses,
                //                         ),
                //                       ),
                //                     );
                //                   } else {
                //                     Navigator.pushNamed(
                //                       context,
                //                       '/catalogue',
                //                     );
                //                   }
                //                 },
                //                 child: Padding(
                //                   padding: EdgeInsets.symmetric(
                //                       horizontal:
                //                           MediaQuery.of(context).size.width *
                //                               0.09),
                //                   child: ClipRRect(
                //                     borderRadius: BorderRadius.circular(10),
                //                     child: Container(
                //                       // height: MediaQuery.of(context).size.height * 0.16,
                //                       width: MediaQuery.of(context).size.width,
                //                       decoration: BoxDecoration(
                //                         borderRadius: BorderRadius.circular(10),
                //                         color: Color(0xFFE9E1FC),
                //                         boxShadow: [
                //                           BoxShadow(
                //                               color: Color.fromRGBO(
                //                                   29, 28, 30, 0.3),
                //                               offset: Offset(2, 2),
                //                               blurStyle: BlurStyle.outer,
                //                               blurRadius: 35)
                //                         ],
                //                       ),
                //                       child: Row(
                //                         mainAxisAlignment:
                //                             MainAxisAlignment.start,
                //                         children: [
                //                           Expanded(
                //                             flex: 1,
                //                             child: Container(
                //                               height: 100 *
                //                                   min(horizontalScale,
                //                                       verticalScale),
                //                               width: 100 *
                //                                   min(horizontalScale,
                //                                       verticalScale),
                //                               child: Padding(
                //                                 padding:
                //                                     const EdgeInsets.all(8.0),
                //                                 child: ClipRRect(
                //                                   borderRadius:
                //                                       BorderRadius.circular(10),
                //                                   child: CachedNetworkImage(
                //                                     imageUrl: course[index]
                //                                         .courseImageUrl,
                //                                     placeholder: (context,
                //                                             url) =>
                //                                         CircularProgressIndicator(),
                //                                     errorWidget:
                //                                         (context, url, error) =>
                //                                             Icon(Icons.error),
                //                                     fit: BoxFit.cover,
                //                                   ),
                //                                 ),
                //                               ),
                //                             ),
                //                           ),
                //                           SizedBox(
                //                             width: 15,
                //                           ),
                //                           Expanded(
                //                             flex: 2,
                //                             child: Column(
                //                               crossAxisAlignment:
                //                                   CrossAxisAlignment.start,
                //                               children: [
                //                                 SizedBox(
                //                                   height: 10,
                //                                 ),
                //                                 course[index].isItComboCourse ==
                //                                         true
                //                                     ? Container(
                //                                         decoration: BoxDecoration(
                //                                             borderRadius:
                //                                                 BorderRadius
                //                                                     .circular(
                //                                                         30),
                //                                             gradient: gradient),
                //                                         child: Padding(
                //                                           padding:
                //                                               const EdgeInsets
                //                                                   .all(4.0),
                //                                           child: Text(
                //                                             'COMBO',
                //                                             textScaleFactor: min(
                //                                                 horizontalScale,
                //                                                 verticalScale),
                //                                             style: TextStyle(
                //                                                 fontFamily:
                //                                                     'SemiBold',
                //                                                 fontSize: 8,
                //                                                 color: Colors
                //                                                     .black),
                //                                           ),
                //                                         ),
                //                                       )
                //                                     : Container(),
                //                                 Container(
                //                                   child: Text(
                //                                     course[index].courseName,
                //                                     textScaleFactor: min(
                //                                         horizontalScale,
                //                                         verticalScale),
                //                                     style: const TextStyle(
                //                                         fontFamily: 'Bold',
                //                                         fontSize: 17,
                //                                         fontWeight:
                //                                             FontWeight.w500),
                //                                     // maxLines: 2,
                //                                     overflow:
                //                                         TextOverflow.ellipsis,
                //                                   ),
                //                                 ),
                //                                 SizedBox(
                //                                   height: 5,
                //                                 ),
                //                                 Container(
                //                                   width: MediaQuery.of(context)
                //                                           .size
                //                                           .width *
                //                                       0.45,
                //                                   child: Row(
                //                                     mainAxisAlignment:
                //                                         MainAxisAlignment
                //                                             .spaceBetween,
                //                                     children: [
                //                                       Container(
                //                                         child: Text(
                //                                           course[index]
                //                                               .courseLanguage,
                //                                           textScaleFactor: min(
                //                                               horizontalScale,
                //                                               verticalScale),
                //                                           style: TextStyle(
                //                                               fontFamily:
                //                                                   'Medium',
                //                                               color: Colors
                //                                                   .black
                //                                                   .withOpacity(
                //                                                       0.4),
                //                                               fontSize: 10,
                //                                               fontWeight:
                //                                                   FontWeight
                //                                                       .w500),
                //                                         ),
                //                                       ),
                //                                       SizedBox(
                //                                         width: 6,
                //                                       ),
                //                                       Container(
                //                                         child: Center(
                //                                           child: Text(
                //                                             '${course[index].numOfVideos} videos',
                //                                             textScaleFactor: min(
                //                                                 horizontalScale,
                //                                                 verticalScale),
                //                                             style: TextStyle(
                //                                                 fontFamily:
                //                                                     'Medium',
                //                                                 color: Colors
                //                                                     .black
                //                                                     .withOpacity(
                //                                                         0.7),
                //                                                 fontSize: 10),
                //                                           ),
                //                                         ),
                //                                       ),
                //                                       SizedBox(
                //                                         width: 80,
                //                                       ),
                //                                     ],
                //                                   ),
                //                                 ),
                //                                 SizedBox(
                //                                   height: 5,
                //                                 ),
                //                                 Text(
                //                                   course[index].coursePrice,
                //                                   textScaleFactor: min(
                //                                       horizontalScale,
                //                                       verticalScale),
                //                                   style: TextStyle(
                //                                       fontFamily: 'Bold',
                //                                       color: Color(0xFF6E5BD9),
                //                                       fontSize: 17),
                //                                 ),
                //                                 // SizedBox(
                //                                 //   width: 40,
                //                                 // ),
                //                               ],
                //                             ),
                //                           ),
                //                         ],
                //                       ),
                //                     ),
                //                   ),
                //                 ),
                //               ),
                //             );
                //           },
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
                Positioned(
                  top: 100 * verticalScale,
                  left: 63 * horizontalScale,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Icon(Icons.arrow_back_sharp,
                        color: Colors.white,
                        size: 40 * min(horizontalScale, verticalScale)),
                  ),
                ),
              ],
            );
          }
        }));
  }
}
