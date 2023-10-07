import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudyml_app2/Providers/UserProvider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_web/razorpay_web.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:toast/toast.dart';
import 'package:upi_plugin/upi_plugin.dart';
import 'package:cloudyml_app2/widgets/coupon_code.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloudyml_app2/globals.dart';
import 'package:cloudyml_app2/global_variable.dart' as globals;
import 'package:url_launcher/url_launcher.dart';
import 'dart:html' as html;

class PaymentButton extends StatefulWidget {
  final ScrollController scrollController;
  final String couponCodeText;
  bool isPayButtonPressed;
  final Function changeState;
  final bool NoCouponApplied;
  final String buttonText;
  final String buttonTextForCode;
  final String amountString;
  final String courseName;
  final String courseImageUrl;
  final String courseDescription;
  // final Razorpay razorpay;
  final Function updateCourseIdToCouponDetails;
  final String? whichCouponCode;
  final String outStandingAmountString;
  bool isItComboCourse;
  int coursePriceMoneyRef;
  String couponCode;
  bool couponcodeused;
  String courseId;

  // String courseFetchedId;

  PaymentButton(
      {Key? key,
      required this.scrollController,
      required this.isPayButtonPressed,
      required this.changeState,
      required this.NoCouponApplied,
      required this.buttonText,
      required this.courseImageUrl,
      required this.buttonTextForCode,
      required this.amountString,
      required this.courseName,
      required this.courseDescription,
      required this.updateCourseIdToCouponDetails,
      required this.outStandingAmountString,
      required this.courseId,
      required this.couponCodeText,
      required this.isItComboCourse,
      required this.whichCouponCode,
      required this.coursePriceMoneyRef,
      required this.couponcodeused,
      required this.couponCode})
      : super(key: key);

  @override
  State<PaymentButton> createState() => _PaymentButtonState();
}

class _PaymentButtonState extends State<PaymentButton> with CouponCodeMixin {
  bool isPayInPartsPressed = false;
  bool isMinAmountCheckerPressed = false;
  bool isOutStandingAmountCheckerPressed = false;
  bool whetherMinAmtBtnEnabled = true;
  bool whetherOutstandingAmtBtnEnabled = false;
  var order_id;

  Map userData = Map<String, dynamic>();
  var _razorpay = Razorpay();

  Future<String> intiateUpiTransaction(String appName) async {
    String response = await UpiTransaction.initiateTransaction(
      app: appName,
      pa: 'cloudyml@icici',
      pn: 'CloudyML',
      mc: null,
      tr: null,
      tn: null,
      am: amountStringForUPI,
      cu: 'INR',
      url: 'https://www.cloudyml.com/',
      mode: null,
      orgid: null,
    );
    return response;
  }

  String? amountStringForRp;
  String? amountStringForUPI;
  List? courseList = [];
  bool isLoading = false;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  String? id;

  var key_id;
  var key_secret;

  loadCourses() async {
    try {
      var url = Uri.parse(
          'https://us-central1-cloudyml-app.cloudfunctions.net/adduser/addgroup');
      await http.post(url, headers: {
        "Access-Control-Allow-Origin": "*", // Required for CORS support to work
        "Access-Control-Allow-Methods": "GET, POST,OPTIONS"
      }, body: {
        "sname": userData["name"],
        "sid": _auth.currentUser!.uid,
        "cname": widget.courseName,
        "image": widget.courseImageUrl,
        "cid": widget.courseId
      });

      var mailurl = Uri.parse(
          'https://us-central1-cloudyml-app.cloudfunctions.net/exceluser/coursemail');
      // final response =
      await http.post(mailurl, headers: {
        "Access-Control-Allow-Origin": "*", // Required for CORS support to work
        "Access-Control-Allow-Methods": "GET, POST,OPTIONS"
      }, body: {
        "uid": _auth.currentUser!.uid,
        "cname": widget.courseName,
      });

      print("Mail Sent");
    } catch (e) {
      print(e);
    }

    try {
      print("couponcodeused1");
      print(widget.couponcodeused);
      if (widget.couponcodeused == true) {
        await calltoupdatecouponinuser();
      }
    } catch (e) {
      print("error id woiejiowie: ${e.toString()}");
    }

    pushToHome();
  }

