import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ContactDetailsPage extends StatefulWidget {
  final Map<String, dynamic> contact;
  final String contactId;

  const ContactDetailsPage({
    super.key,
    required this.contact,
    required this.contactId,
  });

  @override
  State<ContactDetailsPage> createState() => _ContactDetailsPageState();
}

class _ContactDetailsPageState extends State<ContactDetailsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _companyController;
  late TextEditingController _birthdayController;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.contact['firstName']);
    _lastNameController = TextEditingController(text: widget.contact['lastName']);
    _phoneController = TextEditingController(text: widget.contact['phone']);
    _emailController = TextEditingController(text: widget.contact['email']);
    _companyController = TextEditingController(text: widget.contact['company']);
    _birthdayController = TextEditingController(text: widget.contact['birthday']);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _companyController.dispose();
    _birthdayController.dispose();
    super.dispose();
  }

  Future<void> _updateContact() async {
    if (_formKey.currentState!.validate()) {
      await _firestore.collection('contacts').doc(widget.contactId).update({
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'phone': _phoneController.text,
        'email': _emailController.text,
        'company': _companyController.text,
        'birthday': _birthdayController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Contact updated successfully!")),
      );

      Navigator.of(context).pop();
    }
  }

  void _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(

          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(imageUrl),
            TextButton(

              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Close",style: TextStyle(color: Colors.green),),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Contact Details",
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),

      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (widget.contact['imageUrl'] != null && widget.contact['imageUrl'].isNotEmpty)
                GestureDetector(
                  onTap: () => _showImageDialog(widget.contact['imageUrl']!),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(widget.contact['imageUrl']!),
                    radius: 50,
                  ),
                ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: "First Name", border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty ? "Please enter a first name" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: "Last Name", border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty ? "Please enter a last name" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: "Phone", border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty ? "Please enter a phone number" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _companyController,
                decoration: const InputDecoration(labelText: "Company", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _birthdayController,
                decoration: const InputDecoration(labelText: "Birthday", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateContact,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text(
                  "Update Contact",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}