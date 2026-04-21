import 'dart:convert';
import 'l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const MyApp());
}

enum TaskSection { today, shortTerm, longTerm }

class TaskItem {
  String title;
  bool isDone;
  TaskSection section;

  TaskItem({required this.title, required this.section, this.isDone = false});

  Map<String, dynamic> toMap() {
    return {'title': title, 'isDone': isDone, 'section': section.name};
  }

  factory TaskItem.fromMap(Map<String, dynamic> map) {
    return TaskItem(
      title: map['title'] as String,
      isDone: map['isDone'] as bool? ?? false,
      section: TaskSection.values.firstWhere(
        (e) => e.name == map['section'],
        orElse: () => TaskSection.today,
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static _MyAppState of(BuildContext context) {
    return context.findAncestorStateOfType<_MyAppState>()!;
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  void setLocale(Locale? locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: _locale,
      title: 'Local Task App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('zh')],
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const String _tasksKey = 'tasks';

  int _currentIndex = 0;
  bool _isLoading = true;

  List<TaskItem> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _changeLanguage(String value) {
    if (value == 'system') {
      MyApp.of(context).setLocale(null);
    } else if (value == 'en') {
      MyApp.of(context).setLocale(const Locale('en'));
    } else if (value == 'zh') {
      MyApp.of(context).setLocale(const Locale('zh'));
    }
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final storedTasks = prefs.getString(_tasksKey);

    if (storedTasks == null) {
      setState(() {
        _tasks = [
          TaskItem(title: 'Send Serena an email', section: TaskSection.today),
          TaskItem(title: 'Buy groceries', section: TaskSection.today),
          TaskItem(title: 'Update CV', section: TaskSection.shortTerm),
          TaskItem(
            title: 'Prepare interview notes',
            section: TaskSection.shortTerm,
          ),
          TaskItem(title: 'Learn Flutter', section: TaskSection.longTerm),
          TaskItem(
            title: 'Build my own task app',
            section: TaskSection.longTerm,
          ),
        ];
        _isLoading = false;
      });
      await _saveTasks();
      return;
    }

    final List<dynamic> decoded = jsonDecode(storedTasks) as List<dynamic>;

    setState(() {
      _tasks = decoded
          .map((item) => TaskItem.fromMap(item as Map<String, dynamic>))
          .toList();
      _isLoading = false;
    });
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_tasks.map((task) => task.toMap()).toList());
    await prefs.setString(_tasksKey, encoded);
  }

  List<TaskItem> _activeTasksForSection(TaskSection section) {
    return _tasks
        .where((task) => task.section == section && !task.isDone)
        .toList();
  }

  List<TaskItem> _completedTasks() {
    return _tasks.where((task) => task.isDone).toList();
  }

  Future<void> _toggleTask(TaskItem task, bool? value) async {
    setState(() {
      task.isDone = value ?? false;
    });
    await _saveTasks();
  }

  Future<void> _moveTask(TaskItem task, TaskSection newSection) async {
    setState(() {
      task.section = newSection;
    });
    await _saveTasks();
  }

  Future<void> _moveUp(TaskItem task) async {
    setState(() {
      final list = _activeTasksForSection(task.section);
      final index = list.indexOf(task);

      if (index <= 0) return;

      final previousTask = list[index - 1];

      final i1 = _tasks.indexOf(task);
      final i2 = _tasks.indexOf(previousTask);

      _tasks[i1] = previousTask;
      _tasks[i2] = task;
    });
    await _saveTasks();
  }

  Future<void> _moveDown(TaskItem task) async {
    setState(() {
      final list = _activeTasksForSection(task.section);
      final index = list.indexOf(task);

      if (index == -1 || index >= list.length - 1) return;

      final nextTask = list[index + 1];

      final i1 = _tasks.indexOf(task);
      final i2 = _tasks.indexOf(nextTask);

      _tasks[i1] = nextTask;
      _tasks[i2] = task;
    });
    await _saveTasks();
  }

  Future<void> _deleteTask(TaskItem task) async {
    setState(() {
      _tasks.remove(task);
    });
    await _saveTasks();
  }

  Future<void> _clearCompletedTasks() async {
    setState(() {
      _tasks.removeWhere((task) => task.isDone);
    });
    await _saveTasks();
  }

  Future<void> _confirmDeleteTask(TaskItem task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete task'),
          content: Text('Delete "${task.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _deleteTask(task);
    }
  }

  Future<void> _confirmClearCompletedTasks() async {
    final completedCount = _completedTasks().length;
    if (completedCount == 0) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Clear completed'),
          content: Text('Delete all $completedCount completed tasks?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _clearCompletedTasks();
    }
  }

  Future<void> _editTaskDialog(TaskItem task) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: task.title);
    TaskSection selectedSection = task.section;
    bool isDone = task.isDone;

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(l10n.editTask),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        labelText: l10n.taskTitle,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<TaskSection>(
                      value: selectedSection,
                      decoration: InputDecoration(
                        labelText: l10n.section,
                        border: const OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: TaskSection.today,
                          child: Text(l10n.today),
                        ),
                        DropdownMenuItem(
                          value: TaskSection.shortTerm,
                          child: Text(l10n.shortTerm),
                        ),
                        DropdownMenuItem(
                          value: TaskSection.longTerm,
                          child: Text(l10n.longTerm),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setDialogState(() {
                          selectedSection = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.completedLabel),
                      value: isDone,
                      onChanged: (value) {
                        setDialogState(() {
                          isDone = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: Text(l10n.cancel),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (controller.text.trim().isEmpty) return;
                    Navigator.pop(dialogContext, true);
                  },
                  child: Text(l10n.save),
                ),
              ],
            );
          },
        );
      },
    );

    if (saved == true) {
      setState(() {
        task.title = controller.text.trim();
        task.section = selectedSection;
        task.isDone = isDone;
      });
      await _saveTasks();
    }
  }

