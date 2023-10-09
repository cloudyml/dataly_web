import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudyml_app2/globals.dart';
import 'package:cloudyml_app2/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

import '../router/login_state_check.dart';

class SigninPasswordPage extends StatefulWidget {
  String email;
  SigninPasswordPage({Key? key, required this.email}) : super(key: key);
  @override
  _SigninPasswordPageState createState() => _SigninPasswordPageState();
}

class _SigninPasswordPageState extends State<SigninPasswordPage> {
  TextEditingController passwordController = TextEditingController();
  bool loading = false;
  late bool _passwordVisible;
  final FirebaseAuth _auth = FirebaseAuth.instance;


  void saveLoginState(BuildContext context) {
    Provider.of<LoginState>(context, listen: false).loggedIn = true;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _passwordVisible = false;
  }

  @override
  Widget build(BuildContext context) {
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
        backgroundColor: HexColor("7226D1"), systemOverlayStyle: SystemUiOverlayStyle.light,
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
                                    child: Image.asset('assets/lojo.png'),
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
                      Container(

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
                child: Center(
                  child: Column(
                    children: <Widget>[
                      
                      Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20,200,20,20),
                            child: TextFormField(
                              keyboardType: TextInputType.text,
                              controller: passwordController,
                              obscureText:
                                  !_passwordVisible, //This will obscure text dynamically
                              decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14.0),
                                  borderSide: BorderSide(
                                    color: Color.fromRGBO(120, 96, 220, 1),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    width: 1,
                                    color: Color.fromRGBO(120, 96, 220, 1),
                                  ), //<-- SEE HERE
                                ),
                                iconColor: Color.fromRGBO(120, 96, 220, 1),
                                hoverColor: Color.fromRGBO(120, 96, 220, 1),
                                focusColor: Color.fromRGBO(120, 96, 220, 1),
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(14))),
                                labelText: 'Password',
                                hintText: 'Enter your password',
                                labelStyle: TextStyle(
                                    color: Color.fromRGBO(120, 96, 220, 1)),
                                // Here is key idea
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    // Based on passwordVisible state choose the icon
                                    _passwordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Color.fromRGBO(120, 96, 220, 1),
                                  ),
                                  onPressed: () {
                                    // Update the state i.e. toogle the state of passwordVisible variable
                                    setState(() {
                                      _passwordVisible = !_passwordVisible;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                          Padding(
                                        padding: const EdgeInsets.fromLTRB(8.0,8,18,8),
                                        child: InkWell(
                                  onTap: () {
                                    if (widget.email.isNotEmpty) {
                                        _auth.sendPasswordResetEmail(
                                            email: widget.email);
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              Future.delayed(
                                                  Duration(seconds: 13), () {
                                                Navigator.of(context).pop(true);
                                              });
                                              return AlertDialog(
                                                title: Center(
                                                  child: Column(
                                                    children: [
                                                      Lottie.asset(
                                                          'assets/email.json',
                                                          height: height * 0.15,
                                                          width: width * 0.5),
                                                      Text(
                                                        'Reset Password',
                                                        textScaleFactor: min(
                                                            horizontalScale,
                                                            verticalScale),
                                                        style: TextStyle(
                                                            color: Colors.red,
                                                            fontSize: 22,
                                                            fontWeight:
                                                                FontWeight.bold),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                content: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      'An email has been sent to ',
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(),
                                                    ),
                                                    Text(
                                                      '${widget.email}',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Text(
                                                      'Click the link in the email to change password.',
                                                      textAlign: TextAlign.center,
                                                    ),
                                                    SizedBox(
                                                      height: verticalScale * 10,
                                                    ),
                                                    Text(
                                                      'Didn\'t get the email?',
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Text(
                                                      'Check entered email or check spam folder.',
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(),
                                                    ),
                                                    TextButton(
                                                        child: Text(
                                                          'Retry',
                                                          textScaleFactor: min(
                                                              horizontalScale,
                                                              verticalScale),
                                                          style: TextStyle(
                                                            fontSize: 20,
                                                          ),
                                                        ),
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context, true);
                                                        }),
                                                  ],
                                                ),
                                              );
                                            });
                                    } else {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                  title: Center(
                                                    child: Text(
                                                      'Error',
                                                      textScaleFactor: min(
                                                          horizontalScale,
                                                          verticalScale),
                                                      style: TextStyle(
                                                          color: Colors.red,
                                                          fontSize: 24,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                  content: Text(
                                                    'Enter email in the email field or check if the email is valid.',
                                                    textAlign: TextAlign.center,
                                                    textScaleFactor: min(
                                                        horizontalScale,
                                                        verticalScale),
                                                    style:
                                                        TextStyle(fontSize: 16),
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                        child: Text('Retry'),
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context, true);
                                                        })
                                                  ]);
                                            });
                                    }
                                  },
                                  child: Align(
                                    alignment: Alignment.bottomRight,
                                    child: Text(
                                        'Forgot Password?',
                                        textScaleFactor:
                                            min(horizontalScale, verticalScale),
                                        textAlign: TextAlign.end,
                                        style: TextStyle(
                                            color: HexColor('8346E1'),
                                            fontSize: 16),
                                    ),
                                  ),
                                ),
                                      ),
                          GestureDetector(
                            onTap: () async {
                              if (passwordController.text.isNotEmpty) {
                                setState(() {
                                  loading = true;
                                });
                                User? user;
                                FirebaseAuth _auth = FirebaseAuth.instance;
                                try {
                                  user =
                                      (await _auth.signInWithEmailAndPassword(
                                              email: widget.email,
                                              password: passwordController.text
                                                  .toString()))
                                          .user;
                                  await _auth.currentUser!
                                      .linkWithCredential(globals.credental);
                                  var value = await FirebaseAuth
                                      .instance.currentUser!.uid;

                                  await FirebaseFirestore.instance
                                      .collection("Users_dataly")
                                      .doc(_auth.currentUser!.uid)
                                      .update({
                                    "linked": "true",
                                  });
                                  setState(() {
                                    loading = false;
                                  });
                                } on FirebaseException catch (e) {
                                  print(e.code);
                                  setState(() {
                                    loading = false;
                                  });
                                  Toast.show(e.toString());
                                  if (e.code.toString() == "wrong-password") {
                                    setState(() {
                                      loading = false;
                                    });
                                    Toast.show("wrong password");
                                  }
                                  setState(() {
                                    loading = false;
                                  });
                                }

                                // showToast("here");
                                if (user != null) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => HomePage(),
                                    ),
                                  );
                                } else {
                                  Toast.show("wrong password");
                                }
                              } else {
                                Toast.show("enter your password");
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
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(20)),
                                            color: MyColors.primaryColorLight,
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
                        ],
                      )
                    ],
                  ),
                ),
              ),
                    ],
                  ),
                ),
              ],
            );
        }else{
          return SafeArea(
            child: SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.90,
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
                                // Center(
                                //   child: Container(
                                //     height: 140,
                                //     constraints:
                                //         const BoxConstraints(maxWidth: 500),
                                //     margin: const EdgeInsets.only(top: 100),
                                //     decoration: const BoxDecoration(
                                //         color: Color(0xFFE1E0F5),
                                //         borderRadius: BorderRadius.all(
                                //             Radius.circular(30))),
                                //   ),
                                // ),
                                Center(
                                  child: Container(
                                      constraints:
                                          const BoxConstraints(maxHeight: 240),
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      child: Lottie.asset(
                                          'assets/onboarding_password.json')),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 40,
                          ),
                          //  Container(
                          //       constraints:
                          //           const BoxConstraints(maxWidth: 500),
                          //       margin: const EdgeInsets.symmetric(
                          //           horizontal: 10),
                          //       child: RichText(
                          //         textAlign: TextAlign.center,
                          //         text: TextSpan(children: <TextSpan>[
                          //           TextSpan(
                          //               text: 'Choosing a hard-to-guess,',
                          //               style: TextStyle(
                          //                   color: MyColors.primaryColor)),
                          //           TextSpan(
                          //               text: ' but easy-to-remember\n',
                          //               style: TextStyle(
                          //                   color: MyColors.primaryColor,
                          //                   fontWeight: FontWeight.bold)),
                          //           TextSpan(
                          //               text: ' password is important!',
                          //               style: TextStyle(
                          //                   color: MyColors.primaryColor)),
                          //         ]),
                          //       )),
                          SizedBox(
                            height: 40,
                          ),

                          // Container(
                          //   height: 60,
                          //   constraints:
                          //       const BoxConstraints(maxWidth: 500),
                          //   margin: const EdgeInsets.symmetric(
                          //       horizontal: 20, vertical: 10),
                          //   child: CupertinoTextField(
                          //     maxLength: 10,
                          //     padding: const EdgeInsets.symmetric(
                          //         horizontal: 16),
                          //     decoration: BoxDecoration(
                          //         color: Color.fromARGB(255, 242, 240, 240),
                          //         borderRadius: const BorderRadius.all(
                          //             Radius.circular(4))),
                          //     controller: nameController,
                          //     clearButtonMode:
                          //         OverlayVisibilityMode.editing,
                          //     keyboardType: TextInputType.name,
                          //     maxLines: 1,
                          //     placeholder: 'Confirm Password',
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 0,
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: TextFormField(
                              keyboardType: TextInputType.text,
                              controller: passwordController,
                              obscureText:
                                  !_passwordVisible, //This will obscure text dynamically
                              decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14.0),
                                  borderSide: BorderSide(
                                    color: Color.fromRGBO(120, 96, 220, 1),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    width: 1,
                                    color: Color.fromRGBO(120, 96, 220, 1),
                                  ), //<-- SEE HERE
                                ),
                                iconColor: Color.fromRGBO(120, 96, 220, 1),
                                hoverColor: Color.fromRGBO(120, 96, 220, 1),
                                focusColor: Color.fromRGBO(120, 96, 220, 1),
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(14))),
                                labelText: 'Password',
                                hintText: 'Enter your password',
                                labelStyle: TextStyle(
                                    color: Color.fromRGBO(120, 96, 220, 1)),
                                // Here is key idea
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    // Based on passwordVisible state choose the icon
                                    _passwordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Color.fromRGBO(120, 96, 220, 1),
                                  ),
                                  onPressed: () {
                                    // Update the state i.e. toogle the state of passwordVisible variable
                                    setState(() {
                                      _passwordVisible = !_passwordVisible;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                          Padding(
                                        padding: const EdgeInsets.fromLTRB(8.0,8,18,8),
                                        child: InkWell(
                                  onTap: () {
                                    if (widget.email.isNotEmpty) {
                                        _auth.sendPasswordResetEmail(
                                            email: widget.email);
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              Future.delayed(
                                                  Duration(seconds: 13), () {
                                                Navigator.of(context).pop(true);
                                              });
                                              return AlertDialog(
                                                title: Center(
                                                  child: Column(
                                                    children: [
                                                      Lottie.asset(
                                                          'assets/email.json',
                                                          height: height * 0.15,
                                                          width: width * 0.5),
                                                      Text(
                                                        'Reset Password',
                                                        textScaleFactor: min(
                                                            horizontalScale,
                                                            verticalScale),
                                                        style: TextStyle(
                                                            color: Colors.red,
                                                            fontSize: 22,
                                                            fontWeight:
                                                                FontWeight.bold),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                content: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      'An email has been sent to ',
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(),
                                                    ),
                                                    Text(
                                                      '${widget.email}',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Text(
                                                      'Click the link in the email to change password.',
                                                      textAlign: TextAlign.center,
                                                    ),
                                                    SizedBox(
                                                      height: verticalScale * 10,
                                                    ),
                                                    Text(
                                                      'Didn\'t get the email?',
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Text(
                                                      'Check entered email or check spam folder.',
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(),
                                                    ),
                                                    TextButton(
                                                        child: Text(
                                                          'Retry',
                                                          textScaleFactor: min(
                                                              horizontalScale,
                                                              verticalScale),
                                                          style: TextStyle(
                                                            fontSize: 20,
                                                          ),
                                                        ),
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context, true);
                                                        }),
                                                  ],
                                                ),
                                              );
                                            });
                                    } else {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                  title: Center(
                                                    child: Text(
                                                      'Error',
                                                      textScaleFactor: min(
                                                          horizontalScale,
                                                          verticalScale),
                                                      style: TextStyle(
                                                          color: Colors.red,
                                                          fontSize: 24,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                  content: Text(
                                                    'Enter email in the email field or check if the email is valid.',
                                                    textAlign: TextAlign.center,
                                                    textScaleFactor: min(
                                                        horizontalScale,
                                                        verticalScale),
                                                    style:
                                                        TextStyle(fontSize: 16),
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                        child: Text('Retry'),
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context, true);
                                                        })
                                                  ]);
                                            });
                                    }
                                  },
                                  child: Align(
                                    alignment: Alignment.bottomRight,
                                    child: Text(
                                        'Forgot Password?',
                                        textScaleFactor:
                                            min(horizontalScale, verticalScale),
                                        textAlign: TextAlign.end,
                                        style: TextStyle(
                                            color: HexColor('8346E1'),
                                            fontSize: 16),
                                    ),
                                  ),
                                ),
                                      ),
                          SizedBox(
                            height: 10,
                          ),
                          GestureDetector(
                            onTap: () async {
                              if (passwordController.text.isNotEmpty) {
                                setState(() {
                                  loading = true;
                                });
                                User? user;
                                FirebaseAuth _auth = FirebaseAuth.instance;

                                try {
                                  user =
                                      (await _auth.signInWithEmailAndPassword(
                                              email: widget.email,
                                              password: passwordController.text
                                                  .toString()))
                                          .user;
                                  await _auth.currentUser!
                                      .linkWithCredential(globals.credental);
                                  var value = await FirebaseAuth
                                      .instance.currentUser!.uid;

                                  await FirebaseFirestore.instance
                                      .collection("Users_dataly")
                                      .doc(_auth.currentUser!.uid)
                                      .update({
                                    "linked": "true",
                                  });
                                  setState(() {
                                    loading = false;
                                  });
                                } on FirebaseException catch (e) {
                                  print(e.code);
                                  setState(() {
                                    loading = false;
                                  });
                                  Toast.show(e.toString());
                                  if (e.code.toString() == "wrong-password") {
                                    setState(() {
                                      loading = false;
                                    });
                                    Toast.show("wrong password");
                                  }
                                  setState(() {
                                    loading = false;
                                  });
                                }

                                // showToast("here");
                                if (user != null) {
                                  saveLoginState(context);
                                  GoRouter.of(context).pushReplacement('/home');

                                  // Navigator.pushReplacement(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //     builder: (context) => HomePage(),
                                  //   ),
                                  // );

                                } else {
                                  Toast.show("wrong password");
                                }
                              } else {
                                Toast.show("enter your password");
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
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(20)),
                                            color: MyColors.primaryColorLight,
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
            ),
          );
        }
      }),
    );
  }
}
