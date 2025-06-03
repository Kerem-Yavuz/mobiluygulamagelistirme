import 'dart:io';
import 'dart:typed_data';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/base/base_page.dart';
import '../map/widgets/tappable_image.dart';

class InsertPage extends StatefulWidget {
  const InsertPage({super.key});

  @override
  State<InsertPage> createState() => _InsertPageState();
}

class _InsertPageState extends State<InsertPage> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  Map<String, double>? selectedCoordinates;
  File? _imageFile;
  Uint8List? _webImageBytes;

  Future<void> _pickImage() async {
    try {
      if (kIsWeb) { //Pick image for web
        final result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          withData: true,
        );
        if (result != null && result.files.isNotEmpty) {
          setState(() {
            _webImageBytes = result.files.first.bytes!;
            _imageFile = null;
          });
        }
      } else { //Pick image for mobile
        final pickedFile = await _picker.pickImage(source: ImageSource.camera);
        if (pickedFile != null) {
          setState(() {
            _imageFile = File(pickedFile.path);
            _webImageBytes = null;
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Resim alınamadı: $e'.tr())),
      );
    }
  }

  Future<String> uploadComplaintImage(String userId) async {
    final supabase = Supabase.instance.client;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_$userId.png';
    final filePath = 'complaint_images/$fileName';

    try {
      if (kIsWeb && _webImageBytes != null) { // Upload web image bytes to Supabase storage
        await supabase.storage
            .from('images')
            .uploadBinary(filePath, _webImageBytes!,
            fileOptions: const FileOptions(upsert: true));
      } else if (_imageFile != null) { // Upload mobile image file to Supabase storage
        await supabase.storage
            .from('images')
            .upload(filePath, _imageFile!,
            fileOptions: const FileOptions(upsert: true));
      } else {
        throw Exception("Hiç resim seçilmedi.");
      }

      return supabase.storage.from('images').getPublicUrl(filePath); // Return public URL of uploaded image
    } catch (e) {
      print("Resim yükleme hatası: $e");
      throw Exception("Resim yüklenemedi.");
    }
  }

  Future<void> insertData({
    required String userId,
    required String title,
    required String description,
    required String imageUrl,
    required Map<String, dynamic> coordinate,
  }) async {
    final supabase = Supabase.instance.client;

    try {
      final response = await supabase.from('Complaints').insert({ // Insert complaint data into Supabase table
        'user_id': userId,
        'title': title,
        'description': description,
        'image_url': imageUrl,
        'coordinate': coordinate,
      }).select();

      print('Başarıyla eklendi: $response');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('snackbarsent'.tr())),
      );
      Future.delayed(Duration(milliseconds: 300), () {
        Navigator.pushReplacementNamed(context, '/newcomplaintlist');
      });
    } catch (e) {
      print('Hata oluştu: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('SnackBarError: $e'.tr())),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "insertChooseLocation".tr(),
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                Expanded(
                  child: RotatedBox(
                    quarterTurns: 0,
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [ // Show selected coordinates
                      Text(
                        tempCoords != null
                            ? 'Konum: ${tempCoords!['lat']?.toStringAsFixed(4)}, ${tempCoords!['lng']?.toStringAsFixed(4)}'.tr()
                            : 'LocationNotPicked'.tr(),
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
                              SnackBar(content: Text("SnackBarChoose".tr())),
                            );
                          }
                        },
                        child: Text("approve".tr()),
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
                decoration: InputDecoration(labelText: 'inserttitle'.tr()),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Complaint'.tr()),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: Icon(Icons.map),
                label: Text("insertOpenMap".tr()),
                onPressed: () => _showMapPicker(context),
              ),
              if (selectedCoordinates != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    'Seçilen konum: ${selectedCoordinates!['lat']?.toStringAsFixed(4)}, ${selectedCoordinates!['lng']?.toStringAsFixed(4)}',
                  ),
                ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: Icon(Icons.camera_alt),
                label: Text('insertTakePhoto'.tr()),
                onPressed: _pickImage,
              ),
              if (_imageFile != null) // Display the selected image
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Image.file(
                    _imageFile!,
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                )
              else if (_webImageBytes != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Image.memory(
                    _webImageBytes!,
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
                      SnackBar(content: Text('insertChooseLocation'.tr())),
                    );
                    return;
                  }

                  // Get user ID from SharedPreferences
                  final prefs = await SharedPreferences.getInstance();
                  final userId = prefs.getString('uid') ?? '';
                  final title = titleController.text;
                  final description = descriptionController.text;

                  String imageUrl = '';
                  try {
                    imageUrl = await uploadComplaintImage(userId); // Upload image and get public URL
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Resim yüklenemedi: $e")),
                    );
                    return;
                  }

                  await insertData( //insert the data into Supabase database
                    userId: userId,
                    title: title,
                    description: description,
                    imageUrl: imageUrl,
                    coordinate: selectedCoordinates!,
                  );
                },
                child: Text("Upload".tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
