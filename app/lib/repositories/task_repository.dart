import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/task_item.dart';

class TaskRepository {
  static const String _tasksKey = 'tasks';

  Future<List<TaskItem>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final storedTasks = prefs.getString(_tasksKey);

    if (storedTasks == null) {
      final defaults = defaultTasks();
      await saveTasks(defaults);
      return defaults;
    }

    final decoded = jsonDecode(storedTasks) as List<dynamic>;
    return decoded
        .map((item) => TaskItem.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveTasks(List<TaskItem> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(tasks.map((task) => task.toMap()).toList());
    await prefs.setString(_tasksKey, encoded);
  }

  List<TaskItem> defaultTasks() {
    return [
      TaskItem(title: 'Send Serena an email', section: TaskSection.today),
      TaskItem(title: 'Buy groceries', section: TaskSection.today),
      TaskItem(title: 'Update CV', section: TaskSection.shortTerm),
      TaskItem(
        title: 'Prepare interview notes',
        section: TaskSection.shortTerm,
      ),
      TaskItem(title: 'Learn Flutter', section: TaskSection.longTerm),
      TaskItem(title: 'Build my own task app', section: TaskSection.longTerm),
    ];
  }
}
