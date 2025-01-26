import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lifelens/screens/dashboard.dart';
import 'package:lifelens/screens/tProfileImage.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ... (other imports)

class Userprofile extends StatefulWidget {
  const Userprofile({super.key});

  @override
  State<Userprofile> createState() => _UserprofileState();
}

// class _UserprofileState extends State<Userprofile> {
//   final currentUser = FirebaseAuth.instance.currentUser;
//   Map<String, dynamic>? userData; // Store fetched user data
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchUserData(); // Fetch data when the widget initializes
//   }
//
//   Future<void> _fetchUserData() async {
//     userData = await fetchUserData(); // Call your fetchUserData function
//     if (mounted) {
//       setState(() {}); // Update the UI if the widget is still mounted
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => Dashboard()),
//             );
//           },
//           icon: const Icon(LineAwesomeIcons.angle_left_solid),
//         ),
//         backgroundColor: Colors.white,
//         title: const Text(
//           "Profile",
//           style: TextStyle(
//             color: Colors.green,
//             fontSize: 40,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//       backgroundColor: Colors.white,
//       body: SingleChildScrollView(
//         child: Container(
//           padding: const EdgeInsets.all(12),
//           child: Column(
//             children: [
//               // Centering the profile image
//               Center(
//                 child: SizedBox(
//                   width: 120,
//                   height: 120,
//                   child: Image(
//                     image: AssetImage(tProfileImage), // Ensure this asset is correctly configured
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20), // Add spacing for better layout
//
//               // Display user name with FutureBuilder
//               FutureBuilder<Map<String, dynamic>?>(
//                 future: fetchUserData(),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return const CircularProgressIndicator(); // Show loading indicator
//                   } else if (snapshot.hasError) {
//                     return Text('Error: ${snapshot.error}'); // Show error message
//                   } else if (snapshot.hasData && snapshot.data != null) {
//                     return Text(
//                       snapshot.data!['name'] ?? "No Name", // Access name from fetched data
//                       style: const TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black,
//                       ),
//                     );
//                   } else {
//                     return const Text("No Name"); // Handle case where data is null
//                   }
//                 },
//               ),
//
//               const SizedBox(height: 10),
//
//               // Display user email with FutureBuilder (similar to name)
//               FutureBuilder<Map<String, dynamic>?>(
//                 future: fetchUserData(),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return const CircularProgressIndicator(); // Show loading indicator
//                   } else if (snapshot.hasError) {
//                     return Text('Error: ${snapshot.error}'); // Show error message
//                   } else if (snapshot.hasData && snapshot.data != null) {
//                     return Text(
//                       snapshot.data!['email'] ?? "No Email", // Access email from fetched data
//                       style: const TextStyle(
//                         fontSize: 16,
//                         color: Colors.grey,
//                       ),
//                     );
//                   } else {
//                     return const Text("No Email"); // Handle case where data is null
//                   }
//                 },
//               ),
//
//               // ... (rest of your widgets)
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


class _UserprofileState extends State<Userprofile> {
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
      appBar: AppBar(title: const Text("Profile")),
      body:Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
         SizedBox(
                   width: 120,
                  height: 120,
                  child: Image(
                     image: AssetImage(tProfileImage), // Ensure this asset is correctly configured
                   ),
                ),
            const SizedBox(height: 10),
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
