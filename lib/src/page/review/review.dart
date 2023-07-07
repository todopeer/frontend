import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';

import '../../env.dart';
import '../../todo/list.dart';

const gqlDayQuery = r"""
query($days:Int!, $since:Time!) {
  events(since:$since, days: $days){
    events{id,taskID,startAt,endAt,description},
    tasks{id,name,description,status,createdAt,updatedAt,dueDate}
  }
}
""";


class ReviewPageHeader extends StatelessWidget {
  ReviewPageHeader({required this.date, required this.setDate, super.key});

  final DateTime date;
  final Function(DateTime) setDate;

  @override
  Widget build(BuildContext context) {
    return Text("date header: $date");
  }
}

// class ReviewPage extends StatefulWidget {
//   const ReviewPage({super.key});
//
//   @override
//   State<StatefulWidget> createState() {
//     return _ReviewPageState();
//   }
// }
//
// class _ReviewPageState extends State<ReviewPage> {
//   DateTime date = DateTime.now();
//
//   void setDate(DateTime date) {
//     setState(() {
//       this.date = date;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(children: [
//       ReviewPageHeader(date: date, setDate: setDate),
//       Expanded(child: ReviewBody(date)),
//     ]);
//
//   }
// }

class ReviewPage extends StatefulWidget {
  final Env env;

  const ReviewPage({super.key, required this.env});

  @override
  State<StatefulWidget> createState() {
    return _ReviewPageState();
  }
}

class Event {
  Event({required this.id, required this.taskID, required this.startAt, this.endAt, this.desc});
  final int id;
  final DateTime startAt;
  final DateTime? endAt;
  final int taskID;
  final String? desc;
}

var timeFormatter = DateFormat("yyyy-MM-ddTHH:mm:ss");
String formatTime(DateTime time) {
  var tz = time.timeZoneOffset;
  String sign = (tz.isNegative) ? "-" : "+";
  return "${timeFormatter.format(time)}$sign${tz.inHours.toString().padLeft(2, "0")}:00";

}

class _ReviewPageState extends State<ReviewPage> {
  late DateTime selectedDate;
  Map<DateTime, List<Event>> date2events = {};
  Map<int, Task> tasks = {};

  late EventController eventController;

  setSelectedDate(DateTime dtWithHours) async {
    // make the GQL API Call
    GraphQLClient client = GraphQLProvider.of(context).value;
    // make sure dateTime is only of days
    var dateOnly = DateTime(dtWithHours.year, dtWithHours.month, dtWithHours.day);

    if(date2events.containsKey(dateOnly)) {
      return;
    }

    var result = await client.query( QueryOptions(
      document: gql(gqlDayQuery),
      variables: {
        "since": formatTime(dateOnly),
        "days": 1,
      },

      // these 2 seems useless
      // onComplete: (data) {
      //   print("onComplete data: $data");
      // },
      // onError: (err) {
      //   print("on error: $err");
      // },
    ));

    if(result.hasException) {
      print("result has exception: ${result.exception.toString()}");
    }

    // parse result data
    var events = parseResultData(result.data);
    date2events[dateOnly] = events;
    eventController.addAll(
      // TODO: should probably filter out the ongoing task
        events.map(
              (e) => CalendarEventData(
                title: tasks[e.taskID]!.name, date: e.startAt,
                startTime: e.startAt, endTime: e.endAt ?? DateTime.now(),
                description: e.desc ?? "",
              )).toList());

    setState(() {
      selectedDate = dateOnly;
    });
  }

  @override
  void initState() {
    eventController = EventController();
    Future<void>.delayed(const Duration(seconds: 1), () => setSelectedDate(DateTime.now()));
  }

  @override
  void dispose() {
    super.dispose();
    eventController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CalendarControllerProvider(
      controller: eventController,
      child: DayView(
        onPageChange: (date, page) {
          print("on date change: date: $date; page: $page");
          setSelectedDate(date);
        },
        minuteSlotSize: MinuteSlotSize.minutes15,
        maxDay: DateTime.now(),
        heightPerMinute: 3,
      ),
    );
  }

  List<Event> parseResultData(Map<String, dynamic>? data) {
    if(data == null) {
      // nothing to do
      return [];
    }

    // events query, would
    data = data["events"] as Map<String, dynamic>;

    var events = (data["events"] as List).map(
          (e) => Event(
            id: e["id"], taskID: e["taskID"], startAt: parseDateTime(e["startAt"])!,
            endAt: parseDateTime(e["endAt"]), desc: e["description"])
          ).toList();

    // merge into task
    for(var e in data["tasks"] as List) {
      Task t = Task(e["id"], e["name"], status: toStatus(e["status"]));
      if(!tasks.containsKey(t.id)) {
        tasks[t.id] = t;
      }
    }

    return events;
  }

  DateTime? parseDateTime(String? s) {
    if(s == null) {
      return null;
    }
    return DateTime.parse(s).toLocal();
  }
}

// class ReviewBody extends StatelessWidget {
//   const ReviewBody(this.date, {super.key});
//
//   final DateTime date;
//
//   @override
//   Widget build(BuildContext context) {
//     return DayView(initialDay: date,);
//   }
// }