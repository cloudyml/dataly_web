import 'dart:convert';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudyml_app2/Providers/UserProvider.dart';
import 'package:cloudyml_app2/globals.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloudyml_app2/global_variable.dart' as globals;
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:html' as html;
import 'package:razorpay_web/razorpay_web.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';

class RazorPayInternationalBtn extends StatefulWidget {
  int coursePriceMoneyRef;
  final String couponCodeText;
  final String amountString;
  final String courseName;
  final bool NoCouponApplied;
  final String courseImageUrl;
  final String courseDescription;
  final international;

  String courseId;
  RazorPayInternationalBtn(
      {Key? key,
      required this.coursePriceMoneyRef,
      required this.courseId,
      required this.couponCodeText,
      required this.NoCouponApplied,
      required this.amountString,
      required this.courseName,
      required this.courseImageUrl,
      required this.courseDescription,
      this.international})
      : super(key: key);

  @override
  State<RazorPayInternationalBtn> createState() =>
      _RazorPayInternationalBtnState();
}

class _RazorPayInternationalBtnState extends State<RazorPayInternationalBtn> {
  var _razorpay = Razorpay();
  var order_id;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  Map userData = Map<String, dynamic>();
  String selectedCurrency = '';
  String selectedCurrencySymbol = '';
  String currencyRate = '';
  String additionToPayment = '';

  String finalAmount = '';
  bool isLoading = false;
  var key_id;
  var key_secret;

  @override
  void initState() {
    getrzpkey();

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    getPayInPartsDetails();

    super.initState();
  }

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

  @override
  void dispose() {
    _razorpay.clear(); // Removes all listeners
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userprovider = Provider.of<UserProvider>(context);
    return Column(
      children: [
        InkWell(
          onTap: () {
            selectCurrency();
          },
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.lightBlueAccent,
            ),
            child: selectedCurrency.isNotEmpty
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Selected Currency',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        selectedCurrency,
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  )
                : Center(
                    child: Text(
                      'Select Currency',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ),
        ),
        SizedBox(
          height: 20,
        ),
        InkWell(
          onTap: () async {
            setState(() {
              isLoading = true;

              if (selectedCurrency.isEmpty && finalAmount.isEmpty) {
                isLoading = false;
                print('Final Price :: $finalAmount');
                Toast.show('Please select currency');
              } else {
                doPayment(userprovider);
              }
            });
          },
          child: Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.deepPurpleAccent,
            ),
            child: Center(
              child: isLoading
                  ? CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : Text(
                      finalAmount.isEmpty
                          ? 'Pay Now'
                          : 'Pay  $selectedCurrencySymbol ${(double.parse(finalAmount)).round().toString()}',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    await loadCourses();
    print("from wjrjwoeo");

    await redeemmoneyreward();
    // pushToHome();
    Toast.show("Payment successful.");
    // addCoursetoUser(widget.courseId);
    Toast.show("Payment successful.");
    await redeemmoneyreward();

    addCoursetoUser(widget.courseId);
    // pushToHome();

    updateCouponDetailsToUser(
      couponCodeText: widget.couponCodeText,
      courseBaughtId: widget.courseId,
      NoCouponApplied: widget.NoCouponApplied,
    );
    // updatePayInPartsDetails(
    //   isPayInPartsPressed,
    //   isMinAmountCheckerPressed,
    //   isOutStandingAmountCheckerPressed,
    // );

    print("Payment Done");
    _purchasedCourses();
    removeCourseFromTrial();
    await AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: 12345,
            channelKey: 'image',
            title: widget.courseName,
            body: 'You bought ${widget.courseName}.Go to My courses.',
            bigPicture: widget.courseImageUrl,
            largeIcon: 'asset://assets/logo.png',
            notificationLayout: NotificationLayout.BigPicture,
            displayOnForeground: true));

    await Provider.of<UserProvider>(context, listen: false).addToNotificationP(
      title: widget.courseName,
      body: 'You bought ${widget.courseName}. Go to My courses.',
      notifyImage: widget.courseImageUrl,
      NDate: DateFormat('dd-MM-yyyy | h:mm a').format(DateTime.now()),
      //index:
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Toast.show("Payment Failed");
    print("International Payment Fail ${response.message}");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Do something when an external wallet is selected
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
      pushToHome();
    }
    pushToHome();
  }

  void pushToHome() async {
    try {
      print('i am after payment1');

      await _firestore.collection("courses").doc(courseId).get().then((value) {
        var iscombo = value.data()!['combo'];
        if (iscombo == true) {
          GoRouter.of(context).pushNamed('NewComboCourseScreen', queryParams: {
            'courseId': value.data()!['id'],
            'courseName': value.data()!['name'],
          });
        } else {
          GoRouter.of(context).pushReplacementNamed('myCourses');
        }
      });

      final url;
      if (widget.courseId == 'F9gxnjW9nf5Lxg5A6758') {
        url = 'https://de.cloudyml.com/enrolled';
      } else {
        url = 'https://ds.cloudyml.com/enrolled';
      }

      final uri = Uri.parse(url);
      html.WindowBase _popup = html.window.open(url, 'Thank you');
      if (_popup.closed!) {
        throw ("Popups blocked");
      }
    } catch (e) {
      print('Error in push to home : $e');
    }
  }

  void addCoursetoUser(String id) async {
    print('Statt AddCoursetoUser');
    try {
      await FirebaseFirestore.instance
          .collection("Users_dataly")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        'paidCourseNames': FieldValue.arrayUnion([id])
      });
    } catch (e) {
      print('AddCoursetoUser Error : $e');
    }
  }

  loadCourses() async {
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
    pushToHome();
  }

