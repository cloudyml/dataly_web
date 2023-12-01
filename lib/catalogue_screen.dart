import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudyml_app2/Services/database_service.dart';
import 'package:cloudyml_app2/models/course_details.dart';
import 'package:cloudyml_app2/widgets/coupon_code.dart';
import 'package:cloudyml_app2/widgets/curriculam.dart';
import 'package:cloudyml_app2/fun.dart';
import 'package:cloudyml_app2/globals.dart';
import 'package:cloudyml_app2/widgets/pay_now_bottomsheet.dart';
import 'package:cloudyml_app2/payment_screen.dart';
import 'package:cloudyml_app2/widgets/pay_nowfeature.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:ribbon_widget/ribbon_widget.dart';
import 'package:share_extend/share_extend.dart';

import 'Services/code_generator.dart';
import 'Services/deeplink_service.dart';
import 'combo/non_trial_course_paynowbtsheet.dart';

class CatelogueScreen extends StatefulWidget {
  final String? cID;
  final List<dynamic>? courses;
  const CatelogueScreen({Key? key, this.courses, this.cID})
      : super(key: key);

  @override
  State<CatelogueScreen> createState() => _CatelogueScreenState();
}

class _CatelogueScreenState extends State<CatelogueScreen>
    with SingleTickerProviderStateMixin, CouponCodeMixin {
  TabController? _tabController;
  // var _razorpay = Razorpay();
  var amountcontroller = TextEditingController();
  final TextEditingController couponCodeController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  GlobalKey? _positionKey = GlobalKey();

  // double closeBottomSheetAt = 0.0;
  // final scaffoldState = GlobalKey<ScaffoldState>();

  String coursePrice = "";


  String couponAppliedResponse = "";

  //If it is false amountpayble showed will be the amount fetched from db
  //If it is true which will be set to true if when right coupon code is
  //applied and the amountpayble will be set using appludiscount to the finalamountpayble variable
  // declared below same for discount
  bool NoCouponApplied = true;

  String finalamountToDisplay = "";

  String finalAmountToPay = "";

  String discountedPrice = "";

  bool isPayButtonPressed = false;

  bool isPayInPartsPressed = false;

  bool isMinAmountCheckerPressed = false;

  bool isOutStandingAmountCheckerPressed = false;

  bool showCurriculum = false;

  bool bottomSheet = false;

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

  @override
  void initState() {
    dbCheckerForPayInParts();
    getCourseName();
    super.initState();
  }

  var uid = FirebaseAuth.instance.currentUser!.uid;
  var moneyrefcode;
  var moneyreferalcode;
  var moneyreferallink;

  void lookformoneyref() async {
    try {
      await FirebaseFirestore.instance
          .collection("Users_dataly")
          .doc(uid)
          .get()
          .then((value) => {moneyrefcode = value.data()!["moneyrefcode"]});
    } catch (e) {}
    try {
      print("moneyrefcode: ${moneyrefcode}");
      moneyreferalcode = await CodeGenerator()
          .generateCodeformoneyreward('moneyreward-$courseId');
      // moneyreferallink =
      // await DeepLinkService.instance?.createReferLink(moneyreferalcode);
      // print("this is the kings enargy: ${moneyreferallink}");
      if (moneyrefcode == null) {
        FirebaseFirestore.instance.collection("Users_dataly").doc(uid).update({
          "moneyrefcode": "$moneyreferalcode",
        });
      }
    } catch (e) {}
  }

  var international;
  Map<String, dynamic> courseMap = {};
  void getCourseName() async {
    try {
      await FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .get()
          .then((value) {
        setState(() {
          courseMap = value.data()!;
          coursePrice = value.data()!['Course Price'];
          international = value.data()!['international'];
        });
      });
    } catch (e) {
      print('catalogue screen ${e.toString()} ');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    late final size;
    double height, width;
    size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;
    List<CourseDetails> course = Provider.of<List<CourseDetails>>(context);
    return Scaffold(
      bottomSheet: fromMultiCombo ? null :
          courseMap['trialCourse']! != null && courseMap['trialCourse']!
              ? PayNowBottomSheetfeature(
                  coursePrice: '₹${coursePrice}/-',
                  map: courseMap,
                  isItComboCourse: true,
                  cID: widget.cID!,
                  international: international,
                  // id: widget.id!,
                  usermap: userMap as Map<String, dynamic>)
              :
          NonTrialCourseBottomSheet(
                  coursePrice: '₹${coursePrice}/-',
                  map: courseMap,
                  isItComboCourse: true,
                  international: international,
                  cID: widget.cID!,
                ),
      backgroundColor: Colors.white,
      body: LayoutBuilder(builder: (context, constraints) {
        return Device.screenType == ScreenType.mobile
            ? Container(
          decoration: BoxDecoration(
            image: DecorationImage(
                image: NetworkImage(
                    "https://firebasestorage.googleapis.com/v0/b/cloudyml-app.appspot.com/o/test_developer%2FbackGroundImage.jpg?alt=media&token=c7282af8-222d-4761-89b0-35fa206f0ac1"),
                fit: BoxFit.fill),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.sp),
              Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: course.length,
                    itemBuilder: (BuildContext context, index) {
                      if (course[index].courseName == "null") {
                        return Container();
                      }
                      if (courseId == course[index].courseDocumentId) {
                        // CatelogueScreen.coursePrice.value = course[index].coursePrice;
                        // CatelogueScreen.map!.value = map;
                        return Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 00.0, right: 15, left: 15, bottom: 10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(8.sp),
                                    child: Container(
                                      padding: EdgeInsets.all(8.sp),
                                      margin: EdgeInsets.only(bottom: 15.sp),
                                      width: Adaptive.w(90),
                                      height: Adaptive.h(25),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(15.sp),
                                          color: Colors.white),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        children: [
                                          Container(
                                            height: double.infinity,
                                            width: Adaptive.w(35),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                BorderRadius.circular(15.sp),
                                                image: DecorationImage(
                                                    image: NetworkImage(course[index].courseImageUrl),
                                                    fit: BoxFit.cover)),
                                          ),
                                          SizedBox(width: 10.sp,),
                                          Padding(
                                            padding: EdgeInsets.all(10.sp),
                                            child: Column(
                                              mainAxisAlignment:
                                              MainAxisAlignment.start,
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  course[index].courseName,
                                                  style: TextStyle(
                                                      height: 1,
                                                      fontWeight:
                                                      FontWeight.bold,
                                                      fontSize: 14.sp),
                                                  overflow:
                                                  TextOverflow.ellipsis,
                                                  maxLines: 2,
                                                ),
                                                SizedBox(
                                                  height: 13,
                                                ),
                                                Container(
                                                  width: Adaptive.w(32),
                                                  child: Text(
                                                    course[index].courseDescription,
                                                    style: TextStyle(
                                                        fontWeight:
                                                        FontWeight.w500,
                                                        fontSize: 12.sp),
                                                    overflow:
                                                    TextOverflow.ellipsis,
                                                    maxLines: 4,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 30.sp,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      catalogContainerForMobile(
                                        context,
                                        'Guided Hands-On Assignment',
                                        Icons.book,
                                      ),
                                      SizedBox(
                                        width: 15.sp,
                                      ),
                                      catalogContainerForMobile(
                                        context,
                                        'Capstone End to End Project',
                                        Icons.assignment,
                                      ),

                                    ],
                                  ),
                                  SizedBox(
                                    height: 10.sp,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      catalogContainerForMobile(
                                        context,
                                        'One Month Internship Opportunity',
                                        Icons.badge,
                                      ),
                                      SizedBox(
                                        width: 15.sp,
                                      ),
                                      catalogContainerForMobile(
                                        context,
                                        '1-1 Chat Support',
                                        Icons.call,
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10.sp,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      catalogContainerForMobile(
                                        context,
                                        'Job Referrals & Opening Mails',
                                        Icons.email,
                                      ),
                                      SizedBox(
                                        width: 15.sp,
                                      ),
                                      catalogContainerForMobile(
                                        context,
                                        'Interview Q&As PDF Collection',
                                        Icons.picture_as_pdf,
                                      ),
                                    ],
                                  ),
                                  // includes(context),
                                  Container(
                                    child: Curriculam(
                                      courseDetail: course[index],
                                    ),
                                  ),
                                  Container(
                                    key: _positionKey,
                                  ),
                                  // Ribbon(
                                  //   nearLength: 1,
                                  //   farLength: .5,
                                  //   title: ' ',
                                  //   titleStyle: TextStyle(
                                  //       color: Colors.black,
                                  //       // Colors.white,
                                  //       fontSize: 18,
                                  //       fontWeight: FontWeight.bold),
                                  //   color: Color.fromARGB(255, 11, 139, 244),
                                  //   location: RibbonLocation.topStart,
                                  //   child: Container(
                                  //     //  key:key,
                                  //     // width: width * .9,
                                  //     // height: height * .5,
                                  //     color: Color.fromARGB(255, 24, 4, 104),
                                  //     child: Padding(
                                  //       padding: const EdgeInsets.all(40.0),
                                  //       child: Column(
                                  //         //  key:Gkey,
                                  //         children: [
                                  //           SizedBox(
                                  //             height: height * .03,
                                  //           ),
                                  //           Text(
                                  //             'Complete Course Fee',
                                  //             style: TextStyle(
                                  //                 fontFamily: 'Bold',
                                  //                 fontSize: 21,
                                  //                 color: Colors.white),
                                  //           ),
                                  //           SizedBox(
                                  //             height: 5,
                                  //           ),
                                  //           Text(
                                  //             '( Everything with Lifetime Access )',
                                  //             style: TextStyle(
                                  //                 fontFamily: 'Bold',
                                  //                 fontSize: 11,
                                  //                 color: Colors.white),
                                  //           ),
                                  //           SizedBox(
                                  //             height: 30,
                                  //           ),
                                  //           Text(
                                  //             '₹${course[index].coursePrice}/-',
                                  //             style: TextStyle(
                                  //                 fontFamily: 'Medium',
                                  //                 fontSize: 30,
                                  //                 color: Colors.white),
                                  //           ),
                                  //           SizedBox(height: 35),
                                  //           InkWell(
                                  //             onTap: () {

                                  //               GoRouter.of(context).pushNamed('paymentPortal',
                                  //                   queryParams: {
                                  //                     'cID': courseId});

                                  //               // Navigator.push(
                                  //               //   context,
                                  //               //   MaterialPageRoute(
                                  //               //     builder: (context) => PaymentScreen(
                                  //               //       map: courseMap,
                                  //               //       isItComboCourse: false,
                                  //               //     ),
                                  //               //   ),
                                  //               // );

                                  //               // Navigator.pushNamed(
                                  //               //     context, '/paymentscreen'
                                  //               // );
                                  //             },
                                  //             child: Container(
                                  //               decoration: BoxDecoration(
                                  //                   borderRadius:
                                  //                   BorderRadius.circular(30),
                                  //                   color: Color.fromARGB(
                                  //                       255, 119, 191, 249),
                                  //                   gradient: gradient),
                                  //               height: height * .08,
                                  //               width: width * .6,
                                  //               child: Center(
                                  //                 child: Text(
                                  //                   'Buy Now',
                                  //                   textAlign: TextAlign.center,
                                  //                   style: TextStyle(
                                  //                       color: Colors.white,
                                  //                       fontSize: 20),
                                  //                 ),
                                  //               ),
                                  //             ),
                                  //           ),
                                  //         ],
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),
                                  SizedBox(
                                    height: 20,
                                  )
                                ],
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Container();
                      }
                    },
                  ))
            ],
          ),
        )
            : Container(
          decoration: BoxDecoration(
            image: DecorationImage(
                image: NetworkImage(
                    "https://firebasestorage.googleapis.com/v0/b/cloudyml-app.appspot.com/o/test_developer%2FbackGroundImage.jpg?alt=media&token=c7282af8-222d-4761-89b0-35fa206f0ac1"),
                fit: BoxFit.fill),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              Expanded(
                  child: ListView.builder(
                controller: _scrollController,
                itemCount: course.length,
                itemBuilder: (BuildContext context, index) {
                  if (course[index].courseName == "null") {
                    return Container();
                  }
                  if (courseId == course[index].courseDocumentId) {
                    // CatelogueScreen.coursePrice.value = course[index].coursePrice;
                    // CatelogueScreen.map!.value = map;
                    return Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 00.0, right: 18, left: 10, bottom: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  margin: EdgeInsets.only(bottom: 15),
                                  width: width < 1700
                                      ? width < 1300
                                          ? width < 850
                                              ? constraints.maxWidth - 20
                                              : constraints.maxWidth - 200
                                          : constraints.maxWidth - 250
                                      : constraints.maxWidth - 700,
                                  height: width > 700
                                      ? 230
                                      : width < 300
                                          ? 190
                                          : 210,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Colors.white),
                                  child: Row(
                                    children: [
                                      Container(
                                        height: double.infinity,
                                        width: width / 5,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            image: DecorationImage(
                                                image: NetworkImage(
                                                    course[index]
                                                        .courseImageUrl),
                                                fit: BoxFit.cover)),
                                      ),
                                      SizedBox(
                                        width: width / 100,
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            course[index].courseName,
                                            style: TextStyle(
                                                height: 1,
                                                fontWeight:
                                                    FontWeight.bold,
                                                fontSize: width > 700
                                                    ? 25
                                                    : width < 540
                                                        ? 12
                                                        : 14),
                                            overflow:
                                                TextOverflow.ellipsis,
                                            maxLines: 4,
                                          ),
                                          SizedBox(
                                            height: 13,
                                          ),
                                          Container(
                                            width: Adaptive.w(50),
                                            child: Text(
                                              course[index].courseDescription,
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.w500,
                                                  fontSize: width < 540
                                                      ? width < 420
                                                          ? 11
                                                          : 13
                                                      : 14),
                                              overflow:
                                                  TextOverflow.ellipsis,
                                              maxLines: 4,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 45,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  catalogContainer(
                                    context,
                                    'Guided Hands-On Assignment',
                                    Icons.book,
                                  ),
                                  catalogContainer(
                                    context,
                                    'Capstone End to End Project',
                                    Icons.assignment,
                                  ),
                                  catalogContainer(
                                    context,
                                    'One Month Internship Opportunity',
                                    Icons.badge,
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  catalogContainer(
                                    context,
                                    '1-1 Chat Support',
                                    Icons.call,
                                  ),
                                  catalogContainer(
                                    context,
                                    'Job Referrals & Opening Mails',
                                    Icons.email,
                                  ),
                                  catalogContainer(
                                    context,
                                    'Interview Q&As PDF Collection',
                                    Icons.picture_as_pdf,
                                  ),
                                ],
                              ),
                              // includes(context),
                              Container(
                                child: Curriculam(
                                  courseDetail: course[index],
                                ),
                              ),
                              Container(
                                key: _positionKey,
                              ),
                              // Ribbon(
                              //   nearLength: 1,
                              //   farLength: .5,
                              //   title: ' ',
                              //   titleStyle: TextStyle(
                              //       color: Colors.black,
                              //       // Colors.white,
                              //       fontSize: 18,
                              //       fontWeight: FontWeight.bold),
                              //   color: Color.fromARGB(255, 11, 139, 244),
                              //   location: RibbonLocation.topStart,
                              //   child: Container(
                              //     //  key:key,
                              //     // width: width * .9,
                              //     // height: height * .5,
                              //     color: Color.fromARGB(255, 24, 4, 104),
                              //     child: Padding(
                              //       padding: const EdgeInsets.all(40.0),
                              //       child: Column(
                              //         //  key:Gkey,
                              //         children: [
                              //           SizedBox(
                              //             height: height * .03,
                              //           ),
                              //           Text(
                              //             'Complete Course Fee',
                              //             style: TextStyle(
                              //                 fontFamily: 'Bold',
                              //                 fontSize: 21,
                              //                 color: Colors.white),
                              //           ),
                              //           SizedBox(
                              //             height: 5,
                              //           ),
                              //           Text(
                              //             '( Everything with Lifetime Access )',
                              //             style: TextStyle(
                              //                 fontFamily: 'Bold',
                              //                 fontSize: 11,
                              //                 color: Colors.white),
                              //           ),
                              //           SizedBox(
                              //             height: 30,
                              //           ),
                              //           Text(
                              //             '₹${course[index].coursePrice}/-',
                              //             style: TextStyle(
                              //                 fontFamily: 'Medium',
                              //                 fontSize: 30,
                              //                 color: Colors.white),
                              //           ),
                              //           SizedBox(height: 35),
                              //           InkWell(
                              //             onTap: () {

                              //               GoRouter.of(context).pushNamed('paymentPortal',
                              //                   queryParams: {
                              //                     'cID': courseId});

                              //               // Navigator.push(
                              //               //   context,
                              //               //   MaterialPageRoute(
                              //               //     builder: (context) => PaymentScreen(
                              //               //       map: courseMap,
                              //               //       isItComboCourse: false,
                              //               //     ),
                              //               //   ),
                              //               // );

                              //               // Navigator.pushNamed(
                              //               //     context, '/paymentscreen'
                              //               // );
                              //             },
                              //             child: Container(
                              //               decoration: BoxDecoration(
                              //                   borderRadius:
                              //                   BorderRadius.circular(30),
                              //                   color: Color.fromARGB(
                              //                       255, 119, 191, 249),
                              //                   gradient: gradient),
                              //               height: height * .08,
                              //               width: width * .6,
                              //               child: Center(
                              //                 child: Text(
                              //                   'Buy Now',
                              //                   textAlign: TextAlign.center,
                              //                   style: TextStyle(
                              //                       color: Colors.white,
                              //                       fontSize: 20),
                              //                 ),
                              //               ),
                              //             ),
                              //           ),
                              //         ],
                              //       ),
                              //     ),
                              //   ),
                              // ),
                              SizedBox(
                                height: 20,
                              )
                            ],
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Container();
                  }
                },
              ))
            ],
          ),
        );
      }),
    );
  }
}
