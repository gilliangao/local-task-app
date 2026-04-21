import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../models/task_item.dart';

class CalendarPage extends StatefulWidget {
  final DateTime selectedDate;
  final List<TaskItem> allTasks;
  final List<TaskItem> Function(DateTime date) tasksForDate;
  final Future<void> Function(TaskItem task, bool? value) onToggle;
  final Future<void> Function(TaskItem task) onEdit;
  final Future<void> Function(TaskItem task) onDelete;

  const CalendarPage({
    super.key,
    required this.selectedDate,
    required this.allTasks,
    required this.tasksForDate,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _selectedDate;
  late DateTime _visibleMonth;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
    );
    _visibleMonth = DateTime(_selectedDate.year, _selectedDate.month);
  }

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  DateTime _monthStart(DateTime date) => DateTime(date.year, date.month);

  List<DateTime> _calendarDaysForMonth(DateTime month) {
    final firstDayOfMonth = _monthStart(month);
    final startOffset = firstDayOfMonth.weekday % 7;
    final gridStart = firstDayOfMonth.subtract(Duration(days: startOffset));

    return List<DateTime>.generate(
      42,
      (index) => gridStart.add(Duration(days: index)),
    );
  }

  List<TaskItem> _tasksForCalendarDate(DateTime date) {
    final target = _dateOnly(date);
    return widget.allTasks.where((task) {
      if (task.deadline == null) return false;
      return _isSameDate(_dateOnly(task.deadline!), target);
    }).toList();
  }

  int _activeTaskCountForDate(DateTime date) {
    return _tasksForCalendarDate(date).where((task) => !task.isDone).length;
  }

  int _completedTaskCountForDate(DateTime date) {
    return _tasksForCalendarDate(date).where((task) => task.isDone).length;
  }

  void _changeMonth(int offset) {
    setState(() {
      _visibleMonth = DateTime(
        _visibleMonth.year,
        _visibleMonth.month + offset,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final tasks = widget.tasksForDate(_selectedDate);
    final localeTag = Localizations.localeOf(context).toLanguageTag();
    final dateLabel = DateFormat.yMMMMd(localeTag).format(_selectedDate);
    final monthLabel = DateFormat.yMMMM(localeTag).format(_visibleMonth);
    final calendarDays = _calendarDaysForMonth(_visibleMonth);
    final weekdayLabels = List<String>.generate(
      7,
      (index) => DateFormat.E(localeTag).format(DateTime(2024, 1, 7 + index)),
    );
    final today = _dateOnly(DateTime.now());

    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.secondary.withValues(alpha: 0.12),
                theme.colorScheme.primary.withValues(alpha: 0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.calendarInsights,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.secondary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(monthLabel, style: theme.textTheme.headlineMedium),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => _changeMonth(-1),
                            icon: const Icon(Icons.chevron_left),
                          ),
                          Expanded(
                            child: Text(
                              monthLabel,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleMedium,
                            ),
                          ),
                          IconButton(
                            onPressed: () => _changeMonth(1),
                            icon: const Icon(Icons.chevron_right),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: weekdayLabels
                            .map(
                              (label) => Expanded(
                                child: Center(
                                  child: Text(
                                    label,
                                    style: theme.textTheme.labelMedium
                                        ?.copyWith(
                                          color: theme
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 8),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: calendarDays.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 7,
                              mainAxisSpacing: 6,
                              crossAxisSpacing: 6,
                              childAspectRatio: 0.82,
                            ),
                        itemBuilder: (context, index) {
                          final day = calendarDays[index];
                          final isInMonth = day.month == _visibleMonth.month;
                          final isSelected = _isSameDate(day, _selectedDate);
                          final isToday = _isSameDate(day, today);
                          final activeCount = _activeTaskCountForDate(day);
                          final completedCount = _completedTaskCountForDate(
                            day,
                          );
                          final hasTasks = activeCount + completedCount > 0;

                          final backgroundColor = isSelected
                              ? theme.colorScheme.primaryContainer
                              : isToday
                              ? theme.colorScheme.secondaryContainer
                              : Colors.transparent;
                          final borderColor = isSelected
                              ? theme.colorScheme.primary
                              : isToday
                              ? theme.colorScheme.secondary
                              : theme.colorScheme.outlineVariant;
                          final textColor = isInMonth
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onSurfaceVariant;

                          return InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              setState(() {
                                _selectedDate = day;
                                _visibleMonth = _monthStart(day);
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 160),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: backgroundColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: borderColor),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${day.day}',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      color: textColor,
                                      fontWeight: isSelected || isToday
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  if (hasTasks)
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        if (activeCount > 0)
                                          Container(
                                            width: 7,
                                            height: 7,
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.primary,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        if (activeCount > 0 &&
                                            completedCount > 0)
                                          const SizedBox(width: 4),
                                        if (completedCount > 0)
                                          Container(
                                            width: 7,
                                            height: 7,
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.tertiary,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                      ],
                                    )
                                  else
                                    const SizedBox(height: 7),
                                  const SizedBox(height: 4),
                                  Text(
                                    hasTasks
                                        ? '${activeCount + completedCount}'
                                        : '',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(l10n.active, style: theme.textTheme.labelMedium),
                          const SizedBox(width: 16),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.tertiary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            l10n.completed,
                            style: theme.textTheme.labelMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${l10n.tasksOnDate(dateLabel)} (${tasks.length})',
              style: theme.textTheme.titleMedium,
            ),
          ),
        ),
        if (tasks.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              l10n.noTasksOnDate(dateLabel),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          )
        else
          ...tasks.map((task) {
            final sectionName = switch (task.section) {
              TaskSection.today => l10n.today,
              TaskSection.shortTerm => l10n.shortTerm,
              TaskSection.longTerm => l10n.longTerm,
            };

            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Checkbox(
                        value: task.isDone,
                        onChanged: (value) => widget.onToggle(task, value),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                decoration: task.isDone
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: task.isDone
                                    ? theme.colorScheme.onSurfaceVariant
                                    : theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              sectionName,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => widget.onEdit(task),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        onPressed: () => widget.onDelete(task),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }
}
