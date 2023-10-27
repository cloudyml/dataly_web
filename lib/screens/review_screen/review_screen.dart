import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloudyml_app2/api/firebase_api.dart';
import 'package:cloudyml_app2/fun.dart';
import 'package:cloudyml_app2/screens/student_review/review_screen.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:flutter/material.dart';
import 'package:cloudyml_app2/models/firebase_file.dart';
import 'package:cloudyml_app2/globals.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../authentication/firebase_auth.dart';
import '../../router/login_state_check.dart';
import '/global_variable.dart' as globals;

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({Key? key}) : super(key: key);

  @override
  State<ReviewsScreen> createState() => _Review1State();
}

class _Review1State extends State<ReviewsScreen> {
  late Future<List<FirebaseFile>> futurefilesRecentReviews;
  late Future<List<FirebaseFile>> futurefilesComboCourseReviews;
  late Future<List<FirebaseFile>> futurefilesSocialMediaReviews;
  bool reviewType = true;
  @override
  void initState() {
    super.initState();
    futurefilesRecentReviews =
        FirebaseApi.listAll('reviews_dataly/recent_review');
    futurefilesComboCourseReviews =
        FirebaseApi.listAll('reviews_dataly/combo_course_review');
    futurefilesSocialMediaReviews =
        FirebaseApi.listAll('reviews_dataly/social_media_review');
  }

