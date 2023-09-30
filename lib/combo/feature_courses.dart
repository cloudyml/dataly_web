// import 'dart:async';
// import 'dart:convert';
// import 'dart:math';
// import '../widgets/pay_nowfeature.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:cloudyml_app2/Services/database_service.dart';
// import 'package:cloudyml_app2/models/course_details.dart';
// import 'package:cloudyml_app2/widgets/coupon_code.dart';
// import 'package:cloudyml_app2/fun.dart';
// import 'package:cloudyml_app2/globals.dart';
// import 'package:cloudyml_app2/widgets/pay_now_bottomsheet.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:go_router/go_router.dart';
// import 'package:provider/provider.dart';
// import 'package:ribbon_widget/ribbon_widget.dart';
// import 'package:http/http.dart' as http;
// import '../Services/code_generator.dart';
// import '../Services/deeplink_service.dart';

// class FeatureCourses extends StatefulWidget {
//   final String? id;
//   final String? cName;
//   final String? courseP;
//   final String? cID;

//   static ValueNotifier<String> coursePrice = ValueNotifier('');
//   static ValueNotifier<Map<String, dynamic>>? map = ValueNotifier({});
//   static ValueNotifier<double> _currentPosition = ValueNotifier<double>(0.0);
//   static ValueNotifier<double> _closeBottomSheetAtInCombo =
//       ValueNotifier<double>(0.0);
//   FeatureCourses({Key? key, this.id, this.cID, this.cName, this.courseP})
//       : super(key: key);

//   @override
//   State<FeatureCourses> createState() => _FeatureCoursesState();
// }

// class _FeatureCoursesState extends State<FeatureCourses> with CouponCodeMixin {
//   // var _razorpay = Razorpay();
//   var amountcontroller = TextEditingController();
//   TextEditingController couponCodeController = TextEditingController();
//   String? id;
//   final ScrollController _scrollController = ScrollController();

//   String couponAppliedResponse = "";

//   Map<String, dynamic> comboMap = {};

//   String coursePrice = "";

//   //If it is false amountpayble showed will be the amount fetched from db
//   //If it is true which will be set to true if when right coupon code is
//   //applied and the amountpayble will be set using appludiscount to the finalamountpayble variable
//   // declared below same for discount
//   bool NoCouponApplied = true;

//   bool isPayButtonPressed = false;

//   bool isPayInPartsPressed = false;

//   bool isMinAmountCheckerPressed = false;

//   bool isOutStandingAmountCheckerPressed = false;

//   String finalamountToDisplay = "";

//   String finalAmountToPay = "";

//   String discountedPrice = "";

//   String name = "";
//   var vid;
//   int? index;

//   GlobalKey _positionKey = GlobalKey();

//   var uid = FirebaseAuth.instance.currentUser!.uid;
//   var moneyrefcode;
//   var moneyreferalcode;
//   var moneyreferallink;

//   List<CourseDetails> featuredCourse = [];

//   setFeaturedCourse(List<CourseDetails> course) {
//     featuredCourse.clear();

//     course.forEach((element) {
//       print(' $element ');
//       if (element.courseDocumentId == widget.cID) {
//         featuredCourse.add(element);
//         // featuredCourse.add(element.courses);

//         print('element ${featuredCourse[0].courseId} ');
//       }
//       vid = element.courseDocumentId;
//     });
//     print('function ');
//     print("featured course is===$featuredCourse");
//   }

//   void url_del() {
//     FirebaseFirestore.instance.collection('Notice')
//       ..doc("7A85zuoLi4YQpbXlbOAh_redirect")
//           .update({'url': ""}).whenComplete(() {
//         print('feature Deleted');
//       });
//   }

//   void lookformoneyref() async {
//     try {
//       await FirebaseFirestore.instance
//           .collection("Users_dataly")
//           .doc(uid)
//           .get()
//           .then((value) => {moneyrefcode = value.data()!["moneyrefcode"]});
//     } catch (e) {}
//     try {
//       print("moneyrefcode: ${moneyrefcode}");
//       moneyreferalcode = await CodeGenerator()
//           .generateCodeformoneyreward('moneyreward-$courseId');
//       moneyreferallink =
//           await DeepLinkService.instance?.createReferLink(moneyreferalcode);
//       print("this is the kings enargy: ${moneyreferallink}");
//       if (moneyrefcode == null) {
//         FirebaseFirestore.instance.collection("Users_dataly").doc(uid).update({
//           "moneyrefcode": "$moneyreferalcode",
//         });
//       }
//     } catch (e) {}
//   }

//   void getCourseName() async {
//     print('this idd ${widget.cID}');
//     await FirebaseFirestore.instance
//         .collection('courses')
//         .doc(widget.cID)
//         .get()
//         .then((value) {
//       setState(() {
//         comboMap = value.data()!;
//         print('this is $courseId');
//         print('this is $comboMap');
//         print(value.data()![id]);
//         print('cid is ${comboMap['trialCourse']} ${int.parse(widget.id!)}');

