import 'package:flutter/material.dart';
import 'package:mobiluygulamagelistirme/appbar.dart';
import 'package:mobiluygulamagelistirme/drawer.dart';

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
            SizedBox(height: 25),
            Text(
              "Konu",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8), // Spacing between title and box
            Container(
              padding: EdgeInsets.all(12),
              width: double.infinity, // Makes it take full width
              decoration: BoxDecoration(
                color: Colors.grey[200], // Background color
                borderRadius: BorderRadius.circular(8), // Rounded corners
                border: Border.all(color: Colors.black), // Border color
              ),
              child: Text(
                "$konu", // Your content
                style: TextStyle(fontSize: 24),

              ),


            ),
            Text(
              "Şikayet:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8), // Spacing between title and box
            Container(
              padding: EdgeInsets.all(12),
              width: double.infinity, // Makes it take full width
              decoration: BoxDecoration(
                color: Colors.grey[200], // Background color
                borderRadius: BorderRadius.circular(8), // Rounded corners
                border: Border.all(color: Colors.black), // Border color
              ),
              child: Text(
                "$complaintV", // Your content
                style: TextStyle(fontSize: 16),

              ),


            ),


            SizedBox(height: 15),
            OutlinedButton(
              onPressed: _showKonu,
              child: Text("Kaydet"),
            ),
          ],
        ),
      ),
    );
  }

  void _showKonu() {
    setState(() {
      konu = _konuController.text;
      complaintV = _complaintVController.text;
    });
  }
}
