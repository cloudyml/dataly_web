import 'dart:async';
import 'dart:core';
import 'dart:core';
import 'dart:core';
import 'dart:html' as html;
import 'dart:js';
import 'package:cloudyml_app2/screens/flutter_flow/flutter_flow_util.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:toast/toast.dart';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudyml_app2/Notifications/web_messaging.dart';
import 'package:cloudyml_app2/Providers/AppProvider.dart';
import 'package:cloudyml_app2/Providers/UserProvider.dart';
import 'package:cloudyml_app2/Providers/chat_screen_provider.dart';
import 'package:cloudyml_app2/Services/database_service.dart';
import 'package:cloudyml_app2/authentication/firebase_auth.dart';
import 'package:cloudyml_app2/models/course_details.dart';
import 'package:cloudyml_app2/models/video_details.dart';
import 'package:cloudyml_app2/router/login_state_check.dart';
import 'package:cloudyml_app2/router/router.dart';
import 'package:cloudyml_app2/screens/chat_screen.dart';
import 'package:cloudyml_app2/screens/review_screen/review_screen.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:cloudyml_app2/screens/splash.dart';
import 'package:cloudyml_app2/services/local_notificationservice.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:renderer_switcher/renderer_switcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:go_router/go_router.dart';

import 'authentication_screens/phone_auth.dart';
import 'homepage.dart';

Future<void> backgroundHandler(RemoteMessage message) async {}

Future<void> main() async {
  await Hive.initFlutter();
  await Hive.openBox('myBox');
  await Hive.openBox("NotificationBox");
  setPathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  final state = LoginState(await SharedPreferences.getInstance());
  state.checkLoggedIn();

  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyBdAio1wI3RVwl32RoKE7F9GNG_oWBpfbM",
          appId: "1:67056708090:web:f4a43d6b987991016ddc43",
          messagingSenderId: "67056708090",
          projectId: "cloudyml-app",
          storageBucket: "cloudyml-app.appspot.com",
          databaseURL: "https://cloudyml-app-default-rtdb.firebaseio.com",
          authDomain: "cloudyml-app.firebaseapp.com"));
  if (kIsWeb) {
    await FirebaseAuth.instance.authStateChanges().first;
  }
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  LocalNotificationService.initialize();
  //FBMessaging().init();

  runApp(MyApp(
    loginState: state,
  ));

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );

  html.window.document.onContextMenu.listen((evt) => evt.preventDefault());
  final currentRenderer = await RendererSwitcher.getCurrentWebRenderer();

  if (currentRenderer == WebRenderer.auto) {
    RendererSwitcher.switchWebRenderer(WebRenderer.html);
  }

  print('this is url ${Uri.base.path}');
  print(DateFormat('dd-MM-yyyy').format(DateTime.now()));

  if (Uri.base.path == '/comboPaymentPortal') {
    print('abc home');

    if (Uri.base.queryParameters['cID'] == 'aEGX6kMfHzQrVgP3WCwU') {
      final url = Uri.base.queryParameters['cID'];
      FirebaseFirestore.instance
          .collection("Notice")
          .doc("NBrEm6KGry8gxOJJkegG_redirect_pay")
          .set({'url': url});
    } else if (Uri.base.queryParameters['cID'] == 'RIUjOvGBV6YSzMTpMWEG') {
      final url = Uri.base.queryParameters['cID'];
      FirebaseFirestore.instance
          .collection("Notice")
          .doc("HX4neryeAOB1dzUeIAg1_prompt")
          .set({'url': url});
    }else if (Uri.base.queryParameters['cID'] == 'F9gxnjW9nf5Lxg5A6758') {
      final url = Uri.base.queryParameters['cID'];
      FirebaseFirestore.instance
          .collection("Notice")
          .doc("M2jEwYyiWdzYWE9gJd8s_de_pay")
          .set({'url': url});
    } else if (Uri.base.queryParameters['cID'] == 'XSNqt0oNpuY7i2kb7zsW') {
      final url = Uri.base.queryParameters['cID'];
      FirebaseFirestore.instance
          .collection("Notice")
          .doc("o1Hw1CebDH9I4VfpKuiC_sup_pay")
          .set({'url': url});
    }

    final url = Uri.base.path;

    print('pushed');
  } else if (Uri.base.path == '/InternationalPaymentScreen') {
    final url = Uri.base.path;
    FirebaseFirestore.instance
        .collection("Notice")
        .doc("7A85zuoLi4YQpbXlbOAh_redirect")
        .set({'url': url});

    print('pushed');
  } else if (Uri.base.path == '/NewFeature') {
    if (Uri.base.queryParameters['cID'] == 'aEGX6kMfHzQrVgP3WCwU') {
      final url = Uri.base.queryParameters['cID'];
      FirebaseFirestore.instance
          .collection("Notice")
          .doc("XdYtk2DJBIkRGx0ASthZ_newfeaturecourse")
          .set({'url': url});
    } else if (Uri.base.queryParameters['cID'] == 'F9gxnjW9nf5Lxg5A6758') {
      final url = Uri.base.queryParameters['cID'];
      FirebaseFirestore.instance
          .collection("Notice")
          .doc("fSU4MLz1E0858ft8m7F5_dataeng")
          .set({'url': url});
    } else if (Uri.base.queryParameters['cID'] == 'mPqg2Z2BdNHvwaqAEfA0') {
      final url = Uri.base.queryParameters['cID'];
      FirebaseFirestore.instance
          .collection("Notice")
          .doc("ZL5fDjF0pzsgpNu92BKc_intrntnl_course")
          .set({'url': url});
    }
    print('pushed');
  } else if (Uri.base.path == '/multiComboFeatureScreen') {
    if (Uri.base.queryParameters['cID'] == 'XSNqt0oNpuY7i2kb7zsW') {
      final url = Uri.base.queryParameters['cID'];
      FirebaseFirestore.instance
          .collection("Notice")
          .doc("JnCFQ1bT36xl0xKjDL3a_superstar")
          .set({'url': url});
    }
  }
}