//         coursePrice = value.data()!['Course Price'];
//         name = value.data()!['name'];
//         print('ufbufb--$name');
//         print('fcc $featuredCourse');
//       });
//     });
//   }

//   Map userMap = Map<String, dynamic>();

//   void dbCheckerForPayInParts() async {
//     try {
//       DocumentSnapshot userDocs = await FirebaseFirestore.instance
//           .collection("Users_dataly")
//           .doc(FirebaseAuth.instance.currentUser!.uid)
//           .get();
//       // print(map['payInPartsDetails'][id]['outStandingAmtPaid']);
//       setState(() {
//         userMap = userDocs.data() as Map<String, dynamic>;
//         // whetherSubScribedToPayInParts =
//         //     !(!(map['payInPartsDetails']['outStandingAmtPaid'] == null));
//       });
//     } catch (e) {
//       print("ggggggggggg $e");
//     }
//   }

//   FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   FirebaseAuth _auth = FirebaseAuth.instance;

//   void loadCourses() async {
//     await _firestore.collection("courses").doc(widget.cID).get().then((value) {
//       print(_auth.currentUser!.displayName);
//       Map<String, dynamic> groupData = {
//         "name": value.data()!['name'],
//         "icon": value.data()!["image_url"],
//         "mentors": value.data()!["mentors"],
//         "student_id": _auth.currentUser!.uid,
//         "student_name": _auth.currentUser!.displayName,
//         'groupChatCountNew': {
//           'jbG4j36JiihVuZmpoLov2lhrWF02': 0,
//           'QVtxxzHyc6az2LPpvH210lUOeXl1': 0,
//           "2AS3AK7WVQaAMY999D3xf5ycG3h1": 0,
//           'a2WWgtY2ikS8xjCxra0GEfRft5N2': 0,
//           'BX9662ZGi4MfO4C9CvJm4u2JFo63': 0,
//           '6RsvdRETWmXf1pyVGqCUl0qEDmF2': 0,
//           'jeYDhaZCRWW4EC9qZ0YTHKz4PH63': 0,
//           'I6uXWtzpimTYxtGqEXcM9AXcoAi2': 0,
//           'Kr4pX5EZ6CfigOd5C1xjdIYzMml2': 0,
//           'XhcpQzd6cjXF43gCmna1agAfS2A2': 0,
//           'fKHHbDBbbySVJZu2NMAVVIYZZpu2': 0,
//           'oQQ9CrJ8FkP06OoGdrtcwSwY89q1': 0,
//           'rR0oKFMCaOYIlblKzrjYoYMW3Vl1': 0,
//           'v66PnlwqWERgcCDA6ZZLbI0mHPF2': 0,
//           'TOV5h3ezQhWGTb5cCVvBPca1Iqh1': 0,
//           [_auth.currentUser!.uid]: 0
//         },
//       };
//       _firestore.collection("groups_dataly").add(groupData);
//     });
//   }

//   void trialCourse() async {
//     print(
//         'this is name  : ${userMap['name']} ${widget.cID} ${FirebaseAuth.instance.currentUser!.uid} ${widget.cName}');

//     try {
//       // Map data = {
//       //   "uid": "639Fr79OeBheQclDJiVI1pf9lQd2",
//       //   "cid": "aEGX6kMfHzQrVgP3WCwU",
//       //   "uname": "Dipen",
//       //   "cname": "Data Science & Analytics Placement",
//       // };

//       // Map data = {
//       //   "uid": FirebaseAuth.instance.currentUser!.uid,
//       //   "cid": widget.cID,
//       //   "uname": userMap['name'],
//       //   "cname": widget.cName,
//       // };
//       //encode Map to JSON
//       // var body = json.encode(data);

//       var url = Uri.parse(
//           'https://us-central1-cloudyml-app.cloudfunctions.net/exceluser/trialAccess');
//       final response = await http.post(url, headers: {
//         "Access-Control-Allow-Origin": "*", // Required for CORS support to work
//         "Access-Control-Allow-Methods": "GET, POST",
//       }, body: {
//         "uid": FirebaseAuth.instance.currentUser!.uid,
//         "cid": featuredCourse[0].courseId,
//         "uname": userMap['name'],
//         "cname": widget.cName,
//       });
//       // print('this is body ${body.toString()}');

//       print(response.statusCode);
//     } catch (e) {
//       print('this is api error ${e.toString()}');
//     }

//     // if (userMap['paidCourseNames'].contains(featuredCourse[int.parse(widget.id!)].courseId)) {
//     //   Fluttertoast.showToast(msg: 'This course already exist in your trial course...');
//     //   Navigator.of(context).pop();
//     // } else {
//     //   print('paidCourseNames before ${userMap['paidCourseNames']}');
//     //
//     //   setState(() async {
//     //
//     //
//     //
//     //     // userMap['paidCourseNames'].add(featuredCourse[int.parse(widget.id!)].courseId);
//     //     // FirebaseFirestore.instance.collection("Users_dataly")
//     //     //     .doc(FirebaseAuth.instance.currentUser!.uid)
//     //     //     .update({
//     //     //   'paidCourseNames': userMap['paidCourseNames'],
//     //     //   'trialCourseList': [featuredCourse[int.parse(widget.id!)].courseId],
//     //     // });
//     //     // featuredCourse[int.parse(widget.id!)].courseId
//     //     // loadCourses();
//     //
//     //   });
//     //   print('paidCourseNames ${userMap['paidCourseNames']}');
//     // }
//   }

