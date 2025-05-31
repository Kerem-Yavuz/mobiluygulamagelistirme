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


  @override
  void initState() {
    super.initState();
    fetchUserDataFromSupabase();
  }

  Map<String, dynamic>? profile;
  Map<String, dynamic>? firebaseData;
  Future<void> fetchUserDataFromSupabase() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('uid');

    if (uid == null) {
      print("UID shared_preferences içinde bulunamadı.");
      return;
    }

    final docSnapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (docSnapshot.exists) {
      setState(() {
        firebaseData =  docSnapshot.data();
      });
    }
    final supabase = Supabase.instance.client;

    try {
      final response = await supabase
          .from('Profil_Bilgileri') // tablo adı
          .select()
          .eq('uid', uid) // UID'ye göre filtrele
          .single(); // sadece tek kayıt bekliyorsan kullan
      setState(() {
        profile = response;
      });
      print("Kullanıcı verisi: $response");
    } catch (e) {
      print("Veri çekme hatası: $e");
    }
  }




  @override
  Widget build(BuildContext context) {
    if (profile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return BasePage(
      title: "profile".tr(),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: (profile?['profil_resmi'] != null && profile!['profil_resmi'].toString().isNotEmpty)
                  ? NetworkImage(profile!['profil_resmi'])
                  : NetworkImage("https://static-00.iconduck.com/assets.00/avatar-default-icon-2048x2048-h6w375ur.png"),
            ),
            const SizedBox(height: 16),
            Text(
              "${profile!['isim']} ${profile!['soyisim']}",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("Email: ${profile!['email']}"),
            Text('Doğum Yeri: ${firebaseData?['dogumYeri']}'),
            Text('Doğum Tarihi: ${firebaseData?['dogumTarihi']}'),
            Text('Yaşadığı İl: ${firebaseData?['yasadigiIl']}'),
          ],
        ),
      ),
    );
  }
}
