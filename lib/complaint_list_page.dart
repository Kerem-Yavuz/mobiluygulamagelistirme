import 'package:flutter/material.dart';
import 'package:mobiluygulamagelistirme/drawer.dart';
import 'package:mobiluygulamagelistirme/appbar.dart';

class ComplaintListPage extends StatelessWidget {
  final List<Map<String, String>> complaints;

  ComplaintListPage({required this.complaints});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: "Şikayet Listesi"),
      drawer: MyDrawer(),
      body: complaints.isEmpty
          ? Center(
        child: Text(
          "Henüz bir şikayet yok.",
          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
        ),
      )
          : ListView.builder(
        itemCount: complaints.length,
        padding: EdgeInsets.all(12),
        itemBuilder: (context, index) {
          final item = complaints[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 3,
            margin: EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: EdgeInsets.all(16),
              title: Text(
                item['konu'] ?? 'Konu Yok',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  item['complaint'] ?? 'Detay Yok',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

