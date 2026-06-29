// lib/features/timeline/wedding_task.dart

class WeddingTask {
  final String taskId;
  final String title;
  final String targetUser;
  final DateTime dueDate;
  final String ruleBaseline;
  final List<WeddingTask> subTasks;
  bool isCompleted;

  WeddingTask({
    required this.taskId,
    required this.title,
    required this.targetUser,
    required this.dueDate,
    required this.ruleBaseline,
    List<WeddingTask>? subTasks,
    this.isCompleted = false,
  }) : subTasks = subTasks ?? [];

  // Convert a Task object into a Map structure to support BaaS CRUD saving
  Map<String, dynamic> toMap() {
    return {
      'taskId': taskId,
      'title': title,
      'targetUser': targetUser,
      'dueDate': dueDate.toIso8601String(),
      'ruleBaseline': ruleBaseline,
      'isCompleted': isCompleted,
      'subTasks': subTasks.map((task) => task.toMap()).toList(),
    };
  }

  factory WeddingTask.fromMap(Map<String, dynamic> map) {
    final rawSubTasks = map['subTasks'];
    final subTaskMaps = rawSubTasks is List ? rawSubTasks : const [];

    return WeddingTask(
      taskId: map['taskId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      targetUser: map['targetUser'] as String? ?? '',
      dueDate: DateTime.parse(map['dueDate'] as String),
      ruleBaseline: map['ruleBaseline'] as String? ?? '',
      isCompleted: map['isCompleted'] as bool? ?? false,
      subTasks: subTaskMaps
          .whereType<Map>()
          .map((entry) => WeddingTask.fromMap(Map<String, dynamic>.from(entry)))
          .toList(),
    );
  }
}