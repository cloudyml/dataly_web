import 'dart:math';
import 'package:badges/badges.dart';
import 'package:cloudyml_app2/all_certificate_screen.dart';
import 'package:cloudyml_app2/screens/review_screen/review_screen.dart';
import 'package:cloudyml_app2/widgets/notification_popup.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../global_variable.dart' as globals;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloudyml_app2/payments_history.dart';
import 'package:cloudyml_app2/privacy_policy.dart';
import 'package:cloudyml_app2/router/login_state_check.dart';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:cloudyml_app2/models/firebase_file.dart';
import 'package:cloudyml_app2/screens/image_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:cloudyml_app2/globals.dart';
import 'package:provider/provider.dart';
import 'Providers/UserProvider.dart';
import 'aboutus.dart';
import 'authentication/firebase_auth.dart';
import 'home.dart';
import 'homepage.dart';
import 'my_Courses.dart';
import 'package:universal_html/html.dart' as html;
import 'package:share_extend/share_extend.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';

bool isLoading = false;

Row Star() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      Icon(
        Icons.star,
        color: Color.fromARGB(255, 6, 240, 185),
        size: 18,
      ),
      Icon(
        Icons.star,
        color: Color.fromARGB(255, 6, 240, 185),
        size: 18,
      ),
      Icon(
        Icons.star,
        color: Color.fromARGB(255, 6, 240, 185),
        size: 18,
      ),
      Icon(
        Icons.star,
        color: Color.fromARGB(255, 6, 240, 185),
        size: 18,
      ),
      Icon(
        Icons.star_half,
        color: Color.fromARGB(255, 6, 240, 185),
        size: 18,
      ),
    ],
  );
}

Widget buildFile(BuildContext context, FirebaseFile file) => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ImagePage(file: file),
            ),
          ),
          child: solidBorder(
            child: Padding(
              padding: EdgeInsets.all(5),
              child: Container(
                decoration: BoxDecoration(boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 8.0,
                    spreadRadius: .09,
                    offset: Offset(1, 5),
                  )
                ]),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CachedNetworkImage(
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                    imageUrl: file.url,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );

Widget featureTile(
    IconData icon, String T1, double horizontalScale, double verticalScale) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Container(
      width: 364 * horizontalScale,
      height: 38 * verticalScale,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
        boxShadow: [
          BoxShadow(
              color: Color.fromRGBO(31, 31, 31, 0.25),
              offset: Offset(0, 0),
              blurRadius: 5)
        ],
        color: Color.fromRGBO(255, 255, 255, 1),
      ),
      child: Row(
        children: [
          Container(
            width: 38 * min(horizontalScale, verticalScale),
            height: 38 * min(horizontalScale, verticalScale),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
              color: Color.fromRGBO(122, 98, 222, 1),
            ),
            child: Center(
              child: Icon(
                icon,
                color: Colors.white,
                size: 28 * min(horizontalScale, verticalScale),
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Text(
            '$T1',
            textScaleFactor: min(horizontalScale, verticalScale),
            style: TextStyle(
              overflow: TextOverflow.ellipsis,
              color: Colors.black,
              fontSize: 16,
            ),
          ),
        ],
      ),
    ),
  );
  // return Padding(
  //   padding: const EdgeInsets.all(8.0),
  //   child: Row(
  //     mainAxisAlignment: MainAxisAlignment.start,
  //     children: [
  //       Icon(
  //         Icn,
  //         color: Color(0xFF7860DC),
  //       ),
  //       SizedBox(
  //         width: 13,
  //       ),
  //       Text(
  //         '$T1',
  //         style: TextStyle(
  //           overflow: TextOverflow.ellipsis,
  //           color: Colors.black,
  //           fontSize: 13,
  //         ),
  //       ),
  //     ],
  //   ),
  // );
}

