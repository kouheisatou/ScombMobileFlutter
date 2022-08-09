import 'package:flutter/material.dart';
import 'package:scomb_mobile/common/network_screen.dart';

class TaskListScreen extends NetworkScreen {
  TaskListScreen(super.parent, super.title);

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends NetworkScreenState<TaskListScreen> {
  @override
  Future<void> getFromServerAndSaveToSharedResource() {
    // TODO: implement getFromServer
    return super.getFromServerAndSaveToSharedResource();
  }

  @override
  Widget innerBuild() {
    return const Center(child: Text("リスト"));
  }
}