//   void checkl() async {
//     CollectionReference users = FirebaseFirestore.instance.collection("Users_dataly");
//     var doc = await users.doc(FirebaseAuth.instance.currentUser!.uid).get();
//     if (doc.exists) {
//       Map<String, dynamic>? map = doc.data() as Map<String, dynamic>?;
//       if (map!.containsKey('trialCourseList')) {
//         // Replace field by the field you want to check.
//         var valueOfField = map['trialCourseList'];
//         print('i am in main if');

//       } else {
//         FirebaseFirestore.instance
//             .collection("Users_dataly")
//             .doc(FirebaseAuth.instance.currentUser!.uid)
//             .update({
//           'trialCourseList': "",
//         });

//         print('i am in main else');
//       }
//     }
//   }

 

//   @override
//   void initState() {
//     super.initState();

//     // print("i am in trial if");

//     //  FirebaseFirestore.instance.collection("Users_dataly")
//     //       .doc(FirebaseAuth.instance.currentUser!.uid)
//     //       .update({'trialCourseList':"",});

//     checkl();

//     getCourseName();
//     // print("vid is===${featuredCourse[int.parse(widget.id!)]}");
//     dbCheckerForPayInParts();
//     lookformoneyref();
//     _scrollController.addListener(_scrollListener);
//   }

//   void _scrollListener() {
//     RenderBox? box =
//         _positionKey.currentContext?.findRenderObject() as RenderBox;
//     Offset position = box.localToGlobal(Offset.zero); //this is global position
//     double pixels = position.dy;
//     FeatureCourses._closeBottomSheetAtInCombo.value = pixels;
//     FeatureCourses._currentPosition.value = _scrollController.position.pixels;
//     print(pixels);
//     print(_scrollController.position.pixels);
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     couponCodeController.dispose();
//     _scrollController.removeListener(_scrollListener);
//     _scrollController.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     List<CourseDetails> course = Provider.of<List<CourseDetails>>(context);
//     print("abcs is==${course[0].courseDocumentId}");
//     setFeaturedCourse(course);
//     url_del();
//     final screenHeight = MediaQuery.of(context).size.height;
//     final screenWidth = MediaQuery.of(context).size.width;
//     var verticalScale = screenHeight / mockUpHeight;
//     var horizontalScale = screenWidth / mockUpWidth;
//     return Scaffold(
//       // appBar: AppBar(
//       //   title: Center(
//       //     child: Text(
//       //       widget.cName!,
//       //       textScaleFactor:
//       //       min(horizontalScale, verticalScale),
//       //       style: TextStyle(
//       //           color: Color.fromRGBO(255, 255, 255, 1),
//       //           fontFamily: 'Poppins',
//       //           fontSize: 35,
//       //           letterSpacing: 0,
//       //           fontWeight: FontWeight.normal,
//       //           height: 1),
//       //     ),
//       //   ),
//       // ),
//       bottomSheet: comboMap['trialCourse'] != null && comboMap['trialCourse']
//           ? PayNowBottomSheetfeature(
//               currentPosition: FeatureCourses._currentPosition,
//               coursePrice: '₹${widget.courseP!}/-',
//               map: comboMap,
//               popBottomSheetAt: FeatureCourses._closeBottomSheetAtInCombo,
//               isItComboCourse: true,
//               cID: widget.cID!,
//             )
//           : PayNowBottomSheet(
//               currentPosition: FeatureCourses._currentPosition,
//               coursePrice: '₹${widget.courseP!}/-',
//               map: comboMap,
//               popBottomSheetAt: FeatureCourses._closeBottomSheetAtInCombo,
//               isItComboCourse: true,
//               cID: widget.cID!,
//             ),
//       body: Stack(
//         children: [
//           SingleChildScrollView(
//             controller: _scrollController,
//             child: Column(
//               children: [
//                 SizedBox(
//                   height: 100,
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
//                   child: Align(
//                     alignment: Alignment.topLeft,
//                     child: Text(
//                       'Courses you get(Scroll Down To See More)',
//                       textAlign: TextAlign.left,
//                       style: TextStyle(
//                           color: Color.fromRGBO(48, 48, 49, 1),
//                           fontFamily: 'Poppins',
//                           fontSize: 20,
//                           letterSpacing:
//                               0 /*percentages not used in flutter. defaulting to zero*/,
//                           fontWeight: FontWeight.bold,
//                           height: 1),
//                     ),
//                   ),
//                 ),
//                 Container(
//                   width: screenWidth,
//                   height: 500 * verticalScale,
//                   child: MediaQuery.removePadding(
//                     context: context,
//                     removeTop: true,
//                     child: ListView.builder(
//                       // controller: _scrollController,
//                       scrollDirection: Axis.vertical,
//                       // physics: NeverScrollableScrollPhysics(),
//                       itemCount: course.length,
//                       itemBuilder: (BuildContext context, index) {
//                         print('Fc courses ');

