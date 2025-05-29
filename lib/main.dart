import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mobiluygulamagelistirme/login_screen.dart';
import 'package:mobiluygulamagelistirme/profile.dart';
import 'package:mobiluygulamagelistirme/insert_screen.dart';
import 'package:mobiluygulamagelistirme/complaints.dart';
import 'package:mobiluygulamagelistirme/settings.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'ThemeNotifier.dart';


final ThemeData darkTheme = ThemeData(
  scaffoldBackgroundColor: const Color(0xFF222222),
  primaryColor: const Color(0xFFA63D40),
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFFA63D40),
    brightness: Brightness.dark,
    primary: const Color(0xFFA63D40),
    onPrimary: Colors.white,
    background: const Color(0xFF222222),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white70),
    titleLarge: TextStyle(color: Colors.white, fontSize: 24),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white10,
    labelStyle: const TextStyle(color: Colors.white70),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      minimumSize: const Size(double.infinity, 50),
      backgroundColor: const Color(0xFFA63D40),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF222222),
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    iconTheme: IconThemeData(color: Colors.white),
  ),
  drawerTheme: DrawerThemeData(
    backgroundColor: const Color(0xFF222222),
    scrimColor: Colors.black54,
    elevation: 16,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.horizontal(right: Radius.circular(16)),
    ),
  ),
);

final ThemeData lightTheme = ThemeData(
  scaffoldBackgroundColor: Colors.white,
  primaryColor: const Color(0xFFA63D40),
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFFA63D40),
    brightness: Brightness.light,
    primary: const Color(0xFFA63D40),
    onPrimary: Colors.white,
    background: Colors.white,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.black87),
    bodyMedium: TextStyle(color: Colors.black54),
    titleLarge: TextStyle(color: Colors.black87, fontSize: 24),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.black12,
    labelStyle: const TextStyle(color: Colors.black54),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      minimumSize: const Size(double.infinity, 50),
      backgroundColor: const Color(0xFFA63D40),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black87,
    elevation: 1,
    centerTitle: true,
    titleTextStyle: TextStyle(
      color: Colors.black87,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    iconTheme: IconThemeData(color: Colors.black87),
  ),
  drawerTheme: DrawerThemeData(
    backgroundColor: Colors.white,
    scrimColor: Colors.black54,
    elevation: 16,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.horizontal(right: Radius.circular(16)),
    ),
  ),
);


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('isDarkTheme') ?? false;

  await Supabase.initialize(
    url: 'https://rldxceqyinumedzfptnq.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJsZHhjZXF5aW51bWVkemZwdG5xIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDg1MDQ3MTEsImV4cCI6MjA2NDA4MDcxMX0.ITkluOrezbUujAAbXbHftOb-R5F9L-QP9WO2UeycRss',
  );
  await Firebase.initializeApp();
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('tr')],
      path: 'assets/lang', // kendi yoluna göre ayarla
      fallbackLocale: const Locale('en'),
      child: ChangeNotifierProvider(
        create: (_) => ThemeNotifier(isDark),
        child: const MyApp(),
      ),
    ),
  );
  
}

class MyApp extends StatelessWidget {


  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return MaterialApp(
      title: 'Flutter Demo',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeNotifier.isDarkTheme ? ThemeMode.dark : ThemeMode.light,
      initialRoute: '/login',
      routes: {
        '/newcomplaint': (context) => InsertPage(),
        '/newcomplaintlist': (context) => ComplaintsPage(),
        '/settings': (context) => SettingsPage(),
        '/login': (context) => LoginScreen(),
        '/profile': (context) => ProfilePage(),
      },
    );
  }
}

