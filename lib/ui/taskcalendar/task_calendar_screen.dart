import 'package:flutter/material.dart';

class TaskCalendarScreen extends StatelessWidget {
  const TaskCalendarScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("締切カレンダー"),
      ),
      body: const Center(
          child: Text("カレンダー")),
    );
  }
}