@JS()
library stripe;

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:js/js.dart';



  var stripe = Stripe('pk_test_51NHOUASEcX5gh53hu30jRpWYF0EOSLw16gV4OlH9gx0YV6MnyPeAtR01cFljzT7qEn07y6OTDYyxCm8D08zFwQjB00cTztW0EH');


String sessionId = '';
void redirectToCheckout(BuildContext _) async {

await generateSessionId(amount: '1550',productId:  'prod_O4IiCkwPjfYaEl');


sessionId.isNotEmpty ?

 await stripe.redirectToCheckout(CheckoutOptions(
    // lineItems: [
    //   LineItem(
    //  price: 'price_1NIA6fSEcX5gh53hF4EqAo9t', quantity: 1
    //     // amount: 1000,
    //     // currency: 'inr'
    //     ),
    // ],
    sessionId: sessionId,
  //mode: 'payment',
  // currency: 'usd',
   // amount: 1000,
 //  clientSecret: 'sk_test_51NHOUASEcX5gh53hRThS1URuCleeUNZtTty7Wa8c47Jep0LXVFEUz1CYiYkLuU5Bojgfqx2iEzqOSExgl2Vk4b6T00HDNYqWox',
  //  successUrl: 'http://localhost:51612/home',
   // cancelUrl: 'http://localhost:51612/home',
  
  )) : null;





//  final text = result.when(
//         success: (){
//           print('Paid success');
//           return 'Paid';
//         },
//         canceled: () {
//           print('Paid erroe');
//           return 'Paid error';
//         },
//         error: (e) => 'Error $e',
//         redirected: () => 'Redirected succesfully',
//       );
//        ScaffoldMessenger.of(_).showSnackBar(
//         SnackBar(content: Text(text)),
//       );
}

 Future<String> generateSessionId(
       {required String amount,required String productId}) async {
   // var authn = 'Basic ' + base64Encode(utf8.encode('$key:$secret'));

    var headers = {
      'Content-type': 'application/json',
      'Authorization': 'No auth',
    };

    var data =
        '{ "amount": $amount, "product_id": $productId}'; // as per my experience the receipt doesn't play any role in helping you generate a certain pattern in your Order ID!!

    var res = await http.post(
        Uri.parse(
            'https://us-central1-cloudyml-app.cloudfunctions.net/stripeorder/stripeorder'),
        headers: headers,
        body: data);
    if (res.statusCode != 200)
      throw Exception('http.post error: statusCode= ${res.statusCode}');
    print('ORDER ID response => ${res.body}');

    // setState(() {
    //   order_id=json.decode(res.body)['id'].toString();
    // });

    sessionId = json.decode(res.body)['Session'].toString();

   // print("SESS ID :  ${json.decode(res.body)['Session'].toString()}");

    return json.decode(res.body)['Session'].toString();
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
  
  
 

  external factory LineItem({String price, int quantity, String currency, double amount});
}
