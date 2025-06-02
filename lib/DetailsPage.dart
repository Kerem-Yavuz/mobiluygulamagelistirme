import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobiluygulamagelistirme/appbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'MapWithSinglePoint.dart';

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

  static const double imageOriginalWidth = 717.0;
  static const double imageOriginalHeight = 1452.0;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: 'complaintdetails'.tr()),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchComplaintDetail(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Hata: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return const Center(child: Text('Veri bulunamadı'));
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final containerWidth = constraints.maxWidth;
                final containerHeight = constraints.maxHeight;

                final imageRatio = imageOriginalWidth / imageOriginalHeight;
                final containerRatio = containerWidth / containerHeight;

                double displayedWidth, displayedHeight;

                if (containerRatio > imageRatio) {
                  displayedHeight = containerHeight;
                  displayedWidth = displayedHeight * imageRatio;
                } else {
                  displayedWidth = containerWidth;
                  displayedHeight = displayedWidth / imageRatio;
                }

                final offsetX = (containerWidth - displayedWidth) / 2;
                final offsetY = (containerHeight - displayedHeight) / 2;

                final complaint = snapshot.data!;
                final title = complaint['title'] ?? 'Başlıksız';
                final description = complaint['description'] ?? 'Açıklama yok';
                final coordinate = complaint['coordinate'];
                final lat = coordinate?['lat'] != null ? coordinate['lat'] * displayedWidth + offsetX : null;
                final lng = coordinate?['lng'] != null ? coordinate['lng'] * displayedHeight + offsetY : null;
                final imageUrl = complaint['image_url'];

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            )),
                        const SizedBox(height: 16),
                        Text(description),
                        const SizedBox(height: 16),
                        if (imageUrl != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(imageUrl),
                          ),
                        const SizedBox(height: 16),
                        if (lat != null && lng != null) ...[
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {
                              final coordinate = complaint['coordinate'];
                              if (coordinate != null &&
                                  coordinate['lat'] != null &&
                                  coordinate['lng'] != null) {
                                final normalizedLat = coordinate['lat'] as double;
                                final normalizedLng = coordinate['lng'] as double;

                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => MapWithSinglePoint(
                                      normalizedLat: normalizedLat,
                                      normalizedLng: normalizedLng,
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Text('showlocation'.tr()),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          }
      ),
    );
  }
}



