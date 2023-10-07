@JS()
library stripe;

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:js/js.dart';

var stripe;

String sessionId = '';
void redirectToCheckout(BuildContext _, {required String amount, required String courseId}) async {
  await getPublishKey();

  await generateSessionId(amount: "3590", productId: 'prod_OlMAp4Vi1uwazG');

  sessionId.isNotEmpty
      ? await stripe.redirectToCheckout(CheckoutOptions(
          sessionId: sessionId,
        ))
      : null;
}

Future<String> generateSessionId(
    {required String amount, required String productId}) async {
  // var authn = 'Basic ' + base64Encode(utf8.encode('$key:$secret'));

  var headers = {
    'Content-type': 'application/json',
    'Authorization': 'No auth',
  };

  var data =
      '{ "amount": "$amount", "product_id": "$productId"}'; // as per my experience the receipt doesn't play any role in helping you generate a certain pattern in your Order ID!!

  var res = await http.post(
      Uri.parse(
          'https://us-central1-cloudyml-app.cloudfunctions.net/stripeorder/stripeorder'),
      headers: headers,
      body: data);
  if (res.statusCode != 200)
    throw Exception('http.post error: statusCode= ${res.statusCode}');
  print('ORDER ID response => ${res.body}');
  sessionId = json.decode(res.body)['Session'].toString();
  return json.decode(res.body)['Session'].toString();
}

getPublishKey() async {
  try {
    await FirebaseFirestore.instance
        .collection('Notice')
        .doc('stripe_key')
        .get()
        .then((value) {
      stripe = Stripe(value.get('publish_key'));
    });
  } catch (e) {
    debugPrint('Error in fetching stripe publish key');
  }
}

getProductId({required String courseId})async{
    try {
    await FirebaseFirestore.instance
        .collection('courses').where('id', isEqualTo: courseId).get().then((value) {

          print('Course : ${value.docs[0].get('name')}');
         
        });
        
  } catch (e) {
    debugPrint('Error in fetching stripe publish key');
  }

}

@JS()
class Stripe {
  external Stripe(String key);

  external redirectToCheckout(CheckoutOptions options);
}

@JS()
@anonymous
class CheckoutOptions {
  external List<LineItem> get lineItems;

  //external String get clientSecret;

  external String get mode;

  external String get sessionId;

  external String get successUrl;

  // external String get currency;

  // external double get amount;

  //external String get successUrl;

  external String get cancelUrl;

  external factory CheckoutOptions({
    List<LineItem> lineItems,
    //  String clientSecret,
    String mode,
    String sessionId,

    //  double amount,
    String successUrl,
    String cancelUrl,
    // String sessionId,
  });
}

@JS()
@anonymous
class LineItem {
  external String get price;

  external int get quantity;

  external String get currency;
  external double get amount;

  external factory LineItem(
      {String price, int quantity, String currency, double amount});
}
