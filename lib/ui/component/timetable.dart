import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scomb_mobile/ui/dialog/new_class_cell_dialog.dart';

import '../../common/db/class_cell.dart';
import '../../common/values.dart';
import '../dialog/class_detail_dialog.dart';

class TimetableComponent extends StatefulWidget {
  List<List<ClassCell?>> timetable;
  bool showSaturday = true;
  bool isEditMode = false;
  String title;

  TimetableComponent(this.timetable, this.showSaturday, this.title,
      {super.key, required this.isEditMode});

  @override
  State<TimetableComponent> createState() => _TimetableComponentState();
}

class _TimetableComponentState extends State<TimetableComponent> {
  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 10, color: Colors.black),
      child: buildTable(),
    );
  }

  Widget buildTable() {
    // day of week row
    List<Widget> tableRows = [buildDayOfWeekRow()];

    // main rows
    for (int r = 0; r < widget.timetable.length; r++) {
      tableRows.add(buildTableRow(r));
    }

    return Column(
      children: tableRows,
    );
  }

  Row buildDayOfWeekRow() {
    List<Widget> dayOfWeekCells = [];
    // day of week row
    dayOfWeekCells.add(
      const Text(
        "0限",
        style: TextStyle(
          color: Colors.transparent,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
    );
    DAY_OF_WEEK_MAP.forEach(
      (key, value) {
        // skip saturday
        if (widget.showSaturday || key != 5) {
          dayOfWeekCells.add(
            Expanded(
              child: Center(
                child: Container(
                  width: double.infinity,
                  color: (DateTime.now().weekday - 1) == key
                      ? Colors.black12
                      : null,
                  child: Text(value),
                ),
              ),
            ),
          );
        }
      },
    );
    return Row(children: dayOfWeekCells);
  }

  Widget buildTableRow(int row) {
    List<Widget> tableCells = [];

    // period column
    tableCells.add(
      Center(
        child: Text(
          textAlign: TextAlign.center,
          PERIOD_MAP[row] ?? "",
          style: const TextStyle(
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
      ),
    );

    // main columns
    for (int c = 0; c < widget.timetable[0].length; c++) {
      if (widget.showSaturday || c != 5) {
        tableCells.add(buildTableCell(row, c));
      }
    }

    return Expanded(child: Row(children: tableCells));
  }

  Widget buildTableCell(int row, int col) {
    return Expanded(
      child: Container(
        color: (DateTime.now().weekday - 1) == col ? Colors.black12 : null,
        width: double.infinity,
        height: double.infinity,
        child: widget.timetable[row][col] == null
            ? widget.isEditMode
                ? MaterialButton(
                    onPressed: () async {
                      widget.timetable[row][col] = await showNewClassCellDialog(
                        row,
                        col,
                      );
                      setState(() {});
                    },
                  )
                : const Text("")
            : MaterialButton(
                color: Color(
                  widget.timetable[row][col]?.customColorInt ??
                      Colors.white70.value,
                ),
                onPressed: widget.isEditMode
                    ? () async {
                        widget.timetable[row][col] =
                            await showNewClassCellDialog(
                          row,
                          col,
                          classCell: widget.timetable[row][col]!,
                        );
                        setState(() {});
                      }
                    : () async {
                        var currentClassCell = widget.timetable[row][col]!;
                        var detailDialog = ClassDetailDialog(currentClassCell);
                        await showDialog(
                          context: context,
                          builder: (_) {
                            return detailDialog;
                          },
                        );

                        await currentClassCell
                            .setColor(detailDialog.selectedColor);
                        setState(() {});
                      },
                onLongPress: () async {
                  Fluttertoast.showToast(
                      msg: widget.timetable[row][col]?.room ?? "");
                },
                child: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: buildLimitedText(
                    widget.timetable[row][col]?.name ?? "",
                    widget.showSaturday ? 3 : 4,
                  ),
                ),
              ),
      ),
    );
  }

  Text buildLimitedText(String text, int limit) {
    String newText = "";
    int count = 0;
    int returnCount = 0;
    for (var char in text.split("")) {
      if (count % limit == 0 && count != 0) {
        if (returnCount > 5) {
          newText += "..";
          break;
        } else {
          newText += "\n$char";
          returnCount++;
        }
      } else {
        newText += char;
      }
      count++;
    }

    if (newText == "") {
      return const Text("  ");
    }

    return Text(
      newText,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
    );
  }

  Future<ClassCell?> showNewClassCellDialog(int row, int col,
      {ClassCell? classCell}) async {
    return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) {
        return NewClassCellDialog(
          row,
          col,
          widget.title,
          editingClassCell: classCell,
        );
      },
    );
  }
}

List<List<ClassCell?>> createEmptyTimetable() {
  List<List<ClassCell?>> timetable = [
    [null, null, null, null, null, null],
    [null, null, null, null, null, null],
    [null, null, null, null, null, null],
    [null, null, null, null, null, null],
    [null, null, null, null, null, null],
    [null, null, null, null, null, null],
    [null, null, null, null, null, null],
  ];
  return timetable;
}