//                         List courseList = [];
//                         for (var i in featuredCourse[0].courses) {
//                           for (var j in course) {
//                             if (i == j.courseId) {
//                               courseList.add(j);
//                             }
//                           }
//                         }

//                         if (course[index].courseName == "null") {
//                           return Container();
//                         }
//                         if (courseList.length != 0) {
//                           return Padding(
//                             padding: const EdgeInsets.only(
//                                 bottom: 8.0, top: 8, left: 20.0, right: 20.0),
//                             child: InkWell(
//                               onTap: () {
//                                 setState(() {
//                                   courseId = courseList[index].courseDocumentId;
//                                 });
//                                 final id = index.toString();
//                                 // GoRouter.of(context)
//                                 //     .pushNamed('catalogue', queryParams: {
//                                 //   'id': id,
//                                 //   'cID': courseId,
//                                 // });
//                               },
//                               child: Container(
//                                 width: 354 * horizontalScale,
//                                 height: 133 * verticalScale,
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.only(
//                                     topLeft: Radius.circular(25),
//                                     topRight: Radius.circular(25),
//                                     bottomLeft: Radius.circular(25),
//                                     bottomRight: Radius.circular(25),
//                                   ),
//                                   boxShadow: [
//                                     BoxShadow(
//                                         color: Color.fromRGBO(
//                                           58,
//                                           57,
//                                           60,
//                                           0.57,
//                                         ),
//                                         offset: Offset(2, 2),
//                                         blurRadius: 3)
//                                   ],
//                                   color: Color.fromRGBO(233, 225, 252, 1),
//                                 ),
//                                 child: Row(
//                                   //card on combopage
//                                   mainAxisAlignment: MainAxisAlignment.start,
//                                   crossAxisAlignment:
//                                       CrossAxisAlignment.stretch,
//                                   children: [
//                                     SizedBox(width: 10),
//                                     ClipRRect(
//                                       borderRadius: BorderRadius.circular(25),
//                                       child: Container(
//                                         width: 130,
//                                         height: 111,
//                                         decoration: BoxDecoration(
//                                             borderRadius: BorderRadius.only(
//                                           topLeft: Radius.circular(20),
//                                           topRight: Radius.circular(20),
//                                           bottomLeft: Radius.circular(20),
//                                           bottomRight: Radius.circular(20),
//                                         )),
//                                         child: CachedNetworkImage(
//                                           imageUrl:
//                                               courseList[index].courseImageUrl,
//                                           placeholder: (context, url) => Center(
//                                               child:
//                                                   CircularProgressIndicator()),
//                                           errorWidget: (context, url, error) =>
//                                               Icon(Icons.error),
//                                         ),
//                                       ),
//                                     ),
//                                     SizedBox(width: 10),
//                                     Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceEvenly,
//                                       children: [
//                                         // SizedBox(
//                                         //   height: 10,
//                                         // ),
//                                         Container(
//                                           // width: 170,
//                                           // height: 42,
//                                           child: Text(
//                                             courseList[index].courseName,
//                                             textScaleFactor: min(
//                                                 horizontalScale, verticalScale),
//                                             maxLines: 3,
//                                             style: TextStyle(
//                                               color: Color.fromRGBO(0, 0, 0, 1),
//                                               fontFamily: 'Poppins',
//                                               fontSize: 26 * verticalScale,
//                                               letterSpacing: 0,
//                                               fontWeight: FontWeight.bold,
//                                               height: 1,
//                                             ),
//                                           ),
//                                         ),
//                                         // SizedBox(
//                                         //   height: 5,
//                                         // ),
//                                         Container(
//                                           width: 182 * horizontalScale,
//                                           // height: 30*verticalScale,
//                                           child: Text(
//                                             courseList[index].courseDescription,
//                                             maxLines: 5,
//                                             overflow: TextOverflow.ellipsis,
//                                             // overflow: TextOverflow.ellipsis,
//                                             textScaleFactor: min(
//                                                 horizontalScale, verticalScale),
//                                             style: TextStyle(
//                                                 color:
//                                                     Color.fromRGBO(0, 0, 0, 1),
//                                                 fontFamily: 'Poppins',
//                                                 fontSize: 18 * verticalScale,
//                                                 letterSpacing:
//                                                     0 /*percentages not used in flutter. defaulting to zero*/,
//                                                 fontWeight: FontWeight.normal,
//                                                 height: 1),
//                                           ),
//                                         ),
//                                         // Row(
//                                         //   children: [
//                                         //     Text(
//                                         //       course[index].coursePrice,
//                                         //       textAlign: TextAlign.left,
//                                         //       textScaleFactor: min(
//                                         //           horizontalScale,
//                                         //           verticalScale),
//                                         //       style: TextStyle(
//                                         //           color: Color.fromRGBO(
//                                         //               155, 117, 237, 1),
//                                         //           fontFamily: 'Poppins',
//                                         //           fontSize: 20,
//                                         //           letterSpacing:
//                                         //               0 /*percentages not used in flutter. defaulting to zero*/,
//                                         //           fontWeight: FontWeight.bold,
//                                         //           height: 1),
//                                         //     ),
//                                         //     SizedBox(
//                                         //       width: 40 * horizontalScale,
//                                         //     ),
//                                         //     Container(
//                                         //       width: 70 * horizontalScale,
//                                         //       height: 25 * verticalScale,
//                                         //       decoration: BoxDecoration(
//                                         //         borderRadius: BorderRadius.only(
//                                         //           topLeft: Radius.circular(50),
//                                         //           topRight: Radius.circular(50),
//                                         //           bottomLeft:
//                                         //               Radius.circular(50),
//                                         //           bottomRight:
//                                         //               Radius.circular(50),
//                                         //         ),
//                                         //         boxShadow: [
//                                         //           BoxShadow(
//                                         //               color: Color.fromRGBO(
//                                         //                   48,
//                                         //                   209,
//                                         //                   151,
//                                         //                   0.44999998807907104),
//                                         //               offset: Offset(0, 10),
//                                         //               blurRadius: 25)
//                                         //         ],
//                                         //         color: Color.fromRGBO(
//                                         //             48, 209, 151, 1),
//                                         //       ),
//                                         //       child: Center(
//                                         //         child: Text(
//                                         //           'Enroll now',
//                                         //           textAlign: TextAlign.left,
//                                         //           textScaleFactor: min(
//                                         //               horizontalScale,
//                                         //               verticalScale),
//                                         //           style: TextStyle(
//                                         //               color: Color.fromRGBO(
//                                         //                   255, 255, 255, 1),
//                                         //               fontFamily: 'Poppins',
//                                         //               fontSize: 10,
//                                         //               letterSpacing:
//                                         //                   0 /*percentages not used in flutter. defaulting to zero*/,
//                                         //               fontWeight:
//                                         //                   FontWeight.normal,
//                                         //               height: 1),
//                                         //         ),
//                                         //       ),
//                                         //     )
//                                         //   ],
//                                         // )
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           );
//                         } else {
//                           return Container();
//                         }
//                       },
//                     ),
//                   ),
//                 ),
//                 SizedBox(
//                   height: 20,
//                 ),
//                 includes(context),
//                 SizedBox(
//                   key: _positionKey,
//                   height: 20,
//                 ),

