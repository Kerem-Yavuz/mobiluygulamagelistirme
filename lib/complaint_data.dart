import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobiluygulamagelistirme/constants.dart';
class ComplaintData {
  static List<Map<String, String>> allComplaints = [];

  static Future<void> getComplaints() async {
    const url = '${BASE_URL}/getComplaints';

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('cookie') ?? '';

    final headers = {
      'Content-Type': 'application/json',
      'Cookie': 'token=$token',
    };

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode({}), // send empty body if needed
    );

    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(response.body);

      ComplaintData.allComplaints = responseData.map<Map<String, String>>((item) {
        return item.map((key, value) => MapEntry(key.toString(), value.toString()));
      }).toList();

      print('Complaints loaded: ${ComplaintData.allComplaints}');
    } else {
      print('Failed to load complaints: ${response.statusCode}, ${response.body}');
    }
  }
}
