import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloudyml_app2/combo/combo_store.dart';
import 'package:cloudyml_app2/fun.dart';
import 'package:cloudyml_app2/globals.dart';
import 'package:cloudyml_app2/models/course_details.dart';
import 'package:cloudyml_app2/router/login_state_check.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:star_rating/star_rating.dart';
import '../global_variable.dart' as globals;
import 'authentication/firebase_auth.dart';
import 'models/user_details.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({Key? key}) : super(key: key);

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  var textStyle = TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.white,
    fontSize: 14,
    fontFamily: "Semibold",
  );

  var path = Uri.base.path;
  String? currentPath;

  function() {
    setState(() {
      path;
    });
  }

  @override
  void initState() {
    print('path is  $path');
    super.initState();
    function();
  }

  @override
  Widget build(BuildContext context) {
    void saveLoginOutState(BuildContext context) {
      Provider.of<LoginState>(context, listen: false).loggedIn = false;
    }

    List<CourseDetails> courseList = Provider.of<List<CourseDetails>>(context);

    List<CourseDetails> course = [];
    List<dynamic> courseToRemove = [];
    var cou = [];
    bool everycourseispurchased = false;
    UserDetails? userCourse = Provider.of<UserDetails?>(context, listen: true);
    print("hhhhhhhhhhhhhhhhh");
    print("course list: ${courseList}");

    for (CourseDetails element in courseList) {
      print("show${element.show}");
      print(userCourse);
      print(userCourse?.paidCoursesId);

      // logic for showing if complete courses has been taken or not
      try {
        for (var i in userCourse!.paidCoursesId) {
          if (i == element.courseId) {
            courseToRemove.add(i);
          }
          if (i == element.courseId) {
            if (element.isItComboCourse) {
              courseToRemove = courseToRemove + element.courses;
            }
          }
        }
      } catch (e) {}
    }
    try {
      course = courseList;
      var valuedata = [];
      courseList.forEach((element) {
        courseToRemove.forEach((i) {
          if (element.courseId == i) {
            valuedata.add(element);
          }
        });
      });

      print("startdddddddddddddddd");
      //logic for removing
      var set1 = Set.from(course);
      var set2 = Set.from(valuedata);
      setState(() {
        course = List.from(set1.difference(set2));
        if (course == []) {
          everycourseispurchased = true;
        }
        print("sfjdsdjflsdfls$course");
      });

      //logic for show parameter

      for (var i in course) {
        try {
          if (i.show == true) {
            cou.add(i);
          }
        } catch (e) {
          print("uiooiio${e.toString()}");
        }
      }
    } catch (e) {
      print("tttttttttttttttttt${e.toString()}");
    }

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    var verticalScale = screenHeight / mockUpHeight;
    var horizontalScale = screenWidth / mockUpWidth;

    return Scaffold(
      // key: _scaffoldKey,
      // drawer: customDrawer(context),
      body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth >= 515) {
          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: screenWidth,
                  height: 60,
                  color: HexColor("440F87"),
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
                                  color: HexColor('873AFF'),
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
                                color: Colors.white,
                              ),
                            )),
                        SizedBox(
                          width: horizontalScale * 10,
                        ),
                        // TextButton(
                        //     onPressed: () {
                        //       GoRouter.of(context).pushNamed('LiveDoubtSession');
                        //     },
                        //     child: Text(
                        //       'Live Doubt Support',
                        //       style:  buttonTextStyle.copyWith(
                        //         color:
                        //         Uri.base.path == '/LiveDoubtScreen'? HexColor('873AFF') :
                        //         Colors.white ,
                        //       ),
                        //     )),
                        // SizedBox(
                        //   width: horizontalScale * 15,
                        // ),
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
                                color: Colors.white,
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
                                } else if (value == 'My Profile') {
                                  GoRouter.of(context)
                                      .pushReplacementNamed('myAccount');
                                } else if (value == 'My Quizzes') {
                                  GoRouter.of(context)
                                      .pushReplacementNamed('quizes');
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
                  ),

                  // Row(
                  //   children: [
                  //     IconButton(
                  //         onPressed: () {
                  //           Scaffold.of(context).openDrawer();
                  //         },
                  //         icon: Icon(
                  //           Icons.menu,
                  //           color: Colors.white,
                  //         )),
                  //     SizedBox(
                  //       width: horizontalScale * 15,
                  //     ),
                  //     Image.asset(
                  //       "assets/logo2.png",
                  //       width: 30,
                  //       height: 30,
                  //     ),
                  //     Text(
                  //       "CloudyML",
                  //       style: textStyle,
                  //     ),
                  //     SizedBox(
                  //       width: horizontalScale * 25,
                  //     ),
                  //     // SizedBox(
                  //     //   height: 30,
                  //     //   width: screenWidth / 3,
                  //     //   child: TextField(
                  //     //     style: TextStyle(
                  //     //         color: HexColor("A7A7A7"), fontSize: 12),
                  //     //     decoration: InputDecoration(
                  //     //         contentPadding: EdgeInsets.all(5.0),
                  //     //         hintText: "Search Courses",
                  //     //         focusedBorder: OutlineInputBorder(
                  //     //             borderSide: BorderSide(
                  //     //                 color: Colors.white, width: 1)),
                  //     //         disabledBorder: OutlineInputBorder(
                  //     //             borderSide: BorderSide(
                  //     //                 color: Colors.white, width: 1)),
                  //     //         hintStyle: TextStyle(
                  //     //             color: HexColor("A7A7A7"), fontSize: 12),
                  //     //         border: OutlineInputBorder(
                  //     //             borderSide: BorderSide(
                  //     //                 color: Colors.white, width: 1)),
                  //     //         enabledBorder: OutlineInputBorder(
                  //     //             borderSide: BorderSide(
                  //     //                 color: Colors.white, width: 1)),
                  //     //         prefixIcon: IconButton(
                  //     //             onPressed: () {},
                  //     //             icon: Icon(
                  //     //               Icons.search_outlined,
                  //     //               size: 14,
                  //     //               color: Colors.white,
                  //     //             ))),
                  //     //   ),
                  //     // )
                  //   ],
                  // ),
                ),
                Container(
                  width: screenWidth,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 60.0, top: 20, bottom: 20),
                        child: Column(
                          children: [
                            Container(
                              width: horizontalScale * 200,
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Text("Explore our hands on",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'SemiBold',
                                      color: HexColor("000000"),
                                      fontSize: 26,
                                    )),
                              ),
                            ),
                            Container(
                              width: horizontalScale * 200,
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Text("Learning courses 🔥🔥🔥",
                                    style: TextStyle(
                                      color: HexColor("000000"),
                                      fontFamily: 'SemiBold',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 26,
                                    )),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Container(width: horizontalScale * ,),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          padding: EdgeInsets.only(right: 60),
                          width: horizontalScale * 180,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                  "Our Courses comes with Lifetime access, Live",
                                  style: TextStyle(
                                    color: HexColor("000000"),
                                    fontSize: 14,
                                  )),
                              Text("chat support & internship opportunity.",
                                  style: TextStyle(
                                    color: HexColor("000000"),
                                    fontSize: 14,
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 60.0, right: 60),
                  child: Divider(
                    thickness: 2,
                  ),
                ),
                Container(
                    height: MediaQuery.of(context).size.height,
                    padding: const EdgeInsets.only(right: 15.0, left: 15.0),
                    child: GridView.builder(
                      scrollDirection: Axis.vertical,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: constraints.maxWidth <= 750
                            ? 2
                            : constraints.maxWidth <= 1050
                                ? 3
                                : constraints.maxWidth >= 1050
                                    ? 4
                                    : 4,
                        childAspectRatio: constraints.maxWidth <= 750
                            ? 1
                            : constraints.maxWidth <= 1050
                                ? 0.8
                                : constraints.maxWidth >= 1050
                                    ? 0.85
                                    : 1,
                        crossAxisSpacing: constraints.maxWidth >= 900 ? 15 : 10,
                      ),
                      itemCount: cou.length,
                      itemBuilder: (context, index) {
                        if (cou[index].courseName == "null") {
                          return Container(
                            child: Text('This is a container'),
                          );
                        }
                        if (cou[index].show == true)
                          return GestureDetector(
                              onTap: () {
                                setState(() {
                                  courseId = cou[index].courseDocumentId;
                                });
                                print(courseId);
                                if (cou[index].isItComboCourse) {
                                  final id = index.toString();
                                  final cID = cou[index].courseDocumentId;
                                  final courseName = cou[index].courseName;
                                  final courseP = cou[index].coursePrice;
                                  // GoRouter.of(context).pushNamed('comboStore',
                                  //     queryParams: {
                                  //       'courseName': courseName,
                                  //       'id': id,
                                  //       'coursePrice': courseP});

                                  GoRouter.of(context).pushNamed('NewFeature',
                                      queryParams: {
                                        'cID': cID,
                                        'courseName': courseName,
                                        'id': id,
                                        'coursePrice': courseP
                                      });

                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //     builder: (context) =>
                                  //         ComboStore(
                                  //           courses:
                                  //           course[index].courses,
                                  //         ),
                                  //   ),
                                  // );
                                } else if (cou[index].multiCombo == true) {
                                  GoRouter.of(context).pushReplacementNamed(
                                      'multiComboFeatureScreen',
                                      queryParams: {
                                        'cID': cou[index].courseDocumentId,
                                        'courseName': cou[index].courseName,
                                        'id': cou[index].courseId,
                                        'coursePrice': cou[index].coursePrice
                                      });
                                } else {
                                  final id = index.toString();
                                  GoRouter.of(context)
                                      .pushNamed('catalogue', queryParams: {
                                    'id': id,
                                    'cID': courseId,
                                  });
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                        width: 0.5, color: HexColor("440F87")),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: constraints.maxWidth >= 900
                                            ? screenHeight / 4.5
                                            : screenHeight / 5,
                                        width: screenWidth,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(15),
                                              topRight: Radius.circular(15)),
                                          child: CachedNetworkImage(
                                            placeholder: (context, url) => Center(
                                                child:
                                                    CircularProgressIndicator()),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Icon(Icons.error),
                                            imageUrl: cou[index].courseImageUrl,
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: screenWidth,
                                        color: Colors.purpleAccent.shade100,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: 2 * horizontalScale,
                                            ),
                                            Text(
                                              cou[index].reviews.isNotEmpty
                                                  ? cou[index].reviews
                                                  : '5.0',
                                              style: TextStyle(
                                                  fontSize: 14 * verticalScale,
                                                  color: HexColor('440F87'),
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(
                                              width: 3 * horizontalScale,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 5.0),
                                              child: StarRating(
                                                length: 5,
                                                rating: cou[index]
                                                        .reviews
                                                        .isNotEmpty
                                                    ? double.parse(
                                                        cou[index].reviews)
                                                    : 5.0,
                                                color: Colors.green,
                                                // HexColor('440F87'),
                                                starSize: 20,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        height: 35,
                                        padding: EdgeInsets.only(
                                            left: 8, right: 8, top: 4),
                                        width: screenWidth,
                                        child: Text(
                                          cou[index].courseName,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontFamily: 'Medium',
                                            fontSize: 14 * verticalScale,
                                            height: 0.95,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: verticalScale * 50,
                                        width: screenWidth,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 15),
                                          child: Column(
                                            children: [
                                              // Align(
                                              //   alignment: Alignment.topLeft,
                                              //   child: Text(
                                              //     course[index].courseName,
                                              //     maxLines: 2,
                                              //     overflow: TextOverflow.ellipsis,
                                              //     style: TextStyle(
                                              //       color: Colors.black,
                                              //       fontFamily: 'Medium',
                                              //       fontSize: 12,
                                              //       height: 0.95,
                                              //       fontWeight: FontWeight.bold,),
                                              //   ),
                                              // ),
                                              SizedBox(
                                                height: verticalScale * 5,
                                              ),
                                              Align(
                                                alignment: Alignment.topLeft,
                                                child: Text(
                                                  "- ${cou[index].numOfVideos} Videos",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black,
                                                      fontSize:
                                                          12 * verticalScale),
                                                ),
                                              ),
                                              Align(
                                                alignment: Alignment.topLeft,
                                                child: Text(
                                                  "- Lifetime Access",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black,
                                                      fontSize:
                                                          12 * verticalScale),
                                                ),
                                              ),
                                              SizedBox(
                                                height: verticalScale * 5,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: Container(
                                          height: verticalScale * 30,
                                          width: screenWidth / 8,
                                          child: ElevatedButton(
                                              onPressed: () {
                                                setState(() {
                                                  courseId = cou[index]
                                                      .courseDocumentId;
                                                });
                                                print(courseId);
                                                if (cou[index]
                                                    .isItComboCourse) {
                                                  final id = index.toString();
                                                  final cID = cou[index]
                                                      .courseDocumentId;
                                                  final courseName =
                                                      cou[index].courseName;
                                                  final courseP =
                                                      cou[index].coursePrice;
                                                  // GoRouter.of(context).pushNamed('comboStore',
                                                  //     queryParams: {
                                                  //       'courseName': courseName,
                                                  //       'id': id,
                                                  //       'coursePrice': courseP});

                                                  GoRouter.of(context)
                                                      .pushNamed('NewFeature',
                                                          queryParams: {
                                                        'cID': cID,
                                                        'courseName':
                                                            courseName,
                                                        'id': id,
                                                        'coursePrice': courseP
                                                      });

                                                  // Navigator.push(
                                                  //   context,
                                                  //   MaterialPageRoute(
                                                  //     builder: (context) =>
                                                  //         ComboStore(
                                                  //           courses:
                                                  //           course[index].courses,
                                                  //         ),
                                                  //   ),
                                                  // );
                                                } else if (cou[index]
                                                        .multiCombo ==
                                                    true) {
                                                  GoRouter.of(context)
                                                      .pushReplacementNamed(
                                                          'multiComboFeatureScreen',
                                                          queryParams: {
                                                        'cID': cou[index]
                                                            .courseDocumentId,
                                                        'courseName': cou[index]
                                                            .courseName,
                                                        'id':
                                                            cou[index].courseId,
                                                        'coursePrice':
                                                            cou[index]
                                                                .coursePrice
                                                      });
                                                } else {
                                                  final id = index.toString();
                                                  GoRouter.of(context)
                                                      .pushNamed('catalogue',
                                                          queryParams: {
                                                        'id': id,
                                                        'cID': courseId,
                                                      });
                                                }
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    HexColor("8346E1"),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5)),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  "Enroll Now",
                                                  style: TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              )),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ));
                        return Container();
                      },
                    )),
              ],
            ),
          );
        } else {
          return Container(
            color: Colors.deepPurple,
            child: Stack(children: [
              Positioned(
                // left: -50,
                // width: 100,
                // height: 100,
                top: -98.00000762939453,
                left: -88.00000762939453,
                // child: CircleAvatar(
                //   radius: 70,
                //   backgroundColor: Color.fromARGB(255, 173, 149, 149),
                // ),
                child: Container(
                    width: 161.99998474121094,
                    height: 161.99998474121094,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(55, 126, 106, 228),
                      borderRadius: BorderRadius.all(Radius.elliptical(
                          161.99998474121094, 161.99998474121094)),
                    )),
              ),
              Positioned(
                // right: MediaQuery.of(context).size.width * (-.16),
                // bottom: MediaQuery.of(context).size.height * .7,
                top: 73.00000762939453,
                left: 309,

                // child: CircleAvatar(
                //   radius: 80,
                //   backgroundColor: Color.fromARGB(255, 173, 149, 149),
                // ),
                child: Container(
                    width: 161.99998474121094,
                    height: 161.99998474121094,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(55, 126, 106, 228),
                      borderRadius: BorderRadius.all(Radius.elliptical(
                          161.99998474121094, 161.99998474121094)),
                    )),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                //color: Color.fromARGB(214, 83, 109, 254),
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.08,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 30),
                      child: Row(
                        children: [
                          // IconButton(
                          //   onPressed: () {
                          //     print("yyy");
                          //     Navigator.push(
                          //       context,
                          //       MaterialPageRoute(
                          //           builder: (context) => HomePage()),
                          //     );
                          //     // Scaffold.of(context).openDrawer();
                          //   },
                          //   icon: Icon(
                          //     Icons.arrow_back,
                          //     size: 40,
                          //     color: Colors.white,
                          //   ),
                          // ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.17,
                          ),
                          Text(
                            'Store',
                            style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.06,
                    ),
                    !everycourseispurchased
                        ? Expanded(
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height,
                              decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(40),
                                      topRight: Radius.circular(40)),
                                  color: Colors.white),
                              child: MediaQuery.removePadding(
                                context: context,
                                removeTop: true,
                                child: GridView.builder(
                                    gridDelegate:
                                        SliverGridDelegateWithMaxCrossAxisExtent(
                                            maxCrossAxisExtent:
                                                MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    .5,
                                            childAspectRatio: .67),
                                    itemCount: cou.length,
                                    itemBuilder: (context, index) {
                                      print(cou);
                                      print(cou.length);
                                      print(index);
                                      return InkWell(
                                        onTap: () {
                                          setState(() {
                                            courseId =
                                                cou[index].courseDocumentId;
                                          });

                                          print(courseId);
                                          if (cou[index].isItComboCourse) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ComboStore(
                                                  courses: cou[index].courses,
                                                ),
                                              ),
                                            );
                                          } else if (cou[index].multiCombo ==
                                              true) {
                                            GoRouter.of(context)
                                                .pushReplacementNamed(
                                                    'multiComboFeatureScreen',
                                                    queryParams: {
                                                  'cID': cou[index]
                                                      .courseDocumentId,
                                                  'courseName':
                                                      cou[index].courseName,
                                                  'id': cou[index].courseId,
                                                  'coursePrice':
                                                      cou[index].coursePrice
                                                });
                                          } else if (cou[index].free == true ||
                                              cou[index].free != null) {
                                            // Navigator.push(context, MaterialPageRoute(builder: (context) => FreeCourseScreen(),));
                                          } else {
                                            // Navigator.push(
                                            //   context,
                                            //   MaterialPageRoute(
                                            //       builder: (context) =>
                                            //       const CatelogueScreen()),
                                            // );

                                            final id = index.toString();
                                            GoRouter.of(context).pushNamed(
                                                'catalogue',
                                                queryParams: {
                                                  'id': id,
                                                  'cID': courseId,
                                                });
                                          }
                                        },
                                        child: Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              3,
                                          margin: EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            color: Color.fromARGB(
                                                192, 255, 255, 255),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Color.fromRGBO(168, 133,
                                                    250, 0.7099999785423279),
                                                offset: Offset(2, 2),
                                                blurRadius: 5,
                                              )
                                            ],
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(08.0),
                                            child: Column(
                                              //mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                    child: CachedNetworkImage(
                                                      imageUrl: cou[index]
                                                          .courseImageUrl,
                                                      placeholder: (context,
                                                              url) =>
                                                          // CircularProgressIndicator(),
                                                          Container(
                                                        child: Image(
                                                          // height: MediaQuery.of(context).size.height / 3,
                                                          // fit: BoxFit.cover,
                                                          image: AssetImage(
                                                              'assets/new.jpg'),
                                                        ),
                                                      ),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          Icon(Icons.error),
                                                      fit: BoxFit.cover,
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              .15,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              .4,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Container(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      .07,
                                                  child: Text(
                                                    cou[index].courseName,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            .030),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      .004,
                                                ),
                                                Row(
                                                  // mainAxisAlignment:
                                                  //     MainAxisAlignment
                                                  //         .center,
                                                  children: [
                                                    Text(
                                                      cou[index].courseLanguage,
                                                      style: TextStyle(
                                                          fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              .03),
                                                    ),
                                                    SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              .02,
                                                    ),
                                                    Text(
                                                      '||',
                                                      style: TextStyle(
                                                          fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              .03),
                                                    ),
                                                    SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              .02,
                                                    ),
                                                    Text(
                                                      cou[index].numOfVideos,
                                                      style: TextStyle(
                                                          fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              .03),
                                                    ),
                                                    // const SizedBox(
                                                    //   height: 10,
                                                    // ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      .015,
                                                ),
                                                // Row(
                                                //   children: [
                                                //     Container(
                                                //       width:
                                                //           MediaQuery.of(context)
                                                //                   .size
                                                //                   .width *
                                                //               0.20,
                                                //       height:
                                                //           MediaQuery.of(context)
                                                //                   .size
                                                //                   .height *
                                                //               0.030,
                                                //       decoration: BoxDecoration(
                                                //           borderRadius:
                                                //               BorderRadius
                                                //                   .circular(10),
                                                //           color: Colors.green),
                                                //       child: const Center(
                                                //         child: Text(
                                                //           'ENROLL NOW',
                                                //           style: TextStyle(
                                                //               fontSize: 10,
                                                //               color:
                                                //                   Colors.white),
                                                //         ),
                                                //       ),
                                                //     ),
                                                //     const SizedBox(
                                                //       width: 15,
                                                //     ),
                                                //     Text(
                                                //       map['Course Price'],
                                                //       style: const TextStyle(
                                                //         fontSize: 13,
                                                //         color: Colors.indigo,
                                                //         fontWeight:
                                                //             FontWeight.bold,
                                                //       ),
                                                //     ),
                                                //   ],
                                                // ),
                                                Row(
                                                  children: [
                                                    // SizedBox(
                                                    //     width: MediaQuery.of(
                                                    //         context)
                                                    //         .size
                                                    //         .width *
                                                    //         .23),
                                                    Text(
                                                      '₹${cou[index].coursePrice}',
                                                      style: TextStyle(
                                                        fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            .03,
                                                        color: Colors.indigo,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                              ),
                            ),
                          )
                        : Center(
                            child: Container(
                              padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                              child: Text(
                                "You have already purchased all the courses,"
                                "\nAny newly added course will start showing here, "
                                "\nHappy Learning",
                                style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ]),
          );
        }
      }),
    );
  }
}
