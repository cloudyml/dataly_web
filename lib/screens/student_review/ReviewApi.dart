import 'package:http/http.dart' as http;
import 'dart:convert';

Future<String> postReview(reviewData) async {
  final String apiUrl =
      "https://us-central1-cloudyml-app.cloudfunctions.net/postDatalyReview";

  // Convert the data to JSON
  String requestBody = json.encode({"data": reviewData});

  // Set the headers for the request
  Map<String, String> headers = {
    'Content-Type': 'application/json',
  };

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: headers,
      body: requestBody,
    );

    if (response.statusCode == 200) {
      // Request was successful, and you can handle the response data here
      print("Review successfully posted!");
      print("Response data: ${response.body}");
      return 'Review successfully posted!';
    } else {
      // Request failed
      print("Failed to post review. Status code: ${response.statusCode}");
      print("Response data: ${response.body}");
      return 'Failed to post review. Status code: ${response.statusCode}';
    }
  } catch (e) {
    print("Error: $e");
    return 'Error: $e';
  }
}

getReviewsApi() async {
  var headers = {'Content-Type': 'application/json'};

  final response = await http.post(
    Uri.parse('https://us-central1-cloudyml-app.cloudfunctions.net/getDatalyReviews'),
    headers: headers,
    body: '{"data": {}}',
  );

  if (response.statusCode == 200) {
    print('efjwiefjwo$response');
    return response.body;
  } else {
    print(response.reasonPhrase);
    return 'error';
  }
}
