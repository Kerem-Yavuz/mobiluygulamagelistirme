import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Supabase eklendiğinden emin olun

class MyDrawer extends StatefulWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  Map<String, dynamic>? profile;
  String? profileImageUrl;
  String displayName = '';
  String email = '';

  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }

  Future<void> fetchProfileData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('uid') ?? '';

      final response = await Supabase.instance.client
          .from('Profil_Bilgileri')
          .select()
          .eq('uid', uid)
          .single();

      setState(() {
        profile = response;
        displayName = "${response!['isim']} ${response!['soyisim']}";
        email = response['email'] ?? '';
        profileImageUrl = response['profil_resmi'];
      });

      print("Kullanıcı verisi: $response");
    } catch (e) {
      print("Veri çekme hatası: $e");
    }
  }

  void _navigate(BuildContext context, String route) {
    Navigator.pop(context);
    if (ModalRoute.of(context)?.settings.name != route) {
      Navigator.pushReplacementNamed(context, route);
    }
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('logout'.tr()),
          content: Text("logoutquestion".tr()),
          actions: [
            TextButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (Route<dynamic> route) => false);
              },
              child: Text('approve'.tr()),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('cancel'.tr()),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(displayName),
            accountEmail: Text(email),
            currentAccountPicture: CircleAvatar(
              backgroundImage: (profileImageUrl != null && profileImageUrl!.isNotEmpty)
                  ? NetworkImage(profileImageUrl!)
                  : NetworkImage("https://rldxceqyinumedzfptnq.supabase.co/storage/v1/object/public/images//defaultAvatar.png"),
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.warning_amber),
            title: Text('addcomplaint'.tr()),
            onTap: () => _navigate(context, '/newcomplaint'),
          ),
          ListTile(
          leading: const Icon(Icons.map),
          title: Text('complaintmap'.tr()),
          onTap: () => _navigate(context, '/mappage'),
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: Text('complaints'.tr()),
            onTap: () => _navigate(context, '/newcomplaintlist'),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: Text('profile'.tr()),
            onTap: () => _navigate(context, '/profile'),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text('logout'.tr()),
            onTap: () => _logout(context),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text('settings'.tr()),
            onTap: () => _navigate(context, '/settings'),
          ),
        ],
      ),
    );
  }
}
