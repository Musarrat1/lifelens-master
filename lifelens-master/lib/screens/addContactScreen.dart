import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class AddContactScreen extends StatefulWidget {
  final Function(Map<String, String>) onAddContact;

  const AddContactScreen({required this.onAddContact, Key? key}) : super(key: key);

  @override
  State<AddContactScreen> createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController birthdayController = TextEditingController();

  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<String?> _uploadImage(File image) async {
    final url = Uri.parse('https://api.imgbb.com/1/upload');
    final apiKey = '14ab40f2690145fddb823a00b2de8f27';

    final request = http.MultipartRequest('POST', url)
      ..fields['key'] = apiKey
      ..files.add(await http.MultipartFile.fromPath(
        'image',
        image.path,
        contentType: MediaType('image', 'jpeg'),
      ));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      print("ImgBB Response: $responseData"); // Debugging: Print the API response
      final jsonResponse = jsonDecode(responseData);
      return jsonResponse['data']['url'];
    } else {
      print('Failed to upload image. Status Code: ${response.statusCode}');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "New Contact",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              String? imageUrl;
              if (_image != null) {
                imageUrl = await _uploadImage(_image!);
                print("Image URL: $imageUrl"); // Debugging: Print the image URL
              }

              final contactData = {
                "firstName": firstNameController.text,
                "lastName": lastNameController.text,
                "company": companyController.text,
                "phone": phoneController.text,
                "email": emailController.text,
                "birthday": birthdayController.text,
                "imageUrl": imageUrl ?? '',
              };

              print("Contact Data: $contactData"); // Debugging: Print the contact data

              widget.onAddContact(contactData);
              Navigator.pop(context);
            },
            child: const Text(
              "Done",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: _image != null ? FileImage(_image!) : null,
                        child: _image == null
                            ? const Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.white,
                        )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _pickImage,
                      child: const Text(
                        "Add Photo",
                        style: TextStyle(color: Colors.green, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: firstNameController,
                hintText: "First name",
              ),
              const SizedBox(height: 10),
              CustomTextField(
                controller: lastNameController,
                hintText: "Last name",
              ),
              const SizedBox(height: 10),
              CustomTextField(
                controller: companyController,
                hintText: "Company",
              ),
              const SizedBox(height: 10),
              CustomTextField(
                controller: phoneController,
                hintText: "Add Phone",
              ),
              const SizedBox(height: 10),
              CustomTextField(
                controller: emailController,
                hintText: "Add email",
              ),
              const SizedBox(height: 10),
              CustomTextField(
                controller: birthdayController,
                hintText: "Add Birthday",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const CustomTextField({required this.controller, required this.hintText, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(fontSize: 16, color: Colors.grey[600]),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.green),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.green),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.green, width: 2),
        ),
      ),
    );
  }
}