import 'package:flutter/material.dart';

import '../../common/db/class_cell.dart';
import 'color_picker_dialog.dart';

class ClassDetailDialog extends StatelessWidget {
  ClassDetailDialog(this.classCell, {Key? key}) : super(key: key);

  late ClassCell classCell;
  int? selectedColor;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(classCell.name),
      children: [
        TextButton(
          onPressed: () async {
            selectedColor = await showDialog<int>(
              context: context,
              builder: (builder) {
                return ColorPickerDialog();
              },
            );
          },
          child: const Text("color picker"),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, selectedColor);
          },
          child: const Text("閉じる"),
        ),
      ],
    );
  }
}