  void updateAmoutStringForUPI(bool isPayInPartsPressed,
      bool isMinAmountCheckerPressed, bool isOutStandingAmountCheckerPressed) {
    if (isPayInPartsPressed) {
      if (isMinAmountCheckerPressed) {
        setState(() {
          amountStringForUPI = '1000.00';
        });
      } else if (isOutStandingAmountCheckerPressed) {
        setState(() {
          amountStringForUPI = widget.outStandingAmountString;
        });
      }
    } else {
      amountStringForUPI =
          (double.parse(widget.amountString) / 100).toStringAsFixed(2);
    }
  }

  void updateAmoutStringForRP(bool isPayInPartsPressed,
      bool isMinAmountCheckerPressed, bool isOutStandingAmountCheckerPressed) {
    if (isPayInPartsPressed) {
      if (isMinAmountCheckerPressed) {
        setState(() {
          amountStringForRp = '100000';
        });
      } else if (isOutStandingAmountCheckerPressed) {
        setState(() {
          amountStringForRp =
              (double.parse(widget.outStandingAmountString) * 100)
                  .toStringAsFixed(2);
        });
      }
    } else {
      setState(() {
        amountStringForRp = widget.amountString;
      });
    }
  }

  void getrzpkey() async {
    key_id = await FirebaseFirestore.instance
        .collection('Notice')
        .doc('razorpay_key_t0i1VbF9aPBZlB7PEanv')
        .get()
        .then((value) {
      return value.data()!['key_id']; // Access your after your get the data
    });

    key_secret = await FirebaseFirestore.instance
        .collection('Notice')
        .doc('razorpay_key_t0i1VbF9aPBZlB7PEanv')
        .get()
        .then((value) {
      return value.data()!['key_secret']; // Access your after your get the data
    });
    print("key_id is====$key_id");
    print("key_secret is====$key_secret");
  }

  Future<String> generateOrderId(
      String key, String secret, String amount) async {
    var authn = 'Basic ' + base64Encode(utf8.encode('$key:$secret'));

    var headers = {
      'content-type': 'application/json',
      'Authorization': authn,
    };

    var data =
        '{ "amount": $amount, "currency": "INR", "receipt": "receipt#R1", "payment_capture": 1 }'; // as per my experience the receipt doesn't play any role in helping you generate a certain pattern in your Order ID!!

    var res = await http.post(
        Uri.parse(
            'https://us-central1-cloudyml-app.cloudfunctions.net/order/order'),
        headers: headers,
        body: data);
    if (res.statusCode != 200)
      throw Exception('http.post error: statusCode= ${res.statusCode}');
    print('ORDER ID response => ${res.body}');

    // setState(() {
    //   order_id=json.decode(res.body)['id'].toString();
    // });

    order_id = json.decode(res.body)['order']['id'].toString();

    print(order_id);

    return json.decode(res.body)['order']['id'].toString();
  }

  //  generateOrderId('rzp_test_b1Dt1350qiF6cr',
  //       '4HwrQR9o2OSlzzF0MzJmaDdq', amountStringForRp!);

  @override
  void initState() {
    // loadGroup();
    print(widget.courseId);
    print(widget.courseName);
    getrzpkey();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    getPayInPartsDetails();
    updateAmoutStringForUPI(isPayInPartsPressed, isMinAmountCheckerPressed,
        isOutStandingAmountCheckerPressed);
    updateAmoutStringForRP(isPayInPartsPressed, isMinAmountCheckerPressed,
        isOutStandingAmountCheckerPressed);

    super.initState();
  }

  Future<void> _handlePaymentError(PaymentFailureResponse response) async {
    Toast.show("Payment failed");
    print("loadingpaymetn0: ${loadingpayment}");
    setState(() {
      loadingpayment.value = false;
    });
    print("Payment Fail");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print("External wallet");
  }

