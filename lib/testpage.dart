import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'appbar.dart';
import 'drawer.dart';

class testpage extends StatelessWidget
{
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: MyAppBar(title: "Home Page", scaffoldKey: _scaffoldKey),
      drawer: MyDrawer(),
      body: Center(child: Text("Welcome to Home Page!")),
    );
  }
  
}