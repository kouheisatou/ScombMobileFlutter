import 'package:flutter/material.dart';
import 'package:scomb_mobile/ui/component/timetable.dart';

import 'customized_timetable_screen.dart';

class MyTimetableListScreen extends StatelessWidget {
  MyTimetableListScreen({super.key});

  var controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("マイ時間割"),
        actions: [
          IconButton(
            onPressed: () async {
              String? newTimetableTitle = await showDialog(
                context: context,
                builder: (builder) {
                  return AlertDialog(
                    title: const Text("時間割名を入力"),
                    content: TextFormField(
                      controller: controller,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          controller.text = "";
                        },
                        child: const Text("キャンセル"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context, controller.text);
                          controller.text = "";
                        },
                        child: const Text("作成"),
                      ),
                    ],
                  );
                },
              );

              if (newTimetableTitle == null) return;

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (builder) {
                    return CustomizedTimetableScreen(
                      newTimetableTitle,
                      createEmptyTimetable(),
                      isEditMode: true,
                    );
                  },
                ),
              );
            },
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body: ListView(
        children: [
          // TODO DBからマイ時間割のリストを復元
        ],
      ),
    );
  }
}
