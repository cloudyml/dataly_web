import 'package:cloudyml_app2/global_variable.dart';
import 'package:cloudyml_app2/screens/student_review/ReviewApi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart';
import 'package:toast/toast.dart';

class PostReviewScreen extends StatefulWidget {
  @override
  State<PostReviewScreen> createState() => _PostReviewScreenState();
}

class _PostReviewScreenState extends State<PostReviewScreen> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _courseController = TextEditingController();
  TextEditingController _linkdinlinkController = TextEditingController();
  TextEditingController _reviewdescriptionController = TextEditingController();
  TextEditingController _ratingController = TextEditingController();

  DateTime? experienceStartDate;
  DateTime? experienceEndDate;

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime picked = (await showDatePicker(
      context: context,
      initialDate: experienceStartDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    ))!;
    if (picked != null && picked != experienceStartDate) {
      setState(() {
        experienceStartDate = picked;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime picked = (await showDatePicker(
      context: context,
      initialDate: experienceEndDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    ))!;
    if (picked != null && picked != experienceEndDate) {
      setState(() {
        experienceEndDate = picked;
      });
    }
  }

  bool isExpanded = false;

  double fontSize = 30.0;
  double fontSize1 = 30.0;
  double fontSize2 = 30.0;
  double fontSize3 = 30.0;
  double fontSize4 = 30.0;

  var rating = 5;

  void toggleExpansion(int i) {
    rating = i + 1;
    setState(() {
      isExpanded = !isExpanded;
      if (i == 0) {
        fontSize = 46.0;
        fontSize1 = 30.0;
        fontSize2 = 30.0;
        fontSize3 = 30.0;
        fontSize4 = 30.0;
      }
      if (i == 1) {
        fontSize = 30.0;
        fontSize1 = 46.0;
        fontSize2 = 30.0;
        fontSize3 = 30.0;
        fontSize4 = 30.0;
      }
      if (i == 2) {
        fontSize = 30.0;
        fontSize1 = 30.0;
        fontSize2 = 46.0;
        fontSize3 = 30.0;
        fontSize4 = 30.0;
      }
      if (i == 3) {
        fontSize = 30.0;
        fontSize1 = 30.0;
        fontSize2 = 30.0;
        fontSize3 = 46.0;
        fontSize4 = 30.0;
      }
      if (i == 4) {
        fontSize = 30.0;
        fontSize1 = 30.0;
        fontSize2 = 30.0;
        fontSize3 = 30.0;
        fontSize4 = 46.0;
      }
    });
  }

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Define breakpoints for different screen sizes
    final isPhone =
        screenWidth < 600; // Adjust the value as needed for laptop screens

    return Scaffold(
      backgroundColor: const Color.fromARGB(238, 255, 255, 255),
      body: Padding(
        padding: EdgeInsets.all(isPhone
            ? 16.0
            : 32.0), // Adjust the padding for different screen sizes
        child: Material(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                        icon: Icon(Icons.arrow_back_ios),
                      ),
                      SizedBox(
                        width: isPhone
                            ? 5.0
                            : 30.0, // Adjust spacing for different screen sizes
                      ),
                      Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text(
                          'Let us know your experience with us! \u{1F60A}',
                          style: TextStyle(
                            fontFamily: GoogleFonts.abhayaLibre().fontFamily,
                            fontSize: isPhone
                                ? 14.0
                                : 25.0, // Adjust font size for different screen sizes
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 35, 176, 40),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Color.fromARGB(0, 222, 214, 248),
                      border: Border.all(width: 0.3),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    width: isPhone
                        ? screenWidth
                        : 500, // Adjust width for different screen sizes
                    padding: EdgeInsets.all(26.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Name',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              contentPadding: EdgeInsets.all(12.0),
                            ),
                          ),
                          SizedBox(height: 16.0),
                          Text(
                            'Your Email',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              contentPadding: EdgeInsets.all(12.0),
                            ),
                          ),
                          SizedBox(height: 16.0),
                          Text(
                            'Course Enrolled In',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextFormField(
                            controller: _courseController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              contentPadding: EdgeInsets.all(12.0),
                            ),
                          ),
                          SizedBox(height: 16.0),
                          Text(
                            'LinkedIn Url',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextFormField(
                            controller: _linkdinlinkController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              contentPadding: EdgeInsets.all(12.0),
                            ),
                          ),
                          SizedBox(height: 16.0),
                          Text(
                            'Rate Your Experience',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          AnimatedContainer(
                            duration: Duration(milliseconds: 2300),
                            width: 300,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    toggleExpansion(0);
                                  },
                                  child: AnimatedContainer(
                                    duration: Duration(milliseconds: 2300),
                                    child: Text(
                                      '\u{1F922}',
                                      style: TextStyle(
                                        fontSize: fontSize,
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    toggleExpansion(1);
                                  },
                                  child: AnimatedContainer(
                                    duration: Duration(milliseconds: 2300),
                                    child: Text(
                                      '\u{1F612}',
                                      style: TextStyle(
                                        fontSize: fontSize1,
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    toggleExpansion(2);
                                  },
                                  child: AnimatedContainer(
                                    duration: Duration(milliseconds: 2300),
                                    child: Text(
                                      '\u{1F642}',
                                      style: TextStyle(
                                        fontSize: fontSize2,
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    toggleExpansion(3);
                                  },
                                  child: AnimatedContainer(
                                    duration: Duration(milliseconds: 2300),
                                    child: Text(
                                      '\u{1F60A}',
                                      style: TextStyle(
                                        fontSize: fontSize3,
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    toggleExpansion(4);
                                  },
                                  child: AnimatedContainer(
                                    duration: Duration(milliseconds: 2300),
                                    child: Text(
                                      '\u{1F929}',
                                      style: TextStyle(
                                        fontSize: fontSize4,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: 16.0),
                          // RatingBar.builder(
                          //   initialRating: 3,
                          //   minRating: 1,
                          //   direction: Axis.horizontal,
                          //   allowHalfRating: true,
                          //   itemCount: 5,
                          //   itemSize: isPhone
                          //       ? 30.0
                          //       : 40.0, // Adjust item size for different screen sizes
                          //   itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                          //   itemBuilder: (context, index) {
                          //     Text textData;
                          //     switch (index) {
                          //       case 0:
                          //         textData = Text(
                          //           '\u{1F922}',
                          //           style: TextStyle(
                          //             fontSize: 36,
                          //           ),
                          //         );
                          //         break;
                          //       case 1:
                          //         textData = Text(
                          //           '\u{1F612}',
                          //           style: TextStyle(
                          //             fontSize: 36,
                          //           ),
                          //         );
                          //         break;
                          //       case 2:
                          //         textData = Text(
                          //           '\u{1F642}',
                          //           style: TextStyle(
                          //             fontSize: 36,
                          //           ),
                          //         );
                          //         break;
                          //       case 3:
                          //         textData = Text(
                          //           '\u{1F60A}',
                          //           style: TextStyle(
                          //             fontSize: 36,
                          //           ),
                          //         );
                          //         break;
                          //       case 4:
                          //         textData = Text(
                          //           '\u{1F929}',
                          //           style: TextStyle(
                          //             fontSize: 36,
                          //           ),
                          //         );
                          //         break;
                          //       default:
                          //         textData = Text(
                          //           '\u{1FAE0}',
                          //           style: TextStyle(
                          //             fontSize: 36,
                          //           ),
                          //         );
                          //         break;
                          //     }

                          //     return textData;
                          //   },
                          //   onRatingUpdate: (rating) {
                          //     _ratingController.text = rating.toString();
                          //   },
                          // ),
                          // SizedBox(height: 16.0),
                          Text(
                            'Write a Review',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextFormField(
                            controller: _reviewdescriptionController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              contentPadding: EdgeInsets.all(12.0),
                            ),
                          ),
                          SizedBox(height: 16.0),
                          Text(
                            'Date of Experience',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => _selectStartDate(context),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  padding: EdgeInsets.all(8),
                                  child: Text(
                                    experienceStartDate != null
                                        ? '${experienceStartDate!.day}/${experienceStartDate!.month}/${experienceStartDate!.year}'
                                        : 'Select Start Date',
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              GestureDetector(
                                onTap: () => _selectEndDate(context),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  padding: EdgeInsets.all(8),
                                  child: Text(
                                    experienceEndDate != null
                                        ? '${experienceEndDate!.day}/${experienceEndDate!.month}/${experienceEndDate!.year}'
                                        : 'Select End Date',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                              height: isPhone
                                  ? 32.0
                                  : 64.0), // Adjust spacing for different screen sizes
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (_nameController.text.isEmpty) {
                                  Toast.show('Name is required');
                                } else if (!isValidEmail(
                                    _emailController.text)) {
                                  Toast.show(
                                      'Please enter a valid email address');
                                } else if (_courseController.text.isEmpty) {
                                  Toast.show('Course is required');
                                } else if (!isValidLinkedInUrl(
                                    _linkdinlinkController.text)) {
                                  Toast.show(
                                      'Please enter a valid LinkedIn URL');
                                } else if (_reviewdescriptionController
                                    .text.isEmpty) {
                                  Toast.show('Review description is required');
                                } else if (experienceStartDate == null ||
                                    experienceEndDate == null) {
                                  Toast.show(
                                      'Please select start and end dates for your experience');
                                } else {
                                  setState(() {
                                    loading = true;
                                  });
                                  Toast.show(await postReview({
                                    "name": _nameController.text,
                                    "email": _emailController.text,
                                    "course": _courseController.text,
                                    "linkdinlink": _linkdinlinkController.text,
                                    "reviewdescription":
                                        _reviewdescriptionController.text,
                                    "rating": rating.toString(),
                                    "experience":
                                        "${experienceStartDate!.day}/${experienceStartDate!.month}/${experienceStartDate!.year} to ${experienceEndDate!.day}/${experienceEndDate!.month}/${experienceEndDate!.year}",
                                    "date": DateTime.now().toString(),
                                  }));

                                  setState(() {
                                    loading = false;
                                    _nameController.text = '';
                                    _emailController.text = '';
                                    _courseController.text = '';
                                    _linkdinlinkController.text = '';
                                    _reviewdescriptionController.text = '';
                                    _ratingController.text = '';
                                    experienceStartDate = null;
                                    experienceEndDate = null;
                                  });

                                  // Navigator.pop(context);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                primary: Colors.blue,
                                onPrimary: Colors.white,
                                padding: EdgeInsets.all(isPhone
                                    ? 16.0
                                    : 32.0), // Adjust padding for different screen sizes
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: loading
                                  ? Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      'Submit Review',
                                      style: TextStyle(
                                        fontSize: isPhone
                                            ? 18
                                            : 24, // Adjust font size for different screen sizes
                                      ),
                                    ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool isValidEmail(String email) {
    final emailRegExp = RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');
    return emailRegExp.hasMatch(email);
  }

  bool isValidLinkedInUrl(String url) {
    return url.contains('linkedin.com');
  }
}
