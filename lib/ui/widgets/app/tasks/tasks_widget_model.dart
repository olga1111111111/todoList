import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_todo_list/domain/data_provaider/box_manager.dart';

import 'package:flutter_application_todo_list/domain/entity/task.dart';
import 'package:flutter_application_todo_list/ui/navigation/main_navigation.dart';
import 'package:flutter_application_todo_list/ui/widgets/app/tasks/tasks_widget.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';

class TaskWidgetModel extends ChangeNotifier {
  final TaskWidgetConfiguration configuration;
  late final Future<Box<Task>> _box;
  ValueListenable<Object>? _listenableBox;
  var _tasks = <Task>[];
  // .toList для инкапсуляции вместе с геттером

  List<Task> get tasks => _tasks.toList();

  TaskWidgetModel({required this.configuration}) {
    _setUp();
  }

  Future<void> deleteTask(int taskIndex) async {
    await (await _box).deleteAt(taskIndex);
  }

  Future<void> doneToggle(int taskIndex) async {
    final task = (await _box).getAt(taskIndex);
    task?.isDone = !task.isDone;
    await task?.save();
  }

  void showForm(BuildContext context) {
    Navigator.of(context).pushNamed(MainNavigationRouteNames.tasksForm,
        arguments: configuration.groupKey);
  }

  Future<void> _readTasksFromHive() async {
    _tasks = (await _box).values.toList();
    notifyListeners();
  }

  Future<void> _setUp() async {
    _box = BoxManager.instance.openTaskBox(configuration.groupKey);

    //  в начале самом настраиваемся
    _readTasksFromHive();
    // если произошли изменения:
    _listenableBox = (await _box).listenable();
    _listenableBox?.addListener(_readTasksFromHive);
  }

  @override
  Future<void> dispose() async {
    _listenableBox?.removeListener(_readTasksFromHive);
    await BoxManager.instance.closeBox((await _box));
    super.dispose();
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
