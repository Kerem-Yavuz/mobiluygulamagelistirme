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
  TextEditingController _konuController = TextEditingController();
  String complaintV = "";
  TextEditingController _complaintVController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: "Şikayet Et"),
      drawer: MyDrawer(),
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
              controller: _konuController,
            ),
            SizedBox(height: 15),
            TextField(
              decoration: InputDecoration(
                labelText: "Şikayet Detayları",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              controller: _complaintVController,
              maxLines: 4,
            ),
            SizedBox(height: 15),
            OutlinedButton(
              onPressed: () async {
                final title = _konuController.text.trim();
                final message = _complaintVController.text.trim();

                if (title.isEmpty || message.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Lütfen tüm alanları doldurun")),
                  );
                  return;
                }

                // Send to API
                final prefs = await SharedPreferences.getInstance();
                final token = prefs.getString('cookie') ?? '';

                final headers = {
                  'Content-Type': 'application/json',
                  'Cookie': 'token=$token',
                };

                final body = jsonEncode({
                  'title': title,
                  'message': message,
                });

                final response = await http.post(
                  Uri.parse('${BASE_URL}/sendComplaint'),
                  headers: headers,
                  body: body,
                );

                if (response.statusCode == 200) {
                  setState(() {
                    _konuController.clear();
                    _complaintVController.clear();
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Şikayet başarıyla gönderildi")),
                  );
                } else {
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
