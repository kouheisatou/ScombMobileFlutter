import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scomb_mobile/common/timetable_scraping.dart';

import '../../common/values.dart';

class TimetableScreen extends StatelessWidget {
  const TimetableScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("時間割"),
      ),
      body: Column(
        children: [
          OutlinedButton(
            onPressed: () {
              Fluttertoast.showToast(
                msg: "timetable : $timetable",
              );
            },
            child: const Text("取得済み時間割表示"),
          ),
          OutlinedButton(
            onPressed: () async {
              var newTimetable =
                  await fetchTimetable(sessionId, 2022, Term.FIRST);
              Fluttertoast.showToast(
                  msg: newTimetable == null ? "取得失敗" : "取得完了");
              timetable = newTimetable;
            },
            child: const Text("時間割再取得"),
          ),
        ],
      ),
    );
  }
}
