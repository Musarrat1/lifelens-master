import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lifelens/screens/dashboard.dart';
import 'addScheduleScreen.dart';

class ScheduleScreen extends StatefulWidget {
  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Schedule Tracker',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.green),
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
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
                print("Search Query: $searchQuery"); // Debugging searchQuery
              },
              decoration: InputDecoration(
                hintText: "Search events",
                prefixIcon: const Icon(Icons.search, color: Colors.green),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.green),
                ),
              ),
              cursorColor: Colors.black,
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: firestore.collection('schedules').orderBy('date').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No schedules found.'));
                }

                var filteredDocs = snapshot.data!.docs.where((doc) {
                  var task = doc.data() as Map<String, dynamic>;
                  var title = task['title']?.toString().toLowerCase() ?? '';
                  print("Document Title: $title"); // Debugging document title
                  return title.contains(searchQuery); // Local search filtering
                }).toList();

                if (filteredDocs.isEmpty) {
                  return Center(child: Text('No schedules found.'));
                }

                return ListView(
                  children: filteredDocs.map((doc) {
                    var task = doc.data() as Map<String, dynamic>;
                    DateTime scheduleDate = (task['date'] as Timestamp).toDate();

                    return Dismissible(
                      key: Key(doc.id), // Unique key for each item
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: 20),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                        // Show confirmation dialog before deletion
                        bool? confirm = await showDialog(
                          context: context,
                          builder: (ctx) {
                            return AlertDialog(
                              backgroundColor: Colors.white,
                              title: Text("Delete Schedule"),
                              content: Text("Are you sure you want to delete this schedule?"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                  child: Text("Cancel", style: TextStyle(color: Colors.red)),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  child: Text("Delete", style: TextStyle(color: Colors.green)),
                                ),
                              ],
                            );
                          },
                        );
                        return confirm;
                      },
                      onDismissed: (direction) async {
                        // Delete the schedule document using its document ID.
                        await firestore.collection('schedules').doc(doc.id).delete();
                      },
                      child: Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: Colors.green),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          title: Text(task['title']),
                          subtitle: Text(task['description']),
                          trailing: Text(scheduleDate.toString()),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddScheduleScreen()),
        ),
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.green,
      ),
    );
  }
}
