import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TaskReportPage extends StatelessWidget {
  // Removed 'const' from the constructor due to non-constant fields.
  TaskReportPage({super.key});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool?> _showConfirmationDialog(
      BuildContext context, String title, String content) async {
    return await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text("No",style: TextStyle(color: Colors.green),),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text("Yes",style: TextStyle(color: Colors.green),),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteCompletedTask(
      BuildContext context, DocumentSnapshot doc) async {
    bool? confirm = await _showConfirmationDialog(
      context,
      "Delete Task",
      "Are you want to permanently delete this completed task?",
    );

    if (confirm == true) {
      await _firestore.collection('tasks').doc(doc.id).delete();
    }
  }

  Future<void> _deleteDeletedTask(
      BuildContext context, DocumentSnapshot doc) async {
    bool? confirm = await _showConfirmationDialog(
      context,
      "Delete Permanently",
      "Are you want to permanently delete this task?",
    );

    if (confirm == true) {
      await _firestore.collection('deleted_tasks').doc(doc.id).delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Task Report",style: TextStyle(color: Colors.green,fontWeight: FontWeight.bold),),
        backgroundColor: Colors.white,
      ),
      body: ListView(

        padding: const EdgeInsets.all(16.0),




        children: [


          const Text(
            "✅ Completed Tasks:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          // Note: Ordering is removed for testing purposes.
          StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('tasks')
                .where('completed', isEqualTo: true)
                .where('deleted', isEqualTo: false)
            //.orderBy('timestamp', descending: true) // Remove temporarily
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                // Print a debug message to the console.
                debugPrint("No completed tasks found.");
                return const Text("No completed tasks available.");
              }

              return Column(

                children: snapshot.data!.docs.map((doc) {
                  debugPrint("Found completed task: ${doc['taskName']}");
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading:
                      const Icon(Icons.check_circle, color: Colors.green),
                      title: Text(doc['taskName'].toString()),
                      subtitle: doc['timestamp'] != null
                          ? Text(
                          "Date: ${doc['timestamp'].toDate().day}/${doc['timestamp'].toDate().month}/${doc['timestamp'].toDate().year}")
                          : const Text("No timestamp"),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteCompletedTask(context, doc),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const Divider(height: 40, thickness: 2),
          const Text(
            "🗑 Deleted Tasks:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('deleted_tasks')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Text("No deleted tasks available.");
              }

              return Column(
                children: snapshot.data!.docs.map((doc) {
                  return Card(
                    color: Colors.white,
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: const Icon(Icons.delete, color: Colors.red),
                      title: Text(doc['taskName'].toString()),
                      subtitle: doc['timestamp'] != null
                          ? Text(
                          "Date: ${doc['timestamp'].toDate().day}/${doc['timestamp'].toDate().month}/${doc['timestamp'].toDate().year}")
                          : null,
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_forever, color: Colors.red),
                        onPressed: () => _deleteDeletedTask(context, doc),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