  @override
  Widget build(BuildContext context) {
    void saveLoginOutState(BuildContext context) {
      Provider.of<LoginState>(context, listen: false).loggedIn = false;
    }

    final size = MediaQuery.of(context).size;
    final width = size.width;
    final containerWidth = 300.0;
    final containerHeight = 300.0;
    double height = MediaQuery.of(context).size.height;
    var verticalScale = height / mockUpHeight;
    var horizontalScale = width / mockUpWidth;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: screenWidth,
                  height: 60,
                  color: HexColor("440F87"),
                  child: Center(
                      child: Padding(
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
                          child: SizedBox(
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
                        ),
                        Spacer(),
                        TextButton(
                            onPressed: () {
                              GoRouter.of(context).pushNamed('home');
                            },
                            child: Text(
                              'Home',
                              style: buttonTextStyle.copyWith(
                                color: Colors.white,
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
                                  color: Colors.white,
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
                                color: HexColor('873AFF'),
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
                                    color: Colors.white,
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
                                  GoRouter.of(context)
                                      .pushReplacementNamed('myCourses');
                                } else if (value == 'Resume Review') {
                                  GoRouter.of(context)
                                      .pushReplacementNamed('reviewResume');
                                } else if (value == 'Admin Quiz Panel') {
                                  GoRouter.of(context)
                                      .pushReplacementNamed('quizpanel');
                                } else if (value == 'Assignment Review') {
                                  GoRouter.of(context).pushReplacementNamed(
                                      'AssignmentScreenForMentors');
                                } else if (value == 'My Quizzes') {
                                  GoRouter.of(context)
                                      .pushReplacementNamed('quizes');
                                } else if (value == 'My Profile') {
                                  GoRouter.of(context)
                                      .pushReplacementNamed('myAccount');
                                } else if (value == 'Logout') {
                                  logOut(context);
                                  saveLoginOutState(context);
                                  GoRouter.of(context)
                                      .pushReplacement('/login');
                                } else {
                                  Fluttertoast.showToast(
                                      msg: 'Please refresh the screen.');
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
                  )),
                ),
                SizedBox(
                  height: 25 * verticalScale,
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: width / 50,
                  ),
                  child: Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Review Type:',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w400),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      FaIcon(
                        FontAwesomeIcons.image,
                        color: !reviewType ? Colors.deepPurpleAccent : null,
                      ),
                      Switch(
                        value: reviewType,
                        onChanged: (v) {
                          setState(() {
                            reviewType = v;
                          });
                        },
                        activeColor: Colors.deepPurpleAccent,
                        // trackColor: MaterialStatePropertyAll(
                        //     Colors.grey),
                        // thumbColor:
                        // MaterialStatePropertyAll(Colors.deepPurpleAccent),
                      ),
                      FaIcon(FontAwesomeIcons.noteSticky,
                          color: reviewType ? Colors.deepPurpleAccent : null)
                    ],
                  ),
                ),
                reviewType
                    ? StudentReviewScreen()
                    : Column(
                        children: [
                          Container(
                            width: 414 * horizontalScale,
                            height: 125 * verticalScale,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                                HexColor('8346E1'),
                                HexColor('411487'),
                              ]),
                            ),
                            child: Center(
                                child: Text(
                              '🤞 Our Learner\'s review speaks 🤞',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: HexColor('FFFFFF'),
                                fontSize: 38 * verticalScale,
                              ),
                            )),
                          ),

                          SizedBox(
                            height: 25,
                          ),
                          Container(
                            // height: screenHeight * 0.81 * verticalScale,
                            height: containerHeight,
                            width: screenWidth,
                            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                            child: FutureBuilder<List<FirebaseFile>>(
                              future: futurefilesRecentReviews,
                              builder: (context, snapshot) {
                                switch (snapshot.connectionState) {
                                  case ConnectionState.waiting:
                                    return Center(
                                        child: CircularProgressIndicator());
                                  default:
                                    if (snapshot.hasError) {
                                      return Center(
                                          child: Text(
                                        'Some error occurred!',
                                        textScaleFactor:
                                            min(horizontalScale, verticalScale),
                                      ));
                                    } else {
                                      final files = snapshot.data!;
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              // physics: NeverScrollableScrollPhysics(),
                                              itemCount: files.length,
                                              itemBuilder: (context, index) {
                                                final file = files[index];
                                                return Container(
                                                    decoration: BoxDecoration(
                                                        color:
                                                            HexColor("#FFFFFF"),
                                                        // borderRadius: BorderRadius.circular(15),
                                                        border: Border.all(
                                                          color: Colors.black,
                                                          width: 0.5,
                                                        ),
                                                        boxShadow: [
                                                          BoxShadow(
                                                              color:
                                                                  Colors.grey,
                                                              blurRadius: 5,
                                                              offset:
                                                                  Offset(0, 1))
                                                        ]),
                                                    margin: EdgeInsets.only(
                                                        left: 15,
                                                        top: 5,
                                                        bottom: 5),
                                                    padding: EdgeInsets.only(
                                                        left: 5,
                                                        right: 5,
                                                        top: 5,
                                                        bottom: 5),
                                                    width: containerWidth,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                      child: InkWell(
                                                        onTap: () {
                                                          showDialog(
                                                              context: context,
                                                              builder: (context) =>
                                                                  GestureDetector(
                                                                      onTap: () =>
                                                                          Navigator.pop(
                                                                              context),
                                                                      child:
                                                                          Container(
                                                                        alignment:
                                                                            Alignment.center,
                                                                        color: Colors
                                                                            .transparent,
                                                                        height:
                                                                            400,
                                                                        width:
                                                                            300,
                                                                        child:
                                                                            AlertDialog(
                                                                          shape: RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.circular(15.0),
                                                                              side: BorderSide.none),
                                                                          scrollable:
                                                                              true,
                                                                          content:
                                                                              Container(
                                                                            height:
                                                                                500,
                                                                            width:
                                                                                500,
                                                                            child:
                                                                                ClipRRect(
                                                                              borderRadius: BorderRadius.circular(20),
                                                                              child: CachedNetworkImage(
                                                                                errorWidget: (context, url, error) => Icon(Icons.error),
                                                                                imageUrl: file.url,
                                                                                fit: BoxFit.fill,
                                                                                placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      )));
                                                        },
                                                        child:
                                                            CachedNetworkImage(
                                                          placeholder: (context,
                                                                  url) =>
                                                              Center(
                                                                  child:
                                                                      CircularProgressIndicator()),
                                                          errorWidget: (context,
                                                                  url, error) =>
                                                              Icon(Icons.error),
                                                          imageUrl: file.url,
                                                          fit: BoxFit.fill,
                                                        ),
                                                      ),
                                                    ));
                                                // buildFile(context, file);
                                              },
                                            ),
                                          ),
                                        ],
                                      );
                                    }
                                }
                              },
                            ),
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          Container(
                            height: containerHeight,
                            width: screenWidth,
                            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                            child: FutureBuilder<List<FirebaseFile>>(
                              future: futurefilesComboCourseReviews,
                              builder: (context, snapshot) {
                                switch (snapshot.connectionState) {
                                  case ConnectionState.waiting:
                                    return Center(
                                        child: CircularProgressIndicator());
                                  default:
                                    if (snapshot.hasError) {
                                      return Center(
                                          child: Text(
                                        'Some error occurred!',
                                        textScaleFactor:
                                            min(horizontalScale, verticalScale),
                                      ));
                                    } else {
                                      final files = snapshot.data!;
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              // physics: NeverScrollableScrollPhysics(),
                                              itemCount: files.length,
                                              itemBuilder: (context, index) {
                                                final file = files[index];
                                                print('object == ${files.isEmpty}');
                                                return Container(
                                                    decoration: BoxDecoration(
                                                        color:
                                                            HexColor("#FFFFFF"),
                                                        border: Border.all(
                                                          color: Colors.black,
                                                          width: 0.5,
                                                        ),
                                                        // borderRadius: BorderRadius.circular(15),
                                                        boxShadow: [
                                                          BoxShadow(
                                                              color:
                                                                  Colors.grey,
                                                              blurRadius: 5,
                                                              offset:
                                                                  Offset(0, 1))
                                                        ]),
                                                    margin: EdgeInsets.only(
                                                        left: 15,
                                                        top: 5,
                                                        bottom: 5),
                                                    padding: EdgeInsets.only(
                                                        left: 5,
                                                        right: 5,
                                                        top: 5,
                                                        bottom: 5),
                                                    width: containerWidth,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                      child: InkWell(
                                                        onTap: () {
                                                          showDialog(
                                                              context: context,
                                                              builder: (context) =>
                                                                  GestureDetector(
                                                                      onTap: () =>
                                                                          Navigator.pop(
                                                                              context),
                                                                      child:
                                                                          Container(
                                                                        alignment:
                                                                            Alignment.center,
                                                                        color: Colors
                                                                            .transparent,
                                                                        height:
                                                                            400,
                                                                        width:
                                                                            300,
                                                                        child:
                                                                            AlertDialog(
                                                                          shape: RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.circular(15.0),
                                                                              side: BorderSide.none),
                                                                          scrollable:
                                                                              true,
                                                                          content:
                                                                              Container(
                                                                            height:
                                                                                500,
                                                                            width:
                                                                                500,
                                                                            child:
                                                                                ClipRRect(
                                                                              borderRadius: BorderRadius.circular(20),
                                                                              child: CachedNetworkImage(
                                                                                errorWidget: (context, url, error) => Icon(Icons.error),
                                                                                imageUrl: file.url,
                                                                                fit: BoxFit.fill,
                                                                                placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      )));
                                                        },
                                                        child:
                                                            CachedNetworkImage(
                                                          placeholder: (context,
                                                                  url) =>
                                                              Center(
                                                                  child:
                                                                      CircularProgressIndicator()),
                                                          errorWidget: (context,
                                                                  url, error) =>
                                                              Icon(Icons.error),
                                                          imageUrl: file.url,
                                                          fit: BoxFit.fill,
                                                        ),
                                                      ),
                                                    ));
                                              },
                                            ),
                                          ),
                                        ],
                                      );
                                    }
                                }
                              },
                            ),
                          ),
                          SizedBox(height: 25),
                          Container(
                            height: containerHeight,
                            width: screenWidth,
                            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                            child: FutureBuilder<List<FirebaseFile>>(
                              future: futurefilesSocialMediaReviews,
                              builder: (context, snapshot) {
                                switch (snapshot.connectionState) {
                                  case ConnectionState.waiting:
                                    return Center(
                                        child: CircularProgressIndicator());
                                  default:
                                    if (snapshot.hasError) {
                                      return Center(
                                          child: Text(
                                        'Some error occurred!',
                                        textScaleFactor:
                                            min(horizontalScale, verticalScale),
                                      ));
                                    } else {
                                      final files = snapshot.data!;
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              // physics: NeverScrollableScrollPhysics(),
                                              itemCount: files.length,
                                              itemBuilder: (context, index) {
                                                final file = files[index];
                                                return Container(
                                                    decoration: BoxDecoration(
                                                        color:
                                                            HexColor("#FFFFFF"),
                                                        border: Border.all(
                                                          color: Colors.black,
                                                          width: 0.5,
                                                        ),
                                                        // borderRadius: BorderRadius.circular(15),
                                                        boxShadow: [
                                                          BoxShadow(
                                                              color:
                                                                  Colors.grey,
                                                              blurRadius: 5,
                                                              offset:
                                                                  Offset(0, 1))
                                                        ]),
                                                    margin: EdgeInsets.only(
                                                        left: 15,
                                                        top: 5,
                                                        bottom: 5),
                                                    padding: EdgeInsets.only(
                                                        left: 5,
                                                        right: 5,
                                                        top: 5,
                                                        bottom: 5),
                                                    width: containerWidth,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                      child: InkWell(
                                                        onTap: () {
                                                          showDialog(
                                                              context: context,
                                                              builder: (context) =>
                                                                  GestureDetector(
                                                                      onTap: () =>
                                                                          Navigator.pop(
                                                                              context),
                                                                      child:
                                                                          Container(
                                                                        alignment:
                                                                            Alignment.center,
                                                                        color: Colors
                                                                            .transparent,
                                                                        height:
                                                                            400,
                                                                        width:
                                                                            300,
                                                                        child:
                                                                            AlertDialog(
                                                                          shape: RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.circular(15.0),
                                                                              side: BorderSide.none),
                                                                          scrollable:
                                                                              true,
                                                                          content:
                                                                              Container(
                                                                            height:
                                                                                500,
                                                                            width:
                                                                                500,
                                                                            child:
                                                                                ClipRRect(
                                                                              borderRadius: BorderRadius.circular(20),
                                                                              child: CachedNetworkImage(
                                                                                errorWidget: (context, url, error) => Icon(Icons.error),
                                                                                imageUrl: file.url,
                                                                                fit: BoxFit.fill,
                                                                                placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      )));
                                                        },
                                                        child:
                                                            CachedNetworkImage(
                                                          placeholder: (context,
                                                                  url) =>
                                                              Center(
                                                                  child:
                                                                      CircularProgressIndicator()),
                                                          errorWidget: (context,
                                                                  url, error) =>
                                                              Icon(Icons.error),
                                                          imageUrl: file.url,
                                                          fit: BoxFit.fill,
                                                        ),
                                                      ),
                                                    ));
                                                // buildFile(context, file);
                                              },
                                            ),
                                          ),
                                        ],
                                      );
                                    }
                                }
                              },
                            ),
                          ),
                          SizedBox(
                            height: 25 * verticalScale,
                          )
                        ],
                      )
              ],
            ),
          );
        } else {
          return StudentReviewScreen();
        }
      }),
    );
  }
}
