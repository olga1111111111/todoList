import 'package:flutter/material.dart';
import 'package:flutter_application_todo_list/domain/data_provaider/box_manager.dart';
import 'package:flutter_application_todo_list/domain/entity/group.dart';

import 'package:flutter_application_todo_list/ui/navigation/main_navigation.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';

class GroupWidgetModel extends ChangeNotifier {
  var _groups = <Group>[];
  // .toList для инкапсуляции вместе с геттером
  List<Group> get groups => _groups.toList();

  void showForm(BuildContext context) {
    Navigator.of(context).pushNamed(MainNavigationRouteNames.groupsForm);
  }

  void showTasks(BuildContext context, int groupIndex) async {
    final box = await BoxManager.instance.openGroupBox();
    final groupKey = box.keyAt(groupIndex) as int;
    Navigator.of(context)
        .pushNamed(MainNavigationRouteNames.tasks, arguments: groupKey);
  }

  GroupWidgetModel() {
    _setUp();
  }

  void deleteGroup(int groupIndex) async {
    final box = await BoxManager.instance.openGroupBox();
    await box.getAt(groupIndex)?.tasks?.deleteAllFromHive();
    await box.deleteAt(groupIndex);
  }

  void _readGroupsFromHive(Box<Group> box) {
    _groups = box.values.toList();
    notifyListeners();
  }

  void _setUp() async {
    final box = await BoxManager.instance.openGroupBox();

    await BoxManager.instance.openTaskBox();
    //  в начале самом настраиваемся
    _readGroupsFromHive(box);
    // если произошли изменения:
    box.listenable().addListener(() => _readGroupsFromHive(box));
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
