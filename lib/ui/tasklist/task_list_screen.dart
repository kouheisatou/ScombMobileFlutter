import 'package:flutter/material.dart';
import 'package:scomb_mobile/common/network_screen_state.dart';

import '../scomb_mobile.dart';

class TaskListScreen extends StatefulWidget {
  TaskListScreen(this.parent, {Key? key}) : super(key: key);
  ScombMobileState parent;

  @override
  State<TaskListScreen> createState() => _TaskListScreenState(
        parent,
        "課題・テスト一覧",
      );
}

class _TaskListScreenState extends NetworkScreenState<TaskListScreen> {
  _TaskListScreenState(super.parent, super.title);

  @override
  void fetchData() {
    // TODO: implement fetchData
  }

  @override
  void refreshData() {
    // TODO: implement refreshData
  }

  @override
  Widget innerBuild() {
    return const Center(child: Text("リスト"));
  }
}
