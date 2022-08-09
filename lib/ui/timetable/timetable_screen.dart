import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scomb_mobile/common/network_screen_state.dart';
import 'package:scomb_mobile/common/timetable_scraping.dart';

import '../../common/values.dart';
import '../scomb_mobile.dart';

class TimetableScreen extends StatefulWidget {
  TimetableScreen(this.parent, {Key? key}) : super(key: key);

  ScombMobileState parent;

  @override
  State<TimetableScreen> createState() {
    return _TimetableScreenState(parent, "時間割");
  }
}

class _TimetableScreenState extends NetworkScreenState<TimetableScreen> {
  _TimetableScreenState(super.parent, super.title);

  Future<void> refreshData() async {
    initialized = false;
    fetchData();
  }

  Future<void> fetchData() async {
    if (initialized) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    // todo recover from local db
    var savedSessionId = "saved_session_id";
    var yearFromSettings = 2022;
    var termFromSettings = Term.FIRST;

    timetable = await fetchTimetable(
      sessionId ?? savedSessionId,
      yearFromSettings,
      termFromSettings,
    );

    // permission error
    if (timetable == null) {
      parent.navToLoginScreen();
      return;
    }
    // saved session id passed
    else {
      sessionId ??= savedSessionId;
    }

    setState(() {
      isLoading = false;
    });

    initialized = true;
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