Widget catalogContainer(BuildContext context, String text, IconData icon) {
  final screenHeight = MediaQuery.of(context).size.height;
  final screenWidth = MediaQuery.of(context).size.width;
  var verticalScale = screenHeight / mockUpHeight;
  return Padding(
    padding: EdgeInsets.only(left: 50.0),
    child: Container(
      height: screenHeight / 4.25,
      width: screenWidth / 5,
      padding: EdgeInsets.all(20 * verticalScale),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 25.sp,
            color: HexColor('683AB0'),
          ),
          SizedBox(
            height: 5 * verticalScale,
          ),
          Text(
            text,
            style: TextStyle(
                fontSize: 14 * verticalScale, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ),
  );
}

Widget catalogContainerForMobile(
    BuildContext context, String text, IconData icon) {
  return Container(
    height: Adaptive.h(10),
    width: Adaptive.w(30),
    padding: EdgeInsets.all(5.sp),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10.sp),
      color: Colors.white,
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 15.sp,
          color: HexColor('683AB0'),
        ),
        SizedBox(
          height: 5.sp,
        ),
        Text(
          text,
          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}

Column includes(BuildContext context) {
  final screenHeight = MediaQuery.of(context).size.height;
  final screenWidth = MediaQuery.of(context).size.width;
  var verticalScale = screenHeight / mockUpHeight;
  var horizontalScale = screenWidth / mockUpWidth;
  return Column(
    children: [
      Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Container(
            padding: const EdgeInsets.only(left: 10),
            width: 378 * horizontalScale,
            height: 38 * verticalScale,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
              boxShadow: [
                BoxShadow(
                    color: Color.fromRGBO(31, 31, 31, 0.25),
                    offset: Offset(0, 0),
                    blurRadius: 5)
              ],
              color: Color.fromRGBO(122, 98, 222, 1),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Course Features!',
                // textAlign: TextAlign.left,
                textScaleFactor: min(horizontalScale, verticalScale),
                style: TextStyle(
                    color: Color.fromRGBO(255, 255, 255, 1),
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    letterSpacing:
                        0 /*percentages not used in flutter. defaulting to zero*/,
                    fontWeight: FontWeight.bold,
                    height: 1),
              ),
            ),
          ),
        ),
      ),
      SizedBox(
        height: 15,
      ),
      featureTile(
        Icons.book,
        'Guided Hands-On Assignment',
        horizontalScale,
        verticalScale,
      ),
      featureTile(
        Icons.assignment,
        'Capstone End to End Project',
        horizontalScale,
        verticalScale,
      ),
      featureTile(
        Icons.badge,
        'One Month Internship Opportunity',
        horizontalScale,
        verticalScale,
      ),
      featureTile(
        Icons.call,
        '1-1 Chat Support',
        horizontalScale,
        verticalScale,
      ),
      featureTile(
        Icons.email,
        'Job Referrals & Opening Mails',
        horizontalScale,
        verticalScale,
      ),
      featureTile(
        Icons.picture_as_pdf,
        'Interview Q&As PDF Collection',
        horizontalScale,
        verticalScale,
      ),
      featureTile(
        Icons.picture_in_picture,
        'Course Completion Certificates',
        horizontalScale,
        verticalScale,
      ),
    ],
  );
}

Row Buttoncombo(double width, String orgprice, String saleprice) {
  return Row(
    children: [
      Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 0)),
      Container(
        // height: 35,
        // width: width * .27,
        // decoration: BoxDecoration(
        //     borderRadius: BorderRadius.circular(20),
        //     color: Colors.grey.shade300),
        child: Center(
          child: Text(
            '₹$orgprice/-',
            style: TextStyle(
                fontFamily: 'bold',
                color: Colors.black,
                fontSize: 10,
                decoration: TextDecoration.lineThrough),
          ),
        ),
      ),
      SizedBox(
        width: 10,
      ),
      Container(
        // height: 35,
        // width: width * .27,
        // decoration: BoxDecoration(
        //   borderRadius: BorderRadius.circular(20),
        //   gradient: LinearGradient(
        //     begin: Alignment.bottomLeft,
        //     end: Alignment.topRight,
        //     colors: [Color(0xFF57ebde), Color(0xFFaefb2a)],
        //   ),
        // ),
        child: Center(
          child: Text(
            '₹$saleprice/-',
            style: TextStyle(
              fontFamily: 'bold',
              color: Colors.black,
              fontSize: 10,
            ),
          ),
        ),
      )
    ],
  );
}

Row Button1(
  double width,
  String orgprice,
) {
  return Row(
    children: [
      Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 0)),
      Container(
        // height: 35,
        // width: width * .27,
        // decoration: BoxDecoration(
        //   borderRadius: BorderRadius.circular(20),
        //   gradient: LinearGradient(
        //     begin: Alignment.bottomLeft,
        //     end: Alignment.topRight,
        //     colors: [Color(0xFF57ebde), Color(0xFFaefb2a)],
        //   ),
        // ),
        child: Center(
          child: Text(
            '$orgprice',
            style: TextStyle(
              fontFamily: 'bold',
              color: Colors.black,
              fontSize: 10,
            ),
          ),
        ),
      )
    ],
  );
}

Container img(double width, double height, String link) {
  return Container(
    height: height * .25,
    width: width * 13,
    child: Image(image: CachedNetworkImageProvider(link), fit: BoxFit.fill),
  );
}

