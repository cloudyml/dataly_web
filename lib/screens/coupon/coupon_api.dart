import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:cloudyml_app2/global_variable.dart' as globals;

import 'models/createCouponModel.dart';

void printWrapped(String text) {
  final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
  pattern.allMatches(text).forEach((match) => print(match.group(0)));
}

class CreateCouponApi {
  static createCoupon(CreateCouponModel createCouponInfo) async {
    try {
      print(createCouponInfo.toJson());
      // get firebase id token for authentication

      String? token = await FirebaseAuth.instance.currentUser!.getIdToken();
      print("iowefjowe");
      var url = Uri.parse(
          'https://us-central1-cloudyml-app.cloudfunctions.net/datalyCreateCoupon');
      print("fwefewf");

      var data = createCouponInfo.toJson();

      var body = json.encode({"data": data});
      print(body);
      var response = await http.post(url, body: body, headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      });
      print("iowefjwefwefwowe");
      print(token);
      if (response.statusCode == 200) {
        var jsonString = response.body;
        return "Success";
      } else {
        print(response.statusCode);
        print(response.body);
        return response.body;
      }
    } catch (e) {
      print(e);
      return "Failed to create coupon!";
    }
  }

  static verifyCoupon(couponCode) async {
    try {
      // get firebase id token for authentication
      String? token = await FirebaseAuth.instance.currentUser!.getIdToken();
      var url = Uri.parse(
          'https://us-central1-cloudyml-app.cloudfunctions.net/datalyCheckCouponCode');
      var data = {"couponCode": "$couponCode"};
      var body = json.encode({"data": data});
      print(body);
      var response = await http.post(url, body: body, headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      });
      print("iowefjwefwefwowe");
      print(token);
      if (response.statusCode == 200) {
        var jsonString = response.body;
        print(response.body);
        return {"Success": true, "message": response.body};
      } else {
        print(response.statusCode);
        print(response.body);
        return {"Success": false, "message": response.body};
      }
    } catch (e) {
      print(e);
      return "Failed to get coupon!";
    }
  }
}
