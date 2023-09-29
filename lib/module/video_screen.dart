import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:auto_orientation/auto_orientation.dart';
import 'package:cloudyml_app2/homepage.dart';
import 'package:cloudyml_app2/models/video_details.dart';
import 'package:cloudyml_app2/module/submit_resume.dart';
import 'package:cloudyml_app2/offline/db.dart';
import 'package:cloudyml_app2/globals.dart';
import 'package:cloudyml_app2/models/offline_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudyml_app2/screens/quiz/quizinstructions.dart';
import 'package:cloudyml_app2/widgets/assignment_bottomsheet.dart';
import 'package:cloudyml_app2/widgets/settings_bottomsheet.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:go_router/go_router.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hive/hive.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:toast/toast.dart';
import 'package:video_player/video_player.dart';
import 'dart:html' as html;
import 'dart:ui' as ui;
import 'package:cloudyml_app2/global_variable.dart' as globals;
import '../api/firebase_api.dart';
import '../fun.dart';
import '../global_variable.dart';
import '../models/course_details.dart';
import '../models/firebase_file.dart';
import '../screens/quiz/quizentry.dart';
import 'new_assignment_screen.dart';

class VideoScreen extends StatefulWidget {
  final List<dynamic>? courses;
  final int? sr;
  final bool? isDemo;
  final String? courseName;
  final String? cID;
  static ValueNotifier<double> currentSpeed = ValueNotifier(1.0);

  const VideoScreen(
      {required this.isDemo, this.sr, this.courseName, this.courses, this.cID});

  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late List<FirebaseFile> futureAssignments;
  late List<FirebaseFile> futureSolutions;
  late List<FirebaseFile> futureDataSets;

  // VideoPlayerController? _videoController;
  late String htmltext;
  bool htmlbool = false;
  List pathwaydata = [];
  bool? downloading = false;
  bool downloaded = false;
  Map<String, dynamic>? data;
  String? videoUrl;
  Future<void>? playVideo;
  bool showAssignment = false;
  int? serialNo;
  String? assignMentVideoUrl;
  bool _disposed = false;
  bool _isPlaying = false;
  bool loading = false;
  bool enablePauseScreen = false;
  bool _isBuffering = false;
  Duration? _duration;
  Duration? _position;
  bool switchTOAssignment = false;
  bool stopdownloading = true;
  bool showAssignSol = false;
  bool quizbool = false;
  var quizdata;
  var quizScore = 0;
  bool quizNameExistsInList = false;
  TextEditingController updateVideoUrl = TextEditingController();
  TextEditingController updateDescription = TextEditingController();
  TextEditingController updateSolutionVideo = TextEditingController();

  checkQuizScore(String quizName) {
    for (var item in globals.quiztrack) {
      if (item['quizname'] == quizName) {
        setState(() {
          quizScore = item['quizScore'];
          quizNameExistsInList = true;
        });
        break;
      } else {
        quizScore = 0;
        quizNameExistsInList = false;
      }
    }
  }

  var _delayToInvokeonControlUpdate = 0;
  var _progress = 0.0;
  bool submitResume = false;
  List<VideoDetails> _listOfVideoDetails = [];

  ValueNotifier<int> _currentVideoIndex = ValueNotifier(0);
  ValueNotifier<int> _currentVideoIndex2 = ValueNotifier(0);
  ValueNotifier<double> _downloadProgress = ValueNotifier(0);

  html.IFrameElement _iFrameElement = html.IFrameElement();

  String elemtntId = Random().nextInt(100000).toString();
  initPlayer(String url) {
    print('THE VID URL : $url');

    videoUrl = url;
    _iFrameElement.style.height = '100%';
    _iFrameElement.style.width = '100%';
    _iFrameElement.allowFullscreen = true;

    _iFrameElement.src = url;
    _iFrameElement.style.border = 'none';

// ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      elemtntId,
      (int viewId) => _iFrameElement,
    );
  }

  GlobalKey iFrameKey = GlobalKey();

  Future<void> setModuleId() async {
    await FirebaseFirestore.instance
        .collection('courses')
        .doc(widget.cID)
        .collection('Modules')
        .where('firstType', isEqualTo: 'video')
        .get()
        .then((value) {
      moduleId = value.docs[0].id;
    });
  }

  String convertToTwoDigits(int value) {
    return value < 10 ? "0$value" : "$value";
  }

  updateVideoProgress(dynamic listOfProgress) async {
    int total = 0, count = 0;

    await FirebaseFirestore.instance
        .collection("courseprogress")
        .doc(_auth.currentUser!.uid.toString())
        .get()
        .then((value) {
      // if(value.get(CourseID.toString()))

      List res = value.get(CourseID.toString());
      List<int> integerValues = [100];

      for (var element in res) {
        for (var dictionary in element.values) {
          for (var value in dictionary) {
            if (value.values.first is int) {
              integerValues.add(value.values.first);
            }
          }
        }
      }

      total = integerValues.reduce((a, b) => a + b);
      count = integerValues.length - 1;
    });

    await FirebaseFirestore.instance
        .collection("courseprogress")
        .doc(_auth.currentUser!.uid.toString())
        .update({
      CourseID.toString(): listOfProgress,
      CourseID.toString() + "percentage":
          ((total / (count * 100)) * 100).toInt(),
    }).catchError((err) => print("Error$err"));
  }

  Widget timeElapsedString() {
    var timeElapsedString = "00.00";
    final currentPosition = _position?.inSeconds ?? 0;
    final mins = convertToTwoDigits(currentPosition ~/ 60);
    final seconds = convertToTwoDigits(currentPosition % 60);
    timeElapsedString = '$mins:$seconds';
    return Text(
      timeElapsedString,
      style: TextStyle(
          color: Colors.white,
          // fontSize: 12,
          fontWeight: FontWeight.bold),
    );
  }

  int totalDuration = 0;
  int currentPosition = 0;
  String? moduleName, moduleId, videoId;

  void getPermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

  var courseData;
  String courseName = '';
  var curriculumdata;
  var sectionName = [];

  Map<String, List> datamap = {};

  List<VideoDetails> _videodetails = [];
  var listData = [];
  var listOfVideo = [];
  var dataList = [];
  var videoPercentageList = [];
  var totalPercentageList = {};

  var dataa;
  var curriculum1;

  /*-------------- QuizScore for all quiz Code ------------- */
  var courseCurriculum;
  var userQuizTrack;
  Map quizScoreMap = {};
  Map assignmentMap = {};
  bool assignmentSubmitted = false;
  Map assignmentDescription = {};
  getScoreOfAllQuiz() async {
    try {
      courseCurriculum = await FirebaseFirestore.instance
          .collection("courses")
          .doc(widget.cID)
          .get();
      userQuizTrack = await FirebaseFirestore.instance
          .collection("Users")
          .doc(_auth.currentUser!.uid)
          .get();

      var courseQuizList = courseCurriculum['curriculum1'][widget.courseName];

      for (var i = 0; i < courseQuizList.length; i++) {
        for (var j = 0; j < courseQuizList[i]['videos'].length; j++) {
          if (courseQuizList[i]['videos'][j]['type'] == 'quiz') {
            for (var name in userQuizTrack['quiztrack']) {
              if (courseQuizList[i]['videos'][j]['name'] == name['quizname']) {
                setState(() {
                  quizScoreMap[name['quizname']] = name['quizScore'];
                });
              }
            }
          }
        }
        // print('quizScoreMap $quizScoreMap');
      }

      // Logic for all assignment submission
      for (var i = 0; i < courseQuizList.length; i++) {
        for (var j = 0; j < courseQuizList[i]['videos'].length; j++) {
          if (courseQuizList[i]['videos'][j]['type'] == 'assignment') {
            for (var name in userQuizTrack['assignmentTrack']) {
              if (courseQuizList[i]['videos'][j]['name'] ==
                  name['assignmentName']) {
                setState(() {
                  assignmentMap[name['assignmentName']] =
                      name['assignmentName'];
                  assignmentSubmitted = true;
                });
              }
            }
          }
        }
        // print('quizScoreMap $quizScoreMap');
      }
    } catch (e) {
      print('Error quizScoreMap: assignmentMap: $e');
    }
  }

/*-------------- Assignment Description ------------- */

  getAssignmentDescription() async {
    try {
      courseCurriculum = await FirebaseFirestore.instance
          .collection("courses")
          .doc(widget.cID)
          .get();

      var assignmentData = courseCurriculum['curriculum1'][widget.courseName];

      for (var i = 0; i < assignmentData.length; i++) {
        for (var j = 0; j < assignmentData[i]['videos'].length; j++) {
          if (assignmentData[i]['videos'][j]['type'] == 'assignment') {
            assignmentDescription[assignmentData[i]['videos'][j]['name']] =
                assignmentData[i]['videos'][j]['description'];
            // print(assignmentDescription);
          }
        }
        // print('assignmentData $assignmentDescription');
      }
    } catch (e) {
      print('Error getAssignmentDescription: $e');
    }
  }

/*-------------- Assignment Solution URL ------------- */

  var assignmentSolutionVideo = {};
  getAssignmentSolutionVideo() async {
    try {
      courseCurriculum = await FirebaseFirestore.instance
          .collection("courses")
          .doc(widget.cID)
          .get();

      var assignmentData = courseCurriculum['curriculum1'][widget.courseName];
      for (var i = 0; i < assignmentData.length; i++) {
        for (var j = 0; j < assignmentData[i]['videos'].length; j++) {
          if (assignmentData[i]['videos'][j]['type'] == 'assignment') {
            assignmentSolutionVideo[assignmentData[i]['videos'][j]['name']] =
                assignmentData[i]['videos'][j]['videoUrl'];
            // print('getAssignmentSolutionVideo $assignmentSolutionVideo');
          }
        }
        // print('getAssignmentSolutionVideo $assignmentSolutionVideo');
      }
    } catch (e) {
      print('Error getAssignmentSolutionVideo: $e');
    }
  }

/*-------------- Assignment Description Show or Not ------------- */

  var assignmentDescriptionShow = {};
  assignmentDescriptionShowCheck() async {
    try {
      courseCurriculum = await FirebaseFirestore.instance
          .collection("courses")
          .doc(widget.cID)
          .get();

      var assignmentData = courseCurriculum['curriculum1'][widget.courseName];
      for (var i = 0; i < assignmentData.length; i++) {
        for (var j = 0; j < assignmentData[i]['videos'].length; j++) {
          if (assignmentData[i]['videos'][j]['type'] == 'assignment') {
            assignmentDescriptionShow[assignmentData[i]['videos'][j]['name']] =
                assignmentData[i]['videos'][j]['showDescription'];
            // print('getAssignmentSolutionVideo $assignmentDescriptionShow');
          }
        }
        print('assignmentDescriptionShowCheck $assignmentDescriptionShow');
      }
    } catch (e) {
      print('Error assignmentDescriptionShowCheck: $e');
    }
  }

/*-------------- Assignment Track ------------- */

  var assignmentTrack;
  var assignmentTrackBoolMap = {};
  assignmentCheck() async {
    try {
      courseCurriculum = await FirebaseFirestore.instance
          .collection("courses")
          .doc(widget.cID)
          .get();
      assignmentTrack = await FirebaseFirestore.instance
          .collection("Users")
          .doc(_auth.currentUser!.uid)
          .get();

      var courseAssignmentList =
          courseCurriculum['curriculum1'][widget.courseName];

      for (var i = 0; i < courseAssignmentList.length; i++) {
        for (var j = 0; j < courseAssignmentList[i]['videos'].length; j++) {
          if (courseAssignmentList[i]['videos'][j]['type'] == 'assignment') {
            for (var name in assignmentTrack['assignmentTrack']) {
              if (courseAssignmentList[i]['videos'][j]['name'] ==
                  name['assignmentName']) {
                setState(() {
                  assignmentTrackBoolMap[name['assignmentName']] = true;
                });
              }
            }
          }
        }
        print('assignmentTrackBoolMap $assignmentTrackBoolMap');
      }
    } catch (e) {
      print('assignmentCheck() $e');
    }
  }

