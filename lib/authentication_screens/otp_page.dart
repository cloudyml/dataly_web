import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudyml_app2/combo/combo_course.dart';
import 'package:cloudyml_app2/combo/combo_store.dart';
import 'package:cloudyml_app2/combo/feature_courses.dart';
import 'package:cloudyml_app2/globals.dart';
import 'package:cloudyml_app2/home.dart';
import 'package:cloudyml_app2/homescreen/homescreen.dart';
import 'package:cloudyml_app2/payment_screen.dart';
import 'package:cloudyml_app2/screens/review_screen/review_screen.dart';
import 'package:flutter/services.dart';
import 'package:g_recaptcha_v3/g_recaptcha_v3.dart';
import 'package:go_router/go_router.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:numeric_keyboard/numeric_keyboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:pinput/pinput.dart';
import 'package:cloudyml_app2/theme.dart';
import 'package:cloudyml_app2/global_variable.dart' as globals;
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:toast/toast.dart';
import '../models/course_details.dart';
import '../router/login_state_check.dart';
import 'google_auth.dart';
import 'login_email.dart';

class OtpPage extends StatefulWidget {
  String fromemailpage;
  OtpPage(this.fromemailpage, {Key? key}) : super(key: key);
  @override
  _OtpPageState createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  String text = '';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool? googleloading = false;
  bool formVisible = false;
  bool value = false;
  bool phoneVisible = false;
  int _formIndex = 1;
  TextEditingController textController = TextEditingController();
  final _pinPutController = TextEditingController();
  bool _isHidden = true;
  bool _isLoading = false;
  final _loginkey = GlobalKey<FormState>();
  final FirebaseAuth auth = FirebaseAuth.instance;

  bool loading = false;
  late String actualCode;

  late String diurl;
  late String payurl;
  late String depayurl;
  late String suppayurl;
  late String feaurl;
  late String deurl;
  late String supurl;
  late String promEng;

  late String interntnl;
  FocusNode _buttonFocusNode = FocusNode();
  void _onKeyboardTap(String value) {
    setState(() {
      text = text + value;
    });
  }

  List<CourseDetails> featuredCourse = [];

  setFeaturedCourse(List<CourseDetails> course) {
    featuredCourse.clear();
    course.forEach((element) {
      if (element.FcSerialNumber.isNotEmpty &&
          element.FcSerialNumber != null &&
          element.isItComboCourse == true) {
        featuredCourse.add(element);
      }
    });
    featuredCourse.sort((a, b) {
      return int.parse(a.FcSerialNumber).compareTo(int.parse(b.FcSerialNumber));
    });
  }

  final defaultPinTheme = PinTheme(
    width: 56,
    height: 56,
    decoration: BoxDecoration(
      color: Color.fromARGB(255, 226, 226, 226),
    ),
  );

  Widget darkRoundedPinPut(BuildContext context) {
    return Container(
      child: Pinput(
        onChanged: (value) => text = value,
        defaultPinTheme: defaultPinTheme.copyDecorationWith(
          borderRadius: BorderRadius.circular(8),
        ),
        onCompleted: (text) async {
          await validateOtpAndLogin(context, text);
        },
        focusNode: _buttonFocusNode,
        autofocus: true,
        onSubmitted: (text) async {
          await validateOtpAndLogin(context, text);
        },
        length: 6,
      ),
    );
  }

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
        .doc("cDQnMz6hENvxZVfLyUoq_dataly1")
        .get()
        .then((value) {
      print(value.data()!.values.first);
      return value.data()!.values.first;
    });

    print("url is=====$payurl");

    

    feaurl = await FirebaseFirestore.instance
        .collection("Notice")
        .doc("gMAzwcnKV1o7zVwUdLV0_datalyfeature1")
        .get()
        .then((value) {
      print(value.data()!.values.first);
      return value.data()!.values.first;
    });