//                 // Container(
//                 //   key: _positionKey,
//                 // ),
//                 Ribbon(
//                   nearLength: 1,
//                   farLength: .5,
//                   title: ' ',
//                   titleStyle: TextStyle(
//                       color: Colors.black,
//                       // Colors.white,
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold),
//                   color: Color.fromARGB(255, 11, 139, 244),
//                   location: RibbonLocation.topStart,
//                   child: Padding(
//                     padding: const EdgeInsets.only(left: 50.0, right: 50),
//                     child: Container(
//                       //  key:key,
//                       // width: width * .9,
//                       // height: height * .5,
//                       color: Color.fromARGB(255, 24, 4, 104),
//                       child: Column(
//                         //  key:Gkey,
//                         children: [
//                           SizedBox(
//                             height: screenHeight * .03,
//                           ),
//                           Text(
//                             'Complete Course Fee',
//                             style: TextStyle(
//                                 fontFamily: 'Bold',
//                                 fontSize: 21,
//                                 color: Colors.white),
//                           ),
//                           SizedBox(
//                             height: 5,
//                           ),
//                           Text(
//                             '( Everything with Lifetime Access )',
//                             style: TextStyle(
//                                 fontFamily: 'Bold',
//                                 fontSize: 11,
//                                 color: Colors.white),
//                           ),
//                           SizedBox(
//                             height: 30,
//                           ),
//                           Text(
//                             '₹${widget.courseP!}/-',
//                             style: TextStyle(
//                                 fontFamily: 'Medium',
//                                 fontSize: 30,
//                                 color: Colors.white),
//                           ),
//                           SizedBox(height: 35),
//                           comboMap['trialCourse'] != null &&
//                                   comboMap['trialCourse']
//                               ? Container(
//                                   child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       userMap['paidCourseNames'].contains(
//                                               featuredCourse[0].courseId)
//                                           ? InkWell(
//                                               onTap: () {
//                                                 GoRouter.of(context).pushNamed(
//                                                     'newcomboCourse',
//                                                     queryParams: {
//                                                       'courseName':
//                                                           featuredCourse[0]
//                                                               .courseName,
//                                                       'id': "28",
//                                                     });
//                                               },
//                                               child: Container(
//                                                 decoration: BoxDecoration(
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             30),
//                                                     // boxShadow: [
//                                                     //   BoxShadow(
//                                                     //     color: Color.fromARGB(255, 176, 224, 250)
//                                                     //         .withOpacity(0.3),
//                                                     //     spreadRadius: 2,
//                                                     //     blurRadius: 3,
//                                                     //     offset: Offset(3,
//                                                     //         6), // changes position of shadow
//                                                     //   ),
//                                                     // ],
//                                                     color: Color.fromARGB(
//                                                         255, 119, 191, 249),
//                                                     gradient: gradient),
//                                                 height: screenHeight * .08,
//                                                 width: screenWidth / 3,
//                                                 child: Center(
//                                                   child: Text(
//                                                     'Continue Your Course',
//                                                     textAlign: TextAlign.center,
//                                                     style: TextStyle(
//                                                         color: Colors.white,
//                                                         fontSize:
//                                                             20 * verticalScale),
//                                                   ),
//                                                 ),
//                                               ),
//                                             )
//                                           : InkWell(
//                                               onTap: () {
//                                                 showDialog(
//                                                     context: context,
//                                                     builder: (context) {
//                                                       return AlertDialog(
//                                                         backgroundColor: Colors
//                                                                 .deepPurpleAccent[
//                                                             700],
//                                                         title: Center(
//                                                           child: Text(
//                                                             'Start Your ${featuredCourse[0].trialDays} Days Free Trial',
//                                                             style: TextStyle(
//                                                                 color: Colors
//                                                                     .white),
//                                                           ),
//                                                         ),
//                                                         content: Container(
//                                                           height:
//                                                               screenHeight * .5,
//                                                           width:
//                                                               screenWidth / 2.5,
//                                                           child: Column(
//                                                             mainAxisAlignment:
//                                                                 MainAxisAlignment
//                                                                     .center,
//                                                             children: [
//                                                               featureCPopup(
//                                                                 Icons
//                                                                     .video_file,
//                                                                 'Get Complete Access to videos and assignments',
//                                                                 horizontalScale,
//                                                                 verticalScale,
//                                                               ),
//                                                               featureCPopup(
//                                                                 Icons
//                                                                     .mobile_screen_share,
//                                                                 'Watch tutorial videos from any module',
//                                                                 horizontalScale,
//                                                                 verticalScale,
//                                                               ),
//                                                               featureCPopup(
//                                                                 Icons.assistant,
//                                                                 'Connect with Teaching Assistant for Doubt Clearance',
//                                                                 horizontalScale,
//                                                                 verticalScale,
//                                                               ),
//                                                               featureCPopup(
//                                                                 Icons
//                                                                     .mobile_friendly,
//                                                                 'Access videos and chat support over our Mobile App.',
//                                                                 horizontalScale,
//                                                                 verticalScale,
//                                                               ),
//                                                               SizedBox(
//                                                                 height: 17,
//                                                               ),
//                                                               Container(
//                                                                   height:
//                                                                       screenHeight /
//                                                                           8,
//                                                                   width:
//                                                                       screenWidth /
//                                                                           3.5,
//                                                                   decoration:
//                                                                       BoxDecoration(
//                                                                     borderRadius:
//                                                                         BorderRadius.circular(
//                                                                             10),
//                                                                     border: Border.all(
//                                                                         color: Colors
//                                                                             .white,
//                                                                         width:
//                                                                             0.5),
//                                                                     color: Colors
//                                                                         .white,
//                                                                   ),
//                                                                   child: Column(
//                                                                     mainAxisAlignment:
//                                                                         MainAxisAlignment
//                                                                             .center,
//                                                                     children: [
//                                                                       Row(
//                                                                         children: [
//                                                                           Expanded(
//                                                                             flex:
//                                                                                 1,
//                                                                             child:
//                                                                                 Container(
//                                                                               child: CircleAvatar(
//                                                                                 radius: 35,
//                                                                                 // borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
//                                                                                 child: Image.network(
//                                                                                   featuredCourse[0].courseImageUrl,
//                                                                                   fit: BoxFit.fill,
//                                                                                 ),
//                                                                               ),
//                                                                             ),
//                                                                           ),
//                                                                           Expanded(
//                                                                             child:
//                                                                                 Container(
//                                                                               child: Text(
//                                                                                 featuredCourse[0].courseName,
//                                                                                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
//                                                                                 overflow: TextOverflow.ellipsis,
//                                                                               ),
//                                                                             ),
//                                                                           ),
//                                                                         ],
//                                                                       )
//                                                                     ],
//                                                                   )),
//                                                               SizedBox(
//                                                                   height: 29 *
//                                                                       verticalScale),
//                                                               Row(
//                                                                 mainAxisAlignment:
//                                                                     MainAxisAlignment
//                                                                         .spaceBetween,
//                                                                 children: [
//                                                                   Container(
//                                                                     width:
//                                                                         screenWidth /
//                                                                             7,
//                                                                     decoration:
//                                                                         BoxDecoration(
//                                                                       borderRadius:
//                                                                           BorderRadius.circular(
//                                                                               10),
//                                                                       border: Border.all(
//                                                                           color: Colors
//                                                                               .white,
//                                                                           width:
//                                                                               0.5),
//                                                                     ),
//                                                                     child:
//                                                                         ElevatedButton(
//                                                                       onPressed:
//                                                                           () {
//                                                                         print(
//                                                                             'idd ${widget.id} ${featuredCourse[0].courseName}');
//                                                                         // print('this is condition ${userMap['paidCourseNames'].contains(featuredCourse[int.parse(widget.id!)].courseId)}');
//                                                                         Navigator.of(context)
//                                                                             .pop();
//                                                                       },
//                                                                       child:
//                                                                           Text(
//                                                                         'Close',
//                                                                         style: TextStyle(
//                                                                             color:
//                                                                                 Colors.white),
//                                                                       ),
//                                                                     ),
//                                                                   ),
//                                                                   Container(
//                                                                     decoration:
//                                                                         BoxDecoration(
//                                                                       borderRadius:
//                                                                           BorderRadius.circular(
//                                                                               10),
//                                                                       border: Border.all(
//                                                                           color: Colors
//                                                                               .white,
//                                                                           width:
//                                                                               0.5),
//                                                                     ),
//                                                                     child:
//                                                                         ElevatedButton(
//                                                                       onPressed:
//                                                                           () {
//                                                                         var paidcourse;
//                                                                         print(
//                                                                             userMap);

