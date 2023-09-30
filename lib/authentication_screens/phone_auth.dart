import 'dart:convert';
import 'dart:html';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudyml_app2/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:g_recaptcha_v3/g_recaptcha_v3.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:cloudyml_app2/theme.dart';
import 'package:cloudyml_app2/global_variable.dart' as globals;
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

import '../authentication/SignUpForm.dart';
import '../authentication/firebase_auth.dart';
import '../authentication/loginform.dart';
import '../globals.dart';
import '../widgets/loading.dart';
import 'otp_page.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class LoginPage extends StatefulWidget {
  String? name;
  LoginPage({Key? key, this.name}) : super(key: key);
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController phoneController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool loading = false;
  late String actualCode;

  PhoneNumber number = PhoneNumber(isoCode: 'IN');
  String phonenumber = '';

  bool? googleloading = false;
  bool formVisible = false;
  bool value = false;
  bool phoneVisible = false;
  int _formIndex = 1;

  bool _isHidden = true;
  bool _isLoading = false;
  final _loginkey = GlobalKey<FormState>();
  final FirebaseAuth auth = FirebaseAuth.instance;
  FocusNode _buttonFocusNode = FocusNode();

  @override
  void initState() {
    GRecaptchaV3.hideBadge();

    final el = window.document.getElementById('__ff-recaptcha-container');
    if (el != null) {
      el.style.visibility = 'hidden';
    }
    super.initState();
  }

  @override
  void dispose() {
    phoneController.dispose();
    _buttonFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    var verticalScale = height / mockUpHeight;
    var horizontalScale = width / mockUpWidth;
    return Scaffold(
      // backgroundColor: Colors.white,
      body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth >= 700) {
          return Stack(
            children: [
              Container(
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        color: Color.fromRGBO(35, 0, 79, 1),
                      ),
                    ),
                    Expanded(flex: 1, child: Container()),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.all(80.00),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        width: 525,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              bottomLeft: Radius.circular(30)),
                          gradient: LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [
                              HexColor("440F87"),
                              HexColor("7226D1"),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 40.0, // soften the shadow
                              offset: Offset(
                                0, // Move to right 10  horizontally
                                2.0, // Move to bottom 10 Vertically
                              ),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Image.asset(
                                'assets/logo.png',
                                height: 75,
                                width: 110,
                                cacheWidth: 82,
                                cacheHeight: 56,
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                "Let's Explore",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w300,
                                    fontSize: 22),
                              ),
                              Text(
                                "Data Science, Analytics & Data Engineering together!",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 26),
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Image.asset(
                                    'assets/loginoop.png',
                                    cacheWidth: 364,
                                    cacheHeight: 364,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        width: 325,
                        height: MediaQuery.of(context).size.height,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(30),
                              bottomRight: Radius.circular(30)),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 40.0, // soften the shadow
                              offset: Offset(
                                0, // Move to right 10  horizontally
                                2.0, // Move to bottom 10 Vertically
                              ),
                            ),
                          ],
                        ),
                        margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: Center(
                          child: Column(
                            children: <Widget>[
                              Expanded(
                                flex: 0,
                                child: Column(
                                  children: <Widget>[
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.2,
                                    ),
                                    Container(
                                        constraints:
                                            const BoxConstraints(maxWidth: 500),
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: RichText(
                                          textAlign: TextAlign.center,
                                          text: TextSpan(children: <TextSpan>[
                                            TextSpan(
                                                text: 'We will send you a ',
                                                style: TextStyle(
                                                    color:
                                                        MyColors.primaryColor,
                                                    fontSize: 18)),
                                            TextSpan(
                                                text: 'One Time Password ',
                                                style: TextStyle(
                                                    color:
                                                        MyColors.primaryColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18)),
                                            TextSpan(
                                                text: 'on this mobile number',
                                                style: TextStyle(
                                                    color:
                                                        MyColors.primaryColor,
                                                    fontSize: 18)),
                                          ]),
                                        )),
                                    SizedBox(
                                      height: 60,
                                    ),
                                    Container(
                                      height: 40,
                                      constraints:
                                          const BoxConstraints(maxWidth: 500),
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                      child: InternationalPhoneNumberInput(
                                        onInputChanged: (PhoneNumber number) {
                                          print(number.phoneNumber);
                                          print(phoneController.text);
                                          phonenumber =
                                              number.phoneNumber.toString();
                                          print("phone number: ${phonenumber}");
                                        },
                                        onInputValidated: (bool value) {
                                          print(value);
                                        },
                                        selectorConfig: SelectorConfig(
                                          trailingSpace: false,
                                          selectorType:
                                              PhoneInputSelectorType.DIALOG,
                                        ),
                                        autofillHints: [
                                          AutofillHints.telephoneNumber
                                        ],
                                        focusNode: _buttonFocusNode,
                                        autoFocus: true,
                                        textAlignVertical:
                                            TextAlignVertical.center,
                                        textAlign: TextAlign.start,
                                        ignoreBlank: false,
                                        autoValidateMode:
                                            AutovalidateMode.disabled,
                                        selectorTextStyle:
                                            TextStyle(color: Colors.black),
                                        initialValue: number,
                                        textFieldController: phoneController,
                                        formatInput: false,
                                        keyboardType:
                                            TextInputType.numberWithOptions(
                                                signed: true, decimal: true),
                                        onSaved: (PhoneNumber number) {
                                          print('On Saved: $number');
                                          print(phoneController.text);
                                        },
                                        onSubmit: () {
                                          if (phoneController.text.isNotEmpty) {
                                            globals.phone =
                                                phoneController.text.toString();

                                            if (phonenumber
                                                    .toString()
                                                    .substring(0, 3) ==
                                                "+91") {
                                              if (phonenumber
                                                      .toString()
                                                      .substring(0, 4) ==
                                                  "+910") {
                                                phoneController.text =
                                                    phoneController.text
                                                        .toString()
                                                        .replaceFirst("0", "");

                                                phonenumber = phonenumber
                                                    .replaceRange(0, 4, '+91');

                                                getCodeWithPhoneNumber(
                                                    context, "${phonenumber}");
                                              } else {
                                                getCodeWithPhoneNumber(
                                                    context, "${phonenumber}");
                                              }
                                            } else {
                                              getCodeWithPhoneNumber(
                                                  context, "${phonenumber}");
                                            }
                                          } else if (phoneController
                                              .text.isEmpty) {
                                            Toast.show(
                                                'Please enter a phone number');
                                          }
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        if (phoneController.text.isNotEmpty) {
                                          globals.phone =
                                              phoneController.text.toString();

                                          if (phonenumber
                                                  .toString()
                                                  .substring(0, 3) ==
                                              "+91") {
                                            if (phonenumber
                                                    .toString()
                                                    .substring(0, 4) ==
                                                "+910") {
                                              phoneController.text =
                                                  phoneController.text
                                                      .toString()
                                                      .replaceFirst("0", "");

                                              phonenumber = phonenumber
                                                  .replaceRange(0, 4, '+91');

                                              getCodeWithPhoneNumber(
                                                  context, "${phonenumber}");
                                            } else {
                                              getCodeWithPhoneNumber(
                                                  context, "${phonenumber}");
                                            }
                                          } else {
                                            getCodeWithPhoneNumber(
                                                context, "${phonenumber}");
                                          }
                                        } else if (phoneController
                                            .text.isEmpty) {
                                          Toast.show(
                                              'Please enter a phone number');
                                        }
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 10),
                                        constraints:
                                            const BoxConstraints(maxWidth: 500),
                                        alignment: Alignment.center,
                                        decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(14)),
                                            gradient: LinearGradient(
                                                begin: Alignment.centerLeft,
                                                end: Alignment.centerRight,
                                                colors: [
                                                  // Color(0xFF8A2387),
                                                  Color.fromRGBO(
                                                      120, 96, 220, 1),
                                                  Color.fromRGBO(
                                                      120, 96, 220, 1),
                                                  Color.fromARGB(
                                                      255, 88, 52, 246),
                                                ])),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8, horizontal: 8),
                                        child: loading
                                            ? Padding(
                                                padding:
                                                    const EdgeInsets.all(6.0),
                                                child: Container(
                                                    height: 20,
                                                    width: 20,
                                                    child: Center(
                                                        child:
                                                            CircularProgressIndicator(
                                                                color: Colors
                                                                    .white))),
                                              )
                                            : Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: <Widget>[
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(12, 0, 0, 0),
                                                    child: Text(
                                                      'Next',
                                                      style: TextStyle(
                                                          color: Color.fromARGB(
                                                              255,
                                                              255,
                                                              255,
                                                              255),
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          const BorderRadius
                                                                  .all(
                                                              Radius.circular(
                                                                  20)),
                                                      color: MyColors
                                                          .primaryColorLight,
                                                    ),
                                                    child: Icon(
                                                      Icons.arrow_forward_ios,
                                                      color: Colors.white,
                                                      size: 16,
                                                    ),
                                                  )
                                                ],
                                              ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 40,
                                    ),
                                    Container(
                                      child: InkWell(
                                        onTap: () async {
                                          final Uri params = Uri(
                                              scheme: 'mailto',
                                              path: 'app.support@cloudyml.com',
                                              query: 'subject=Query about App');
                                          var mailurl = params.toString();
                                          if (await canLaunch(mailurl)) {
                                            await launch(mailurl);
                                          } else {
                                            throw 'Could not launch $mailurl';
                                          }
                                        },
                                        child: Text(
                                          'Need Help with Login?',
                                          textScaleFactor: min(
                                              horizontalScale, verticalScale),
                                          style: TextStyle(
                                              fontFamily: 'Regular',
                                              fontSize: 19,
                                              color: Colors.black),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedSwitcher(
                  duration: Duration(milliseconds: 200),
                  child: (formVisible)
                      ? (_formIndex == 1)
                          ? Container(
                              color: Colors.black54,
                              alignment: Alignment.center,
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton(
                                            onPressed: () {},
                                            style: ElevatedButton.styleFrom(
                                              primary: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          width * 0.06)),
                                            ),
                                            child: Text(
                                              'Login',
                                              textScaleFactor: min(
                                                  horizontalScale,
                                                  verticalScale),
                                              style: TextStyle(
                                                color: HexColor('6153D3'),
                                                fontSize: 16,
                                              ),
                                            )),
                                        SizedBox(
                                          width: horizontalScale * 17,
                                        ),
                                        IconButton(
                                            color: Colors.white,
                                            onPressed: () {
                                              setState(() {
                                                // formVisible = false;
                                              });
                                            },
                                            icon: Icon(Icons.clear))
                                      ],
                                    ),
                                    Container(
                                      child: AnimatedSwitcher(
                                        duration: Duration(milliseconds: 200),
                                        child: LoginForm(
                                          page: "OnBoard",
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            )
                          : Container(
                              color: Colors.black54,
                              alignment: Alignment.center,
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton(
                                            onPressed: () {},
                                            style: ElevatedButton.styleFrom(
                                              primary: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          width * 0.06)),
                                            ),
                                            child: Text('SignUp',
                                                textScaleFactor: min(
                                                    horizontalScale,
                                                    verticalScale),
                                                style: TextStyle(
                                                  color: HexColor('6153D3'),
                                                  fontSize: 18,
                                                ))),
                                        SizedBox(
                                          width: horizontalScale * 17,
                                        ),
                                        IconButton(
                                            color: Colors.white,
                                            onPressed: () {
                                              setState(() {
                                                // formVisible = false;
                                              });
                                            },
                                            icon: Icon(Icons.clear))
                                      ],
                                    ),
                                    Container(
                                      child: AnimatedSwitcher(
                                        duration: Duration(milliseconds: 200),
                                        child: SignUpform(
                                            // listOfAllExistingUser:
                                            //     listOfAllExistingUser,
                                            ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            )
                      : null),
            ],
          );
        } else {
          return SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: <Widget>[
                        Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 20),
                          child: Stack(
                            children: <Widget>[
                              Center(
                                child: Container(
                                    constraints:
                                        const BoxConstraints(maxHeight: 300),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    child: Image.asset(
                                        'assets/loginoop.png')), //assets/logingif.json
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text('CloudyML',
                                style: TextStyle(
                                    color: MyColors.primaryColor,
                                    fontSize: 25,
                                    fontWeight: FontWeight.w800)))
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: <Widget>[
                        Container(
                            constraints: const BoxConstraints(maxWidth: 500),
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(children: <TextSpan>[
                                TextSpan(
                                    text: 'We will send you an ',
                                    style: TextStyle(
                                        color: MyColors.primaryColor)),
                                TextSpan(
                                    text: 'One Time Password ',
                                    style: TextStyle(
                                        color: MyColors.primaryColor,
                                        fontWeight: FontWeight.bold)),
                                TextSpan(
                                    text: 'on this mobile number',
                                    style: TextStyle(
                                        color: MyColors.primaryColor)),
                              ]),
                            )),
                        Container(
                          height: 40,
                          constraints: const BoxConstraints(maxWidth: 500),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: InternationalPhoneNumberInput(
                            onInputChanged: (PhoneNumber number) {
                              print(number.phoneNumber);
                              print(phoneController.text);
                              phonenumber = number.phoneNumber.toString();
                              print("phone number: ${phonenumber}");
                            },
                            onInputValidated: (bool value) {
                              print(value);
                            },
                            selectorConfig: SelectorConfig(
                              trailingSpace: false,
                              selectorType: PhoneInputSelectorType.DIALOG,
                            ),
                            autofillHints: [AutofillHints.telephoneNumber],
                            autoFocus: true,
                            textAlignVertical: TextAlignVertical.center,
                            textAlign: TextAlign.start,
                            ignoreBlank: false,
                            autoValidateMode: AutovalidateMode.disabled,
                            selectorTextStyle: TextStyle(color: Colors.black),
                            initialValue: number,
                            textFieldController: phoneController,
                            formatInput: false,
                            keyboardType: TextInputType.numberWithOptions(
                                signed: true, decimal: true),
                            onSaved: (PhoneNumber number) {
                              print('On Saved: $number');
                              print(phoneController.text);
                            },
                          ),
                        ),
                        // Container(
                        //   height: 40,
                        //   constraints: const BoxConstraints(maxWidth: 500),
                        //   margin: const EdgeInsets.symmetric(
                        //       horizontal: 20, vertical: 10),
                        //   child: CupertinoTextField(
                        //     padding: const EdgeInsets.symmetric(horizontal: 16),
                        //     decoration: BoxDecoration(
                        //         color: Colors.white,
                        //         borderRadius:
                        //             const BorderRadius.all(Radius.circular(4))),
                        //     controller: phoneController,
                        //     clearButtonMode: OverlayVisibilityMode.editing,
                        //     keyboardType: TextInputType.phone,
                        //     maxLines: 1,
                        //     placeholder: '+91...',
                        //   ),
                        // ),
                        SizedBox(
                          height: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            if (phoneController.text.isNotEmpty) {
                              globals.phone = phoneController.text.toString();

                              if (phonenumber.toString().substring(0, 3) ==
                                  "+91") {
                                if (phonenumber.toString().substring(0, 4) ==
                                    "+910") {
                                  phoneController.text = phoneController.text
                                      .toString()
                                      .replaceFirst("0", "");

                                  phonenumber =
                                      phonenumber.replaceRange(0, 4, '+91');

                                  getCodeWithPhoneNumber(
                                      context, "${phonenumber}");
                                } else {
                                  getCodeWithPhoneNumber(
                                      context, "${phonenumber}");
                                }
                              } else {
                                getCodeWithPhoneNumber(
                                    context, "${phonenumber}");
                              }
                            } else if (phoneController.text.isEmpty) {
                              Toast.show('Please enter a phone number');
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            constraints: const BoxConstraints(maxWidth: 500),
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(14)),
                                gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      // Color(0xFF8A2387),
                                      Color.fromRGBO(120, 96, 220, 1),
                                      Color.fromRGBO(120, 96, 220, 1),
                                      Color.fromARGB(255, 88, 52, 246),
                                    ])),
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 8),
                            child: loading
                                ? Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: Container(
                                        height: 20,
                                        width: 20,
                                        child: Center(
                                            child: CircularProgressIndicator(
                                                color: Colors.white))),
                                  )
                                : Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            12, 0, 0, 0),
                                        child: Text(
                                          'Next',
                                          style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 255, 255, 255),
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(20)),
                                          color: MyColors.primaryColorLight,
                                        ),
                                        child: Icon(
                                          Icons.arrow_forward_ios,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          child: InkWell(
                            onTap: () async {
                              final Uri params = Uri(
                                  scheme: 'mailto',
                                  path: 'app.support@cloudyml.com',
                                  query: 'subject=Query about App');
                              var mailurl = params.toString();
                              if (await canLaunch(mailurl)) {
                                await launch(mailurl);
                              } else {
                                throw 'Could not launch $mailurl';
                              }
                            },
                            child: Text(
                              'Need Help with Login?',
                              textScaleFactor:
                                  min(horizontalScale, verticalScale),
                              style: TextStyle(
                                  fontFamily: 'Regular',
                                  fontSize: 19,
                                  color: Colors.black),
                            ),
                          ),
                        ),
                        // SizedBox(
                        //   height: 10,
                        // ),
                        // Container(
                        //   margin: const EdgeInsets.symmetric(
                        //       horizontal: 20, vertical: 10),
                        //   constraints:
                        //       const BoxConstraints(maxWidth: 500),
                        //   child: RaisedButton(
                        //     onPressed: () {
                        //       if (phoneController.text.isNotEmpty) {
                        //         loginStore.getCodeWithPhoneNumber(context,
                        //             "+91${phoneController.text.toString()}");
                        //       } else {
                        //         loginStore.loginScaffoldKey.currentState
                        //             ?.showSnackBar(SnackBar(
                        //           behavior: SnackBarBehavior.floating,
                        //           backgroundColor: Colors.red,
                        //           content: Text(
                        //             'Please enter a phone number',
                        //             style: TextStyle(color: Colors.white),
                        //           ),
                        //         ));
                        //       }
                        //     },
                        //     color: MyColors.primaryColor,
                        //     shape: const RoundedRectangleBorder(
                        //         borderRadius: BorderRadius.all(
                        //             Radius.circular(14))),
                        //     child: Container(
                        //       padding: const EdgeInsets.symmetric(
                        //           vertical: 8, horizontal: 8),
                        //       child: Row(
                        //         mainAxisAlignment:
                        //             MainAxisAlignment.spaceBetween,
                        //         children: <Widget>[
                        //           Text(
                        //             'Next',
                        //             style: TextStyle(color: Colors.white),
                        //           ),
                        //           Container(
                        //             padding: const EdgeInsets.all(8),
                        //             decoration: BoxDecoration(
                        //               borderRadius:
                        //                   const BorderRadius.all(
                        //                       Radius.circular(20)),
                        //               color: MyColors.primaryColorLight,
                        //             ),
                        //             child: Icon(
                        //               Icons.arrow_forward_ios,
                        //               color: Colors.white,
                        //               size: 16,
                        //             ),
                        //           )
                        //         ],
                        //       ),
                        //     ),
                        //   ),
                        // )
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        }
      }),
    );
  }

  Future<void> getCodeWithPhoneNumber(
      BuildContext context, String phoneNumber) async {
    setState(() {
      loading = true;
    });
    // if (phoneController.text.toString().substring(1, 4) == '+91') {
    //   if (phoneNumber[0] == '0') {
    //     phoneNumber = phoneNumber.replaceFirst("0", '');
    //     phoneController.text =
    //         phoneController.text.toString().replaceFirst("0", '');
    //   }
    // }

    List<dynamic> items = [];
    var docSnapshots;
    try {
      print("1");
      docSnapshots = await FirebaseFirestore.instance
          .collection("Users_dataly")
          .where('mobilenumber', isEqualTo: phoneController.text.toString())
          .get();
      await FirebaseFirestore.instance
          .collection("Users_dataly")
          .where('mobilenumber', isEqualTo: phoneController.text.toString())
          .get()
          .then((QuerySnapshot snapshot) {
        snapshot.docs.forEach((f) => items.add(f.data()));
      });
      if (items.length == 0) {
        docSnapshots = await FirebaseFirestore.instance
            .collection("Users_dataly")
            .where('mobilenumber',
                isEqualTo: int.parse(phoneController.text.toString()))
            .get();
        await FirebaseFirestore.instance
            .collection("Users_dataly")
            .where('mobilenumber',
                isEqualTo: int.parse(phoneController.text.toString()))
            .get()
            .then((QuerySnapshot snapshot) {
          snapshot.docs.forEach((f) => items.add(f.data()));
        });
      }

      if (items.length == 0) {
        if (phonenumber.toString().substring(0, 3) == "+91") {
          docSnapshots = await FirebaseFirestore.instance
              .collection("Users_dataly")
              .where('mobilenumber',
                  isEqualTo: "+910" + phoneController.text.toString())
              .get();
          await FirebaseFirestore.instance
              .collection("Users_dataly")
              .where('mobilenumber',
                  isEqualTo: "+910" + phoneController.text.toString())
              .get()
              .then((QuerySnapshot snapshot) {
            snapshot.docs.forEach((f) => items.add(f.data()));
          });
          if (items.length == 0) {
            docSnapshots = await FirebaseFirestore.instance
                .collection("Users_dataly")
                .where('mobilenumber',
                    isEqualTo: "0" + phoneController.text.toString())
                .get();
            await FirebaseFirestore.instance
                .collection("Users_dataly")
                .where('mobilenumber',
                    isEqualTo: "0" + phoneController.text.toString())
                .get()
                .then((QuerySnapshot snapshot) {
              snapshot.docs.forEach((f) => items.add(f.data()));
            });
          }
        }
      }

      print("2");

      print("1sdkfffffj${items}");

      if (items.length == 0) {
        print("3");
        docSnapshots = await FirebaseFirestore.instance
            .collection("Users_dataly")
            .where('mobilenumber', isEqualTo: phoneNumber)
            .get();

        print("4");

        await FirebaseFirestore.instance
            .collection("Users_dataly")
            .where('mobilenumber', isEqualTo: phoneNumber)
            .get()
            .then((QuerySnapshot snapshot) {
          snapshot.docs.forEach((f) => items.add(f.data()));
        });
      }

      // if (items.length == 0) {
      //   print("3");
      //   docSnapshots = await FirebaseFirestore.instance
      //       .collection("Users_dataly")
      //       .where('mobilenumber', isEqualTo: "0"+phoneNumber)
      //       .get();

      //   print("4");

      //   await FirebaseFirestore.instance
      //       .collection("Users_dataly")
      //       .where('mobilenumber', isEqualTo: "0"+phoneNumber)
      //       .get()
      //       .then((QuerySnapshot snapshot) {
      //     snapshot.docs.forEach((f) => items.add(f.data()));
      //   });
      // }

      if (items.length == 0) {
        final docSnapshot = await FirebaseFirestore.instance
            .collection('UserData')
            .doc()
            .set({"phone": phoneNumber, "date": DateTime.now()});
      }

      Map data = items[0];
      globals.googleAuth = data.containsValue("googleAuth").toString();
      globals.phone = data.containsValue("phoneAuth").toString();
      globals.linked = data.containsKey("linked").toString();
      print("ddddddddddddddd");

      print(globals.googleAuth);
      print(globals.linked);
      print("dsdssssssssssssssssss");
      print("7");
      final userSnapshot = docSnapshots.docs.first;
      print("8");
      globals.phoneNumberexists = userSnapshot.exists.toString();
      print("llllllsfsui");
      print(userSnapshot.exists.toString());
      print("llllllsfsui");
      if (!userSnapshot.exists) {
        final docSnapshot = await FirebaseFirestore.instance
            .collection('UserData')
            .doc()
            .set({"phone": phoneNumber, "date": DateTime.now()});
      }
    } catch (e) {
      print(e);
      print("9");
    }
    print("10");
    if (true) {
      print("11");
      setState(() {
        loading = true;
      });
      await _auth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          timeout: const Duration(seconds: 60),
          verificationCompleted: (AuthCredential auth) async {
            await _auth.signInWithCredential(auth).then((dynamic value) {
              print("1");
              if (value != null && value.user != null) {
                setState(() {
                  loading = false;
                  print("2");
                });
                print('Authentication successful');
              } else {
                setState(() {
                  loading = false;
                });
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.red,
                  content: Text(
                    'Invalid code/invalid authentication',
                    style: TextStyle(color: Colors.white),
                  ),
                );
                print("3");
              }
            }).catchError((error) {
              setState(() {
                loading = false;
              });
              Toast.show(error);
            });
          },
          verificationFailed: (dynamic authException) {
            Toast.show('Error message: ' + authException.message);
            print('Error message: ' + authException.message);
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.red,
              content: Text(
                'The phone number format is incorrect. Please enter your number in E.164 format. [+][country code][number]',
                style: TextStyle(color: Colors.white),
              ),
            );
            setState(() {
              loading = false;
            });
          },
          codeSent: (String verificationId, int? forceResendingToken) async {
            setState(() {
              loading = false;
            });
            actualCode = verificationId;
            globals.actualCode = verificationId;
            globals.phone = phoneNumber;
            print(
                "tttttttttttttttttttttttttttttttttttttttttttttttttttttttt ${phoneNumber}");

            setState(() {
              loading = false;
            });
            await Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => OtpPage('')));
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            actualCode = verificationId;
            globals.actualCode = verificationId;
          });
    }
  }
// Future<void> onAuthenticationSuccessful(
//     BuildContext context, dynamic result) async {
//   // firebaseUser = result.user;

//   var user = FirebaseAuth.instance.currentUser;
//   if (globals.name != "") {
//     if (user != null) {
//       setState(() {
//         loading = false;
//       });
//       DocumentSnapshot userDocs = await FirebaseFirestore.instance
//           .collection("Users_dataly")
//           .doc(FirebaseAuth.instance.currentUser!.uid)
//           .get();
//       if (userDocs.data() == null) {
//         userprofile(
//             name: globals.name,
//             image: '',
//             mobilenumber: globals.phone,
//             authType: 'phoneAuth',
//             phoneVerified: true,
//             email: globals.email);
//       }
//     } else {
//       setState(() {
//         loading = false;
//       });
//       showToast('user does not exist');
//     }
//     setState(() {
//       loading = false;
//     });
//   }
//   setState(() {
//     loading = false;
//   });

//   Navigator.of(context).pushAndRemoveUntil(
//       MaterialPageRoute(builder: (_) => HomePage()),
//       (Route<dynamic> route) => false);
// }
}
