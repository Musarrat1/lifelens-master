import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'healthEntryScreen.dart';
import 'dashboard.dart'; // Import the Dashboard screen

class HealthDataScreen extends StatefulWidget {
  const HealthDataScreen({super.key});

  @override
  _HealthDataScreenState createState() => _HealthDataScreenState();
}

class _HealthDataScreenState extends State<HealthDataScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String searchQuery = "";

  // Function to delete a health data entry from Firestore
  Future<void> _deleteHealthData(String docId) async {
    await firestore.collection('health_data').doc(docId).delete();
    print("Health data entry deleted");
  }

  // Function to show a confirmation dialog before deletion
  Future<bool?> _showDeleteConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text("Delete Entry"),
          content: const Text("Are you sure you want to delete this health data entry?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text("Cancel",style: TextStyle(color: Colors.green),),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Health Data',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Dashboard()),
            );
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: "Search by weight or steps...",

                prefixIcon: const Icon(Icons.search,color: Colors.green,),
                border: OutlineInputBorder(

                  borderRadius: BorderRadius.circular(10),
                 borderSide: BorderSide(color: Colors.green),

                ),

              ),
              cursorColor: Colors.black,

            ),
          ),

          // Health Data List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: firestore
                  .collection('health_data')
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No health data available.'));
                }
                var filteredDocs = snapshot.data!.docs.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  String weight = data['weight'].toString().toLowerCase();
                  String steps = data['steps'].toString().toLowerCase();

                  return weight.contains(searchQuery) || steps.contains(searchQuery);
                }).toList();

                return ListView.builder(
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    var doc = filteredDocs[index];
                    var data = doc.data() as Map<String, dynamic>;

                    return Dismissible(
                      key: Key(doc.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.bottomCenter,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                        return await _showDeleteConfirmationDialog(context);
                      },
                      onDismissed: (direction) async {
                        await _deleteHealthData(doc.id);
                      },
                      child: Container(

                        child: Card(
                          color: Colors.white,

                        shape:
                          RoundedRectangleBorder(

                            side: BorderSide(color: Colors.green,),
                            borderRadius: BorderRadius.circular(10),

                          ),


                          child: ListTile(

                            title: Text('Weight: ${data['weight']} kg'),
                            subtitle: Text('Steps: ${data['steps']}'),
                            trailing: Text(
                              '${(data['date'] as Timestamp).toDate()}',
                              style: const TextStyle(fontSize: 12),
                            ),

                          ),


                        ),

                      ),

                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      // Floating action button to add new health data
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HealthEntryScreen()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.green,
      ),
    );
  }
}
