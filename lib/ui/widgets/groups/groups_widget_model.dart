import 'package:flutter/material.dart';
import 'package:flutter_application_todo_list/domain/data_provaider/box_manager.dart';
import 'package:flutter_application_todo_list/domain/entity/group.dart';

import 'package:flutter_application_todo_list/ui/navigation/main_navigation.dart';
import 'package:flutter_application_todo_list/ui/widgets/app/tasks/tasks_widget.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';

class GroupWidgetModel extends ChangeNotifier {
  late final Future<Box<Group>> _box;
  var _groups = <Group>[];
  // .toList для инкапсуляции вместе с геттером
  List<Group> get groups => _groups.toList();

  GroupWidgetModel() {
    _setUp();
  }

  void showForm(BuildContext context) {
    Navigator.of(context).pushNamed(MainNavigationRouteNames.groupsForm);
  }

  Future<void> showTasks(BuildContext context, int groupIndex) async {
    final group = (await _box).getAt(groupIndex);
    if (group != null) {
      final configuration = TaskWidgetConfiguration(
        group.key as int,
        group.name,
      );
      Navigator.of(context).pushNamed(
        MainNavigationRouteNames.tasks,
        arguments: configuration,
      );
    }
  }

  Future<void> deleteGroup(int groupIndex) async {
    final box = await _box;
    final groupKey = (await _box).keyAt(groupIndex) as int;
    final taskBoxName = BoxManager.instance.makeTaskBoxName(groupKey);
    await Hive.deleteBoxFromDisk(taskBoxName);
    await box.deleteAt(groupIndex);
  }

  Future<void> _readGroupsFromHive() async {
    _groups = (await _box).values.toList();
    notifyListeners();
  }

  Future<void> _setUp() async {
    _box = BoxManager.instance.openGroupBox();

    //  в начале самом настраиваемся
    _readGroupsFromHive();
    // если произошли изменения:
    (await _box).listenable().addListener(_readGroupsFromHive);
  }
}

class GroupWidgetModelProvider extends InheritedNotifier {
  final GroupWidgetModel model;
  const GroupWidgetModelProvider(
      {Key? key, required this.model, required Widget child})
      : super(key: key, notifier: model, child: child);

  static GroupWidgetModelProvider? watch(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<GroupWidgetModelProvider>();
  }

  static GroupWidgetModelProvider? read(BuildContext context) {
    final widget = context
        .getElementForInheritedWidgetOfExactType<GroupWidgetModelProvider>()
        ?.widget;
    return widget is GroupWidgetModelProvider ? widget : null;
  }
}
