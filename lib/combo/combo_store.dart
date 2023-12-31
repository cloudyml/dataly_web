import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudyml_app2/models/course_details.dart';
import 'package:cloudyml_app2/widgets/coupon_code.dart';
import 'package:cloudyml_app2/fun.dart';
import 'package:cloudyml_app2/globals.dart';
import 'package:cloudyml_app2/catalogue_screen.dart';
import 'package:cloudyml_app2/payment_screen.dart';
import 'package:cloudyml_app2/widgets/pay_now_bottomsheet.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ribbon_widget/ribbon_widget.dart';
import 'package:share_extend/share_extend.dart';

import '../Services/code_generator.dart';
import '../Services/deeplink_service.dart';

class ComboStore extends StatefulWidget {
  final String? id;
  final String? cName;
  final String? courseP;
  final String? cID;
  final List<dynamic>? courses;

  static ValueNotifier<String> coursePrice = ValueNotifier('');
  static ValueNotifier<Map<String, dynamic>>? map = ValueNotifier({});
  static ValueNotifier<double> _currentPosition = ValueNotifier<double>(0.0);
  static ValueNotifier<double> _closeBottomSheetAtInCombo =
  ValueNotifier<double>(0.0);
  ComboStore({Key? key, this.courses, this.id, this.cName, this.courseP, this.cID}) : super(key: key);

  @override
  State<ComboStore> createState() => _ComboStoreState();
}

class _ComboStoreState extends State<ComboStore> with CouponCodeMixin {
  // var _razorpay = Razorpay();
  var amountcontroller = TextEditingController();
  TextEditingController couponCodeController = TextEditingController();
  String? id;
  final ScrollController _scrollController = ScrollController();

  String couponAppliedResponse = "";

  Map<String, dynamic> comboMap = {};

  String coursePrice = "";

  //If it is false amountpayble showed will be the amount fetched from db
  //If it is true which will be set to true if when right coupon code is
  //applied and the amountpayble will be set using appludiscount to the finalamountpayble variable
  // declared below same for discount
  bool NoCouponApplied = true;

  bool isPayButtonPressed = false;

  bool isPayInPartsPressed = false;

  bool isMinAmountCheckerPressed = false;

  bool isOutStandingAmountCheckerPressed = false;

  String finalamountToDisplay = "";

  String finalAmountToPay = "";

  String discountedPrice = "";

  String name = "";

  GlobalKey _positionKey = GlobalKey();

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

  void getCourseName() async {
    await FirebaseFirestore.instance
        .collection('courses')
        .doc(courseId)
        .get()
        .then((value) {
      setState(() {
        comboMap = value.data()!;
        coursePrice = value.data()!['Course Price'];
        name = value.data()!['name'];
        print('ufbufb--$name');
        print("this is -- $courseId");
      });
    });
  }

  @override
  void initState() {
    super.initState();
    lookformoneyref();
    getCourseName();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    RenderBox? box =
    _positionKey.currentContext?.findRenderObject() as RenderBox;
    Offset position = box.localToGlobal(Offset.zero); //this is global position
    double pixels = position.dy;
    ComboStore._closeBottomSheetAtInCombo.value = pixels;
    ComboStore._currentPosition.value = _scrollController.position.pixels;
    print(pixels);
    print(_scrollController.position.pixels);
  }

