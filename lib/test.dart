import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InsertTestPage extends StatefulWidget {
  const InsertTestPage({super.key});

  @override
  State<InsertTestPage> createState() => _InsertTestPageState();
}

class _InsertTestPageState extends State<InsertTestPage> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final imageUrlController = TextEditingController();
  final latController = TextEditingController();
  final lngController = TextEditingController();

  Future<void> insertData({
    required String userId,
    required String title,
    required String description,
    required String imageUrl,
    required Map<String, dynamic> coordinate,
  }) async {
    final supabase = Supabase.instance.client;

    try {
      final response = await supabase.from('ID').insert({
        'user_id': userId,
        'title': title,
        'description': description,
        'image_url': imageUrl,
        'coordinate': coordinate,
      }).select();

      print('Başarıyla eklendi: $response');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veri başarıyla eklendi')),
      );
    } catch (e) {
      print('Hata oluştu: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata oluştu: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Veri Ekleme Testi")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Başlık')),
              TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Açıklama')),
              TextField(controller: imageUrlController, decoration: const InputDecoration(labelText: 'Görsel URL')),
              TextField(controller: latController, decoration: const InputDecoration(labelText: 'Latitude'), keyboardType: TextInputType.number),
              TextField(controller: lngController, decoration: const InputDecoration(labelText: 'Longitude'), keyboardType: TextInputType.number),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final userId = Supabase.instance.client.auth.currentUser?.id ?? 'test-user';
                  final title = titleController.text;
                  final description = descriptionController.text;
                  final imageUrl = imageUrlController.text;
                  final lat = double.tryParse(latController.text) ?? 0.0;
                  final lng = double.tryParse(lngController.text) ?? 0.0;

                  await insertData(
                    userId: userId,
                    title: title,
                    description: description,
                    imageUrl: imageUrl,
                    coordinate: {'lat': lat, 'lng': lng},
                  );
                },
                child: const Text("Veriyi Yükle"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
