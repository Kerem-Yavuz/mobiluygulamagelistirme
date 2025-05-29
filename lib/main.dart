import 'package:flutter/material.dart';
import 'package:mobiluygulamagelistirme/login_screen.dart';
import 'package:mobiluygulamagelistirme/complaint_list_page.dart';
import 'package:mobiluygulamagelistirme/complaint.dart';
import 'package:mobiluygulamagelistirme/test.dart';
import 'package:mobiluygulamagelistirme/test2.dart';
import 'complaint_data.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://rldxceqyinumedzfptnq.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJsZHhjZXF5aW51bWVkemZwdG5xIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDg1MDQ3MTEsImV4cCI6MjA2NDA4MDcxMX0.ITkluOrezbUujAAbXbHftOb-R5F9L-QP9WO2UeycRss',
  );

  runApp(const MyApp());
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
      initialRoute: '/test',
      routes: {
        '/test': (context) => InsertTestPage(),
        '/complaint': (context) => Complaint(),
        '/complaintList': (context) => ComplaintListPage(),
        '/login': (context) => LoginScreen(),
      },
    );
  }
}