//    void loadCourses() async {
//  var groupData;
//    try {
//     await _firestore.collection('courses').where('id',isEqualTo: widget.courseId).get().then((value) {
//  print('AAAAAAAAAA:: ${value.docs[0].data()['name']}');
//  groupData = {
//         "name":value.docs[0].data()['name'],
//         "icon": value.docs[0].data()["image_url"],
//         "mentors": value.docs[0].data()["mentors"],
//         "student_id": _auth.currentUser!.uid,
//         "student_name": _auth.currentUser!.displayName,
//         'groupChatCount': {
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

//     }).whenComplete(() {
//       _firestore.collection("groups_dataly").add(groupData);
//     });

//    } catch (e) {
//      print('Errrrorrrrrrrr:::; $e');
//    }
// }

  void updateCouponDetailsToUser(
      {required String courseBaughtId,
      required String couponCodeText,
      required bool NoCouponApplied}) async {
    bool couponCodeDetailsExists = await checkIfCouponDetailsExist();

    print(couponCodeDetailsExists);

    Map map = Map<String, dynamic>();

    // map['couponCodeAppliedOncourseId'] = courseBaughtId;
    map['couponCodeApplied'] = couponCodeText;
    if (!NoCouponApplied) {
      if (!couponCodeDetailsExists) {
        await FirebaseFirestore.instance
            .collection("Users_dataly")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({
          'couponCodeDetails': {courseBaughtId: map}
        });
      } else {
        await FirebaseFirestore.instance
            .collection("Users_dataly")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({
          'couponCodeDetails': {courseBaughtId: map}
        });
      }
    }
  }

  Future<bool> checkIfCouponDetailsExist() async {
    bool couponCodeDetailsExists;

    DocumentSnapshot userDs = await FirebaseFirestore.instance
        .collection("Users_dataly")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    Map userFields = userDs.data() as Map<String, dynamic>;

    if (userFields.containsKey('couponCodeDetails')) {
      couponCodeDetailsExists = true;
    } else {
      couponCodeDetailsExists = false;
    }
    return couponCodeDetailsExists;
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

  void getPayInPartsDetails() async {
    DocumentSnapshot userDs = await FirebaseFirestore.instance
        .collection("Users_dataly")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    setState(() {
      userData = userDs.data() as Map<String, dynamic>;
    });
  }

  void getrzpkey() async {
    key_id = await FirebaseFirestore.instance
        .collection('Notice')
        .doc('razorpay_international_key')
        .get()
        .then((value) {
      return value.data()!['key_id']; // Access your after your get the data
    });

    key_secret = await FirebaseFirestore.instance
        .collection('Notice')
        .doc('razorpay_international_key')
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
      'Content-type': 'application/json',
      'Authorization': authn,
    };

    var data =
        '{ "amount": $amount, "currency": "$selectedCurrency", "receipt": "order_rcptid_11" }'; // as per my experience the receipt doesn't play any role in helping you generate a certain pattern in your Order ID!!

    var res = await http.post(
        Uri.parse(
            'https://us-central1-cloudyml-app.cloudfunctions.net/interorder/inorder'),
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

  selectCurrency() {
    showCurrencyPicker(
      context: context,
      showFlag: true,
      showCurrencyName: true,
      showCurrencyCode: true,
      theme: CurrencyPickerThemeData(
          bottomSheetHeight: MediaQuery.of(context).size.height / 1.5),
      currencyFilter: [
        'USD',
        'AUD',
        'CAD',
        'EUR',
        'GBP',
        'SAR',
      ],
      onSelect: (Currency currency) {
        setState(() {
          selectedCurrency = currency.code;
          selectedCurrencySymbol = currency.symbol;
          print('Selected currency: $selectedCurrency');
          if (selectedCurrency.isNotEmpty) {
            getCurrencyRate(currency: selectedCurrency);
          }
        });
      },
    );
  }

  getCurrencyRate({required String currency}) {
    try {
      FirebaseFirestore.instance
          .collection('CurrencyRates')
          .doc(currency.toLowerCase())
          .get()
          .then((value) {
        print('$currency rate :: ${value.get('rate')}');
        currencyRate = value.get('rate');
        additionToPayment = value.get('addition');

        countFinalAmount();
      });
    } catch (e) {
      print('Error in getting currency rates');
    }
  }

  countFinalAmount() {
    print('Indian Price :: ${int.parse(widget.amountString) / 100}');
    finalAmount =
        (((int.parse(widget.amountString) / 100) / double.parse(currencyRate)) +
                int.parse(additionToPayment))
            .round()
            .toString();
    print('Final Price :: $finalAmount');
    setState(() {});
  }

  doPayment(UserProvider userprovider) async {
    var od = await generateOrderId(key_id, key_secret,
        ((double.parse(finalAmount) * 100).round()).toString());

    print('Final Price :: $finalAmount');

    var options = {
      'key': key_id,
      //'amount': '10000', //in the smallest currency sub-unit.
      'name': widget.courseName,
      'order_id': od, // Generate order_id using Orders API
      //'description': widget.courseDescription,
      'timeout': 300, // in seconds
      'prefill': {
        'contact': userprovider.userModel!.mobile,
        'email': userprovider.userModel!.email,
        'name': userprovider.userModel!.name
      },
      'notes': {
        'contact': userprovider.userModel!.mobile,
        'email': userprovider.userModel!.email,
        'name': userprovider.userModel!.name
      }
    };
    _razorpay.open(options);
    isLoading = false;
    setState(() {});
  }
}
