import 'package:flutter/material.dart';
import 'package:flutter_application_todo_list/domain/data_provaider/box_manager.dart';

import 'package:flutter_application_todo_list/domain/entity/task.dart';

class TaskFormWidgetModel extends ChangeNotifier {
  int groupKey;
  var _taskText = '';

  bool get isValid => _taskText.trim().isNotEmpty;

  set taskText(String value) {
    final isTaskFormEmpty = _taskText.trim().isEmpty;
    _taskText = value;
    if (value.trim().isEmpty != isTaskFormEmpty) {
      notifyListeners();
    }
  }

  TaskFormWidgetModel({required this.groupKey});

  void saveTask(BuildContext context) async {
    final taskText = _taskText.trim();
    if (taskText.isEmpty) return;
    final task = Task(text: taskText, isDone: false);
    final box = await BoxManager.instance.openTaskBox(groupKey);
    await box.add(task);
    await BoxManager.instance.closeBox(box);
    Navigator.of(context).pop();

    // if (taskText.isEmpty) return;
    // if (!Hive.isAdapterRegistered(2)) {
    //   Hive.registerAdapter(TaskAdapter());
    // }
    // if (!Hive.isAdapterRegistered(1)) {
    //   Hive.registerAdapter(GroupAdapter());
    // }

    // final taskBox = await Hive.openBox<Task>('task_box');
    // final task = Task(text: taskText, isDone: false);
    // await taskBox.add(task);

    // final groupBox = await Hive.openBox<Group>('group_box');
    // final group = groupBox.get(groupKey);
    // group?.addTask(taskBox, task);

    // Navigator.of(context).pop();
  }
}

class TaskFormWidgetModelProvaider extends InheritedNotifier {
  final TaskFormWidgetModel? model;
  const TaskFormWidgetModelProvaider(
      {Key? key, required this.model, required Widget child})
      : super(key: key, notifier: model, child: child);

  static TaskFormWidgetModelProvaider? watch(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<TaskFormWidgetModelProvaider>();
  }

  static TaskFormWidgetModelProvaider? read(BuildContext context) {
    final widget = context
        .getElementForInheritedWidgetOfExactType<TaskFormWidgetModelProvaider>()
        ?.widget;
    return widget is TaskFormWidgetModelProvaider? ? widget : null;
  }

  @override
  bool updateShouldNotify(TaskFormWidgetModelProvaider oldWidget) {
    return false;
  }
}
