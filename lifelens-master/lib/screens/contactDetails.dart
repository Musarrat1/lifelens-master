import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'addContactScreen.dart';

class ContactDetails extends StatefulWidget {
  const ContactDetails({super.key});

  @override
  State<ContactDetails> createState() => _ContactDetailsState();
}

class _ContactDetailsState extends State<ContactDetails> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Contact Details",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddContactScreen(
                onAddContact: (Map<String, String> contact) async {
                  await _firestore.collection('contacts').add(contact);
                },
              ),
            ),
          );
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('contacts').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No contacts available",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final contactDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: contactDocs.length,
            itemBuilder: (context, index) {
              final contact = contactDocs[index];
              return ListTile(
                title: Text(
                  "${contact['firstName']} ${contact['lastName']}",
                ),
                subtitle: Text(contact['phone'] ?? ""),
                onTap: () {
                  _showContactDetailsDialog(context, contact);
                },
              );
            },
          );
        },
      ),
    );
  }

  void _showContactDetailsDialog(BuildContext context, QueryDocumentSnapshot contact) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("${contact['firstName']} ${contact['lastName']}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Phone: ${contact['phone'] ?? 'N/A'}"),
              Text("Email: ${contact['email'] ?? 'N/A'}"),
              Text("Company: ${contact['company'] ?? 'N/A'}"),
              Text("Birthday: ${contact['birthday'] ?? 'N/A'}"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Close",
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        );
      },
    );
  }
}
