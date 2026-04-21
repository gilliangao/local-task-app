enum TaskSection { today, shortTerm, longTerm }

class TaskItem {
  String title;
  bool isDone;
  TaskSection section;
  DateTime? deadline;

  TaskItem({
    required this.title,
    required this.section,
    this.isDone = false,
    this.deadline,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'isDone': isDone,
      'section': section.name,
      'deadline': deadline?.toIso8601String(),
    };
  }

  factory TaskItem.fromMap(Map<String, dynamic> map) {
    return TaskItem(
      title: map['title'] as String,
      isDone: map['isDone'] as bool? ?? false,
      section: TaskSection.values.firstWhere(
        (section) => section.name == map['section'],
        orElse: () => TaskSection.today,
      ),
      deadline: map['deadline'] != null
          ? DateTime.parse(map['deadline'] as String)
          : null,
    );
  }
}
