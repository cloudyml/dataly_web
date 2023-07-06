import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../global_variable.dart';
import '../models/firebase_file.dart';

import '../screens/flutter_flow/flutter_flow_theme.dart';

class AssignmentScreen extends StatefulWidget {
  const AssignmentScreen(
      {Key? key,
        this.courseData,
        this.courseName,
        this.selectedSection,
        this.assignmentUrl,
        this.solutionUrl,
        this.dataSetUrl,
        this.assignmentName,
        this.assignmentDescription
      })
      : super(key: key);

  final courseData;
  final courseName;
  final selectedSection;
  final assignmentUrl;
  final solutionUrl;
  final dataSetUrl;
  final assignmentName;
  final assignmentDescription;

  @override
  State<AssignmentScreen> createState() => _AssignmentScreenState();
}

class _AssignmentScreenState extends State<AssignmentScreen> {
  // TextEditingController noteText = TextEditingController();

  Uint8List? uploadedFile;

  FirebaseFirestore _reference = FirebaseFirestore.instance;
  FirebaseFile? file;

  String? fileName;

  var ref;

  Future getFile() async {
    FilePickerResult? result;

    try {
      result = await FilePicker.platform.pickFiles(type: FileType.any);
    } catch (e) {
      print(e.toString());
    }

    if (result != null && result.files.isNotEmpty) {
      try {
        Uint8List? uploadFile = result.files.single.bytes;

        // final String filepath = path.basename(uploadFile.toString());
        String pickedFileName = result.files.first.name;

        setState(() {
          uploadedFile = uploadFile;
          fileName = pickedFileName;
        });

        if (uploadedFile != null) {
          Fluttertoast.showToast(msg: 'Your file is attached');
        }
      } catch (e) {
        Fluttertoast.showToast(msg: e.toString());
        print(e.toString());
      }
    }
  }

  var user;

  void getModuleId() async {
    ref = await FirebaseFirestore.instance
        .collection('courses')
        .doc('lLorGjaJf2m6hTzCdIxU')
        .get();

    await FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get().then((value) {
      user = value.data()!['name'].toString();
      print('this is email ${user.toString()}');
    });
  }

  final RegExp _linkRegExp =
  RegExp(r'(http[s]?:\/\/[^\s]+)', caseSensitive: false);
  String extractedLink = '';
  void _extractLink() {

    try{
      final String text = widget.assignmentDescription[widget.assignmentName];
      final Match match = _linkRegExp.firstMatch(text) as Match;
      setState(() {
        extractedLink = match.group(0) ?? '';
      });
      print('text is $extractedLink');
    }catch(e){
      print('_extractLink $e');
    }


  }

  Future downloadFile(String fileUrl) async {
    FirebaseStorage _storage = FirebaseStorage.instance;
    await _storage.ref('Assignments/${user.toString()}/${fileUrl}');
  }

  @override
  void initState() {
    getModuleId();
    _extractLink();
    super.initState();

  }



  var count;

