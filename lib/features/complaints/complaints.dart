import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/base/base_page.dart';
import 'DetailsPage.dart';

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
          final imageUrl = complaint['image_url'];
          final title = complaint['title'] ?? 'Başlıksız';
          final id = complaint['id'].toString();

          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              contentPadding: const EdgeInsets.all(8),
              title: Text(title),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ComplaintDetailPage(id: id),
                  ),
                );
              },
              trailing: imageUrl != null && imageUrl.toString().isNotEmpty
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(
                  imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return SizedBox(
                      width: 60,
                      height: 60,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image, size: 60),
                ),
              )
                  : const Icon(Icons.image_not_supported),
            ),
          );
        },
      ),
    );
  }
}
