import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobiluygulamagelistirme/appbar.dart';
import 'package:mobiluygulamagelistirme/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Login screen widget
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}


// State class for the login scren
class _LoginScreenState extends State<LoginScreen> {
  // Controllers for input fields
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();


  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    if (googleUser == null) {
      throw Exception('Google sign in cancelled');
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
    final user = userCredential.user;
    final profile = userCredential.additionalUserInfo?.profile;

    if (user != null && profile != null) {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('uid', user.uid);
      await prefs.setString('email', user.email ?? '');
      await prefs.setString('name', profile['name'] ?? user.displayName ?? '');
      await prefs.setString('firstName', profile['given_name'] ?? '');
      await prefs.setString('lastName', profile['family_name'] ?? '');
      await prefs.setString('photoURL', profile['picture'] ?? user.photoURL ?? '');
    }
    Future.delayed(Duration(milliseconds: 300), () {
      Navigator.pushReplacementNamed(context, '/profile');
    });
    return userCredential;
  }

  Future<UserCredential> signInWithGitHub() async {
    try {
      final githubProvider = GithubAuthProvider();

      final userCredential = await FirebaseAuth.instance.signInWithProvider(githubProvider);
      final user = userCredential.user;
      final profile = userCredential.additionalUserInfo?.profile;

      if (user != null && profile != null) {
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('uid', user.uid);
        await prefs.setString('email', user.email ?? '');
        await prefs.setString('name', profile['name'] ?? user.displayName ?? '');
        await prefs.setString('firstName', profile['given_name'] ?? '');
        await prefs.setString('lastName', profile['family_name'] ?? '');
        await prefs.setString('photoURL', profile['avatar_url'] ?? user.photoURL ?? '');
      }

      Future.delayed(const Duration(milliseconds: 300), () {
        Navigator.pushReplacementNamed(context, '/profile');
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Bu e-posta başka bir giriş yöntemiyle kayıtlı. Lütfen o yöntemle giriş yapın.',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('GitHub ile giriş hatası: ${e.message}'),
          ),
        );
      }
      rethrow;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Beklenmeyen bir hata oluştu: ${e.toString()}'),
        ),
      );
      rethrow;
    }
  }

  Future<void> signInWithEmailAndPassword() async {
    final String email = _usernameController.text.trim();
    final String password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen e-posta ve şifre girin.')),
      );
      return;
    }

    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      final user = userCredential.user;

      if (user != null) {
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('uid', user.uid);
        await prefs.setString('email', user.email ?? '');
        await prefs.setString('name', user.displayName ?? '');
        await prefs.setString('firstName', '');
        await prefs.setString('lastName', '');
        await prefs.setString('photoURL', user.photoURL ?? '');
      }

      Navigator.pushReplacementNamed(context, '/profile');
    } on FirebaseAuthException catch (e) {
      String message = 'Giriş başarısız';

      if (e.code == 'user-not-found') {
        message = 'Bu e-posta ile kayıtlı bir kullanıcı yok.';
      } else if (e.code == 'wrong-password') {
        message = 'Şifre yanlış.';
      } else if (e.code == 'invalid-email') {
        message = 'Geçersiz e-posta formatı.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bir hata oluştu: ${e.toString()}')),
      );
    }
  }


  // Function to login
  Future<void> _login() async {
    final String username = _usernameController.text;
    final String password = _passwordController.text;

    // checks if empty or not
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kullanıcı Adı ve şifre boş olamaz')),
      );
      return;
    }

    // API endpoint for login
    final Uri url = Uri.parse("${BASE_URL}/login/check?username=$username&password=$password");

    try {
      // Sending GET request to the server
      final response = await http.get(url);
      print(response);

      // If login is successful
      if (response.statusCode == 200) {
        // Save cookie from response headers
        String? cookie = response.headers['set-cookie'];
        if (cookie != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString("cookie", cookie); // Store the cookie locally
          print(prefs.getString('cookie'));
        }


        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Giriş başarılı!')),
        );

        Future.delayed(Duration(milliseconds: 300), () {
          Navigator.pushReplacementNamed(context, '/complaint');
        });
      } else {
        // Show failure message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Giriş başarısız!')),
        );
      }
    } catch (e) {
      // Show connection error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bağlantı hatası!')),
      );
    }
  }

  // Function to get headers with stored cookie
  Future<Map<String, String>> _getHeaders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cookie = prefs.getString("cookie");

    return {
      "Content-Type": "application/json",
      if (cookie != null) "Cookie": cookie, // Add cookie if possible
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Hoş Geldiniz',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),

              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Kullanıcı Adı',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 15),

              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Şifre',
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 25),

              ElevatedButton.icon(
                onPressed: signInWithEmailAndPassword,
                icon: const Icon(Icons.email),
                label: const Text('E-posta ile Giriş Yap'),
              ),
              const SizedBox(height: 15),

              ElevatedButton.icon(
                onPressed: signInWithGoogle,
                icon: const Icon(Icons.g_mobiledata),
                label: const Text('Google ile Giriş Yap'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  foregroundColor: Theme.of(context).colorScheme.onSurface,
                  side: const BorderSide(color: Colors.white30),
                ),
              ),
              const SizedBox(height: 15),

              ElevatedButton.icon(
                onPressed: signInWithGitHub,
                icon: const Icon(Icons.code),
                label: const Text('GitHub ile Giriş Yap'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  foregroundColor: Theme.of(context).colorScheme.onSurface,
                  side: const BorderSide(color: Colors.white30),
                ),
              ),
              const SizedBox(height: 20),

              TextButton(
                onPressed: () {},
                child: const Text('Hesabınız yok mu? Kayıt olun'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