    print("url is=====$feaurl");

    
  }

  Widget _otpTextField(BuildContext context, bool autoFocus, int position) {
    return Container(
      height: MediaQuery.of(context).size.shortestSide * 0.04,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
        shape: BoxShape.rectangle,
      ),
      child: AspectRatio(
        aspectRatio: 1,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
            child: TextField(
              // controller: textController,
              autofocus: autoFocus,
              decoration: InputDecoration(
                border: InputBorder.none,
              ),
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              style: TextStyle(),
              maxLines: 1,
              onChanged: (value) {
                print(value);
                print(position);
                if (value.length == 1) {
                  text += value;
                  FocusScope.of(context).nextFocus();
                }
                print(text);
                if (value.length == 0) {
                  FocusScope.of(context).nearestScope;
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget otpNumberWidget(int position) {
    try {
      return Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 0),
            borderRadius: const BorderRadius.all(Radius.circular(8))),
        child: Center(
            child: Text(
          text[position],
          style: TextStyle(color: Colors.black),
        )),
      );
    } catch (e) {
      return Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 0),
            borderRadius: const BorderRadius.all(Radius.circular(8))),
      );
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    url();
    GRecaptchaV3.hideBadge();
    // url();
  }

  @override
  void dispose() {
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: widget.fromemailpage == 'fromemailpage'
            ? Container()
            : IconButton(
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
                                    child: Image.asset(
                                      'assets/otpll.png',
                                      cacheWidth: 364,
                                      cacheHeight: 364,
                                    ),
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        Container(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 20),
                                            child: Text(
                                                'Enter 6 digits verification code sent to your number',
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.w500))),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              18, 80, 18, 0),
                                          child: Container(
                                            constraints: const BoxConstraints(
                                                maxWidth: 400),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                                Expanded(
                                                    child: darkRoundedPinPut(
                                                        context)),
                                                // _otpTextField(context, true, 0),
                                                // _otpTextField(
                                                //     context, false, 1),
                                                // _otpTextField(
                                                //     context, false, 2),
                                                // _otpTextField(
                                                //     context, false, 3),
                                                // _otpTextField(
                                                //     context, false, 4),
                                                // _otpTextField(
                                                //     context, false, 5),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 0, 0, 58),
                                    child: InkWell(
                                      onTap: () async {
                                        await validateOtpAndLogin(
                                            context, text);
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
                                                      'Confirm',
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
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return SafeArea(
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    child: Text(
                                        'Enter 6 digits verification code sent to your number',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 26,
                                            fontWeight: FontWeight.w500))),
                                Container(
                                  constraints:
                                      const BoxConstraints(maxWidth: 500),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      otpNumberWidget(0),
                                      otpNumberWidget(1),
                                      otpNumberWidget(2),
                                      otpNumberWidget(3),
                                      otpNumberWidget(4),
                                      otpNumberWidget(5),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              await validateOtpAndLogin(context, text);
                              // context.goNamed(MyRoutes.homeRoute);
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
                                            'Confirm',
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
                          NumericKeyboard(
                            onKeyboardTap: _onKeyboardTap,
                            textColor: MyColors.primaryColorLight,
                            rightIcon: Icon(
                              Icons.backspace,
                              color: MyColors.primaryColorLight,
                            ),
                            rightButtonFn: () {
                              setState(() {
                                text = text.substring(0, text.length - 1);
                              });
                            },
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> validateOtpAndLogin(BuildContext context, String smsCode) async {
    var result;
    var output;
    actualCode = globals.actualCode;
    try {
      setState(() {
        loading = true;
      });
      final AuthCredential _authCredential = PhoneAuthProvider.credential(
          verificationId: actualCode, smsCode: smsCode);
      globals.credental = _authCredential;
      onAuthenticationSuccessful(context, output, _authCredential);
    } on FirebaseException catch (e) {
      print(e.toString());
      Toast.show(e.toString());
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> onAuthenticationSuccessful(
      BuildContext context, dynamic result, dynamic crediantial) async {
    try {
      print("ttt1:${globals.googleAuth}");
      print("ttt2:${globals.phoneNumberexists}");
      print("ttt3:${globals.linked}");
      if (globals.googleAuth != 'true') {
        if (globals.phoneNumberexists == "true") {
          if (globals.linked == "true") {
            print("here 1");
            try {
              User? user = (await _auth.signInWithCredential(crediantial)).user;
              if (user != null) {
                print("Login Successful======");

                Toast.show("Login Successful");
                print(user);
                print("Login Successful==");
                print(GoRouter.of(context).location);
                // GoRouter.of(context).pushReplacement('/home');
                String location = GoRouter.of(context).location;

                if (feaurl == 'mIXvDqDBLfmjtvUnHxfn') {
                  final id = "0";
                  final cID = "mIXvDqDBLfmjtvUnHxfn";
                  final courseName =
                      "Data Superstar Placement Guarantee Program";
                  final courseP = "999";
                  GoRouter.of(context).goNamed('NewFeature', queryParams: {
                    'cID': cID,
                    'courseName': courseName,
                    'id': id,
                    'coursePrice': courseP
                  });
                }  else if (payurl == 'mIXvDqDBLfmjtvUnHxfn') {
                  final cID = "mIXvDqDBLfmjtvUnHxfn";
                  GoRouter.of(context).go(
                    '/comboPaymentPortal?cID=mIXvDqDBLfmjtvUnHxfn',
                    // queryParams: {
                    //   'cID': cID,
                    //   }
                  );
                } else {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => LandingScreen()));
                  GoRouter.of(context).pushNamed('home');
                }

                //
                // Navigator.of(context)
                //     .push(MaterialPageRoute(builder: (_) => HomePage()));
                //

                // (Route<dynamic> route) => false;
                saveLoginState(context);
              } else {
                Toast.show("Login Failed");
                print("Login Failed");
              }
            } catch (e) {
              Toast.show("wrong otp: ${e.toString()}");
            }
          } else if (globals.googleAuth == 'true') {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => GoogleAuthLogin(),
              ),
            );
          } else {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => LoginEmailPage(user: "signin")));
          }
        } else {
          print("here 2");
          try {
            FirebaseAuth auth = FirebaseAuth.instance;
            await auth.signInWithCredential(globals.credental);
            Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => LoginEmailPage(user: "signup")));
          } catch (e) {
            Toast.show(e.toString());
          }
        }
      } else {
        if (globals.linked == 'true') {
          GoRouter.of(context).pushReplacement('/home');

          (Route<dynamic> route) => false;
          saveLoginState(context);
        } else {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => GoogleAuthLogin()));
        }
      }
      setState(() {
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
      print(e.toString());
      Toast.show(e.toString());
    }
  }

  void saveLoginState(BuildContext context) async {
    Provider.of<LoginState>(context, listen: false).loggedIn = true;
    try {
      DateTime now = DateTime.now();

      var sessionExpiryDays = await FirebaseFirestore.instance
          .collection('Notice')
          .doc('sessionExpiryDays')
          .get();
      print('sessionExpiryDays ${sessionExpiryDays['sessionExpiryDays']}');

      DateTime updatedTime =
          now.add(Duration(days: sessionExpiryDays['sessionExpiryDays']));

      await FirebaseFirestore.instance
          .collection("Users_dataly")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        'sessionExpiryTime': Timestamp.fromDate(updatedTime),
      });
    } catch (e) {
      print('session expiry error');
    }
  }
}