Column colname(String text1, String text2) {
  return Column(children: [
    Container(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
      alignment: Alignment.topLeft,
      margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
      child: Text(
        '$text1',
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            color: Colors.black,
            fontSize: 11,
            fontFamily: 'GideonRoman',
            fontWeight: FontWeight.bold,
            height: .97),
      ),
    ),
    Container(
      padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
      alignment: Alignment.topLeft,
      child: Text(
        '$text2',
        style: TextStyle(color: Colors.black, fontSize: 15),
      ),
    ),
  ]);
}

SafeArea safearea() {
  final image1 = imageFile('assets/image_1.jpeg');
  final image2 = imageFile('assets/image_2.jpeg');
  final image3 = imageFile('assets/image_3.jpeg');
  final image4 = imageFile('assets/image_4.jpeg');
  final image5 = imageFile('assets/image_5.jpeg');

  return
      // appBar: AppBar(),
      SafeArea(
          child: SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        children: [
          const Text(
            'Recent Success Stories Of Our Learners',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 23, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(
            height: 20,
          ),
          solidBorder(
            child: image1,
          ),
          const SizedBox(
            height: 15,
          ),
          solidBorder(
            child: image2,
          ),
          const SizedBox(
            height: 15,
          ),
          solidBorder(
            child: image3,
          ),
          const SizedBox(
            height: 15,
          ),
          solidBorder(
            child: image4,
          ),
          const SizedBox(
            height: 15,
          ),
          solidBorder(
            child: image5,
          ),
        ],
      ),
    ),
  ));
}

Widget solidBorder({required Widget child}) {
  return DottedBorder(
    strokeWidth: 5,
    padding: EdgeInsets.all(2),
    color: Colors.white24,
    borderType: BorderType.RRect,
    radius: const Radius.circular(20),
    dashPattern: const [1, 0],
    child: child,
  );
}

Widget imageFile(String url) {
  return Image.asset(
    url,
    width: 330,
    height: 330,
    fit: BoxFit.cover,
  );
}

SingleChildScrollView safearea1(BuildContext context) {
  // final size = MediaQuery.of(context).size;
  //   final height = size.height;
  //   final width = size.width;
  final screenHeight = MediaQuery.of(context).size.height;
  final screenWidth = MediaQuery.of(context).size.width;
  var verticalScale = screenHeight / mockUpHeight;
  var horizontalScale = screenWidth / mockUpWidth;
  final LinearGradient _gradient = const LinearGradient(
    colors: [Colors.white, Colors.white],
  );
  // print('i love you');
  return SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // ShaderMask(
        //   shaderCallback: (Rect rect) {
        //     return _gradient.createShader(rect);
        //   },
        //   child:
        // ),
        // const SizedBox(
        //   height: 10,
        // ),
        Container(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image(
                    image: AssetImage('assets/a1.png'),
                    height: 225,
                    width: 350,
                    fit: BoxFit.fill),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 5,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 20, 0, 0),
          child: Text(
            'About Me',
            textScaleFactor: min(horizontalScale, verticalScale),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.normal,
              color: Colors.black,
              fontFamily: 'Poppins',
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(10, 15, 15, 0),
          child: Container(
            width: 300,
            alignment: Alignment.topLeft,
            child: const Text.rich(TextSpan(
                text: 'I have transitioned my career from ',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black,
                  wordSpacing: 1,
                ),
                children: [
                  TextSpan(
                      text: 'Manual Tester to Data Scientist ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 12,
                        wordSpacing: 5,
                      )),
                  TextSpan(
                    text:
                        'by upskilling myself on my own from various online resources and doing lots of ',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                      wordSpacing: 5,
                    ),
                  ),
                  TextSpan(
                      text: 'Hands-on practice. ',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        wordSpacing: 5,
                      )),
                  TextSpan(
                      text: 'For internal switch I sent around ',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        wordSpacing: 2,
                      )),
                  TextSpan(
                    text: '150 mails ',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      wordSpacing: 5,
                    ),
                  ),
                  TextSpan(
                      text: 'to different project managers, ',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black,
                        wordSpacing: 5,
                      )),
                  TextSpan(
                      text: 'interviewed in 20 ',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        wordSpacing: 5,
                      )),
                  TextSpan(
                      text: 'and got selected in ',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black,
                        wordSpacing: 4,
                      )),
                  TextSpan(
                      text: '10 projects.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        wordSpacing: 5,
                      )),
                ])),
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
          child: Container(
            width: 300,
            child: const Text.rich(TextSpan(
                text:
                    'When it came to changing company I put papers with NO offers in hand. And in the notice period I struggled to get a job. First 2 months were very difficult but in the last month things started changing miraculously.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black,
                  wordSpacing: 3,
                ))),
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
          child: Container(
            width: 340,
            child: const Text.rich(TextSpan(
              text: 'I attended ',
              style: TextStyle(
                color: Colors.black,
                fontSize: 12,
                wordSpacing: 5,
              ),
              children: [
                TextSpan(
                    text: '40+ interviews ',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      wordSpacing: 5,
                    )),
                TextSpan(
                    text: 'in span of ',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      wordSpacing: 5,
                    )),
                TextSpan(
                    text: '3 months ',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      wordSpacing: 5,
                    )),
                TextSpan(
                    text: 'with the help of ',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      wordSpacing: 5,
                    )),
                TextSpan(
                    text: 'Naukri and LinkedIn profile Optimizations ',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      wordSpacing: 5,
                    )),
                TextSpan(
                    text: 'and got offer by ',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      wordSpacing: 5,
                    )),
                TextSpan(
                    text: '8 companies. ',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      wordSpacing: 5,
                    )),
              ],
            )),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    ),
  );
}

