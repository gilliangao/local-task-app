import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/task_item.dart';

class TaskFormData {
  final String title;
  final TaskSection section;
  final bool isDone;
  final DateTime? deadline;

  const TaskFormData({
    required this.title,
    required this.section,
    required this.isDone,
    required this.deadline,
  });
}

Future<TaskFormData?> showTaskDialog({
  required BuildContext context,
  required String title,
  required String submitLabel,
  required Future<DateTime?> Function(BuildContext, DateTime?) pickDeadline,
  TaskFormData? initialData,
  bool showCompletedToggle = false,
  String? taskTitleHint,
}) {
  final l10n = AppLocalizations.of(context)!;
  final theme = Theme.of(context);
  final controller = TextEditingController(text: initialData?.title ?? '');
  var selectedSection = initialData?.section ?? TaskSection.today;
  var isDone = initialData?.isDone ?? false;
  DateTime? selectedDeadline = initialData?.deadline == null
      ? null
      : DateTime(
          initialData!.deadline!.year,
          initialData.deadline!.month,
          initialData.deadline!.day,
        );

  return showDialog<TaskFormData>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 20),
            titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
            actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title),
                const SizedBox(height: 8),
                Text(
                  showCompletedToggle
                      ? l10n.dashboardSubtitle
                      : l10n.emptyStateSubtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: l10n.taskTitle,
                      hintText: taskTitleHint,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<TaskSection>(
                    initialValue: selectedSection,
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
                  InputDecorator(
                    decoration: InputDecoration(
                      labelText: l10n.deadline,
                      border: const OutlineInputBorder(),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            selectedDeadline == null
                                ? l10n.noDeadline
                                : MaterialLocalizations.of(
                                    context,
                                  ).formatMediumDate(selectedDeadline!),
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            final picked = await pickDeadline(
                              dialogContext,
                              selectedDeadline,
                            );
                            if (picked == null) return;
                            setDialogState(() {
                              selectedDeadline = DateTime(
                                picked.year,
                                picked.month,
                                picked.day,
                              );
                            });
                          },
                          icon: const Icon(Icons.calendar_today_outlined),
                          tooltip: l10n.selectDate,
                        ),
                        if (selectedDeadline != null)
                          IconButton(
                            onPressed: () {
                              setDialogState(() {
                                selectedDeadline = null;
                              });
                            },
                            icon: const Icon(Icons.close),
                            tooltip: l10n.clearDate,
                          ),
                      ],
                    ),
                  ),
                  if (showCompletedToggle) ...[
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
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () {
                  final trimmedTitle = controller.text.trim();
                  if (trimmedTitle.isEmpty) return;

                  Navigator.pop(
                    dialogContext,
                    TaskFormData(
                      title: trimmedTitle,
                      section: selectedSection,
                      isDone: isDone,
                      deadline: selectedDeadline,
                    ),
                  );
                },
                child: Text(submitLabel),
              ),
            ],
          );
        },
      );
    },
  );
}
