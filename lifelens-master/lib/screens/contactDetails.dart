import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'addContactScreen.dart'; // Replace with the correct file path
import 'contact_details_page.dart'; // Import the new page

class ContactDetails extends StatefulWidget {
  const ContactDetails({super.key});

  @override
  State<ContactDetails> createState() => _ContactDetailsState();
}

class _ContactDetailsState extends State<ContactDetails> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String searchQuery = "";

  // Function to delete contact from Firestore
  Future<void> _deleteContact(String contactId) async {
    await _firestore.collection('contacts').doc(contactId).delete();
  }

  // Function to show contact details in a dialog
  void _showContactDetails(Map<String, dynamic> contact, String contactId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactDetailsPage(
          contact: contact,
          contactId: contactId,
        ),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text("Delete Contact"),
          content: const Text("Are you sure you want to delete this contact?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel", style: TextStyle(color: Colors.green)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Delete", style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }

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
            color: Colors.green,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: "Search contacts...",
                prefixIcon: const Icon(Icons.search, color: Colors.green),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          // Contact List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
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

                // Filter contacts based on search query
                final filteredContacts = contactDocs.where((doc) {
                  final contact = doc.data() as Map<String, dynamic>;
                  final firstName = (contact['firstName'] ?? "").toLowerCase();
                  final lastName = (contact['lastName'] ?? "").toLowerCase();
                  final phone = (contact['phone'] ?? "").toLowerCase();
                  return firstName.contains(searchQuery) ||
                      lastName.contains(searchQuery) ||
                      phone.contains(searchQuery);
                }).toList();

                return ListView.builder(
                  itemCount: filteredContacts.length,
                  itemBuilder: (context, index) {
                    final contact = filteredContacts[index];
                    final contactId = contact.id; // Get the document ID
                    final contactData = contact.data() as Map<String, dynamic>;

                    // Debugging: Print the imageUrl
                    print("Contact imageUrl: ${contactData['imageUrl']}");

                    return Dismissible(
                      key: Key(contactId),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                        final bool? confirmed = await _showDeleteConfirmationDialog();
                        return confirmed;
                      },
                      onDismissed: (direction) async {
                        // Delete the contact after confirmation
                        await _deleteContact(contactId);
                      },
                      child: ListTile(
                        leading: contactData['imageUrl'] != null && contactData['imageUrl'].isNotEmpty
                            ? CircleAvatar(
                          backgroundImage: NetworkImage(contactData['imageUrl']),
                        )
                            : const CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                        title: Text(
                          "${contactData['firstName']} ${contactData['lastName']}",
                        ),
                        subtitle: Text(contactData['phone'] ?? ""),
                        onTap: () {
                          // Show contact details when tapped
                          _showContactDetails(contactData, contactId);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddContactScreen(
                onAddContact: (Map<String, String> contact) async {
                  // Add the contact to Firestore
                  await _firestore.collection('contacts').add(contact);
                  print("Contact added to Firestore"); // Debugging: Confirm Firestore update
                },
              ),
            ),
          );
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}