import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
      content: SingleChildScrollView(
        child: Column(
          children: [
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
                        color: widget.editingClassCell.customColorInt != null
                            ? Color(widget.editingClassCell.customColorInt!)
                            : Colors.white70,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(
              height: 15,
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
            TextFormField(
              decoration: const InputDecoration(labelText: "メモ"),
              initialValue: widget.editingClassCell.note,
              onChanged: (text) {
                widget.editingClassCell.setNoteText(text);
              },
            ),
          ],
        ),
      ),
    );
  }
}