//                                                                         if (userMap['paidCourseNames']
//                                                                             .contains(featuredCourse[0].courseId)) {
//                                                                           Fluttertoast.showToast(
//                                                                               msg: 'You have already enrolled in this course.');
//                                                                         } else if (userMap['trialCourseList'] !=
//                                                                                 null &&
//                                                                             userMap['trialCourseList'].contains(featuredCourse[0].courseId)) {
//                                                                           // print("this is it====${course[index!].toString()}");
//                                                                           Fluttertoast.showToast(
//                                                                               msg: 'You have already tried this course... Please purchase the course.');
//                                                                         } else {
//                                                                           setState(
//                                                                               () {
//                                                                             trialCourse();

//                                                                             //  print("this is it====${course[index!].toString()}");

//                                                                             Fluttertoast.showToast(msg: 'Congrats!! Course is now available in enrolled courses for ${featuredCourse[0].trialDays}...');
//                                                                             Timer(
//                                                                                 Duration(seconds: 1),
//                                                                                 () => GoRouter.of(context).pushNamed('newcomboCourse', queryParams: {
//                                                                                       'courseName': featuredCourse[0].courseName,
//                                                                                       'id': "28",
//                                                                                     }));
//                                                                           });
//                                                                         }
//                                                                       },
//                                                                       child:
//                                                                           Text(
//                                                                         'Start your free trial',
//                                                                         style: TextStyle(
//                                                                             color:
//                                                                                 Colors.white),
//                                                                       ),
//                                                                     ),
//                                                                   ),
//                                                                 ],
//                                                               ),
//                                                             ],
//                                                           ),
//                                                         ),
//                                                       );
//                                                     });
//                                               },
//                                               child: Container(
//                                                 decoration: BoxDecoration(
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             30),
//                                                     // boxShadow: [
//                                                     //   BoxShadow(
//                                                     //     color: Color.fromARGB(255, 176, 224, 250)
//                                                     //         .withOpacity(0.3),
//                                                     //     spreadRadius: 2,
//                                                     //     blurRadius: 3,
//                                                     //     offset: Offset(3,
//                                                     //         6), // changes position of shadow
//                                                     //   ),
//                                                     // ],
//                                                     color: Color.fromARGB(
//                                                         255, 119, 191, 249),
//                                                     gradient: gradient),
//                                                 height: screenHeight * .08,
//                                                 width: screenWidth / 2.5,
//                                                 child: Center(
//                                                   child: Text(
//                                                     'Start your free trial now',
//                                                     textAlign: TextAlign.center,
//                                                     style: TextStyle(
//                                                         color: Colors.white,
//                                                         fontSize:
//                                                             20 * verticalScale),
//                                                   ),
//                                                 ),
//                                               ),
//                                             ),
//                                       SizedBox(width: 20),
//                                       InkWell(
//                                         onTap: () {
//                                           // GoRouter.of(context)
//                                           //     .pushNamed(
//                                           //     'paymentScreen',
//                                           //     queryParams: {
//                                           //       'isItComboCourse': true,
//                                           //       'courseMap': comboMap,
//                                           //     }
//                                           // );

