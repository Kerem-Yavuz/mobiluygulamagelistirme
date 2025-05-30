import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ResimSaglayici.dart';

class MyDrawer extends StatelessWidget {


  @override
  Widget build(BuildContext context) {

    final resimSaglayici = ResimSaglayici();

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: const Color(0xFFA63D40)),
            child: Row(
              children: [
                FutureBuilder<Uint8List?>(
                  future: resimSaglayici.fetchImage(1),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator(); // Show loading circle while waiting
                    } else if (snapshot.hasError || snapshot.data == null) {
                      return Text("Resim yüklenemedi.");
                    } else {
                      return Image.memory(snapshot.data!, width: 50, height: 50, ); //Transform Bytes into Image
                    }
                  },
                ),
                Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Text(
                    "menu".tr(),
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.warning_amber),
            title: Text('addcomplaint'.tr()),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/newcomplaint');
            },
          ),
          ListTile(
            leading: Icon(Icons.map),
            title: Text('complaints'.tr()),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/newcomplaintlist');
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('profile'.tr()),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/profile');
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('logout'.tr()),
            onTap: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.clear(); // Tüm verileri siler
              Navigator.pushNamedAndRemoveUntil(context, '/login', (Route<dynamic> route) => false);
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('settings'.tr()),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/settings');
            },
          ),
        ],
      ),
    );
  }
}
