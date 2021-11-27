import 'package:flutter/material.dart';
import 'package:flutter_application_todo_list/ui/widgets/app/tasks/tasks_widget_model.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class TaskWidgetConfiguration {
  final int groupKey;
  final String title;

  TaskWidgetConfiguration(this.groupKey, this.title);
}

class TasksWidget extends StatefulWidget {
  final TaskWidgetConfiguration configuration;
  const TasksWidget({Key? key, required this.configuration}) : super(key: key);

  @override
  _TasksWidgetState createState() => _TasksWidgetState();
}

class _TasksWidgetState extends State<TasksWidget> {
  // TaskWidgetModel? _model;
  // через конструктор будет инициализироваться,можно сделать late final
  late final TaskWidgetModel _model;
  @override
  void initState() {
    super.initState();

    _model = TaskWidgetModel(configuration: widget.configuration);
  }
  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();

  //   if (_model == null) {
  //     // current rout with arguments:
  //     final groupKey = ModalRoute.of(context)!.settings.arguments as int;
  //     _model = TaskWidgetModel(groupKey: groupKey);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    // чтобы делать сравнение на неравенство нулю
    // final model = _model;
    // if (model != null) {
    //   return TaskWidgetModelProvider(
    //       model: model, child: const TaskWidgetBody());
    // } else {
    //   return const Center(child: CircularProgressIndicator());
    // }
    // если без проверки упростить,то ! использовать
    return TaskWidgetModelProvider(
        model: _model, child: const TaskWidgetBody());
  }

  // вызывается автоматически в стейте, когда виджет исчезает из дерева:
  @override
  void dispose() async {
    super.dispose();
    await _model.dispose();
  }
}

class TaskWidgetBody extends StatelessWidget {
  const TaskWidgetBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = TaskWidgetModelProvider.watch(context)?.model;
    final title = model?.configuration.title ?? 'tasks';
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: const _TaskListWidget(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => model?.showForm(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _TaskListWidget extends StatelessWidget {
  const _TaskListWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tasksCount =
        TaskWidgetModelProvider.watch(context)?.model.tasks.length ?? 0;
    return ListView.separated(
      itemBuilder: (BuildContext context, int index) {
        return TaskListRowWidget(
          indexInList: index,
        );
      },
      itemCount: tasksCount,
      separatorBuilder: (BuildContext context, int index) {
        return const Divider(
          height: 1,
        );
      },
    );
  }
}

class TaskListRowWidget extends StatelessWidget {
  final int indexInList;
  const TaskListRowWidget({Key? key, required this.indexInList})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = TaskWidgetModelProvider.read(context)!.model;
    final task = model.tasks[indexInList];
    final icon = task.isDone ? Icons.done : null;
    final style = task.isDone
        ? const TextStyle(decoration: TextDecoration.lineThrough)
        : null;
    return Slidable(
      actionPane: const SlidableBehindActionPane(),
      secondaryActions: <Widget>[
        IconSlideAction(
            caption: 'Delete',
            color: Colors.red,
            icon: Icons.delete,
            onTap: () => model.deleteTask(indexInList)),
      ],
      child: ColoredBox(
        color: Colors.white,
        child: ListTile(
          title: Text(
            task.text,
            style: style,
          ),
          trailing: Icon(icon),
          onTap: () => model.doneToggle(indexInList),
        ),
      ),
    );
  }
}
