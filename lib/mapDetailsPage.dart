import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'base_page.dart';

class ComplaintDetailPage extends StatelessWidget {
  final String id;

  const ComplaintDetailPage({super.key, required this.id});

  Future<Map<String, dynamic>> fetchComplaintDetail() async {
    final response = await Supabase.instance.client
        .from('Complaints')
        .select()
        .eq('id', id)
        .single();

    return Map<String, dynamic>.from(response);
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'complaintmap'.tr(),
      child: FutureBuilder<Map<String, dynamic>>(
        future: fetchComplaintDetail(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Veri bulunamadı'));
          }

          final complaint = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ID: ${complaint['id']}'),
                const SizedBox(height: 8),
                Text('Veri: ${complaint}'),
                // Diğer alanlar buraya eklenebilir
              ],
            ),
          );
        },
      ),
    );
  }
}
