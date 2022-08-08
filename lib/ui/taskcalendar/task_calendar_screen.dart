import 'package:flutter/material.dart';
import 'package:scomb_mobile/ui/login/login_screen.dart';

class TaskCalendarScreen extends StatelessWidget {
  const TaskCalendarScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("締切カレンダー"),
      ),
      body: Column(
        children: [
          const Text("カレンダー画面"),
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
          )
        ],
      ),
    );
  }
}