  void _purchasedCourses() async {
    print(userData["Email"]);
    var data = await FirebaseFirestore.instance
        .collection("AppPurchasedCourse")
        .limit(1)
        .orderBy("Time", descending: true)
        .get();
    print("data---${data.docs.length}");
    if (data.docs.length == 0) {
      await FirebaseFirestore.instance
          .collection("AppPurchasedCourse")
          .doc(_auth.currentUser!.uid)
          .set({
        "id": _auth.currentUser!.uid,
        "Name": userData["name"],
        "Email": userData["email"],
        "Time": FieldValue.serverTimestamp(),
        "ListOfCourses": [
          {
            "CourseName": widget.courseName,
            "CoursePrice": widget.amountString,
            "Time": DateTime.now()
          }
        ],
        "SerialNumber": 1
      });
    } else {
      var checkIdPresent = await FirebaseFirestore.instance
          .collection("AppPurchasedCourse")
          .where("id", isEqualTo: _auth.currentUser!.uid)
          .get();
      print(checkIdPresent.docs.length);

      if (checkIdPresent.docs.length != 0) {
        await FirebaseFirestore.instance
            .collection("AppPurchasedCourse")
            .doc(_auth.currentUser!.uid)
            .update({
          "ListOfCourses": FieldValue.arrayUnion([
            {
              "CourseName": widget.courseName,
              "CoursePrice": widget.amountString,
              "Time": DateTime.now()
            }
          ])
        });
      } else {
        await FirebaseFirestore.instance
            .collection("AppPurchasedCourse")
            .doc()
            .set({
          "id": _auth.currentUser!.uid,
          "Name": userData["name"],
          "Email": userData["email"],
          "Time": FieldValue.serverTimestamp(),
          "ListOfCourses": [
            {
              "CourseName": widget.courseName,
              "CoursePrice": widget.amountString,
              "Time": DateTime.now()
            }
          ],
          "SerialNumber": data.docs[0]["SerialNumber"] + 1
        });
      }
    }
  }

  redeemmoneyreward() async {
    var sendermoneyrefuid;
    var senderrefvalidfrom;
    var sendersmoneyrefcode;
    try {
      await FirebaseFirestore.instance
          .collection("Users_dataly")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get()
          .then((value) async {
        try {
          sendermoneyrefuid = value.data()!["sendermoneyrefuid"];
          sendersmoneyrefcode = value.data()!['sendersmoneyrefcode'];
          print(sendermoneyrefuid);
          senderrefvalidfrom = value.data()!['senderrefvalidfrom'];
          print(senderrefvalidfrom);
        } catch (e) {
          print(e.toString());
        }

        if (sendersmoneyrefcode.toString().split("-")[1] == courseId) {
          var data = DateTime.now().difference(senderrefvalidfrom.toDate());
          print(data.inDays);
          if (data.inDays <= 7) {
            print('herooo');
            await FirebaseFirestore.instance
                .collection("Users_dataly")
                .doc(sendermoneyrefuid.toString())
                .update({
              "moneyreward":
                  FieldValue.increment(widget.coursePriceMoneyRef / 10)
            }).whenComplete(() {
              print('success');
            }).onError((error, stackTrace) => print(error));
          }
        }
      });
    } catch (e) {
      print("check for redeeming money reward error ${e}");
      // cuponcodeentries();
    }
    cuponcodeentries();
  }

  cuponcodeentries() async {
    try {
      if (globals.cuponcode == 'applied') {
        await FirebaseFirestore.instance
            .collection("Users_dataly")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({
          "couponCodeDetails": FieldValue.arrayUnion([
            {
              "course": globals.cuponcourse,
              "price": globals.cuponcourseprice,
              "cuponcode": globals.cuponname,
              "discount": globals.cupondiscount,
              "type": globals.cupontype,
            }
          ])
        });

        await FirebaseFirestore.instance.collection("CuponRecord").doc().set({
          "useruid": FirebaseAuth.instance.currentUser!.uid.toString(),
          "course": globals.cuponcourse,
          "price": globals.cuponcourseprice,
          "cuponcode": globals.cuponname,
          "discount": globals.cupondiscount,
          "type": globals.cupontype,
          "date": DateTime.now()
        });
      }
    } catch (e) {
      print("from iwoeifwo");
      pushToHome();
    }
    print('from wowief');
    pushToHome();
  }

  // void addCoursetoUser(String id) async {
  //   await FirebaseFirestore.instance
  //       .collection("Users_dataly")
  //       .doc(FirebaseAuth.instance.currentUser!.uid)
  //       .update({
  //     "paidCourseNames": FieldValue.arrayUnion([id]),
  //     "paid": "true",
  //   });

  //   print("course added");

  // }

