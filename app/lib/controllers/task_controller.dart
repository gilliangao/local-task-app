import 'package:flutter/material.dart';

import '../models/task_item.dart';
import '../repositories/task_repository.dart';

class TaskController extends ChangeNotifier {
  TaskController(this._repository);

  final TaskRepository _repository;

  bool _isLoading = true;
  final List<TaskItem> _tasks = [];

  bool get isLoading => _isLoading;
  List<TaskItem> get allTasks => List.unmodifiable(_tasks);

  Future<void> loadTasks() async {
    _tasks
      ..clear()
      ..addAll(await _repository.loadTasks());
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTask({
    required String title,
    required TaskSection section,
    DateTime? deadline,
  }) async {
    _tasks.add(TaskItem(title: title, section: section, deadline: deadline));
    notifyListeners();
    await _persist();
  }

  Future<void> updateTask(TaskItem task, TaskFormUpdate update) async {
    task.title = update.title;
    task.section = update.section;
    task.isDone = update.isDone;
    task.deadline = update.deadline;
    notifyListeners();
    await _persist();
  }

  Future<void> toggleTask(TaskItem task, bool? value) async {
    task.isDone = value ?? false;
    notifyListeners();
    await _persist();
  }

  Future<void> moveTask(TaskItem task, TaskSection newSection) async {
    task.section = newSection;
    notifyListeners();
    await _persist();
  }

  Future<void> moveUp(TaskItem task) async {
    final list = activeTasksForSection(task.section);
    final index = list.indexOf(task);
    if (index <= 0) return;

    final previousTask = list[index - 1];
    final currentIndex = _tasks.indexOf(task);
    final previousIndex = _tasks.indexOf(previousTask);

    _tasks[currentIndex] = previousTask;
    _tasks[previousIndex] = task;
    notifyListeners();
    await _persist();
  }

  Future<void> moveDown(TaskItem task) async {
    final list = activeTasksForSection(task.section);
    final index = list.indexOf(task);
    if (index == -1 || index >= list.length - 1) return;

    final nextTask = list[index + 1];
    final currentIndex = _tasks.indexOf(task);
    final nextIndex = _tasks.indexOf(nextTask);

    _tasks[currentIndex] = nextTask;
    _tasks[nextIndex] = task;
    notifyListeners();
    await _persist();
  }

  Future<void> deleteTask(TaskItem task) async {
    _tasks.remove(task);
    notifyListeners();
    await _persist();
  }

  Future<void> clearCompletedTasks() async {
    _tasks.removeWhere((task) => task.isDone);
    notifyListeners();
    await _persist();
  }

  List<TaskItem> activeTasksForSection(TaskSection section) {
    return _sortedTasks(
      _tasks.where((task) => task.section == section && !task.isDone),
    );
  }

  List<TaskItem> completedTasks() {
    return _sortedTasks(_tasks.where((task) => task.isDone));
  }

  List<TaskItem> tasksForDate(DateTime date) {
    final target = _dateOnly(date);
    final matched = _tasks.where((task) {
      if (task.deadline == null) return false;
      return _dateOnly(task.deadline!) == target;
    }).toList();

    matched.sort((a, b) {
      if (a.isDone != b.isDone) {
        return a.isDone ? 1 : -1;
      }
      return _compareTasksByDeadline(a, b);
    });

    return matched;
  }

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  int _compareTasksByDeadline(TaskItem a, TaskItem b) {
    final aDeadline = a.deadline == null ? null : _dateOnly(a.deadline!);
    final bDeadline = b.deadline == null ? null : _dateOnly(b.deadline!);

    if (aDeadline == null && bDeadline == null) {
      return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    }
    if (aDeadline == null) return 1;
    if (bDeadline == null) return -1;

    final byDate = aDeadline.compareTo(bDeadline);
    if (byDate != 0) return byDate;

    return a.title.toLowerCase().compareTo(b.title.toLowerCase());
  }

  List<TaskItem> _sortedTasks(Iterable<TaskItem> tasks) {
    final sorted = tasks.toList();
    sorted.sort(_compareTasksByDeadline);
    return sorted;
  }

  Future<void> _persist() async {
    await _repository.saveTasks(_tasks);
  }
}

class TaskFormUpdate {
  final String title;
  final TaskSection section;
  final bool isDone;
  final DateTime? deadline;

  const TaskFormUpdate({
    required this.title,
    required this.section,
    required this.isDone,
    required this.deadline,
  });
}
