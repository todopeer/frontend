import 'package:flutter/material.dart';

class TaskListView extends StatelessWidget {
  const TaskListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("TodoPeer"),
      ),
      body: ListView(
        children: const [

          Text("Num 1"),
          Text("Num 2"),
        ],
      )
    );
  }
}