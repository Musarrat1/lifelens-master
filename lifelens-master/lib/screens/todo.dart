import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lifelens/screens/taskReport.dart';

class Todo extends StatefulWidget {
  const Todo({super.key});

  @override
  State<Todo> createState() => _TodoState();
}

class _TodoState extends State<Todo> {
  final _firestore = FirebaseFirestore.instance;
  String searchQuery = "";
  final _controller = TextEditingController();

  void saveNewTask() async {
    final taskName = _controller.text.trim();
    if (taskName.isEmpty) return;

    await _firestore.collection('tasks').add({
      'taskName': taskName,
      'completed': false,
      'deleted': false, // Ensure task is not marked as deleted
      'timestamp': FieldValue.serverTimestamp(),
    });

    _controller.clear();
    Navigator.of(context).pop(); // Close the add-task dialog
  }

  void toggleTaskCompletion(DocumentSnapshot task) async {
    bool isCompleted = !task['completed'];
    await _firestore.collection('tasks').doc(task.id).update({
      'completed': isCompleted,
    });

    if (isCompleted) {
      debugPrint("Task Marked as Completed: ${task['taskName']}");
    }
  }

  void deleteTask(DocumentSnapshot task) async {
    String taskId = task.id;
    String taskName = task['taskName'];
    bool isCompleted = task['completed'];
    Timestamp? timestamp = task['timestamp'];

    // Move deleted task to "deleted_tasks" collection
    await _firestore.collection('deleted_tasks').doc(taskId).set({
      'taskName': taskName,
      'completed': isCompleted,
      'timestamp': timestamp ?? FieldValue.serverTimestamp(),
    });

    // Delete from the original collection
    await _firestore.collection('tasks').doc(taskId).delete();
  }

  void _showAddTaskDialog() {
    _controller.clear();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text("Add New Task"),
          content: TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: "Enter task name",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Close the dialog
              child: const Text("Cancel", style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: saveNewTask, // Save the task
              child: const Text("Save", style: TextStyle(color: Colors.green)),
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
        onPressed: _showAddTaskDialog, // Open dialog to add a new task
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
            fontSize: 22,
            color: Colors.green,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.view_list, color: Colors.green),
            onPressed: () {
              // Navigate to the separate Task Report page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TaskReportPage()),
              );
            },
            tooltip: "Show Task Report",
          ),
        ],
      ),
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
                hintText: "Search Tasks",
                prefixIcon: const Icon(Icons.search, color: Colors.green),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.green),
                ),
              ),
              cursorColor: Colors.black,
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
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

                // Filter tasks based on search query
                final filteredTasks = tasks.where((task) {
                  final taskName = task['taskName'].toString().toLowerCase();
                  return taskName.contains(searchQuery);
                }).toList();

                if (filteredTasks.isEmpty) {
                  return const Center(
                    child: Text(
                      "No tasks found",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredTasks.length,
                  itemBuilder: (context, index) {
                    final task = filteredTasks[index];
                    final taskName = task['taskName'];
                    final completed = task['completed'];
                    final timestamp = task['timestamp']?.toDate();

                    final dateText = timestamp != null
                        ? "${timestamp.day}/${timestamp.month}/${timestamp.year}"
                        : "No date";
                    final timeText = timestamp != null
                        ? "${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}"
                        : "All-day";

                    return Dismissible(
                      key: Key(task.id), // Unique key for each task
                      direction: DismissDirection.endToStart, // Swipe right-to-left
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                        // Show confirmation dialog before deletion
                        bool? confirm = await showDialog(
                          context: context,
                          builder: (ctx) {
                            return AlertDialog(
                              title: const Text("Delete Task"),
                              content: const Text(
                                  "Are you sure you want to delete this task?"),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(ctx).pop(false),
                                  child: const Text("No"),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(ctx).pop(true),
                                  child: const Text("Yes"),
                                ),
                              ],
                            );
                          },
                        );
                        return confirm;
                      },
                      onDismissed: (direction) async {
                        // Delete the task
                        deleteTask(task);
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.green, width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ToDOTile(
                            taskName: taskName,
                            taskCompleted: completed,
                            onChanged: (value) => toggleTaskCompletion(task),
                            deleteFunction: () => deleteTask(task),
                            subtitle: "$dateText at $timeText",
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
    );
  }
}

class ToDOTile extends StatelessWidget {
  final String taskName;
  final bool taskCompleted;
  final void Function(bool?) onChanged;
  final void Function() deleteFunction;
  final String? subtitle;

  const ToDOTile({
    super.key,
    required this.taskName,
    required this.taskCompleted,
    required this.onChanged,
    required this.deleteFunction,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        value: taskCompleted,
        onChanged: onChanged,
      ),
      title: Text(
        taskName,
        style: TextStyle(
          decoration: taskCompleted ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      // Optionally add a trailing delete icon:
      // trailing: IconButton(
      //   icon: const Icon(Icons.delete, color: Colors.red),
      //   onPressed: deleteFunction,
      // ),
    );
  }
}