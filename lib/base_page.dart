import 'package:flutter/material.dart';
import 'appbar.dart';
import 'drawer.dart';

class BasePage extends StatelessWidget {
  final String title;
  final Widget child;

  const BasePage({
    Key? key,
    required this.title,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: title),
      drawer: MyDrawer(),
      body: child,
    );
  }
}
