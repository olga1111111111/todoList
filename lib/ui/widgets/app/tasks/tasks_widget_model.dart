import 'package:flutter/cupertino.dart';
import 'package:flutter_application_todo_list/domain/entity/group.dart';
import 'package:flutter_application_todo_list/domain/entity/task.dart';
import 'package:flutter_application_todo_list/ui/navigation/main_navigation.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';

class TaskWidgetModel extends ChangeNotifier {
  final int groupKey;
  late final Future<Box<Group>> _groupBox;
  var _tasks = <Task>[];
  // .toList для инкапсуляции вместе с геттером

  List<Task> get tasks => _tasks.toList();

  Group? _group;
  Group? get group => _group;

  TaskWidgetModel({required this.groupKey}) {
    _setUp();
  }
  void _loadGroup() async {
    final box = await _groupBox;
    _group = box.get(groupKey);
    notifyListeners();
  }

  void _readTasks() {
    _tasks = _group?.tasks ?? <Task>[];
    notifyListeners();
  }

  void deleteTask(int groupIndex) async {
    await _group?.tasks?.deleteFromHive(groupIndex);
    await _group?.save();
  }

  void doneToggle(int groupIndex) async {
    final task = group?.tasks?[groupIndex];
    final currentState = task?.isDone ?? false;
    task?.isDone = !currentState;
    await task?.save();
    notifyListeners();
  }

  void setUpListenTasks() async {
    final box = await _groupBox;
    _readTasks();
    box.listenable(keys: <dynamic>[groupKey]).addListener(_readTasks);
  }

  void showForm(BuildContext context) {
    Navigator.of(context)
        .pushNamed(MainNavigationRouteNames.tasksForm, arguments: groupKey);
  }

  void _setUp() {
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(GroupAdapter());
    }
    _groupBox = Hive.openBox<Group>('group_box');
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(TaskAdapter());
    }
    Hive.openBox<Task>('task_box');

    _loadGroup();
    setUpListenTasks();
  }
}

class TaskWidgetModelProvider extends InheritedNotifier {
  final TaskWidgetModel model;
  const TaskWidgetModelProvider(
      {Key? key, required this.model, required Widget child})
      : super(key: key, notifier: model, child: child);

  static TaskWidgetModelProvider? watch(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<TaskWidgetModelProvider>();
  }

  static TaskWidgetModelProvider? read(BuildContext context) {
    final widget = context
        .getElementForInheritedWidgetOfExactType<TaskWidgetModelProvider>()
        ?.widget;
    return widget is TaskWidgetModelProvider? ? widget : null;
  }
}
