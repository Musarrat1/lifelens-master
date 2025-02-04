import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class UserInfoScreen extends StatefulWidget {
  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  String _name = "";
  String _email = "";
  String _facebookId = "";
  String _bloodGroup = "";
  String _profileImage = "";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    try {
      setState(() => _isLoading = true);
      _user = _auth.currentUser;

      if (_user == null) {
        print("No user logged in!");
        setState(() => _isLoading = false);
        return;
      }

      print("Fetching user data for UID: ${_user!.uid}");

      DocumentSnapshot userDoc =
      await _firestore.collection("users_info").doc(_user!.uid).get();

      if (userDoc.exists) {
        Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;

        if (data != null) {
          print("User data found: $data");
          setState(() {
            _name = data["name"] ?? "No Name";
            _email = data["email"] ?? _user!.email ?? "No Email";
            _facebookId = data["facebookId"] ?? "No Facebook ID";
            _bloodGroup = data["bloodGroup"] ?? "Not Provided";
            _profileImage = data["profileImage"] ?? ""; // Fetching Image
          });
        } else {
          print("User document exists but has no data!");
        }
      } else {
        print("User document not found in Firestore.");
      }
    } catch (e) {
      print("Error fetching user data: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateUserInfo() async {
    try {
      await _firestore.collection("users_info").doc(_user!.uid).set({
        "name": _name,
        "email": _email,
        "facebookId": _facebookId,
        "bloodGroup": _bloodGroup,
        "profileImage": _profileImage, // Save image URL to Firestore
      }, SetOptions(merge: true));

      Fluttertoast.showToast(msg: "Profile updated successfully!");
      print("Profile updated: Name: $_name, Email: $_email");
    } catch (e) {
      print("Error updating user info: $e");
      Fluttertoast.showToast(msg: "Error updating profile!");
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse("https://api.imgbb.com/1/upload?key=14ab40f2690145fddb823a00b2de8f27"),
      );

      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
      var response = await request.send();

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        var jsonData = json.decode(responseBody);
        String imageUrl = jsonData["data"]["url"];

        setState(() {
          _profileImage = imageUrl;
        });
        await _firestore.collection("users_info").doc(_user!.uid).set(
          {"profileImage": imageUrl},
          SetOptions(merge: true),
        );

        Fluttertoast.showToast(msg: "Profile picture updated!");
      } else {
        print("Image upload failed: ${response.statusCode}");
        Fluttertoast.showToast(msg: "Image upload failed!");
      }
    } catch (e) {
      print("Error uploading image: $e");
      Fluttertoast.showToast(msg: "Error uploading image!");
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      await _uploadImage(imageFile);
    }
  }

  Widget _buildEditableField(String label, String value, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onChanged: onChanged,
        controller: TextEditingController(text: value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "User Profile",
          style: GoogleFonts.poppins(color: Colors.green, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(color: Colors.green),
      )
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage, // Tap to pick image
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _profileImage.isNotEmpty
                      ? NetworkImage(_profileImage) // Load image from Firestore
                      : AssetImage("assets/default_user.png") as ImageProvider,
                  backgroundColor: Colors.grey.shade300,
                ),
              ),
              const SizedBox(height: 20),
              _buildEditableField("Name", _name, (val) => _name = val),
              _buildEditableField("Email", _email, (val) => _email = val),
              _buildEditableField("Facebook ID", _facebookId, (val) => _facebookId = val),
              _buildEditableField("Blood Group", _bloodGroup, (val) => _bloodGroup = val),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: _updateUserInfo,
                child: Text(
                  "Save Changes",
                  style: GoogleFonts.poppins(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}