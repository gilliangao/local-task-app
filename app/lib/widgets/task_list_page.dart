import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/task_item.dart';

class TaskListPage extends StatelessWidget {
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

  String _subtitle(BuildContext context, TaskItem task) {
    final l10n = AppLocalizations.of(context)!;
    final parts = <String>[
      task.isDone
          ? l10n.completedInSection(_sectionLabel(context, task.section))
          : l10n.active,
    ];

    if (task.deadline != null) {
      final deadlineLabel = MaterialLocalizations.of(
        context,
      ).formatMediumDate(task.deadline!);
      parts.add('${l10n.deadline}: $deadlineLabel');
    }

    return parts.join('  •  ');
  }

  ({Color color, Color tint, IconData icon}) _deadlineStyle(
    BuildContext context,
    TaskItem task,
  ) {
    final theme = Theme.of(context);
    if (task.deadline == null) {
      return (
        color: theme.colorScheme.secondary,
        tint: theme.colorScheme.secondary.withValues(alpha: 0.12),
        icon: Icons.layers_outlined,
      );
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final deadline = DateTime(
      task.deadline!.year,
      task.deadline!.month,
      task.deadline!.day,
    );
    final daysLeft = deadline.difference(today).inDays;

    if (!task.isDone && daysLeft < 0) {
      return (
        color: const Color(0xFFB14F3A),
        tint: const Color(0xFFF8DDD6),
        icon: Icons.priority_high_rounded,
      );
    }
    if (!task.isDone && daysLeft <= 2) {
      return (
        color: theme.colorScheme.tertiary,
        tint: theme.colorScheme.tertiary.withValues(alpha: 0.16),
        icon: Icons.bolt_rounded,
      );
    }

    return (
      color: theme.colorScheme.secondary,
      tint: theme.colorScheme.secondary.withValues(alpha: 0.12),
      icon: Icons.schedule_rounded,
    );
  }

  Widget _metaPill(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required Color background,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (tasks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Icon(
                  Icons.spa_outlined,
                  size: 38,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                l10n.emptyStateTitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              Text(
                l10n.emptyStateSubtitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                emptyText,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.secondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final task = tasks[index];
        final deadlineStyle = _deadlineStyle(context, task);
        final deadlineLabel = task.deadline == null
            ? l10n.noDeadline
            : MaterialLocalizations.of(
                context,
              ).formatMediumDate(task.deadline!);

        return Card(
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.64),
                  deadlineStyle.tint.withValues(alpha: 0.34),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Transform.scale(
                      scale: 1.08,
                      child: Checkbox(
                        value: task.isDone,
                        onChanged: (value) => onToggle(task, value),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
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
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _subtitle(context, task),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Wrap(
                      spacing: 2,
                      children: [
                        if (showMoveMenu)
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.drive_file_move_outline),
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
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _metaPill(
                      context,
                      icon: task.isDone
                          ? Icons.check_circle_outline
                          : Icons.radio_button_checked,
                      label: task.isDone ? l10n.completed : l10n.active,
                      color: task.isDone
                          ? theme.colorScheme.secondary
                          : theme.colorScheme.primary,
                      background:
                          (task.isDone
                                  ? theme.colorScheme.secondary
                                  : theme.colorScheme.primary)
                              .withValues(alpha: 0.12),
                    ),
                    _metaPill(
                      context,
                      icon: deadlineStyle.icon,
                      label: '${l10n.deadline}: $deadlineLabel',
                      color: deadlineStyle.color,
                      background: deadlineStyle.tint,
                    ),
                    _metaPill(
                      context,
                      icon: Icons.folder_open_outlined,
                      label: _sectionLabel(context, task.section),
                      color: theme.colorScheme.onSurface,
                      background: theme.colorScheme.surfaceContainerHighest,
                    ),
                  ],
                ),
                if (showReorderActions) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Text(
                        'Order',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () => onMoveUp(task),
                        icon: const Icon(Icons.arrow_upward),
                        label: const Text('Up'),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () => onMoveDown(task),
                        icon: const Icon(Icons.arrow_downward),
                        label: const Text('Down'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
