import 'dart:developer';

import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:todopeer/src/gql/api.dart';

import '../../env.dart';
import '../../gql/model.dart';

class ReviewPage extends StatefulWidget {
  final Env env;

  const ReviewPage({super.key, required this.env});

  @override
  State<StatefulWidget> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  Map<DateTime, List<Event>> date2events = {};
  Map<int, Task> tasks = {};

  late EventController eventController;

  setSelectedDate(DateTime dtWithHours) async {
    // make sure dateTime is only of days
    var dateOnly = DateTime(dtWithHours.year, dtWithHours.month, dtWithHours.day);

    if(date2events.containsKey(dateOnly)) {
      return;
    }

    // make the GQL API Call
    GraphQLClient client = GraphQLProvider.of(context).value;
    var result = await client.query( qOptionDayEvents(dateOnly) );
    if(result.hasException) {
      log("result has exception: ${result.exception.toString()}");
      // TODO: decide what to do with exceptions
      return;
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
          log("on date change: date: $date; page: $page");
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

    var events = (data["events"] as List).map(gqlEventParse).toList();

    // merge into task
    for(var e in data["tasks"] as List) {
      Task t = gqlTaskParse(e);
      if(!tasks.containsKey(t.id)) {
        tasks[t.id] = t;
      }
    }

    return events;
  }
}