import 'package:flutter/material.dart';
import 'package:my_app/TimelineEngine.dart';
import 'package:my_app/firestore_service.dart';
import 'package:my_app/CustomSubTask.dart';

class TaskCard extends StatefulWidget {
  final WeddingTask task;
  final FirestoreService firestoreService;

  const TaskCard({
    super.key,
    required this.task,
    required this.firestoreService,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  final TextEditingController _controller = TextEditingController();

  Future<void> _showAddSubTaskDialog() async {
  _controller.clear();

  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Add Subtask"),

        content: TextField(
          controller: _controller,
          decoration: const InputDecoration(
            hintText: "Enter subtask",
          ),
        ),

        actions: [

          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),

          ElevatedButton(
            onPressed: () async {

              if (_controller.text.trim().isEmpty) {
                return;
              }

              final subTask = CustomSubTask(
                id: "",
                parentTaskId: widget.task.taskId,
                title: _controller.text.trim(),
                completed: false,
              );

              await widget.firestoreService.addSubTask(subTask);

              if (mounted) {
                setState(() {});
              }

              if (context.mounted) {
                Navigator.pop(context);
              }

            },
            child: const Text("Add"),
          ),

        ],
      );
    },
  );
}
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFE5B6B6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.task.dueDate
                  .toIso8601String()
                  .substring(0, 10),
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            widget.task.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5C4646),
            ),
          ),

          const SizedBox(height: 12),

          const Divider(),
          FutureBuilder<List<CustomSubTask>>(
            future: widget.firestoreService.getSubTasks(widget.task.taskId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(8),
                  child: CircularProgressIndicator(strokeWidth: 2),
                );
              }

              if (snapshot.hasError) {
                return Text(
                  snapshot.error.toString(),
                  style: const TextStyle(color: Colors.red),
                );
              }

              final subtasks = snapshot.data ?? [];

              if (subtasks.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    "No subtasks yet.",
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              return Column(
                children: subtasks.map((subtask) {
                  return CheckboxListTile(
                    value: subtask.completed,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    activeColor: const Color(0xFFBA8B8B),

                    title: Text(
                      subtask.title,
                      style: TextStyle(
                        decoration: subtask.completed
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        color: subtask.completed
                            ? Colors.grey
                            : const Color(0xFF5C4646),
                      ),
                    ),

                    onChanged: (value) async {
                      final updatedSubTask = CustomSubTask(
                        id: subtask.id,
                        parentTaskId: subtask.parentTaskId,
                        title: subtask.title,
                        completed: value ?? false,
                      );

                      await widget.firestoreService.updateSubTask(updatedSubTask);

                      if (mounted) {
                        setState(() {});
                      }
                    },
                  );
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 8),

          TextButton.icon(
            onPressed: _showAddSubTaskDialog,
            icon: const Icon(Icons.add),
            label: const Text("Add Subtask"),
          ),
        ],
      ),
    );
  }
}