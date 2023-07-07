class Event {
  Event({required this.id, required this.taskID, required this.startAt, this.endAt, this.desc});
  final int id;
  final DateTime startAt;
  final DateTime? endAt;
  final int taskID;
  final String? desc;
}

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

