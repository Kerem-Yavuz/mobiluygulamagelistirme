import 'package:flutter/material.dart';
import 'package:mobiluygulamagelistirme/login_screen.dart';
import 'package:mobiluygulamagelistirme/complaint_list_page.dart';
import 'package:mobiluygulamagelistirme/complaint.dart';
import 'complaint_data.dart';

void main() {
  runApp(MyApp());
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
      initialRoute: '/login',
      routes:{
        '/complaint': (context) => Complaint(),
        '/complaintList': (context) => ComplaintListPage(
          complaints: ComplaintData.allComplaints,
        ),
        '/login': (context) => LoginScreen(),
      },
    );
  }
}
