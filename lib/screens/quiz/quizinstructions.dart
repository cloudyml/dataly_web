import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudyml_app2/screens/flutter_flow/flutter_flow_util.dart';
import 'package:cloudyml_app2/screens/quiz/model/quiztrackmodel.dart';
import 'package:cloudyml_app2/screens/quiz/quiz_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../global_variable.dart' as globals;
import 'package:toast/toast.dart';
import '../flutter_flow/flutter_flow_theme.dart';

class InstructionspageWidget extends StatefulWidget {
  var quizdata;
  InstructionspageWidget(this.quizdata, {Key? key}) : super(key: key);

  @override
  _InstructionspageWidgetState createState() => _InstructionspageWidgetState();
}

class _InstructionspageWidgetState extends State<InstructionspageWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _unfocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  checkQuizStatusOrNavigate() async {
    await FirebaseFirestore.instance
        .collection("Users_dataly")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) {
      try {
        var data = value.data()!['quiztrack'];
        bool attemptingquizforthefirsttime = true;
        for (var i in data) {
          if (i != null) {
            i = QuizTrackModel.fromJson(i);
            print(i.quizname);
            print(widget.quizdata['name']);
            try {
              if (i!.quizname == widget.quizdata['name']) {
                attemptingquizforthefirsttime = false;
                print("quiz found");
                print("quiz cleared ppppppppppppp ${i.quizCleared}");
                if (i.quizCleared == true) {
                  print("quiz cleared ppppppppppppp");
                  Toast.show('You have already aced this quiz!');
                  globals.quizCleared = true;
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => QuizPage(widget.quizdata)));
                } else {
                  // condition for quiz not cleared
                  print("quiz not cleared");
                  // condition for course quiz
                  if (i.quizlevel == "courselevel") {
                    if (i.quizAttemptGapForCourseQuiz!
                            .compareTo(DateTime.now()) <
                        0) {
                      print("quiz attempt gap over");
                      print(i.quizAttemptGapForCourseQuiz);
                      print(DateTime.now());
                      // navigate to quiz page
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => QuizPage(widget.quizdata)));
                    } else {
                      print("quiz attempt gap not over");
                      Toast.show(
                        'You can attempt this quiz after ${i.quizAttemptGapForCourseQuiz}',
                      );
                    }
                  } else {
                    print("quiz attempt gap not over");
                    // condition for modular quiz
                    if (i.quizAttemptGapForModularQuiz!
                            .compareTo(DateTime.now()) <
                        0) {
                      // navigate to quiz page
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => QuizPage(widget.quizdata)));
                    } else {
                      print('quiz attempt gap not over');
                      Toast.show(
                          'You can attempt this quiz after ${i.quizAttemptGapForModularQuiz}');
                    }
                  }
                }
              }
            } catch (e) {
              print("error id: ifwjoefjwoeivfff: ${e.toString()}");
            }
          }
        }
        if (attemptingquizforthefirsttime) {
          print("quiz is taken for the first time");
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => QuizPage(widget.quizdata)));
        }
      } catch (e) {
        print("error id: efwefwe3223232: ${e.toString()}");
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => QuizPage(widget.quizdata)));
      }
    });
  }

  @override
  void dispose() {
    _unfocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        },
            icon: Icon(Icons.arrow_back_outlined, color: Colors.black,)),
      ),
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(_unfocusNode),
          child: Align(
            alignment: AlignmentDirectional(0, 0),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.95,
              height: MediaQuery.of(context).size.height *0.9,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                border: Border.all(
                  color: Color(0xFF14181B),
                ),
              ),
              child: ListView(
                padding: EdgeInsets.zero,
                scrollDirection: Axis.vertical,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: Align(
                          alignment: AlignmentDirectional(0, 0),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(0, 5, 0, 0),
                            child: Text(
                              'Instructions',
                              style: FlutterFlowTheme.of(context)
                                  .bodyText1
                                  .override(
                                    fontFamily: 'Urbanist',
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    fontSize: 24,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(5, 20, 0, 0),
                    child: Text(
                      'General instructions',
                      style: FlutterFlowTheme.of(context).bodyText1.override(
                            fontFamily: 'Urbanist',
                            color: FlutterFlowTheme.of(context).primaryText,
                            fontWeight: FontWeight.w900,
                            decoration: TextDecoration.underline,
                          ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(10, 10, 10, 10),
                    child: Text(
                      '1. The Question Palette displayed on the right side of screen will show the status of each question using one of the following symbols:',
                      style: FlutterFlowTheme.of(context).bodyText1.override(
                            fontFamily: 'Urbanist',
                            color: FlutterFlowTheme.of(context).primaryText,
                          ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.1,
                    height: 315.6,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(5, 5, 5, 5),
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryText,
                                ),
                                child: Align(
                                  alignment: AlignmentDirectional(0, 0),
                                  child: Text(
                                    '1',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyText1
                                        .override(
                                          fontFamily: 'Urbanist',
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                          fontSize: 20,
                                        ),
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              'You have not visited the question Yet!',
                              style: FlutterFlowTheme.of(context)
                                  .bodyText1
                                  .override(
                                    fontFamily: 'Urbanist',
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    fontSize: 13,
                                  ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(5, 5, 5, 5),
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Color(0xDEF32B2B),
                                ),
                                child: Align(
                                  alignment: AlignmentDirectional(0, 0),
                                  child: Text(
                                    '3',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyText1
                                        .override(
                                          fontFamily: 'Urbanist',
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                          fontSize: 20,
                                        ),
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              'You have not answered the question',
                              style: FlutterFlowTheme.of(context)
                                  .bodyText1
                                  .override(
                                    fontFamily: 'Urbanist',
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    fontSize: 13,
                                  ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(5, 5, 5, 5),
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                ),
                                child: Align(
                                  alignment: AlignmentDirectional(0, 0),
                                  child: Text(
                                    '5',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyText1
                                        .override(
                                          fontFamily: 'Urbanist',
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                          fontSize: 20,
                                        ),
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              'You have answered the question',
                              style: FlutterFlowTheme.of(context)
                                  .bodyText1
                                  .override(
                                    fontFamily: 'Urbanist',
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    fontSize: 13,
                                  ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(5, 5, 5, 5),
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color:
                                      FlutterFlowTheme.of(context).primaryColor,
                                ),
                                child: Align(
                                  alignment: AlignmentDirectional(0, 0),
                                  child: Text(
                                    '7',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyText1
                                        .override(
                                          fontFamily: 'Urbanist',
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                          fontSize: 20,
                                        ),
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              'You have NOT answered the question,\nbut have marked the question\nfor review.',
                              style: FlutterFlowTheme.of(context)
                                  .bodyText1
                                  .override(
                                    fontFamily: 'Urbanist',
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    fontSize: 13,
                                  ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(5, 5, 5, 5),
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Color(0xFF2488E4),
                                ),
                                child: Align(
                                  alignment: AlignmentDirectional(0, 0),
                                  child: Text(
                                    '9',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyText1
                                        .override(
                                          fontFamily: 'Urbanist',
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                          fontSize: 20,
                                        ),
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              'You have answered the question, but\n marked it for review.',
                              style: FlutterFlowTheme.of(context)
                                  .bodyText1
                                  .override(
                                    fontFamily: 'Urbanist',
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    fontSize: 13,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(5, 0, 5, 0),
                    child: Text(
                      '2. The Marked for Review status for a question simply indicates that you would like to look at that question again.',
                      style: FlutterFlowTheme.of(context).bodyText1.override(
                            fontFamily: 'Urbanist',
                            color: FlutterFlowTheme.of(context).primaryText,
                          ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(5, 0, 5, 0),
                    child: Text(
                      'If a question is answered and Marked for Review, your answer for that question will be considered in the evaluation.',
                      style: FlutterFlowTheme.of(context).bodyText1.override(
                            fontFamily: 'Urbanist',
                            color: Color(0xB1D90808),
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(5, 10, 0, 0),
                    child: Text(
                      'Navigating to a question:',
                      style: FlutterFlowTheme.of(context).bodyText1.override(
                            fontFamily: 'Urbanist',
                            color: FlutterFlowTheme.of(context).primaryText,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            decoration: TextDecoration.underline,
                          ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(5, 10, 5, 0),
                    child: Text(
                      '3. To answer a question, do the following:\na. Click on the question number in the Wuestion Palette to go to that numbered question directly.\nb. Click on Save & Next to save your answer for the current question and then go to the next question.\nc. Click on Mark for Review & Next to save your answer for the current question, mark if for review, and then go the next question.\nd. Caution: Note that your answer for the current question will not be saved, if you navigate to another question directly by clicking on its question number.\n4. You can view all the questions by clicking on the Question Pager button. Note that the options for multiple choice type questions will not be shown.',
                      style: FlutterFlowTheme.of(context).bodyText1.override(
                            fontFamily: 'Urbanist',
                            color: FlutterFlowTheme.of(context).primaryText,
                          ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(5, 10, 0, 0),
                    child: Text(
                      'Answering a Question:',
                      style: FlutterFlowTheme.of(context).bodyText1.override(
                            fontFamily: 'Urbanist',
                            color: FlutterFlowTheme.of(context).primaryText,
                            fontWeight: FontWeight.w900,
                            decoration: TextDecoration.underline,
                          ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(5, 5, 5, 0),
                    child: Text(
                      '5. Procedure for answering a multiple choice type question:\na. To select your answer, click on the button of one of the options.\nb. To deselect your chosen answer, click on the button of the chosen option again or click on the Clear Response\nbutton.\nc. To change your chosen answer, click on the button of another option.\nd. To save your answer, you MUST click on teh save & Next Button.\ne. To mark the question for review, click on the Mark for Review & Next button.\nf. If an answer is selected for a question that is \'Marked for Review\', that answer will be considered in the evaluation even if it is not marked as \'Save & Next\', at the time of final submission.\n\n6. To change your answer to a question that has already been answered, first select that question for answering and then\nfollow the procedure for answering that type of question.\n7. Note that questions for which option has been chosen and answers are saved or marked for review will be considered for evaluation.',
                      style: FlutterFlowTheme.of(context).bodyText1.override(
                            fontFamily: 'Urbanist',
                            color: FlutterFlowTheme.of(context).primaryText,
                          ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      checkQuizStatusOrNavigate();
                    },
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(5, 5, 5, 5),
                      child: Container(
                        width: 40,
                        height: 50,
                        decoration: BoxDecoration(
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: Colors.green,
                            width: 2,
                          ),
                        ),
                        child: Align(
                          alignment: AlignmentDirectional(0, 0),
                          child: Text(
                            'Start',
                            style:
                                FlutterFlowTheme.of(context).bodyText1.override(
                                      fontFamily: 'Urbanist',
                                      color: Colors.green,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                          ),
                        ),
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
}
