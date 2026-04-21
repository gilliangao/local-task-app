// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get today => 'Today';

  @override
  String get shortTerm => 'Short Term';

  @override
  String get longTerm => 'Long Term';

  @override
  String get completed => 'Completed';

  @override
  String get active => 'Active';

  @override
  String get addTask => 'Add Task';

  @override
  String get editTask => 'Edit Task';

  @override
  String get taskTitle => 'Task title';

  @override
  String get enterTask => 'Enter task...';

  @override
  String get section => 'Section';

  @override
  String get cancel => 'Cancel';

  @override
  String get add => 'Add';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get deleteTask => 'Delete task';

  @override
  String get clearCompleted => 'Clear Completed';

  @override
  String get clear => 'Clear';

  @override
  String get completedLabel => 'Completed';

  @override
  String get moveToToday => 'Move to Today';

  @override
  String get moveToShortTerm => 'Move to Short Term';

  @override
  String get moveToLongTerm => 'Move to Long Term';

  @override
  String get noActiveTasksToday => 'No active tasks in Today';

  @override
  String get noActiveTasksShortTerm => 'No active tasks in Short Term';

  @override
  String get noActiveTasksLongTerm => 'No active tasks in Long Term';

  @override
  String get noCompletedTasks => 'No completed tasks yet';

  @override
  String deleteTaskMessage(Object taskTitle) {
    return 'Delete \"$taskTitle\"?';
  }

  @override
  String completedInSection(Object sectionName) {
    return 'Completed • $sectionName';
  }

  @override
  String clearCompletedMessage(int count) {
    return 'Delete all $count completed tasks?';
  }
}
