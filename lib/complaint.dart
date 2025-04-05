import 'package:flutter/material.dart';
import 'package:mobiluygulamagelistirme/appbar.dart';
import 'package:mobiluygulamagelistirme/drawer.dart';
import 'package:mobiluygulamagelistirme/complaint_data.dart';
import 'package:mobiluygulamagelistirme/complaint_list_page.dart';

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
              onPressed: () {
                // Save complaint
                ComplaintData.allComplaints.add({
                  'konu': _konuController.text,
                  'complaint': _complaintVController.text,
                });

                // Navigate to list of complaints
                OutlinedButton(
                  onPressed: () {
                    ComplaintData.allComplaints.add({
                      'konu': _konuController.text,
                      'complaint': _complaintVController.text,
                    });

                    setState(() {
                      konu = _konuController.text;
                      complaintV = _complaintVController.text;
                      _konuController.clear();
                      _complaintVController.clear();
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Şikayet kaydedildi")),
                    );
                  },
                  child: Text("Kaydet"),
                );
              },
              child: Text("Kaydet"),
            ),
          ],
        ),
      ),
    );
  }
}
