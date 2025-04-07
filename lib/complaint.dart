import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobiluygulamagelistirme/appbar.dart';
import 'package:mobiluygulamagelistirme/drawer.dart';
import 'constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Complaint extends StatefulWidget {
  @override
  State<Complaint> createState() => _ComplaintState();
}

class _ComplaintState extends State<Complaint> {
  String konu = "";
  TextEditingController _konuController = TextEditingController();  //controller to get input for "konu"
  String complaintV = "";
  TextEditingController _complaintVController = TextEditingController();//controller to get input for "Şikayet Detayları"


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: "Şikayet Et"),// Using a custom app bar with title
      drawer: MyDrawer(), // Using a custom drawer (navigation menu)
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: "Konu",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              controller: _konuController, // Connects the field to the controller
            ),
            SizedBox(height: 15),
            TextField(
              decoration: InputDecoration(
                labelText: "Şikayet Detayları",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              controller: _complaintVController, // Connects the field to the controller
              maxLines: 4,
            ),
            SizedBox(height: 15),
            OutlinedButton(
              onPressed: () async {
                final title = _konuController.text.trim(); // Gets and trims the subject
                final message = _complaintVController.text.trim(); //Gets and trims the complaint


                // Show error message if empty
                if (title.isEmpty || message.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Lütfen tüm alanları doldurun")),
                  );
                  return;
                }

                // Access stored token from shared preferences
                final prefs = await SharedPreferences.getInstance();
                final token = prefs.getString('cookie') ?? '';   // Get the token or use empty string


                // Prepare HTTP headers
                final headers = {
                  'Content-Type': 'application/json',
                  'Cookie': 'token=$token',
                };
                // Prepare JSON body to send
                final body = jsonEncode({
                  'title': title,
                  'message': message,
                });


                // Send POST request to the API
                final response = await http.post(
                  Uri.parse('${BASE_URL}/sendComplaint'), // API endpoint
                  headers: headers,
                  body: body,
                );


                // Check if the response is successful
                if (response.statusCode == 200) {
                  setState(() {
                    _konuController.clear(); // Clear the title field
                    _complaintVController.clear(); // Clear the message field
                  });

                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Şikayet başarıyla gönderildi")),
                  );
                } else {
                  // Show error message with status code
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Gönderme başarısız: ${response.statusCode}")),
                  );
                }
              },
              child: Text("Kaydet"),
            ),

            ],
        ),
      ),
    );
  }
}
