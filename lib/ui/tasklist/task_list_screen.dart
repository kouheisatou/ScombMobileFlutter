import 'package:flutter/material.dart';
import 'package:scomb_mobile/common/network_screen_state.dart';

import '../scomb_mobile.dart';

class TaskListScreen extends StatefulWidget {
  TaskListScreen(this.parent, {Key? key}) : super(key: key);
  ScombMobileState parent;

  @override
  State<TaskListScreen> createState() => _TaskListScreenState(parent);
}

class _TaskListScreenState extends State<TaskListScreen>
    implements NetworkScreenState {
  _TaskListScreenState(this.parent);

  @override
  ScombMobileState parent;
  @override
  bool initialized = false;
  @override
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("課題・テスト一覧"),
      ),
      body: const Center(child: Text("リスト")),
    );
  }

  @override
  void fetchData() {
    // TODO: implement fetchData
  }

  @override
  void refreshData() {
    // TODO: implement refreshData
  }
}
