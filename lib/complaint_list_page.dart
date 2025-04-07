import 'package:flutter/material.dart';
import 'package:mobiluygulamagelistirme/drawer.dart';
import 'package:mobiluygulamagelistirme/appbar.dart';
import 'package:mobiluygulamagelistirme/complaint_data.dart';

class ComplaintListPage extends StatefulWidget {
  const ComplaintListPage({super.key});
  @override
  State<ComplaintListPage> createState() => _ComplaintListPageState();
}

class _ComplaintListPageState extends State<ComplaintListPage> {
  List<Map<String, String>> complaints = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadComplaints(); // To load complaints when complaint list page clicked
  }

  Future<void> loadComplaints() async {
    await ComplaintData.getComplaints();
    setState(() {
      complaints = ComplaintData.allComplaints;// Get allComplaints from complaint_data.dart
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: "Şikayet Listesi"),
      drawer: MyDrawer(),
      body: isLoading // to show while wait for complaints to come from api
          ? const Center(child: CircularProgressIndicator())
          : complaints.isEmpty
          ? Center( // Shows this if complaints empty and shows complaints if there exists
        child: Text(
          "Henüz bir şikayet yok.",
          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
        ),
      )
          : ListView.builder(
        itemCount: complaints.length,
        padding: const EdgeInsets.all(12),
        itemBuilder: (context, index) {
          final item = complaints[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                item['title'] ?? 'Konu Yok',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['complaint_message'] ?? 'Detay Yok',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Gönderen: ${item['username'] ?? 'Bilinmiyor'}',
                      style: const TextStyle(
                          fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
