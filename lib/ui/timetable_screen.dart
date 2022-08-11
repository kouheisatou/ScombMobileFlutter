import 'package:flutter/material.dart';
import 'package:scomb_mobile/common/network_screen.dart';
import 'package:scomb_mobile/common/scraping/timetable_scraping.dart';

import '../common/values.dart';

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
  Future<void> getFromServerAndSaveToSharedResource(savedSessionId) async {
    // todo recover from timetable setting
    var yearFromSettings = 2022;
    var termFromSettings = Term.FIRST;

    await fetchTimetable(
      sessionId ?? savedSessionId,
      yearFromSettings,
      termFromSettings,
    );
  }

  @override
  Widget innerBuild() {
    return Column(
      children: [
        OutlinedButton(
          onPressed: () async {
            refreshData();
          },
          child: const Text("時間割再取得"),
        ),
        Text(timetable.toString())
      ],
    );
  }
}
