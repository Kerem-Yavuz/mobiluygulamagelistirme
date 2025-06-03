import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../utils/DBHelper.dart';
import '../../core/base/base_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? profile;
  Map<String, dynamic>? firebaseData;
  DateTime? _selectedDate;
  bool isEditing = false;
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  Uint8List? _webImageBytes;

  late TextEditingController nameController;
  late TextEditingController surnameController;
  late TextEditingController emailController;
  late TextEditingController dogumYeriController;
  late TextEditingController dogumTarihiController;
  late TextEditingController yasadigiIlController;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('uid');
    if (uid == null) return;
    final response = await Supabase.instance.client
        .from('Profil_Bilgileri')
        .select()
        .eq('uid', uid)
        .single();

    final docSnapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (docSnapshot.exists) {
      firebaseData = docSnapshot.data();

      setState(() {
        profile = response;
        nameController = TextEditingController(text: profile?['isim']);
        surnameController = TextEditingController(text: profile?['soyisim']);
        emailController = TextEditingController(text: profile?['email']);
        dogumYeriController = TextEditingController(text: firebaseData?['dogumYeri'] ?? '');
        dogumTarihiController = TextEditingController(text: firebaseData?['dogumTarihi'] ?? '');
        yasadigiIlController = TextEditingController(text: firebaseData?['yasadigiIl'] ?? '');
      });
    }
  }

  Future<void> saveProfileChanges() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('uid');
    if (uid == null) return;

    await prefs.setString('email', emailController.text ?? ' ');
    await prefs.setString('name', "${nameController.text} ${surnameController.text}" ?? ' ');
    await prefs.setString('firstName', nameController.text ??'');
    await prefs.setString('lastName', surnameController.text ?? '');

    // Firestore kullanıcı dokümanını güncelle
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'dogumYeri': dogumYeriController.text,
      'dogumTarihi': _selectedDate != null
          ? "${_selectedDate!.day.toString().padLeft(2, '0')}.${_selectedDate!.month.toString().padLeft(2, '0')}.${_selectedDate!.year}"
          : dogumTarihiController.text,
      'yasadigiIl': yasadigiIlController.text,
    });
    final supabase = Supabase.instance.client;
    await supabase.from('Profil_Bilgileri')
        .update({
        'isim': nameController.text,
        'soyisim': surnameController.text,
        'email': emailController.text,
      })
        .eq('uid', uid);


    if (!kIsWeb) {
      final Map<String, dynamic> userData = {
        'uid': uid,
        'email': emailController.text.trim() ?? '',
        'name': "${nameController.text.trim()} ${surnameController.text.trim()}" ?? ' ',
        'firstName':  nameController.text.trim() ?? '',
        'lastName': surnameController.text.trim() ?? "",
        'dogumYeri': dogumYeriController.text.trim() ?? '',
        'dogumTarihi': _selectedDate ?? '',
        'yasadigiIl': yasadigiIlController.text.trim() ?? '',
      };

      await DBHelper().updateUser(userData);
    }
    setState(() {
      isEditing = false;
      profile!['isim'] = nameController.text;
      profile!['soyisim'] = surnameController.text;
      profile!['email'] = emailController.text;
      firebaseData!['dogumYeri'] = dogumYeriController.text;
      firebaseData!['dogumTarihi'] = dogumTarihiController.text;
      firebaseData!['yasadigiIl'] = yasadigiIlController.text;
    });
  }


  Future<void> _pickImage() async {
    try {
      if (kIsWeb) {
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
      } else {
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


  Future<void> uploadProfileImage() async {
    await _pickImage();

    if (_imageFile == null && _webImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen bir resim seçin.")),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('uid');
    if (uid == null) return;

    final filePath = 'profile_pictures/$uid.png';
    final supabase = Supabase.instance.client;

    try {
      // Varsa eski dosyayı sil
      final existingFiles = await supabase.storage.from('images').list(path: 'profile_pictures/');
      final fileExists = existingFiles.any((file) => file.name == '$uid.png');

      if (fileExists) {
        final deleted = await supabase.storage.from('images').remove([filePath]);
        if (deleted.isEmpty) {
          print('Eski dosya silinemedi.');
        } else {
          print('Eski dosya silindi.');
        }
      }

      // Dosyayı yükle
      if (kIsWeb && _webImageBytes != null) {
        await supabase.storage
            .from('images')
            .uploadBinary(filePath, _webImageBytes!, fileOptions: const FileOptions(upsert: true));
      } else if (_imageFile != null) {
        await supabase.storage
            .from('images')
            .upload(filePath, _imageFile!, fileOptions: const FileOptions(upsert: true));
      } else {
        throw Exception("Hiç resim seçilmedi.");
      }

      final publicUrl = supabase.storage.from('images').getPublicUrl(filePath);

      await supabase
          .from('Profil_Bilgileri')
          .update({'profil_resmi': publicUrl})
          .eq('uid', uid);

      await prefs.setString('photoURL', publicUrl);

      print('Public URL: $publicUrl');
      if (!kIsWeb) {
        await DBHelper.updateProfilePhoto(uid, publicUrl);
      }
      setState(() {
        profile!['profil_resmi'] = publicUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profil resmi başarıyla güncellendi.")),
      );
    } catch (e) {
      print("Profil resmi güncelleme hatası: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profil resmi güncellenirken hata oluştu.")),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return BasePage(
      title: "profile".tr(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Stack(
              children: [
                GestureDetector(
                  onTap: uploadProfileImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: (profile?['profil_resmi'] != null &&
                        profile!['profil_resmi'].toString().isNotEmpty)
                        ? NetworkImage(profile!['profil_resmi']) as ImageProvider
                        : const NetworkImage(
                        "https://rldxceqyinumedzfptnq.supabase.co/storage/v1/object/public/images//defaultAvatar.png"),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: uploadProfileImage,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: const Icon(
                        Icons.edit,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            isEditing
                ? Column(
              children: [
                TextField(
                    controller: nameController,
                    decoration:
                    InputDecoration(labelText: 'name'.tr())),
                const SizedBox(height: 15),
                TextField(
                    controller: surnameController,
                    decoration:
                    InputDecoration(labelText: 'surname'.tr())),
                const SizedBox(height: 15),
                TextField(
                    controller: emailController,
                    decoration:
                    InputDecoration(labelText: 'email'.tr())),
                const SizedBox(height: 15),
                TextField(
                    controller: dogumYeriController,
                    decoration:
                    InputDecoration(labelText: 'birthplace'.tr())),
                const SizedBox(height: 15),
                TextFormField(
                  controller: dogumTarihiController,
                  decoration: InputDecoration(
                    labelText: 'birthdate'.tr(),
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime(2000, 1, 1),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                      locale: const Locale('tr'),
                    );

                    if (picked != null) {
                      setState(() {
                        _selectedDate = picked;
                        dogumTarihiController.text =
                        "${picked.day.toString().padLeft(2, '0')}.${picked.month.toString().padLeft(2, '0')}.${picked.year}";
                      });
                    }
                  },
                ),
                const SizedBox(height: 15),
                TextField(
                    controller: yasadigiIlController,
                    decoration: const InputDecoration(labelText: "Yaşadığı İl")),
              ],
            )
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${profile!['isim']} ${profile!['soyisim']}",
                    style: textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text("Email: ${profile!['email']}", style: textTheme.bodyMedium),
                const SizedBox(height: 8),
                if (firebaseData != null) ...[
                  Text('${'birthplace'.tr()} ${firebaseData!['dogumYeri'] ?? '-'}',
                      style: textTheme.bodyMedium),
                  Text('${'birthdate'.tr()} ${firebaseData!['dogumTarihi'] ?? '-'}',
                      style: textTheme.bodyMedium),
                  Text('${'livingplace'.tr()} ${firebaseData!['yasadigiIl'] ?? '-'}',
                      style: textTheme.bodyMedium),
                ],
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: Icon(isEditing ? Icons.save : Icons.edit),
              label: Text(isEditing ? "save".tr() : "Edit".tr()),
              onPressed: () {
                if (isEditing) {
                  saveProfileChanges();
                } else {
                  setState(() => isEditing = true);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

