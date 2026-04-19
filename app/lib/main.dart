import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

enum TaskSection { today, shortTerm, longTerm }

class TaskItem {
  final String title;
  bool isDone;
  TaskSection section;

  TaskItem({required this.title, required this.section, this.isDone = false});
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Local Task App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
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
  int _currentIndex = 0;

  final List<TaskItem> _tasks = [
    TaskItem(title: 'Send Serena an email', section: TaskSection.today),
    TaskItem(title: 'Buy groceries', section: TaskSection.today),
    TaskItem(title: 'Update CV', section: TaskSection.shortTerm),
    TaskItem(title: 'Prepare interview notes', section: TaskSection.shortTerm),
    TaskItem(title: 'Learn Flutter', section: TaskSection.longTerm),
    TaskItem(title: 'Build my own task app', section: TaskSection.longTerm),
  ];

  List<TaskItem> _tasksForSection(TaskSection section) {
    return _tasks.where((task) => task.section == section).toList();
  }

  void _toggleTask(TaskItem task, bool? value) {
    setState(() {
      task.isDone = value ?? false;
    });
  }

  void _moveTask(TaskItem task, TaskSection newSection) {
    setState(() {
      task.section = newSection;
    });
  }

  void _moveUp(TaskItem task) {
    setState(() {
      final list = _tasksForSection(task.section);
      final index = list.indexOf(task);

      if (index <= 0) return;

      final previousTask = list[index - 1];

      final i1 = _tasks.indexOf(task);
      final i2 = _tasks.indexOf(previousTask);

      _tasks[i1] = previousTask;
      _tasks[i2] = task;
    });
  }

  void _moveDown(TaskItem task) {
    setState(() {
      final list = _tasksForSection(task.section);
      final index = list.indexOf(task);

      if (index == -1 || index >= list.length - 1) return;

      final nextTask = list[index + 1];

      final i1 = _tasks.indexOf(task);
      final i2 = _tasks.indexOf(nextTask);

      _tasks[i1] = nextTask;
      _tasks[i2] = task;
    });
  }

  void _addTaskDialog() {
    final TextEditingController controller = TextEditingController();
    TaskSection selectedSection = TaskSection.today;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Task'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: 'Enter task...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButton<TaskSection>(
                    value: selectedSection,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(
                        value: TaskSection.today,
                        child: Text('Today'),
                      ),
                      DropdownMenuItem(
                        value: TaskSection.shortTerm,
                        child: Text('Short Term'),
                      ),
                      DropdownMenuItem(
                        value: TaskSection.longTerm,
                        child: Text('Long Term'),
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
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (controller.text.trim().isEmpty) return;

                    setState(() {
                      _tasks.add(
                        TaskItem(
                          title: controller.text.trim(),
                          section: selectedSection,
                        ),
                      );
                    });

                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Add'),
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
    final pages = [
      TaskListPage(
        title: 'Today',
        tasks: _tasksForSection(TaskSection.today),
        onToggle: _toggleTask,
        onMove: _moveTask,
        onMoveUp: _moveUp,
        onMoveDown: _moveDown,
      ),
      TaskListPage(
        title: 'Short Term',
        tasks: _tasksForSection(TaskSection.shortTerm),
        onToggle: _toggleTask,
        onMove: _moveTask,
        onMoveUp: _moveUp,
        onMoveDown: _moveDown,
      ),
      TaskListPage(
        title: 'Long Term',
        tasks: _tasksForSection(TaskSection.longTerm),
        onToggle: _toggleTask,
        onMove: _moveTask,
        onMoveUp: _moveUp,
        onMoveDown: _moveDown,
      ),
    ];

    final titles = ['Today', 'Short Term', 'Long Term'];

    return Scaffold(
      appBar: AppBar(title: Text(titles[_currentIndex])),
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.today), label: 'Today'),
          BottomNavigationBarItem(icon: Icon(Icons.schedule), label: 'Short'),
          BottomNavigationBarItem(icon: Icon(Icons.flag), label: 'Long'),
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
  final void Function(TaskItem task, bool? value) onToggle;
  final void Function(TaskItem task, TaskSection section) onMove;
  final void Function(TaskItem task) onMoveUp;
  final void Function(TaskItem task) onMoveDown;

  const TaskListPage({
    super.key,
    required this.title,
    required this.tasks,
    required this.onToggle,
    required this.onMove,
    required this.onMoveUp,
    required this.onMoveDown,
  });

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Center(
        child: Text('No tasks in $title', style: const TextStyle(fontSize: 18)),
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
            subtitle: Text(task.isDone ? 'Completed' : 'Active'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_upward),
                  onPressed: () => onMoveUp(task),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_downward),
                  onPressed: () => onMoveDown(task),
                ),
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
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'today', child: Text('Move to Today')),
                    PopupMenuItem(
                      value: 'short',
                      child: Text('Move to Short Term'),
                    ),
                    PopupMenuItem(
                      value: 'long',
                      child: Text('Move to Long Term'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
