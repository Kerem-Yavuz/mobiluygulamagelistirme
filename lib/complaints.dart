import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'base_page.dart';
import 'DetailsPage.dart'; // <- Bunu eklediğine emin ol

class ComplaintsPage extends StatefulWidget {
  @override
  _ComplaintListPageState createState() => _ComplaintListPageState();
}

class _ComplaintListPageState extends State<ComplaintsPage> {
  final supabase = Supabase.instance.client;
  List<dynamic> complaints = [];

  @override
  void initState() {
    super.initState();
    fetchComplaints();
  }

  Future<void> fetchComplaints() async {
    try {
      final response = await supabase
          .from('Complaints')
          .select()
          .order('id', ascending: false);

      setState(() {
        complaints = response;
      });
    } catch (e) {
      print('Hata: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'complaints'.tr(),
      child: ListView.builder(
        itemCount: complaints.length,
        itemBuilder: (context, index) {
          final complaint = complaints[index];
          final coordinate = complaint['coordinate'];
          final lat = coordinate?['lat'] ?? 'Yok';
          final lng = coordinate?['lng'] ?? 'Yok';

          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text(complaint['title'] ?? 'Başlıksız'),
              onTap: () {
                final id = complaint['id'].toString(); // id'yi al
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ComplaintDetailPage(id: id),
                  ),
                );
              },
              trailing: complaint['image_url'] != null
                  ? Image.network(
                complaint['image_url'],
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              )
                  : null,
            ),
          );
        },
      ),
    );
  }
}