final buttonTextStyle = TextStyle(
  // color: Colors.white,
  fontWeight: FontWeight.w500,
  fontSize: 16,
  letterSpacing: 1.1,
);

var textStyle = TextStyle(
  fontWeight: FontWeight.bold,
  color: Colors.white,
  fontSize: 20,
  fontFamily: "Semibold",
);

// String numberOfLearners = '13000+ learners';
var mentorItems = [
  'My Courses',
  'Resume Review',
  'Your Certificates',
  'Admin Quiz Panel',
  'Add Course',
  'My Quizzes',
  'Assignment Review',
  'My Profile',
  'Logout'
];

var items = ['My Courses', 'My Quizzes', 'My Profile', 'Logout'];
String dropdownValue = '';

Widget customMenuBar(BuildContext context) {
  void saveLoginOutState(BuildContext context) {
    Provider.of<LoginState>(context, listen: false).loggedIn = false;
  }

  final screenHeight = MediaQuery.of(context).size.height;
  final screenWidth = MediaQuery.of(context).size.width;
  var verticalScale = screenHeight / mockUpHeight;
  var horizontalScale = screenWidth / mockUpWidth;
  return Padding(
    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
    child: Row(
      children: [
        SizedBox(
          width: horizontalScale * 10,
        ),
        InkWell(
          onTap: () {
            GoRouter.of(context).pushNamed('home');
          },
          child: Row(
            children: [
              Image.asset(
                "assets/logo.png",
                width: 75,
                height: 55,
              ),
              Text(
                "Dataly",
                style: textStyle,
              ),
            ],
          ),
        ),
        Spacer(),
        TextButton(
            onPressed: () {
              GoRouter.of(context).pushNamed('home');
            },
            child: Text(
              'Home',
              style: buttonTextStyle.copyWith(
                color: Uri.base.path == '/home'
                    ? HexColor('873AFF')
                    : Colors.white,
              ),
            )),
        SizedBox(
          width: horizontalScale * 10,
        ),
        TextButton(
            onPressed: () {
              GoRouter.of(context).pushNamed('store');
            },
            child: Text('Store',
                style: buttonTextStyle.copyWith(
                  color: Uri.base.path == '/store'
                      ? HexColor('873AFF')
                      : Colors.white,
                ))),
        SizedBox(
          width: horizontalScale * 10,
        ),
        TextButton(
            onPressed: () {
              // GoRouter.of(context).goNamed('reviews');
              GoRouter.of(context).pushNamed('reviews');
            },
            child: Text(
              'Reviews',
              style: buttonTextStyle.copyWith(
                color: Uri.base.path == '/reviews'
                    ? HexColor('873AFF')
                    : Colors.white,
              ),
            )),
        SizedBox(
          width: horizontalScale * 10,
        ),
        TextButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: Colors.white,
                      title: Center(
                        child: Text('Contact Support'),
                      ),
                      content: Container(
                        height: 30.sp,
                        child: Column(
                          children: [
                            SelectableText(
                                'Please email us at app.support@cloudyml.com'),
                            SelectableText(' or call on +91 85879 11971.'),
                          ],
                        ),
                      ),
                    );
                  });
            },
            child: Text(
              'Support',
              style: buttonTextStyle.copyWith(
                color: Colors.white,
              ),
            )),
        SizedBox(
          width: horizontalScale * 10,
        ),
        DropdownButtonHideUnderline(
          child: DropdownButton2(
            customButton: Row(
              children: [
                Text(
                  'More',
                  style: buttonTextStyle.copyWith(
                    color: Uri.base.path == '/myCourses'
                        ? HexColor('873AFF')
                        : Colors.white,
                  ),
                ),
                SizedBox(
                  width: 100,
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: Colors.white,
                )
              ],
            ),
            isExpanded: false,
            isDense: false,
            iconStyleData: IconStyleData(
              icon: Icon(Icons.arrow_drop_down),
              iconDisabledColor: Colors.white,
              iconEnabledColor: Colors.white,
            ),
            dropdownStyleData: DropdownStyleData(
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            underline: Container(),
            hint: Text(
              'More',
              style: buttonTextStyle.copyWith(
                color: Uri.base.path == '/myCourses'
                    ? HexColor('873AFF')
                    : Colors.white,
              ),
            ),
            onChanged: (String? value) {
              if (value != dropdownValue) {
                if (value == 'My Courses') {
                  GoRouter.of(context).pushReplacementNamed('myCourses');
                } else if (value == 'Resume Review') {
                  GoRouter.of(context).pushReplacementNamed('reviewResume');
                } else if (value == 'Admin Quiz Panel') {
                  GoRouter.of(context).pushReplacementNamed('quizpanel');
                } else if (value == 'Your Certificates') {
                  GoRouter.of(context)
                      .pushReplacementNamed('allcertificatescreen');
                } else if (value == 'Add Course') {
                  GoRouter.of(context).pushNamed('AddCourse');
                } else if (value == 'My Quizzes') {
                  GoRouter.of(context).pushReplacementNamed('quizes');
                } else if (value == 'Assignment Review') {
                  GoRouter.of(context)
                      .pushReplacementNamed('AssignmentScreenForMentors');
                } else if (value == 'My Profile') {
                  GoRouter.of(context).pushReplacementNamed('myAccount');
                } else if (value == 'Logout') {
                  logOut(context);
                  saveLoginOutState(context);
                  GoRouter.of(context).pushReplacement('/login');
                } else {
                  Fluttertoast.showToast(msg: 'Please refresh the screen.');
                }
              }
            },
            items: globals.role == 'mentor'
                ? mentorItems.map((String mentorItems) {
                    return DropdownMenuItem(
                        value: mentorItems,
                        child: Text(
                          mentorItems,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ));
                  }).toList()
                : items.map((String items) {
                    return DropdownMenuItem(
                        value: items,
                        child: Text(
                          items,
                          style: buttonTextStyle.copyWith(
                            color: Colors.white,
                          ),
                        ));
                  }).toList(),
          ),
        ),
        SizedBox(
          width: 15 * horizontalScale,
        ),
      ],
    ),
  );
}

