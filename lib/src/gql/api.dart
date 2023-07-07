import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';

import 'model.dart';

const _gqlDayQuery = r"""
query($days:Int!, $since:Time!) {
  events(since:$since, days: $days){
    events{id,taskID,startAt,endAt,description},
    tasks{id,name,description,status,createdAt,updatedAt,dueDate}
  }
}
""";

qOptionDayEvents(datetime) {
  return QueryOptions(
    document: gql(_gqlDayQuery),
    variables: {
      "since": formatTime(datetime),
      "days": 1,
    },
  );
}

const _gqlLoadTasks = r"""query($status:[TaskStatus!]) {
  tasks(input:{status: $status}){id,name,description,status,createdAt,updatedAt,dueDate}
}
""";

qOptionTasks() {
  var document = gql(_gqlLoadTasks);
  return QueryOptions(
    document: document,
    variables: const {
      "status": ["NOT_STARTED", "DOING", "PAUSED", "DONE"],
    },
  );
}



const gqlMutationLogin = r'''mutation Login($email: String!, $password: String!) {
  login(input: {
    email: $email
    password: $password
  }) {
    token
  }
}
''';


var timeFormatter = DateFormat("yyyy-MM-ddTHH:mm:ss");
String formatTime(DateTime time) {
  var tz = time.timeZoneOffset;
  String sign = (tz.isNegative) ? "-" : "+";
  return "${timeFormatter.format(time)}$sign${tz.inHours.toString().padLeft(2, "0")}:00";
}

DateTime? parseDateTime(String? s) {
  if(s == null) {
    return null;
  }
  return DateTime.parse(s).toLocal();
}

Event gqlEventParse(e) => Event(
      id: e["id"], taskID: e["taskID"], startAt: parseDateTime(e["startAt"])!,
      endAt: parseDateTime(e["endAt"]), desc: e["description"],
);

Task gqlTaskParse(e) => Task(e["id"], e["name"], status: toStatus(e["status"]));
