import 'dart:typed_data';

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
            decoration: BoxDecoration(color: Colors.blue),
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
                    "Menü",
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.map),
            title: Text("Şikayet Listesi"),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/complaintList');
            },
          ),
          ListTile(
            leading: Icon(Icons.warning_amber),
            title: Text("Şikayet Et"),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/complaint');
            },
          ),
          ListTile(
            leading: Icon(Icons.warning_amber),
            title: Text("Şikayet Et Yeni"),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/newcomplaint');
            },
          ),
          ListTile(
            leading: Icon(Icons.map),
            title: Text("Şikayetler Yeni"),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/newcomplaintlist');
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text("Profil"),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/profile');
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text("Çıkış Yap"),
            onTap: () async { // This will delete token in cookie for logout and then it will go to the login page
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.remove('cookie');
              Navigator.pushNamedAndRemoveUntil(context, '/login', (Route<dynamic> route) => false);
            },
          ),

        ],
      ),
    );
  }
}
