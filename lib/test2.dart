import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ComplaintListPageTest extends StatefulWidget {
  @override
  _ComplaintListPageState createState() => _ComplaintListPageState();
}

class _ComplaintListPageState extends State<ComplaintListPageTest> {
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
          .from('complaints') // tablo adını kendi projenle eşleştir
          .select()
          .order('id', ascending: false); // ya da istediğin alana göre sırala

      setState(() {
        complaints = response;
      });
    } catch (e) {
      print('Hata: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Şikayetler')),
      body: ListView.builder(
        itemCount: complaints.length,
        itemBuilder: (context, index) {
          final complaint = complaints[index];

          // JSON alanı: coordinate
          final coordinate = complaint['coordinate'];
          final lat = coordinate?['lat'] ?? 'Yok';
          final lng = coordinate?['lng'] ?? 'Yok';

          return Card(
            margin: EdgeInsets.all(8),
            child: ListTile(
              title: Text(complaint['title'] ?? 'Başlıksız'),
              subtitle: Text('${complaint['description'] ?? ''}\nKoordinat: ($lat, $lng)'),
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
