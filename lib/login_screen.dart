import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobiluygulamagelistirme/appbar.dart';
import 'package:mobiluygulamagelistirme/drawer.dart';
import 'package:mobiluygulamagelistirme/constants.dart'; // <-- Constants dosyasını ekledik
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    final String email = _emailController.text;
    final String password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('E-posta ve şifre boş olamaz')),
      );
      return;
    }

    final Uri url = Uri.parse("${BASE_URL}/login/check?username=$email&password=$password");

    try {
      final response = await http.get(url);
      print(response);
      if (response.statusCode == 200) {
        // Çerezleri kaydet
        String? cookie = response.headers['set-cookie'];
        if (cookie != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString("cookie", cookie);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Giriş başarılı!')),
        );
        Future.delayed(Duration(milliseconds: 300), () {
          Navigator.pushReplacementNamed(context, '/complaint');
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Giriş başarısız!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bağlantı hatası!')),
      );
    }
  }

  Future<Map<String, String>> _getHeaders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cookie = prefs.getString("cookie");

    return {
      "Content-Type": "application/json",
      if (cookie != null) "Cookie": cookie,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: "Giriş Yap"),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'E-Posta',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Şifre',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                child: Text('Giriş Yap'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
