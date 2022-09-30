import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scomb_mobile/common/utils.dart';
import 'package:scomb_mobile/common/values.dart';

import '../../common/db/class_cell.dart';
import '../../common/db/task.dart';
import '../../common/shared_resource.dart';

class AddTaskDialog extends StatefulWidget {
  AddTaskDialog(this.initDate, this.initRelatedClass, {Key? key})
      : super(key: key);

  late DateTime? initDate;
  late ClassCell? initRelatedClass;

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  DateTime? selectedDate;
  String title = "";
  ClassCell? classDropDownValue;
  int taskTypeDropDownValue = TaskType.OTHERS;

  @override
  void initState() {
    if (widget.initDate != null) {
      selectedDate = DateTime(widget.initDate!.year, widget.initDate!.month,
          widget.initDate!.day, 23, 59, 0, 0, 0);
    }
    classDropDownValue = widget.initRelatedClass;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("課題追加"),
      actions: [
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

            var newTask = Task.userTask(
              title,
              classDropDownValue,
              taskTypeDropDownValue,
              selectedDate!.millisecondsSinceEpoch,
            );

            Navigator.pop(context, newTask);
          },
          child: const Text("追加"),
        ),
      ],
      content: Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: "課題タイトル"),
                onChanged: (text) {
                  title = text;
                },
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("授業 : "),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          DropdownButton<ClassCell?>(
                            value: classDropDownValue,
                            items: buildDropdownItems(),
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
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("課題タイプ : "),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
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
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("締め切り日時 : "),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Text(
                            selectedDate != null
                                ? timeToString(
                                    selectedDate!.millisecondsSinceEpoch)
                                : "選択されていません",
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
                                  if (date.millisecondsSinceEpoch <
                                      DateTime.now().millisecondsSinceEpoch) {
                                    Fluttertoast.showToast(
                                        msg: "現在よりも前の日付は指定できません");
                                  } else {
                                    setState(() {
                                      selectedDate = date;
                                    });
                                  }
                                },
                                currentTime: selectedDate ??
                                    (widget.initDate ?? DateTime.now()),
                                locale: LocaleType.jp,
                              );
                            },
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<DropdownMenuItem<ClassCell?>>? buildDropdownItems() {
    List<ClassCell> allClasses = [];
    sharedTimetable.applyToAllCells((classCell) {
      if (classCell != null && !allClasses.contains(classCell)) {
        allClasses.add(classCell);
      }
    });

    List<DropdownMenuItem<ClassCell?>> result = [];

    result.add(const DropdownMenuItem(
      value: null,
      child: Text("選択なし"),
    ));
    for (var c in allClasses) {
      result.add(
        DropdownMenuItem(
          value: c,
          child: Text(
            c.name ?? "",
            style: TextStyle(
                color: c.customColorInt != null
                    ? Color(c.customColorInt!)
                    : Colors.black),
          ),
        ),
      );
    }

    return result;
  }
}
