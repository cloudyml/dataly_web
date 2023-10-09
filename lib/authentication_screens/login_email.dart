import 'dart:developer';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudyml_app2/authentication_screens/otp_page.dart';
import 'package:cloudyml_app2/authentication_screens/signin_password.dart';
import 'package:cloudyml_app2/home.dart';
import 'package:cloudyml_app2/homescreen/homescreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:lottie/lottie.dart';
import 'package:cloudyml_app2/theme.dart';
import 'package:cloudyml_app2/global_variable.dart' as globals;
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:toast/toast.dart';
import '../Providers/UserProvider.dart';
import '../authentication/firebase_auth.dart';
import '../globals.dart';
import '../models/UserModel.dart';
import '../router/login_state_check.dart';
import 'login_username.dart';

class LoginEmailPage extends StatefulWidget {
  String user;
  LoginEmailPage({Key? key, required this.user}) : super(key: key);
  @override
  _LoginEmailPageState createState() => _LoginEmailPageState();
}

class _LoginEmailPageState extends State<LoginEmailPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _passwordVisible = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool loading = false;

  late String feaurl;
  late String deurl;
  late String supurl;
  late String depayurl;
  late String suppayurl;
  late String interntnl;
  late String promEng;

  void url() async {
    diurl = await FirebaseFirestore.instance
        .collection("Notice")
        .doc("7A85zuoLi4YQpbXlbOAh_redirect")
        .get()
        .then((value) {
      print(value.data()!.values.first);
      return value.data()!.values.first;
    });

    print("url is=====$diurl");

    interntnl = await FirebaseFirestore.instance
        .collection("Notice")
        .doc("7A85zuoLi4YQpbXlbOAh_redirect")
        .get()
        .then((value) {
      print(value.data()!.values.first);
      return value.data()!.values.first;
    });

    print("url is=====$interntnl");
     promEng= await FirebaseFirestore.instance
        .collection("Notice")
        .doc("HX4neryeAOB1dzUeIAg1_prompt")
        .get()
        .then((value) {
      print(value.data()!.values.first);
      return value.data()!.values.first;
    });

    print("url is=====$promEng");

    payurl = await FirebaseFirestore.instance
        .collection("Notice")
        .doc("NBrEm6KGry8gxOJJkegG_redirect_pay")
        .get()
        .then((value) {
      print(value.data()!.values.first);
      return value.data()!.values.first;
    });

    print("url is=====$payurl");
    feaurl = await FirebaseFirestore.instance
        .collection("Notice")
        .doc("XdYtk2DJBIkRGx0ASthZ_newfeaturecourse")
        .get()
        .then((value) {
      print(value.data()!.values.first);
      return value.data()!.values.first;
    });

    print("url is=====$feaurl");

    deurl = await FirebaseFirestore.instance
        .collection("Notice")
        .doc("fSU4MLz1E0858ft8m7F5_dataeng")
        .get()
        .then((value) {
      print(value.data()!.values.first);
      return value.data()!.values.first;
    });

    print("url is=====$deurl");

    supurl = await FirebaseFirestore.instance
        .collection("Notice")
        .doc("JnCFQ1bT36xl0xKjDL3a_superstar")
        .get()
        .then((value) {
      print(value.data()!.values.first);
      return value.data()!.values.first;
    });

    print("url is=====$supurl");

    depayurl = await FirebaseFirestore.instance
        .collection("Notice")
        .doc("M2jEwYyiWdzYWE9gJd8s_de_pay")
        .get()
        .then((value) {
      print(value.data()!.values.first);
      return value.data()!.values.first;
    });

    print("url is=====$supurl");

    suppayurl = await FirebaseFirestore.instance
        .collection("Notice")
        .doc("o1Hw1CebDH9I4VfpKuiC_sup_pay")
        .get()
        .then((value) {
      print(value.data()!.values.first);
      return value.data()!.values.first;
    });

    print("url is=====$supurl");
  }

  @override
  void initState() {
    super.initState();
    url();
    print("rrrrrrrrrrrrrrrrr: ${widget.user}");
    print(globals.action);
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    var verticalScale = height / mockUpHeight;
    var horizontalScale = width / mockUpWidth;
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                color: Color.fromARGB(255, 140, 58, 240),
              ),
              child: Icon(
                Icons.arrow_back_ios,
                color: Color.fromRGBO(35, 0, 79, 1),
                size: 16,
              ),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          elevation: 0,
          backgroundColor: HexColor("7226D1"),
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
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
                                SizedBox(
                                  width: Adaptive.w(18.5),
                                  child: Stack(
                                    children: [
                                      Image.asset(
                                        'assets/logo.png',
                                        height: 75,
                                        width: 110,
                                        cacheWidth: 82,
                                        cacheHeight: 56,
                                      ),
                                      ],
                                  ),
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
                                      fontSize: 34),
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Image.asset('assets/loginoop.png'),
                                    // child: SvgPicture.asset(
                                    //   'assets/Frame.svg',
                                    //   height: verticalScale * 360,
                                    //   width: horizontalScale * 300,
                                    //   fit: BoxFit.fill,
                                    // ),
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
                          height: MediaQuery.of(context).size.height,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(4, 60, 4, 0),
                            child: Column(
                              children: <Widget>[
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                          constraints: const BoxConstraints(
                                              maxWidth: 500),
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: RichText(
                                            textAlign: TextAlign.center,
                                            text: TextSpan(children: <TextSpan>[
                                              TextSpan(
                                                  text:
                                                      'We look forward to getting to know you better.',
                                                  style: TextStyle(
                                                      color:
                                                          MyColors.primaryColor,
                                                      fontSize: 18)),
                                              TextSpan(
                                                  text: '',
                                                  style: TextStyle(
                                                      color:
                                                          MyColors.primaryColor,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18)),
                                              TextSpan(
                                                  text:
                                                      " Let's begin with email",
                                                  style: TextStyle(
                                                      color:
                                                          MyColors.primaryColor,
                                                      fontSize: 18)),
                                            ]),
                                          )),
                                      SizedBox(
                                        height: 40,
                                      ),
                                      widget.user == "signup"
                                          ? Column(
                                              children: <Widget>[
                                                Container(
                                                  height: 60,
                                                  constraints:
                                                      const BoxConstraints(
                                                          maxWidth: 500),
                                                  margin: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 20,
                                                      vertical: 10),
                                                  child: CupertinoTextField(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 16),
                                                    decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            const BorderRadius
                                                                    .all(
                                                                Radius.circular(
                                                                    4))),
                                                    controller: nameController,
                                                    clearButtonMode:
                                                        OverlayVisibilityMode
                                                            .editing,
                                                    keyboardType:
                                                        TextInputType.name,
                                                    maxLines: 1,
                                                    placeholder: 'Name',
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Container(),
                                      Container(
                                        height: 40,
                                        constraints:
                                            const BoxConstraints(maxWidth: 500),
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 10),
                                        child: CupertinoTextField(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16),
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(4))),
                                          controller: emailController,
                                          clearButtonMode:
                                              OverlayVisibilityMode.editing,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          maxLines: 1,
                                          placeholder: 'Email',
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      widget.user == "signin"
                                          ? Expanded(
                                              flex: 0,
                                              child: Column(
                                                children: <Widget>[
                                                  Container(
                                                    height: 40,
                                                    constraints:
                                                        const BoxConstraints(
                                                            maxWidth: 500),
                                                    margin: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 20,
                                                        vertical: 10),
                                                    child: CupertinoTextField(
                                                      suffix: IconButton(
                                                        icon: Icon(
                                                          // Based on passwordVisible state choose the icon
                                                          _passwordVisible
                                                              ? Icons.visibility
                                                              : Icons
                                                                  .visibility_off,
                                                          color: Color.fromRGBO(
                                                              120, 96, 220, 1),
                                                        ),
                                                        onPressed: () {
                                                          // Update the state i.e. toogle the state of passwordVisible variable
                                                          setState(() {
                                                            _passwordVisible =
                                                                !_passwordVisible;
                                                          });
                                                        },
                                                      ),
                                                      obscureText:
                                                          !_passwordVisible,
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 16),
                                                      decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              const BorderRadius
                                                                      .all(
                                                                  Radius
                                                                      .circular(
                                                                          4))),
                                                      clearButtonMode:
                                                          OverlayVisibilityMode
                                                              .editing,
                                                      keyboardType:
                                                          TextInputType.text,
                                                      controller:
                                                          passwordController,
                                                      maxLines: 1,
                                                      placeholder: 'Password',
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 4,
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                            .fromLTRB(
                                                        8.0, 2, 18, 8),
                                                    child: InkWell(
                                                      onTap: () {
                                                        if (emailController
                                                            .text.isNotEmpty) {
                                                          _auth.sendPasswordResetEmail(
                                                              email: emailController
                                                                  .text
                                                                  .toLowerCase()
                                                                  .toString());
                                                          showDialog(
                                                              context: context,
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                Future.delayed(
                                                                    Duration(
                                                                        seconds:
                                                                            13),
                                                                    () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop(
                                                                          true);
                                                                });
                                                                return AlertDialog(
                                                                  title: Center(
                                                                    child:
                                                                        Column(
                                                                      children: [
                                                                        Lottie.asset(
                                                                            'assets/email.json',
                                                                            height: height *
                                                                                0.15,
                                                                            width:
                                                                                width * 0.5),
                                                                        Text(
                                                                          'Reset Password',
                                                                          textScaleFactor: min(
                                                                              horizontalScale,
                                                                              verticalScale),
                                                                          style: TextStyle(
                                                                              color: Colors.red,
                                                                              fontSize: 22,
                                                                              fontWeight: FontWeight.bold),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  content:
                                                                      Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    children: [
                                                                      Text(
                                                                        'An email has been sent to ',
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        style:
                                                                            TextStyle(),
                                                                      ),
                                                                      Text(
                                                                        '${emailController.text.toLowerCase().toString()}',
                                                                        style: TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold),
                                                                      ),
                                                                      Text(
                                                                        'Click the link in the email to change password.',
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                      ),
                                                                      SizedBox(
                                                                        height:
                                                                            verticalScale *
                                                                                10,
                                                                      ),
                                                                      Text(
                                                                        'Didn\'t get the email?',
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        style: TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold),
                                                                      ),
                                                                      Text(
                                                                        'Check entered email or check spam folder.',
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        style:
                                                                            TextStyle(),
                                                                      ),
                                                                      TextButton(
                                                                          child:
                                                                              Text(
                                                                            'Retry',
                                                                            textScaleFactor:
                                                                                min(horizontalScale, verticalScale),
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 20,
                                                                            ),
                                                                          ),
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.pop(context,
                                                                                true);
                                                                          }),
                                                                    ],
                                                                  ),
                                                                );
                                                              });
                                                        } else {
                                                          showDialog(
                                                              context: context,
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return AlertDialog(
                                                                    title:
                                                                        Center(
                                                                      child:
                                                                          Text(
                                                                        'Error',
                                                                        textScaleFactor: min(
                                                                            horizontalScale,
                                                                            verticalScale),
                                                                        style: TextStyle(
                                                                            color: Colors
                                                                                .red,
                                                                            fontSize:
                                                                                24,
                                                                            fontWeight:
                                                                                FontWeight.bold),
                                                                      ),
                                                                    ),
                                                                    content:
                                                                        Text(
                                                                      'Enter email in the email field or check if the email is valid.',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      textScaleFactor: min(
                                                                          horizontalScale,
                                                                          verticalScale),
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              16),
                                                                    ),
                                                                    actions: [
                                                                      TextButton(
                                                                          child: Text(
                                                                              'Retry'),
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.pop(context,
                                                                                true);
                                                                          })
                                                                    ]);
                                                              });
                                                        }
                                                      },
                                                      child: Align(
                                                        alignment: Alignment
                                                            .bottomRight,
                                                        child: Text(
                                                          'Forgot Password?',
                                                          textScaleFactor: min(
                                                              horizontalScale,
                                                              verticalScale),
                                                          textAlign:
                                                              TextAlign.end,
                                                          style: TextStyle(
                                                              color: HexColor(
                                                                  '8346E1'),
                                                              fontSize: 16),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : Container(),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      GestureDetector(
                                          onTap: () async {
                                            if (widget.user == "signup") {
                                              print('uuyguyguguy');
                                              if (nameController
                                                  .text.isNotEmpty) {
                                                if (RegExp(
                                                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                                    .hasMatch(emailController
                                                        .text
                                                        .toLowerCase()
                                                        .toString())) {
                                                  if (email != "" ||
                                                      email != null) {
                                                    try {
                                                      setState(() {
                                                        loading = true;
                                                      });
                                                      globals.email =
                                                          emailController.text
                                                              .toLowerCase()
                                                              .toString();
                                                      FirebaseAuth _auth =
                                                          FirebaseAuth.instance;
                                                      userprofile(
                                                          listOfCourses: [],
                                                          linked: "true",
                                                          name: nameController
                                                              .text
                                                              .toString(),
                                                          image: '',
                                                          mobilenumber:
                                                              globals.phone,
                                                          authType: 'phoneAuth',
                                                          phoneVerified: true,
                                                          email: globals.email);
                                                      try {
                                                        Future.delayed(
                                                            const Duration(
                                                                seconds: 2),
                                                            () {
                                                          if (feaurl ==
                                                              'aEGX6kMfHzQrVgP3WCwU') {
                                                            final id = "0";
                                                            final cID =
                                                                "aEGX6kMfHzQrVgP3WCwU";
                                                            final courseName =
                                                                "Data Science & Analytics Placement Assurance Program";
                                                            final courseP =
                                                                "11999";
                                                            GoRouter.of(context)
                                                                .goNamed(
                                                                    'NewFeature',
                                                                    queryParams: {
                                                                  'cID': cID,
                                                                  'courseName':
                                                                      courseName,
                                                                  'id': id,
                                                                  'coursePrice':
                                                                      courseP
                                                                });
                                                          } else if (promEng ==
                                                              'RIUjOvGBV6YSzMTpMWEG') {
                                                            final cID =
                                                                "RIUjOvGBV6YSzMTpMWEG";
                                                            GoRouter.of(context)
                                                                .go(
                                                              '/paymentPortal?cID=RIUjOvGBV6YSzMTpMWEG',
                                                              // queryParams: {
                                                              //   'cID': cID,
                                                              //   }
                                                            );
                                                          } else if (payurl ==
                                                              'aEGX6kMfHzQrVgP3WCwU') {
                                                            final cID =
                                                                "aEGX6kMfHzQrVgP3WCwU";
                                                            GoRouter.of(context)
                                                                .go(
                                                              '/paymentPortal?cID=aEGX6kMfHzQrVgP3WCwU',
                                                              // queryParams: {
                                                              //   'cID': cID,
                                                              //   }
                                                            );
                                                          }else if (depayurl ==
                                                              'F9gxnjW9nf5Lxg5A6758') {
                                                            final cID =
                                                                "F9gxnjW9nf5Lxg5A6758";
                                                            GoRouter.of(context)
                                                                .go(
                                                              '/comboPaymentPortal?cID=F9gxnjW9nf5Lxg5A6758',
                                                              // queryParams: {
                                                              //   'cID': cID,
                                                              //   }
                                                            );
                                                          } else if (suppayurl ==
                                                              'XSNqt0oNpuY7i2kb7zsW') {
                                                            final cID =
                                                                "XSNqt0oNpuY7i2kb7zsW";
                                                            GoRouter.of(context)
                                                                .go(
                                                              '/comboPaymentPortal?cID=XSNqt0oNpuY7i2kb7zsW',
                                                              // queryParams: {
                                                              //   'cID': cID,
                                                              //   }
                                                            );
                                                          } else if (deurl ==
                                                              'F9gxnjW9nf5Lxg5A6758') {
                                                            final id = "0";
                                                            final cID =
                                                                "F9gxnjW9nf5Lxg5A6758";
                                                            final courseName =
                                                                "Data Engineering Placement Assurance Program";
                                                            final courseP =
                                                                "12000";
                                                            GoRouter.of(context)
                                                                .goNamed(
                                                                    'NewFeature',
                                                                    queryParams: {
                                                                  'cID': cID,
                                                                  'courseName':
                                                                      courseName,
                                                                  'id': id,
                                                                  'coursePrice':
                                                                      courseP
                                                                });
                                                          } else if (interntnl ==
                                                              'mPqg2Z2BdNHvwaqAEfA0') {
                                                            final id = "0";
                                                            final cID =
                                                                "mPqg2Z2BdNHvwaqAEfA0";
                                                            final courseName =
                                                                "Data Superstar(International)";
                                                            final courseP =
                                                                "399";
                                                            GoRouter.of(context)
                                                                .goNamed(
                                                                    'NewFeature',
                                                                    queryParams: {
                                                                  'cID': cID,
                                                                  'courseName':
                                                                      courseName,
                                                                  'id': id,
                                                                  'coursePrice':
                                                                      courseP
                                                                });
                                                          } else if (supurl ==
                                                              'XSNqt0oNpuY7i2kb7zsW') {
                                                            final id = "0";
                                                            final cID =
                                                                "XSNqt0oNpuY7i2kb7zsW";
                                                            final courseName =
                                                                "Data Superstar Placement Assurance Program";
                                                            final courseP =
                                                                "20000";
                                                            GoRouter.of(context)
                                                                .goNamed(
                                                                    'NewFeature',
                                                                    queryParams: {
                                                                  'cID': cID,
                                                                  'courseName':
                                                                      courseName,
                                                                  'id': id,
                                                                  'coursePrice':
                                                                      courseP
                                                                });
                                                          } else {
                                                            Navigator.of(
                                                                    context)
                                                                .push(MaterialPageRoute(
                                                                    builder: (_) =>
                                                                        LandingScreen()));
                                                          }
                                                          // Navigator.of(
                                                          //         context)
                                                          //     .pushReplacement(
                                                          //   MaterialPageRoute(
                                                          //     builder: (_) =>
                                                          //         HomePage(),
                                                          //   ),
                                                          // );
                                                          saveLoginState(
                                                              context);
                                                          setState(() {
                                                            loading = false;
                                                          });
                                                        });
                                                      } catch (e) {
                                                        Toast.show(
                                                            e.toString());
                                                        Navigator.of(context)
                                                            .pushReplacement(
                                                          MaterialPageRoute(
                                                            builder: (_) => OtpPage(
                                                                "fromemailpage"),
                                                          ),
                                                        );
                                                      }
                                                    } catch (e) {
                                                      setState(() {
                                                        loading = false;
                                                      });
                                                      print(e.toString());
                                                      Toast.show(e.toString());
                                                    }

                                                    // try {
                                                    // var value = await FirebaseAuth
                                                    //     .instance
                                                    //     .currentUser!
                                                    //     .uid;
                                                    // print(
                                                    //     "sdjsodjew${globals.moneyrefcode}");
                                                    // if (globals.moneyrefcode !=
                                                    //     '') {
                                                    //   print("ijsofjdserer");
                                                    //   courseId = globals
                                                    //       .moneyrefcode
                                                    //       .split('-')[1];
                                                    //   try {
                                                    //     print(
                                                    //         "sdjsdfgdohroeodjew");
                                                    //     await FirebaseFirestore
                                                    //         .instance
                                                    //         .collection("Users_dataly")
                                                    //         .doc(FirebaseAuth
                                                    //             .instance
                                                    //             .currentUser!
                                                    //             .uid)
                                                    //         .get()
                                                    //         .then((value) async {
                                                    //       try {
                                                    //         print(
                                                    //             "sdjsodjesfwenjoerigoeg");
                                                    //         print(
                                                    //             "sdsdfsoijojwjjgsdsdsdrgjei ${value.data()!['sendermoneyrefuid']}");
                                                    // if (true) {
                                                    // await FirebaseFirestore
                                                    //     .instance
                                                    //     .collection(
                                                    //         "Users")
                                                    //     .doc(FirebaseAuth
                                                    //         .instance
                                                    //         .currentUser!
                                                    //         .uid)
                                                    //     .update({
                                                    //   "sendermoneyrefuid":
                                                    //       globals
                                                    //           .moneyrefcode
                                                    //           .split(
                                                    //               '-')[2],
                                                    //   "senderrefvalidfrom":
                                                    //       DateTime.now()
                                                    // });
                                                    // }
                                                    //       } catch (e) {
                                                    //         print(
                                                    //             "tyuiiiiii${e.toString()}");
                                                    //       }
                                                    //     });
                                                    //   } catch (e) {
                                                    //     print(
                                                    //         "poooiiieirj${e.toString()}");
                                                    //   }
                                                    // } else {
                                                    //   Navigator.of(context)
                                                    //       .pushReplacement(
                                                    //     MaterialPageRoute(
                                                    //       builder: (_) =>
                                                    //           HomePage(),
                                                    //     ),
                                                    //   );
                                                    // }
                                                    //   setState(() {
                                                    //     loading = false;
                                                    //   });
                                                    // } catch (e) {
                                                    //   showToast(
                                                    //       "error jkl ${e.toString()}");
                                                    //   print("jkl");
                                                    //   print(e.toString());
                                                    //   Navigator.of(context)
                                                    //       .pushReplacement(
                                                    //     MaterialPageRoute(
                                                    //       builder: (_) =>
                                                    //           HomePage(),
                                                    //     ),
                                                    //   );
                                                    // }
                                                  } else {
                                                    setState(() {
                                                      loading = false;
                                                    });
                                                    Toast.show(
                                                        'Please enter a email');
                                                  }
                                                } else {
                                                  setState(() {
                                                    loading = false;
                                                  });
                                                  Toast.show(
                                                      'Please enter a valid email');
                                                }
                                              } else {
                                                Toast.show(
                                                    "please enter your name");
                                              }
                                            } else if (widget.user ==
                                                "signin") {
                                              bool otpverified = true;
                                              print('dfgdrgergreger');
                                              if (passwordController
                                                  .text.isNotEmpty) {
                                                setState(() {
                                                  loading = true;
                                                });
                                                User? user;
                                                FirebaseAuth _auth =
                                                    FirebaseAuth.instance;
                                                try {
                                                  user = (await _auth.signInWithEmailAndPassword(
                                                          email: emailController
                                                              .text
                                                              .toLowerCase()
                                                              .toString(),
                                                          password:
                                                              passwordController
                                                                  .text
                                                                  .toString()))
                                                      .user;

                                                  //otp verification and linking
                                                  try {
                                                    await _auth.currentUser!
                                                        .linkWithCredential(
                                                            globals.credental);
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection("Users_dataly")
                                                        .doc(_auth
                                                            .currentUser!.uid)
                                                        .update({
                                                      "linked": "true",
                                                    });
                                                  } catch (e) {
                                                    Toast.show(e.toString());
                                                    otpverified = false;
                                                    Navigator.of(context)
                                                        .pushReplacement(
                                                      MaterialPageRoute(
                                                        builder: (_) => OtpPage(
                                                            "fromemailpage"),
                                                      ),
                                                    );
                                                  }

                                                  var value = await FirebaseAuth
                                                      .instance
                                                      .currentUser!
                                                      .uid;

                                                  setState(() {
                                                    loading = false;
                                                  });
                                                } on FirebaseException catch (e) {
                                                  print("iooijjj${e.code}");
                                                  setState(() {
                                                    loading = false;
                                                  });
                                                  // showToast(e.toString());
                                                  if (e.code.toString() ==
                                                      "wrong-password") {
                                                    setState(() {
                                                      loading = false;
                                                    });
                                                    Toast.show(
                                                        "wrong password");
                                                  }
                                                  Toast.show(e.toString());
                                                  setState(() {
                                                    loading = false;
                                                  });
                                                }

                                                // showToast("here");
                                                if (user != null) {
                                                  // if (globals.moneyrefcode !=
                                                  //     '') {
                                                  //   courseId = globals
                                                  //       .moneyrefcode
                                                  //       .split('-')[1];
                                                  //   try {
                                                  //     await FirebaseFirestore
                                                  //         .instance
                                                  //         .collection("Users_dataly")
                                                  //         .doc(FirebaseAuth
                                                  //             .instance
                                                  //             .currentUser!
                                                  //             .uid)
                                                  //         .get()
                                                  //         .then((value) async {
                                                  //       try {
                                                  //         print(
                                                  //             "sdsdfsoijojwjjgsdsdsdrgjei ${value.data()!['sendermoneyrefuid']}");
                                                  //         if (true) {
                                                  //           await FirebaseFirestore
                                                  //               .instance
                                                  //               .collection(
                                                  //                   "Users")
                                                  //               .doc(FirebaseAuth
                                                  //                   .instance
                                                  //                   .currentUser!
                                                  //                   .uid)
                                                  //               .update({
                                                  //             "sendermoneyrefuid":
                                                  //                 globals
                                                  //                     .moneyrefcode
                                                  //                     .split(
                                                  //                         '-')[2],
                                                  //             "senderrefvalidfrom":
                                                  //                 DateTime.now()
                                                  //           });
                                                  //         }
                                                  //       } catch (e) {
                                                  //         print(
                                                  //             "tyuiiiiii${e.toString()}");
                                                  //       }
                                                  //     });
                                                  //   } catch (e) {
                                                  //     print(
                                                  //         "poooiiieirj${e.toString()}");
                                                  //   }
                                                  // } else {
                                                  //adding condition for handling otp verification error
                                                  if (otpverified) {
                                                    // Navigator.of(context)
                                                    //     .pushReplacement(
                                                    //   MaterialPageRoute(
                                                    //     builder: (_) =>
                                                    //         HomePage(),
                                                    //   ),
                                                    // );
                                                    if (diurl ==
                                                        '/InternationalPaymentScreen') {
                                                      final cID =
                                                          "aEGX6kMfHzQrVgP3WCwU";
                                                      GoRouter.of(context).go(
                                                        '/InternationalPaymentScreen?cID=mPqg2Z2BdNHvwaqAEfA0',
                                                        // queryParams: {
                                                        //   'cID': cID,
                                                        //   }
                                                      );
                                                    } else if (deurl ==
                                                        'F9gxnjW9nf5Lxg5A6758') {
                                                      final id = "0";
                                                      final cID =
                                                          "F9gxnjW9nf5Lxg5A6758";
                                                      final courseName =
                                                          "Data Engineering Placement Assurance Program";
                                                      final courseP = "12000";
                                                      GoRouter.of(context)
                                                          .goNamed('NewFeature',
                                                              queryParams: {
                                                            'cID': cID,
                                                            'courseName':
                                                                courseName,
                                                            'id': id,
                                                            'coursePrice':
                                                                courseP
                                                          });
                                                    } else if (interntnl ==
                                                        'mPqg2Z2BdNHvwaqAEfA0') {
                                                      final id = "0";
                                                      final cID =
                                                          "mPqg2Z2BdNHvwaqAEfA0";
                                                      final courseName =
                                                          "Data Superstar(International)";
                                                      final courseP = "399";
                                                      GoRouter.of(context)
                                                          .goNamed('NewFeature',
                                                              queryParams: {
                                                            'cID': cID,
                                                            'courseName':
                                                                courseName,
                                                            'id': id,
                                                            'coursePrice':
                                                                courseP
                                                          });
                                                    } else if (supurl ==
                                                        'XSNqt0oNpuY7i2kb7zsW') {
                                                      final id = "0";
                                                      final cID =
                                                          "XSNqt0oNpuY7i2kb7zsW";
                                                      final courseName =
                                                          "Data Superstar Placement Assurance Program";
                                                      final courseP = "20000";
                                                      GoRouter.of(context)
                                                          .goNamed('NewFeature',
                                                              queryParams: {
                                                            'cID': cID,
                                                            'courseName':
                                                                courseName,
                                                            'id': id,
                                                            'coursePrice':
                                                                courseP
                                                          });
                                                    } else if (payurl ==
                                                        'aEGX6kMfHzQrVgP3WCwU') {
                                                      final cID =
                                                          "aEGX6kMfHzQrVgP3WCwU";
                                                      GoRouter.of(context).go(
                                                        '/paymentPortal?cID=aEGX6kMfHzQrVgP3WCwU',
                                                        // queryParams: {
                                                        //   'cID': cID,
                                                        //   }
                                                      );
                                                    }  else if (promEng ==
                                                        'RIUjOvGBV6YSzMTpMWEG') {
                                                      final cID =
                                                          "RIUjOvGBV6YSzMTpMWEG";
                                                      GoRouter.of(context).go(
                                                        '/paymentPortal?cID=RIUjOvGBV6YSzMTpMWEG',
                                                        // queryParams: {
                                                        //   'cID': cID,
                                                        //   }
                                                      );
                                                    }else if (depayurl ==
                                                        'F9gxnjW9nf5Lxg5A6758') {
                                                      final cID =
                                                          "F9gxnjW9nf5Lxg5A6758";
                                                      GoRouter.of(context).go(
                                                        '/comboPaymentPortal?cID=F9gxnjW9nf5Lxg5A6758',
                                                        // queryParams: {
                                                        //   'cID': cID,
                                                        //   }
                                                      );
                                                    } else if (suppayurl ==
                                                        'XSNqt0oNpuY7i2kb7zsW') {
                                                      final cID =
                                                          "XSNqt0oNpuY7i2kb7zsW";
                                                      GoRouter.of(context).go(
                                                        '/comboPaymentPortal?cID=XSNqt0oNpuY7i2kb7zsW',
                                                        // queryParams: {
                                                        //   'cID': cID,
                                                        //   }
                                                      );
                                                    } else {
                                                      Navigator.of(context).push(
                                                          MaterialPageRoute(
                                                              builder: (_) =>
                                                                  LandingScreen()));
                                                    }
                                                    saveLoginState(context);
                                                    // }
                                                  }
                                                } else {
                                                  Toast.show("wrong password");
                                                }
                                              } else {
                                                Toast.show(
                                                    "enter your password");
                                              }
                                            } else {
                                              // await email(
                                              //     context,
                                              //     emailController.text
                                              //         .toLowerCase()
                                              //         .toString());
                                            }
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 10),
                                            constraints: const BoxConstraints(
                                                maxWidth: 500),
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
                                                        const EdgeInsets.all(
                                                            6.0),
                                                    child: Container(
                                                        height: 20,
                                                        width: 20,
                                                        child: Center(
                                                            child: CircularProgressIndicator(
                                                                color: Colors
                                                                    .white))),
                                                  )
                                                : Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: <Widget>[
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .fromLTRB(
                                                                12, 0, 0, 0),
                                                        child: Text(
                                                          'Next',
                                                          style: TextStyle(
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      255,
                                                                      255,
                                                                      255),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ),
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              const BorderRadius
                                                                      .all(
                                                                  Radius
                                                                      .circular(
                                                                          20)),
                                                          color: MyColors
                                                              .primaryColorLight,
                                                        ),
                                                        child: Icon(
                                                          Icons
                                                              .arrow_forward_ios,
                                                          color: Colors.white,
                                                          size: 16,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                          )),
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
              ],
            );
          } else {
            return SingleChildScrollView(
              child: SafeArea(
                child: SingleChildScrollView(
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
                                          constraints: const BoxConstraints(
                                              maxHeight: 340),
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 8),
                                          child: Image.asset(
                                              'assets/loginoop.png')),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Text('CloudyML',
                                      style: TextStyle(
                                          color: MyColors.primaryColor,
                                          fontSize: 25,
                                          fontWeight: FontWeight.w800)))
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: <Widget>[
                              SingleChildScrollView(
                                child: Container(
                                    constraints:
                                        const BoxConstraints(maxWidth: 500),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(children: <TextSpan>[
                                        TextSpan(
                                            text:
                                                'We look forward to getting to know you better.',
                                            style: TextStyle(
                                                color: MyColors.primaryColor)),
                                        TextSpan(
                                            text: '',
                                            style: TextStyle(
                                                color: MyColors.primaryColor,
                                                fontWeight: FontWeight.bold)),
                                        TextSpan(
                                            text: " Let's begin with email",
                                            style: TextStyle(
                                                color: MyColors.primaryColor)),
                                      ]),
                                    )),
                              ),
                              SizedBox(
                                height: 40,
                              ),
                              widget.user == "signup"
                                  ? Column(
                                      children: <Widget>[
                                        Container(
                                          height: 60,
                                          constraints: const BoxConstraints(
                                              maxWidth: 500),
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 10),
                                          child: CupertinoTextField(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16),
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(4))),
                                            controller: nameController,
                                            clearButtonMode:
                                                OverlayVisibilityMode.editing,
                                            keyboardType: TextInputType.name,
                                            maxLines: 1,
                                            placeholder: 'Name',
                                          ),
                                        ),
                                      ],
                                    )
                                  : Container(),
                              Container(
                                height: 40,
                                constraints:
                                    const BoxConstraints(maxWidth: 500),
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                child: CupertinoTextField(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(4))),
                                  controller: emailController,
                                  clearButtonMode:
                                      OverlayVisibilityMode.editing,
                                  keyboardType: TextInputType.emailAddress,
                                  maxLines: 1,
                                  placeholder: 'Email',
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              widget.user == "signin"
                                  ? Expanded(
                                      flex: 0,
                                      child: Column(
                                        children: <Widget>[
                                          Container(
                                            height: 40,
                                            constraints: const BoxConstraints(
                                                maxWidth: 500),
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 10),
                                            child: CupertinoTextField(
                                              suffix: IconButton(
                                                icon: Icon(
                                                  // Based on passwordVisible state choose the icon
                                                  _passwordVisible
                                                      ? Icons.visibility
                                                      : Icons.visibility_off,
                                                  color: Color.fromRGBO(
                                                      120, 96, 220, 1),
                                                ),
                                                onPressed: () {
                                                  // Update the state i.e. toogle the state of passwordVisible variable
                                                  setState(() {
                                                    _passwordVisible =
                                                        !_passwordVisible;
                                                  });
                                                },
                                              ),
                                              obscureText: !_passwordVisible,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16),
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(4))),
                                              clearButtonMode:
                                                  OverlayVisibilityMode.editing,
                                              keyboardType: TextInputType.text,
                                              controller: passwordController,
                                              maxLines: 1,
                                              placeholder: 'Password',
                                            ),
                                          ),
                                          SizedBox(
                                            height: 4,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                8.0, 2, 18, 8),
                                            child: InkWell(
                                              onTap: () {
                                                if (emailController
                                                    .text.isNotEmpty) {
                                                  _auth.sendPasswordResetEmail(
                                                      email: emailController
                                                          .text
                                                          .toLowerCase()
                                                          .toString());
                                                  showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        Future.delayed(
                                                            Duration(
                                                                seconds: 13),
                                                            () {
                                                          Navigator.of(context)
                                                              .pop(true);
                                                        });
                                                        return AlertDialog(
                                                          title: Center(
                                                            child: Column(
                                                              children: [
                                                                Lottie.asset(
                                                                    'assets/email.json',
                                                                    height:
                                                                        height *
                                                                            0.15,
                                                                    width:
                                                                        width *
                                                                            0.5),
                                                                Text(
                                                                  'Reset Password',
                                                                  textScaleFactor: min(
                                                                      horizontalScale,
                                                                      verticalScale),
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .red,
                                                                      fontSize:
                                                                          22,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          content: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Text(
                                                                'An email has been sent to ',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style:
                                                                    TextStyle(),
                                                              ),
                                                              Text(
                                                                '${emailController.text.toLowerCase().toString()}',
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                              Text(
                                                                'Click the link in the email to change password.',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                              ),
                                                              SizedBox(
                                                                height:
                                                                    verticalScale *
                                                                        10,
                                                              ),
                                                              Text(
                                                                'Didn\'t get the email?',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                              Text(
                                                                'Check entered email or check spam folder.',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style:
                                                                    TextStyle(),
                                                              ),
                                                              TextButton(
                                                                  child: Text(
                                                                    'Retry',
                                                                    textScaleFactor: min(
                                                                        horizontalScale,
                                                                        verticalScale),
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          20,
                                                                    ),
                                                                  ),
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.pop(
                                                                        context,
                                                                        true);
                                                                  }),
                                                            ],
                                                          ),
                                                        );
                                                      });
                                                } else {
                                                  showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                            title: Center(
                                                              child: Text(
                                                                'Error',
                                                                textScaleFactor: min(
                                                                    horizontalScale,
                                                                    verticalScale),
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .red,
                                                                    fontSize:
                                                                        24,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ),
                                                            content: Text(
                                                              'Enter email in the email field or check if the email is valid.',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              textScaleFactor: min(
                                                                  horizontalScale,
                                                                  verticalScale),
                                                              style: TextStyle(
                                                                  fontSize: 16),
                                                            ),
                                                            actions: [
                                                              TextButton(
                                                                  child: Text(
                                                                      'Retry'),
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.pop(
                                                                        context,
                                                                        true);
                                                                  })
                                                            ]);
                                                      });
                                                }
                                              },
                                              child: Align(
                                                alignment:
                                                    Alignment.bottomRight,
                                                child: Text(
                                                  'Forgot Password?',
                                                  textScaleFactor: min(
                                                      horizontalScale,
                                                      verticalScale),
                                                  textAlign: TextAlign.end,
                                                  style: TextStyle(
                                                      color: HexColor('8346E1'),
                                                      fontSize: 16),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Container(),
                              SizedBox(
                                height: 10,
                              ),
                              GestureDetector(
                                  onTap: () async {
                                    if (widget.user == "signup") {
                                      print('uuyguyguguy');
                                      if (nameController.text.isNotEmpty) {
                                        if (RegExp(
                                                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                            .hasMatch(emailController.text
                                                .toLowerCase()
                                                .toString())) {
                                          if (email != "" || email != null) {
                                            try {
                                              setState(() {
                                                loading = true;
                                              });
                                              globals.email = emailController
                                                  .text
                                                  .toLowerCase()
                                                  .toString();
                                              FirebaseAuth _auth =
                                                  FirebaseAuth.instance;
                                              userprofile(
                                                  listOfCourses: [],
                                                  linked: "true",
                                                  name: nameController.text
                                                      .toString(),
                                                  image: '',
                                                  mobilenumber: globals.phone,
                                                  authType: 'phoneAuth',
                                                  phoneVerified: true,
                                                  email: globals.email);
                                              try {
                                                Future.delayed(
                                                    const Duration(seconds: 2),
                                                    () {
                                                  if (diurl ==
                                                      '/InternationalPaymentScreen') {
                                                    final cID =
                                                        "aEGX6kMfHzQrVgP3WCwU";
                                                    GoRouter.of(context).go(
                                                      '/InternationalPaymentScreen?cID=mPqg2Z2BdNHvwaqAEfA0',
                                                      // queryParams: {
                                                      //   'cID': cID,
                                                      //   }
                                                    );
                                                  } else if (payurl ==
                                                      'aEGX6kMfHzQrVgP3WCwU') {
                                                    final cID =
                                                        "aEGX6kMfHzQrVgP3WCwU";
                                                    GoRouter.of(context).go(
                                                      '/paymentPortal?cID=aEGX6kMfHzQrVgP3WCwU',
                                                      // queryParams: {
                                                      //   'cID': cID,
                                                      //   }
                                                    );
                                                  } else if (promEng ==
                                                      'RIUjOvGBV6YSzMTpMWEG') {
                                                    final cID =
                                                        "RIUjOvGBV6YSzMTpMWEG";
                                                    GoRouter.of(context).go(
                                                      '/paymentPortal?cID=RIUjOvGBV6YSzMTpMWEG',
                                                      // queryParams: {
                                                      //   'cID': cID,
                                                      //   }
                                                    );
                                                  }else if (depayurl ==
                                                      'F9gxnjW9nf5Lxg5A6758') {
                                                    final cID =
                                                        "F9gxnjW9nf5Lxg5A6758";
                                                    GoRouter.of(context).go(
                                                      '/comboPaymentPortal?cID=F9gxnjW9nf5Lxg5A6758',
                                                      // queryParams: {
                                                      //   'cID': cID,
                                                      //   }
                                                    );
                                                  } else if (suppayurl ==
                                                      'XSNqt0oNpuY7i2kb7zsW') {
                                                    final cID =
                                                        "XSNqt0oNpuY7i2kb7zsW";
                                                    GoRouter.of(context).go(
                                                      '/comboPaymentPortal?cID=XSNqt0oNpuY7i2kb7zsW',
                                                      // queryParams: {
                                                      //   'cID': cID,
                                                      //   }
                                                    );
                                                  } else {
                                                    Navigator.of(context).push(
                                                        MaterialPageRoute(
                                                            builder: (_) =>
                                                                LandingScreen()));
                                                  }
                                                  // Navigator.of(context)
                                                  //     .pushReplacement(
                                                  //   MaterialPageRoute(
                                                  //     builder: (_) =>
                                                  //         HomePage(),
                                                  //   ),
                                                  // );
                                                  saveLoginState(context);
                                                  setState(() {
                                                    loading = false;
                                                  });
                                                });
                                              } catch (e) {
                                                Toast.show(e.toString());
                                                Navigator.of(context)
                                                    .pushReplacement(
                                                  MaterialPageRoute(
                                                    builder: (_) => OtpPage(
                                                        "fromemailpage"),
                                                  ),
                                                );
                                              }
                                            } catch (e) {
                                              setState(() {
                                                loading = false;
                                              });
                                              print(e.toString());
                                              Toast.show(e.toString());
                                            }

                                            // try {
                                            // var value = await FirebaseAuth
                                            //     .instance
                                            //     .currentUser!
                                            //     .uid;
                                            // print(
                                            //     "sdjsodjew${globals.moneyrefcode}");
                                            // if (globals.moneyrefcode !=
                                            //     '') {
                                            //   print("ijsofjdserer");
                                            //   courseId = globals
                                            //       .moneyrefcode
                                            //       .split('-')[1];
                                            //   try {
                                            //     print(
                                            //         "sdjsdfgdohroeodjew");
                                            //     await FirebaseFirestore
                                            //         .instance
                                            //         .collection("Users_dataly")
                                            //         .doc(FirebaseAuth
                                            //             .instance
                                            //             .currentUser!
                                            //             .uid)
                                            //         .get()
                                            //         .then((value) async {
                                            //       try {
                                            //         print(
                                            //             "sdjsodjesfwenjoerigoeg");
                                            //         print(
                                            //             "sdsdfsoijojwjjgsdsdsdrgjei ${value.data()!['sendermoneyrefuid']}");
                                            // if (true) {
                                            // await FirebaseFirestore
                                            //     .instance
                                            //     .collection(
                                            //         "Users")
                                            //     .doc(FirebaseAuth
                                            //         .instance
                                            //         .currentUser!
                                            //         .uid)
                                            //     .update({
                                            //   "sendermoneyrefuid":
                                            //       globals
                                            //           .moneyrefcode
                                            //           .split(
                                            //               '-')[2],
                                            //   "senderrefvalidfrom":
                                            //       DateTime.now()
                                            // });
                                            // }
                                            //       } catch (e) {
                                            //         print(
                                            //             "tyuiiiiii${e.toString()}");
                                            //       }
                                            //     });
                                            //   } catch (e) {
                                            //     print(
                                            //         "poooiiieirj${e.toString()}");
                                            //   }
                                            // } else {
                                            //   Navigator.of(context)
                                            //       .pushReplacement(
                                            //     MaterialPageRoute(
                                            //       builder: (_) =>
                                            //           HomePage(),
                                            //     ),
                                            //   );
                                            // }
                                            //   setState(() {
                                            //     loading = false;
                                            //   });
                                            // } catch (e) {
                                            //   showToast(
                                            //       "error jkl ${e.toString()}");
                                            //   print("jkl");
                                            //   print(e.toString());
                                            //   Navigator.of(context)
                                            //       .pushReplacement(
                                            //     MaterialPageRoute(
                                            //       builder: (_) =>
                                            //           HomePage(),
                                            //     ),
                                            //   );
                                            // }
                                          } else {
                                            setState(() {
                                              loading = false;
                                            });
                                            Toast.show('Please enter a email');
                                          }
                                        } else {
                                          setState(() {
                                            loading = false;
                                          });
                                          Toast.show(
                                              'Please enter a valid email');
                                        }
                                      } else {
                                        Toast.show("please enter your name");
                                      }
                                    } else if (widget.user == "signin") {
                                      bool otpverified = true;
                                      print('dfgdrgergreger');
                                      if (passwordController.text.isNotEmpty) {
                                        setState(() {
                                          loading = true;
                                        });
                                        User? user;
                                        FirebaseAuth _auth =
                                            FirebaseAuth.instance;
                                        try {
                                          user = (await _auth
                                                  .signInWithEmailAndPassword(
                                                      email: emailController
                                                          .text
                                                          .toLowerCase()
                                                          .toString(),
                                                      password:
                                                          passwordController
                                                              .text
                                                              .toString()))
                                              .user;

                                          //otp verification and linking
                                          try {
                                            await _auth.currentUser!
                                                .linkWithCredential(
                                                    globals.credental);
                                            await FirebaseFirestore.instance
                                                .collection("Users_dataly")
                                                .doc(_auth.currentUser!.uid)
                                                .update({
                                              "linked": "true",
                                            });
                                          } catch (e) {
                                            Toast.show(e.toString());
                                            otpverified = false;
                                            Navigator.of(context)
                                                .pushReplacement(
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    OtpPage("fromemailpage"),
                                              ),
                                            );
                                          }

                                          var value = await FirebaseAuth
                                              .instance.currentUser!.uid;

                                          setState(() {
                                            loading = false;
                                          });
                                        } on FirebaseException catch (e) {
                                          print("iooijjj${e.code}");
                                          setState(() {
                                            loading = false;
                                          });
                                          // showToast(e.toString());
                                          if (e.code.toString() ==
                                              "wrong-password") {
                                            setState(() {
                                              loading = false;
                                            });
                                            Toast.show("wrong password");
                                          }
                                          Toast.show(e.toString());
                                          setState(() {
                                            loading = false;
                                          });
                                        }

                                        // showToast("here");
                                        if (user != null) {
                                          // if (globals.moneyrefcode !=
                                          //     '') {
                                          //   courseId = globals
                                          //       .moneyrefcode
                                          //       .split('-')[1];
                                          //   try {
                                          //     await FirebaseFirestore
                                          //         .instance
                                          //         .collection("Users_dataly")
                                          //         .doc(FirebaseAuth
                                          //             .instance
                                          //             .currentUser!
                                          //             .uid)
                                          //         .get()
                                          //         .then((value) async {
                                          //       try {
                                          //         print(
                                          //             "sdsdfsoijojwjjgsdsdsdrgjei ${value.data()!['sendermoneyrefuid']}");
                                          //         if (true) {
                                          //           await FirebaseFirestore
                                          //               .instance
                                          //               .collection(
                                          //                   "Users")
                                          //               .doc(FirebaseAuth
                                          //                   .instance
                                          //                   .currentUser!
                                          //                   .uid)
                                          //               .update({
                                          //             "sendermoneyrefuid":
                                          //                 globals
                                          //                     .moneyrefcode
                                          //                     .split(
                                          //                         '-')[2],
                                          //             "senderrefvalidfrom":
                                          //                 DateTime.now()
                                          //           });
                                          //         }
                                          //       } catch (e) {
                                          //         print(
                                          //             "tyuiiiiii${e.toString()}");
                                          //       }
                                          //     });
                                          //   } catch (e) {
                                          //     print(
                                          //         "poooiiieirj${e.toString()}");
                                          //   }
                                          // } else {
                                          //adding condition for handling otp verification error
                                          if (otpverified) {
                                            // Navigator.of(context)
                                            //     .pushReplacement(
                                            //   MaterialPageRoute(
                                            //     builder: (_) => HomePage(),
                                            //   ),
                                            // );
                                            if (diurl ==
                                                '/InternationalPaymentScreen') {
                                              final cID =
                                                  "aEGX6kMfHzQrVgP3WCwU";
                                              GoRouter.of(context).go(
                                                '/InternationalPaymentScreen?cID=mPqg2Z2BdNHvwaqAEfA0',
                                                // queryParams: {
                                                //   'cID': cID,
                                                //   }
                                              );
                                            } else if (payurl ==
                                                'aEGX6kMfHzQrVgP3WCwU') {
                                              final cID =
                                                  "aEGX6kMfHzQrVgP3WCwU";
                                              GoRouter.of(context).go(
                                                '/paymentPortal?cID=aEGX6kMfHzQrVgP3WCwU',
                                                // queryParams: {
                                                //   'cID': cID,
                                                //   }
                                              );
                                            } else if (promEng ==
                                                'RIUjOvGBV6YSzMTpMWEG') {
                                              final cID =
                                                  "RIUjOvGBV6YSzMTpMWEG";
                                              GoRouter.of(context).go(
                                                '/paymentPortal?cID=RIUjOvGBV6YSzMTpMWEG',
                                                // queryParams: {
                                                //   'cID': cID,
                                                //   }
                                              );
                                            }else if (depayurl ==
                                                'F9gxnjW9nf5Lxg5A6758') {
                                              final cID =
                                                  "F9gxnjW9nf5Lxg5A6758";
                                              GoRouter.of(context).go(
                                                '/comboPaymentPortal?cID=F9gxnjW9nf5Lxg5A6758',
                                                // queryParams: {
                                                //   'cID': cID,
                                                //   }
                                              );
                                            } else if (suppayurl ==
                                                'XSNqt0oNpuY7i2kb7zsW') {
                                              final cID =
                                                  "XSNqt0oNpuY7i2kb7zsW";
                                              GoRouter.of(context).go(
                                                '/comboPaymentPortal?cID=XSNqt0oNpuY7i2kb7zsW',
                                                // queryParams: {
                                                //   'cID': cID,
                                                //   }
                                              );
                                            } else {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (_) =>
                                                          LandingScreen()));
                                            }
                                            // GoRouter.of(context).pushReplacementNamed('home');
                                            saveLoginState(context);
                                            // }
                                          }
                                        } else {
                                          Toast.show("wrong password");
                                        }
                                      } else {
                                        Toast.show("enter your password");
                                      }
                                    } else {
                                      // await email(
                                      //     context,
                                      //     emailController.text
                                      //         .toLowerCase()
                                      //         .toString());
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
                                                    child:
                                                        CircularProgressIndicator(
                                                            color:
                                                                Colors.white))),
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        12, 0, 0, 0),
                                                child: Text(
                                                  'Next',
                                                  style: TextStyle(
                                                      color: Color.fromARGB(
                                                          255, 255, 255, 255),
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(20)),
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
                                  )),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        }));
  }

  void saveLoginState(BuildContext context) {
    Provider.of<LoginState>(context, listen: false).loggedIn = true;
  }
}
