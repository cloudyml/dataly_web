// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:cloudyml_app2/home.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:hexcolor/hexcolor.dart';
// import 'package:lottie/lottie.dart';
// import 'package:provider/provider.dart';
// import 'package:cloudyml_app2/theme.dart';
// import 'package:cloudyml_app2/global_variable.dart' as globals;
// import 'package:toast/toast.dart';
// import '../../authentication/firebase_auth.dart';
// import '../router/login_state_check.dart';

// class LoginUsernamePage extends StatefulWidget {
//   const LoginUsernamePage({Key? key}) : super(key: key);
//   @override
//   _LoginUsernamePageState createState() => _LoginUsernamePageState();
// }

// class _LoginUsernamePageState extends State<LoginUsernamePage> {
//   TextEditingController nameController = TextEditingController();

//   bool loading = false;
//   bool signin = false;

//   @override
//   void initState() {
//     super.initState();
//     loginnewuser();
//   }

//   void loginnewuser() async {
//     try {
//       FirebaseAuth _auth = FirebaseAuth.instance;
//       await _auth.signInWithCredential(globals.credental);

//       signin = true;
//     } catch (e) {
//       Toast.show(e.toString());
//     }
//   }

//   void saveLoginState(BuildContext context) {
//     Provider.of<LoginState>(context, listen: false).loggedIn = true;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           leading: IconButton(
//             icon: Container(
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 borderRadius: const BorderRadius.all(Radius.circular(20)),
//                 color: Color.fromARGB(255, 140, 58, 240),
//               ),
//               child: Icon(
//                 Icons.arrow_back_ios,
//                 color: Color.fromRGBO(35, 0, 79, 1),
//                 size: 16,
//               ),
//             ),
//             onPressed: () => Navigator.of(context).pop(),
//           ),
//           elevation: 0,
//           backgroundColor: HexColor("7226D1"), systemOverlayStyle: SystemUiOverlayStyle.light,
//         ),
//         body: LayoutBuilder(
//             builder: (BuildContext context, BoxConstraints constraints) {
//               if (constraints.maxWidth >= 700) {
//                 return Stack(
//                   children: [
//                     Container(
//                       child: Row(
//                         children: [
//                           Expanded(
//                             flex: 2,
//                             child: Container(
//                               color: Color.fromRGBO(35, 0, 79, 1),
//                             ),
//                           ),
//                           Expanded(flex: 1, child: Container()),
//                         ],
//                       ),
//                     ),
//                     Container(
//                       margin: EdgeInsets.all(80.00),
//                       child: Row(
//                         children: [
//                           Expanded(
//                             child: Container(
//                               width: 525,
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.only(
//                                     topLeft: Radius.circular(30),
//                                     bottomLeft: Radius.circular(30)),
//                                 gradient: LinearGradient(
//                                   begin: Alignment.topRight,
//                                   end: Alignment.bottomLeft,
//                                   colors: [
//                                     HexColor("440F87"),
//                                     HexColor("7226D1"),
//                                   ],
//                                 ),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.black12,
//                                     blurRadius: 40.0, // soften the shadow
//                                     offset: Offset(
//                                       0, // Move to right 10  horizontally
//                                       2.0, // Move to bottom 10 Vertically
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               child: Padding(
//                                 padding: const EdgeInsets.all(20.0),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   mainAxisAlignment: MainAxisAlignment.start,
//                                   children: [
//                                     Image.asset(
//                                       'assets/logo.png',
//                                       height: 75,
//                                       width: 110,
//                                     ),
//                                     SizedBox(
//                                       height: 5,
//                                     ),
//                                     Text(
//                                       "Let's Explore",
//                                       style: TextStyle(
//                                           color: Colors.white,
//                                           fontWeight: FontWeight.w300,
//                                           fontSize: 22),
//                                     ),
//                                     Text(
//                                       "Data Science, Analytics & Data Engineering together!",
//                                       style: TextStyle(
//                                           color: Colors.white,
//                                           fontWeight: FontWeight.bold,
//                                           fontSize: 34),
//                                     ),
//                                     SizedBox(
//                                       height: 30,
//                                     ),
//                                     Expanded(
//                                       child: Align(
//                                         alignment: Alignment.center,
//                                         child: Image.asset('assets/nameoop.png'),
//                                         // child: SvgPicture.asset(
//                                         //   'assets/Frame.svg',
//                                         //   height: verticalScale * 360,
//                                         //   width: horizontalScale * 300,
//                                         //   fit: BoxFit.fill,
//                                         // ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                           Container(
//                             width: 325,
//                             height: MediaQuery.of(context).size.height,
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.only(
//                                   topRight: Radius.circular(30),
//                                   bottomRight: Radius.circular(30)),
//                               color: Colors.white,
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.black12,
//                                   blurRadius: 40.0, // soften the shadow
//                                   offset: Offset(
//                                     0, // Move to right 10  horizontally
//                                     2.0, // Move to bottom 10 Vertically
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             child: Column(
//                               children: <Widget>[
//                                 SizedBox(
//                                   height: 100,
//                                 ),
//                                 Column(
//                                   children: <Widget>[
//                                     Container(
//                                         constraints:
//                                         const BoxConstraints(maxWidth: 500),
//                                         margin: const EdgeInsets.symmetric(
//                                             horizontal: 10),
//                                         child: RichText(
//                                           textAlign: TextAlign.center,
//                                           text: TextSpan(children: <TextSpan>[
//                                             TextSpan(
//                                                 text: 'What should we call you?',
//                                                 style: TextStyle(
//                                                     color: MyColors.primaryColor)),
//                                             TextSpan(
//                                                 text: '',
//                                                 style: TextStyle(
//                                                     color: MyColors.primaryColor,
//                                                     fontWeight: FontWeight.bold)),
//                                             TextSpan(
//                                                 text: '',
//                                                 style: TextStyle(
//                                                     color: MyColors.primaryColor)),
//                                           ]),
//                                         )),
//                                     Container(
//                                       height: 60,
//                                       constraints:
//                                       const BoxConstraints(maxWidth: 500),
//                                       margin: const EdgeInsets.symmetric(
//                                           horizontal: 20, vertical: 10),
//                                       child: CupertinoTextField(
//                                         padding: const EdgeInsets.symmetric(
//                                             horizontal: 16),
//                                         decoration: BoxDecoration(
//                                             color: Colors.white,
//                                             borderRadius: const BorderRadius.all(
//                                                 Radius.circular(4))),
//                                         controller: nameController,
//                                         clearButtonMode:
//                                         OverlayVisibilityMode.editing,
//                                         keyboardType: TextInputType.name,
//                                         maxLines: 1,
//                                         placeholder: 'Name',
//                                       ),
//                                     ),
//                                     SizedBox(
//                                       height: 10,
//                                     ),
//                                     GestureDetector(
//                                       onTap: () async {
//                                         FirebaseAuth _auth = FirebaseAuth.instance;

//                                         if (signin == false) {
//                                           var logi =
//                                           await _auth.signInWithCredential(
//                                               globals.credental);
//                                           userprofile(
//                                               name: nameController.text.toString(),
//                                               image: '',
//                                               mobilenumber: globals.phone,
//                                               authType: 'phoneAuth',
//                                               phoneVerified: true,
//                                               email: globals.email, linked: '');
//                                           print(logi.user?.email);
//                                           Toast.show("${logi.user!.email}");
//                                           saveLoginState(context);
//                                         } else {
//                                           userprofile(
//                                               name: nameController.text.toString(),
//                                               image: '',
//                                               mobilenumber: globals.phone,
//                                               authType: 'phoneAuth',
//                                               phoneVerified: true,
//                                               email: globals.email, linked: '');
//                                           saveLoginState(context);
//                                         }

//                                         if (nameController.text.isNotEmpty) {
//                                           try {
//                                             setState(() {
//                                               loading = true;
//                                             });
//                                             globals.name =
//                                                 nameController.text.toString();
//                                             var user = _auth.currentUser;
//                                             if (user != null) {
//                                               await FirebaseFirestore.instance
//                                                   .collection("Users_dataly")
//                                                   .doc(FirebaseAuth
//                                                   .instance.currentUser!.uid)
//                                                   .update({
//                                                 "linked": "true",
//                                               });
//                                               var userDocs;

//                                               try {
//                                                 userDocs = await FirebaseFirestore
//                                                     .instance
//                                                     .collection("Users_dataly")
//                                                     .doc(FirebaseAuth
//                                                     .instance.currentUser!.uid)
//                                                     .get();
//                                               } catch (e) {
//                                                 if (userDocs.data() == null) {
//                                                   await FirebaseFirestore.instance
//                                                       .collection("Users_dataly")
//                                                       .doc(FirebaseAuth.instance
//                                                       .currentUser!.uid)
//                                                       .update({
//                                                     "linked": "true",
//                                                   });
//                                                   // showToast('user data does not exist');

//                                                   setState(() {
//                                                     loading = false;
//                                                   });
//                                                 }
//                                               }

//                                               setState(() {
//                                                 loading = false;
//                                               });
//                                             } else {
//                                               Toast.show('user does not exist');
//                                               setState(() {
//                                                 loading = false;
//                                               });
//                                             }

//                                             var value = await FirebaseAuth
//                                                 .instance.currentUser!.uid;

//                                             Navigator.pushReplacement(
//                                               context,
//                                               MaterialPageRoute(
//                                                 builder: (context) => HomePage(),
//                                               ),
//                                             );
//                                             setState(() {
//                                               loading = false;
//                                             });
//                                           } catch (e) {
//                                             Toast.show(e.toString());
//                                             // Navigator.pushReplacement(
//                                             //   context,
//                                             //   MaterialPageRoute(
//                                             //     builder: (context) => HomePage(),
//                                             //   ),
//                                             // );
//                                           }
//                                         } else {
//                                           setState(() {
//                                             loading = false;
//                                           });
//                                           Toast.show('Please enter your name');
//                                         }
//                                         //        var user = FirebaseAuth.instance.currentUser;
//                                         //       if (nameController.text.isNotEmpty) {
//                                         //         if (user != null) {
//                                         // DocumentSnapshot userDocs = await FirebaseFirestore
//                                         //     .instance
//                                         //     .collection("Users_dataly")
//                                         //     .doc(FirebaseAuth.instance.currentUser!.uid)
//                                         //     .get();
//                                         // if (userDocs.data() == null) {
//                                         //   userprofile(
//                                         //       name: '',
//                                         //       image: '',
//                                         //       mobilenumber: mobile.text,
//                                         //       authType: 'phoneAuth',
//                                         //       phoneVerified: true,
//                                         //       email: '');
//                                         //   showToast('Account Created');
//                                         // }
//                                         //       } else {
//                                         //         SnackBar(
//                                         //           behavior: SnackBarBehavior.floating,
//                                         //           backgroundColor: Colors.red,
//                                         //           content: Text(
//                                         //             'Please enter your name',
//                                         //             style: TextStyle(color: Colors.white),
//                                         //           ),
//                                         //         );
//                                         //       }
//                                       },
//                                       child: Container(
//                                         margin: const EdgeInsets.symmetric(
//                                             horizontal: 20, vertical: 10),
//                                         constraints:
//                                         const BoxConstraints(maxWidth: 500),
//                                         alignment: Alignment.center,
//                                         decoration: const BoxDecoration(
//                                             borderRadius: BorderRadius.all(
//                                                 Radius.circular(14)),
//                                             gradient: LinearGradient(
//                                                 begin: Alignment.centerLeft,
//                                                 end: Alignment.centerRight,
//                                                 colors: [
//                                                   // Color(0xFF8A2387),
//                                                   Color.fromRGBO(120, 96, 220, 1),
//                                                   Color.fromRGBO(120, 96, 220, 1),
//                                                   Color.fromARGB(255, 88, 52, 246),
//                                                 ])),
//                                         padding: const EdgeInsets.symmetric(
//                                             vertical: 8, horizontal: 8),
//                                         child: loading
//                                             ? Padding(
//                                           padding: const EdgeInsets.all(6.0),
//                                           child: Container(
//                                               height: 20,
//                                               width: 20,
//                                               child: Center(
//                                                   child:
//                                                   CircularProgressIndicator(
//                                                       color:
//                                                       Colors.white))),
//                                         )
//                                             : Row(
//                                           mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                           children: <Widget>[
//                                             Padding(
//                                               padding:
//                                               const EdgeInsets.fromLTRB(
//                                                   12, 0, 0, 0),
//                                               child: Text(
//                                                 'Next',
//                                                 style: TextStyle(
//                                                     color: Color.fromARGB(
//                                                         255, 255, 255, 255),
//                                                     fontWeight:
//                                                     FontWeight.bold),
//                                               ),
//                                             ),
//                                             Container(
//                                               padding:
//                                               const EdgeInsets.all(8),
//                                               decoration: BoxDecoration(
//                                                 borderRadius:
//                                                 const BorderRadius.all(
//                                                     Radius.circular(20)),
//                                                 color: MyColors
//                                                     .primaryColorLight,
//                                               ),
//                                               child: Icon(
//                                                 Icons.arrow_forward_ios,
//                                                 color: Colors.white,
//                                                 size: 16,
//                                               ),
//                                             )
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                     // SizedBox(
//                                     //   height: 10,
//                                     // ),
//                                     // Container(
//                                     //   margin: const EdgeInsets.symmetric(
//                                     //       horizontal: 20, vertical: 10),
//                                     //   constraints:
//                                     //       const BoxConstraints(maxWidth: 500),
//                                     //   child: RaisedButton(
//                                     //     onPressed: () {
//                                     //       if (phoneController.text.isNotEmpty) {
//                                     //         loginStore.getCodeWithPhoneNumber(context,
//                                     //             "+91${phoneController.text.toString()}");
//                                     //       } else {
//                                     //         loginStore.loginScaffoldKey.currentState
//                                     //             ?.showSnackBar(SnackBar(
//                                     //           behavior: SnackBarBehavior.floating,
//                                     //           backgroundColor: Colors.red,
//                                     //           content: Text(
//                                     //             'Please enter a phone number',
//                                     //             style: TextStyle(color: Colors.white),
//                                     //           ),
//                                     //         ));
//                                     //       }
//                                     //     },
//                                     //     color: MyColors.primaryColor,
//                                     //     shape: const RoundedRectangleBorder(
//                                     //         borderRadius: BorderRadius.all(
//                                     //             Radius.circular(14))),
//                                     //     child: Container(
//                                     //       padding: const EdgeInsets.symmetric(
//                                     //           vertical: 8, horizontal: 8),
//                                     //       child: Row(
//                                     //         mainAxisAlignment:
//                                     //             MainAxisAlignment.spaceBetween,
//                                     //         children: <Widget>[
//                                     //           Text(
//                                     //             'Next',
//                                     //             style: TextStyle(color: Colors.white),
//                                     //           ),
//                                     //           Container(
//                                     //             padding: const EdgeInsets.all(8),
//                                     //             decoration: BoxDecoration(
//                                     //               borderRadius:
//                                     //                   const BorderRadius.all(
//                                     //                       Radius.circular(20)),
//                                     //               color: MyColors.primaryColorLight,
//                                     //             ),
//                                     //             child: Icon(
//                                     //               Icons.arrow_forward_ios,
//                                     //               color: Colors.white,
//                                     //               size: 16,
//                                     //             ),
//                                     //           )
//                                     //         ],
//                                     //       ),
//                                     //     ),
//                                     //   ),
//                                     // )
//                                   ],
//                                 )
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 );
//               } else {
//                 return SafeArea(
//                   child: SingleChildScrollView(
//                     child: Container(
//                       height: MediaQuery.of(context).size.height,
//                       child: Column(
//                         children: <Widget>[
//                           Expanded(
//                             flex: 2,
//                             child: Column(
//                               children: <Widget>[
//                                 Container(
//                                   margin: const EdgeInsets.symmetric(
//                                       horizontal: 20, vertical: 20),
//                                   child: Stack(
//                                     children: <Widget>[
//                                       // Center(
//                                       //   child: Container(
//                                       //     height: 240,
//                                       //     constraints:
//                                       //         const BoxConstraints(maxWidth: 500),
//                                       //     margin: const EdgeInsets.only(top: 100),
//                                       //     decoration: const BoxDecoration(
//                                       //         color: Color.fromRGBO(225, 224, 245, 1),
//                                       //         borderRadius: BorderRadius.all(
//                                       //             Radius.circular(30))),
//                                       //   ),
//                                       // ),
//                                       Center(
//                                         child: Container(
//                                             decoration: const BoxDecoration(
//                                                 borderRadius: BorderRadius.all(
//                                                     Radius.circular(30))),
//                                             constraints: const BoxConstraints(
//                                                 maxHeight: 340),
//                                             margin: const EdgeInsets.symmetric(
//                                                 horizontal: 8),
//                                             child:
//                                             Image.asset('assets/nameoop.png')),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 SizedBox(
//                                   height: 40,
//                                 ),
//                                 Container(
//                                     margin:
//                                     const EdgeInsets.symmetric(horizontal: 10),
//                                     child: Text('CloudyML',
//                                         style: TextStyle(
//                                             color: MyColors.primaryColor,
//                                             fontSize: 25,
//                                             fontWeight: FontWeight.w800)))
//                               ],
//                             ),
//                           ),
//                           Expanded(
//                             flex: 1,
//                             child: Column(
//                               children: <Widget>[
//                                 Container(
//                                     constraints:
//                                     const BoxConstraints(maxWidth: 500),
//                                     margin:
//                                     const EdgeInsets.symmetric(horizontal: 10),
//                                     child: RichText(
//                                       textAlign: TextAlign.center,
//                                       text: TextSpan(children: <TextSpan>[
//                                         TextSpan(
//                                             text: 'What should we call you?',
//                                             style: TextStyle(
//                                                 color: MyColors.primaryColor)),
//                                         TextSpan(
//                                             text: '',
//                                             style: TextStyle(
//                                                 color: MyColors.primaryColor,
//                                                 fontWeight: FontWeight.bold)),
//                                         TextSpan(
//                                             text: '',
//                                             style: TextStyle(
//                                                 color: MyColors.primaryColor)),
//                                       ]),
//                                     )),
//                                 Container(
//                                   height: 60,
//                                   constraints: const BoxConstraints(maxWidth: 500),
//                                   margin: const EdgeInsets.symmetric(
//                                       horizontal: 20, vertical: 10),
//                                   child: CupertinoTextField(
//                                     padding:
//                                     const EdgeInsets.symmetric(horizontal: 16),
//                                     decoration: BoxDecoration(
//                                         color: Colors.white,
//                                         borderRadius: const BorderRadius.all(
//                                             Radius.circular(4))),
//                                     controller: nameController,
//                                     clearButtonMode: OverlayVisibilityMode.editing,
//                                     keyboardType: TextInputType.name,
//                                     maxLines: 1,
//                                     placeholder: 'Name',
//                                   ),
//                                 ),
//                                 SizedBox(
//                                   height: 10,
//                                 ),
//                                 GestureDetector(
//                                   onTap: () async {
//                                     FirebaseAuth _auth = FirebaseAuth.instance;

//                                     if (signin == false) {
//                                       var logi = await _auth
//                                           .signInWithCredential(globals.credental);
//                                       userprofile(
//                                           name: nameController.text.toString(),
//                                           image: '',
//                                           mobilenumber: globals.phone,
//                                           authType: 'phoneAuth',
//                                           phoneVerified: true,
//                                           email: globals.email, linked: '');
//                                       print(logi.user?.email);
//                                       Toast.show("${logi.user!.email}");
//                                     } else {
//                                       userprofile(
//                                           name: nameController.text.toString(),
//                                           image: '',
//                                           mobilenumber: globals.phone,
//                                           authType: 'phoneAuth',
//                                           phoneVerified: true,
//                                           email: globals.email, linked: '');
//                                     }

//                                     if (nameController.text.isNotEmpty) {
//                                       try {
//                                         setState(() {
//                                           loading = true;
//                                         });
//                                         globals.name =
//                                             nameController.text.toString();
//                                         var user = _auth.currentUser;
//                                         if (user != null) {
//                                           await FirebaseFirestore.instance
//                                               .collection("Users_dataly")
//                                               .doc(FirebaseAuth
//                                               .instance.currentUser!.uid)
//                                               .update({
//                                             "linked": "true",
//                                           });
//                                           var userDocs;
//                                           try {
//                                             userDocs = await FirebaseFirestore
//                                                 .instance
//                                                 .collection("Users_dataly")
//                                                 .doc(FirebaseAuth
//                                                 .instance.currentUser!.uid)
//                                                 .get();
//                                           } catch (e) {
//                                             if (userDocs.data() == null) {
//                                               await FirebaseFirestore.instance
//                                                   .collection("Users_dataly")
//                                                   .doc(FirebaseAuth
//                                                   .instance.currentUser!.uid)
//                                                   .update({
//                                                 "linked": "true",
//                                               });
//                                               // showToast('user data does not exist');

//                                               setState(() {
//                                                 loading = false;
//                                               });
//                                             }
//                                           }

//                                           setState(() {
//                                             loading = false;
//                                           });
//                                         } else {
//                                           Toast.show('user does not exist');
//                                           setState(() {
//                                             loading = false;
//                                           });
//                                         }

//                                         var value = await FirebaseAuth
//                                             .instance.currentUser!.uid;

//                                         Navigator.pushReplacement(
//                                           context,
//                                           MaterialPageRoute(
//                                             builder: (context) => HomePage(),
//                                           ),
//                                         );
//                                         setState(() {
//                                           loading = false;
//                                         });
//                                       } catch (e) {
//                                         Toast.show(e.toString());
//                                         // Navigator.pushReplacement(
//                                         //   context,
//                                         //   MaterialPageRoute(
//                                         //     builder: (context) => HomePage(),
//                                         //   ),
//                                         // );
//                                       }
//                                     } else {
//                                       setState(() {
//                                         loading = false;
//                                       });
//                                       Toast.show('Please enter your name');
//                                     }
//                                     //        var user = FirebaseAuth.instance.currentUser;
//                                     //       if (nameController.text.isNotEmpty) {
//                                     //         if (user != null) {
//                                     // DocumentSnapshot userDocs = await FirebaseFirestore
//                                     //     .instance
//                                     //     .collection("Users_dataly")
//                                     //     .doc(FirebaseAuth.instance.currentUser!.uid)
//                                     //     .get();
//                                     // if (userDocs.data() == null) {
//                                     //   userprofile(
//                                     //       name: '',
//                                     //       image: '',
//                                     //       mobilenumber: mobile.text,
//                                     //       authType: 'phoneAuth',
//                                     //       phoneVerified: true,
//                                     //       email: '');
//                                     //   showToast('Account Created');
//                                     // }
//                                     //       } else {
//                                     //         SnackBar(
//                                     //           behavior: SnackBarBehavior.floating,
//                                     //           backgroundColor: Colors.red,
//                                     //           content: Text(
//                                     //             'Please enter your name',
//                                     //             style: TextStyle(color: Colors.white),
//                                     //           ),
//                                     //         );
//                                     //       }
//                                   },
//                                   child: Container(
//                                     margin: const EdgeInsets.symmetric(
//                                         horizontal: 20, vertical: 10),
//                                     constraints:
//                                     const BoxConstraints(maxWidth: 500),
//                                     alignment: Alignment.center,
//                                     decoration: const BoxDecoration(
//                                         borderRadius:
//                                         BorderRadius.all(Radius.circular(14)),
//                                         gradient: LinearGradient(
//                                             begin: Alignment.centerLeft,
//                                             end: Alignment.centerRight,
//                                             colors: [
//                                               // Color(0xFF8A2387),
//                                               Color.fromRGBO(120, 96, 220, 1),
//                                               Color.fromRGBO(120, 96, 220, 1),
//                                               Color.fromARGB(255, 88, 52, 246),
//                                             ])),
//                                     padding: const EdgeInsets.symmetric(
//                                         vertical: 8, horizontal: 8),
//                                     child: loading
//                                         ? Padding(
//                                       padding: const EdgeInsets.all(6.0),
//                                       child: Container(
//                                           height: 20,
//                                           width: 20,
//                                           child: Center(
//                                               child:
//                                               CircularProgressIndicator(
//                                                   color: Colors.white))),
//                                     )
//                                         : Row(
//                                       mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                       children: <Widget>[
//                                         Padding(
//                                           padding: const EdgeInsets.fromLTRB(
//                                               12, 0, 0, 0),
//                                           child: Text(
//                                             'Next',
//                                             style: TextStyle(
//                                                 color: Color.fromARGB(
//                                                     255, 255, 255, 255),
//                                                 fontWeight: FontWeight.bold),
//                                           ),
//                                         ),
//                                         Container(
//                                           padding: const EdgeInsets.all(8),
//                                           decoration: BoxDecoration(
//                                             borderRadius:
//                                             const BorderRadius.all(
//                                                 Radius.circular(20)),
//                                             color: MyColors.primaryColorLight,
//                                           ),
//                                           child: Icon(
//                                             Icons.arrow_forward_ios,
//                                             color: Colors.white,
//                                             size: 16,
//                                           ),
//                                         )
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                                 // SizedBox(
//                                 //   height: 10,
//                                 // ),
//                                 // Container(
//                                 //   margin: const EdgeInsets.symmetric(
//                                 //       horizontal: 20, vertical: 10),
//                                 //   constraints:
//                                 //       const BoxConstraints(maxWidth: 500),
//                                 //   child: RaisedButton(
//                                 //     onPressed: () {
//                                 //       if (phoneController.text.isNotEmpty) {
//                                 //         loginStore.getCodeWithPhoneNumber(context,
//                                 //             "+91${phoneController.text.toString()}");
//                                 //       } else {
//                                 //         loginStore.loginScaffoldKey.currentState
//                                 //             ?.showSnackBar(SnackBar(
//                                 //           behavior: SnackBarBehavior.floating,
//                                 //           backgroundColor: Colors.red,
//                                 //           content: Text(
//                                 //             'Please enter a phone number',
//                                 //             style: TextStyle(color: Colors.white),
//                                 //           ),
//                                 //         ));
//                                 //       }
//                                 //     },
//                                 //     color: MyColors.primaryColor,
//                                 //     shape: const RoundedRectangleBorder(
//                                 //         borderRadius: BorderRadius.all(
//                                 //             Radius.circular(14))),
//                                 //     child: Container(
//                                 //       padding: const EdgeInsets.symmetric(
//                                 //           vertical: 8, horizontal: 8),
//                                 //       child: Row(
//                                 //         mainAxisAlignment:
//                                 //             MainAxisAlignment.spaceBetween,
//                                 //         children: <Widget>[
//                                 //           Text(
//                                 //             'Next',
//                                 //             style: TextStyle(color: Colors.white),
//                                 //           ),
//                                 //           Container(
//                                 //             padding: const EdgeInsets.all(8),
//                                 //             decoration: BoxDecoration(
//                                 //               borderRadius:
//                                 //                   const BorderRadius.all(
//                                 //                       Radius.circular(20)),
//                                 //               color: MyColors.primaryColorLight,
//                                 //             ),
//                                 //             child: Icon(
//                                 //               Icons.arrow_forward_ios,
//                                 //               color: Colors.white,
//                                 //               size: 16,
//                                 //             ),
//                                 //           )
//                                 //         ],
//                                 //       ),
//                                 //     ),
//                                 //   ),
//                                 // )
//                               ],
//                             ),
//                           )
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               }
//             }));
//   }
// }