/*-------------- Video Percentage Srinivas Code ------------- */

  var _initialVideoPercentageList = {};
  List<dynamic>? _getVideoPercentageList;
  String? CourseID;
  getProgressData() async {
    try {
      var res = await FirebaseFirestore.instance
          .collection("courses")
          .doc(widget.cID)
          .get();
      CourseID = await res.get("id");
      print('course id - $CourseID ');

      var courseType = await res.get("courseContent");

      print('Course Type :::; $courseType');

      if (courseType == 'video') {
        await FirebaseFirestore.instance
            .collection("courseprogress")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get()
            .then((value) async {
          print("vvvvvvvvvvvvvvvvvvvvvvvvv");
          // print(_auth.currentUser!.uid.toString());
          // print(value.exists);

          var list = await res.get("curriculum1")[widget.courseName];

          if (value.exists) {
            if (value.data()![CourseID] != null) {
              // print("List-----$list");
              for (int i = 0; i < list.length; i++) {
                await list[i]["videos"]
                    .removeWhere((item) => item['type'] != "video");
              }

              // print(await list);
              list.sort((a, b) {
                if (a["sr"] > b["sr"]) {
                  return 1;
                }
                return -1;
              });

              /* check */
              var finalProgressData = [];
              var progressData = value.data()![CourseID];

              for (int i = 0; i < list.length; i++) {
                // int counter = 0;
                for (int k = 0; k < progressData.length; k++) {
                  if (progressData[k][list[i]["id"]] != null) {
                    // print("((((((( ${progressData[k]}");
                    finalProgressData.add(progressData[k]);
                    // counter=1;
                  }
                }
                for (int i = 0; i < finalProgressData.length; i++) {
                  for (var items in finalProgressData[i].entries) {
                    int count = 0;
                    for (var k in items.value) {
//         print(k.values.first);
//         print("**");
                      finalProgressData[i][items.key]![count][k.keys.first] >
                              100
                          ? finalProgressData[i][items.key]![count]
                              [k.keys.first] = 100
                          : null;
                      count++;
                    }
                  }
                }
                // Map<String,dynamic> moduleNew = {};
                // if(counter==0)
                //   {
                //     for(int k=0;k<list[i]["videos"].length;k++)
                //       {
                //         moduleNew[list[i]["id"].toString()]!.add({list[i]["videos"][k]["id"]:0});
                //       }
                //     // print("dic===$dic");
                //   }
                // counter==0?print("RRRTTT    ${list[i]["videos"]}  $moduleNew"):null;
              }
              Map<String, int> tempMap = {};

              var uniqueList = [];

              var removeDuplicateList = [];
              for (int h = 0; h < progressData.length; h++) {
                await progressData[h].forEach((key, val) async {
                  // print("9jdeiuwbw$val");
                  await val.forEach((map) async {
                    // print("Malppppp");
                    await map.forEach((key, value) {
                      // print("PLOPOPO");
                      if (!tempMap.containsKey(key)) {
                        tempMap.putIfAbsent(key, () => value);
                        // print(map);
                        uniqueList.add(map);
                        // print("Map------$map");
                      }
                      // print("Map--------");
                    });
                  });
                  // print("plplplplplplp");
                  // print(uniqueList);
                  removeDuplicateList.add({key: uniqueList});
                  uniqueList = [];
                  tempMap = {};
                });
              }
              finalProgressData = removeDuplicateList;

              // print("UUUUUUUUU $finalProgressData");

              await FirebaseFirestore.instance
                  .collection("courseprogress")
                  .doc(_auth.currentUser!.uid)
                  .update({CourseID.toString(): finalProgressData});

              // print("yyyyyyy $list");
              // value.data()![CourseID][0][list[0]["id"]];

              // print("&&&&&&&& ${_initialVideoPercentageList[widget.courseName]}");

              // print("data((--- ${finalProgressData}");
              var data = finalProgressData;
              // print("oooo ${list.length}");
              if (list.length == finalProgressData.length) {
                for (int k = 0; k < list.length; k++) {
                  if (list[k]["videos"].length ==
                      finalProgressData[k][list[k]["id"]].length) {
                  } else {
                    if (list[k]["videos"].length >
                        finalProgressData[k][list[k]["id"]].length) {
                      for (int g = 0; g < list[k]["videos"].length; g++) {
                        int count = 0;
                        finalProgressData[k][list[k]["id"]].forEach((ele) => {
                              if (ele.containsKey(list[k]["videos"][g]["id"]))
                                {
                                  // print("True")
                                  count = 1
                                }
                              else
                                {
                                  // print("false")
                                  // data[k][list[k]["id"]].add(ele)
                                }
                            });
                        count == 1
                            ? null
                            : data[k][list[k]["id"]].add(
                                {list[k]["videos"][g]["id"].toString(): 0});
                      }
                    } else {
                      for (int g = 0; g < data[k][list[k]["id"]].length; g++) {
                        int count = 0;
                        print("====${data[k][list[k]["id"]][g]}");
                        list[k]["videos"].forEach((ele) => {
                              if (data[k][list[k]["id"]][g]
                                  .containsKey(ele["id"]))
                                {count = 1}
                              else
                                {print("false ${ele["id"]}")}
                            });
                        count == 0 ? data[k][list[k]["id"]].removeAt(g) : null;
                      }
                    }
                  }
                }
              } else {
                if (list.length > finalProgressData.length) {
                  for (int i = 0; i < list.length; i++) {
                    int count = 0;
                    finalProgressData.forEach((ele) => {
                          // print("tyypypypyp $ele")
                          if (ele.containsKey(list[i]["id"]))
                            {
                              // print("True")
                              count = 1
                            }
                          else
                            {
                              print("false")
                              // data[k][list[k]["id"]].add(ele)
                            }
                        });
                    var listOfID = [];
                    for (int j = 0; j < list[i]["videos"].length; j++) {
                      listOfID.add({list[i]["videos"][j]["id"]: 0});
                    }
                    print("iddddddd");
                    print(listOfID);
                    count == 1
                        ? null
                        : data.add({list[i]["id"].toString(): listOfID});
                  }
                } else {
                  for (int j = 0; j < data.length; j++) {
                    int count = 0;
                    list.forEach((ele) {
                      if (data[j].containsKey(ele["id"])) {
                        count = 1;
                      }
                    });
                    count == 1 ? null : data.removeAt(j);
                  }
                }
              }

              await FirebaseFirestore.instance
                  .collection("courseprogress")
                  .doc(_auth.currentUser!.uid)
                  .update({CourseID.toString(): data});
              // print("finally  $data");
              _getVideoPercentageList = data;
            } else {
              var list = await res.get("curriculum1")[widget.courseName];
              list.sort((a, b) {
                if (a["sr"] > b["sr"]) {
                  return 1;
                }
                return -1;
              });
              _initialVideoPercentageList[widget.courseName.toString()] = [];
              for (int i = 0; i < list.length; i++) {
                print(_initialVideoPercentageList[widget.courseName.toString()]
                    .runtimeType);
                _initialVideoPercentageList[widget.courseName.toString()]
                    .add({list[i]["id"].toString(): []});
                for (int j = 0; j < list[i]["videos"].length; j++) {
                  list[i]["videos"][j]["type"] == "video"
                      ? _initialVideoPercentageList[widget.courseName][i]
                              [list[i]["id"]]
                          .add({list[i]["videos"][j]["id"]: 0})
                      : null;
                }
              }
              print("**** $_initialVideoPercentageList");
              await getUserRole();
              await FirebaseFirestore.instance
                  .collection("courseprogress")
                  .doc(_auth.currentUser!.uid.toString())
                  .update({
                CourseID.toString():
                    _initialVideoPercentageList[widget.courseName.toString()],
                "email": userEmail,
              }).catchError((err) => print("Error$err"));
              print("done----");
              _getVideoPercentageList =
                  _initialVideoPercentageList[widget.courseName.toString()];
            }
          } else {
            var list = await res.get("curriculum1")[widget.courseName];
            list.sort((a, b) {
              if (a["sr"] > b["sr"]) {
                return 1;
              }
              return -1;
            });
            _initialVideoPercentageList[widget.courseName.toString()] = [];
            for (int i = 0; i < list.length; i++) {
              print(_initialVideoPercentageList[widget.courseName.toString()]
                  .runtimeType);
              _initialVideoPercentageList[widget.courseName.toString()]
                  .add({list[i]["id"].toString(): []});
              for (int j = 0; j < list[i]["videos"].length; j++) {
                list[i]["videos"][j]["type"] == "video"
                    ? _initialVideoPercentageList[widget.courseName][i]
                            [list[i]["id"]]
                        .add({list[i]["videos"][j]["id"]: 0})
                    : null;
              }
            }
            print("**** $_initialVideoPercentageList");
            await getUserRole();
            await FirebaseFirestore.instance
                .collection("courseprogress")
                .doc(_auth.currentUser!.uid.toString())
                .set({
              CourseID.toString():
                  _initialVideoPercentageList[widget.courseName.toString()],
              "email": userEmail,
            }).catchError((err) => print("Error$err"));
            print("done----");
            _getVideoPercentageList =
                _initialVideoPercentageList[widget.courseName.toString()];
          }
        });
        setState(() {
          _getVideoPercentageList;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future download({
    Dio? dio,
    String? url,
    String? savePath,
    String? fileName,
    String? courseName,
    String? topicName,
  }) async {
    getPermission();
    var directory = await getApplicationDocumentsDirectory();
    try {
      setState(() {
        downloading = true;
      });
      Response response = await dio!.get(
        url!,
        onReceiveProgress: (rec, total) {
          _downloadProgress.value = rec / total;
        },
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
          validateStatus: (status) {
            return status! < 500;
          },
        ),
      );
      print(response.headers);
      File file = File(savePath!);
      var raf = file.openSync(mode: FileMode.write);
      print('savePath--$savePath');

      raf.writeFromSync(response.data);
      await raf.close();
      DatabaseHelper _dbhelper = DatabaseHelper();
      OfflineModel video = OfflineModel(
          topic: topicName,
          path: '${directory.path}/${fileName!.replaceAll(' ', '')}.mp4');
      _dbhelper.insertTask(video);

      setState(() {
        downloading = false;
        downloaded = true;
      });
    } catch (e) {
      print('e::$e');
    }
  }

  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    super.dispose();
    print("disposeeeee");
    // _videoController!.dispose();
    AutoOrientation.portraitUpMode();
    _disposed = true;
    // _videoController = null;
  }

  String? role;
  String? userEmail;
  String? studentId;
  String? studentName;

  List videos = [];
  getUserRole() async {
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(_auth.currentUser!.uid)
        .get()
        .then((value) {
      setState(() {
        role = value.exists ? value.data()!["role"] : null;
        userEmail = value.exists ? value.data()!['email'] : null;
        studentId = value.exists ? value.data()!['id'] : null;
        studentName = value.exists ? value.data()!['name'] : null;
      });
    });
  }

  streamVideoData() async {
    print("Videoss;");
    print(widget.cID);
    await FirebaseFirestore.instance
        .collection("courses")
        .doc(widget.cID)
        .get()
        .then((value) async {
      // print("!!!!!!!!!!!!!!!!!!!!!!! ${value.data()}");
      Map<String, dynamic>? data = await value.data();
      Counter.counterSinkVideos.add(data != null ? data : null);
    });
  }

  String? currentPlayingVideoName;

  getFirstVideo() async {
    print("Firstvideo---");
    var res = await FirebaseFirestore.instance
        .collection("courses")
        .doc(widget.cID)
        .get();
    var list = res.get("curriculum1")[widget.courseName];
    list.sort((a, b) {
      if (a["sr"] > b["sr"]) {
        return 1;
      }
      return -1;
    });
    list[0]["videos"].sort((a, b) {
      if (a["sr"] > b["sr"]) {
        return 1;
      }
      return -1;
    });
    setState(() {
      currentPlayingVideoName = list[0]["videos"][0]["name"].toString();
    });
    // Get First Vid

    list[0]["videos"][0]["weburl"].toString() != 'null'
        ? initPlayer(list[0]["videos"][0]["weburl"].toString())
        : null;
    // initializeVidController(
    //   list[0]["videos"][0]["url"].toString(),
    //   list[0]["videos"][0]["name"].toString(),
    //   list[0]["modulename"].toString(),
    //   list[0]["id"].toString(),
    //   list[0]["videos"][0]["id"].toString(),
    // );
  }

  getcoursedata(valuepassed) async {
    var coursedata =
        await FirebaseFirestore.instance.collection("courses").get();
    // print("kokokokokok:  ${coursedata.docs})}");
    var data = coursedata.docs;
    List newlist = [];
    data.forEach(
      (element) {
        // print(element['name']);
        if (element['name'] == widget.courseName) {
          var gecoursedata = element['curriculum1'][widget.courseName];
          for (var k in gecoursedata) {
            videos.addAll(k['videos']);
          }
          // print('klklklk....l: $videos');
          // print(gecoursedata);
          for (var i = 1; i <= 20; i++) {
            for (var j in gecoursedata) {
              if (j['sr'] == i) {
                newlist.add(j);
              }
            }
          }
        }
      },
    );
    globalquizstatus();
  }

  globalquizstatus() async {
    List modularquizlist = [];
    for (var j in videos) {
      if (j['type'] == 'quiz') {
        modularquizlist.add(j['name']);
      }
      print("wiefjwoie$modularquizlist");
    }
    print("hoiwejiowj${await modularquizlist}");
    List userquiztakenlist = [];
    bool showglobalquiz = true;
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) async {
      print("fiweofw${await modularquizlist}");
      try {
        print("hoiwejiiweofowowj${modularquizlist}");
        print("quiztaken iwfejo ${value.data()!['quiztrack']}");
        print("hhhhh: ${widget.courseName}");
        globals.quiztrack = value.data()!['quiztrack'];
        try {
          for (var i in value.data()!['quiztrack']) {
            print(
                "wjefweiwoeiw ${i['quizname']} ${i['quizlevel']}  ${i['quizlevel']}");
            if (i['quizlevel'] == 'modulelevel' &&
                i['courseName'] == widget.courseName) {
              if (i['quizCleared'] == false &&
                  i['quizlevel'] == 'modulelevel') {
                setState(() {
                  showglobalquiz = false;
                });
              } else {
                userquiztakenlist.add(i['quizname']);
              }
            } else {
              print("no quiz taken");
              print(i['quizlevel']);
              print(i['courseName']);
              print(i['quizname']);
            }
          }
        } catch (e) {
          print("quiztrack does not exist");
        }

        print("wefiwjeofiw${modularquizlist}");
        print("userquiijowe ${userquiztakenlist.length}");
        print("userquiijow2e ${userquiztakenlist}");
        print("modularquis ijweo ${modularquizlist}");
        if (userquiztakenlist.length != modularquizlist.length) {
          print("yes it is not equal");
          setState(() {
            showglobalquiz = false;
          });
        }

        //("iffwoejf4${modularquizlist.length}");
        if (modularquizlist.length == 0) {
          //("iffwoejf${modularquizlist.length}");
          setState(() {
            showglobalquiz = true;
          });
        }

        setState(() {
          _switchValue = showglobalquiz;
        });
        print(showglobalquiz);
      } catch (e) {
        print("quizid: wej3434434fwio: ${e}");
      }
    });
  }

  updateSessionExpiryTime() async {
    try {
      var learners = await FirebaseFirestore.instance
          .collection('Notice')
          .doc('sessionExpiryDays')
          .get();
      DateTime now = DateTime.now();
      DateTime updatedTime =
          now.add(Duration(days: learners['sessionExpiryDays']));

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        'sessionExpiryTime': Timestamp.fromDate(updatedTime),
      });
    } catch (e) {
      print('updateSessionExpiryTime() $e');
    }
  }

  @override
  void initState() {
    print('wejfiowjoiefjwioefo');
    assignmentDescriptionShowCheck();
    updateSessionExpiryTime();
    assignmentCheck();
    getAssignmentSolutionVideo();
    getAssignmentDescription();
    getScoreOfAllQuiz();
    globalquizstatus();
    VideoScreen.currentSpeed.value = 1.0;
    streamVideoData();
    getCourseQuiz();
    getUserRole();
    getProgressData();
    getpathway(widget.courseName);
    Future.delayed(Duration(milliseconds: 500), () {
      getFirstVideo();
    });
    getcoursedata("");

    super.initState();
  }

  bool _switchValue = false;

  List coursequiz = [];

  getCourseQuiz() async {
    try {
      print("seoiwfjoe");
      print(widget.courseName);
      await FirebaseFirestore.instance
          .collection("courses")
          .where("name", isEqualTo: widget.courseName)
          .get()
          .then((value) {
        print('wewewe1');
        setState(() {
          print('wewewe2');
          try {
            print('wewewe');
            coursequiz = value.docs.first.data()['coursequiz'];
            print("coursequizL: ${coursequiz}");
          } catch (e) {
            setState(() {
              coursequiz = [];
            });
            print("getCourseQuiz: ${e}");
          }
        });

        // print("coursequiz1: ${coursequiz}");
      });
    } catch (e) {
      setState(() {
        coursequiz = [];
      });
      print("ttttttt: ${e.toString()}");
    }
  }

  bool menuClicked = false;
  String solutionUrl = '';
  String assignmentUrl = '';
  int? currentIndex;
  @override
  Widget build(BuildContext context) {
    // List<CourseDetails> course = Provider.of<List<CourseDetails>>(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    var verticalScale = screenHeight / mockUpHeight;
    var horizontalScale = screenWidth / mockUpWidth;
    return Scaffold(
        // floatingActionButton: FloatingActionButton(
        //     onPressed: (){
        //       getScoreOfAllQuiz();
        // }),
        body: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
      if (constraints.maxWidth >= 650) {
        return Container(
          color: Colors.white,
          child: OrientationBuilder(
            builder: (BuildContext context, Orientation orientation) {
              final isPortrait = orientation == Orientation.portrait;
              return Row(
                children: [
                  menuClicked
                      ? isPortrait
                          ? Container()
                          : SizedBox()
                      : Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  // _videoController!.pause();
                                  widget.isDemo == null
                                      ? Navigator.pop(context)
                                      : GoRouter.of(context)
                                          .pushReplacementNamed('myCourses');
                                  // Navigator.pop(context);
                                },
                                child: Container(
                                    child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      Icon(Icons.arrow_back_ios),
                                      Text(
                                        'Back to courses',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      )
                                    ],
                                  ),
                                )),
                              ),
                              Expanded(
                                child: _buildVideoDetails(
                                    // horizontalScale,
                                    // verticalScale,
                                    ),
                              ),
                            ],
                          ),
                        ),
                  !htmlbool
                      ? Expanded(
                          flex: 2,
                          child: showAssignment
                              ? AssignmentScreen(
                                  selectedSection: selectedSection,
                                  courseData: courseData,
                                  courseName: widget.courseName,
                                  assignmentUrl: assignmentUrl,
                                  dataSetUrl: dataSetUrl,
                                  solutionUrl: solutionUrl,
                                  assignmentName: assignmentName,
                                  assignmentDescription: assignmentDescription,
                                  assignmentSolutionVideo:
                                      assignmentSolutionVideo,
                                  assignmentTrackBoolMap:
                                      assignmentTrackBoolMap,
                                  showDescription: assignmentDescriptionShow,
                                )
                              : submitResume
                                  ? SubmitResume(
                                      studentId: studentId ?? '',
                                      studentEmail: userEmail ?? '',
                                      studentName: studentName ?? '',
                                    )
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // UI

                                        videoUrl != null
                                            ? Expanded(
                                                child: HtmlElementView(
                                                viewType: elemtntId,
                                                key: iFrameKey,
                                              ))
                                            : SizedBox(),
                                        // FutureBuilder(
                                        //   future: playVideo,
                                        //   builder: (BuildContext context,
                                        //       AsyncSnapshot<dynamic> snapshot) {
                                        //     if (ConnectionState.done ==
                                        //         snapshot.connectionState) {
                                        //       return Stack(
                                        //         children: [
                                        //           Container(
                                        //             height: menuClicked
                                        //                 ? screenHeight
                                        //                 : screenHeight / 1.2,
                                        //             child: Center(
                                        //               child: AspectRatio(
                                        //                 aspectRatio: 16 / 9,
                                        //                 child: VideoPlayer(
                                        //                     _videoController!),
                                        //               ),
                                        //             ),
                                        //           ),
                                        //           InkWell(
                                        //               onTap: () {
                                        //                 setState(() {
                                        //                   enablePauseScreen =
                                        //                       !enablePauseScreen;
                                        //                   // print(
                                        //                   //     'Container of column clicked');
                                        //                 });
                                        //               },
                                        //               child: Container(
                                        //                 height: menuClicked
                                        //                     ? screenHeight
                                        //                     : screenHeight / 1.2,
                                        //                 width: screenWidth,
                                        //               )),
                                        //           enablePauseScreen
                                        //               ? Container(
                                        //                   height: menuClicked
                                        //                       ? screenHeight
                                        //                       : screenHeight / 1.2,
                                        //                   child: _buildControls(
                                        //                     context,
                                        //                     isPortrait,
                                        //                     horizontalScale,
                                        //                     verticalScale,
                                        //                   ),
                                        //                 )
                                        //               : SizedBox(),
                                        //           _isBuffering && !enablePauseScreen
                                        //               ? Center(
                                        //                   heightFactor: 6.2,
                                        //                   child: Container(
                                        //                     width: 60,
                                        //                     height: 60,
                                        //                     child:
                                        //                         CircularProgressIndicator(
                                        //                       color: Color.fromARGB(
                                        //                         114,
                                        //                         255,
                                        //                         255,
                                        //                         255,
                                        //                       ),
                                        //                     ),
                                        //                   ),
                                        //                 )
                                        //               : Container(),
                                        //         ],
                                        //       );
                                        //     } else {
                                        //       return Container(
                                        //         height: screenHeight / 1.2,
                                        //         child: Center(
                                        //           child: CircularProgressIndicator(
                                        //             color: Color(0xFF7860DC),
                                        //           ),
                                        //         ),
                                        //       );
                                        //     }
                                        //   },
                                        // ),
                                        menuClicked
                                            ? Container()
                                            : Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 15.0),
                                                child: Text(
                                                  videoTitle.toString() !=
                                                          'null'
                                                      ? videoTitle.toString()
                                                      : '',
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontFamily: 'SemiBold'),
                                                ),
                                              ),
                                        isPortrait
                                            ? _buildPartition(
                                                context,
                                                horizontalScale,
                                                verticalScale,
                                              )
                                            : SizedBox(),
                                        isPortrait
                                            ? SizedBox()
                                            // Expanded(
                                            //   flex: 2,
                                            //   child: _buildVideoDetailsListTile(
                                            //     horizontalScale,
                                            //     verticalScale,
                                            //   ),
                                            // )
                                            : SizedBox(),
                                      ],
                                    ),
                        )
                      : quizbool
                          ? Expanded(
                              flex: 2,
                              child: QuizentrypageWidget(
                                quizdata,
                                quizScore: quizScore,
                                quizNameExistsInList: quizNameExistsInList,
                                ontap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            InstructionspageWidget(quizdata)),
                                  ).then((value) {
                                    getScoreOfAllQuiz();
                                  });
                                },
                              ))
                          : Expanded(
                              flex: 2,
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: Padding(
                                  padding: const EdgeInsets.all(50.0),
                                  child: SingleChildScrollView(
                                    child: HtmlWidget('''
                                                $htmltext
                                                '''),
                                  ),
                                ),
                              ),
                            ),
                ],
              );
            },
          ),
        );
      } else {
        return Container(
          color: Colors.white,
          child: OrientationBuilder(
            builder: (BuildContext context, Orientation orientation) {
              final isPortrait = orientation == Orientation.portrait;
              return SingleChildScrollView(
                child: Column(
                  children: [
                    !htmlbool
                        ? showAssignment
                            ? Container(
                                height: Adaptive.h(35),
                                width: Adaptive.w(100),
                                child: AssignmentScreen(
                                  selectedSection: selectedSection,
                                  courseData: courseData,
                                  courseName: widget.courseName,
                                  assignmentUrl: assignmentUrl,
                                  dataSetUrl: dataSetUrl,
                                  solutionUrl: solutionUrl,
                                  assignmentName: assignmentName,
                                  assignmentDescription: assignmentDescription,
                                  assignmentSolutionVideo:
                                      assignmentSolutionVideo,
                                  assignmentTrackBoolMap:
                                      assignmentTrackBoolMap,
                                  showDescription: assignmentDescriptionShow,
                                ),
                              )
                            : submitResume
                                ? SubmitResume(
                                    studentId: studentId ?? '',
                                    studentEmail: userEmail ?? '',
                                    studentName: studentName ?? '',
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // UI

                                      videoUrl != null
                                          ? AspectRatio(
                                              aspectRatio: 16 / 9,
                                              child: HtmlElementView(
                                                viewType: elemtntId,
                                                key: iFrameKey,
                                              ),
                                            )
                                          : SizedBox(),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 15.0),
                                        child: Text(
                                          videoTitle.toString() != 'null'
                                              ? videoTitle.toString()
                                              : '',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontFamily: 'SemiBold'),
                                        ),
                                      ),
                                      isPortrait
                                          ? SizedBox()
                                          // Expanded(
                                          //   flex: 2,
                                          //   child: _buildVideoDetailsListTile(
                                          //     horizontalScale,
                                          //     verticalScale,
                                          //   ),
                                          // )
                                          : SizedBox(),
                                    ],
                                  )
                        : quizbool
                            ? QuizentrypageWidget(
                                quizdata,
                                quizScore: quizScore,
                                quizNameExistsInList: quizNameExistsInList,
                                ontap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            InstructionspageWidget(quizdata)),
                                  ).then((value) {
                                    getScoreOfAllQuiz();
                                  });
                                },
                              )
                            : Align(
                                alignment: Alignment.topCenter,
                                child: Padding(
                                  padding: const EdgeInsets.all(50.0),
                                  child: SingleChildScrollView(
                                    child: HtmlWidget('''
                                                  $htmltext
                                                  '''),
                                  ),
                                ),
                              ),
                    _buildVideoDetails(),
                  ],
                ),
              );
            },
          ),
        );
      }
    }));
  }

  String? assignmentFileName;
  Uint8List? uploadedAssignmentFile;

  String? pdfFileName;
  Uint8List? uploadedpdfFile;

  String? datasetFileName;
  Uint8List? uploadedDatasetFile;
  TextEditingController addAssignmentNameController = TextEditingController();
  TextEditingController assignmentDescriptionController =
      TextEditingController();
  bool addAssignmentLoading = false;

  TextEditingController assignmentLinkController = TextEditingController();
  TextEditingController pdfLinkController = TextEditingController();
  TextEditingController datasetLinkController = TextEditingController();
  bool isToggled = false;

  Widget addAssigmentPopUp({required dynamic listOfSectionData}) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding:
            EdgeInsets.symmetric(horizontal: width / 50, vertical: height / 50),
        width: width / 3,
        decoration: BoxDecoration(
          color: Color(0xffF2E9FE),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 3,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DefaultTextStyle(
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              child: Text(
                'Add Assignment',
                textAlign: TextAlign.left,
              ),
            ),
            SizedBox(
              height: height / 40,
            ),
            Material(
              child: TextFormField(
                controller: addAssignmentNameController,
                decoration: InputDecoration(
                  fillColor: Color(0xffF2E9FE),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.deepPurpleAccent),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  hintText: 'Enter Assignment Name',
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: height / 50,
            ),
            StatefulBuilder(builder: (context, state) {
              return Row(children: [
                Text('Show description?'),
                SizedBox(
                  width: height / 40,
                ),
                CupertinoSwitch(
                  value: isToggled,
                  onChanged: (value) {
                    isToggled = value;
                    setState(() {});
                    print('isToggled $isToggled');
                  },
                ),
              ]);
            }),
            SizedBox(
              height: height / 50,
            ),
            Material(
              child: TextFormField(
                controller: assignmentDescriptionController,
                maxLines: 6,
                decoration: InputDecoration(
                  fillColor: Color(0xffF2E9FE),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.deepPurpleAccent),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  hintText: 'Enter Assignment description',
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: height / 50,
            ),
            addAssignmentBox(
                uploadedFile: uploadedAssignmentFile,
                fileName: assignmentFileName,
                onChooseFile: () async {
                  if (assignmentLinkController.text.isEmpty) {
                    await getAssignmentFile(
                        listOfSectionData: listOfSectionData);
                  } else {
                    Toast.show(
                        'Remove Assignment link if you want to attach file');
                  }
                },
                name: 'Assignment',
                controller: assignmentLinkController,
                onDelete: () {
                  setState(() {
                    uploadedAssignmentFile = null;
                    assignmentFileName = '';
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return addAssigmentPopUp(
                            listOfSectionData: listOfSectionData);
                      },
                    );
                  });
                }),
            SizedBox(
              height: height / 50,
            ),
            addAssignmentBox(
                uploadedFile: uploadedpdfFile,
                fileName: pdfFileName,
                onChooseFile: () async {
                  if (pdfLinkController.text.isEmpty) {
                    await getPdfFile(listOfSectionData: listOfSectionData);
                  } else {
                    Toast.show('Remove Pdf link if you want to attach file');
                  }
                },
                name: 'Pdf',
                controller: pdfLinkController,
                onDelete: () {
                  setState(() {
                    uploadedpdfFile = null;
                    pdfFileName = '';
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return addAssigmentPopUp(
                            listOfSectionData: listOfSectionData);
                      },
                    );
                  });
                }),
            SizedBox(
              height: height / 50,
            ),
            addAssignmentBox(
                uploadedFile: uploadedDatasetFile,
                fileName: datasetFileName,
                onChooseFile: () async {
                  if (datasetLinkController.text.isEmpty) {
                    await getDatasetFile(listOfSectionData: listOfSectionData);
                  } else {
                    Toast.show(
                        'Remove Dataset link if you want to attach file');
                  }
                },
                name: 'Dataset',
                controller: datasetLinkController,
                onDelete: () {
                  setState(() {
                    uploadedDatasetFile = null;
                    datasetFileName = '';
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return addAssigmentPopUp(
                            listOfSectionData: listOfSectionData);
                      },
                    );
                  });
                }),
            SizedBox(
              height: height / 50,
            ),
            Center(
              child: StatefulBuilder(builder: (context, state) {
                return addAssignmentLoading
                    ? CircularProgressIndicator(
                        color: Colors.black, strokeWidth: 2)
                    : ElevatedButton(
                        onPressed: () async {
                          state;
                          addAssignmentLoading = true;
                          addAssignment(listOfSectionData: listOfSectionData)
                              .whenComplete(() {
                            addAssignmentLoading = false;
                            state;
                          });
                          await getAssignmentDescription();
                          await assignmentDescriptionShowCheck();
                        },
                        child: Text("Add Assignment"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurpleAccent,
                        ),
                      );
              }),
            )
          ],
        ),
      ),
    );
  }

  Future getAssignmentFile({required dynamic listOfSectionData}) async {
    FilePickerResult? result;

    try {
      result = await FilePicker.platform.pickFiles(type: FileType.any);
    } catch (e) {
      print(e.toString());
    }

    if (result != null && result.files.isNotEmpty) {
      try {
        Uint8List? uploadFile = result.files.single.bytes;

        String pickedFileName = result.files.first.name;

        setState(() {
          uploadedAssignmentFile = uploadFile;
          assignmentFileName = pickedFileName;
        });

        if (uploadedAssignmentFile != null) {
          Toast.show('Assignment file is attached');
          Navigator.pop(context);
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return addAssigmentPopUp(listOfSectionData: listOfSectionData);
            },
          );
          print('Asssignment File : ${assignmentFileName.toString()}');
        }
      } catch (e) {
        Toast.show(e.toString());
        print(e.toString());
      }
    }
  }

  Future getPdfFile({required dynamic listOfSectionData}) async {
    FilePickerResult? result;

    try {
      result = await FilePicker.platform.pickFiles(type: FileType.any);
    } catch (e) {
      print(e.toString());
    }

    if (result != null && result.files.isNotEmpty) {
      try {
        Uint8List? uploadFile = result.files.single.bytes;

        String pickedFileName = result.files.first.name;

        setState(() {
          uploadedpdfFile = uploadFile;
          pdfFileName = pickedFileName;
        });

        if (uploadedpdfFile != null) {
          Toast.show('Pdf file is attached');
          Navigator.pop(context);
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return addAssigmentPopUp(listOfSectionData: listOfSectionData);
            },
          );
          print('Pdf File : ${pdfFileName.toString()}');
        }
      } catch (e) {
        Toast.show(e.toString());
        print(e.toString());
      }
    }
  }

  Future getDatasetFile({required dynamic listOfSectionData}) async {
    FilePickerResult? result;

    try {
      result = await FilePicker.platform.pickFiles(type: FileType.any);
    } catch (e) {
      print(e.toString());
    }

    if (result != null && result.files.isNotEmpty) {
      try {
        Uint8List? uploadFile = result.files.single.bytes;

        String pickedFileName = result.files.first.name;

        setState(() {
          uploadedDatasetFile = uploadFile;
          datasetFileName = pickedFileName;
        });

        if (uploadedDatasetFile != null) {
          Toast.show('Dataset file is attached');
          Navigator.pop(context);
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return addAssigmentPopUp(listOfSectionData: listOfSectionData);
            },
          );
          print('Dataset File : ${datasetFileName.toString()}');
        }
      } catch (e) {
        Toast.show(e.toString());
        print(e.toString());
      }
    }
  }

  Future addAssignment({required dynamic listOfSectionData}) async {
    if (uploadedAssignmentFile == null &&
        uploadedDatasetFile == null &&
        uploadedpdfFile == null &&
        assignmentLinkController.text.isEmpty &&
        pdfLinkController.text.isEmpty &&
        datasetLinkController.text.isEmpty) {
      setState(() {
        Toast.show('Please Select Assignment Or Pdf Or Dataset');
      });
    } else if (addAssignmentNameController.text.isEmpty) {
      setState(() {
        Toast.show('Please Enter Assignment Name');
      });
    } else {
      try {
        String assignmentUrlLink = '';
        String pdfUrlLink = '';
        String datasetUrlLink = '';
        print('Course Name : ${widget.courseName!}');
        print('Course Id : ${widget.cID!}');

        if (uploadedAssignmentFile != null) {
          var assignmentStorageRef = FirebaseStorage.instance
              .ref()
              .child('courses')
              .child(widget.courseName!)
              .child('assignment')
              .child(assignmentFileName!);

          final UploadTask assignmentUploadTask =
              assignmentStorageRef.putData(uploadedAssignmentFile!);

          final TaskSnapshot downloadUrl = await assignmentUploadTask;
          final String fileURL = (await downloadUrl.ref.getDownloadURL());
          assignmentUrlLink = fileURL;
          print('Assignment link :  $fileURL');
        }

        if (uploadedpdfFile != null) {
          var pdfStorageRef = FirebaseStorage.instance
              .ref()
              .child('courses')
              .child(widget.courseName!)
              .child('solution')
              .child(pdfFileName!);

          final UploadTask pdfUploadTask =
              pdfStorageRef.putData(uploadedpdfFile!);

          final TaskSnapshot downloadUrl = await pdfUploadTask;
          final String fileURL = (await downloadUrl.ref.getDownloadURL());
          pdfUrlLink = fileURL;
          print('Pdf link :  $fileURL');
        }

        if (uploadedDatasetFile != null) {
          var dataSetStorageRef = FirebaseStorage.instance
              .ref()
              .child('courses')
              .child(widget.courseName!)
              .child('dataset')
              .child(datasetFileName!);

          final UploadTask dataSetUploadTask =
              dataSetStorageRef.putData(uploadedDatasetFile!);

          final TaskSnapshot downloadUrl = await dataSetUploadTask;
          final String fileURL = (await downloadUrl.ref.getDownloadURL());
          datasetUrlLink = fileURL;
          print('Dataset link :  $fileURL');
        }

        final firestoreInstance = FirebaseFirestore.instance;

        final courseRef = firestoreInstance.collection('courses');

        try {
          listOfSectionData[widget.courseName][editIndex]['videos'].add({
            if (uploadedDatasetFile != null)
              'dataset': [
                {'name': 'Dataset', 'url': datasetUrlLink}
              ]
            else if (datasetLinkController.text.isNotEmpty)
              'dataset': [
                {'name': 'Dataset', 'url': datasetLinkController.text}
              ],
            'name': addAssignmentNameController.text,
            if (uploadedAssignmentFile != null)
              'url': assignmentUrlLink
            else if (assignmentLinkController.text.isNotEmpty)
              'url': assignmentLinkController.text,
            if (uploadedpdfFile != null)
              'pdf': pdfUrlLink
            else if (pdfLinkController.text.isNotEmpty)
              'pdf': pdfLinkController.text,
            'type': 'assignment',
            'sr': listOfSectionData[widget.courseName][editIndex]['videos']
                .length,
            'description': assignmentDescriptionController.text.isNotEmpty
                ? assignmentDescriptionController.text
                : null,
            'showDescription': isToggled,
          });

          await courseRef.doc(widget.cID).update({
            'curriculum1': {
              widget.courseName: listOfSectionData[widget.courseName]
            }
          }).whenComplete(() {
            setState(() {
              assignmentFileName = null;
              uploadedAssignmentFile = null;

              pdfFileName = null;
              uploadedpdfFile = null;

              datasetFileName = null;
              uploadedDatasetFile = null;
              addAssignmentNameController.text = '';
              assignmentLinkController.clear();
              pdfLinkController.clear();
              datasetLinkController.clear();
              assignmentDescriptionController.clear();
              Navigator.pop(context);
              Toast.show('Assignment Added!!');
            });
          });
        } catch (e) {
          Navigator.pop(context);
          Toast.show('Try Again');

          print('Errrorrr is :: $e');
        }
      } catch (e) {
        Navigator.pop(context);
        Toast.show('Try Again');
      }
    }
  }

  Widget addAssignmentBox(
      {required Uint8List? uploadedFile,
      required String? fileName,
      required VoidCallback onChooseFile,
      required String name,
      required TextEditingController controller,
      required VoidCallback onDelete}) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.deepPurpleAccent, width: 2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onChooseFile,
                  icon: Icon(Icons.upload_file),
                  label: Text("Choose $name",
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.deepPurpleAccent,
                    onPrimary: Colors.white,
                  ),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              DefaultTextStyle(
                style: TextStyle(fontSize: 12, color: Colors.black),
                child: Text(
                  "OR",
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Material(
                  child: TextFormField(
                    controller: controller,
                    onTap: uploadedFile != null
                        ? () {
                            Toast.show('Please Remove Attached File');
                          }
                        : null,
                    readOnly: uploadedFile != null ? true : false,
                    decoration: InputDecoration(
                      fillColor: Color(0xffF2E9FE),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.deepPurpleAccent),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      hintText: '$name Link',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          uploadedFile != null
              ? DefaultTextStyle(
                  style: TextStyle(fontSize: 18, color: Colors.black26),
                  child: Row(
                    children: [
                      Text(
                        fileName!,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      GestureDetector(
                        onTap: onDelete,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: Colors.red),
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      )
                    ],
                  ),
                )
              : DefaultTextStyle(
                  style: TextStyle(fontSize: 18, color: Colors.black26),
                  child: Text(
                    "No file chosen",
                  ),
                ),
        ],
      ),
    );
  }

  // Widget _buildControls(
  //   BuildContext context,
  //   bool isPortrait,
  //   double horizontalScale,
  //   double verticalScale,
  // ) {
  //   final screenHeight = MediaQuery.of(context).size.height;
  //   final screenWidth = MediaQuery.of(context).size.width;
  //   return InkWell(
  //     onTap: () {
  //       setState(() {
  //         enablePauseScreen = !enablePauseScreen;
  //       });
  //     },
  //     child: Container(
  //       height: screenHeight / 3,
  //       width: screenWidth,
  //       color: Color.fromARGB(114, 0, 0, 0),
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           ListTile(
  //             title: Text(
  //               videoTitle.toString() != 'null' ? videoTitle.toString() : '',
  //               textAlign: TextAlign.center,
  //               style: TextStyle(
  //                 color: Colors.white,
  //                 fontSize: 15,
  //               ),
  //             ),
  //             trailing: InkWell(
  //               onTap: () {
  //                 showSettingsBottomsheet(
  //                   context,
  //                   horizontalScale,
  //                   verticalScale,
  //                   _videoController!,
  //                 );
  //                 // var directory = await getApplicationDocumentsDirectory();
  //                 // download(
  //                 //   dio: Dio(),
  //                 //   fileName: data!['name'],
  //                 //   url: data!['url'],
  //                 //   savePath:
  //                 //       "${directory.path}/${data!['name'].replaceAll(' ', '')}.mp4",
  //                 //   topicName: data!['name'],
  //                 // );
  //                 // print(directory.path);
  //               },
  //               child: Icon(
  //                 Icons.settings,
  //                 color: Colors.white,
  //               ),
  //             ),
  //           ),
  //           ValueListenableBuilder(
  //             valueListenable: _currentVideoIndex,
  //             builder: (context, value, child) {
  //               return Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceAround,
  //                 children: [
  //                   _currentVideoIndex.value >= 1
  //                       ? InkWell(
  //                           onTap: () {
  //                             VideoScreen.currentSpeed.value = 1.0;
  //                             _currentVideoIndex.value--;
  //                             initializeVidController(
  //                                 _listOfVideoDetails[_currentVideoIndex.value]
  //                                     .videoUrl,
  //                                 _listOfVideoDetails[_currentVideoIndex.value]
  //                                     .videoTitle,
  //                                 "",
  //                                 "",
  //                                 "");
  //                           },
  //                           child: Icon(
  //                             Icons.skip_previous_rounded,
  //                             color: Colors.white,
  //                             size: 40,
  //                           ),
  //                         )
  //                       : SizedBox(),
  //                   replay10(
  //                     videoController: _videoController,
  //                   ),
  //                   !_isBuffering
  //                       ? InkWell(
  //                           onTap: () {
  //                             if (_isPlaying) {
  //                               setState(() {
  //                                 _videoController!.pause();
  //                               });
  //                             } else {
  //                               setState(() {
  //                                 enablePauseScreen = !enablePauseScreen;
  //                                 _videoController!.play();
  //                               });
  //                             }
  //                           },
  //                           child: Icon(
  //                             _isPlaying ? Icons.pause : Icons.play_arrow,
  //                             color: Colors.white,
  //                             size: 50,
  //                           ),
  //                         )
  //                       : CircularProgressIndicator(
  //                           color: Color.fromARGB(
  //                             114,
  //                             255,
  //                             255,
  //                             255,
  //                           ),
  //                         ),
  //                   fastForward10(
  //                     videoController: _videoController,
  //                   ),
  //                   _currentVideoIndex.value < _listOfVideoDetails.length - 1
  //                       ? InkWell(
  //                           onTap: () {
  //                             VideoScreen.currentSpeed.value = 1.0;
  //                             _currentVideoIndex.value++;
  //                             initializeVidController(
  //                                 _listOfVideoDetails[_currentVideoIndex.value]
  //                                     .videoUrl,
  //                                 _listOfVideoDetails[_currentVideoIndex.value]
  //                                     .videoTitle,
  //                                 "",
  //                                 "",
  //                                 "");
  //                           },
  //                           child: Icon(
  //                             Icons.skip_next_rounded,
  //                             color: Colors.white,
  //                             size: 40,
  //                           ),
  //                         )
  //                       : SizedBox(),
  //                 ],
  //               );
  //             },
  //           ),
  //           Padding(
  //             padding: const EdgeInsets.symmetric(horizontal: 10),
  //             child: Column(
  //               children: [
  //                 Container(
  //                   height: 10,
  //                   child: VideoProgressIndicator(
  //                     _videoController!,
  //                     allowScrubbing: true,
  //                     colors: VideoProgressColors(
  //                       backgroundColor: Color.fromARGB(74, 255, 255, 255),
  //                       bufferedColor: Color(0xFFC0AAF5),
  //                       playedColor: Color(0xFF7860DC),
  //                     ),
  //                   ),
  //                 ),
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                   children: [
  //                     Row(
  //                       children: [
  //                         timeElapsedString(),
  //                         Text(
  //                           '/${_videoController!.value.duration.toString().substring(2, 7)}',
  //                           style: TextStyle(
  //                             color: Colors.white,
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                     IconButton(
  //                       onPressed: () {
  //                         setState(() {
  //                           menuClicked = !menuClicked;
  //                         });
  //                         if (menuClicked) {
  //                           html.document.documentElement?.requestFullscreen();
  //                         } else {
  //                           html.document.exitFullscreen();
  //                           streamVideoData();
  //                         }
  //                       },
  //                       icon: Icon(
  //                         menuClicked
  //                             ? Icons.fullscreen_exit_rounded
  //                             : Icons.fullscreen_rounded,
  //                         color: Colors.white,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Column _buildPartition(
      BuildContext context, double horizontalScale, double verticalScale) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.courseName!,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                fontFamily: "Medium",
              ),
            ),
          ),
        ),
        SizedBox(
          height: 60,
          child: Center(
            child: Row(
              children: [
                SizedBox(width: 20),
                Expanded(child: _buildLecturesTab(context)),
                SizedBox(width: 30),
                Expanded(
                  flex: 1,
                  child: _buildAssignmentTab(
                    context,
                    horizontalScale,
                    verticalScale,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Container _buildLecturesTab(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            'Lectures',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          Container(
            height: 3,
            width: MediaQuery.of(context).size.width * 0.2,
            color: Color(0xFF7860DC),
          )
        ],
      ),
    );
  }

  InkWell _buildAssignmentTab(
      BuildContext context, double horizontalScale, double verticalScale) {
    return InkWell(
      onTap: () {
        setState(() {
          // _videoController!.pause();
          showAssignmentBottomSheet(
            context,
            horizontalScale,
            verticalScale,
          );
        });
      },
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              'Assignments',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            Container(
              height: 3,
              width: MediaQuery.of(context).size.width * 0.25,
              color: Color(0xFF7860DC),
            )
          ],
        ),
      ),
    );
  }

  String selectedSection = '';
  int? selectedIndexOfVideo;
  String? selectedVideoIndexName;
  String? videoTitle;
  List<dynamic> dataSetUrl = [];

  Color color = Colors.black;

  Future<void> getpathway(String? courseName) async {
    List path;
    String jsonString;
    var d;
    try {
      // print("1");
      await FirebaseFirestore.instance
          .collection('courses')
          .where("name", isEqualTo: "${courseName}")
          .get()
          .then((value) async => {
                // print("2"),
                path = await value.docs[0]['pathway'],
                // print("3"),
                for (var i in path)
                  {
                    // print("4"),
                    jsonString = jsonEncode(i),
                    // print("5"),
                    pathwaydata.add(jsonString),
                    // print("6"),
                  },
                // htmltext = pathwaydata[1]['data'],
                d = jsonDecode(pathwaydata[1]),
                htmltext = d['data'],
                // print("7"),
                // print("llll $htmltext")
              });
      // print("pathwaydata ${pathwaydata}");
    } catch (e) {
      // print("pathwaydata -- ${e}");
    }
    ;
  }

  int? dragSectionIndex, dragSubsectionIndex;
  int? subIndex, index;
  bool assignmentDrag = false;
  List<Map<String, dynamic>> listAssignment = [
    {
      "assign": [
        {"assignment": "assignment 1"}
      ],
      "index": 0
    },
    {
      "assign": [
        {"assignment": "assignment 1"}
      ],
      "index": 1
    },
  ];
  String? name, assignmentName;
  bool editModule = false;
  int? editIndex;
  int? editVideoIndex;
  TextEditingController moduleNameController = TextEditingController();
  // int? selectAssignment;
  // int? selectAssignmentSectionIndex;
    Widget _buildVideoDetails() {
    return StreamBuilder<Map<String, dynamic>?>(
        stream: Counter.counterStreamVideos,
        builder: (context, AsyncSnapshot snapshot) {
          // print('dishss ${snapshot}');
          if (snapshot.hasData) {
            // print("snapdata---------- ${snapshot.hasData}}");
            // print('${widget.courseName}');
            var listOfSectionData;
            var id;

            listOfSectionData = snapshot.data["curriculum1"];
            id = snapshot.data["id"];
            // print('cName ${widget.courseName}');
            // print('courseName ${listOfSectionData[widget.courseName]}');
            // print(snapshot.data);
            try {
              listOfSectionData[widget.courseName].sort((a, b) {
                print("---========");
                // print(coursequiz.length);
                // print(a["sr"]);
                if (a["sr"] > b["sr"]) {
                  return 1;
                }
                return -1;
              });
            } catch (e) {
              print('rooor $e ');
            }
            // print("listtttt ${listOfSectionData}");
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children:
                List.generate(listOfSectionData[widget.courseName].length,
                        (sectionIndex) {
                      // var listOfDraggable = List<List>.generate(listOfSectionSort.length, (index) => []);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          sectionIndex == 0
                              ? Padding(
                            padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                            child: Column(
                              children: [
                                pathwaydata.isEmpty
                                    ? Container()
                                    : Container(
                                  child: ExpansionTile(
                                    title: Text(
                                      'Important Instructions',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    children: List.generate(
                                      pathwaydata.length,
                                          (index1) {
                                        Map valueMap = json.decode(
                                            pathwaydata[index1]);
                                        // print("ppppp ${valueMap}");
                                        return Column(
                                          children: [
                                            // videoPercentageList.length != 0 ?
                                            // Text(videoPercentageList[index][courseData.entries.elementAt(index).key][courseData.entries.elementAt(index).value[index1].videoTitle].toString()) : SizedBox(),
                                            GestureDetector(
                                              onTap: () {
                                                print(valueMap['name']);
                                                showAssignment = false;
                                                setState(() {
                                                  currentPosition = 0;
                                                  videoTitle =
                                                  valueMap['name'];
                                                  totalDuration = 0;
                                                });
                                                if (valueMap['type'] ==
                                                    "video") {
                                                  setState(() {
                                                    htmlbool = false;
                                                    enablePauseScreen =
                                                    false;
                                                  });

                                                  selectedIndexOfVideo =
                                                      index1;
                                                  // initPlayer(valueMap['data']);
                                                  //  iFrameKey.currentState!.setState(() {

                                                  //  });;
                                                  // VideoScreen.currentSpeed
                                                  //     .value = 1.0;

                                                  // initializeVidController(
                                                  // valueMap['data'],
                                                  // valueMap['name'],
                                                  // "",
                                                  // "",
                                                  //     "");
                                                } else {
                                                  setState(() {
                                                    htmltext = valueMap[
                                                    'data'];
                                                    enablePauseScreen =
                                                    false;
                                                    htmlbool = true;
                                                  });
                                                }
                                              },
                                              child: Container(
                                                padding:
                                                EdgeInsets.only(
                                                    left: 60,
                                                    top: 15,
                                                    bottom: 15),
                                                child: Align(
                                                  alignment: Alignment
                                                      .centerLeft,
                                                  child: Text(
                                                    valueMap['name'],
                                                    textAlign:
                                                    TextAlign.start,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                              : SizedBox(),
                          // SizedBox(),
                          Text(
                            " ",
                            style: TextStyle(fontSize: 0.5),
                          ),
                          Container(
                            child: ExpansionTile(
                                expandedCrossAxisAlignment:
                                CrossAxisAlignment.stretch,
                                // initiallyExpanded: (widget.courseName == 'Instruction For Mega Combo Course' || widget.courseName == 'Course Introduction For All In One Super Combo') && sectionIndex == 0 ? true : false,
                                title: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: editModule && sectionIndex == editIndex
                                          ? Container(
                                        child: TextField(
                                          controller: moduleNameController,
                                          decoration: InputDecoration(
                                              hintText:
                                              'Enter updated module name',
                                              suffix: IconButton(
                                                  onPressed: () {
                                                    // print('hey ${moduleNameController.text}');
                                                    // print('sectionIndex is $editIndex');
                                                    listOfSectionData[widget
                                                        .courseName]
                                                    [editIndex]
                                                    ['modulename'] =
                                                        moduleNameController
                                                            .text;

                                                    try {
                                                      FirebaseFirestore
                                                          .instance
                                                          .collection(
                                                          'courses')
                                                          .doc(widget.cID)
                                                          .update({
                                                        'curriculum1': {
                                                          '${widget.courseName}':
                                                          listOfSectionData[
                                                          widget
                                                              .courseName],
                                                        }
                                                      }).whenComplete(() =>
                                                          Toast.show(
                                                              'Module name updated successfully.'));
                                                    } catch (e) {
                                                      print(e.toString());
                                                    }
                                                    setState(() {
                                                      editModule = false;
                                                      moduleNameController
                                                          .clear();
                                                      streamVideoData();
                                                    });
                                                    print(
                                                        'hello ${moduleNameController.text}');
                                                    // sectionIndex = sectionIndex;
                                                  },
                                                  icon: Icon(Icons.update))),
                                        ),
                                      )
                                          : Text(
                                        listOfSectionData[widget.courseName]
                                        [sectionIndex]["modulename"]
                                            .toString(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    role == 'mentor'
                                        ? PopupMenuButton<int>(
                                        onSelected: (item) {
                                          if (item == 0) {
                                            setState(() {
                                              editIndex = sectionIndex;
                                            });
                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    alignment:
                                                    Alignment.centerLeft,
                                                    content: Container(
                                                      height: 450,
                                                      width: 350,
                                                      child: Column(
                                                        children: [
                                                          TextField(
                                                            decoration: InputDecoration(
                                                                border:
                                                                OutlineInputBorder(),
                                                                hintText:
                                                                'Enter video name'),
                                                            controller:
                                                            addVideoName,
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          TextField(
                                                            decoration: InputDecoration(
                                                                border:
                                                                OutlineInputBorder(),
                                                                hintText:
                                                                'Enter video url'),
                                                            controller:
                                                            addVideoUrl,
                                                          ),
                                                          SizedBox(
                                                            height: 20,
                                                          ),
                                                          Row(
                                                            children: [
                                                              ElevatedButton(
                                                                  onPressed:
                                                                      () {
                                                                    Random
                                                                    number =
                                                                    Random();
                                                                    int min = 1;
                                                                    int max =
                                                                    1000;
                                                                    int randomNumber = min +
                                                                        number.nextInt(max -
                                                                            min);
                                                                    print(
                                                                        "$randomNumber is in the range of $min and $max");

                                                                    print(
                                                                        'dipen Pau');
                                                                    print('$id' +
                                                                        '${listOfSectionData[widget.courseName][editIndex].length}' +
                                                                        '${listOfSectionData[widget.courseName][editIndex]['videos'].length}');

                                                                    if (addVideoName
                                                                        .text
                                                                        .isNotEmpty &&
                                                                        addVideoUrl
                                                                            .text
                                                                            .isNotEmpty) {
                                                                      listOfSectionData[widget.courseName][editIndex]
                                                                      [
                                                                      'videos']
                                                                          .add({
                                                                        'name':
                                                                        addVideoName.text,
                                                                        'id': '$id' +
                                                                            'V' +
                                                                            '${listOfSectionData[widget.courseName][editIndex].length}' +
                                                                            '$randomNumber',
                                                                        'weburl':
                                                                        addVideoUrl.text,
                                                                        'url': addVideoUrl
                                                                            .text,
                                                                        'type':
                                                                        'video',
                                                                        'offline':
                                                                        false,
                                                                        'demo':
                                                                        false,
                                                                        'sr': listOfSectionData[widget.courseName][editIndex]['videos']
                                                                            .length,
                                                                      });
                                                                      try {
                                                                        FirebaseFirestore
                                                                            .instance
                                                                            .collection(
                                                                            'courses')
                                                                            .doc(widget
                                                                            .cID)
                                                                            .update({
                                                                          'curriculum1':
                                                                          {
                                                                            widget.courseName:
                                                                            listOfSectionData[widget.courseName],
                                                                          }
                                                                        }).whenComplete(() =>
                                                                            Toast.show('New video added'));
                                                                      } catch (e) {
                                                                        print(e
                                                                            .toString());
                                                                      }
                                                                    }
                                                                    print(
                                                                        'added new video name ${addVideoName.text}');

                                                                    setState(
                                                                            () {
                                                                          addVideoId
                                                                              .clear();
                                                                          addVideoUrl
                                                                              .clear();
                                                                          addVideoName
                                                                              .clear();
                                                                          Navigator.of(
                                                                              context)
                                                                              .pop();
                                                                          getProgressData();
                                                                          streamVideoData();
                                                                        });
                                                                  },
                                                                  child: Text(
                                                                      'Submit')),
                                                              SizedBox(
                                                                  width: 20),
                                                              ElevatedButton(
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.of(
                                                                        context)
                                                                        .pop();
                                                                  },
                                                                  child: Text(
                                                                      'Close'))
                                                            ],
                                                            mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                });
                                          }

                                          if (item == 1) {
                                            print('roless $role');
                                            setState(() {
                                              editModule = true;
                                              editIndex = sectionIndex;
                                            });
                                            print('sectionIndex is $editIndex');
                                          }
                                          if (item == 2) {
                                            setState(() {
                                              editIndex = sectionIndex;
                                            });

                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return addAssigmentPopUp(
                                                    listOfSectionData:
                                                    listOfSectionData);
                                              },
                                            );
                                          }
                                          if (item == 3) {
                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    alignment:
                                                    Alignment.centerLeft,
                                                    content: Container(
                                                      height: 250,
                                                      width: 350,
                                                      child: Column(
                                                        children: [
                                                          TextField(
                                                            decoration: InputDecoration(
                                                                border:
                                                                OutlineInputBorder(),
                                                                hintText:
                                                                'Enter module name'),
                                                            controller:
                                                            newModuleName,
                                                          ),
                                                          SizedBox(
                                                            height: 20,
                                                          ),
                                                          Row(
                                                            children: [
                                                              ElevatedButton(
                                                                  onPressed:
                                                                      () {
                                                                    Random
                                                                    number =
                                                                    Random();
                                                                    int min = 2;
                                                                    int max =
                                                                    1000;
                                                                    int randomNumber = min +
                                                                        number.nextInt(max -
                                                                            min);
                                                                    print(
                                                                        "$randomNumber is in the range of $min and $max");

                                                                    if (newModuleName
                                                                        .text
                                                                        .isNotEmpty) {
                                                                      listOfSectionData[
                                                                      widget.courseName]
                                                                          .add({
                                                                        'modulename':
                                                                        newModuleName.text,
                                                                        'id': '${listOfSectionData[widget.courseName][0]['id']}' +
                                                                            '$randomNumber',
                                                                        'videos':
                                                                        [],
                                                                        'sr': listOfSectionData[widget.courseName].length +
                                                                            1,
                                                                      });
                                                                      try {
                                                                        FirebaseFirestore
                                                                            .instance
                                                                            .collection(
                                                                            'courses')
                                                                            .doc(widget
                                                                            .cID)
                                                                            .update({
                                                                          'curriculum1':
                                                                          {
                                                                            widget.courseName:
                                                                            listOfSectionData[widget.courseName],
                                                                          }
                                                                        }).whenComplete(() =>
                                                                            Toast.show('New module added'));
                                                                      } catch (e) {
                                                                        print(e
                                                                            .toString());
                                                                      }
                                                                    }

                                                                    setState(
                                                                            () {
                                                                          newModuleName
                                                                              .clear();
                                                                          Navigator.of(
                                                                              context)
                                                                              .pop();
                                                                          getProgressData();
                                                                          streamVideoData();
                                                                        });
                                                                  },
                                                                  child: Text(
                                                                      'Submit')),
                                                              SizedBox(
                                                                  width: 20),
                                                              ElevatedButton(
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.of(
                                                                        context)
                                                                        .pop();
                                                                  },
                                                                  child: Text(
                                                                      'Close'))
                                                            ],
                                                            mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                });
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          PopupMenuItem<int>(
                                              value: 0,
                                              child:
                                              Text('Add a new video')),
                                          PopupMenuItem<int>(
                                              value: 1,
                                              child:
                                              Text('Edit module name')),
                                          PopupMenuItem<int>(
                                              value: 2,
                                              child:
                                              Text('Add Assignment')),
                                          PopupMenuItem<int>(
                                              value: 3,
                                              child:
                                              Text('Add a new module'))
                                        ])
                                        : SizedBox(),
                                  ],
                                ),
                                children: List.generate(
                                    listOfSectionData[widget.courseName]
                                    [sectionIndex]["videos"]
                                        .length, (subsectionIndex) {
                                  listOfSectionData[widget.courseName][sectionIndex]
                                  ["videos"]
                                      .sort((a, b) {
                                    // print("a=====${a["sr"]}");
                                    if (a["sr"] > b["sr"]) {
                                      return 1;
                                    }
                                    return -1;
                                  });

                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (subIndex != null &&
                                          subIndex == subsectionIndex &&
                                          index == sectionIndex)
                                        Draggable(
                                          data: 0,
                                          child: Container(
                                            color: Colors.purpleAccent,
                                            child: GestureDetector(
                                                onTap: () {
                                                  print(
                                                      'vdo = $videoPercentageList');
                                                  htmlbool = false;
                                                  showAssignment = false;
                                                  if (listOfSectionData[widget
                                                      .courseName]
                                                  [sectionIndex]
                                                  ["videos"]
                                                  [subsectionIndex]
                                                  ["type"] ==
                                                      "video") {
                                                    setState(() {
                                                      currentPosition = 0;
                                                      videoTitle = listOfSectionData[
                                                      widget
                                                          .courseName]
                                                      [sectionIndex]
                                                      ["videos"][
                                                      subsectionIndex]["name"]
                                                          .toString();
                                                      totalDuration = 0;
                                                    });

                                                    // On Vid Change

                                                    initPlayer(listOfSectionData[widget
                                                        .courseName]
                                                    [sectionIndex]
                                                    ["videos"][
                                                    subsectionIndex]["weburl"]
                                                        .toString());
                                                    iFrameKey.currentState!
                                                        .setState(() {});
                                                    ;

                                                    // VideoScreen.currentSpeed.value =
                                                    //     1.0;
                                                    // initializeVidController(
                                                    //     listOfSectionData[widget.courseName][sectionIndex]["videos"]
                                                    //                 [subsectionIndex]
                                                    //             ["url"]
                                                    //         .toString(),
                                                    //     listOfSectionData[widget.courseName][sectionIndex]
                                                    //                 ["videos"][subsectionIndex]
                                                    //             ["name"]
                                                    //         .toString(),
                                                    //     listOfSectionData[widget.courseName]
                                                    //                 [sectionIndex]
                                                    //             ["modulename"]
                                                    //         .toString(),
                                                    //     listOfSectionData[widget.courseName]
                                                    //             [sectionIndex]["id"]
                                                    //         .toString(),
                                                    //     listOfSectionData[widget.courseName]
                                                    //                 [sectionIndex]["videos"]
                                                    //             [subsectionIndex]["id"]
                                                    //         .toString());
                                                  } else if (listOfSectionData[widget
                                                      .courseName]
                                                  [sectionIndex]
                                                  ["videos"]
                                                  [subsectionIndex]["type"] ==
                                                      "quiz") {
                                                    //QuizentrypageWidget
                                                    print(
                                                        "sdjfosjdfoisjdofjsodifjsoijdfoisdfsodfiosjiofdjosdjfoisidfjiowjofowejojiojbdf");
                                                    //  GoRouter.of(context).pushNamed('quizpage');
                                                    setState(() {
                                                      quizdata = listOfSectionData[
                                                      widget.courseName]
                                                      [sectionIndex][
                                                      "videos"][subsectionIndex];
                                                      quizbool = true;
                                                      print("iwoe");
                                                      htmlbool = true;
                                                    });
                                                    checkQuizScore(
                                                        quizdata['name']);
                                                  } else {
                                                    // showAssignment = true;
                                                    setState(() {
                                                      assignmentUrl = listOfSectionData[
                                                      widget
                                                          .courseName]
                                                      [sectionIndex]
                                                      ["videos"][
                                                      subsectionIndex]["url"]
                                                          .toString();

                                                      assignmentName = listOfSectionData[
                                                      widget
                                                          .courseName]
                                                      [sectionIndex]
                                                      ["videos"][
                                                      subsectionIndex]["name"]
                                                          .toString();
                                                      print(assignmentName);
                                                      solutionUrl = listOfSectionData[
                                                      widget
                                                          .courseName]
                                                      [sectionIndex]
                                                      ["videos"][
                                                      subsectionIndex]["pdf"]
                                                          .toString();
                                                      dataSetUrl = listOfSectionData[
                                                      widget.courseName]
                                                      [
                                                      sectionIndex]["videos"]
                                                      [
                                                      subsectionIndex]["dataset"];
                                                    });

                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                AssignmentScreen(
                                                                  selectedSection:
                                                                  selectedSection,
                                                                  courseData:
                                                                  courseData,
                                                                  courseName: widget
                                                                      .courseName,
                                                                  assignmentUrl:
                                                                  assignmentUrl,
                                                                  dataSetUrl:
                                                                  dataSetUrl,
                                                                  solutionUrl:
                                                                  solutionUrl,
                                                                  assignmentName:
                                                                  assignmentName,
                                                                  assignmentDescription:
                                                                  assignmentDescription,
                                                                  assignmentSolutionVideo:
                                                                  assignmentSolutionVideo,
                                                                  assignmentTrackBoolMap:
                                                                  assignmentTrackBoolMap,
                                                                  showDescription:
                                                                  assignmentDescriptionShow,
                                                                )));
                                                    print("Eagle");
                                                  }
                                                },
                                                child: Container(
                                                    padding: EdgeInsets.only(
                                                        left: 60,
                                                        top: 15,
                                                        bottom: 15),
                                                    child: Align(
                                                      alignment:
                                                      Alignment.centerLeft,
                                                      child: Row(
                                                        children: [
                                                          listOfSectionData[widget.courseName]
                                                          [sectionIndex]
                                                          ["videos"]
                                                          [subsectionIndex]
                                                          ["type"] ==
                                                              "video"
                                                              ? Icon(
                                                              Icons.play_circle)
                                                              : listOfSectionData[widget.courseName]
                                                          [sectionIndex]
                                                          [
                                                          "videos"][subsectionIndex]
                                                          [
                                                          "type"] ==
                                                              "quiz"
                                                              ? Icon(Icons.quiz)
                                                              : Icon(Icons
                                                              .assessment),
                                                          SizedBox(
                                                            width: 10,
                                                          ),
                                                          Expanded(
                                                              child: Text(
                                                                listOfSectionData[widget.courseName][sectionIndex]
                                                                ["videos"]
                                                                [subsectionIndex]
                                                                ["type"] ==
                                                                    "video"
                                                                    ? listOfSectionData[widget.courseName]
                                                                [sectionIndex]
                                                                ["videos"][subsectionIndex]
                                                                ["name"]
                                                                    .toString()
                                                                    : listOfSectionData[widget.courseName][sectionIndex]["videos"][subsectionIndex]["type"] ==
                                                                    "quiz"
                                                                    ? "Quiz : " +
                                                                    listOfSectionData[widget.courseName][sectionIndex]["videos"][subsectionIndex]["name"]
                                                                        .toString()
                                                                    : "Assignment : " +
                                                                    listOfSectionData[widget.courseName][sectionIndex]["videos"][subsectionIndex]
                                                                    ["name"]
                                                                        .toString(),
                                                                style: TextStyle(
                                                                    overflow:
                                                                    TextOverflow
                                                                        .ellipsis),
                                                              ))
                                                        ],
                                                      ),
                                                    ))),
                                          ),
                                          feedback: SizedBox(
                                            height: 50,
                                            child: Container(
                                                padding: EdgeInsets.only(
                                                    left: 60, top: 15, bottom: 15),
                                                child: Align(
                                                  alignment: Alignment.centerLeft,
                                                  child: Row(
                                                    children: [
                                                      listOfSectionData[widget.courseName]
                                                      [
                                                      index]
                                                      [
                                                      "videos"]
                                                      [subIndex]
                                                      ["type"] ==
                                                          "video"
                                                          ? Icon(Icons.play_circle)
                                                          : Icon(Icons.assessment),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      DefaultTextStyle(
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            overflow: TextOverflow
                                                                .ellipsis),
                                                        child:
                                                        // Expanded(
                                                        //   child:
                                                        Text(
                                                          listOfSectionData[widget.courseName][index]["videos"]
                                                          [subIndex]
                                                          ["type"] ==
                                                              "video"
                                                              ? listOfSectionData[widget.courseName][index]
                                                          ["videos"]
                                                          [subIndex]
                                                          ["name"]
                                                              .toString()
                                                              : listOfSectionData[widget.courseName][index]["videos"][subIndex]["type"] ==
                                                              "quiz"
                                                              ? "Quiz : " +
                                                              listOfSectionData[widget.courseName][index]["videos"][subIndex]["name"]
                                                                  .toString()
                                                              : "Assignment : " +
                                                              listOfSectionData[widget.courseName][index]["videos"][subIndex]
                                                              ["name"]
                                                                  .toString(),
                                                          style: TextStyle(
                                                              color: Colors.black,
                                                              fontSize: 17,
                                                              fontWeight:
                                                              FontWeight.normal,
                                                              overflow: TextOverflow
                                                                  .ellipsis),
                                                        ),
                                                        // )
                                                      )
                                                    ],
                                                  ),
                                                )),
                                            // width: 50,
                                            // height: 50,
                                          ),
                                        )
                                      else
                                        DragTarget<int>(
                                          builder: (context, _, __) =>
                                              GestureDetector(
                                                  onDoubleTap: () {
                                                    print("doubletap");
                                                    if (role != null) {
                                                      if (role == "mentor") {
                                                        setState(() {
                                                          // selectAssignment = null;
                                                          subIndex =
                                                              subsectionIndex;
                                                          index = sectionIndex;
                                                        });
                                                      }
                                                    }
                                                    print(subsectionIndex);
                                                  },
                                                  onTap: () {
                                                    // _videoController!.pause();
                                                    setState(() {
                                                      currentPlayingVideoName =
                                                          listOfSectionData[widget
                                                              .courseName]
                                                          [
                                                          sectionIndex]
                                                          ["videos"][
                                                          subsectionIndex]["name"]
                                                              .toString();
                                                    });
                                                    if (listOfSectionData[widget.courseName]
                                                    [sectionIndex]
                                                    ["videos"]
                                                    [subsectionIndex]
                                                    ["type"] ==
                                                        "video") {
                                                      print(
                                                          'vdo = $videoPercentageList');
                                                      htmlbool = false;
                                                      showAssignment = false;
                                                      submitResume = false;
                                                      setState(() {
                                                        currentPosition = 0;
                                                        videoTitle = listOfSectionData[
                                                        widget
                                                            .courseName]
                                                        [
                                                        sectionIndex]
                                                        ["videos"][
                                                        subsectionIndex]["name"]
                                                            .toString();
                                                        totalDuration = 0;
                                                      });
                                                      // On Vid Change

                                                      initPlayer(listOfSectionData[
                                                      widget
                                                          .courseName]
                                                      [sectionIndex]
                                                      ["videos"][
                                                      subsectionIndex]["weburl"]
                                                          .toString());
                                                      iFrameKey.currentState!
                                                          .setState(() {});
                                                      ;
                                                      // VideoScreen
                                                      //     .currentSpeed.value = 1.0;

                                                      // initializeVidController(
                                                      //     listOfSectionData[widget.courseName][sectionIndex]["videos"]
                                                      //                 [subsectionIndex]
                                                      //             ["url"]
                                                      //         .toString(),
                                                      //     listOfSectionData[widget.courseName]
                                                      //                     [sectionIndex]["videos"]
                                                      //                 [subsectionIndex]
                                                      //             ["name"]
                                                      //         .toString(),
                                                      //     listOfSectionData[widget.courseName]
                                                      //                 [sectionIndex]
                                                      //             ["modulename"]
                                                      //         .toString(),
                                                      //     listOfSectionData[widget.courseName]
                                                      //                 [sectionIndex]
                                                      //             ["id"]
                                                      //         .toString(),
                                                      //     listOfSectionData[widget.courseName]
                                                      //                 [sectionIndex]["videos"]
                                                      //             [subsectionIndex]["id"]
                                                      //         .toString());
                                                    } else if (listOfSectionData[widget.courseName]
                                                    [sectionIndex]
                                                    ["videos"]
                                                    [subsectionIndex]
                                                    ["type"] ==
                                                        "quiz") {
                                                      print(
                                                          "ll;;;;;;;;;;;;;;;;;;;");
                                                      submitResume = false;
                                                      setState(() {
                                                        quizdata = listOfSectionData[
                                                        widget
                                                            .courseName]
                                                        [sectionIndex][
                                                        "videos"][subsectionIndex];
                                                        htmlbool = true;
                                                        quizbool = true;
                                                      });
                                                      checkQuizScore(
                                                          quizdata['name']);
                                                    } else if (listOfSectionData[widget.courseName]
                                                    [sectionIndex]
                                                    ["videos"]
                                                    [subsectionIndex]
                                                    ["type"] ==
                                                        "resume") {
                                                      setState(() {
                                                        quizbool = false;
                                                        !submitResume
                                                            ? submitResume = true
                                                            : null;
                                                      });
                                                    } else {
                                                      submitResume = false;
                                                      // showAssignment = true;

                                                      setState(() {
                                                        assignmentUrl = listOfSectionData[
                                                        widget
                                                            .courseName]
                                                        [
                                                        sectionIndex]
                                                        ["videos"][
                                                        subsectionIndex]["url"]
                                                            .toString();
                                                        assignmentName = listOfSectionData[
                                                        widget
                                                            .courseName]
                                                        [
                                                        sectionIndex]
                                                        ["videos"][
                                                        subsectionIndex]["name"]
                                                            .toString();
                                                        solutionUrl = listOfSectionData[
                                                        widget
                                                            .courseName]
                                                        [
                                                        sectionIndex]
                                                        ["videos"][
                                                        subsectionIndex]["pdf"]
                                                            .toString();
                                                        dataSetUrl = listOfSectionData[widget.courseName]
                                                        [sectionIndex]
                                                        ["videos"]
                                                        [subsectionIndex]
                                                        ["dataset"] !=
                                                            null
                                                            ? listOfSectionData[widget
                                                            .courseName]
                                                        [
                                                        sectionIndex]
                                                        ["videos"][
                                                        subsectionIndex]["dataset"]
                                                            : [];
                                                      });
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  AssignmentScreen(
                                                                    selectedSection:
                                                                    selectedSection,
                                                                    courseData:
                                                                    courseData,
                                                                    courseName: widget
                                                                        .courseName,
                                                                    assignmentUrl:
                                                                    assignmentUrl,
                                                                    dataSetUrl:
                                                                    dataSetUrl,
                                                                    solutionUrl:
                                                                    solutionUrl,
                                                                    assignmentName:
                                                                    assignmentName,
                                                                    assignmentDescription:
                                                                    assignmentDescription,
                                                                    assignmentSolutionVideo:
                                                                    assignmentSolutionVideo,
                                                                    assignmentTrackBoolMap:
                                                                    assignmentTrackBoolMap,
                                                                    showDescription:
                                                                    assignmentDescriptionShow,
                                                                  )));
                                                      print("Eagle");
                                                    }
                                                  },
                                                  child: Container(
                                                      color: currentPlayingVideoName ==
                                                          listOfSectionData[widget.courseName]
                                                          [sectionIndex]
                                                          ["videos"]
                                                          [subsectionIndex]
                                                          ["name"]
                                                              .toString()
                                                          ? HexColor("#fbedfc")
                                                          : Colors.white,
                                                      //     Colors.red,

                                                      padding: EdgeInsets.only(
                                                          left: listOfSectionData[widget.courseName]
                                                          [sectionIndex]
                                                          ["videos"]
                                                          [subsectionIndex]["type"] ==
                                                              "video"
                                                              ? 60
                                                              : 60,
                                                          top: 15,
                                                          bottom: 15),
                                                      child: Align(
                                                        alignment:
                                                        Alignment.centerLeft,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                          children: [
                                                            listOfSectionData[widget.courseName][sectionIndex]
                                                            ["videos"]
                                                            [subsectionIndex]
                                                            ["type"] ==
                                                                "video"
                                                                ? Icon(Icons.play_circle,
                                                                color:
                                                                Colors.black
                                                              // :null,
                                                            )
                                                                : listOfSectionData[widget.courseName][sectionIndex]["videos"][subsectionIndex]["type"] ==
                                                                "resume"
                                                                ? Icon(Icons
                                                                .reviews)
                                                                : Icon(Icons.assessment,
                                                                color: listOfSectionData[widget.courseName][sectionIndex]["videos"][subsectionIndex]["type"] == "assignment" && assignmentMap[listOfSectionData[widget.courseName][sectionIndex]["videos"][subsectionIndex]["name"].toString()] == listOfSectionData[widget.courseName][sectionIndex]["videos"][subsectionIndex]["name"].toString()
                                                                    ? Colors
                                                                    .green
                                                                    : Colors
                                                                    .purple
                                                              // :null,
                                                            ),
                                                            SizedBox(
                                                              width: 10,
                                                            ),
                                                            _getVideoPercentageList !=
                                                                null &&
                                                                CourseID != null
                                                                ? listOfSectionData[widget.courseName][sectionIndex]["videos"]
                                                            [
                                                            subsectionIndex]
                                                            [
                                                            "type"] ==
                                                                "video"
                                                                ? Expanded(
                                                              child:
                                                              Column(
                                                                crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                                mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                                children: List.generate(
                                                                    _getVideoPercentageList![sectionIndex][listOfSectionData[widget.courseName][sectionIndex]["id"].toString()]
                                                                        .length,
                                                                        (index) {
                                                                      if (_getVideoPercentageList![sectionIndex][listOfSectionData[widget.courseName][sectionIndex]["id"].toString()][index][listOfSectionData[widget.courseName][sectionIndex]["videos"][subsectionIndex]["id"].toString()] !=
                                                                          null) {
                                                                        return updateVideoName && updateVideoIndex == subsectionIndex
                                                                            ? TextField(
                                                                          controller: updateVideoNameController,
                                                                          decoration: InputDecoration(
                                                                              hintText: '${listOfSectionData[widget.courseName][sectionIndex]["videos"][subsectionIndex]["name"]}',
                                                                              suffix: IconButton(
                                                                                onPressed: () {
                                                                                  listOfSectionData[widget.courseName][editIndex]['videos'][updateVideoIndex]['name'] = updateVideoNameController.text;
                                                                                  try {
                                                                                    FirebaseFirestore.instance.collection('courses').doc(widget.cID).update({
                                                                                      'curriculum1': {
                                                                                        widget.courseName: listOfSectionData[widget.courseName],
                                                                                      }
                                                                                    });
                                                                                  } catch (e) {
                                                                                    print(e.toString());
                                                                                  }

                                                                                  setState(() {
                                                                                    streamVideoData();
                                                                                    updateVideoNameController.clear();
                                                                                    updateVideoName = false;
                                                                                  });
                                                                                },
                                                                                icon: Icon(Icons.update_outlined),
                                                                              )),
                                                                        )
                                                                            : Text(
                                                                          listOfSectionData[widget.courseName][sectionIndex]["videos"][subsectionIndex]["type"] == "video"
                                                                              ? listOfSectionData[widget.courseName][sectionIndex]["videos"][subsectionIndex]["name"].toString()
                                                                              : listOfSectionData[widget.courseName][sectionIndex]["videos"][subsectionIndex]["type"] == "quiz"
                                                                              ? "Quiz : " + listOfSectionData[widget.courseName][sectionIndex]["videos"][subsectionIndex]["name"].toString()
                                                                              : listOfSectionData[widget.courseName][sectionIndex]["videos"][subsectionIndex]["type"] == "resume"
                                                                              ? ''
                                                                              : "Assignment : " + listOfSectionData[widget.courseName][sectionIndex]["videos"][subsectionIndex]["name"].toString(),
                                                                          style: TextStyle(overflow: TextOverflow.ellipsis, color: _getVideoPercentageList![sectionIndex][listOfSectionData[widget.courseName][sectionIndex]["id"].toString()][index][listOfSectionData[widget.courseName][sectionIndex]["videos"][subsectionIndex]["id"].toString()] == 100 ? Colors.green : Colors.black),
                                                                        );
                                                                      } else {
                                                                        return SizedBox();
                                                                      }
                                                                    }),
                                                              ),
                                                            )
                                                                : SizedBox()
                                                                : SizedBox(),
                                                            listOfSectionData[widget.courseName]
                                                            [
                                                            sectionIndex]
                                                            [
                                                            "videos"]
                                                            [
                                                            subsectionIndex]["type"] !=
                                                                "video"
                                                                ? Expanded(
                                                              child: editAssignmentName &&
                                                                  updateVideoIndex ==
                                                                      subsectionIndex
                                                                  ? TextField(
                                                                controller:
                                                                updateVideoNameController,
                                                                decoration: InputDecoration(
                                                                    hintText: '${listOfSectionData[widget.courseName][sectionIndex]["videos"][subsectionIndex]["name"]}',
                                                                    suffix: IconButton(
                                                                      onPressed: () {
                                                                        listOfSectionData[widget.courseName][editIndex]['videos'][updateVideoIndex]['name'] = updateVideoNameController.text;
                                                                        try {
                                                                          FirebaseFirestore.instance.collection('courses').doc(widget.cID).update({
                                                                            'curriculum1': {
                                                                              widget.courseName: listOfSectionData[widget.courseName],
                                                                            }
                                                                          });
                                                                        } catch (e) {
                                                                          print(e.toString());
                                                                        }

                                                                        setState(() {
                                                                          streamVideoData();
                                                                          updateVideoNameController.clear();
                                                                          editAssignmentName = false;
                                                                        });
                                                                      },
                                                                      icon: Icon(Icons.update_outlined),
                                                                    )),
                                                              )
                                                                  : Text(
                                                                listOfSectionData[widget.courseName][sectionIndex]["videos"][subsectionIndex]["type"] ==
                                                                    "video"
                                                                    ? ''
                                                                    : listOfSectionData[widget.courseName][sectionIndex]["videos"][subsectionIndex]["type"] == "quiz"
                                                                    ? "Quiz : " + listOfSectionData[widget.courseName][sectionIndex]["videos"][subsectionIndex]["name"].toString()
                                                                    : listOfSectionData[widget.courseName][sectionIndex]["videos"][subsectionIndex]["type"] == "resume"
                                                                    ? listOfSectionData[widget.courseName][sectionIndex]["videos"][subsectionIndex]["name"].toString()
                                                                    : "Assignment : " + listOfSectionData[widget.courseName][sectionIndex]["videos"][subsectionIndex]["name"].toString(),
                                                                style: TextStyle(
                                                                    overflow: TextOverflow
                                                                        .ellipsis,
                                                                    color: listOfSectionData[widget.courseName][sectionIndex]["videos"][subsectionIndex]["type"] == "assignment" && assignmentMap[listOfSectionData[widget.courseName][sectionIndex]["videos"][subsectionIndex]["name"].toString()] == listOfSectionData[widget.courseName][sectionIndex]["videos"][subsectionIndex]["name"].toString()
                                                                        ? Colors.green
                                                                        : Colors.purple
                                                                  // :null
                                                                ),
                                                              ),
                                                            )
                                                                : SizedBox(),
                                                            _getVideoPercentageList !=
                                                                null
                                                                ? listOfSectionData[widget.courseName][sectionIndex]["videos"]
                                                            [
                                                            subsectionIndex]
                                                            [
                                                            "type"] ==
                                                                "video"
                                                                ? Column(
                                                              crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                              mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                              children: List.generate(
                                                                  _getVideoPercentageList![sectionIndex][listOfSectionData[widget.courseName][sectionIndex]["id"].toString()]
                                                                      .length,
                                                                      (index) {
                                                                    if (_getVideoPercentageList![sectionIndex][listOfSectionData[widget.courseName][sectionIndex]["id"].toString()][index]
                                                                    [
                                                                    listOfSectionData[widget.courseName][sectionIndex]["videos"][subsectionIndex]["id"].toString()] !=
                                                                        null) {
                                                                      return Row(
                                                                        children: [
                                                                          Text(
                                                                            _getVideoPercentageList![sectionIndex][listOfSectionData[widget.courseName][sectionIndex]["id"].toString()][index][listOfSectionData[widget.courseName][sectionIndex]["videos"][subsectionIndex]["id"].toString()].toString() + "%",
                                                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: _getVideoPercentageList![sectionIndex][listOfSectionData[widget.courseName][sectionIndex]["id"].toString()][index][listOfSectionData[widget.courseName][sectionIndex]["videos"][subsectionIndex]["id"].toString()] == 100 ? Colors.green : Colors.black),
                                                                          ),
                                                                          //UI

                                                                          Column(
                                                                            children: [
                                                                              Transform.scale(
                                                                                scale: 1,
                                                                                child: Checkbox(
                                                                                  checkColor: _getVideoPercentageList![sectionIndex][listOfSectionData[widget.courseName][sectionIndex]["id"].toString()][index][listOfSectionData[widget.courseName][sectionIndex]["videos"][subsectionIndex]["id"].toString()] == 100 ? Colors.white : Colors.white,
                                                                                  fillColor: _getVideoPercentageList![sectionIndex][listOfSectionData[widget.courseName][sectionIndex]["id"].toString()][index][listOfSectionData[widget.courseName][sectionIndex]["videos"][subsectionIndex]["id"].toString()] == 100
                                                                                      ? MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                                                                                    if (states.contains(MaterialState.disabled)) {
                                                                                      return Colors.green;
                                                                                    }
                                                                                    return Colors.green;
                                                                                  })
                                                                                      : null,
                                                                                  value: _getVideoPercentageList![sectionIndex][listOfSectionData[widget.courseName][sectionIndex]["id"].toString()][index][listOfSectionData[widget.courseName][sectionIndex]["videos"][subsectionIndex]["id"].toString()] == 100 ? true : false,
                                                                                  shape: CircleBorder(),
                                                                                  onChanged: (bool? value) {
                                                                                    setState(() {
                                                                                      if (_getVideoPercentageList![sectionIndex][listOfSectionData[widget.courseName][sectionIndex]["id"].toString()][index][listOfSectionData[widget.courseName][sectionIndex]["videos"][subsectionIndex]["id"].toString()] == 100) {
                                                                                        _getVideoPercentageList![sectionIndex][listOfSectionData[widget.courseName][sectionIndex]["id"].toString()][index][listOfSectionData[widget.courseName][sectionIndex]["videos"][subsectionIndex]["id"].toString()] = 0;
                                                                                      } else {
                                                                                        _getVideoPercentageList![sectionIndex][listOfSectionData[widget.courseName][sectionIndex]["id"].toString()][index][listOfSectionData[widget.courseName][sectionIndex]["videos"][subsectionIndex]["id"].toString()] = 100;
                                                                                      }

                                                                                      updateVideoProgress(_getVideoPercentageList);
                                                                                    });
                                                                                  },
                                                                                ),
                                                                              ),
                                                                              Text(
                                                                                "Mark As Complete",
                                                                                style: TextStyle(fontSize: 10),
                                                                              )
                                                                            ],
                                                                          )
                                                                        ],
                                                                      );
                                                                      // ,
                                                                      // );
                                                                    } else {
                                                                      return SizedBox();
                                                                    }
                                                                  }),
                                                            )
                                                                : SizedBox()
                                                                : SizedBox(),
                                                            SizedBox(
                                                              width: 10,
                                                            ),
                                                            role == 'mentor' &&
                                                                listOfSectionData[widget.courseName][sectionIndex]["videos"]
                                                                [
                                                                subsectionIndex]
                                                                [
                                                                "type"] ==
                                                                    "video"
                                                                ? PopupMenuButton<
                                                                int>(
                                                                onSelected:
                                                                    (item) {
                                                                  if (item ==
                                                                      1) {
                                                                    setState(
                                                                            () {
                                                                          updateVideoNameController
                                                                              .text = listOfSectionData[widget.courseName][sectionIndex]["videos"]
                                                                          [
                                                                          subsectionIndex]
                                                                          [
                                                                          "name"];
                                                                          updateVideoName =
                                                                          true;
                                                                          editIndex =
                                                                              sectionIndex;
                                                                          updateVideoIndex =
                                                                              subsectionIndex;
                                                                        });
                                                                  }
                                                                  if (item ==
                                                                      2) {
                                                                    setState(
                                                                            () {
                                                                          updateVideoName =
                                                                          false;
                                                                          editIndex =
                                                                              sectionIndex;
                                                                          deleteVideoIndex =
                                                                              subsectionIndex;
                                                                        });
                                                                    listOfSectionData[widget.courseName][editIndex]
                                                                    [
                                                                    'videos']
                                                                        .removeAt(
                                                                        deleteVideoIndex);

                                                                    try {
                                                                      FirebaseFirestore
                                                                          .instance
                                                                          .collection(
                                                                          'courses')
                                                                          .doc(widget
                                                                          .cID)
                                                                          .update({
                                                                        'curriculum1':
                                                                        {
                                                                          widget.courseName:
                                                                          listOfSectionData[widget.courseName],
                                                                        }
                                                                      }).whenComplete(() =>
                                                                          Toast.show('Video deleted'));

                                                                      streamVideoData();
                                                                    } catch (e) {
                                                                      print(e
                                                                          .toString());
                                                                    }
                                                                  }
                                                                  if (item ==
                                                                      3) {
                                                                    setState(
                                                                            () {
                                                                          updateVideoIndex =
                                                                              subsectionIndex;
                                                                          editIndex =
                                                                              sectionIndex;
                                                                          updateVideoName =
                                                                          false;
                                                                        });
                                                                    showDialog(
                                                                        context:
                                                                        context,
                                                                        builder:
                                                                            (context) {
                                                                          return AlertDialog(
                                                                            alignment:
                                                                            Alignment.centerLeft,
                                                                            content:
                                                                            Container(
                                                                              height: 250,
                                                                              width: 350,
                                                                              child: Column(
                                                                                children: [
                                                                                  TextField(
                                                                                    controller: updateVideoUrl,
                                                                                    decoration: InputDecoration(
                                                                                      border: OutlineInputBorder(),
                                                                                      hintText: 'Enter updated video URL',
                                                                                    ),
                                                                                  ),
                                                                                  SizedBox(
                                                                                    height: 20,
                                                                                  ),
                                                                                  Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                                    children: [
                                                                                      ElevatedButton(
                                                                                          onPressed: () {
                                                                                            if (updateVideoUrl.text.isNotEmpty) {
                                                                                              listOfSectionData[widget.courseName][editIndex]['videos'][updateVideoIndex]['weburl'] = updateVideoUrl.text;
                                                                                              listOfSectionData[widget.courseName][editIndex]['videos'][updateVideoIndex]['url'] = updateVideoUrl.text;
                                                                                              try {
                                                                                                FirebaseFirestore.instance.collection('courses').doc(widget.cID).update({
                                                                                                  'curriculum1': {
                                                                                                    widget.courseName: listOfSectionData[widget.courseName],
                                                                                                  }
                                                                                                }).whenComplete(() => Toast.show('Video URL updated.'));
                                                                                              } catch (e) {
                                                                                                print(e.toString());
                                                                                              }
                                                                                              setState(() {
                                                                                                updateVideoUrl.clear();
                                                                                                Navigator.of(context).pop();
                                                                                                streamVideoData();
                                                                                              });
                                                                                            } else {
                                                                                              Toast.show('Please enter URL');
                                                                                            }
                                                                                          },
                                                                                          child: Text('Submit')),
                                                                                      SizedBox(width: 20),
                                                                                      ElevatedButton(
                                                                                        onPressed: () {
                                                                                          Navigator.of(context).pop();
                                                                                        },
                                                                                        child: Text('Close'),
                                                                                      )
                                                                                    ],
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          );
                                                                        });
                                                                  }
                                                                },
                                                                itemBuilder:
                                                                    (context) =>
                                                                [
                                                                  PopupMenuItem<int>(
                                                                      value: 1,
                                                                      child: Text('Edit video name')),
                                                                  PopupMenuItem<int>(
                                                                      value: 2,
                                                                      child: Text('Delete video')),
                                                                  PopupMenuItem<int>(
                                                                      value: 3,
                                                                      child: Text('Update video URL')),
                                                                ])
                                                                : SizedBox(),
                                                            role == 'mentor' &&
                                                                listOfSectionData[widget.courseName][sectionIndex]["videos"]
                                                                [
                                                                subsectionIndex]
                                                                [
                                                                "type"] ==
                                                                    "assignment"
                                                                ? PopupMenuButton<
                                                                int>(
                                                              onSelected:
                                                                  (item) {
                                                                if (item ==
                                                                    1) {
                                                                  setState(
                                                                          () {
                                                                        updateVideoName =
                                                                        false;
                                                                        editIndex =
                                                                            sectionIndex;
                                                                        deleteVideoIndex =
                                                                            subsectionIndex;
                                                                      });
                                                                  listOfSectionData[widget.courseName][editIndex]
                                                                  [
                                                                  'videos']
                                                                      .removeAt(
                                                                      deleteVideoIndex);

                                                                  try {
                                                                    FirebaseFirestore
                                                                        .instance
                                                                        .collection(
                                                                        'courses')
                                                                        .doc(widget
                                                                        .cID)
                                                                        .update({
                                                                      'curriculum1':
                                                                      {
                                                                        widget.courseName:
                                                                        listOfSectionData[widget.courseName],
                                                                      }
                                                                    });

                                                                    streamVideoData();
                                                                  } catch (e) {
                                                                    print(e
                                                                        .toString());
                                                                  }
                                                                }
                                                                if (item ==
                                                                    2) {
                                                                  setState(
                                                                          () {
                                                                        updateVideoNameController
                                                                            .text = listOfSectionData[widget.courseName][sectionIndex]["videos"]
                                                                        [
                                                                        subsectionIndex]
                                                                        [
                                                                        "name"];
                                                                        editAssignmentName =
                                                                        true;
                                                                        editIndex =
                                                                            sectionIndex;
                                                                        updateVideoIndex =
                                                                            subsectionIndex;
                                                                      });
                                                                }
                                                                if (item ==
                                                                    3) {
                                                                  setState(
                                                                          () {
                                                                        updateVideoIndex =
                                                                            subsectionIndex;
                                                                        editIndex =
                                                                            sectionIndex;
                                                                        updateVideoName =
                                                                        false;
                                                                      });
                                                                  showDialog(
                                                                      context:
                                                                      context,
                                                                      builder:
                                                                          (context) {
                                                                        return AlertDialog(
                                                                          alignment:
                                                                          Alignment.centerLeft,
                                                                          content:
                                                                          Container(
                                                                            height: 250,
                                                                            width: 350,
                                                                            child: Column(
                                                                              children: [
                                                                                TextField(
                                                                                  controller: updateVideoUrl,
                                                                                  decoration: InputDecoration(
                                                                                    border: OutlineInputBorder(),
                                                                                    hintText: 'Enter updated assignment URL',
                                                                                  ),
                                                                                ),
                                                                                SizedBox(
                                                                                  height: 20,
                                                                                ),
                                                                                Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                                  children: [
                                                                                    ElevatedButton(
                                                                                        onPressed: () {
                                                                                          if (updateVideoUrl.text.isNotEmpty && listOfSectionData[widget.courseName][editIndex]['videos'][updateVideoIndex]['dataset'] != null) {
                                                                                            listOfSectionData[widget.courseName][editIndex]['videos'][updateVideoIndex]['dataset'][0]['url'] = updateVideoUrl.text;
                                                                                            try {
                                                                                              FirebaseFirestore.instance.collection('courses').doc(widget.cID).update({
                                                                                                'curriculum1': {
                                                                                                  widget.courseName: listOfSectionData[widget.courseName],
                                                                                                }
                                                                                              }).whenComplete(() => Toast.show('Assignment URL updated.'));
                                                                                            } catch (e) {
                                                                                              print(e.toString());
                                                                                            }
                                                                                            setState(() {
                                                                                              updateVideoUrl.clear();
                                                                                              Navigator.of(context).pop();
                                                                                              streamVideoData();
                                                                                            });
                                                                                          } else if (updateVideoUrl.text.isNotEmpty) {
                                                                                            listOfSectionData[widget.courseName][editIndex]['videos'][updateVideoIndex]['url'] = updateVideoUrl.text;
                                                                                            try {
                                                                                              FirebaseFirestore.instance.collection('courses').doc(widget.cID).update({
                                                                                                'curriculum1': {
                                                                                                  widget.courseName: listOfSectionData[widget.courseName],
                                                                                                }
                                                                                              }).whenComplete(() => Toast.show('Assignment URL updated.'));
                                                                                            } catch (e) {
                                                                                              print(e.toString());
                                                                                            }
                                                                                            setState(() {
                                                                                              updateVideoUrl.clear();
                                                                                              Navigator.of(context).pop();
                                                                                              streamVideoData();
                                                                                            });
                                                                                          } else {
                                                                                            Toast.show('Please enter URL');
                                                                                          }
                                                                                        },
                                                                                        child: Text('Submit')),
                                                                                    SizedBox(width: 20),
                                                                                    ElevatedButton(
                                                                                      onPressed: () {
                                                                                        Navigator.of(context).pop();
                                                                                      },
                                                                                      child: Text('Close'),
                                                                                    )
                                                                                  ],
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        );
                                                                      });
                                                                }
                                                                if (item ==
                                                                    4) {
                                                                  setState(
                                                                          () {
                                                                        updateVideoIndex =
                                                                            subsectionIndex;
                                                                        editIndex =
                                                                            sectionIndex;
                                                                        updateVideoName =
                                                                        false;
                                                                      });
                                                                  showDialog(
                                                                      context:
                                                                      context,
                                                                      builder:
                                                                          (context) {
                                                                        return AlertDialog(
                                                                          alignment:
                                                                          Alignment.centerLeft,
                                                                          content:
                                                                          Container(
                                                                            height: 700,
                                                                            width: 350,
                                                                            child: Column(
                                                                              children: [
                                                                                TextField(
                                                                                  controller: updateDescription,
                                                                                  maxLines: 6,
                                                                                  decoration: InputDecoration(
                                                                                    border: OutlineInputBorder(),
                                                                                    hintText: 'Enter description',
                                                                                  ),
                                                                                ),
                                                                                SizedBox(
                                                                                  height: 20,
                                                                                ),
                                                                                Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                                  children: [
                                                                                    ElevatedButton(
                                                                                        onPressed: () {
                                                                                          if (updateDescription.text.isNotEmpty && listOfSectionData[widget.courseName][editIndex]['videos'][updateVideoIndex] != null) {
                                                                                            listOfSectionData[widget.courseName][editIndex]['videos'][updateVideoIndex]['description'] = updateDescription.text;
                                                                                            try {
                                                                                              FirebaseFirestore.instance.collection('courses').doc(widget.cID).update({
                                                                                                'curriculum1': {
                                                                                                  widget.courseName: listOfSectionData[widget.courseName],
                                                                                                }
                                                                                              }).whenComplete(() => Toast.show('Assignment Description Updated.'));
                                                                                            } catch (e) {
                                                                                              print(e.toString());
                                                                                            }
                                                                                            setState(() {
                                                                                              updateDescription.clear();
                                                                                              getAssignmentDescription();
                                                                                              Navigator.of(context).pop();
                                                                                              streamVideoData();
                                                                                            });
                                                                                          } else {
                                                                                            Toast.show('Please enter URL');
                                                                                          }
                                                                                        },
                                                                                        child: Text('Submit')),
                                                                                    SizedBox(width: 20),
                                                                                    ElevatedButton(
                                                                                      onPressed: () {
                                                                                        Navigator.of(context).pop();
                                                                                      },
                                                                                      child: Text('Close'),
                                                                                    )
                                                                                  ],
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        );
                                                                      });
                                                                }
                                                                if (item ==
                                                                    5) {
                                                                  setState(
                                                                          () {
                                                                        updateVideoIndex =
                                                                            subsectionIndex;
                                                                        editIndex =
                                                                            sectionIndex;
                                                                        updateVideoName =
                                                                        false;
                                                                      });
                                                                  showDialog(
                                                                      context:
                                                                      context,
                                                                      builder:
                                                                          (context) {
                                                                        return AlertDialog(
                                                                          alignment:
                                                                          Alignment.centerLeft,
                                                                          content:
                                                                          Container(
                                                                            height: 350,
                                                                            width: 350,
                                                                            child: Column(
                                                                              children: [
                                                                                TextField(
                                                                                  controller: updateSolutionVideo,
                                                                                  maxLines: 2,
                                                                                  decoration: InputDecoration(
                                                                                    border: OutlineInputBorder(),
                                                                                    hintText: 'Enter Solution Url',
                                                                                  ),
                                                                                ),
                                                                                SizedBox(
                                                                                  height: 20,
                                                                                ),
                                                                                Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                                  children: [
                                                                                    ElevatedButton(
                                                                                        onPressed: () {
                                                                                          if (updateSolutionVideo.text.isNotEmpty && listOfSectionData[widget.courseName][editIndex]['videos'][updateVideoIndex] != null) {
                                                                                            listOfSectionData[widget.courseName][editIndex]['videos'][updateVideoIndex]['videoUrl'] = updateSolutionVideo.text;
                                                                                            try {
                                                                                              FirebaseFirestore.instance.collection('courses').doc(widget.cID).update({
                                                                                                'curriculum1': {
                                                                                                  widget.courseName: listOfSectionData[widget.courseName],
                                                                                                }
                                                                                              }).whenComplete(() => Toast.show('Assignment solution Updated.'));
                                                                                            } catch (e) {
                                                                                              print(e.toString());
                                                                                            }
                                                                                            setState(() {
                                                                                              updateSolutionVideo.clear();
                                                                                              getAssignmentSolutionVideo();
                                                                                              Navigator.of(context).pop();
                                                                                              streamVideoData();
                                                                                            });
                                                                                          } else {
                                                                                            Toast.show('Please enter URL');
                                                                                          }
                                                                                        },
                                                                                        child: Text('Submit')),
                                                                                    SizedBox(width: 20),
                                                                                    ElevatedButton(
                                                                                      onPressed: () {
                                                                                        Navigator.of(context).pop();
                                                                                      },
                                                                                      child: Text('Close'),
                                                                                    )
                                                                                  ],
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        );
                                                                      });
                                                                }
                                                                if (item ==
                                                                    6) {
                                                                  setState(
                                                                          () {
                                                                        updateVideoIndex =
                                                                            subsectionIndex;
                                                                        editIndex =
                                                                            sectionIndex;
                                                                        updateVideoName =
                                                                        false;
                                                                      });
                                                                  try {
                                                                    if (listOfSectionData[widget.courseName][editIndex]['videos'][updateVideoIndex]['showDescription'] ==
                                                                        null ||
                                                                        listOfSectionData[widget.courseName][editIndex]['videos'][updateVideoIndex]['showDescription'] ==
                                                                            true) {
                                                                      listOfSectionData[widget.courseName][editIndex]['videos'][updateVideoIndex]['showDescription'] =
                                                                      false;
                                                                    } else {
                                                                      listOfSectionData[widget.courseName][editIndex]['videos'][updateVideoIndex]['showDescription'] =
                                                                      true;
                                                                    }
                                                                    FirebaseFirestore
                                                                        .instance
                                                                        .collection(
                                                                        'courses')
                                                                        .doc(widget
                                                                        .cID)
                                                                        .update({
                                                                      'curriculum1':
                                                                      {
                                                                        widget.courseName:
                                                                        listOfSectionData[widget.courseName],
                                                                      }
                                                                    }).whenComplete(() =>
                                                                        Toast.show('Description visibility updated.'));
                                                                    assignmentDescriptionShowCheck();
                                                                  } catch (e) {
                                                                    print(
                                                                        'Description visibility  ${e.toString()}');
                                                                  }
                                                                }
                                                              },
                                                              itemBuilder:
                                                                  (context) =>
                                                              [
                                                                PopupMenuItem<
                                                                    int>(
                                                                    value: 1,
                                                                    child: Text(
                                                                        'Delete assignment')),
                                                                PopupMenuItem<
                                                                    int>(
                                                                    value: 2,
                                                                    child: Text(
                                                                        'Edit assignment name')),
                                                                PopupMenuItem<
                                                                    int>(
                                                                    value: 3,
                                                                    child: Text(
                                                                        'Update assignment URL')),
                                                                PopupMenuItem<
                                                                    int>(
                                                                    value: 4,
                                                                    child: Text(
                                                                        'Update assignment Description')),
                                                                PopupMenuItem<
                                                                    int>(
                                                                    value: 5,
                                                                    child: Text(
                                                                        'Update solution video')),
                                                                PopupMenuItem<
                                                                    int>(
                                                                    value: 6,
                                                                    child: Text(
                                                                        'Toggle Description Visibility'))
                                                              ],
                                                            )
                                                                : SizedBox(),
                                                            listOfSectionData[widget.courseName][sectionIndex]["videos"]
                                                            [
                                                            subsectionIndex]
                                                            [
                                                            "type"] ==
                                                                "quiz" &&
                                                                quizScoreMap[listOfSectionData[widget.courseName][sectionIndex]["videos"]
                                                                [subsectionIndex]
                                                                [
                                                                "name"]] !=
                                                                    null
                                                                ? Text(
                                                                '${quizScoreMap[listOfSectionData[widget.courseName][sectionIndex]["videos"][subsectionIndex]["name"]]} %')
                                                                : Container(),
                                                            role == 'mentor' &&
                                                                listOfSectionData[widget.courseName][sectionIndex]["videos"]
                                                                [
                                                                subsectionIndex]
                                                                [
                                                                "type"] ==
                                                                    "quiz"
                                                                ? PopupMenuButton<
                                                                int>(
                                                              onSelected:
                                                                  (item) {
                                                                if (item ==
                                                                    1) {
                                                                  setState(
                                                                          () {
                                                                        updateVideoName =
                                                                        false;
                                                                        editIndex =
                                                                            sectionIndex;
                                                                        deleteVideoIndex =
                                                                            subsectionIndex;
                                                                      });
                                                                  listOfSectionData[widget.courseName][editIndex]
                                                                  [
                                                                  'videos']
                                                                      .removeAt(
                                                                      deleteVideoIndex);

                                                                  try {
                                                                    FirebaseFirestore
                                                                        .instance
                                                                        .collection(
                                                                        'courses')
                                                                        .doc(widget
                                                                        .cID)
                                                                        .update({
                                                                      'curriculum1':
                                                                      {
                                                                        widget.courseName:
                                                                        listOfSectionData[widget.courseName],
                                                                      }
                                                                    })
                                                                      ..whenComplete(() =>
                                                                          Toast.show('Quiz deleted'));

                                                                    streamVideoData();
                                                                  } catch (e) {
                                                                    print(e
                                                                        .toString());
                                                                  }
                                                                }
                                                              },
                                                              itemBuilder:
                                                                  (context) =>
                                                              [
                                                                PopupMenuItem<
                                                                    int>(
                                                                    value: 1,
                                                                    child: Text(
                                                                        'Delete quiz')),
                                                              ],
                                                            )
                                                                : SizedBox(),
                                                          ],
                                                        ),
                                                      ))),
                                          onAccept: (data) async {
                                            print("data---------");
                                            // print(data);
                                            print("selected sectionIndex=${index}");
                                            print(
                                                "selected subsectionIndex = ${subIndex}");
                                            print(
                                                "subsectionIndex = ${subsectionIndex}");
                                            print("section index= ${sectionIndex}");
                                            print(subsectionIndex);
                                            int count = 0;
                                            if (subIndex != null &&
                                                index != null &&
                                                index == sectionIndex) {
                                              if (subIndex! < subsectionIndex) {
                                                print(true);
                                                for (int i = 0;
                                                i <= subsectionIndex;
                                                i++) {
                                                  print("count===");
                                                  if (i == subIndex) {
                                                    listOfSectionData[widget
                                                        .courseName]
                                                    [sectionIndex]
                                                    ["videos"][i]
                                                    ["sr"] = listOfSectionData[
                                                    widget.courseName]
                                                    [sectionIndex]["videos"]
                                                    [subsectionIndex]["sr"];
                                                    continue;
                                                  }
                                                  print("count===${count}");
                                                  listOfSectionData[widget
                                                      .courseName][sectionIndex]
                                                  ["videos"][i]["sr"] = count;
                                                  count++;
                                                }
                                              } else {
                                                print(false);
                                                count = 0;

                                                ///
                                                for (int j = subsectionIndex;
                                                j <= subIndex!;
                                                j++) {
                                                  // print("count===${count}");
                                                  print("j======${j}");
                                                  if (j == subIndex) {
                                                    listOfSectionData[
                                                    widget.courseName]
                                                    [sectionIndex]["videos"]
                                                    [j]["sr"] = subsectionIndex;
                                                    print(
                                                        "a = ${listOfSectionData[widget.courseName][sectionIndex]["videos"][j]["sr"]}");
                                                  } else {
                                                    listOfSectionData[
                                                    widget.courseName]
                                                    [sectionIndex]["videos"]
                                                    [j]["sr"] = j + 1;
                                                    print(
                                                        "b = ${listOfSectionData[widget.courseName][sectionIndex]["videos"][j]["sr"]}");
                                                  }
                                                }
                                              }
                                              await FirebaseFirestore.instance
                                                  .collection("courses")
                                                  .doc(widget.cID)
                                                  .update({
                                                "curriculum1": listOfSectionData
                                              });
                                              setState(() {
                                                listOfSectionData;
                                                subIndex = null;
                                                index = null;
                                              });
                                            }
                                          },
                                        ),
                                    ],
                                  );
                                })),
                          ),

                          true
                              ? sectionIndex ==
                              listOfSectionData[widget.courseName].length -
                                  1
                              ? coursequiz.runtimeType != Null
                              ? Padding(
                            padding:
                            const EdgeInsets.fromLTRB(5, 0, 5, 0),
                            child: Column(
                              children: [
                                Container(
                                  color: Color.fromARGB(
                                      255, 255, 255, 255),
                                  child: ExpansionTile(
                                    title: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment
                                          .spaceBetween,
                                      children: [
                                        Text(
                                          'Certificate Quiz',
                                          style: TextStyle(
                                              fontWeight:
                                              FontWeight.bold),
                                        ),
                                        true
                                            ? Icon(Icons.lock_open)
                                            : Icon(Icons.lock)
                                      ],
                                    ),
                                    children: true
                                        ? List.generate(
                                      coursequiz.length,
                                          (index1) {
                                        // print("ppppp ${valueMap}");
                                        return Column(
                                          children: [
                                            // videoPercentageList.length != 0 ?
                                            // Text(videoPercentageList[index][courseData.entries.elementAt(index).key][courseData.entries.elementAt(index).value[index1].videoTitle].toString()) : SizedBox(),
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  quizdata =
                                                  coursequiz[
                                                  index1];
                                                  quizbool =
                                                  true;
                                                  htmlbool =
                                                  true;
                                                });
                                              },
                                              child: Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,
                                                children: [
                                                  Container(
                                                    padding: EdgeInsets.only(
                                                        left:
                                                        60,
                                                        top: 15,
                                                        bottom:
                                                        15),
                                                    child:
                                                    Align(
                                                      alignment:
                                                      Alignment
                                                          .centerLeft,
                                                      child:
                                                      Text(
                                                        coursequiz[index1]
                                                        [
                                                        'name'],
                                                        textAlign:
                                                        TextAlign.start,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    )
                                        : [
                                      Container(
                                        child: Center(
                                          child: Text(
                                            "You need to clear all the quiz of this course to unlock this certificate quiz!",
                                            style: TextStyle(
                                                color:
                                                Colors.red),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                              : Container()
                              : Container()
                              : Container()
                        ],
                      );
                    }),
              ),
            );
          } else {
            return Text("Loading...");
          }
        });
  }

  TextEditingController addVideoName = TextEditingController();
  TextEditingController newModuleName = TextEditingController();
  TextEditingController addVideoId = TextEditingController();
  TextEditingController addVideoUrl = TextEditingController();
  bool updateVideoName = false;
  bool editAssignmentName = false;
  int? updateVideoIndex;
  int? deleteVideoIndex;
  String? initialVideoName;
  TextEditingController updateVideoNameController = TextEditingController();
}

class Counter {
  static final _stateStreamControllerVideos =
      StreamController<Map<String, dynamic>?>.broadcast();
  static StreamSink<Map<String, dynamic>?> get counterSinkVideos =>
      _stateStreamControllerVideos.sink;
  static Stream<Map<String, dynamic>?> get counterStreamVideos =>
      _stateStreamControllerVideos.stream;
}

class replay10 extends StatelessWidget {
  const replay10({
    Key? key,
    required VideoPlayerController? videoController,
  })  : _videoController = videoController,
        super(key: key);

  final VideoPlayerController? _videoController;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (() async {
        final currentPosition = await _videoController!.position;
        final newPosition = currentPosition! - Duration(seconds: 10);
        _videoController!.seekTo(newPosition);
      }),
      child: Icon(
        Icons.replay_10,
        size: 40,
        color: Colors.white,
      ),
    );
  }
}

class fastForward10 extends StatelessWidget {
  const fastForward10({
    Key? key,
    required VideoPlayerController? videoController,
  })  : _videoController = videoController,
        super(key: key);

  final VideoPlayerController? _videoController;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (() async {
        final currentPosition = await _videoController!.position;
        final newPosition = currentPosition! + Duration(seconds: 10);
        _videoController!.seekTo(newPosition);
      }),
      child: Icon(
        Icons.forward_10,
        size: 40,
        color: Colors.white,
      ),
    );
  }
}
