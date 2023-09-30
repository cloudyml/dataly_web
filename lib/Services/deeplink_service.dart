// ignore_for_file: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:cloudyml_app2/global_variable.dart' as globals;
import 'package:cloudyml_app2/globals.dart';

import '../homepage.dart';


class DeepLinkService {
  DeepLinkService._();
  static DeepLinkService? _instance;

  static DeepLinkService? get instance {
    _instance ??= DeepLinkService._();
    return _instance;
  }

  ValueNotifier<String> referrerCode = ValueNotifier<String>('');
  ValueNotifier<String> moneyreferrerCode = ValueNotifier<String>('');

  final dynamicLink = FirebaseDynamicLinks.instance;

  Future<void> handleDynamicLinks() async {
    //Get initial dynamic link if app is started using the link
    final data = await dynamicLink.getInitialLink();
    print("link data is null: ${data}");
    if (data != null) {
      print("link data is not null ${data}");
      _handleDeepLink(data);
    }

    //handle foreground
 
  }

  Future<void> createReferLink(String referCode) async {
    final DynamicLinkParameters dynamicLinkParameters =  DynamicLinkParameters(
      uriPrefix: 'https://cloudymlapp.page.link',
      link: Uri.parse(
          'https://play.google.com/store/apps/details?id=com.cloudyml.cloudymlapp&/refer?code=$referCode'),
      androidParameters: AndroidParameters(
        fallbackUrl: Uri.parse(
            'https://play.google.com/store/apps/details?id=com.cloudyml.cloudymlapp'),
        packageName: 'com.cloudyml.cloudymlapp',
        minimumVersion: 4,
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: 'Share & Earn',
        description:
            'Get Complete Hands-on Practical Learning Experience with CloudyML',
        imageUrl: Uri.parse(
            'https://www.cloudyml.com/wp-content/uploads/2022/11/Share-Your-Friend-And-Earn1.png'),
      ),
    );

    // final shortLink = await dynamicLink.buildShortLink(dynamicLinkParameters);

    // return shortLink.shortUrl.toString();
  }



  Future<void> _handleDeepLink(PendingDynamicLinkData data) async {
    final Uri deepLink = data.link;
    var len = deepLink.toString().length;
    var index = data.link.toString().indexOf("moneyreward");
    print("llllppoooo ${deepLink}");
    print(index);
    print(data.link);
    if (deepLink.toString().length > 15) {
      if (index == -1) {
        var value = deepLink.toString().substring(len - 14, len);
        print("this is value ${value}");
        print(
            "sdfffffffffffffffasdjfaaaaaaaaaaa${index}aajhhjhhhhhhhhhhhh${value}hhhhhaaaaaaaaaaaaaaa ${data.link}");
        referrerCode.value = value;
        print(value);
        print(referrerCode.value);
        referrerCode.notifyListeners();
      } else {
        print(
            "else block: ${index}aajhhjhhhhhhhhhhhhhhhhhaaaaaaaaaaaaaaa ${data.link}");
        var splitingdatalink =
            data.link.toString().split('cloudymlapp&/refer?code=');
        globals.moneyrefcode = splitingdatalink[1];
        
        print("this is refer code: ${globals.moneyrefcode}");
        try {
          if (FirebaseAuth.instance.currentUser?.uid != null) {
            await FirebaseFirestore.instance
                .collection("Users_dataly")
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .update({"sendersmoneyrefcode": splitingdatalink[1]});
          }
        } catch (e) {
          print("ooppooppoopp--: ${e}");
        }

        courseId = globals.moneyrefcode.split('-')[1];
        referrerCode.value = '';
        moneyreferrerCode.value = globals.moneyrefcode[2];
        if (globals.moneyrefcode[2].toString() !=
            FirebaseAuth.instance.currentUser!.uid) {}

        moneyreferrerCode.notifyListeners();
        referrerCode.notifyListeners();
      }
    }
  }
}
