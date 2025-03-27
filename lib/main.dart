import 'package:flutter/material.dart';
import 'package:mobiluygulamagelistirme/testpage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/testpage',
      routes:{
        '/testpage':(context) => testpage(),
      },
    );
  }
}