import 'package:flutter/material.dart';
import 'package:flutter_application_todo_list/domain/entity/group.dart';
import 'package:flutter_application_todo_list/domain/entity/task.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';

class TaskFormWidgetModel {
  int groupKey;
  var taskText = '';
  TaskFormWidgetModel({required this.groupKey});

  void saveTask(BuildContext context) async {
    if (taskText.isEmpty) return;
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(TaskAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(GroupAdapter());
    }

    final taskBox = await Hive.openBox<Task>('task_box');
    final task = Task(text: taskText, isDone: false);
    await taskBox.add(task);

    final groupBox = await Hive.openBox<Group>('group_box');
    final group = groupBox.get(groupKey);
    group?.addTask(taskBox, task);

    Navigator.of(context).pop();
  }
}

class TaskFormWidgetModelProvaider extends InheritedWidget {
  final TaskFormWidgetModel? model;
  const TaskFormWidgetModelProvaider(
      {Key? key, required this.model, required Widget child})
      : super(key: key, child: child);

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