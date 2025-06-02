import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'base_page.dart';

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

  late TextEditingController nameController;
  late TextEditingController surnameController;
  late TextEditingController emailController;
  late TextEditingController dogumYeriController;
  late TextEditingController dogumTarihiController;
  late TextEditingController yasadigiIlController;

  @override
  void initState() {
    super.initState();
    fetchUserDataFromSupabase();
  }

  Future<void> fetchUserDataFromSupabase() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('uid');
    if (uid == null) return;

    final docSnapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (docSnapshot.exists) {
      firebaseData = docSnapshot.data();
    }
    final supabase = Supabase.instance.client;
    try {
      final response = await supabase
          .from('Profil_Bilgileri') // tablo adı
          .select()
          .eq('uid', uid) // UID'ye göre filtrele
          .single();

      setState(() {
        profile = response;
        nameController = TextEditingController(text: profile?['isim'] ?? '');
        surnameController = TextEditingController(text: profile?['soyisim'] ?? '');
        emailController = TextEditingController(text: profile?['email'] ?? '');
        dogumYeriController = TextEditingController(text: firebaseData?['dogumYeri'] ?? '');
        dogumTarihiController = TextEditingController(text: firebaseData?['dogumTarihi'] ?? '');
        yasadigiIlController = TextEditingController(text: firebaseData?['yasadigiIl'] ?? '');
      });
    } catch (e) {
      print("Veri çekme hatası: $e");
    }
  }

  Future<void> saveProfileChanges() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('uid');
    if (uid == null) return;

    await Supabase.instance.client.from('Profil_Bilgileri').update({
      'isim': nameController.text,
      'soyisim': surnameController.text,
      'email': emailController.text,
    }).eq('uid', uid);

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'dogumYeri': dogumYeriController.text,
      'dogumTarihi': _selectedDate ?? '',
      'yasadigiIl': yasadigiIlController.text,
    });

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
            GestureDetector(
              onTap: isEditing ? () {
                // TODO: Profil resmi değiştirme işlemi buraya yazılabilir.
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Profil resmi değiştirilecek (henüz eklenmedi).")),
                );
              } : null,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: (profile?['profil_resmi'] != null &&
                    profile!['profil_resmi'].toString().isNotEmpty)
                    ? NetworkImage(profile!['profil_resmi']) as ImageProvider
                    : const NetworkImage("https://static-00.iconduck.com/assets.00/avatar-default-icon-2048x2048-h6w375ur.png"),
              ),
            ),
            const SizedBox(height: 24),
            isEditing
                ? Column(
              children: [
                TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'name'.tr())
                ),
                TextField(
                    controller: surnameController,
                    decoration: InputDecoration(labelText: 'surname'.tr())
                ),
                TextField(
                    controller: emailController,
                    decoration: InputDecoration(labelText: 'email'.tr())
                ),
                TextField(
                    controller: dogumYeriController,
                    decoration: InputDecoration(labelText: 'birthplace'.tr())
                ),
                TextFormField(
                  controller: dogumTarihiController,
                  decoration: InputDecoration(
                    labelText: 'birthdate'.tr(),
                    suffixIcon: Icon(Icons.calendar_today),
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
                TextField(
                    controller: yasadigiIlController,
                    decoration: const InputDecoration(labelText: "Yaşadığı İl")
                ),
              ],
            )
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${profile!['isim']} ${profile!['soyisim']}", style: textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text("Email: ${profile!['email']}", style: textTheme.bodyMedium),
                const SizedBox(height: 8),
                if (firebaseData != null) ...[
                  Text('${'birthplace'.tr()} ${firebaseData!['dogumYeri'] ?? '-'}', style: textTheme.bodyMedium),
                  Text('${'birthdate'.tr()} ${firebaseData!['dogumTarihi'] ?? '-'}', style: textTheme.bodyMedium),
                  Text('${'livingplace'.tr()} ${firebaseData!['yasadigiIl'] ?? '-'}', style: textTheme.bodyMedium),
                ],
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: Icon(isEditing ? Icons.save : Icons.edit),
              label: Text(isEditing ? "Kaydet" : "Düzenle"),
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
