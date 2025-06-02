import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobiluygulamagelistirme/appbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  bool _expandExtraFields = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _dogumYeriController = TextEditingController();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _dogumTarihiController = TextEditingController();
  final _yasadigiIlController = TextEditingController();

  bool _loading = false;

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final uid = credential.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'dogumYeri': _dogumYeriController.text.trim() ?? '',
        'dogumTarihi': _selectedDate ?? '',
        'yasadigiIl': _yasadigiIlController.text.trim() ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      final supabase = Supabase.instance.client;
      try {
        await supabase.from('Profil_Bilgileri').insert({
          'isim': _nameController.text.trim() ?? "",
          'soyisim': _surnameController.text.trim() ?? "",
          'email': _emailController.text.trim(),
          'uid': uid,
        });

        print('✅ New user inserted into Supabase');
      } catch (e) {
        print('Supabase insert error: $e');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kayıt başarılı')),
      );

      Future.delayed(const Duration(milliseconds: 300), () {
        Navigator.pushReplacementNamed(context, '/login');
      });

      // Navigate to home or login
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: ${e.message}')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _dogumYeriController.dispose();
    _dogumTarihiController.dispose();
    _yasadigiIlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: "signup".tr()),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'email'.tr()),
                validator: (val) => val!.isEmpty ? 'Email girin' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'password'.tr()),
                obscureText: true,
                validator: (val) => val!.length < 6 ? 'En az 6 karakter' : null,
              ),
              const SizedBox(height: 20),

              /// Genişleyebilen Alan
              ExpansionTile(
                title: Text('additionalinfo'.tr()),
                initiallyExpanded: _expandExtraFields,
                children: [
                  TextFormField(
                    controller: _dogumYeriController,
                    decoration: InputDecoration(labelText: 'birthplace'.tr()),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _dogumTarihiController,
                    decoration: InputDecoration(
                      labelText: 'birthdate'.tr(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
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
                    decoration: const InputDecoration(labelText: 'Yaşadığı İl'),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'İsim'),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _surnameController,
                    decoration: const InputDecoration(labelText: 'Soyisim'),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _signUp,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('Kayıt Ol'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
