import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ResimSaglayici.dart';

class MyDrawer extends StatelessWidget {

  void _navigate(BuildContext context, String route){
    Navigator.pop(context);
    if(ModalRoute.of(context)?.settings.name != route){
      Navigator.pushReplacementNamed(context, route);
    }
  }

  void _logout(BuildContext context){
    showDialog(context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text('logout'.tr()),
            content: Text("logoutquestion".tr()),
            actions: [
              TextButton(onPressed:() async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.clear(); // Tüm verileri siler
                Navigator.pushNamedAndRemoveUntil(context, '/login', (Route<dynamic> route) => false);
              },
                  child: Text('approve'.tr())

              ),
              TextButton(onPressed:() {
                Navigator.of(context).pop();
              },
                  child: Text('cancel'.tr())

              ),
            ],
          );
        }
    );
  }

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
              _navigate(context, '/newcomplaint');
            },
          ),
          ListTile(
            leading: Icon(Icons.map),
            title: Text('complaints'.tr()),
            onTap: () {
              _navigate(context, '/newcomplaintlist');
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('profile'.tr()),
            onTap: () {
              _navigate(context, '/profile');
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('logout'.tr()),
            onTap: () async {
             _logout(context);
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
