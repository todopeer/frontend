import 'package:flutter/material.dart';


class ReviewPageHeader extends StatelessWidget {
  ReviewPageHeader({required this.date, required this.setDate, super.key});

  final DateTime date;
  final Function(DateTime) setDate;

  @override
  Widget build(BuildContext context) {
    return Text("date header: $date");
  }
}

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ReviewPageState();
  }
}

class _ReviewPageState extends State<ReviewPage> {
  DateTime date = DateTime.now();

  void setDate(DateTime date) {
    setState(() {
      this.date = date;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      ReviewPageHeader(date: date, setDate: setDate),
      Expanded(child: ReviewBody(date)),
    ]);

  }
}

class ReviewBody extends StatelessWidget {
  const ReviewBody(this.date, {super.key});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Text("Review Body: $date");
  }

}