  Future submissionTask() async {
    try {
      var storageRef =
      FirebaseStorage.instance.ref()
          .child('Assignments')
          .child('${user.toString()}')
          .child(fileName!);

      var sentData = await _reference.collection('assignment').add({
        "email": FirebaseAuth.instance.currentUser?.email,
        "name": FirebaseAuth.instance.currentUser?.displayName,
        "student id": FirebaseAuth.instance.currentUser?.uid,
        "date of submission": FieldValue.serverTimestamp(),
        "filename": fileName!,
        "link": '',
        // "note": noteText.text,
        'assignmentName': widget.assignmentName,
      });


      final UploadTask uploadTask = storageRef.putData(uploadedFile!);

      final TaskSnapshot downloadUrl = await uploadTask;
      final String fileURL = (await downloadUrl.ref.getDownloadURL());
      await sentData.update({"link": fileURL});
      print('Assignment file link is here: $fileURL');

      await _reference.collection('Users').doc(FirebaseAuth.instance.currentUser?.uid).update(
          {
            'assignmentTrack': FieldValue.arrayUnion([{
              "filename": fileName!,
              "link": fileURL,
              // "note": noteText.text,
              'assignmentName': widget.assignmentName,
            }])
          }
      );

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Congratulations!',
              style: FlutterFlowTheme.of(context)
                  .bodyText1
                  .override(
                fontFamily: 'Poppins',
                fontSize: 25,
                fontWeight: FontWeight.normal,
              ),
            ),
            content: Text("Your assignment is submitted successfully.",
              style:  FlutterFlowTheme.of(context)
                  .bodyText1
                  .override(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),),
            actions: <Widget>[
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );

      // Fluttertoast.showToast(msg: "Your file has been uploaded successfully");
      count = 1;
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              if (constraints.maxWidth >= 650) {
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SingleChildScrollView(
                    child: Container(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: (){
                                  Navigator.pop(context);
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(Icons.arrow_back_rounded),
                                    Text('Back'),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 10.sp,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  children: [
                                    Text(
                                      'Assignment Instructions',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 28,
                                      ),
                                    ),
                                    // Text('${widget.selectedSection}',
                                    //   style: TextStyle(
                                    //   color: Colors.grey,
                                    //   fontWeight: FontWeight.bold,
                                    //   fontSize: 22,
                                    // ),),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey,
                                          width: 0.2,
                                          style: BorderStyle.solid)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: widget.assignmentDescription[widget.assignmentName] != null ?
                                    Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // (widget.solutionUrl != null &&
                                          //             widget.solutionUrl != "null" &&
                                          //             widget.solutionUrl != "") ||
                                          (widget.assignmentUrl != null &&
                                              widget.assignmentUrl != "" &&
                                              widget.assignmentUrl != "null")
                                              ? Text(widget.assignmentDescription[widget.assignmentName],
                                            textAlign: TextAlign.left,
                                            maxLines: 6,
                                          )
                                              : SizedBox(),

                                          SizedBox(height: 10,),

                                          extractedLink == '' ? Container() : Row(
                                            children: [
                                              Text(
                                                'Click to open ',
                                                style: TextStyle(),
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  launch(extractedLink);
                                                },
                                                child: Text(
                                                  '${extractedLink}',
                                                  style: TextStyle(
                                                      color: Colors.deepPurpleAccent),
                                                ),
                                              ),
                                            ],
                                          ),

                                          // (widget.solutionUrl != null &&
                                          //             widget.solutionUrl != "null" &&
                                          //             widget.solutionUrl != "") ||
                                          (widget.assignmentUrl != null &&
                                              widget.assignmentUrl != "" &&
                                              widget.assignmentUrl != "null")
                                              ? SizedBox(
                                            height: 20,
                                          )
                                              : SizedBox(),
                                          widget.solutionUrl != null &&
                                              widget.solutionUrl != "null" &&
                                              widget.solutionUrl != ""
                                              ? Row(
                                            children: [
                                              Text("Reference PDF for output"),
                                              InkWell(
                                                  onTap: () {
                                                    launch(widget.solutionUrl);
                                                  },
                                                  child: Text(
                                                    'output.pdf',
                                                    style: TextStyle(
                                                        color:
                                                        Colors.deepPurpleAccent),
                                                  )),
                                            ],
                                          )
                                              : SizedBox(),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          //for assignments
                                          widget.assignmentUrl != null &&
                                              widget.assignmentUrl != "" &&
                                              widget.assignmentUrl != "null"
                                              ? Row(
                                            children: [
                                              Text(
                                                'Click to download ',
                                                style: TextStyle(),
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  launch(widget.assignmentUrl);
                                                },
                                                child: Text(
                                                  '${widget.assignmentName}',
                                                  style: TextStyle(
                                                      color: Colors.deepPurpleAccent),
                                                ),
                                              ),
                                            ],
                                          )
                                              : SizedBox(),
                                          //future builder for DataSets
                                          widget.dataSetUrl.length != 0
                                              ? Column(
                                            children: List.generate(
                                                widget.dataSetUrl.length, (index) {
                                              return Padding(
                                                padding:
                                                const EdgeInsets.only(top: 8.0),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      'Click to download ',
                                                    ),
                                                    InkWell(
                                                      onTap: () {
                                                        launch(
                                                            widget.dataSetUrl[index]
                                                            ["url"]);
                                                        // print(
                                                        //     'dataset = ${widget.dataSetUrl} ${widget.dataSetUrl.toString()}');
                                                      },
                                                      child: Container(
                                                        width: 640,
                                                        child: Text(
                                                          '${widget.dataSetUrl[index]["name"]}',
                                                          maxLines: 10,
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .deepPurpleAccent),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }),
                                          )
                                              : SizedBox()
                                        ])
                                        : Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // (widget.solutionUrl != null &&
                                          //             widget.solutionUrl != "null" &&
                                          //             widget.solutionUrl != "") ||
                                          (widget.assignmentUrl != null &&
                                              widget.assignmentUrl != "" &&
                                              widget.assignmentUrl != "null")
                                              ? Text(
                                            "Please download the assignment, watch videos as instructed and answer all questions ",
                                            textAlign: TextAlign.left,
                                          )
                                              : SizedBox(),

                                          // (widget.solutionUrl != null &&
                                          //             widget.solutionUrl != "null" &&
                                          //             widget.solutionUrl != "") ||
                                          (widget.assignmentUrl != null &&
                                              widget.assignmentUrl != "" &&
                                              widget.assignmentUrl != "null")
                                              ? Row(
                                            children: [
                                              Text(
                                                "accordingly. Open colab by clicking here : ",
                                                textAlign: TextAlign.left,
                                              ),
                                              InkWell(
                                                  onTap: () => launch(
                                                      'https://colab.research.google.com/'),
                                                  child: Text(
                                                    "https://colab.research.google.com/",
                                                    style: TextStyle(
                                                        color:
                                                        Colors.deepPurpleAccent),
                                                  )),
                                            ],
                                          )
                                              : SizedBox(),

                                          // (widget.solutionUrl != null &&
                                          //             widget.solutionUrl != "null" &&
                                          //             widget.solutionUrl != "") ||
                                          (widget.assignmentUrl != null &&
                                              widget.assignmentUrl != "" &&
                                              widget.assignmentUrl != "null")
                                              ? SizedBox(
                                            height: 20,
                                          )
                                              : SizedBox(),
                                          widget.solutionUrl != null &&
                                              widget.solutionUrl != "null" &&
                                              widget.solutionUrl != ""
                                              ? Row(
                                            children: [
                                              Text("Reference PDF for output"),
                                              InkWell(
                                                  onTap: () {
                                                    launch(widget.solutionUrl);
                                                  },
                                                  child: Text(
                                                    'output.pdf',
                                                    style: TextStyle(
                                                        color:
                                                        Colors.deepPurpleAccent),
                                                  )),
                                            ],
                                          )
                                              : SizedBox(),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          //for assignments
                                          widget.assignmentUrl != null &&
                                              widget.assignmentUrl != "" &&
                                              widget.assignmentUrl != "null"
                                              ? Row(
                                            children: [
                                              Text(
                                                'Click to download ',
                                                style: TextStyle(),
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  launch(widget.assignmentUrl);
                                                },
                                                child: Text(
                                                  '${widget.assignmentName}',
                                                  style: TextStyle(
                                                      color: Colors.deepPurpleAccent),
                                                ),
                                              ),
                                            ],
                                          )
                                              : SizedBox(),
                                          //future builder for DataSets
                                          widget.dataSetUrl.length != 0
                                              ? Column(
                                            children: List.generate(
                                                widget.dataSetUrl.length, (index) {
                                              return Padding(
                                                padding:
                                                const EdgeInsets.only(top: 8.0),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      'Click to download ',
                                                    ),
                                                    InkWell(
                                                      onTap: () {
                                                        launch(
                                                            widget.dataSetUrl[index]
                                                            ["url"]);
                                                        // print(
                                                        //     'dataset = ${widget.dataSetUrl} ${widget.dataSetUrl.toString()}');
                                                      },
                                                      child: Container(
                                                        width: 640,
                                                        child: Text(
                                                          '${widget.dataSetUrl[index]["name"]}',
                                                          maxLines: 10,
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .deepPurpleAccent),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }),
                                          )
                                              : SizedBox()
                                        ]),
                                  ),
                                ),
                              ),
                              // main grey container

                              // (widget.solutionUrl != null &&
                              //             widget.solutionUrl != "null" &&
                              //             widget.solutionUrl != "") ||
                              (widget.assignmentUrl != null &&
                                  widget.assignmentUrl != "" &&
                                  widget.assignmentUrl != "null")
                                  ? Container(
                                width: MediaQuery.of(context).size.width / 2,
                                decoration: BoxDecoration(
                                  border:
                                  Border.all(color: Colors.white12, width: 0.5),
                                  color: Colors.black12,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            "Upload Assignment",
                                            style: TextStyle(
                                                color: Colors.black54,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            width: 10.sp,
                                          ),
                                          Text(
                                            "You can upload maximum 200 MB of file size.",
                                            style: TextStyle(
                                                color: Colors.black54, fontSize: 12),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      //button container
                                      Container(
                                        padding: EdgeInsets.only(left: 20),
                                        width:
                                        MediaQuery.of(context).size.width / 1.2,
                                        color: Colors.black12,
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(10.0),
                                              child: ElevatedButton(
                                                onPressed: () async {
                                                  await getFile();
                                                  if (fileName!.isNotEmpty) {
                                                    print(fileName);
                                                  }
                                                },
                                                child: Text("Choose file",
                                                    style: TextStyle(
                                                        color: Colors.black26)),
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.white),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            uploadedFile != null
                                                ? Text(
                                              fileName.toString(),
                                              style: TextStyle(
                                                  color: Colors.black),
                                            )
                                                : Text(
                                              "No file chosen",
                                              style: TextStyle(
                                                  color: Colors.black26),
                                            )
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      // Text(
                                      //   "Notes",
                                      //   style: TextStyle(
                                      //       color: Colors.black54,
                                      //       fontSize: 18,
                                      //       fontWeight: FontWeight.bold),
                                      // ),
                                      // SizedBox(
                                      //   height: 10,
                                      // ),
                                      // Container(
                                      //   width: MediaQuery.of(context).size.width / 2,
                                      //   padding: EdgeInsets.all(10.0),
                                      //   decoration: BoxDecoration(
                                      //       color: Colors.white,
                                      //       border: Border.all(
                                      //           color: Colors.white12, width: 0.5),
                                      //       borderRadius: BorderRadius.circular(5.0)),
                                      //   child: TextField(
                                      //     controller: noteText,
                                      //     decoration: InputDecoration(
                                      //       hintText: 'Please write note here...',
                                      //       border: InputBorder.none,
                                      //     ),
                                      //     maxLines: 10,
                                      //     minLines: 5,
                                      //     autocorrect: true,
                                      //   ),
                                      // ),
                                      // SizedBox(
                                      //   height: 10,
                                      // ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          if (uploadedFile == null) {
                                            Fluttertoast.showToast(msg: 'Please upload a file',fontSize: 35,);
                                          } else {

                                            await submissionTask();

                                            setState(() {
                                              // noteText.clear();
                                              uploadedFile = null;
                                            });

                                          }
                                        },
                                        child: Text(count == 1 ? "Resubmit" : "Submit",
                                          style: TextStyle(),),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: uploadedFile == null
                                              ? count == 1 ? Colors.grey : Colors.green
                                              : Colors.deepPurpleAccent,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              )
                                  : SizedBox(),
                            ],
                          ),
                        )),
                  ),
                );
              } else {
                return Padding(
                  padding:  EdgeInsets.all(10.sp),
                  child: SingleChildScrollView(
                    child: Container(
                        color: Colors.white,
                        child: Padding(
                          padding: EdgeInsets.all(12.sp),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: (){
                                  Navigator.pop(context);
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(Icons.arrow_back_rounded),
                                    Text('Back'),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 10.sp,
                              ),
                              Padding(
                                padding: EdgeInsets.only(bottom: 8.sp),
                                child: Row(
                                  children: [
                                    Text(
                                      'Assignment Instructions',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20.sp,
                                      ),
                                    ),
                                    // Text('${widget.selectedSection}',
                                    //   style: TextStyle(
                                    //   color: Colors.grey,
                                    //   fontWeight: FontWeight.bold,
                                    //   fontSize: 22,
                                    // ),),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(bottom: 8.sp),
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey,
                                          width: 0.2.sp,
                                          style: BorderStyle.solid)),
                                  child: Padding(
                                    padding: EdgeInsets.all(8.sp),
                                    child: widget.assignmentDescription[widget.assignmentName] != null
                                        ?  Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // (widget.solutionUrl != null &&
                                          //             widget.solutionUrl != "null" &&
                                          //             widget.solutionUrl != "") ||
                                          (widget.assignmentUrl != null &&
                                              widget.assignmentUrl != "" &&
                                              widget.assignmentUrl != "null")
                                              ? Text(
                                            widget.assignmentDescription[widget.assignmentName],
                                            textAlign: TextAlign.left,

                                          )
                                              : SizedBox(),

                                          // (widget.solutionUrl != null &&
                                          //             widget.solutionUrl != "null" &&
                                          //             widget.solutionUrl != "") ||
                                          // (widget.assignmentUrl != null &&
                                          //     widget.assignmentUrl != "" &&
                                          //     widget.assignmentUrl != "null")
                                          //     ? Column(
                                          //   children: [
                                          //     Text(
                                          //       "accordingly. Open colab by clicking here : ",
                                          //       textAlign: TextAlign.left,
                                          //     ),
                                          //     InkWell(
                                          //         onTap: () => launch(
                                          //             'https://colab.research.google.com/'),
                                          //         child: Text(
                                          //           "https://colab.research.google.com/",
                                          //           style: TextStyle(
                                          //               color:
                                          //               Colors.deepPurpleAccent),
                                          //         )),
                                          //   ],
                                          // )
                                          //     : SizedBox(),

                                          // (widget.solutionUrl != null &&
                                          //             widget.solutionUrl != "null" &&
                                          //             widget.solutionUrl != "") ||
                                          (widget.assignmentUrl != null &&
                                              widget.assignmentUrl != "" &&
                                              widget.assignmentUrl != "null")
                                              ? SizedBox(
                                            height: 20,
                                          )
                                              : SizedBox(),
                                          extractedLink == '' ? Container() : Row(
                                            children: [
                                              Text(
                                                'Click to open ',
                                                style: TextStyle(),
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  launch(extractedLink);
                                                },
                                                child: Text(
                                                  '${extractedLink}',
                                                  style: TextStyle(
                                                      color: Colors.deepPurpleAccent),
                                                ),
                                              ),
                                            ],
                                          ),
                                          widget.solutionUrl != null &&
                                              widget.solutionUrl != "null" &&
                                              widget.solutionUrl != ""
                                              ? Row(
                                            children: [
                                              Text("Reference PDF for output"),
                                              InkWell(
                                                  onTap: () {
                                                    launch(widget.solutionUrl);
                                                  },
                                                  child: Text(
                                                    'output.pdf',
                                                    style: TextStyle(
                                                        color:
                                                        Colors.deepPurpleAccent),
                                                  )),
                                            ],
                                          )
                                              : SizedBox(),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          //for assignments
                                          widget.assignmentUrl != null &&
                                              widget.assignmentUrl != "" &&
                                              widget.assignmentUrl != "null"
                                              ? Row(
                                            children: [
                                              Text(
                                                'Click to download ',
                                                style: TextStyle(),
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  launch(widget.assignmentUrl);
                                                },
                                                child: Text(
                                                  '${widget.assignmentName}',
                                                  style: TextStyle(
                                                      color: Colors.deepPurpleAccent),
                                                ),
                                              ),
                                            ],
                                          )
                                              : SizedBox(),
                                          //future builder for DataSets
                                          widget.dataSetUrl.length != 0
                                              ? Column(
                                            children: List.generate(
                                                widget.dataSetUrl.length, (index) {
                                              return Padding(
                                                padding:
                                                const EdgeInsets.only(top: 8.0),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      'Click to download ',
                                                    ),
                                                    InkWell(
                                                      onTap: () {
                                                        launch(
                                                            widget.dataSetUrl[index]
                                                            ["url"]);
                                                        // print(
                                                        //     'dataset = ${widget.dataSetUrl} ${widget.dataSetUrl.toString()}');
                                                      },
                                                      child: Container(
                                                        width: 640,
                                                        child: Text(
                                                          '${widget.dataSetUrl[index]["name"]}',
                                                          maxLines: 10,
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .deepPurpleAccent),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }),
                                          )
                                              : SizedBox()
                                        ])
                                        :  Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // (widget.solutionUrl != null &&
                                          //             widget.solutionUrl != "null" &&
                                          //             widget.solutionUrl != "") ||
                                          (widget.assignmentUrl != null &&
                                              widget.assignmentUrl != "" &&
                                              widget.assignmentUrl != "null")
                                              ? Text(
                                            "Please download the assignment, watch videos as instructed and answer all questions ",
                                            textAlign: TextAlign.left,

                                          )
                                              : SizedBox(),

                                          // (widget.solutionUrl != null &&
                                          //             widget.solutionUrl != "null" &&
                                          //             widget.solutionUrl != "") ||
                                          (widget.assignmentUrl != null &&
                                              widget.assignmentUrl != "" &&
                                              widget.assignmentUrl != "null")
                                              ? Column(
                                            children: [
                                              Text(
                                                "accordingly. Open colab by clicking here : ",
                                                textAlign: TextAlign.left,
                                              ),
                                              InkWell(
                                                  onTap: () => launch(
                                                      'https://colab.research.google.com/'),
                                                  child: Text(
                                                    "https://colab.research.google.com/",
                                                    style: TextStyle(
                                                        color:
                                                        Colors.deepPurpleAccent),
                                                  )),
                                            ],
                                          )
                                              : SizedBox(),

                                          // (widget.solutionUrl != null &&
                                          //             widget.solutionUrl != "null" &&
                                          //             widget.solutionUrl != "") ||
                                          (widget.assignmentUrl != null &&
                                              widget.assignmentUrl != "" &&
                                              widget.assignmentUrl != "null")
                                              ? SizedBox(
                                            height: 20,
                                          )
                                              : SizedBox(),
                                          widget.solutionUrl != null &&
                                              widget.solutionUrl != "null" &&
                                              widget.solutionUrl != ""
                                              ? Row(
                                            children: [
                                              Text("Reference PDF for output"),
                                              InkWell(
                                                  onTap: () {
                                                    launch(widget.solutionUrl);
                                                  },
                                                  child: Text(
                                                    'output.pdf',
                                                    style: TextStyle(
                                                        color:
                                                        Colors.deepPurpleAccent),
                                                  )),
                                            ],
                                          )
                                              : SizedBox(),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          //for assignments
                                          widget.assignmentUrl != null &&
                                              widget.assignmentUrl != "" &&
                                              widget.assignmentUrl != "null"
                                              ? Row(
                                            children: [
                                              Text(
                                                'Click to download ',
                                                style: TextStyle(),
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  launch(widget.assignmentUrl);
                                                },
                                                child: Text(
                                                  '${widget.assignmentName}',
                                                  style: TextStyle(
                                                      color: Colors.deepPurpleAccent),
                                                ),
                                              ),
                                            ],
                                          )
                                              : SizedBox(),
                                          //future builder for DataSets
                                          widget.dataSetUrl.length != 0
                                              ? Column(
                                            children: List.generate(
                                                widget.dataSetUrl.length, (index) {
                                              return Padding(
                                                padding:
                                                const EdgeInsets.only(top: 8.0),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      'Click to download ',
                                                    ),
                                                    InkWell(
                                                      onTap: () {
                                                        launch(
                                                            widget.dataSetUrl[index]
                                                            ["url"]);
                                                        // print(
                                                        //     'dataset = ${widget.dataSetUrl} ${widget.dataSetUrl.toString()}');
                                                      },
                                                      child: Container(
                                                        width: 640,
                                                        child: Text(
                                                          '${widget.dataSetUrl[index]["name"]}',
                                                          maxLines: 10,
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .deepPurpleAccent),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }),
                                          )
                                              : SizedBox()
                                        ]),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20.sp,
                              ),
                              // main grey container

                              // (widget.solutionUrl != null &&
                              //             widget.solutionUrl != "null" &&
                              //             widget.solutionUrl != "") ||
                              (widget.assignmentUrl != null &&
                                  widget.assignmentUrl != "" &&
                                  widget.assignmentUrl != "null")
                                  ? Container(
                                decoration: BoxDecoration(
                                  border:
                                  Border.all(color: Colors.white12, width: 0.5),
                                  color: Colors.black12,
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(10.sp),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Upload Assignment",
                                            style: TextStyle(
                                                color: Colors.black54,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(height: 10.sp),
                                          Text(
                                            "You can upload maximum 200 MB of file size.",
                                            style: TextStyle(
                                                color: Colors.black54, fontSize: 12),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10.sp,
                                      ),
                                      //button container
                                      Container(
                                        padding: EdgeInsets.only(left: 15.sp),
                                        width:
                                        MediaQuery.of(context).size.width / 1.2,
                                        color: Colors.black12,
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(10.0),
                                              child: ElevatedButton(
                                                onPressed: () async {
                                                  await getFile();
                                                  if (fileName!.isNotEmpty) {
                                                    print(fileName);
                                                  }
                                                },
                                                child: Text("Choose file",
                                                    style: TextStyle(
                                                        color: Colors.black26)),
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.white),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            uploadedFile != null
                                                ? Text(
                                              fileName.toString(),
                                              style: TextStyle(
                                                  color: Colors.black),
                                            )
                                                : Text(
                                              "No file chosen",
                                              style: TextStyle(
                                                  color: Colors.black26),
                                            )
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10.sp,
                                      ),
                                      // Text(
                                      //   "Notes",
                                      //   style: TextStyle(
                                      //       color: Colors.black54,
                                      //       fontSize: 16.sp,
                                      //       fontWeight: FontWeight.bold),
                                      // ),
                                      // SizedBox(
                                      //   height: 10,
                                      // ),
                                      // Container(
                                      //   padding: EdgeInsets.all(10.sp),
                                      //   decoration: BoxDecoration(
                                      //       color: Colors.white,
                                      //       border: Border.all(
                                      //           color: Colors.white12, width: 0.5),
                                      //       borderRadius: BorderRadius.circular(10.sp)),
                                      //   child: TextField(
                                      //     controller: noteText,
                                      //     decoration: InputDecoration(
                                      //       hintText: 'Please write note here...',
                                      //       border: InputBorder.none,
                                      //     ),
                                      //     maxLines: 10,
                                      //     minLines: 5,
                                      //     autocorrect: true,
                                      //   ),
                                      // ),
                                      // SizedBox(
                                      //   height: 10.sp,
                                      // ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          if (uploadedFile == null) {
                                            Fluttertoast.showToast(msg: 'Please upload a file',fontSize: 35,);
                                          } else {

                                            await submissionTask();

                                            setState(() {
                                              // noteText.clear();
                                              uploadedFile = null;
                                            });

                                          }
                                        },
                                        child: Text(count == 1 ? "Resubmit" : "Submit",
                                          style: TextStyle(),),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: uploadedFile == null
                                              ? count == 1 ? Colors.grey : Colors.green
                                              : Colors.deepPurpleAccent,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              )
                                  : SizedBox(),
                            ],
                          ),
                        )),
                  ),
                );
              }

            }
        ));
  }
}
