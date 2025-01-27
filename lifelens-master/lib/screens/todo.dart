import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../utility/todo_tile.dart';
 // Ensure this is correctly imported

class Todo extends StatefulWidget {
  const Todo({super.key});

  @override
  State<Todo> createState() => _TodoState();
}

class _TodoState extends State<Todo> {
  final _firestore = FirebaseFirestore.instance; // Firestore instance
  final _controller = TextEditingController();

  void saveNewTask() async {
    final taskName = _controller.text.trim();
    if (taskName.isEmpty) return;

    await _firestore.collection('tasks').add({
      'taskName': taskName,
      'completed': false,
      'timestamp': FieldValue.serverTimestamp(), // Add server time
    });

    _controller.clear();
    Navigator.of(context).pop(); // Close dialog
  }

  void toggleTaskCompletion(DocumentSnapshot task) async {
    await _firestore.collection('tasks').doc(task.id).update({
      'completed': !task['completed'],
    });
  }

  void deleteTask(String taskId) async {
    await _firestore.collection('tasks').doc(taskId).delete();
  }

  void createNewTask() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add New Task"),
          content: TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: "Enter task name",
            ),
          ),
          actions: [
            TextButton(


              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),

            ),
            ElevatedButton(
              onPressed: saveNewTask,
              child: const Text("Save"),
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
      floatingActionButton: FloatingActionButton(
        onPressed: createNewTask,
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "View Task",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('tasks')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No tasks available",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final tasks = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              final taskName = task['taskName'];
              final completed = task['completed'];
              final timestamp = task['timestamp']?.toDate();

              final timeText = timestamp != null
                  ? "${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}"
                  : "All-day";

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: ToDOTile(
                  taskName: taskName,
                  taskCompleted: completed,
                  onChanged: (value) => toggleTaskCompletion(task),
                  deleteFunction: (context) => deleteTask(task.id),
                  subtitle: timeText,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
