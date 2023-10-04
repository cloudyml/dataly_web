
import 'package:http_auth/http_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PaypalServices {
  String domain = "https://api.paypal.com";
  /// for testing mode
//String domain = "https://api.paypal.com"; /// for production mode
  /// Change the clientId and secret given by PayPal to your own.
  String clientId =
      'AeTwQh7iQ5s89OLrUZ4BwnYC0C5oSkaknAkyDmU-ntrarpLTJ4E35aviyKcblt3x90-BsdM8k9xsxMiJ';
  String secret =
      'EJJVqY0yaylBM98SaqpdSDofm3qInBpx9_QlLqhNrEjnSsFm9ES7hBba702KRoqDFVdtEbXJtqkWR2Vo';
  /// for obtaining the access token from Paypal
  Future<String?> getAccessToken() async {
    try {
      var client = BasicAuthClient(clientId, secret);
      var response = await client.post(
          Uri.parse('$domain/v1/oauth2/token?grant_type=client_credentials'));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        print('${body["access_token"]}');
        return body["access_token"];
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
  // for generating the PayPal payment request
  Future<Map<String, String>?> createPaypalPayment(
      transactions, accessToken) async {
    try {
      var response = await http.post(Uri.parse("$domain/v1/payments/payment"),
          body: jsonEncode(transactions),
          headers: {
            "content-type": "application/json",
            'Authorization': 'Bearer ' + accessToken
          });
      final body = jsonDecode(response.body);
      if (response.statusCode == 201) {

        print('Success full');
        return body;
        if (body["links"] != null && body["links"].length > 0) {
          List links = body["links"];
          String executeUrl = "";
          String approvalUrl = "";
          final item = links.firstWhere((o) => o["rel"] == "approval_url",
              orElse: () => null);
          if (item != null) {
            approvalUrl = item["href"];
          }
          final item1 = links.firstWhere((o) => o["rel"] == "execute",
              orElse: () => null);
          if (item1 != null) {
            executeUrl = item1["href"];
          }
          return {"executeUrl": executeUrl, "approvalUrl": approvalUrl};
        }
        return null;
      } else {
        throw Exception(body["message"]);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// for carrying out the payment process
  Future<String?> executePayment(url, payerId, accessToken) async {
    try {
      var response = await http.post(url,
          body: jsonEncode({"payer_id": payerId}),
          headers: {
            "content-type": "application/json",
            'Authorization': 'Bearer ' + accessToken
          });
      final body = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return body["id"];
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
}