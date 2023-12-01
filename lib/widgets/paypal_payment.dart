import 'dart:html';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudyml_app2/Providers/UserProvider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:paypal_sdk/catalog_products.dart';
import 'package:paypal_sdk/core.dart';
import 'package:paypal_sdk/subscriptions.dart';
import 'package:paypal_sdk/webhooks.dart';
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
import 'package:paypal_sdk/src/webhooks/webhooks_api.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:ui' as ui;

import '../api/paypal_service.dart';

class PaypalPaymentButton extends StatefulWidget {
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

  PaypalPaymentButton(
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
  State<PaypalPaymentButton> createState() => _PaypalPaymentButtonState();
}

class _PaypalPaymentButtonState extends State<PaypalPaymentButton>
    with CouponCodeMixin {
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

  Future<void> webhookExamples(PayPalHttpClient payPalHttpClient) async {
    var webhooksApi = WebhooksApi(payPalHttpClient);

    // List webhooks
    try {
      var webhooksList = await webhooksApi.listWebhooks();
      print(webhooksList);
    } on ApiException catch (e) {
      print(e);
    }

    // Create webhook
    try {
      var webhook =
          Webhook(url: 'https://api.test.com/paypal_callback', eventTypes: [
        EventType(name: 'BILLING.SUBSCRIPTION.CREATED'),
        EventType(name: 'BILLING.SUBSCRIPTION.CANCELLED'),
      ]);

      webhook = await webhooksApi.createWebhook(webhook);
      print(webhook);
    } on ApiException catch (e) {
      print(e);
    }

    // Delete webhook
    try {
      await webhooksApi.deleteWebhook('1HG80537L4140544T');
    } on ApiException catch (e) {
      print(e);
    }

    // Update webhook
    try {
      await webhooksApi.updateWebhook('5B760822JX046254S', [
        Patch(
            op: PatchOperation.replace,
            path: '/url',
            value: 'https://api.test.com/paypal_callback_new'),
      ]);
    } on ApiException catch (e) {
      print(e);
    }

    // Show webhook details
    try {
      var webhook = await webhooksApi.showWebhookDetails('7BS56736HU608525B');
      print(webhook);
    } on ApiException catch (e) {
      print(e);
    }

    // List event types for webhook
    try {
      var eventTypesList = await webhooksApi
          .listEventSubscriptionsForWebhook('7BS56736HU608525B');
      print(eventTypesList);
    } on ApiException catch (e) {
      print(e);
    }

    // List available events
    try {
      var eventTypesList = await webhooksApi.listAvailableEvents();
      print(eventTypesList);
    } on ApiException catch (e) {
      print(e);
    }
  }

  var clientId;
  var clientSecret;
  var canadianValue;
  getIdKeyCurrency() async {
    try {
      await _firestore
          .collection('Notice')
          .doc('paypal_money')
          .get()
          .then((value) {
        clientId = value.data()!['client_id'];
        clientSecret = value.data()!['secret_key'];
        canadianValue = value.data()!['currency'];
      });
    } catch (e) {
      print('getIdKeyCurrency $e');
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

  PaypalServices payPalServices = PaypalServices();
  String? accessToken1;
  @override
  void initState() {
    getIdKeyCurrency();

    super.initState();
  }

  String? checkoutUrl;
  String? executeUrl;
  String itemName = 'One plus 10';
  String itemPrice = '100';
  int quantity = 1;
  String returnURL = 'return.example.com';
  String cancelURL = 'cancel.example.com';
  Map<dynamic, dynamic> defaultCurrency = {
    "symbol": "USD ",
    "decimalDigits": 2,
    "symbolBeforeTheNumber": true,
    "currency": "USD"
  };
  bool isEnableShipping = false;
  bool isEnableAddress = false;

  paymentCheckOut(transactions, accessToken) async {
    var headers = {
      // 'Authorization':
      //     'Basic QVJQUkU0QmVndFRlRHBhY1JkTUJSa09teWF2TE9xSlczNUZSTndYbVJqazh3M0FEX3Z6Yks4SXEwNzNRRWdHSEVQQUZtZVk0R01nSzFjbV86RUt3MVJJckRvSEVSRTVmOGdZVk9oY2o0MVphMk1UQ1FMUFJ4MjBXYklOOGVyZHl0dEh5TkI1RDdpMTc5ZnlEczFkZzhlSE9jZ3lfTWVuQnI=',
      'Content-Type': 'application/json',
      'Cookie': 'l7_az=ccg14.slc',
      'Authorization': 'Bearer $accessToken'
    };
    var url = Uri.parse('https://api.paypal.com/v1/payments/payment');
    var body = json.encode(transactions);
    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 201) {
      print(await response.body);
      final newBody = jsonDecode(response.body);
      if (newBody["links"] != null && newBody["links"].length > 0) {
        List links = newBody["links"];
        String executeUrl = "";
        String approvalUrl = "";
        final item = links.firstWhere((o) => o["rel"] == "approval_url",
            orElse: () => null);
        if (item != null) {
          approvalUrl = item["href"];
        }
        final item1 =
            links.firstWhere((o) => o["rel"] == "execute", orElse: () => null);
        if (item1 != null) {
          executeUrl = item1["href"];
        }
        return {"executeUrl": executeUrl, "approvalUrl": approvalUrl};
      }
    } else {
      print(response.reasonPhrase);
    }
  }

  @override
  Widget build(BuildContext context) {
    print('widget.amountString = ${widget.amountString}');
    final transactions = {
      "intent": "sale",
      "payer": {"payment_method": "paypal"},
      "transactions": [
        {
          "amount": {
            "total": "1.00",
            // "total": "${widget.amountString}",
            "currency": "CAD",
            "details": {
              "subtotal": "1.00",
              // "subtotal": "${widget.amountString}",
              "tax": "0.00",
              "shipping": "0.00",
              "handling_fee": "0.00",
              "shipping_discount": "0.00",
              "insurance": "0.00"
            }
          },
          "description": "The payment transaction description.",
          "custom": "EBAY_EMS_90048630024435",
          "invoice_number": "48787589673",
          "payment_options": {
            "allowed_payment_method": "INSTANT_FUNDING_SOURCE"
          },
          "soft_descriptor": "ECHI5786786",
          "item_list": {
            "items": [
              {
                "name": "${widget.courseName}",
                "description": "Brown hat.",
                "quantity": "1",
                "price": "1.00",
                // "price": "${widget.amountString}",
                "tax": "0.00",
                "sku": "1",
                "currency": "CAD"
              },
            ],
            "shipping_address": {
              "recipient_name": "Brian Robinson",
              "line1": "4th Floor",
              "line2": "Unit #34",
              "city": "San Jose",
              "country_code": "US",
              "postal_code": "95131",
              "phone": "011862212345678",
              "state": "CA"
            }
          }
        }
      ],
      "note_to_payer": "Contact us for any questions on your order.",
      "redirect_urls": {
        "return_url": "https://example.com/return",
        "cancel_url": "https://example.com/cancel"
      }
    };
    final userprovider = Provider.of<UserProvider>(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    var verticalScale = screenHeight / mockUpHeight;
    var horizontalScale = screenWidth / mockUpWidth;
    // return Scaffold(
    // floatingActionButton: FloatingActionButton(onPressed: () async {
    //
    // Future.delayed(Duration.zero, () async {
    //   try{
    //     print('Accessss token');
    //     accessToken1 = await payPalServices.getAccessToken();
    //     final response  = await paymentCheckOut(transactions, accessToken);
    //     print('response = ${response}');
    //
    //     if (response != null) {
    //       setState(() {
    //         checkoutUrl = response["approvalUrl"];
    //         executeUrl = response["executeUrl"];
    //       });
    //     }
    //   }catch(e){
    //     print('erorr = $e');
    //   }
    // });
    // print('executeUrl $executeUrl');
    // print('checkoutUrl $checkoutUrl');
    // }),
    // );
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

                    Future.delayed(Duration.zero, () async {
                      try {
                        print('Accessss token');
                        accessToken1 = await payPalServices.getAccessToken();
                        final response =
                            await paymentCheckOut(transactions, accessToken1);
                        print('response = ${response}');
                        checkoutUrl = response["approvalUrl"];
                        executeUrl = response["executeUrl"];
                        setState(() {});
                        print('executeUrl $executeUrl');
                        print('checkoutUrl $checkoutUrl');
                        launch(checkoutUrl!);
                      } catch (e) {
                        print('erorr = $e');
                      }
                    });

                    // showDialog(
                    //     context: context,
                    //     builder: (context) {
                    //       return AlertDialog(
                    //         content: Container(
                    //           width: Adaptive.w(75),
                    //           child: WebViewElement(),
                    //           // child: WebView(
                    //           //   initialUrl: checkoutUrl,
                    //           //   javascriptMode: JavascriptMode.unrestricted,
                    //           //   navigationDelegate:
                    //           //       (NavigationRequest request) {
                    //           //     if (request.url.contains(returnURL)) {
                    //           //       final uri = Uri.parse(request.url);
                    //           //       final payerID =
                    //           //           uri.queryParameters['PayerID'];
                    //           //       if (payerID != null) {
                    //           //         payPalServices
                    //           //             .executePayment(executeUrl,
                    //           //                 payerID, accessToken1)
                    //           //             .then((id) {
                    //           //           Navigator.of(context).pop();
                    //           //         });
                    //           //       } else {
                    //           //         Navigator.of(context).pop();
                    //           //       }
                    //           //       Navigator.of(context).pop();
                    //           //     }
                    //           //     if (request.url.contains(cancelURL)) {
                    //           //       Navigator.of(context).pop();
                    //           //     }
                    //           //     return NavigationDecision.navigate;
                    //           //   },
                    //           // ),
                    //         ),
                    //       );
                    //     });

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
                        child: Text(
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
                                                                  // updateAmoutStringForUPI(
                                                                  //     isPayInPartsPressed,
                                                                  //     isMinAmountCheckerPressed,
                                                                  //     isOutStandingAmountCheckerPressed);
                                                                  // updateAmoutStringForRP(
                                                                  //     isPayInPartsPressed,
                                                                  //     isMinAmountCheckerPressed,
                                                                  //     isOutStandingAmountCheckerPressed);
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
                                                                  // updateAmoutStringForUPI(
                                                                  //     isPayInPartsPressed,
                                                                  //     isMinAmountCheckerPressed,
                                                                  //     isOutStandingAmountCheckerPressed);
                                                                  // updateAmoutStringForRP(
                                                                  //     isPayInPartsPressed,
                                                                  //     isMinAmountCheckerPressed,
                                                                  //     isOutStandingAmountCheckerPressed);
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
                          InkWell(
                            onTap: () async {
                              // setState(() {
                              //   widget.courseId = widget.courseFetchedId;
                              // });

                              // updateAmoutStringForRP(
                              //     isPayInPartsPressed,
                              //     isMinAmountCheckerPressed,
                              //     isOutStandingAmountCheckerPressed);
                              // widget.updateCourseIdToCouponDetails();
                              // order_id = await generateOrderId(
                              //     key_id, ////rzp_live_ESC1ad8QCKo9zb
                              //     key_secret, ////D5fscRQB6i7dwCQlZybecQND
                              //     amountStringForRp!);

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
