import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lifelens/data/database.dart';
import 'package:lifelens/utility/todo_tile.dart';
import '../utility/dialog_box.dart';
class Todo extends StatefulWidget {
  final Box myBox; // Add a field to accept the Hive box

  const Todo({super.key, required this.myBox}); // Ensure it's passed to the constructor

  @override
  State<Todo> createState() => _TodoState();
}

class _TodoState extends State<Todo> {
  late final Box _myBox; // Declare the box
  final _controller = TextEditingController();
  ToDoDataBase db = ToDoDataBase();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Initialize the Hive box in an async method
    _initializeHive();
  }

  Future<void> _initializeHive() async {
    _myBox = widget.myBox; // Use the box passed from the widget
    if (_myBox.get("TODOLIST") == null) {
      db.createInitialData();
    } else {
      db.loadData();
    }
    setState(() {
      _isLoading = false; // Data has been loaded
    });
  }

  void checkBoxChanged(bool? value, int index) {
    setState(() {
      db.toDoList[index][1] = !db.toDoList[index][1];
    });
    db.updateDatabase();
  }

  void saveNewTask() {
    setState(() {
      db.toDoList.add([_controller.text, false]);
      _controller.clear();
    });
    Navigator.of(context).pop();
    db.updateDatabase();
  }

  void createNewTask() {
    showDialog(
      context: context,
      builder: (context) {
        return DialogBox(
          controller: _controller,
          onSave: saveNewTask,
          onCancel: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  void deleteTask(int index) {
    setState(() {
      db.toDoList.removeAt(index);
    });
    db.updateDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: createNewTask,
        backgroundColor: Colors.lightGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "View Tasks",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Show a loading spinner
          : ListView.builder(
        itemCount: db.toDoList.length,
        itemBuilder: (context, index) {
          return ToDOTile(
            taskName: db.toDoList[index][0],
            taskCompleted: db.toDoList[index][1],
            onChanged: (value) => checkBoxChanged(value, index),
            deleteFunction: (context) => deleteTask(index),
          );
        },
      ),
    );
  }
}
