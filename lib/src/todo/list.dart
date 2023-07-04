import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../env.dart';
import '../theme/colors.dart';

/*
component would be:

TaskView
- AddTask
- TaskList
*/

// TODO: add doneAt filter
const gqlLoadTasks = r"""query($status:[TaskStatus!]) {
  tasks(input:{status: $status}){id,name,description,status,createdAt,updatedAt,dueDate}
}
""";


enum TaskStatus { notStarted, doing, done, paused }

TaskStatus toStatus(String v) {
  switch(v) {
    case "PAUSED": return TaskStatus.paused;
    case "DONE": return TaskStatus.done;
    case "DOING": return TaskStatus.doing;
    default: return TaskStatus.notStarted;
  }
}

class Task {
  Task(this.id, this.name, {this.status = TaskStatus.notStarted});

  final int id;
  String name;

  TaskStatus status;
}

class TaskListPage extends StatefulWidget {
  final Env env;

  const TaskListPage({super.key, required this.env});

  @override
  _TaskListPageState createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  // List<Task> tasks = [];
  String? token;

  void onTaskAdded(Task task) {
    print("adding task: $task");
  }

  void onTaskStatusChange(Task task, TaskStatus newStatus) {
    setState(() {
      task.status = newStatus;
    });
  }

  Widget tasklistBuilder(QueryResult<List<Task>> result, { VoidCallback? refetch, FetchMore? fetchMore }) {
    if(result.hasException) {
      return Text("Got Exception: ${result.exception.toString()}");
    }

    if(result.isLoading) {
      return const Text("loading");
    }

    List<Task> tasks = [];
    var data = result.data;

    if(data == null){
      print("didn't get any task");
    } else {
      for(var e in data["tasks"] as List) {
        tasks.add(Task(e["id"], e["name"], status: toStatus(e["status"])));
      }
    }

    return TaskListView(tasks: tasks, onTaskStatusChange: onTaskStatusChange);
  }

  @override
  Widget build(BuildContext context) {
    if(token == null) {
      return const Text("No Token. This shouldn't be rendered");
    }
    var document = gql(gqlLoadTasks);
    inspect(document);

    return Column(
      children: [
        AddTaskView(onTaskAdded: onTaskAdded),
        Expanded(child: Query<List<Task>>(
          options: QueryOptions(
            document: document,
            variables: const {
              "status": ["NOT_STARTED", "DOING", "PAUSED", "DONE"],
            },
          ),
          builder: tasklistBuilder,
        )),
      ],
    );
  }

  @override
  void initState() {
    super.initState();

    // make API calls
    token = widget.env.tokenNotifier.value;
    if(token == null) {
      print("navigating to login page");
      SchedulerBinding.instance.addPostFrameCallback((_) {
        context.go("/login");
        // Navigator.of(context).pushNamed("/login");
      });
    } else {

    }
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
        return TaskRow(task: task, onTaskStatusChange: onTaskStatusChange);
      },
    );
  }
}

class AddTaskView extends StatefulWidget {
  final Function(Task) onTaskAdded;

  const AddTaskView({super.key, required this.onTaskAdded});

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

  const TaskRow({super.key, required this.task, required this.onTaskStatusChange});

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