//                                           GoRouter.of(context).pushNamed(
//                                               'comboPaymentPortal',
//                                               queryParams: {
//                                                 'cID': widget.cID,
//                                               });

//                                           // Navigator.push(
//                                           //   context,
//                                           //   MaterialPageRoute(
//                                           //     builder: (context) => PaymentScreen(
//                                           //       map: comboMap,
//                                           //       isItComboCourse: true,
//                                           //       cID: widget.cID,
//                                           //     ),
//                                           //   ),
//                                           // );
//                                         },
//                                         child: Container(
//                                           decoration: BoxDecoration(
//                                               borderRadius:
//                                                   BorderRadius.circular(30),
//                                               // boxShadow: [
//                                               //   BoxShadow(
//                                               //     color: Color.fromARGB(255, 176, 224, 250)
//                                               //         .withOpacity(0.3),
//                                               //     spreadRadius: 2,
//                                               //     blurRadius: 3,
//                                               //     offset: Offset(3,
//                                               //         6), // changes position of shadow
//                                               //   ),
//                                               // ],
//                                               color: Color.fromARGB(
//                                                   255, 119, 191, 249),
//                                               gradient: gradient),
//                                           height: screenHeight * .08,
//                                           width: screenWidth / 3,
//                                           child: Center(
//                                             child: Text(
//                                               'Buy Now',
//                                               textAlign: TextAlign.center,
//                                               style: TextStyle(
//                                                   color: Colors.white,
//                                                   fontSize: 20 * verticalScale),
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 )
//                               : InkWell(
//                                   onTap: () {
//                                     GoRouter.of(context).pushNamed(
//                                         'comboPaymentPortal',
//                                         queryParams: {
//                                           'cID': widget.cID,
//                                         });