Drawer customDrawer(BuildContext context) {
  void saveLoginState(BuildContext context) {
    Provider.of<LoginState>(context, listen: false).loggedIn = false;
  }

  final userProvider = Provider.of<UserProvider>(context);
  return Drawer(
    child: Container(
      child: Stack(
        children: [
          ListView(
            padding: EdgeInsets.only(top: 0),
            children: [
              Stack(
                children: [
                  Container(
                    child: Image.network(
                        "https://firebasestorage.googleapis.com/v0/b/cloudyml-app.appspot.com/o/test_developer%2FRectangle%20133.png?alt=media&token=1c822b64-1f79-4654-9ebd-2bd0682c8e0f"),
                  ),
                  UserAccountsDrawerHeader(
                    accountName: Text(
                      userProvider.userModel?.name.toString() ?? 'Enter name',
                    ),
                    accountEmail: Text(
                      userProvider.userModel?.email.toString() == ''
                          ? userProvider.userModel?.mobile.toString() ?? ''
                          : userProvider.userModel?.email.toString() ??
                              'Enter email',
                    ),
                    currentAccountPicture: GestureDetector(
                      onTap: () {
                        GoRouter.of(context).push('/myAccount');
                        // Navigator.pushNamed(context, '/myAccount');
                      },
                      child: CircleAvatar(
                        foregroundColor: Colors.black,
                        //foregroundImage: NetworkImage('https://stratosphere.co.in/img/user.jpg'),
                        foregroundImage:
                            NetworkImage(userProvider.userModel?.image ?? ''),
                        backgroundColor: Colors.transparent,
                        backgroundImage: CachedNetworkImageProvider(
                          'https://stratosphere.co.in/img/user.jpg',
                        ),
                      ),
                    ),
                    decoration: BoxDecoration(color: Colors.transparent),
                  ),
                ],
              ),
              InkWell(
                child: ListTile(
                  title: Text('Home'),
                  leading: Icon(
                    Icons.home,
                    color: HexColor('691EC8'),
                  ),
                ),
                onTap: () {
                  GoRouter.of(context).push('/home');
                },
              ),
              //navigate to store
              InkWell(
                child: ListTile(
                  title: Text('Courses'),
                  leading: Icon(
                    Icons.store,
                    color: HexColor('691EC8'),
                  ),
                ),
                onTap: () {
                  GoRouter.of(context).push('/store');
                },
              ),

              //navigate to messages
              InkWell(
                child: ListTile(
                  title: Text('Chat with TA'),
                  leading: Icon(
                    Icons.chat_bubble_outline_sharp,
                    color: HexColor('691EC8'),
                  ),
                ),
                onTap: () {
                  Device.screenType == ScreenType.tablet
                      ? GoRouter.of(context).push('/mychat')
                      : GoRouter.of(context).push('/mobilechat');
                },
              ),
              InkWell(
                child: ListTile(
                  title: Text(''
                      'My Account'),
                  leading: Icon(
                    Icons.person,
                    color: HexColor('691EC8'),
                  ),
                ),
                onTap: () {
                  GoRouter.of(context).push('/myAccount');
                },
              ),
              InkWell(
                child: ListTile(
                  title: Text('My Courses'),
                  leading: Icon(
                    Icons.assignment,
                    color: HexColor('691EC8'),
                  ),
                ),
                onTap: () {
                  GoRouter.of(context).push('/myCourses');
                },
              ),
              globals.role == 'mentor'
                  ? InkWell(
                      child: ListTile(
                        title: Text('Review Resume'),
                        leading: Icon(
                          Icons.reviews,
                          color: HexColor('691EC8'),
                        ),
                      ),
                      onTap: () {
                        GoRouter.of(context).push('/reviewResume');
                      },
                    )
                  : SizedBox(),
              InkWell(
                child: ListTile(
                  title: Text('Certificates'),
                  leading: Icon(
                    Icons.card_membership_outlined,
                    color: HexColor('6153D3'),
                  ),
                ),
                onTap: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AllCertificateScreen()));
                },
              ),
              globals.role == "mentor"
                  ? InkWell(
                      child: ListTile(
                        title: Text('Admin Quiz Panel'),
                        leading: Icon(
                          Icons.quiz,
                          color: HexColor('691EC8'),
                        ),
                      ),
                      onTap: () {
                        GoRouter.of(context).push('/quizpanel');
                      },
                    )
                  : Container(),

              //Assignments tab for mentors only
              // ref.data() != null && ref.data()!["role"] == 'mentor'
              //     ? InkWell(
              //   child: ListTile(
              //     title: Text('Assignments'),
              //     leading: Icon(
              //       Icons.assignment_ind_outlined,
              //       color: HexColor('691EC8'),
              //     ),
              //   ),
              //   onTap: () {
              //     Navigator.pushNamed(context, '/reviewAssignments');
              //   },
              // )
              //     : Container(),
              // InkWell(
              //   onTap: () {
              //     GoRouter.of(context).push('/paymentHistory');
              //   },
              //   child: ListTile(
              //     title: Text('Payment History'),
              //     leading: Icon(
              //       Icons.payment_rounded,
              //       color: HexColor('691EC8'),
              //     ),
              //   ),
              // ),
              Divider(
                thickness: 2,
              ),
              InkWell(
                child: ListTile(
                  title: Text('Reviews'),
                  leading: Icon(
                    Icons.reviews_rounded,
                    color: HexColor('691EC8'),
                  ),
                ),
                onTap: () {
                  GoRouter.of(context).push('/reviews');
                },
              ),
              // InkWell(
              //   child: ListTile(
              //     title: Text('Share'),
              //     leading: Icon(
              //       Icons.share,
              //       color: HexColor('691EC8'),
              //     ),
              //   ),
              //   onTap: () {
              //     // AppInstalledCount();
              //     String? a = linkMessage.toString();
              //     // ShareExtend.share("share text", a);
              //     ShareExtend.share(a, "text");
              //   },
              // ),
              InkWell(
                child: ListTile(
                  title: Text('Reward  $rewardCount'),
                  leading: Icon(
                    Icons.price_change,
                    color: HexColor('691EC8'),
                  ),
                ),
                onTap: () {},
              ),
              InkWell(
                onTap: () {
                  logOut(context);
                  GoRouter.of(context).pushReplacement('/login');
                  saveLoginState(context);
                },
                child: ListTile(
                  title: Text('LogOut'),
                  leading: Icon(
                    Icons.logout_rounded,
                    color: HexColor('691EC8'),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 10,
            right: 10,
            child: CircleAvatar(
                maxRadius: 16,
                backgroundColor: Colors.white,
                child: Center(
                  child: IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                        size: 12,
                      )),
                )),
          ),
        ],
      ),
    ),
  );
}

