import 'package:flutter/material.dart';

class ThankYouPageStripe extends StatelessWidget {
  const ThankYouPageStripe({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Payment Successfull', style: TextStyle(fontSize: 30),),
      ),
    );
  }
}