//                                     // Navigator.push(
//                                     //   context,
//                                     //   MaterialPageRoute(
//                                     //     builder: (context) => PaymentScreen(
//                                     //       map: comboMap,
//                                     //       isItComboCourse: true,
//                                     //       cID: widget.cID,
//                                     //     ),
//                                     //   ),
//                                     // );
//                                   },
//                                   child: Container(
//                                     decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(30),
//                                         // boxShadow: [
//                                         //   BoxShadow(
//                                         //     color: Color.fromARGB(255, 176, 224, 250)
//                                         //         .withOpacity(0.3),
//                                         //     spreadRadius: 2,
//                                         //     blurRadius: 3,
//                                         //     offset: Offset(3,
//                                         //         6), // changes position of shadow
//                                         //   ),
//                                         // ],
//                                         color:
//                                             Color.fromARGB(255, 119, 191, 249),
//                                         gradient: gradient),
//                                     height: screenHeight * .08,
//                                     width: screenWidth * .6,
//                                     child: Center(
//                                       child: Text(
//                                         'Buy Now',
//                                         textAlign: TextAlign.center,
//                                         style: TextStyle(
//                                             color: Colors.white,
//                                             fontSize: 20 * verticalScale),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             width: 414 * horizontalScale,
//             height: 100 * verticalScale,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(0),
//                 topRight: Radius.circular(0),
//                 bottomLeft: Radius.circular(25),
//                 bottomRight: Radius.circular(25),
//               ),
//               color: Color.fromRGBO(122, 98, 222, 1),
//             ),
//             child: Stack(
//               children: [
//                 Positioned(
//                   top: -15 * verticalScale,
//                   right: -15 * horizontalScale,
//                   child: Container(
//                     width: 128 * min(horizontalScale, verticalScale),
//                     height: 128 * min(verticalScale, horizontalScale),
//                     decoration: BoxDecoration(
//                       color: Color.fromRGBO(129, 105, 229, 1),
//                       borderRadius: BorderRadius.all(
//                         Radius.elliptical(128, 128),
//                       ),
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                   top: 80 * verticalScale,
//                   left: -31 * horizontalScale,
//                   child: Container(
//                     width: 62 * min(horizontalScale, verticalScale),
//                     height: 62 * min(verticalScale, horizontalScale),
//                     decoration: BoxDecoration(
//                       color: Color.fromRGBO(129, 105, 229, 1),
//                       borderRadius: BorderRadius.all(
//                         Radius.elliptical(62, 62),
//                       ),
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                   top: 25 * verticalScale,
//                   left: 15 * horizontalScale,
//                   child: Container(
//                     // width: 230,
//                     // height: 81,
//                     child: Row(
//                       children: [
//                         InkWell(
//                           onTap: () {
//                             // Navigator.of(context).pop();
//                             GoRouter.of(context).push('/home');
//                           },
//                           child: Icon(
//                             Icons.arrow_back,
//                             color: Colors.white,
//                             size: 30 * min(horizontalScale, verticalScale),
//                           ),
//                         ),
//                         SizedBox(width: 10),
//                         Center(
//                           child: Text(
//                             widget.cName!,
//                             textScaleFactor:
//                                 min(horizontalScale, verticalScale),
//                             style: TextStyle(
//                                 color: Color.fromRGBO(255, 255, 255, 1),
//                                 fontFamily: 'Poppins',
//                                 fontSize: 35,
//                                 letterSpacing: 0,
//                                 fontWeight: FontWeight.normal,
//                                 height: 1),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 // Positioned(
//                 //   top: 25 * verticalScale,
//                 //   right: 15 * horizontalScale,
//                 //   child: IconButton(
//                 //     icon: const Icon(
//                 //       Icons.share,
//                 //       color: Colors.black,
//                 //     ),
//                 //     onPressed: () async {
//                 //       if (moneyreferallink.toString() != 'null') {
//                 //         ShareExtend.share(moneyreferallink.toString(), "text");
//                 //       }
//                 //     },
//                 //   ),)
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