  void _addTaskDialog() {
    final l10n = AppLocalizations.of(context)!;
    final TextEditingController controller = TextEditingController();
    TaskSection selectedSection = TaskSection.today;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(l10n.addTask),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: l10n.enterTask,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButton<TaskSection>(
                    value: selectedSection,
                    isExpanded: true,
                    items: [
                      DropdownMenuItem(
                        value: TaskSection.today,
                        child: Text(l10n.today),
                      ),
                      DropdownMenuItem(
                        value: TaskSection.shortTerm,
                        child: Text(l10n.shortTerm),
                      ),
                      DropdownMenuItem(
                        value: TaskSection.longTerm,
                        child: Text(l10n.longTerm),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setDialogState(() {
                        selectedSection = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(l10n.cancel),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (controller.text.trim().isEmpty) return;

                    setState(() {
                      _tasks.add(
                        TaskItem(
                          title: controller.text.trim(),
                          section: selectedSection,
                        ),
                      );
                    });

                    await _saveTasks();

                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                    }
                  },
                  child: Text(l10n.add),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pages = [
      TaskListPage(
        title: 'Today',
        tasks: _activeTasksForSection(TaskSection.today),
        onToggle: _toggleTask,
        onMove: _moveTask,
        onMoveUp: _moveUp,
        onMoveDown: _moveDown,
        onDelete: _confirmDeleteTask,
        onEdit: _editTaskDialog,
        emptyText: 'No active tasks in Today',
        showReorderActions: true,
        showMoveMenu: true,
      ),
      TaskListPage(
        title: 'Short Term',
        tasks: _activeTasksForSection(TaskSection.shortTerm),
        onToggle: _toggleTask,
        onMove: _moveTask,
        onMoveUp: _moveUp,
        onMoveDown: _moveDown,
        onDelete: _confirmDeleteTask,
        onEdit: _editTaskDialog,
        emptyText: 'No active tasks in Short Term',
        showReorderActions: true,
        showMoveMenu: true,
      ),
      TaskListPage(
        title: 'Long Term',
        tasks: _activeTasksForSection(TaskSection.longTerm),
        onToggle: _toggleTask,
        onMove: _moveTask,
        onMoveUp: _moveUp,
        onMoveDown: _moveDown,
        onDelete: _confirmDeleteTask,
        onEdit: _editTaskDialog,
        emptyText: 'No active tasks in Long Term',
        showReorderActions: true,
        showMoveMenu: true,
      ),
      TaskListPage(
        title: 'Completed',
        tasks: _completedTasks(),
        onToggle: _toggleTask,
        onMove: _moveTask,
        onMoveUp: _moveUp,
        onMoveDown: _moveDown,
        onDelete: _confirmDeleteTask,
        onEdit: _editTaskDialog,
        emptyText: 'No completed tasks yet',
        showReorderActions: false,
        showMoveMenu: false,
      ),
    ];

    final titles = [l10n.today, l10n.shortTerm, l10n.longTerm, l10n.completed];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_currentIndex]),
        actions: [
          if (_currentIndex == 3)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Clear Completed',
              onPressed: _completedTasks().isEmpty
                  ? null
                  : _confirmClearCompletedTasks,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.today),
            label: l10n.today,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.schedule),
            label: l10n.shortTerm,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.flag),
            label: l10n.longTerm,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.check_circle),
            label: l10n.completed,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTaskDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TaskListPage extends StatelessWidget {
  final String title;
  final List<TaskItem> tasks;
  final Future<void> Function(TaskItem task, bool? value) onToggle;
  final Future<void> Function(TaskItem task, TaskSection section) onMove;
  final Future<void> Function(TaskItem task) onMoveUp;
  final Future<void> Function(TaskItem task) onMoveDown;
  final Future<void> Function(TaskItem task) onDelete;
  final Future<void> Function(TaskItem task) onEdit;
  final String emptyText;
  final bool showReorderActions;
  final bool showMoveMenu;

  const TaskListPage({
    super.key,
    required this.title,
    required this.tasks,
    required this.onToggle,
    required this.onMove,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onDelete,
    required this.onEdit,
    required this.emptyText,
    required this.showReorderActions,
    required this.showMoveMenu,
  });

  String _sectionLabel(BuildContext context, TaskSection section) {
    final l10n = AppLocalizations.of(context)!;

    switch (section) {
      case TaskSection.today:
        return l10n.today;
      case TaskSection.shortTerm:
        return l10n.shortTerm;
      case TaskSection.longTerm:
        return l10n.longTerm;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // then use l10n below
    if (tasks.isEmpty) {
      return Center(
        child: Text(emptyText, style: const TextStyle(fontSize: 18)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Checkbox(
              value: task.isDone,
              onChanged: (value) => onToggle(task, value),
            ),
            title: Text(
              task.title,
              style: TextStyle(
                fontSize: 18,
                decoration: task.isDone ? TextDecoration.lineThrough : null,
                color: task.isDone ? Colors.grey : null,
              ),
            ),
            subtitle: Text(
              task.isDone
                  ? l10n.completedInSection(
                      _sectionLabel(context, task.section),
                    )
                  : l10n.active,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showReorderActions) ...[
                  IconButton(
                    icon: const Icon(Icons.arrow_upward),
                    onPressed: () => onMoveUp(task),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_downward),
                    onPressed: () => onMoveDown(task),
                  ),
                ],
                if (showMoveMenu)
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'today') {
                        onMove(task, TaskSection.today);
                      } else if (value == 'short') {
                        onMove(task, TaskSection.shortTerm);
                      } else if (value == 'long') {
                        onMove(task, TaskSection.longTerm);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'today',
                        child: Text(l10n.moveToToday),
                      ),
                      PopupMenuItem(
                        value: 'short',
                        child: Text(l10n.moveToShortTerm),
                      ),
                      PopupMenuItem(
                        value: 'long',
                        child: Text(l10n.moveToLongTerm),
                      ),
                    ],
                  ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => onEdit(task),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => onDelete(task),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
