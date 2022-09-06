import 'package:flutter/material.dart';

import '../../common/db/class_cell.dart';

class NewClassCellDialog extends StatelessWidget {
  NewClassCellDialog(this.row, this.col, String timetableTitle,
      {super.key, ClassCell? editingClassCell}) {
    if (editingClassCell == null) {
      this.editingClassCell = ClassCell(
        "user-${DateTime.now().millisecondsSinceEpoch}",
        "",
        "",
        "",
        col,
        row,
        0,
        timetableTitle,
        null,
        null,
        0,
        0,
        null,
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: isNew ? const Text("新規授業作成") : const Text("授業詳細編集"),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, null);
          },
          child: const Text("キャンセル"),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, editingClassCell);
          },
          child: isNew ? const Text("作成") : const Text("更新"),
        ),
      ],
      content: SingleChildScrollView(
        child: Column(
          children: [],
        ),
      ),
    );
  }
}
