import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../common/timetable_scraping.dart';
import '../../common/values.dart';
import '../login/login_screen.dart';

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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginScreen(),
                  fullscreenDialog: true,
                ),
              );
            },
            child: const Text("ログイン画面へ"),
          ),
          ElevatedButton(
            onPressed: () async {
              var timetable = await fetchTimetable(
                sessionId,
                2022,
                Term.FIRST,
              );
              Fluttertoast.showToast(
                msg: "timetable : $timetable",
              );
            },
            child: const Text("時間割取得"),
          ),
        ],
      ),
    );
  }
}