// FloatingActionButton floatingButton(BuildContext context) {
//   return FloatingActionButton.extended(
//     backgroundColor: Colors.black54,
//     onPressed: () {
//       GoRouter.of(context).push('/chat');
//     },
//     label: Text('Chat with TA', style: TextStyle(fontSize: 16)),
//     icon: Icon(
//       Icons.chat_bubble_outline_sharp,
//       color: Colors.white,
//       size: 20,
//     ),
//   );
// }
Widget featureCPopup(
    IconData icon, String T1, double horizontalScale, double verticalScale) {
  return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
    if (constraints.maxWidth >= 650) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
          width: 250 * horizontalScale,
          height: 38 * verticalScale,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
            boxShadow: [
              BoxShadow(
                  color: Color.fromRGBO(31, 31, 31, 0.25),
                  offset: Offset(0, 0),
                  blurRadius: 5)
            ],
            color: Color.fromRGBO(255, 255, 255, 1),
          ),
          child: Row(
            children: [
              Container(
                width: 38 * min(horizontalScale, verticalScale),
                height: 38 * min(horizontalScale, verticalScale),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                  color: Color.fromRGBO(54, 141, 255, 1),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 28 * min(horizontalScale, verticalScale),
                  ),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Container(
                // width: 250 * horizontalScale,
                child: Text(
                  '$T1',
                  textScaleFactor: min(horizontalScale, verticalScale),
                  style: TextStyle(
                      overflow: TextOverflow.ellipsis,
                      color: Colors.black,
                      fontSize: 18 * verticalScale,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
          width: 364 * horizontalScale,
          height: 40 * verticalScale,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
            boxShadow: [
              BoxShadow(
                  color: Color.fromRGBO(31, 31, 31, 0.25),
                  offset: Offset(0, 0),
                  blurRadius: 5)
            ],
            color: Color.fromRGBO(255, 255, 255, 1),
          ),
          child: Row(
            children: [
              Container(
                width: 38 * min(horizontalScale, verticalScale),
                height: 38 * min(horizontalScale, verticalScale),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                  color: Color.fromRGBO(54, 141, 255, 1),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 28 * min(horizontalScale, verticalScale),
                  ),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Container(
                // width: 215 * horizontalScale,
                // color: Colors.red,
                child: Text(
                  '$T1',
                  maxLines: 2,
                  textScaleFactor: min(horizontalScale, verticalScale),
                  style: TextStyle(
                      overflow: TextOverflow.ellipsis,
                      color: Colors.black,
                      fontSize: 14 * verticalScale,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );
    }
  });
}

Drawer dr(BuildContext context) {
  void saveLoginState(BuildContext context) {
    Provider.of<LoginState>(context, listen: false).loggedIn = false;
  }

  double height = MediaQuery.of(context).size.height;
  double width = MediaQuery.of(context).size.width;
  return Drawer(
    child: ListView(
      padding: EdgeInsets.only(top: 0),
      children: [
        Container(
            height: height * 0.27,
            //decoration: BoxDecoration(gradient: gradient),
            color: HexColor('7B62DF'),
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection("Users_dataly").snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return const SizedBox.shrink();
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (BuildContext context, index) {
                    DocumentSnapshot document = snapshot.data!.docs[index];
                    Map<String, dynamic> map = snapshot.data!.docs[index].data()
                        as Map<String, dynamic>;
                    if (map["id"].toString() ==
                        FirebaseAuth.instance.currentUser!.uid) {
                      return Padding(
                        padding: EdgeInsets.all(width * 0.05),
                        child: Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: width * 0.089,
                                backgroundImage: AssetImage('assets/user.jpg'),
                              ),
                              SizedBox(
                                height: height * 0.01,
                              ),
                              map['name'] != null
                                  ? Text(
                                      map['name'],
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                          fontSize: width * 0.049),
                                    )
                                  : Text(
                                      map['mobilenumber'],
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                          fontSize: width * 0.049),
                                    ),
                              SizedBox(
                                height: height * 0.007,
                              ),
                              map['email'] != null
                                  ? Text(
                                      map['email'],
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: width * 0.038),
                                    )
                                  : Container(),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return Container();
                    }
                  },
                );
              },
            )),
        InkWell(
          child: ListTile(
            title: Text('Home'),
            leading: Icon(
              Icons.home,
              color: HexColor('6153D3'),
            ),
          ),
          onTap: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => HomePage()));
          },
        ),
        // InkWell(
        //   child: ListTile(
        //     title: Text('My Account'),
        //     leading: Icon(
        //       Icons.person,
        //       color: HexColor('6153D3'),
        //     ),
        //   ),
        // ),
        InkWell(
          child: ListTile(
            title: Text('My Courses'),
            leading: Icon(
              Icons.book,
              color: HexColor('6153D3'),
            ),
          ),
          onTap: () async {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => HomeScreen()));
            print("this is courseID: $courseId");
          },
        ),
        InkWell(
          child: ListTile(
            title: Text('Assignments'),
            leading: Icon(
              Icons.assignment_ind_outlined,
              color: HexColor('6153D3'),
            ),
          ),
          onTap: () {},
        ),
        InkWell(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => PaymentHistory()));
          },
          child: ListTile(
            title: Text('Payment History'),
            leading: Icon(
              Icons.payment_rounded,
              color: HexColor('6153D3'),
            ),
          ),
        ),
        Divider(
          thickness: 2,
        ),
        InkWell(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => PrivacyPolicy()));
          },
          child: ListTile(
            title: Text('Privacy policy'),
            leading: Icon(
              Icons.privacy_tip,
              color: HexColor('6153D3'),
            ),
          ),
        ),
        InkWell(
          child: ListTile(
            title: Text('Certificates'),
            leading: Icon(
              Icons.card_membership_outlined,
              color: HexColor('6153D3'),
            ),
          ),
          onTap: () async {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AllCertificateScreen()));
          },
        ),
        InkWell(
          child: ListTile(
            title: Text('About Us'),
            leading: Icon(
              Icons.info,
              color: HexColor('6153D3'),
            ),
          ),
          onTap: () async {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => AboutUs()));
          },
        ),
        InkWell(
          child: ListTile(
            title: Text('LogOut'),
            leading: Icon(
              Icons.logout,
              color: HexColor('6153D3'),
            ),
          ),
          onTap: () {
            logOut(context);
            saveLoginState(context);
          },
        ),
      ],
    ),
  );
}

