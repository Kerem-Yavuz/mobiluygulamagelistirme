import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // SharedPreferences data
  String? uid;
  String? email;
  String? name;
  String? firstName;
  String? lastName;
  String? photoURL;

  // Firebase data
  User? firebaseUser;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      uid = prefs.getString('uid');
      email = prefs.getString('email');
      name = prefs.getString('name');
      firstName = prefs.getString('firstName');
      lastName = prefs.getString('lastName');
      photoURL = prefs.getString('photoURL');

      firebaseUser = FirebaseAuth.instance.currentUser;
    });
  }

  Widget buildInfo(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        "$label: ${value ?? '-'}",
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("From SharedPreferences", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            buildInfo("UID", uid),
            buildInfo("Email", email),
            buildInfo("Name", name),
            buildInfo("First Name", firstName),
            buildInfo("Last Name", lastName),
            buildInfo("Photo URL", photoURL),
            const SizedBox(height: 20),
            const Text("From FirebaseAuth", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            buildInfo("Firebase UID", firebaseUser?.uid),
            buildInfo("Firebase Email", firebaseUser?.email),
            buildInfo("Firebase Name", firebaseUser?.displayName),
          ],
        ),
      ),
    );
  }
}
