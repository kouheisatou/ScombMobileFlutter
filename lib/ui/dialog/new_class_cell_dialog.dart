import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scomb_mobile/common/db/scomb_mobile_database.dart';
import 'package:scomb_mobile/ui/dialog/selector_dialog.dart';

import '../../common/db/class_cell.dart';
import '../../common/timetable_model.dart';

class NewClassCellDialog extends StatefulWidget {
  NewClassCellDialog(this.row, this.col, this.currentTimetable,
      {super.key, ClassCell? editingClassCell}) {
    if (editingClassCell == null) {
      this.editingClassCell = ClassCell.user(
        "${currentTimetable.title}/user_class_cell/${DateTime.now().millisecondsSinceEpoch}",
        row,
        col,
        true,
        currentTimetable.title,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        currentTimetable,
        0,
      );
      isNew = true;
    } else {
      this.editingClassCell = editingClassCell;
      isNew = false;
    }
  }

  int row;
  int col;
  late bool isNew;
  late ClassCell editingClassCell;
  late TimetableModel currentTimetable;

  @override
  State<NewClassCellDialog> createState() => _NewClassCellDialogState();
}

class _NewClassCellDialogState extends State<NewClassCellDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: widget.isNew
          ? const Text("新規授業作成")
          : Row(
              children: [
                const Text("授業詳細編集"),
                const Spacer(),
                IconButton(
                  onPressed: () async {
                    await widget.editingClassCell
                        .showRemoveClassDialog(context);
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.delete),
                )
              ],
            ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("キャンセル"),
        ),
        TextButton(
          onPressed: () {
            if (widget.editingClassCell.name == "" ||
                widget.editingClassCell.name == null) {
              Fluttertoast.showToast(msg: "授業名が入力されていません");
            } else {
              Navigator.pop(context, widget.editingClassCell);
            }
          },
          child: widget.isNew ? const Text("作成") : const Text("更新"),
        ),
      ],
      contentPadding: EdgeInsets.zero,
      content: Scrollbar(
        thumbVisibility: true,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                OutlinedButton(
                  onPressed: () async {
                    var selectionMap = await buildClassSelectionMap();

                    await showDialog(
                      context: context,
                      builder: (_) {
                        return SelectorDialog<ClassCell?>(
                          selectionMap,
                          (_, copyOriginalCell) async {
                            // copy from other class
                            if (copyOriginalCell != null) {
                              setState(() {
                                widget.editingClassCell.classId =
                                    copyOriginalCell.classId;
                                widget.editingClassCell.name =
                                    copyOriginalCell.name;
                                widget.editingClassCell.teachers =
                                    copyOriginalCell.teachers;
                                widget.editingClassCell.room =
                                    copyOriginalCell.room;
                                widget.editingClassCell.customColorInt =
                                    copyOriginalCell.customColorInt;
                                widget.editingClassCell.url =
                                    copyOriginalCell.url;
                                widget.editingClassCell.note =
                                    copyOriginalCell.note;
                                widget.editingClassCell.syllabusUrl =
                                    copyOriginalCell.syllabusUrl;
                              });
                              Navigator.pop(context, widget.editingClassCell);
                            }
                          },
                        );
                      },
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text("他の授業からコピー "),
                      Spacer(),
                      Icon(
                        Icons.keyboard_arrow_right,
                        size: 16,
                      )
                    ],
                  ),
                ),
                const Divider(
                  height: 20,
                  color: Colors.transparent,
                ),
                Row(
                  children: [
                    const Text("色設定 : "),
                    const Spacer(),
                    InkResponse(
                      onTap: () async {
                        await widget.editingClassCell
                            .showColorPickerDialog(context);
                        setState(() {});
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                spreadRadius: 1,
                                blurRadius: 5,
                              )
                            ],
                            color: widget.editingClassCell.customColorInt !=
                                    null
                                ? Color(widget.editingClassCell.customColorInt!)
                                : Colors.white70,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(
                  height: 14,
                  color: Colors.transparent,
                ),
                TextFormField(
                  autofocus: true,
                  decoration: const InputDecoration(labelText: "授業名*"),
                  initialValue: widget.editingClassCell.name,
                  onChanged: (text) {
                    widget.editingClassCell.name = text;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: "教室"),
                  initialValue: widget.editingClassCell.room,
                  onChanged: (text) {
                    widget.editingClassCell.room = text;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: "授業URL"),
                  initialValue: widget.editingClassCell.url,
                  onChanged: (text) {
                    widget.editingClassCell.url = text;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: "教員"),
                  initialValue: widget.editingClassCell.teachers,
                  onChanged: (text) {
                    widget.editingClassCell.teachers = text;
                  },
                ),
                const Divider(
                  height: 10,
                  color: Colors.transparent,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text(
                      "単位数 : ",
                      style: TextStyle(color: Colors.black54),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () async {
                        var db = await AppDatabase.getDatabase();
                        widget.editingClassCell.numberOfCredit ??= 0;
                        if (widget.editingClassCell.numberOfCredit! > 0) {
                          widget.editingClassCell.numberOfCredit =
                              widget.editingClassCell.numberOfCredit! - 1;
                          await db.currentClassCellDao
                              .insertClassCell(widget.editingClassCell);
                          setState(() {});
                        }
                      },
                      icon: const Text(
                        "<",
                        style: TextStyle(color: Colors.blueGrey),
                      ),
                    ),
                    Text(
                      (widget.editingClassCell.numberOfCredit ?? 0).toString(),
                    ),
                    IconButton(
                      onPressed: () async {
                        var db = await AppDatabase.getDatabase();
                        widget.editingClassCell.numberOfCredit ??= 0;
                        widget.editingClassCell.numberOfCredit =
                            widget.editingClassCell.numberOfCredit! + 1;
                        await db.currentClassCellDao
                            .insertClassCell(widget.editingClassCell);
                        setState(() {});
                      },
                      icon: const Text(
                        ">",
                        style: TextStyle(color: Colors.blueGrey),
                      ),
                    ),
                  ],
                ),
                const Divider(
                  height: 10,
                  color: Colors.transparent,
                ),
                Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Expanded(
                                child: Text(
                                  widget.editingClassCell.note ?? "",
                                ),
                              ),
                              InkResponse(
                                onTap: () async {
                                  await widget.editingClassCell
                                      .showNoteEditDialog(context);
                                  setState(() {});
                                },
                                child: const Padding(
                                  padding: EdgeInsets.only(left: 10),
                                  child: Icon(
                                    Icons.edit,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: const Alignment(-0.85, 0),
                      child: Container(
                        color: Colors.white,
                        child: const Padding(
                          padding: EdgeInsets.only(right: 5, left: 5),
                          child: Text(
                            "メモ",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<Map<String, ClassCell>> buildClassSelectionMap() async {
    Map<String, ClassCell> result = {};
    var db = await AppDatabase.getDatabase();
    var allCells = await db.currentClassCellDao.getAllClasses();
    for (var cell in allCells) {
      if (cell.name != null) {
        result[cell.name!] = cell;
      }
    }
    return result;
  }
}