class MyApp extends StatefulWidget {
  final LoginState loginState;

  MyApp({required this.loginState});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    debugInvertOversizedImages = false;
    return ChangeNotifierProvider(
        create: (context) => GoogleSignInProvider(),
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider(
                create: (_) => ChatScreenNotifier(), child: ChatScreen()),
            ChangeNotifierProvider.value(value: UserProvider.initialize()),
            ChangeNotifierProvider.value(value: AppProvider()),
            ChangeNotifierProvider<LoginState>(
              lazy: false,
              create: (BuildContext createContext) => widget.loginState,
            ),
            Provider<MyRouter>(
              lazy: false,
              create: (BuildContext createContext) =>
                  MyRouter(widget.loginState),
            ),
            StreamProvider<List<CourseDetails>>.value(
              value: DatabaseServices().courseDetails,
              initialData: [],
            ),
            StreamProvider<List<VideoDetails>>.value(
              value: DatabaseServices().videoDetails,
              initialData: [],
            ),
          ],
          child: Sizer(builder: ((context, orientation, deviceType) {
            return ResponsiveSizer(builder: (context, orientation, screenType) {
              final botToastBuilder = BotToastInit();
              final router =
                  Provider.of<MyRouter>(context, listen: false).routes;
              return GetMaterialApp.router(
                routerDelegate: router.routerDelegate,
                routeInformationParser: router.routeInformationParser,
                routeInformationProvider: router.routeInformationProvider,
                debugShowCheckedModeBanner: false,
                title: 'Dataly',
                scrollBehavior: MyCustomScrollBehavior(),
                builder: (BuildContext context, child) {
                  child = MediaQuery(
                    child: child!,
                    data:
                        MediaQuery.of(context).copyWith(textScaleFactor: 1.15),
                  );
                  child = botToastBuilder(context, child);
                  ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
                    return Container();
                  };
                  botToastBuilder(context, widget);
                  return child;
                },
                theme: ThemeData(
                  primarySwatch: Colors.blue,
                  scrollbarTheme: ScrollbarThemeData(
                    thumbColor:
                        MaterialStateProperty.all<Color>(Colors.purpleAccent),

                    interactive: true, // Set the desired color
                    // thumbVisibility:
                    //     false, // You can set this to true if you want the scrollbar to be always visible
                  ),
                ),
              );
            });
          })),
        ));
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}