  calltoupdatecouponinuser() async {
    var couponbool = false;
    var couponList;
    try {
      print('1');

      await FirebaseFirestore.instance
          .collection("Users_dataly")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get()
          .then((value) {
        print('2');
        couponList = value.data()!['Coupons'];
        print('3');
        for (var i = 0; i < couponList.length; i++) {
          print('4');
          print(couponList[i]['couponCode']);
          print(widget.couponCode);
          if (couponList[i]['couponCode'] == widget.couponCode) {
            print('5');
            couponList[i]['couponStatus'] = 'purchased';
            couponList[i]['purchasedDate'] = DateTime.now();
            couponList[i]['courseName'] = widget.courseName;
            couponList[i]['courseId'] = widget.courseId;
            print('6');
            break;
          }
        }
        print('7');
        couponbool = true;
      });
    } catch (e) {
      print("error id woiejiowie: ${e.toString()}");
    }
    if (couponbool) {
      print('8');
      await FirebaseFirestore.instance
          .collection("Users_dataly")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({'Coupons': couponList}).whenComplete(() {
        print('complete we are here');
      });
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    await loadCourses();
    print("from wjrjwoeo");
    removeCourseFromTrial();

    // await redeemmoneyreward();
    // pushToHome();
    setState(() {
      print("loadingpaymetn1: ${loadingpayment}");
      loadingpayment.value = false;
    });
    Toast.show("Payment successful.");
    // addCoursetoUser(widget.courseId);

    updateCouponDetailsToUser(
      couponCodeText: widget.couponCodeText,
      courseBaughtId: widget.courseId,
      NoCouponApplied: widget.NoCouponApplied,
    );
    updatePayInPartsDetails(
      isPayInPartsPressed,
      isMinAmountCheckerPressed,
      isOutStandingAmountCheckerPressed,
    );

    // disableMinAmtBtn();
    // enableoutStandingAmtBtn();
    print("Payment Done");

    _purchasedCourses();
    // await AwesomeNotifications().createNotification(
    //     content: NotificationContent(
    //         id: 12345,
    //         channelKey: 'image',
    //         title: widget.courseName,
    //         body: 'You bought ${widget.courseName}.Go to My courses.',
    //         bigPicture: widget.courseImageUrl,
    //         largeIcon: 'asset://assets/DATALY Logo.png',
    //         notificationLayout: NotificationLayout.BigPicture,
    //         displayOnForeground: true));

    // await Provider.of<UserProvider>(context, listen: false).addToNotificationP(
    //   title: widget.courseName,
    //   body: 'You bought ${widget.courseName}. Go to My courses.',
    //   notifyImage: widget.courseImageUrl,
    //   NDate: DateFormat('dd-MM-yyyy | h:mm a').format(DateTime.now()),
    //   //index:
    // );
  }

  // if user pays for course then remove course from trial course if it exists there
  // Dipen Pau
  var trialCourseList;
  void removeCourseFromTrial() async {
    try {
      if (userData['trialCourseList'].contains(widget.courseId)) {
        trialCourseList = userData['trialCourseList'].remove(widget.courseId);
        await FirebaseFirestore.instance
            .collection("Users_dataly")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({
          "trialCourseList": trialCourseList,
        });
      } else {
        print('Direct purchase made.');
      }
    } catch (e) {
      print('removeCourseFromTrial() $e');
    }
  }

  // void disableMinAmtBtn() {
  //   if (isMinAmountCheckerPressed) {
  //     setState(() {
  //       whetherMinAmtBtnEnabled = !whetherMinAmtBtnEnabled;
  //     });
  //   }
  // }

  // void enableoutStandingAmtBtn() {
  //   if (isOutStandingAmountCheckerPressed) {
  //     setState(() {
  //       whetherOutstandingAmtBtnEnabled = !whetherOutstandingAmtBtnEnabled;
  //     });
  //   }
  // }

  void getPayInPartsDetails() async {
    DocumentSnapshot userDs = await FirebaseFirestore.instance
        .collection("Users_dataly")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    setState(() {
      userData = userDs.data() as Map<String, dynamic>;
    });
  }

  void pushToHome() async {
    print('i am after payment1');

    // GoRouter.of(context).pushReplacementNamed('myCourses');

    final url;
    if (widget.courseId == 'DEPAP1') {
      // url = 'https://de.cloudyml.com/enrolled';
      html.window.open('https://de.cloudyml.com/enrolled', "_self");
    } else {
      // url = 'https://ds.cloudyml.com/enrolled';
      html.window.open('https://ds.cloudyml.com/enrolled', "_self");
    }

    // final uri = Uri.parse(url);
    // // html.WindowBase _popup =
    // html.window.open(url,"_self");
    // if (_popup.closed!) {
    //   throw ("Popups blocked");
    // }

    // GoRouter.of(context).pushReplacementNamed('myCourses');
    // const url = 'https://www.cloudyml.com/tnkyu/';
    // final url = widget.courseId ==
    //     'F9gxnjW9nf5Lxg5A6758'
    //     ? 'https://de.cloudyml.com/enrolled'
    //     : 'https://ds.cloudyml.com/enrolled';
  }

  bool stateOfMinAmtBtn() {
    bool? returnBool;
    if (userData['payInPartsDetails'][widget.courseId] == null) {
      if (userData['payInPartsDetails'][widget.courseId]['minAmtPaid']) {
        returnBool = false;
      }
      returnBool = true;
    }
    return returnBool!;
  }

  void updatePayInPartsDetails(
      bool isPayInPartsPressed,
      bool isMinAmountCheckerPressed,
      bool isOutStandingAmountCheckerPressed) async {
    if (isPayInPartsPressed) {
      Map map = Map<String, dynamic>();

      if (isMinAmountCheckerPressed) {
        map['minAmtPaid'] = true;
        map['outStandingAmtPaid'] = false;
        map['startDateOfLimitedAccess'] = DateTime.now().toString();
        map['endDateOfLimitedAccess'] =
            DateTime.now().add(Duration(days: 21)).toString();
        // map['endDateOfLimitedAccess'] =
        //     DateTime.now().add(Duration(seconds: 60)).toString();
        await FirebaseFirestore.instance
            .collection("Users_dataly")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({'payInPartsDetails.${widget.courseId}': map});
      } else if (isOutStandingAmountCheckerPressed) {
        // DocumentSnapshot userDs = await FirebaseFirestore.instance
        //     .collection("Users_dataly")
        //     .doc(FirebaseAuth.instance.currentUser!.uid)
        //     .get();
        // Map userFields = userDs.data() as Map<String, dynamic>;
        // print(userFields['payInPartsDetails']['${widget.courseId}']
        //     ['minAmtPaid']);
        // final oldmap = Map<String, dynamic>();

        // oldmap['minAmtPaid'] = FieldValue.delete();
        // oldmap['startDateOfLimitedAccess'] = FieldValue.delete();
        // oldmap['endDateOfLimitedAccess'] = FieldValue.delete();
        // oldmap['outStandingAmtPaid'] = FieldValue.delete();

        map['minAmtPaid'] = true;
        map['startDateOfLimitedAccess'] = await userData['payInPartsDetails']
            ['${widget.courseId}']['startDateOfLimitedAccess'];
        map['endDateOfLimitedAccess'] = await userData['payInPartsDetails']
            ['${widget.courseId}']['endDateOfLimitedAccess'];
        map['outStandingAmtPaid'] = true;
        await FirebaseFirestore.instance
            .collection("Users_dataly")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update(
                {'payInPartsDetails.${widget.courseId}': FieldValue.delete()});
        await FirebaseFirestore.instance
            .collection("Users_dataly")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({'payInPartsDetails.${widget.courseId}': map});
      }
    }
  }

  // void initState() {
  //   super.initState();
  //   updateAmoutStringForRP(
  //       widget.isPayInPartsPressed,
  //       widget.isMinAmountCheckerPressed,
  //       widget.isOutStandingAmountCheckerPressed);
  //   updateAmoutStringForUPI(
  //       widget.isPayInPartsPressed,
  //       widget.isMinAmountCheckerPressed,
  //       widget.isOutStandingAmountCheckerPressed);
  // }

  @override
  Widget build(BuildContext context) {
    final userprovider = Provider.of<UserProvider>(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    var verticalScale = screenHeight / mockUpHeight;
    var horizontalScale = screenWidth / mockUpWidth;
    // loadCourses();

    return isLoading
        ? Center(child: CircularProgressIndicator())
        : Container(
            width: screenWidth / 3.5,
            height: Device.screenType == ScreenType.mobile ? 30.sp : 22.5.sp,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            child: Column(
              children: [
                InkWell(
                  onTap: () async {
                    setState(() {
                      loadingpayment.value = true;
                    });
                    setState(() {
                      isLoading = true;
                    });
                    updateAmoutStringForRP(
                        isPayInPartsPressed,
                        isMinAmountCheckerPressed,
                        isOutStandingAmountCheckerPressed);
                    widget.updateCourseIdToCouponDetails();
                    order_id = await generateOrderId(
                        key_id, ////rzp_live_ESC1ad8QCKo9zb
                        key_secret, ////D5fscRQB6i7dwCQlZybecQND
                        amountStringForRp!);

                    print('order id is out--$order_id');
                    // Future.delayed(const Duration(milliseconds: 300), () {
                    print('order id is --$order_id');
                    var options = {
                      'key': key_id, ////rzp_live_ESC1ad8QCKo9zb
                      'amount':
                          amountStringForRp, //amount is paid in paises so pay in multiples of 100
                      'name': widget.courseName,
                      'description': widget.courseDescription,
                      'timeout': 300, //in seconds
                      'order_id': order_id,
                      'prefill': {
                        'contact': userprovider.userModel!.mobile,
                        // '7003482660', //original number and email
                        'email': userprovider.userModel!.email,
                        // 'cloudyml.com@gmail.com'
                        // 'test@razorpay.com'
                        'name': userprovider.userModel!.name
                      },
                      'notes': {
                        'contact': userprovider.userModel!.mobile,
                        'email': userprovider.userModel!.email,
                        'name': userprovider.userModel!.name
                      }
                    };
                    _razorpay.open(options);
                    setState(() {
                      isLoading = false;
                    });
                  },
                  child: Center(
                    child: Container(
                      width: screenWidth,
                      height: Device.screenType == ScreenType.mobile
                          ? 30.sp
                          : 22.5.sp,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.deepPurple.shade600,
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Text(
                              // widget.NoCouponApplied
                              //     ? widget.buttonText
                              //     : widget.buttonTextForCode,
                              "Pay Now",
                              style: TextStyle(
                                  color: Color.fromRGBO(255, 255, 255, 1),
                                  fontFamily: 'Poppins',
                                  fontSize: 24 * verticalScale,
                                  letterSpacing:
                                      0 /*percentages not used in flutter. defaulting to zero*/,
                                  fontWeight: FontWeight.bold,
                                  height: 1),
                            ),
                            Text(
                              // widget.NoCouponApplied
                              //     ? widget.buttonText
                              //     : widget.buttonTextForCode,
                              "(For Indian Students)",
                              style: TextStyle(
                                  color: Color.fromRGBO(255, 255, 255, 1),
                                  fontFamily: 'Poppins',
                                  fontSize: 14 * verticalScale,
                                  letterSpacing:
                                      0 /*percentages not used in flutter. defaulting to zero*/,
                                  fontWeight: FontWeight.bold,
                                  height: 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                widget.isPayButtonPressed
                    ? Column(
                        children: [
                          SizedBox(
                            height: 15,
                          ),
                          (widget.isItComboCourse &&
                                  (widget.whichCouponCode == 'parts2'))
                              ? Container(
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(
                                            25, 10, 245, 10),
                                        child: Text('Pay in parts'),
                                      ),
                                      Container(
                                        width: 300,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                            color: Colors.grey.shade200,
                                            width: 1.1,
                                          ),
                                          color: Colors.grey.shade100,
                                        ),
                                        child: Column(
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                setState(() {
                                                  isPayInPartsPressed =
                                                      !isPayInPartsPressed;
                                                });
                                                // widget.pressPayInPartsButton();
                                              },
                                              child: Container(
                                                height: 60,
                                                width: 300,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  border: Border.all(
                                                    color: Colors.grey.shade200,
                                                    width: 1.1,
                                                  ),
                                                  color: Colors.white,
                                                ),
                                                child: Row(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                        left: 10,
                                                        right: 10,
                                                      ),
                                                      child: Icon(
                                                          Icons.pie_chart,
                                                          size: 43),
                                                    ),
                                                    Expanded(
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            'Pay in parts',
                                                            style: TextStyle(
                                                                fontSize: 17),
                                                          ),
                                                          Text(
                                                            'Pay min ₹1000 to get limited access of 20 days after that pay the rest and enjoy lifetime access',
                                                            style: TextStyle(
                                                                fontSize: 9,
                                                                color: Colors
                                                                    .grey
                                                                    .shade500),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            isPayInPartsPressed
                                                ? Container(
                                                    //this container will expand onTap
                                                    child: Column(
                                                      children: [
                                                        Container(
                                                          height: 50,
                                                          width: 180,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            border: Border.all(
                                                              color: Colors.grey
                                                                  .shade200,
                                                              width: 1.1,
                                                            ),
                                                            color: userData['payInPartsDetails']
                                                                        [widget
                                                                            .courseId] !=
                                                                    null
                                                                ? Colors.grey
                                                                    .shade100
                                                                : Colors.white,
                                                            // color:if(userData[
                                                            //                   'payInPartsDetails']
                                                            //               [widget.courseId]==null){
                                                            //                 Colors.white
                                                            //               }else if(userData[
                                                            //                   'payInPartsDetails']
                                                            //               [widget.courseId]['isMinAmtPaid']){
                                                            //                 Colors.grey.shade100
                                                            //               }
                                                          ),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            20),
                                                                child: Text(
                                                                    'Pay  ₹1000.0/-'),
                                                              ),
                                                              InkWell(
                                                                onTap: () {
                                                                  if (userData[
                                                                              'payInPartsDetails']
                                                                          [
                                                                          widget
                                                                              .courseId] !=
                                                                      null)
                                                                    return;
                                                                  setState(() {
                                                                    isMinAmountCheckerPressed =
                                                                        !isMinAmountCheckerPressed;
                                                                  });
                                                                  updateAmoutStringForUPI(
                                                                      isPayInPartsPressed,
                                                                      isMinAmountCheckerPressed,
                                                                      isOutStandingAmountCheckerPressed);
                                                                  updateAmoutStringForRP(
                                                                      isPayInPartsPressed,
                                                                      isMinAmountCheckerPressed,
                                                                      isOutStandingAmountCheckerPressed);
                                                                  print(
                                                                      isMinAmountCheckerPressed);
                                                                  print(
                                                                      "Print payinparts:${isPayInPartsPressed}");
                                                                  print(
                                                                      amountStringForUPI);
                                                                },
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          right:
                                                                              20),
                                                                  child:
                                                                      Container(
                                                                    width: 30,
                                                                    height: 30,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              50),
                                                                      border:
                                                                          Border
                                                                              .all(
                                                                        color: Colors
                                                                            .grey
                                                                            .shade300,
                                                                        width:
                                                                            3,
                                                                      ),
                                                                      color: isMinAmountCheckerPressed
                                                                          ? Color(
                                                                              0xFFaefb2a)
                                                                          : Colors
                                                                              .grey
                                                                              .shade100,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Container(
                                                          height: 50,
                                                          width: 180,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            border: Border.all(
                                                              color: Colors.grey
                                                                  .shade200,
                                                              width: 1.1,
                                                            ),
                                                            color: !(userData[
                                                                            'payInPartsDetails']
                                                                        [widget
                                                                            .courseId] ==
                                                                    null)
                                                                ? Colors.white
                                                                : Colors.grey
                                                                    .shade100,
                                                          ),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            20),
                                                                child: Text(
                                                                  'Pay ₹${widget.outStandingAmountString}/-',
                                                                ),
                                                              ),
                                                              InkWell(
                                                                onTap: () {
                                                                  if (userData[
                                                                              'payInPartsDetails']
                                                                          [
                                                                          widget
                                                                              .courseId] ==
                                                                      null)
                                                                    return;
                                                                  setState(() {
                                                                    isOutStandingAmountCheckerPressed =
                                                                        !isOutStandingAmountCheckerPressed;
                                                                  });
                                                                  updateAmoutStringForUPI(
                                                                      isPayInPartsPressed,
                                                                      isMinAmountCheckerPressed,
                                                                      isOutStandingAmountCheckerPressed);
                                                                  updateAmoutStringForRP(
                                                                      isPayInPartsPressed,
                                                                      isMinAmountCheckerPressed,
                                                                      isOutStandingAmountCheckerPressed);
                                                                },
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          right:
                                                                              20),
                                                                  child:
                                                                      Container(
                                                                    width: 30,
                                                                    height: 30,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              50),
                                                                      border:
                                                                          Border
                                                                              .all(
                                                                        color: Colors
                                                                            .grey
                                                                            .shade300,
                                                                        width:
                                                                            3,
                                                                      ),
                                                                      color: isOutStandingAmountCheckerPressed
                                                                          ? Color(
                                                                              0xFFaefb2a)
                                                                          : Colors
                                                                              .grey
                                                                              .shade100,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                : Container(),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Container(),
                          // Padding(
                          //   padding: EdgeInsets.fromLTRB(25, 10, 240, 10),
                          //   child: Text('Pay with UPI'),
                          // ),
                          // Container(
                          //   width: 300,
                          //   decoration: BoxDecoration(
                          //     borderRadius: BorderRadius.circular(10),
                          //     border: Border.all(
                          //       color: Colors.grey.shade200,
                          //       width: 1.1,
                          //     ),
                          //     color: Colors.white,
                          //   ),
                          //   child: Column(
                          //     children: [
                          //       InkWell(
                          //         onTap: () {
                          //           intiateUpiTransaction(UpiApps.GooglePay);
                          //         },
                          //         child: Container(
                          //           height: 60,
                          //           child: Row(
                          //             // mainAxisAlignment:MainAxisAlignment.spaceBetween,
                          //             children: [
                          //               Padding(
                          //                 padding: const EdgeInsets.only(
                          //                   top: 10,
                          //                   left: 20,
                          //                   right: 15,
                          //                 ),
                          //                 child: Image.asset(
                          //                   'assets/Google_Pay.png',
                          //                   width: 45,
                          //                   height: 45,
                          //                 ),
                          //               ),
                          //               Padding(
                          //                 padding: const EdgeInsets.only(
                          //                   top: 10,
                          //                 ),
                          //                 child: Text(
                          //                   'Google Pay',
                          //                   style: TextStyle(fontSize: 17),
                          //                 ),
                          //               ),
                          //               Padding(
                          //                 padding: const EdgeInsets.only(
                          //                   left: 100,
                          //                   top: 10,
                          //                 ),
                          //                 child: Icon(
                          //                   Icons.keyboard_arrow_right,
                          //                   color: Colors.grey.shade300,
                          //                 ),
                          //               ),
                          //             ],
                          //           ),
                          //         ),
                          //       ),
                          //       Divider(),
                          //       InkWell(
                          //         onTap: () {
                          //           intiateUpiTransaction(UpiApps.PhonePe);
                          //         },
                          //         child: Container(
                          //           height: 60,
                          //           child: Row(
                          //             // mainAxisAlignment:MainAxisAlignment.spaceBetween,
                          //             children: [
                          //               Padding(
                          //                 padding: const EdgeInsets.only(
                          //                   bottom: 10,
                          //                   left: 20,
                          //                   right: 15,
                          //                 ),
                          //                 child: Image.asset(
                          //                   'assets/phonepe.png',
                          //                   width: 45,
                          //                   height: 45,
                          //                 ),
                          //               ),
                          //               Padding(
                          //                 padding: const EdgeInsets.only(
                          //                   bottom: 10,
                          //                 ),
                          //                 child: Text(
                          //                   'PhonePe',
                          //                   style: TextStyle(fontSize: 17),
                          //                 ),
                          //               ),
                          //               Padding(
                          //                 padding: const EdgeInsets.only(
                          //                   left: 116,
                          //                   bottom: 10,
                          //                 ),
                          //                 child: Icon(
                          //                   Icons.keyboard_arrow_right,
                          //                   color: Colors.grey.shade300,
                          //                 ),
                          //               ),
                          //             ],
                          //           ),
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          // Padding(
                          //   padding: EdgeInsets.fromLTRB(25, 10, 170, 10),
                          //   child: Text('Other payment methods'),
                          // ),
                          InkWell(
                            onTap: () async {
                              // setState(() {
                              //   widget.courseId = widget.courseFetchedId;
                              // });

                              updateAmoutStringForRP(
                                  isPayInPartsPressed,
                                  isMinAmountCheckerPressed,
                                  isOutStandingAmountCheckerPressed);
                              widget.updateCourseIdToCouponDetails();
                              order_id = await generateOrderId(
                                  key_id, ////rzp_live_ESC1ad8QCKo9zb
                                  key_secret, ////D5fscRQB6i7dwCQlZybecQND
                                  amountStringForRp!);

                              print('order id is out--$order_id');
                              // Future.delayed(const Duration(milliseconds: 300), () {
                              print('order id is --$order_id');
                              var options = {
                                'key': key_id, ////rzp_live_ESC1ad8QCKo9zb
                                'amount':
                                    amountStringForRp, //amount is paid in paises so pay in multiples of 100

                                'name': widget.courseName,
                                'description': widget.courseDescription,
                                'timeout': 300, //in seconds
                                'order_id': order_id,
                                'prefill': {
                                  'contact': userprovider.userModel!.mobile,
                                  // '7003482660', //original number and email
                                  'email': userprovider.userModel!.email,
                                  // 'cloudyml.com@gmail.com'
                                  // 'test@razorpay.com'
                                  'name': userprovider.userModel!.name
                                },
                                'notes': {
                                  'contact': userprovider.userModel!.mobile,
                                  'email': userprovider.userModel!.email,
                                  'name': userprovider.userModel!.name
                                }
                              };
                              _razorpay.open(options);
                              // });
                            },
                            child: Container(
                              height: 60,
                              width: 300,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white,
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/razorpay1.jpg',
                                      width: 45,
                                      height: 45,
                                    ),
                                    Text(
                                      'Razorpay',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      )
                    : Container(),
              ],
            ),
          );
  }
}
