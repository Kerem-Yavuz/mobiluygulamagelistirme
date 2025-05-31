import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
    final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;

    if (user != null && profile != null) {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('uid', user.uid);
      await prefs.setString('email', user.email ?? '');
      await prefs.setString('name', profile['name'] ?? user.displayName ?? '');
      await prefs.setString('firstName', profile['given_name'] ?? '');
      await prefs.setString('lastName', profile['family_name'] ?? '');
      await prefs.setString('photoURL', profile['picture'] ?? user.photoURL ?? '');

      final supabase = Supabase.instance.client;

      if (isNewUser) {

        Navigator.pushReplacementNamed(context, '/newcomplaintlist');

        final extraInfo = await showExtraInfoDialog(context);
        await supabase.from('Profil_Bilgileri').insert({
          'isim': profile['given_name'] ?? '',
          'soyisim': profile['family_name'] ?? '',
          'profil_resmi': profile['picture'] ?? '',
          'email': user.email ?? '',
          'uid': user.uid,
        });


        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'dogumYeri': extraInfo?['dogumYeri'] ?? '',
          'dogumTarihi': extraInfo?['dogumTarihi'] ?? '',
          'yasadigiIl': extraInfo?['yasadigiIl'] ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        });

        print('✅ New user inserted with extra info into Supabase And Firebase');
      } else {
        print("Not new User");
      }
    }

    Future.delayed(Duration(milliseconds: 300), () {
      Navigator.pushReplacementNamed(context, '/newcomplaintlist');
    });

    return userCredential;
  }


  Future<UserCredential> signInWithGitHub() async {
    try {
      final githubProvider = GithubAuthProvider();

      final userCredential = await FirebaseAuth.instance.signInWithProvider(githubProvider);
      final user = userCredential.user;
      final profile = userCredential.additionalUserInfo?.profile;
      final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
      if (user != null && profile != null) {
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('uid', user.uid);
        await prefs.setString('email', user.email ?? '');
        await prefs.setString('name', profile['name'] ?? user.displayName ?? '');
        await prefs.setString('firstName', profile['given_name'] ?? '');
        await prefs.setString('lastName', profile['family_name'] ?? '');
        await prefs.setString('photoURL', profile['avatar_url'] ?? user.photoURL ?? '');

        final supabase = Supabase.instance.client;

        if (isNewUser) {
          Navigator.pushReplacementNamed(context, '/newcomplaintlist');
          final extraInfo = await showExtraInfoDialog(context);
            await supabase.from('Profil_Bilgileri').insert({
              'isim': profile['given_name'] ?? '',
              'soyisim': profile['family_name'] ?? '',
              'profil_resmi': profile['avatar_url'] ?? '',
              'email': user.email ?? '',
              'uid': user.uid,
            });


            await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
              'dogumYeri': extraInfo?['dogumYeri'] ?? '',
              'dogumTarihi': extraInfo?['dogumTarihi'] ?? '',
              'yasadigiIl': extraInfo?['yasadigiIl'] ?? '',
              'createdAt': FieldValue.serverTimestamp(),
            });

            print('✅ New user inserted with extra info into Supabase And Firebase');
        } else {
          print("Not new User");
        }

      }
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'samecreditential'.tr(),
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
        SnackBar(content: Text('providecreditentials'.tr())),
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

      Navigator.pushReplacementNamed(context, '/newcomplaintlist');
    } on FirebaseAuthException catch (e) {
      String message = 'Giriş başarısız';

      if (e.code == 'user-not-found') {
        message = 'nouser'.tr();
      } else if (e.code == 'wrong-password') {
        message = 'wrongpass'.tr();
      } else if (e.code == 'invalid-email') {
        message = 'invalidemailformat'.tr();
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
                'welcome'.tr(),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),

              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'email'.tr(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 15),

              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'password'.tr(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 25),

              ElevatedButton.icon(
                onPressed: signInWithEmailAndPassword,
                icon: const Icon(Icons.email),
                label: Text("login".tr()),
              ),
              const SizedBox(height: 15),

              ElevatedButton.icon(
                onPressed: signInWithGoogle,
                icon: const Icon(Icons.g_mobiledata),
                label: Text('logingoogle'.tr()),
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
                label: Text('logingithub'.tr()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  foregroundColor: Theme.of(context).colorScheme.onSurface,
                  side: const BorderSide(color: Colors.white30),
                ),
              ),
              const SizedBox(height: 20),

              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/signup');
                },
                child: Text('signup'.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


Future<Map<String, String>?> showExtraInfoDialog(BuildContext context) async {
  final _formKey = GlobalKey<FormState>();

  DateTime? _selectedDate;
  final _dogumYeriController = TextEditingController();
  final _dogumTarihiController = TextEditingController();
  final _yasadigiIlController = TextEditingController();

  return showDialog<Map<String, String>>(
    context: context,
    barrierDismissible: false, // Dışarı tıklayınca kapanmasın, zorunlu doldursun
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Ek Bilgi Gerekli'),
            content: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _dogumYeriController,
                      decoration: InputDecoration(labelText: 'Doğum Yeri'),
                      validator: (val) => val == null || val.isEmpty ? 'Doğum Yeri Girin' : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _dogumTarihiController,
                      decoration: InputDecoration(
                        labelText: 'Doğum Tarihi',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      validator: (val) => val == null || val.isEmpty ? 'Doğum Tarihi Girin' : null,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime(2000, 1, 1),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                          locale: const Locale('tr'),
                        );
                        if (picked != null) {
                          setState(() {
                            _selectedDate = picked;
                            _dogumTarihiController.text =
                            "${picked.day.toString().padLeft(2, '0')}.${picked.month.toString().padLeft(2, '0')}.${picked.year}";
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _yasadigiIlController,
                      decoration: InputDecoration(labelText: 'Yaşadığı İl'),
                      validator: (val) => val == null || val.isEmpty ? 'İl Girin' : null,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(null); // iptal edildiğinde null döner
                },
                child: Text('Atla'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.of(context).pop({
                      'dogumYeri': _dogumYeriController.text.trim(),
                      'dogumTarihi': _dogumTarihiController.text.trim(),
                      'yasadigiIl': _yasadigiIlController.text.trim(),
                    });
                  }
                },
                child: Text('Kaydet'),
              ),
            ],
          );
        },
      );
    },
  );
}

