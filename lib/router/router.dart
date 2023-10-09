import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudyml_app2/MyAccount/myaccount.dart';
import 'package:cloudyml_app2/all_certificate_screen.dart';
import 'package:cloudyml_app2/combo/combo_course.dart';
import 'package:cloudyml_app2/combo/combo_store.dart';
import 'package:cloudyml_app2/combo/multi_combo_course.dart';
import 'package:cloudyml_app2/combo/multi_combo_feature_screen.dart';
import 'package:cloudyml_app2/combo/new_combo_course.dart';
import 'package:cloudyml_app2/combo/updated_combo_course.dart';
import 'package:cloudyml_app2/home.dart';
import 'package:cloudyml_app2/homepage.dart';
import 'package:cloudyml_app2/homescreen/homescreen.dart';
import 'package:cloudyml_app2/live_doubt_screen/live_doubt_session.dart';
import 'package:cloudyml_app2/module/review%20resume/review_resume.dart';
import 'package:cloudyml_app2/module/review%20resume/review_resume_detailed.dart';
import 'package:cloudyml_app2/module/video_screen.dart';
import 'package:cloudyml_app2/payment/stripe/thankyou.dart';
import 'package:cloudyml_app2/payment_screen.dart';
import 'package:cloudyml_app2/payments_history.dart';
import 'package:cloudyml_app2/router/error_page.dart';
import 'package:cloudyml_app2/screens/chat_screen.dart';
import 'package:cloudyml_app2/screens/chatpage.dart';
import 'package:cloudyml_app2/screens/groups_list.dart';
import 'package:cloudyml_app2/screens/quiz/quizList.dart';
import 'package:cloudyml_app2/screens/quiz/quiz_new_combo_course.dart';
import 'package:cloudyml_app2/screens/splash.dart';
import 'package:cloudyml_app2/store.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import '../authentication_screens/phone_auth.dart';
import '../catalogue_screen.dart';
import '../combo/feature_courses.dart';
import '../combo/trialfeatutr.dart';
import '../international_payment_screen.dart';
import '../models/course_details.dart';
import '../my_Courses.dart';
import '../screens/add_new_course/add_new_course.dart';
import '../screens/assignment_tab_screen.dart';
import '../screens/coupon/create_coupon.dart';
import '../screens/groupscreen.dart';
import '../screens/quiz/admin_quiz.dart';
// import '../screens/quiz/all_certificate_screen.dart';
import '../screens/quiz/multi_combo_module.dart';
import '../screens/quiz/quiz_page.dart';
import '../screens/quiz/quiz_panel.dart';
import '../screens/quiz/quizentry.dart';
import '../screens/quiz/quizesofenrolledcourses.dart';
import '../screens/review_screen/review_screen.dart';
import 'login_state_check.dart';

class MyRouter {
  final LoginState loginState;
  MyRouter(this.loginState);

