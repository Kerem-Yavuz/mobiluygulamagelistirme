import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobiluygulamagelistirme/constants.dart';
class ComplaintData {
  // Static list to hold complaint data in memory
  static List<Map<String, String>> allComplaints = [];


  // Async method to fetch complaints from the server
  static Future<void> getComplaints() async {
    const url = '${BASE_URL}/getComplaints';


    // Get stored token from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('cookie') ?? '';  // Get 'cookie' or use empty string if not found


    // Prepare headers including the token in a cookie format
    final headers = {
      'Content-Type': 'application/json',
      'Cookie': '$token',
    };
    // Make a POST request to the API with empty body
    final response = await http.post(
      Uri.parse(url),
      headers: headers,
    );
    // If request was successful (HTTP 200 OK)
    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(response.body); // Decode the JSON array

      // Convert each item (Map) in the list to Map<String, String>
      ComplaintData.allComplaints = responseData.map<Map<String, String>>((item) {
        return {
          'title': item['complaint_title']?.toString() ?? '',
          'complaint_message': item['complaint_message']?.toString() ?? '',
          'username': item['user_Name']?.toString() ?? '',
        };
      }).toList();

      print('Complaints loaded: ${ComplaintData.allComplaints}');
    } else {

      print('Failed to load complaints: ${response.statusCode}, ${response.body}');
    }
  }
}
