import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String userName = "Loading...";
  String userEmail = "Loading...";

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Fetch user data when the screen loads
  }

  Future<void> _fetchUserData() async {
    User? user = _auth.currentUser; // Get current logged-in user

    if (user != null) {
      DocumentSnapshot userDoc =
      await _firestore.collection('users_info').doc(user.uid).get();

      if (userDoc.exists) {
        setState(() {
          userName = userDoc['name'] ?? "No Name";
          userEmail = userDoc['email'] ?? "No Email";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home Screen")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Welcome, $userName",
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("Email: $userEmail", style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
