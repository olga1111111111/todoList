import 'package:flutter_application_todo_list/domain/entity/group.dart';
import 'package:flutter_application_todo_list/domain/entity/task.dart';
import 'package:hive/hive.dart';

// хелперы для работы с hive Box:
class BoxManager {
  static final BoxManager instance = BoxManager._();
  BoxManager._();

  Future<Box<Group>> openGroupBox() async {
    return _openBox('group_box', 1, GroupAdapter());
  }

  Future<Box<Task>> openTaskBox(int groupKey) async {
    return _openBox(makeTaskBoxName(groupKey), 2, TaskAdapter());
  }

  String makeTaskBoxName(int groupKey) => 'task_box_$groupKey';

  Future<void> closeBox<T>(Box<T> box) async {
    await box.compact();
    await box.close();
  }

  Future<Box<T>> _openBox<T>(
      String name, int typeId, TypeAdapter<T> adapter) async {
    if (!Hive.isAdapterRegistered(typeId)) {
      Hive.registerAdapter(adapter);
    }

    return Hive.openBox<T>(name);
  }
}
