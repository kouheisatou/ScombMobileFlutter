import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scomb_mobile/common/network_screen.dart';
import 'package:scomb_mobile/common/timetable_scraping.dart';

import '../../common/values.dart';

class TimetableScreen extends NetworkScreen {
  TimetableScreen(super.parent, super.title, {Key? key}) : super(key: key);

  @override
  State<TimetableScreen> createState() {
    return _TimetableScreenState();
  }
}

class _TimetableScreenState extends NetworkScreenState<TimetableScreen> {
  _TimetableScreenState();

  @override
  Future<void> getFromServerAndSaveToSharedResource() async {
    // todo recover from local db
    var savedSessionId = "saved_session_id";
    var yearFromSettings = 2022;
    var termFromSettings = Term.FIRST;

    var newTimetable = await fetchTimetable(
      sessionId ?? savedSessionId,
      yearFromSettings,
      termFromSettings,
    );

    // permission error
    if (newTimetable == null) {
      widget.parent.navToLoginScreen();
      widget.initialized = false;
      throw Exception("not_permitted");
    }
    // saved session id passed
    else {
      sessionId ??= savedSessionId;
    }
    timetable = newTimetable;
  }

  @override
  Widget innerBuild() {
    return Column(
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
            refreshData();
          },
          child: const Text("時間割再取得"),
        ),
      ],
    );
  }
}
