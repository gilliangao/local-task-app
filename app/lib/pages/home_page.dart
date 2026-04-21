import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app.dart';
import '../controllers/task_controller.dart';
import '../l10n/app_localizations.dart';
import '../models/task_item.dart';
import '../widgets/task_dialog.dart';
import '../widgets/task_list_page.dart';
import 'calendar_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  void _changeLanguage(String value) {
    if (value == 'system') {
      MyApp.setLocaleOf(context, null);
    } else if (value == 'en') {
      MyApp.setLocaleOf(context, const Locale('en'));
    } else if (value == 'zh') {
      MyApp.setLocaleOf(context, const Locale('zh'));
    }
  }

  Future<DateTime?> _pickDeadline(
    BuildContext dialogContext,
    DateTime? initialDate,
  ) async {
    final now = DateTime.now();

    return showDatePicker(
      context: dialogContext,
      initialDate: initialDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 10),
    );
  }

  Future<void> _confirmDeleteTask(TaskItem task) async {
    final l10n = AppLocalizations.of(context)!;
    final taskController = context.read<TaskController>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.deleteTask),
          content: Text(l10n.deleteTaskMessage(task.title)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await taskController.deleteTask(task);
    }
  }

  Future<void> _confirmClearCompletedTasks() async {
    final l10n = AppLocalizations.of(context)!;
    final taskController = context.read<TaskController>();
    final completedCount = taskController.completedTasks().length;
    if (completedCount == 0) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.clearCompleted),
          content: Text(l10n.clearCompletedMessage(completedCount)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l10n.clear),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await taskController.clearCompletedTasks();
    }
  }

  Future<void> _editTaskDialog(TaskItem task) async {
    final l10n = AppLocalizations.of(context)!;
    final taskController = context.read<TaskController>();
    final result = await showTaskDialog(
      context: context,
      title: l10n.editTask,
      submitLabel: l10n.save,
      pickDeadline: _pickDeadline,
      showCompletedToggle: true,
      initialData: TaskFormData(
        title: task.title,
        section: task.section,
        isDone: task.isDone,
        deadline: task.deadline,
      ),
    );

    if (result == null) return;

    await taskController.updateTask(
      task,
      TaskFormUpdate(
        title: result.title,
        section: result.section,
        isDone: result.isDone,
        deadline: result.deadline,
      ),
    );
  }

  Future<void> _addTaskDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final taskController = context.read<TaskController>();
    final result = await showTaskDialog(
      context: context,
      title: l10n.addTask,
      submitLabel: l10n.add,
      pickDeadline: _pickDeadline,
      taskTitleHint: l10n.enterTask,
    );

    if (result == null) return;

    await taskController.addTask(
      title: result.title,
      section: result.section,
      deadline: result.deadline,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final taskController = context.watch<TaskController>();
    final theme = Theme.of(context);
    final isCalendarFocused = _currentIndex == 3;
    final today = _dateOnly(DateTime.now());
    final openCount = taskController.allTasks
        .where((task) => !task.isDone)
        .length;
    final dueSoonCount = taskController.allTasks.where((task) {
      if (task.isDone || task.deadline == null) return false;
      final deadline = _dateOnly(task.deadline!);
      return !deadline.isBefore(today) &&
          deadline.isBefore(today.add(const Duration(days: 8)));
    }).length;
    final completedCount = taskController.completedTasks().length;
    final completionRate = taskController.allTasks.isEmpty
        ? 0
        : ((completedCount / taskController.allTasks.length) * 100).round();

    final pages = [
      TaskListPage(
        tasks: taskController.activeTasksForSection(TaskSection.today),
        onToggle: taskController.toggleTask,
        onMove: taskController.moveTask,
        onMoveUp: taskController.moveUp,
        onMoveDown: taskController.moveDown,
        onDelete: _confirmDeleteTask,
        onEdit: _editTaskDialog,
        emptyText: l10n.noActiveTasksToday,
        showReorderActions: false,
        showMoveMenu: true,
      ),
      TaskListPage(
        tasks: taskController.activeTasksForSection(TaskSection.shortTerm),
        onToggle: taskController.toggleTask,
        onMove: taskController.moveTask,
        onMoveUp: taskController.moveUp,
        onMoveDown: taskController.moveDown,
        onDelete: _confirmDeleteTask,
        onEdit: _editTaskDialog,
        emptyText: l10n.noActiveTasksShortTerm,
        showReorderActions: false,
        showMoveMenu: true,
      ),
      TaskListPage(
        tasks: taskController.activeTasksForSection(TaskSection.longTerm),
        onToggle: taskController.toggleTask,
        onMove: taskController.moveTask,
        onMoveUp: taskController.moveUp,
        onMoveDown: taskController.moveDown,
        onDelete: _confirmDeleteTask,
        onEdit: _editTaskDialog,
        emptyText: l10n.noActiveTasksLongTerm,
        showReorderActions: false,
        showMoveMenu: true,
      ),
      CalendarPage(
        selectedDate: DateTime.now(),
        allTasks: taskController.allTasks,
        tasksForDate: taskController.tasksForDate,
        onToggle: taskController.toggleTask,
        onEdit: _editTaskDialog,
        onDelete: _confirmDeleteTask,
      ),
      TaskListPage(
        tasks: taskController.completedTasks(),
        onToggle: taskController.toggleTask,
        onMove: taskController.moveTask,
        onMoveUp: taskController.moveUp,
        onMoveDown: taskController.moveDown,
        onDelete: _confirmDeleteTask,
        onEdit: _editTaskDialog,
        emptyText: l10n.noCompletedTasks,
        showReorderActions: false,
        showMoveMenu: false,
      ),
    ];

    final tabs = [
      _HomeTabData(label: l10n.today, icon: Icons.today_outlined),
      _HomeTabData(label: l10n.shortTerm, icon: Icons.timelapse_outlined),
      _HomeTabData(label: l10n.longTerm, icon: Icons.rocket_launch_outlined),
      _HomeTabData(label: l10n.calendar, icon: Icons.calendar_month_outlined),
      _HomeTabData(label: l10n.completed, icon: Icons.task_alt_outlined),
    ];

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          Positioned(
            top: -80,
            right: -20,
            child: _GlowOrb(
              color: theme.colorScheme.primary.withValues(alpha: 0.16),
              size: 220,
            ),
          ),
          Positioned(
            top: 180,
            left: -70,
            child: _GlowOrb(
              color: theme.colorScheme.secondary.withValues(alpha: 0.14),
              size: 180,
            ),
          ),
          Positioned(
            bottom: 40,
            right: -30,
            child: _GlowOrb(
              color: theme.colorScheme.tertiary.withValues(alpha: 0.12),
              size: 180,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 8),
                  child: Row(
                    children: [
                      PopupMenuButton<String>(
                        tooltip: l10n.systemLanguage,
                        onSelected: _changeLanguage,
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'system',
                            child: Text(l10n.systemLanguage),
                          ),
                          PopupMenuItem(value: 'en', child: Text(l10n.english)),
                          PopupMenuItem(value: 'zh', child: Text(l10n.chinese)),
                        ],
                        child: const _RoundIconButton(icon: Icons.language),
                      ),
                      const Spacer(),
                      if (_currentIndex == 4)
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: TextButton.icon(
                            onPressed: taskController.completedTasks().isEmpty
                                ? null
                                : _confirmClearCompletedTasks,
                            icon: const Icon(Icons.delete_sweep_outlined),
                            label: Text(l10n.clearCompleted),
                          ),
                        ),
                      FilledButton.icon(
                        onPressed: _addTaskDialog,
                        icon: const Icon(Icons.add),
                        label: Text(l10n.newTask),
                      ),
                    ],
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: Padding(
                    key: ValueKey('hero-$isCalendarFocused'),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: isCalendarFocused
                        ? _CompactHeroBar(
                            badge: l10n.calendarInsights,
                            title: l10n.calendar,
                            subtitle: l10n.tasksOnDate(
                              MaterialLocalizations.of(
                                context,
                              ).formatMediumDate(today),
                            ),
                          )
                        : _HeroPanel(
                            badge: l10n.portfolioBadge,
                            title: l10n.dashboardTitle,
                            subtitle: l10n.dashboardSubtitle,
                            currentTab: tabs[_currentIndex].label,
                          ),
                  ),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  child: isCalendarFocused
                      ? const SizedBox(height: 10)
                      : Column(
                          children: [
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 102,
                              child: ListView(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                ),
                                scrollDirection: Axis.horizontal,
                                children: [
                                  _StatCard(
                                    label: l10n.openTasks,
                                    value: '$openCount',
                                    accent: theme.colorScheme.primary,
                                    icon: Icons.checklist_rounded,
                                  ),
                                  const SizedBox(width: 12),
                                  _StatCard(
                                    label: l10n.dueSoon,
                                    value: '$dueSoonCount',
                                    accent: theme.colorScheme.tertiary,
                                    icon: Icons.hourglass_top_rounded,
                                  ),
                                  const SizedBox(width: 12),
                                  _StatCard(
                                    label: l10n.completionRate,
                                    value: '$completionRate%',
                                    accent: theme.colorScheme.secondary,
                                    icon: Icons.insights_rounded,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                ),
                SizedBox(
                  height: 46,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      final tab = tabs[index];
                      final selected = _currentIndex == index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        child: Material(
                          color: selected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.surface.withValues(
                                  alpha: 0.72,
                                ),
                          borderRadius: BorderRadius.circular(18),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () {
                              setState(() {
                                _currentIndex = index;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    tab.icon,
                                    size: 16,
                                    color: selected
                                        ? Colors.white
                                        : theme.colorScheme.onSurface,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    tab.label,
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: selected
                                          ? Colors.white
                                          : theme.colorScheme.onSurface,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 10),
                    itemCount: tabs.length,
                  ),
                ),
                SizedBox(height: isCalendarFocused ? 8 : 10),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      18,
                      0,
                      18,
                      isCalendarFocused ? 10 : 14,
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      child: Container(
                        key: ValueKey(_currentIndex),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface.withValues(
                            alpha: 0.76,
                          ),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: theme.colorScheme.outlineVariant.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 24,
                              offset: const Offset(0, 16),
                              color: const Color(
                                0xFF6B5B47,
                              ).withValues(alpha: 0.08),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: taskController.isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : pages[_currentIndex],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeTabData {
  final String label;
  final IconData icon;

  const _HomeTabData({required this.label, required this.icon});
}

class _GlowOrb extends StatelessWidget {
  final Color color;
  final double size;

  const _GlowOrb({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      ),
    );
  }
}

class _CompactHeroBar extends StatelessWidget {
  final String badge;
  final String title;
  final String subtitle;

  const _CompactHeroBar({
    required this.badge,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.secondary.withValues(alpha: 0.92),
            theme.colorScheme.primary.withValues(alpha: 0.86),
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              badge,
              style: theme.textTheme.labelMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.84),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  final String badge;
  final String title;
  final String subtitle;
  final String currentTab;

  const _HeroPanel({
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.currentTab,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.95),
            theme.colorScheme.secondary.withValues(alpha: 0.92),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 26,
            offset: const Offset(0, 14),
            color: theme.colorScheme.primary.withValues(alpha: 0.2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              badge,
              style: theme.textTheme.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: theme.textTheme.displaySmall?.copyWith(
              color: Colors.white,
              height: 1.0,
              fontSize: 34,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.88),
              height: 1.35,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                size: 16,
                color: Colors.white.withValues(alpha: 0.85),
              ),
              const SizedBox(width: 6),
              Text(
                currentTab,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.accent,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 132,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accent, size: 14),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 11,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;

  const _RoundIconButton({required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface.withValues(alpha: 0.74),
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        width: 48,
        height: 48,
        child: Icon(icon, color: theme.colorScheme.onSurface),
      ),
    );
  }
}