  @override
  void dispose() {
    super.dispose();
    couponCodeController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<CourseDetails> course = Provider.of<List<CourseDetails>>(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    var verticalScale = screenHeight / mockUpHeight;
    var horizontalScale = screenWidth / mockUpWidth;
    return Scaffold(
      bottomSheet: PayNowBottomSheet(
        currentPosition: ComboStore._currentPosition,
        coursePrice: '₹${widget.courseP!}/-',
        map: comboMap,
        popBottomSheetAt: ComboStore._closeBottomSheetAtInCombo,
        isItComboCourse: true,
        cID: courseId!,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                SizedBox(
                  height: 100,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Courses you get(Scroll Down To See More)',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          color: Color.fromRGBO(48, 48, 49, 1),
                          fontFamily: 'Poppins',
                          fontSize: 20,
                          letterSpacing:
                          0 /*percentages not used in flutter. defaulting to zero*/,
                          fontWeight: FontWeight.bold,
                          height: 1),
                    ),
                  ),
                ),
                Container(
                  width: screenWidth,
                  height: 500 * verticalScale,
                  child: MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: ListView.builder(
                      // controller: _scrollController,
                      scrollDirection: Axis.vertical,
                      // physics: NeverScrollableScrollPhysics(),
                      itemCount: course.length,
                      itemBuilder: (BuildContext context, index) {
                        if (course[index].courseName == "null") {
                          return Container();
                        }
                        if (widget.courses!.contains(course[index].courseId)) {
                          return Padding(
                            padding: const EdgeInsets.only(
                                bottom: 8.0, top: 8, left: 20.0, right: 20.0),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  courseId = course[index].courseDocumentId;
                                });
                                final id = index.toString();
                              GoRouter.of(context).pushNamed(
                                  'catalogue',
                                  queryParams: {'id': id,'cID': courseId,});
                              },
                              child: Container(
                                width: 354 * horizontalScale,
                                height: 133 * verticalScale,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(25),
                                    topRight: Radius.circular(25),
                                    bottomLeft: Radius.circular(25),
                                    bottomRight: Radius.circular(25),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Color.fromRGBO(
                                          58,
                                          57,
                                          60,
                                          0.57,
                                        ),
                                        offset: Offset(2, 2),
                                        blurRadius: 3)
                                  ],
                                  color: Color.fromRGBO(233, 225, 252, 1),
                                ),
                                child: Row(
                                  //card on combopage
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment:
                                  CrossAxisAlignment.stretch,
                                  children: [
                                    SizedBox(width: 10),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(25),
                                      child: Container(
                                        width: 130,
                                        height: 111,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(20),
                                              topRight: Radius.circular(20),
                                              bottomLeft: Radius.circular(20),
                                              bottomRight: Radius.circular(20),
                                            )),
                                        child: CachedNetworkImage(
                                          imageUrl:
                                          course[index].courseImageUrl,
                                          placeholder: (context, url) =>
                                              Center(child: CircularProgressIndicator()),
                                          errorWidget: (context, url, error) =>
                                              Icon(Icons.error),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                      children: [
                                        // SizedBox(
                                        //   height: 10,
                                        // ),
                                        Container(
                                          // width: 170,
                                          // height: 42,
                                          child: Text(
                                            course[index].courseName,
                                            textScaleFactor: min(
                                                horizontalScale, verticalScale),
                                            style: TextStyle(
                                              color: Color.fromRGBO(0, 0, 0, 1),
                                              fontFamily: 'Poppins',
                                              fontSize: 26,
                                              letterSpacing: 0,
                                              fontWeight: FontWeight.bold,
                                              height: 1,
                                            ),
                                          ),
                                        ),
                                        // SizedBox(
                                        //   height: 5,
                                        // ),
                                        Container(
                                          width: 220 * horizontalScale,
                                          // height: 24.000001907348633,
                                          child: Text(
                                            course[index].courseDescription,
                                            // overflow: TextOverflow.ellipsis,
                                            maxLines: 4,
                                            textScaleFactor: min(
                                                horizontalScale, verticalScale),
                                            style: TextStyle(
                                                color:
                                                Color.fromRGBO(0, 0, 0, 1),
                                                fontFamily: 'Poppins',
                                                fontSize: 18,
                                                letterSpacing:
                                                0 /*percentages not used in flutter. defaulting to zero*/,
                                                fontWeight: FontWeight.normal,
                                                height: 1),
                                          ),
                                        ),
                                        // Row(
                                        //   children: [
                                        //     Text(
                                        //       course[index].coursePrice,
                                        //       textAlign: TextAlign.left,
                                        //       textScaleFactor: min(
                                        //           horizontalScale,
                                        //           verticalScale),
                                        //       style: TextStyle(
                                        //           color: Color.fromRGBO(
                                        //               155, 117, 237, 1),
                                        //           fontFamily: 'Poppins',
                                        //           fontSize: 20,
                                        //           letterSpacing:
                                        //               0 /*percentages not used in flutter. defaulting to zero*/,
                                        //           fontWeight: FontWeight.bold,
                                        //           height: 1),
                                        //     ),
                                        //     SizedBox(
                                        //       width: 40 * horizontalScale,
                                        //     ),
                                        //     Container(
                                        //       width: 70 * horizontalScale,
                                        //       height: 25 * verticalScale,
                                        //       decoration: BoxDecoration(
                                        //         borderRadius: BorderRadius.only(
                                        //           topLeft: Radius.circular(50),
                                        //           topRight: Radius.circular(50),
                                        //           bottomLeft:
                                        //               Radius.circular(50),
                                        //           bottomRight:
                                        //               Radius.circular(50),
                                        //         ),
                                        //         boxShadow: [
                                        //           BoxShadow(
                                        //               color: Color.fromRGBO(
                                        //                   48,
                                        //                   209,
                                        //                   151,
                                        //                   0.44999998807907104),
                                        //               offset: Offset(0, 10),
                                        //               blurRadius: 25)
                                        //         ],
                                        //         color: Color.fromRGBO(
                                        //             48, 209, 151, 1),
                                        //       ),
                                        //       child: Center(
                                        //         child: Text(
                                        //           'Enroll now',
                                        //           textAlign: TextAlign.left,
                                        //           textScaleFactor: min(
                                        //               horizontalScale,
                                        //               verticalScale),
                                        //           style: TextStyle(
                                        //               color: Color.fromRGBO(
                                        //                   255, 255, 255, 1),
                                        //               fontFamily: 'Poppins',
                                        //               fontSize: 10,
                                        //               letterSpacing:
                                        //                   0 /*percentages not used in flutter. defaulting to zero*/,
                                        //               fontWeight:
                                        //                   FontWeight.normal,
                                        //               height: 1),
                                        //         ),
                                        //       ),
                                        //     )
                                        //   ],
                                        // )
                                      ],
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
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                includes(context),
                SizedBox(
                  key: _positionKey,
                  height: 20,
                ),

                // Container(
                //   key: _positionKey,
                // ),
                Ribbon(
                  nearLength: 1,
                  farLength: .5,
                  title: ' ',
                  titleStyle: TextStyle(
                      color: Colors.black,
                      // Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                  color: Color.fromARGB(255, 11, 139, 244),
                  location: RibbonLocation.topStart,
                  child: Container(
                    //  key:key,
                    // width: width * .9,
                    // height: height * .5,
                    color: Color.fromARGB(255, 24, 4, 104),
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Column(
                        //  key:Gkey,
                        children: [
                          SizedBox(
                            height: screenHeight * .03,
                          ),
                          Text(
                            'Complete Course Fee',
                            style: TextStyle(
                                fontFamily: 'Bold',
                                fontSize: 21,
                                color: Colors.white),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            '( Everything with Lifetime Access )',
                            style: TextStyle(
                                fontFamily: 'Bold',
                                fontSize: 11,
                                color: Colors.white),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Text(
                            '₹${widget.courseP!}/-',
                            style: TextStyle(
                                fontFamily: 'Medium',
                                fontSize: 30,
                                color: Colors.white),
                          ),
                          SizedBox(height: 35),
                          InkWell(
                            onTap: () {

                              GoRouter.of(context).pushNamed('paymentPortal',
                                  queryParams: {
                                    'cID': courseId});


                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) => PaymentScreen(
                              //       map: comboMap,
                              //       isItComboCourse: true,
                              //     ),
                              //   ),
                              // );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  // boxShadow: [
                                  //   BoxShadow(
                                  //     color: Color.fromARGB(255, 176, 224, 250)
                                  //         .withOpacity(0.3),
                                  //     spreadRadius: 2,
                                  //     blurRadius: 3,
                                  //     offset: Offset(3,
                                  //         6), // changes position of shadow
                                  //   ),
                                  // ],
                                  color: Color.fromARGB(255, 119, 191, 249),
                                  gradient: gradient),
                              height: screenHeight * .08,
                              width: screenWidth * .6,
                              child: Center(
                                child: Text(
                                  'Buy Now',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 414 * horizontalScale,
            height: 100 * verticalScale,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(0),
                topRight: Radius.circular(0),
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
              color: Color.fromRGBO(122, 98, 222, 1),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -15 * verticalScale,
                  right: -15 * horizontalScale,
                  child: Container(
                    width: 128 * min(horizontalScale, verticalScale),
                    height: 128 * min(verticalScale, horizontalScale),
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(129, 105, 229, 1),
                      borderRadius: BorderRadius.all(
                        Radius.elliptical(128, 128),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 80 * verticalScale,
                  left: -31 * horizontalScale,
                  child: Container(
                    width: 62 * min(horizontalScale, verticalScale),
                    height: 62 * min(verticalScale, horizontalScale),
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(129, 105, 229, 1),
                      borderRadius: BorderRadius.all(
                        Radius.elliptical(62, 62),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 25 * verticalScale,
                  left: 15 * horizontalScale,
                  child: Container(
                    // width: 230,
                    // height: 81,
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                            // GoRouter.of(context).push('/home');
                          },
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 30 * min(horizontalScale, verticalScale),
                          ),
                        ),
                        SizedBox(width: 10),
                        Center(
                          child: Text(
                            widget.cName!,
                            textScaleFactor:
                            min(horizontalScale, verticalScale),
                            style: TextStyle(
                                color: Color.fromRGBO(255, 255, 255, 1),
                                fontFamily: 'Poppins',
                                fontSize: 35,
                                letterSpacing: 0,
                                fontWeight: FontWeight.normal,
                                height: 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Positioned(
                //   top: 25 * verticalScale,
                //   right: 15 * horizontalScale,
                //   child: IconButton(
                //     icon: const Icon(
                //       Icons.share,
                //       color: Colors.black,
                //     ),
                //     onPressed: () async {
                //       if (moneyreferallink.toString() != 'null') {
                //         ShareExtend.share(moneyreferallink.toString(), "text");
                //       }
                //     },
                //   ),)
              ],
            ),
          ),
        ],
      ),
    );
  }
}