  late final GoRouter routes = GoRouter(
      initialLocation: '/',
      refreshListenable: loginState,
      redirect: (context, GoRouterState state) {
        final loggedIn = loginState.loggedIn;
        final goingToLogin = state.location == ('/login');

        // final dc = state.location == ('/comboPaymentPortal?cID=aEGX6kMfHzQrVgP3WCwU');

        // final pc=state.location==('/featuredCourses?cID=aEGX6kMfHzQrVgP3WCwU&courseName=Data+Science+%26+Analytics+Placement+Assurance+Program&id=0&coursePrice=9999');

        if (!loggedIn && !goingToLogin) {
          return ('/');
        } else if (loggedIn && goingToLogin) {
          return ('/home');
        } else {
          return null;
        }
      },
      routes: <RouteBase>[
        GoRoute(
            path: '/',
            pageBuilder: (context, state) {
              return MaterialPage(child: splash());
            }),
        GoRoute(
          path: '/login',
          pageBuilder: (context, state) {
            return MaterialPage(child: LoginPage());
          },
        ),
        GoRoute(
            name: 'home',
            path: '/home',
            pageBuilder: (context, state) {
              return MaterialPage(child: LandingScreen());
            }),
        GoRoute(
            name: 'AssignmentScreenForMentors',
            path: '/AssignmentScreenForMentors',
            pageBuilder: (context, state) {
              return MaterialPage(child: Assignments());
            }),
        GoRoute(
            name: 'store',
            path: '/store',
            pageBuilder: (context, state) {
              return MaterialPage(child: StoreScreen());
            }),
        GoRoute(
          name: 'createcoupon',
          path: '/createcoupon',
          pageBuilder: (context, state) {
            return MaterialPage(key: state.pageKey, child: CreateCoupon());
          },
        ),
        GoRoute(
          name: 'quizpanel',
          path: '/quizpanel',
          pageBuilder: (context, state) {
            return MaterialPage(key: state.pageKey, child: QuizPanel());
          },
        ), //CongratulationsWidget
        GoRoute(
          name: 'reviews',
          path: '/reviews',
          pageBuilder: (context, state) {
            return MaterialPage(child: ReviewsScreen());
          },
        ),
        GoRoute(
            name: 'myAccount',
            path: '/myAccount',
            pageBuilder: (context, state) {
              return MaterialPage(child: MyAccountPage());
            }),
        GoRoute(
            name: 'mychat',
            path: '/mychat',
            pageBuilder: (context, state) {
              return MaterialPage(child: ChatPage());
            }),
        GoRoute(
            name: 'mobilechat',
            path: '/mobilechat',
            pageBuilder: ((context, state) {
              return MaterialPage(child: GroupPage());
            })),
        GoRoute(
            name: 'NewComboCourseScreen',
            path: '/NewComboCourseScreen',
            pageBuilder: (context, state) {
              final String courseId = state.queryParams['courseId']!;
              final String courseName = state.queryParams['courseName']!;
              return MaterialPage(
                  key: state.pageKey,
                  child: NewComboCourse(
                    courseName: courseName,
                    courseIdd: courseId,
                  ));
            }),
        GoRoute(
            name: 'QuizNewComboCourseScreen',
            path: '/QuizNewComboCourseScreen',
            pageBuilder: (context, state) {
              final String courseId = state.queryParams['courseId']!;
              final String courseName = state.queryParams['courseName']!;
              return MaterialPage(
                  key: state.pageKey,
                  child: QuizNewComboCourse(
                    courseName: courseName,
                    courseIdd: courseId,
                  ));
            }),
        GoRoute(
            name: 'chat',
            path: '/chat',
            pageBuilder: (context, state) {
              return MaterialPage(child: GroupsList());
            }),

            GoRoute(
          name: 'success',
          path: '/sucess',
          pageBuilder: (context, state) {
            return MaterialPage(child: ThankYouPageStripe());
          },
        ),
        GoRoute(
            name: 'MultiComboFeatureScreen',
            path: '/multiComboFeatureScreen',
            pageBuilder: (context, state) {
              final String cID = state.queryParams['cID']!;
              final String id = state.queryParams['id']!;
              final String courseName = state.queryParams['courseName']!;
              final String coursePrice = state.queryParams['coursePrice']!;
              return MaterialPage(
                  key: state.pageKey,
                  child: MultiComboFeatureScreen(
                    id: id,
                    courseName: courseName,
                    coursePrice: coursePrice,
                    cID: cID,
                  ));
            }),
        GoRoute(
            name: 'MultiComboCourseScreen',
            path: '/multiComboCourseScreen',
            pageBuilder: (context, state) {
              //  final String cID = state.queryParams['cID']!;
              final String id = state.queryParams['id']!;
              final String courseName = state.queryParams['courseName']!;
              //           final String coursePrice = state.queryParams['coursePrice']!;
              return MaterialPage(
                  key: state.pageKey,
                  child: MultiComboCourse(
                    id: id,
                    courseName: courseName,
                    // coursePrice: coursePrice,
                    // cID: cID,
                  ));
            }),
        GoRoute(
            name: 'MultiComboModuleScreen',
            path: '/multiComboModuleScreen',
            pageBuilder: (context, state) {
              //  final String cID = state.queryParams['cID']!;
              final String id = state.queryParams['id']!;
              final String courseName = state.queryParams['courseName']!;
              //           final String coursePrice = state.queryParams['coursePrice']!;
              return MaterialPage(
                  key: state.pageKey,
                  child: MultiComboModule(
                    id: id,
                    courseName: courseName,
                    // coursePrice: coursePrice,
                    // cID: cID,
                  ));
            }),
        GoRoute(
            path: '/paymentHistory',
            pageBuilder: (context, state) {
              return MaterialPage(child: PaymentHistory());
            }),
        GoRoute(
          name: 'LiveDoubtSession',
          path: '/LiveDoubtSession',
          pageBuilder: (context, state) {
            return MaterialPage(key: state.pageKey, child: LiveDoubtScreen());
          },
        ),
        GoRoute(
          name: 'myCourses',
          path: '/myCourses',
          pageBuilder: (context, state) {
            return MaterialPage(key: state.pageKey, child: HomeScreen());
          },
        ),
        GoRoute(
          name: 'AdminQuizPanel',
          path: '/adminquizpanel',
          pageBuilder: (context, state) {
            return MaterialPage(key: state.pageKey, child: AdminQuizPanel());
          },
        ), //CongratulationsWidget
        GoRoute(
          name: 'AllCertificateScreen',
          path: '/allcertificatescreen',
          pageBuilder: (context, state) {
            return MaterialPage(
                key: state.pageKey, child: AllCertificateScreen());
          },
        ), //CongratulationsWidget
        GoRoute(
          name: 'Quizes',
          path: '/quizes',
          pageBuilder: (context, state) {
            return MaterialPage(
                key: state.pageKey, child: QuizesOfEnrolledCourses());
          },
        ),
        GoRoute(
          name: 'AddCourse',
          path: '/addNewCourse',
          pageBuilder: (context, state) {
            return MaterialPage(child: AddNewCourseScreen());
          },
        ),
        GoRoute(
          name: 'QuizPage',
          path: '/quizpage',
          pageBuilder: (context, state) {
            return MaterialPage(key: state.pageKey, child: QuizPage(""));
          },
        ),

        GoRoute(
          name: 'quizentry',
          path: '/quizentry',
          pageBuilder: (context, state) {
            return MaterialPage(
                key: state.pageKey, child: QuizentrypageWidget('param'));
          },
        ),
        GoRoute(
          name: 'catalogue',
          path: '/catalogue',
          pageBuilder: (context, state) {
            List<CourseDetails> course =
                Provider.of<List<CourseDetails>>(context);
            final String id = state.queryParams["id"]!;
            final String cID = state.queryParams['cID']!;
            return MaterialPage<void>(
                key: state.pageKey,
                child: CatelogueScreen(
                    courses: course[int.parse(id)].courses,
                    id: id,
                    cID: cID));
          },
        ),
        GoRoute(
            name: 'comboStore',
            path: '/comboStore',
            pageBuilder: (context, state) {
              List<CourseDetails> course =
                  Provider.of<List<CourseDetails>>(context);
              final String id = state.queryParams['id']!;
              final String courseName = state.queryParams['courseName']!;
              final String coursePrice = state.queryParams['coursePrice']!;
              return MaterialPage(
                  key: state.pageKey,
                  child: ComboStore(
                    courses: course[int.parse(id)].courses,
                    id: id,
                    cName: courseName,
                    courseP: coursePrice,
                  ));
            }),
        // GoRoute(
        //     name: 'featuredCourses',
        //     path: '/featuredCourses',
        //     pageBuilder: (context, state) {
        //       final String cID = state.queryParams['cID']!;
        //       final String id = state.queryParams['id']!;
        //       final String courseName = state.queryParams['courseName']!;
        //       final String coursePrice = state.queryParams['coursePrice']!;
        //       return MaterialPage(
        //           key: state.pageKey,
        //           child: FeatureCourses(
        //             cID: cID,
        //             id: id,
        //             cName: courseName,
        //             courseP: coursePrice,
        //           ));
        //     }
        // ),
        GoRoute(
            name: 'NewFeature',
            path: '/NewFeature',
            pageBuilder: (context, state) {
              List<CourseDetails> course =
                  Provider.of<List<CourseDetails>>(context);
              final String cID = state.queryParams['cID']!;
              final String id = state.queryParams['id']!;
              final String courseName = state.queryParams['courseName']!;
              final String coursePrice = state.queryParams['coursePrice']!;
              return MaterialPage(
                  key: state.pageKey,
                  child: NewFeature(
                    courses: course[int.parse(id)].courses,
                    id: id,
                    cID: cID,
                    courseP: coursePrice,
                    courseName: courseName,
                  ));
            }),
        GoRoute(
            name: 'NewScreen',
            path: '/NewScreen',
            pageBuilder: (context, state) {
              List<CourseDetails> course =
                  Provider.of<List<CourseDetails>>(context);
              final String id = state.queryParams['id']!;
              final String courseName = state.queryParams['courseName']!;
              return MaterialPage(
                  key: state.pageKey,
                  child: NewScreen(
                    courses: course[int.parse(id)].courses,
                    id: id,
                    courseName: courseName,
                  ));
            }),
        GoRoute(
            name: 'reviewResume',
            path: '/reviewResume',
            pageBuilder: (context, state) {
              return MaterialPage(child: ReviewResumeScreen());
            }),
        GoRoute(
            name: 'reviewResumeDetailed',
            path: '/reviewResumeDetailed',
            pageBuilder: (context, state) {
              String? id = state.queryParams['studentId'];
              String? name = state.queryParams['studentName'];
              String? email = state.queryParams['studentEmail'];
              String? link = state.queryParams['resumeLink'];
              return MaterialPage(
                  child: ReviewDetailScreen(
                studentId: id!,
                studentName: name!,
                studentEmail: email!,
                resumeLink: link!,
              ));
            }),
        GoRoute(
            name: 'comboCourse',
            path: '/comboCourse',
            pageBuilder: (context, state) {
              List<CourseDetails> course =
                  Provider.of<List<CourseDetails>>(context);
              final String id = state.queryParams['id']!;
              final String courseName = state.queryParams['courseName']!;
              return MaterialPage(
                  key: state.pageKey,
                  child: ComboCourse(
                    courses: course[int.parse(id)].courses,
                    id: id,
                    courseName: courseName,
                  ));
            }),
        GoRoute(
            name: 'videoScreen',
            path: '/videoScreen',
            pageBuilder: (context, state) {
              // final bool isDemo = state.queryParams['isDemo']! as bool;
              // final int sr = state.queryParams['sr']! as int;
              final String courseName = state.queryParams['courseName']!;
              final String cID = state.queryParams['cID']!;
              return MaterialPage(
                  child: VideoScreen(
                isDemo: true,
                cID: cID,
                courseName: courseName,
                sr: 1,
              ));
            }),
        GoRoute(
            name: 'quizlist',
            path: '/quizlist',
            pageBuilder: (context, state) {
              // final bool isDemo = state.queryParams['isDemo']! as bool;
              // final int sr = state.queryParams['sr']! as int;
              final String courseName = state.queryParams['courseName']!;
              final String cID = state.queryParams['cID']!;
              return MaterialPage(
                  child: QuizList(
                isDemo: true,
                cID: cID,
                courseName: courseName,
                sr: 1,
              ));
            }),
        GoRoute(
            name: 'newcomboCourse',
            path: '/newcomboCourse',
            pageBuilder: (context, state) {
              List<CourseDetails> course =
                  Provider.of<List<CourseDetails>>(context);
              final String id = state.queryParams['id']!;
              final String courseName = state.queryParams['courseName']!;
              return MaterialPage(
                  key: state.pageKey,
                  child: NewScreen(
                    courses: course[int.parse(id)].courses,
                    id: id,
                    courseName: courseName,
                  ));
            }),
        GoRoute(
            name: 'comboVideoScreen',
            path: '/comboVideoScreen',
            pageBuilder: (context, state) {
              // final bool isDemo = state.queryParams['isDemo']! as bool;
              // final int sr = state.queryParams['sr']! as int;
              final String cID = state.queryParams['cID']!;
              final String courseName = state.queryParams['courseName']!;
              return MaterialPage(
                  child: VideoScreen(
                isDemo: null,
                courseName: courseName,
                cID: cID,
                sr: null,
              ));
            }),
        GoRoute(
            name: 'comboPaymentPortal',
            path: '/comboPaymentPortal',
            pageBuilder: (context, state) {
              // final Map<String, dynamic> courseMap = state.queryParams['courseMap']! as Map<String, dynamic>;
              String cID = state.queryParams['cID']!;
              return MaterialPage(
                child: PaymentScreen(
                  cID: cID,
                  isItComboCourse: true,
                  // map: {},
                ),
              );
            }),
        GoRoute(
            name: 'InternationalPaymentScreen',
            path: '/InternationalPaymentScreen',
            pageBuilder: (context, state) {
              String cID = state.queryParams['cID']!;
              // Map<String, dynamic> courseMap =
              // state.queryParams['courseMap']! as Map<String, dynamic>;
              return MaterialPage(
                child: InternationalPaymentScreen(
                    cID: cID,
                    // map: courseMap,
                    isItComboCourse: false),
              );
            }),

        GoRoute(
            name: 'paymentPortal',
            path: '/paymentPortal',
            pageBuilder: (context, state) {
              String cID = state.queryParams['cID']!;
              // Map<String, dynamic> courseMap =
              // state.queryParams['courseMap']! as Map<String, dynamic>;
              return MaterialPage(
                child: PaymentScreen(
                    cID: cID,
                    // map: courseMap,
                    isItComboCourse: false),
              );
            }),
        GoRoute(
            name: 'chatWindow',
            path: '/chatWindow',
            pageBuilder: (context, state) {
              // dynamic groupData = state.queryParams['groupData']! as dynamic;
              // final userData = state.queryParams['userData']! as dynamic;
              String? groupId = state.queryParams['groupId']!;
              // Object chatScreen = state.extra!;
              return MaterialPage(
                  child: ChatScreen(
                // userData: userData,
                // groupData: groupData,
                groupId: groupId,
              ));
            }),
        GoRoute(
            name: 'studentChat',
            path: '/studentChat',
            pageBuilder: (context, state) {
              // Object? chatScreen = state.extra!;
              String? groupId = state.queryParams['groupId']!;
              return MaterialPage(
                  child: ChatScreen(
                groupId: groupId,
                // chatScreen: chatScreen,
              ));
            }),
        // GoRoute(
        //     name: 'videoNameClass',
        //     path: '/videoNameClass',
        //     builder: (context, state) {
        //       final String videoName = state.queryParams['videoName']!;
        //       final dynamic videoController = state.queryParams['videoController']!;
        //       return videoNameClass(
        //         videoName: videoName,
        //         videoController: videoController,
        //       );
        //     },
        // ),
      ],
      errorPageBuilder: (context, state) {
        return MaterialPage(key: state.pageKey, child: ErrorPage());
      });
}
