import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scomb_mobile/common/db/scomb_mobile_database.dart';
import 'package:scomb_mobile/common/utils.dart';
import 'package:scomb_mobile/common/values.dart';

import '../../common/db/class_cell.dart';
import '../../common/db/task.dart';
import '../../common/shared_resource.dart';

class AddTaskDialog extends StatefulWidget {
  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  DateTime? selectedDate;
  String title = "";
  ClassCell? classDropDownValue;
  int taskTypeDropDownValue = TaskType.OTHERS;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text("課題追加"),
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              TextField(
                autofocus: true,
                decoration: const InputDecoration(labelText: "課題タイトル"),
                onChanged: (text) {
                  title = text;
                },
              ),
              Row(
                children: [
                  const Text("授業 : "),
                  const Spacer(),
                  DropdownButton<ClassCell>(
                    value: classDropDownValue,
                    items: buildDropdownItems()
                        .map<DropdownMenuItem<ClassCell>>((ClassCell c) {
                      return DropdownMenuItem<ClassCell>(
                        value: c,
                        child: Text(
                          c.name,
                          style: TextStyle(
                              color: c.customColorInt != null
                                  ? Color(c.customColorInt!)
                                  : Colors.black),
                        ),
                      );
                    }).toList(),
                    onChanged: (newClassCell) async {
                      setState(() {
                        classDropDownValue = newClassCell;
                      });
                    },
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        classDropDownValue = null;
                      });
                    },
                    icon: const Icon(Icons.close_sharp),
                  )
                ],
              ),
              Row(
                children: [
                  const Text("課題タイプ : "),
                  const Spacer(),
                  DropdownButton<int>(
                    value: taskTypeDropDownValue,
                    items: <int>[
                      TaskType.TASK,
                      TaskType.TEST,
                      TaskType.SURVEY,
                      TaskType.OTHERS
                    ].map<DropdownMenuItem<int>>((int t) {
                      return DropdownMenuItem<int>(
                        value: t,
                        child: Text(TASK_TYPE_MAP[t]!),
                      );
                    }).toList(),
                    onChanged: (i) async {
                      setState(() {
                        taskTypeDropDownValue = i ?? TaskType.OTHERS;
                      });
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  const Text("締め切り日時 : "),
                  const Spacer(),
                  Text(
                    selectedDate != null
                        ? timeToString(selectedDate!.millisecondsSinceEpoch)
                        : "",
                  ),
                  IconButton(
                    icon: const Icon(Icons.access_time),
                    onPressed: () async {
                      DatePicker.showDateTimePicker(
                        context,
                        showTitleActions: true,
                        theme: const DatePickerTheme(
                          backgroundColor: Colors.blue,
                          itemStyle: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          doneStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        onChanged: (date) {
                          setState(() {
                            selectedDate = date;
                          });
                        },
                        currentTime: selectedDate ?? DateTime.now(),
                        locale: LocaleType.jp,
                      );
                    },
                  ),
                ],
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context, null);
                },
                child: const Text("キャンセル"),
              ),
              TextButton(
                onPressed: () async {
                  if (title == "") {
                    Fluttertoast.showToast(msg: "課題タイトルを入力してください");
                    return;
                  }
                  if (selectedDate == null) {
                    Fluttertoast.showToast(msg: "締め切り日時を入力してください");
                    return;
                  }
                  if (selectedDate!.millisecondsSinceEpoch <
                      DateTime.now().millisecondsSinceEpoch) {
                    Fluttertoast.showToast(msg: "今よりの先の時刻を選択してください");
                    return;
                  }

                  var newTask = Task(
                    title,
                    classDropDownValue?.name ?? "",
                    taskTypeDropDownValue,
                    selectedDate!.millisecondsSinceEpoch,
                    classDropDownValue?.url ?? "",
                    "usertask-${DateTime.now().millisecondsSinceEpoch.hashCode}",
                    classDropDownValue?.classId ?? "null",
                    classDropDownValue?.customColorInt,
                    true,
                  );

                  var db = await AppDatabase.getDatabase();
                  await db.currentTaskDao.insertTask(newTask);
                  Navigator.pop(context, newTask);
                },
                child: const Text("追加"),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<ClassCell> buildDropdownItems() {
    List<ClassCell> result = [];
    for (int r = 0; r < timetable.length; r++) {
      for (int c = 0; c < timetable[0].length; c++) {
        if (timetable[r][c] != null && !result.contains(timetable[r][c])) {
          result.add(timetable[r][c]!);
        }
      }
    }
    return result;
  }
}
