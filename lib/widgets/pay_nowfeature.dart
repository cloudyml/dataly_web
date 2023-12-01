import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudyml_app2/global_variable.dart';
import 'package:cloudyml_app2/models/course_details.dart';
import 'package:cloudyml_app2/payment_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:cloudyml_app2/fun.dart';
import '../Providers/UserProvider.dart';
import '../globals.dart';

class PayNowBottomSheetfeature extends StatefulWidget {
  // ValueListenable<double> currentPosition;
  // ValueListenable<double> popBottomSheetAt;
  String coursePrice;
  // String? id;
  Map<String, dynamic> map;
  Map<String, dynamic> usermap;
  bool isItComboCourse;
  bool international;
  String cID;
  PayNowBottomSheetfeature({
    Key? key,
    // required this.currentPosition,
    required this.coursePrice,
    required this.map,
    required this.usermap,
    required this.international,
    // required this.popBottomSheetAt,
    required this.isItComboCourse,
    required this.cID,
    // required this.id,
  }) : super(key: key);

  @override
  State<PayNowBottomSheetfeature> createState() =>
      _PayNowBottomSheetfeatureState();
}

class _PayNowBottomSheetfeatureState extends State<PayNowBottomSheetfeature> {
  List<CourseDetails> featuredCourse = [];

  Map userMap1 = Map<String, dynamic>();

  getuserdata() async {
    try {
      DocumentSnapshot userDocs = await FirebaseFirestore.instance
          .collection("Users_dataly")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      userMap1 = userDocs.data() as Map<String, dynamic>;
    } catch (e) {
      print("error $e");
    }
  }

  setFeaturedCourse(List<CourseDetails> course) {
    featuredCourse.clear();
    course.forEach((element) {
      if (element.courseDocumentId == widget.cID) {
        featuredCourse.add(element);
        // featuredCourse.add(element.courses);

        print('element ${featuredCourse[0].courseId}');
      }
    });
    print('function ');
  }


  void trialCourse() async {
    print(
        'this is name  : ${userMap1['name']} ${widget.cID} ${FirebaseAuth.instance.currentUser!.uid} "abc"');

    try {
      var url = Uri.parse(
          'https://us-central1-cloudyml-app.cloudfunctions.net/exceluser/trialAccesscanada');
      final response = await http.post(url, headers: {
        "Access-Control-Allow-Origin": "*", // Required for CORS support to work
        "Access-Control-Allow-Methods": "GET, POST",
      }, body: {
        "uid": FirebaseAuth.instance.currentUser!.uid,
        "cid": featuredCourse[0].courseId,
        "uname": userMap1['name'],
        "cname": featuredCourse[0].courseName,
      });
      // print('this is body ${body.toString()}');

      print(response.statusCode);
    } catch (e) {
      print('this is api error ${e.toString()}');
    }
  }

