import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scomb_mobile/common/timetable_model.dart';

import '../../common/values.dart';

class TimetableComponent extends StatefulWidget {
  TimetableModel timetable;
  bool showSaturday = true;
  bool isEditMode = false;
  bool shouldEmphasizeToday;
  bool shouldShowCellText;
  Function? onUpdatedUi;

  TimetableComponent(this.timetable, this.showSaturday,
      {super.key,
      required this.isEditMode,
      this.shouldEmphasizeToday = true,
      this.shouldShowCellText = true,
      this.onUpdatedUi});

  @override
  State<TimetableComponent> createState() => _TimetableComponentState();
}

class _TimetableComponentState extends State<TimetableComponent> {
  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 10, color: Colors.grey),
      child: buildTable(),
    );
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    if (widget.onUpdatedUi != null) {
      widget.onUpdatedUi!();
    }
  }

  Widget buildTable() {
    // day of week row
    List<Widget> tableRows = [buildDayOfWeekRow()];

    // main rows
    for (int r = 0; r < widget.timetable.timetable.length; r++) {
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
                  color: ((DateTime.now().weekday - 1) == key &&
                          widget.shouldEmphasizeToday)
                      ? Colors.black12
                      : null,
                  child: Text(
                    value,
                    overflow: TextOverflow.clip,
                    maxLines: 1,
                  ),
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
    for (int c = 0; c < widget.timetable.timetable[0].length; c++) {
      if (widget.showSaturday || c != 5) {
        tableCells.add(buildTableCell(row, c));
      }
    }

    return Expanded(child: Row(children: tableCells));
  }

  Widget buildTableCell(int row, int col) {
    return Expanded(
      child: Container(
        color:
            ((DateTime.now().weekday - 1) == col && widget.shouldEmphasizeToday)
                ? Colors.black12
                : null,
        width: double.infinity,
        height: double.infinity,
        child: widget.timetable.timetable[row][col] == null
            ? widget.isEditMode
                ? MaterialButton(
                    onPressed: () async {
                      await widget.timetable.showNewClassCellDialog(
                        row,
                        col,
                        context,
                      );
                      setState(() {});
                    },
                  )
                : const Text("")
            : MaterialButton(
                color: Color(
                  widget.timetable.timetable[row][col]?.customColorInt ??
                      Colors.white70.value,
                ),
                onPressed: widget.isEditMode
                    ? () async {
                        await widget.timetable.showNewClassCellDialog(
                          row,
                          col,
                          context,
                          classCell: widget.timetable.timetable[row][col]!,
                        );
                        setState(() {});
                      }
                    : () async {
                        await widget.timetable.timetable[row][col]!
                            .showClassDetailDialog(context);
                        setState(() {});
                      },
                onLongPress: widget.isEditMode
                    ? () async {
                        print(widget.timetable.timetable[row][col]);
                        await widget.timetable.timetable[row][col]
                            ?.showRemoveClassDialog(context);
                        setState(() {});
                      }
                    : () async {
                        print(widget.timetable.timetable[row][col]);
                        Fluttertoast.showToast(
                          msg: widget.timetable.timetable[row][col]?.room ?? "",
                        );
                      },
                child: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: buildLimitedText(
                    widget.shouldShowCellText
                        ? widget.timetable.timetable[row][col]?.name ?? ""
                        : "",
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
}
