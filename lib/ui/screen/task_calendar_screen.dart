import 'package:flutter/material.dart';
import 'package:scomb_mobile/ui/screen/network_screen.dart';

class TaskCalendarScreen extends NetworkScreen {
  TaskCalendarScreen(super.parent, super.title, {Key? key}) : super(key: key);

  @override
  State<TaskCalendarScreen> createState() => _TaskCalendarScreenState();
}

class _TaskCalendarScreenState extends NetworkScreenState<TaskCalendarScreen> {
  @override
  Future<void> getFromServerAndSaveToSharedResource(savedSessionId) {
    // TODO: implement getFromServer
    return super.getFromServerAndSaveToSharedResource(savedSessionId);
  }

  @override
  Widget innerBuild() {
    return const Center(child: Text("カレンダー画面"));
  }
}
