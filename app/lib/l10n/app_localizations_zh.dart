// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get today => '今日';

  @override
  String get shortTerm => '短期';

  @override
  String get longTerm => '长期';

  @override
  String get completed => '已完成';

  @override
  String get active => '进行中';

  @override
  String get addTask => '添加任务';

  @override
  String get editTask => '编辑任务';

  @override
  String get taskTitle => '任务标题';

  @override
  String get enterTask => '输入任务...';

  @override
  String get section => '分类';

  @override
  String get cancel => '取消';

  @override
  String get add => '添加';

  @override
  String get save => '保存';

  @override
  String get delete => '删除';

  @override
  String get deleteTask => '删除任务';

  @override
  String get clearCompleted => '清空已完成';

  @override
  String get clear => '清空';

  @override
  String get completedLabel => '已完成';

  @override
  String get moveToToday => '移动到今日';

  @override
  String get moveToShortTerm => '移动到短期';

  @override
  String get moveToLongTerm => '移动到长期';

  @override
  String get noActiveTasksToday => '今日没有进行中的任务';

  @override
  String get noActiveTasksShortTerm => '短期没有进行中的任务';

  @override
  String get noActiveTasksLongTerm => '长期没有进行中的任务';

  @override
  String get noCompletedTasks => '还没有已完成任务';

  @override
  String deleteTaskMessage(Object taskTitle) {
    return '删除“$taskTitle”吗？';
  }

  @override
  String completedInSection(Object sectionName) {
    return '已完成 • $sectionName';
  }

  @override
  String clearCompletedMessage(int count) {
    return '删除全部 $count 个已完成任务吗？';
  }
}