Column chat() {
  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(10, 15, 15, 10),
        child: Container(
          width: 300,
          alignment: Alignment.topLeft,
          child: const Text.rich(TextSpan(
              text: 'You can ask assignment related doubts here 6pm- midnight.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black,
                wordSpacing: 1,
              ),
              children: [
                TextSpan(
                    text: '(Indian standard time)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 12,
                      wordSpacing: 5,
                    )),
                TextSpan(
                  text: '\nOur mentors:-',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                    wordSpacing: 5,
                  ),
                ),

                TextSpan(
                    text: '\n6:00pm-7:30pm - Rahul',
                    style: TextStyle(
                      fontSize: 12,
                      height: 2,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      wordSpacing: 5,
                    )),
                TextSpan(
                    text: '\n7:30pm-midnight - Harsh',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      wordSpacing: 2,
                    )),
                TextSpan(
                  text: '\nPowerbi doubt - 11am-12 afternoon',
                  style: TextStyle(
                    color: Colors.black,
                    height: 2,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    wordSpacing: 5,
                  ),
                ),
                TextSpan(
                    text:
                        '\nHow can you learn better?\n -Its a good idea to google once about your doubt and see what stackoverflow suggest and how others solved the same kind of doubt by looking at documentation once.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                      wordSpacing: 5,
                    )),
                // TextSpan(
                //     text: '\nNote : ',
                //     style: TextStyle(
                //       fontSize: 12,
                //       height: 2,
                //       color: Colors.black,
                //       fontWeight: FontWeight.bold,
                //       wordSpacing: 5,
                //     )),
                // TextSpan(
                //     text: '\n1) If you see late response from mentor multiple times',
                //     style: TextStyle(
                //       fontSize: 12,
                //       color: Colors.black,
                //       wordSpacing: 4,
                //     )),
                // TextSpan(
                //     text: 'during 6pm - midnight (more than 5 minutes or max more than 10 minutes )',
                //     style: TextStyle(
                //       fontSize: 12,
                //       fontWeight: FontWeight.bold,
                //       color: Colors.black,
                //       wordSpacing: 5,
                //     )),
                //     TextSpan(
                //     text: ' then tag me and raise the concern.',
                //     style: TextStyle(
                //       fontSize: 12,
                //       color: Colors.black,
                //       wordSpacing: 4,
                //     )),
                //     TextSpan(
                //     text: '\n2) Assignments are self evaluated. After submission, theres a solution link provided, go through it and self evaluate.',
                //     style: TextStyle(
                //       fontSize: 12,
                //       color: Colors.black,
                //       wordSpacing: 4,
                //     )),
              ])),
        ),
      ),
    ],
  );
}