  @override
  void initState() {
    super.initState();
    getuserdata();
    print("usermap1==$userMap1");
    // print("vid is===${featuredCourse[int.parse(widget.id!)]}");
    // dbCheckerForPayInParts();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    var verticalScale = screenHeight / mockUpHeight;
    var horizontalScale = screenWidth / mockUpWidth;
    final userprovider = Provider.of<UserProvider>(context);

    List<CourseDetails> course = Provider.of<List<CourseDetails>>(context);
    setFeaturedCourse(course);
    Map userMap = Map<String, dynamic>();

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      if (constraints.maxWidth >= 650) {
        return BottomSheet(
          builder: (BuildContext context) {
            return Container(
              height: 80,
              width: MediaQuery.of(context).size.width,
              // duration: Duration(milliseconds: 1000),
              // curve: Curves.easeIn,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                    ),
                    Container(
                      height: screenHeight * .08,
                      width: screenWidth / 3,
                      color: Color(0xFF7860DC),
                      child: Center(
                        child: userMap1['paidCourseNames'] != null &&
                                userMap1['paidCourseNames']
                                      .contains(featuredCourse[0].courseId)
                            ? InkWell(
                                onTap: () {

                                  mainCourseId = featuredCourse[0].courseId;
                                  mainCourseId == 'DSPAPCAD1' ?
                                  GoRouter.of(context).pushNamed('MultiComboCourseScreen', queryParams: {
                                    'courseName': featuredCourse[0].courseName,
                                    'id': featuredCourse[0].courseId,
                                  })
                                      :

                                  GoRouter.of(context).pushNamed(
                                      'NewComboCourseScreen',
                                      queryParams: {
                                        'courseName':
                                            featuredCourse[0].courseName,
                                        'courseId': featuredCourse[0].courseId,
                                      });
                                  // }
                                  // else if(featuredCourse[0].findex=='14')
                                  // {
                                  //            GoRouter.of(context).pushNamed(
                                  //     'newcomboCourse',
                                  //     queryParams: {
                                  //       'courseName':
                                  //           featuredCourse[0]
                                  //               .courseName,
                                  //       'courseId': featuredCourse[0].courseDocumentId,
                                  //     });
                                  // }

                                  // GoRouter.of(context).pushNamed(
                                  //     'newcomboCourse',
                                  //     queryParams: {
                                  //       'courseName':
                                  //           featuredCourse[0].courseName,
                                  //       'id': "40",
                                  //     });
                                },
                                child: Center(
                                  child: Container(
                                    // height: screenHeight * .08,
                                    // width: screenWidth / 2,
                                    child: Center(
                                      child: Text(
                                        'Continue Your Course',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 18 * verticalScale,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Medium',
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : InkWell(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          backgroundColor:
                                              Colors.deepPurpleAccent[700],
                                          title: Center(
                                            child: Text(
                                              'Start Your ${featuredCourse[0].trialDays} Days Free Trial',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                          content: Container(
                                            height: screenHeight * .5,
                                            width: screenWidth / 2,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                featureCPopup(
                                                  Icons.video_file,
                                                  'Get Complete Access to videos and assignments',
                                                  horizontalScale,
                                                  verticalScale,
                                                ),
                                                featureCPopup(
                                                  Icons.mobile_screen_share,
                                                  'Watch tutorial videos from any module',
                                                  horizontalScale,
                                                  verticalScale,
                                                ),
                                                featureCPopup(
                                                  Icons.assistant,
                                                  'Connect with Teaching Assistant for Doubt Clearance',
                                                  horizontalScale,
                                                  verticalScale,
                                                ),
                                                featureCPopup(
                                                  Icons.mobile_friendly,
                                                  'Access videos and chat support over our Mobile App.',
                                                  horizontalScale,
                                                  verticalScale,
                                                ),
                                                SizedBox(
                                                  height: 17,
                                                ),
                                                Container(
                                                    height: screenHeight / 8,
                                                    width: screenWidth / 3.5,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      border: Border.all(
                                                          color: Colors.white,
                                                          width: 0.5),
                                                      color: Colors.white,
                                                    ),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              flex: 1,
                                                              child: Container(
                                                                child:
                                                                    CircleAvatar(
                                                                  radius: 35,
                                                                  // borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                                                                  child: Image
                                                                      .network(
                                                                    featuredCourse[
                                                                            0]
                                                                        .courseImageUrl,
                                                                    fit: BoxFit
                                                                        .fill,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Container(
                                                                child: Text(
                                                                    featuredCourse[
                                                                            0]
                                                                        .courseName,
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize:
                                                                            13)),
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                      ],
                                                    )),
                                                SizedBox(
                                                    height: 29 * verticalScale),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Container(
                                                      width: screenWidth / 7,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        border: Border.all(
                                                            color: Colors.white,
                                                            width: 0.5),
                                                      ),
                                                      child: ElevatedButton(
                                                        onPressed: () {
                                                          print(
                                                              "user map ===$userMap");

                                                          // print(
                                                          //     'idd ${widget.id} ${featuredCourse[0].courseName}');
                                                          // print('this is condition ${userMap['paidCourseNames'].contains(featuredCourse[int.parse(widget.id!)].courseId)}');
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: Text(
                                                          'Close',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        border: Border.all(
                                                            color: Colors.white,
                                                            width: 0.5),
                                                      ),
                                                      child: ElevatedButton(
                                                        onPressed: () {
                                                          var paidcourse;
                                                          print("paidCourseList = ${userMap1['paidCourseNames']}");

                                                          if (userMap1[
                                                                  'paidCourseNames']
                                                              .contains(
                                                                  featuredCourse[
                                                                          0]
                                                                      .courseId)) {
                                                            Fluttertoast.showToast(
                                                                msg:
                                                                    'You have already enrolled in this course.');
                                                          } else if (widget
                                                                          .usermap[
                                                                      'trialCourseList'] !=
                                                                  null && widget
                                                              .usermap[
                                                          'trialCourseList'].isNotEmpty &&
                                                              userMap1[
                                                                      'trialCourseList']
                                                                  .contains(
                                                                      featuredCourse[
                                                                              0]
                                                                          .courseId)) {
                                                            Fluttertoast.showToast(
                                                                msg:
                                                                    'You have already tried this course... Please purchase the course.');
                                                          } else {
                                                            setState(() {
                                                              trialCourse();
                                                              Fluttertoast
                                                                  .showToast(
                                                                      msg:
                                                                          'Congrats!! Course is now available in enrolled courses for ${featuredCourse[0].trialDays}...');
                                                              Timer(
                                                                  Duration(
                                                                      seconds:
                                                                          2),
                                                                  () => {


                                                                        mainCourseId =
                                                                            featuredCourse[0].courseId,
                                                                    mainCourseId == 'DSPAPCAD1' ?
                                                                    GoRouter.of(context).pushNamed('MultiComboCourseScreen', queryParams: {
                                                                      'courseName': featuredCourse[0].courseName,
                                                                      'id': featuredCourse[0].courseId,
                                                                    })
                                                                        :
                                                                        GoRouter.of(context).pushNamed(
                                                                            'NewComboCourseScreen',
                                                                            queryParams: {
                                                                              'courseName': featuredCourse[0].courseName,
                                                                              'courseId': featuredCourse[0].courseId,
                                                                            })
                                                                      });
                                                            });
                                                          }
                                                        },
                                                        child: Center(
                                                          child: Text(
                                                            'Start your free trial',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      });
                                },
                                child: Container(
                                  height: screenHeight * .08,
                                  width: screenWidth / 2.5,
                                  child: Center(
                                    child: Text(
                                      'Start your free trial now',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 18 * verticalScale,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Medium',
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    InkWell(
                      onTap: () {
                        if (widget.international != null &&
                            widget.international == true) {
                          GoRouter.of(context).pushNamed(
                              'InternationalPaymentScreen',
                              queryParams: {
                                'cID': widget.cID,
                              });
                        } else {
                          GoRouter.of(context)
                              .pushNamed('comboPaymentPortal', queryParams: {
                            'cID': widget.cID,
                          });
                        }
                      },
                      child: Container(
                        height: screenHeight * .08,
                        width: screenWidth / 3,
                        color: Color(0xFF7860DC),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Pay Now',
                                style: TextStyle(
                                  fontSize: 18 * verticalScale,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Medium',
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(
                                width: 15,
                              ),
                              Text(
                                widget.coursePrice,
                                style: TextStyle(
                                  fontSize: 18 * verticalScale,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Medium',
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                  ],
                ),
              ),
            );
          },
          onClosing: () {},
          enableDrag: false,
        );
      } else {
        return BottomSheet(
          builder: (BuildContext context) {
            return Container(
              height: 80,
              width: MediaQuery.of(context).size.width,
              // duration: Duration(milliseconds: 1000),
              // curve: Curves.easeIn,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                    ),
                    Container(
                      height: screenHeight * .06,
                      width: screenWidth / 2,
                      color: Color(0xFF7860DC),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // SizedBox(
                            //   width: 200,
                            // ),
                            userMap1['paidCourseNames'] != null &&
                                    userMap1['paidCourseNames']
                                        .contains(featuredCourse[0].courseId)
                                ? InkWell(
                                    onTap: () {
                                      mainCourseId = featuredCourse[0].courseId;
                                      setState(() {

                                      });


                                      mainCourseId == 'DSPAPCAD1' ?
                                      GoRouter.of(context).pushNamed('MultiComboCourseScreen', queryParams: {
                                        'id': featuredCourse[0].courseId,
                                        'courseName': featuredCourse[0].courseName,
                                      })
                                          :
                                      GoRouter.of(context).pushNamed(
                                          'NewComboCourseScreen',
                                          queryParams: {
                                            'courseName':
                                                featuredCourse[0].courseName,
                                            'courseId':
                                                featuredCourse[0].courseId,
                                          });
                                    },
                                    child: Center(
                                      child: Container(
                                        // height: screenHeight * .08,
                                        // width: screenWidth / 2,
                                        child: Center(
                                          child: Text(
                                            'Continue Your Course',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 15 * verticalScale,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Medium',
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : InkWell(
                                    onTap: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              backgroundColor:
                                                  Colors.deepPurpleAccent[700],
                                              title: Center(
                                                child: Text(
                                                  'Start Your ${featuredCourse[0].trialDays} Days Free Trial',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ),
                                              content: Container(
                                                height: screenHeight * .5,
                                                width: screenWidth / 2,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    featureCPopup(
                                                      Icons.video_file,
                                                      'Get Complete Access to videos and assignments',
                                                      horizontalScale,
                                                      verticalScale,
                                                    ),
                                                    featureCPopup(
                                                      Icons.mobile_screen_share,
                                                      'Watch tutorial videos from any module',
                                                      horizontalScale,
                                                      verticalScale,
                                                    ),
                                                    featureCPopup(
                                                      Icons.assistant,
                                                      'Connect with Teaching Assistant for Doubt Clearance',
                                                      horizontalScale,
                                                      verticalScale,
                                                    ),
                                                    featureCPopup(
                                                      Icons.mobile_friendly,
                                                      'Access videos and chat support over our Mobile App.',
                                                      horizontalScale,
                                                      verticalScale,
                                                    ),
                                                    SizedBox(
                                                      height: 17,
                                                    ),
                                                    Container(
                                                        height:
                                                            screenHeight / 8,
                                                        width: screenWidth,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          border: Border.all(
                                                              color:
                                                                  Colors.white,
                                                              width: 0.5),
                                                          color: Colors.white,
                                                        ),
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Expanded(
                                                                  flex: 1,
                                                                  child:
                                                                      Container(
                                                                    child:
                                                                        CircleAvatar(
                                                                      radius:
                                                                          35,
                                                                      // borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                                                                      child: Image
                                                                          .network(
                                                                        featuredCourse[0]
                                                                            .courseImageUrl,
                                                                        fit: BoxFit
                                                                            .fill,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child:
                                                                      Container(
                                                                    child: Text(
                                                                        featuredCourse[0]
                                                                            .courseName,
                                                                        style: TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontSize: 13)),
                                                                  ),
                                                                ),
                                                              ],
                                                            )
                                                          ],
                                                        )),
                                                    SizedBox(
                                                        height:
                                                            29 * verticalScale),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            border: Border.all(
                                                                color: Colors
                                                                    .white,
                                                                width: 0.5),
                                                          ),
                                                          child: ElevatedButton(
                                                            onPressed: () {
                                                              // print(
                                                              //     'idd ${widget.id} ${featuredCourse[0].courseName}');
                                                              // print('this is condition ${userMap['paidCourseNames'].contains(featuredCourse[int.parse(widget.id!)].courseId)}');
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            child: Text(
                                                              'Close',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                          ),
                                                        ),
                                                        Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            border: Border.all(
                                                                color: Colors
                                                                    .white,
                                                                width: 0.5),
                                                          ),
                                                          child: ElevatedButton(
                                                            onPressed: () {
                                                              var paidcourse;
                                                              print(widget
                                                                  .usermap);

                                                              if (widget
                                                                  .usermap[
                                                                      'paidCourseNames']
                                                                  .contains(
                                                                      featuredCourse[
                                                                              0]
                                                                          .courseId)) {
                                                                Fluttertoast
                                                                    .showToast(
                                                                        msg:
                                                                            'You have already enrolled in this course.');
                                                              } else if (widget
                                                                              .usermap[
                                                                          'trialCourseList'] !=
                                                                      null &&
                                                                  widget
                                                                      .usermap[
                                                                          'trialCourseList']
                                                                      .contains(
                                                                          featuredCourse[0]
                                                                              .courseId)) {
                                                                Fluttertoast
                                                                    .showToast(
                                                                        msg:
                                                                            'You have already tried this course... Please purchase the course.');
                                                              } else {
                                                                setState(() {
                                                                  trialCourse();
                                                                  Fluttertoast
                                                                      .showToast(
                                                                          msg:
                                                                              'Congrats!! Course is now available in enrolled courses for ${featuredCourse[0].trialDays}...');
                                                                  Timer(
                                                                      Duration(
                                                                          seconds:
                                                                              2),
                                                                      () => {

                                                                            mainCourseId = featuredCourse[0].courseId,

                                                                        mainCourseId == 'DSPAPCAD1' ?
                                                                      GoRouter.of(context).pushNamed('MultiComboCourseScreen', queryParams: {
                                                                    'courseName': featuredCourse[0].courseName,
                                                                    'id': featuredCourse[0].courseId,
                                                                  })
                                                                      :
                                                                            GoRouter.of(context).pushNamed('NewComboCourseScreen', queryParams: {
                                                                              'courseName': featuredCourse[0].courseName,
                                                                              'courseId': featuredCourse[0].courseId,
                                                                            })
                                                                          });
                                                                });
                                                              }
                                                            },
                                                            child: Center(
                                                              child: Text(
                                                                'Start your free trial',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          });
                                    },
                                    child: Container(
                                      height: screenHeight * .06,
                                      width: screenWidth / 3,
                                      child: Center(
                                        child: Text(
                                          'Start your free trial now',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 14 * verticalScale,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Medium',
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                            // SizedBox(
                            //   width: 200,
                            // ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        onTap: () {
                          GoRouter.of(context)
                              .pushNamed('comboPaymentPortal', queryParams: {
                            'cID': widget.cID,
                          });
                        },
                        child: Container(
                          height: screenHeight * .06,
                          width: screenWidth / 2,
                          padding: EdgeInsets.only(left: 5, right: 5),
                          color: Color(0xFF7860DC),
                          child: Center(
                            child: Text(
                              'Pay Now ${widget.coursePrice}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 14 * verticalScale,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Medium',
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                  ],
                ),
              ),
            );
          },
          onClosing: () {},
          enableDrag: false,
        );
      }
    });
  }
}
