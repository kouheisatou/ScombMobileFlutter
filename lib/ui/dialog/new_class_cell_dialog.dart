import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scomb_mobile/common/db/scomb_mobile_database.dart';

import '../../common/db/class_cell.dart';
import '../../common/timetable_model.dart';
import 'color_picker_dialog.dart';

class NewClassCellDialog extends StatefulWidget {
  NewClassCellDialog(this.row, this.col, this.currentTimetable,
      {super.key, ClassCell? editingClassCell}) {
    if (editingClassCell == null) {
      this.editingClassCell = ClassCell(
        "",
        "",
        "",
        "",
        col,
        row,
        0,
        currentTimetable.title,
        null,
        null,
        0,
        0,
        null,
        "",
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
      title: widget.isNew ? const Text("新規授業作成") : const Text("授業詳細編集"),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, null);
          },
          child: const Text("キャンセル"),
        ),
        TextButton(
          onPressed: () {
            // title check
            if (widget.editingClassCell.name == "") {
              Fluttertoast.showToast(msg: "タイトルを入力してください");
              return;
            }

            insertClassCell();

            // close dialog
            Navigator.pop(context, widget.editingClassCell);
          },
          child: widget.isNew ? const Text("作成") : const Text("更新"),
        ),
      ],
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: "授業名*"),
              initialValue: widget.editingClassCell.name,
              onChanged: (text) {
                widget.editingClassCell.name = text;
                widget.editingClassCell.classId = "userClass.$text";
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
              height: 20,
              color: Colors.transparent,
            ),
            Row(
              children: [
                const Text("色設定 : "),
                const Spacer(),
                InkResponse(
                  onTap: () async {
                    widget.editingClassCell.customColorInt =
                        await showDialog<int>(
                      context: context,
                      builder: (builder) {
                        return ColorPickerDialog();
                      },
                    );
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
                        color: widget.editingClassCell.customColorInt != null
                            ? Color(widget.editingClassCell.customColorInt!)
                            : Colors.white70,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> insertClassCell() async {
    var db = await AppDatabase.getDatabase();
    db.currentClassCellDao.insertClassCell(widget.editingClassCell);
  }
}
