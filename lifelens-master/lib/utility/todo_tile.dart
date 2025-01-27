import 'package:flutter/material.dart';

class ToDOTile extends StatelessWidget {
  final String taskName;
  final bool taskCompleted;
  final void Function(bool?) onChanged;
  final void Function(BuildContext) deleteFunction;
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
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () => deleteFunction(context),
      ),
    );
  }
}
