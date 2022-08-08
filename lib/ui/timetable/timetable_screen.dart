import 'package:flutter/material.dart';

import '../../common/scraping.dart';
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
              final doc = await getTimetable(
                "ZDkwZjYwMTMtNjkzZC00OWMyLTkyODYtNmI2OGM5ODNjYzM2",
                2022,
                Term.First,
              );
              print(doc?.body?.text);
            },
            child: const Text("時間割画面"),
          ),
        ],
      ),
    );
  }
}
