import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mobiluygulamagelistirme/login_screen.dart';
import 'package:mobiluygulamagelistirme/complaint_list_page.dart';
import 'package:mobiluygulamagelistirme/complaint.dart';
import 'package:mobiluygulamagelistirme/profile.dart';
import 'package:mobiluygulamagelistirme/insert_screen.dart';
import 'package:mobiluygulamagelistirme/complaints.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://rldxceqyinumedzfptnq.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJsZHhjZXF5aW51bWVkemZwdG5xIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDg1MDQ3MTEsImV4cCI6MjA2NDA4MDcxMX0.ITkluOrezbUujAAbXbHftOb-R5F9L-QP9WO2UeycRss',
  );
  await Firebase.initializeApp();
  runApp(MyApp());
  
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/login',
      routes: {
        '/newcomplaint': (context) => InsertPage(),
        '/newcomplaintlist': (context) => ComplaintsPage(),
        '/complaint': (context) => Complaint(),
        '/complaintList': (context) => ComplaintListPage(),
        '/login': (context) => LoginScreen(),
        '/profile': (context) => ProfilePage(),
      },
    );
  }
}

