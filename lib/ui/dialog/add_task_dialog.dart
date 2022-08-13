import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class AddTaskDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("課題追加"),
      content: Row(
        children: [
          Expanded(
            child: TextField(
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'limitDay',
                hintText: 'date',
              ),
              onTap: () {
                DatePicker.showDateTimePicker(context,
                    showTitleActions: true,
                    theme: const DatePickerTheme(
                        backgroundColor: Colors.blue,
                        itemStyle: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                        doneStyle:
                            TextStyle(color: Colors.white, fontSize: 16)),
                    onChanged: (date) {
                  print(
                      'change $date in time zone ${date.timeZoneOffset.inHours}');
                }, onConfirm: (date) {
                  print('confirm $date');
                }, currentTime: DateTime.now(), locale: LocaleType.jp);
              },
            ),
          )
        ],
      ),
    );
  }
}
