import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'appbar.dart';
import 'base_page.dart';
import 'drawer.dart';
import 'tappable_image.dart';

class InsertPage extends StatefulWidget {
  const InsertPage({super.key});

  @override
  State<InsertPage> createState() => _InsertTestPageState();
}

class _InsertTestPageState extends State<InsertPage> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  Map<String, double>? selectedCoordinates;

  File? _imageFile;  // Store picked image file

  final ImagePicker _picker = ImagePicker();

  Future<void> insertData({
    required String userId,
    required String title,
    required String description,
    required String imageUrl,
    required Map<String, dynamic> coordinate,
  }) async {
    final supabase = Supabase.instance.client;

    try {
      final response = await supabase.from('Complaints').insert({
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

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Resim alınamadı: $e')),
      );
    }
  }

  void _showMapPicker(BuildContext context) {
    Map<String, double>? tempCoords = selectedCoordinates;

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Column(
              children: [
                // Başlık satırı
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Haritadan konum seçin",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),

                // Harita alanı - döndürülmüş ve genişletilmiş
                Expanded(
                  child: RotatedBox(
                    quarterTurns: 0, // pi/2 dönüş
                    child: SizedBox.expand(
                      child: TappableImage(
                        initialPoint: tempCoords,
                        onCoordinateSelected: (coords) {
                          tempCoords = coords;
                        },
                      ),
                    ),
                  ),
                ),

                // Alt bilgi ve buton
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        tempCoords != null
                            ? 'Konum: ${tempCoords!['lat']?.toStringAsFixed(4)}, ${tempCoords!['lng']?.toStringAsFixed(4)}'
                            : 'Henüz konum seçilmedi',
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          if (tempCoords != null) {
                            setState(() {
                              selectedCoordinates = tempCoords;
                            });
                            Navigator.of(context).pop();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Lütfen bir konum seçin")),
                            );
                          }
                        },
                        child: const Text("Tamam"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'addcomplaint'.tr(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration:  InputDecoration(labelText: 'inserttitle'.tr()),
              ),
              TextField(
                controller: descriptionController,
                decoration:  InputDecoration(labelText: 'Complaint'.tr()),
              ),
              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: () => _showMapPicker(context),
                child:  Text("Haritayı Aç"),
              ),

              if (selectedCoordinates != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    'Seçilen konum: ${selectedCoordinates!['lat']?.toStringAsFixed(4)}, ${selectedCoordinates!['lng']?.toStringAsFixed(4)}',
                  ),
                ),

              const SizedBox(height: 16),

              // New ElevatedButton to take picture
              ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: const Text('Fotoğraf Çek'),
                onPressed: _pickImage,
              ),

              if (_imageFile != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Image.file(
                    _imageFile!,
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () async {
                  if (selectedCoordinates == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Lütfen haritadan bir konum seçin')),
                    );
                    return;
                  }
                  final prefs = await SharedPreferences.getInstance();
                  final userId = prefs.getString('uid') ?? '';

                  final title = titleController.text;
                  final description = descriptionController.text;

                  String imageUrl = '';


                  await insertData(
                    userId: userId,
                    title: title,
                    description: description,
                    imageUrl: imageUrl,
                    coordinate: selectedCoordinates!,
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
