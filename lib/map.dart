import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'ResimSaglayici.dart';
import 'appbar.dart';
import 'drawer.dart';

class map extends StatelessWidget
{
  final resimSaglayici = ResimSaglayici();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: "Harita"),
      drawer: MyDrawer(),
      body: FutureBuilder<Uint8List?>(
        future: resimSaglayici.fetchImage(2),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container( // Yükleniyor göstergesi
              margin: EdgeInsets.only(top: 15), // Üstten 20 birim boşluk ekler
              alignment: Alignment.center, // Ortaya hizalar
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError || snapshot.data == null) {
            return Text("Harita Yüklenemedi.");
          } else {
            return Container(
              margin: EdgeInsets.only(top: 15), // Üstten 20 birim boşluk ekler
              alignment: Alignment.center, // Ortaya hizalar
              child: Image.memory(
                snapshot.data!,
                fit: BoxFit.cover,
              ),
            ); // Byte verisini resme çevir
          }
        },
      ),
    );
  }
}