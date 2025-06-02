import 'package:flutter/material.dart';


class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  MyAppBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title), // to show the pages name that we get from the called page
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight); // to align the appbars height
}
