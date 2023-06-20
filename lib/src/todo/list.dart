import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/colors.dart';

enum TaskStatus { notStarted, doing, done, paused }
class Task {
  Task(this.id, this.name, {this.status = TaskStatus.notStarted});

  final int id;
  String name;

  TaskStatus status;
}

var tasks = <Task>[
  Task(1, "Learning flutter - Layout", status: TaskStatus.paused),
  Task(2, "Learning dart - classes", status: TaskStatus.doing),
  Task(3, "LeetCode Daily Quest", status: TaskStatus.done),
];

class AddTaskView extends StatefulWidget {
  final Function(Task) onTaskAdded;

  AddTaskView({required this.onTaskAdded});

  @override
  _AddTaskViewState createState() => _AddTaskViewState();
}

class _AddTaskViewState extends State<AddTaskView> {
  final TextEditingController _textEditingController = TextEditingController();

  addTaskFromInput(){
    final taskName = _textEditingController.text;
    if(taskName.isEmpty) {
      return;
    }

    widget.onTaskAdded(Task(-1, taskName));
    _textEditingController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _textEditingController,
            decoration: const InputDecoration(
              hintText: 'task name',
            ),
            autofocus: true,
            onSubmitted: (s)=> addTaskFromInput(),
          ),
        ) ,

        IconButton(
          icon: const Icon(Icons.add),
          onPressed: addTaskFromInput,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }
}

class TaskRow extends StatelessWidget {
  final Task task;
  final Function(Task, TaskStatus) onTaskStatusChange;

  TaskRow(this.task, this.onTaskStatusChange);

  Color _getBackgroundColor(context) {
    switch (task.status) {
      case TaskStatus.doing:
        return TodoColors.bgDoing;
      default:
        return TodoColors.bgDefault;
    }
  }

  TextStyle _getTextStyle(context) {
    switch (task.status) {
      case TaskStatus.done:
        return const TextStyle(color: TodoColors.todoDone, decoration: TextDecoration.lineThrough);
      default:
        return const TextStyle(color: TodoColors.todoDefault);
    }
  }

  IconData _getButtonIcon() {
    switch (task.status) {
      case TaskStatus.doing:
        return Icons.pause;
      default:
        return Icons.play_arrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _getBackgroundColor(context),
      child: ListTile(
        title: Row(
          children: [
            Checkbox(value: task.status == TaskStatus.done, onChanged: (ctx) {
              if(task.status == TaskStatus.done) {
                onTaskStatusChange(task, TaskStatus.notStarted);
              } else {
                onTaskStatusChange(task, TaskStatus.done);
              }
            }),
            Expanded(
              child: Text(
                task.name,
                style: _getTextStyle(context),
              ),
            ),
            IconButton(
              icon: Icon(_getButtonIcon()),
              onPressed: () {
                if(task.status == TaskStatus.doing){
                  onTaskStatusChange(task, TaskStatus.paused);
                } else {
                  onTaskStatusChange(task, TaskStatus.doing);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}


class TaskListView extends StatelessWidget {
  static const routeName = "/";

  final List<Task> tasks;
  final Function(Task,TaskStatus) onTaskStatusChange;

  const TaskListView({super.key, required this.tasks, required this.onTaskStatusChange});

  @override
  Widget build(BuildContext context) {
    final tasks = this.tasks;
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (ctx, idx) {
        final task = tasks[idx];
        return TaskRow(task, onTaskStatusChange);
      },
    );
  }
}

class TaskListPage extends StatefulWidget {
  @override
  _TaskListPageState createState() => _TaskListPageState();
}
class _TaskListPageState extends State<TaskListPage> {
  List<Task> tasks = [];

  void onTaskAdded(Task task) {
    setState(() {
      tasks.add(task);
    });
  }

  void onTaskStatusChange(Task task, TaskStatus newStatus) {
    setState(() {
      task.status = newStatus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("TodoPeer"),
        ),
        body: Column(
          children: [
            AddTaskView(onTaskAdded: onTaskAdded),
            Expanded(child: TaskListView(tasks: tasks, onTaskStatusChange: onTaskStatusChange,)),
          ],
        )
    );
  }
}
