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
  bool shouldShowPeriodTime;
  Function? onUpdatedUi;

  TimetableComponent(this.timetable, this.showSaturday,
      {super.key,
      required this.isEditMode,
      this.shouldEmphasizeToday = true,
      this.shouldShowCellText = true,
      this.shouldShowPeriodTime = true,
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
    for (int r = 0; r < widget.timetable.cells.length; r++) {
      tableRows.add(buildTableRow(r));
    }

    return Column(
      children: tableRows,
    );
  }

  Widget buildDayOfWeekRow() {
    List<Widget> dayOfWeekCells = [];
    // day of week row
    dayOfWeekCells.add(
      const Text(
        "00:00",
        style: TextStyle(
          color: Colors.transparent,
          fontFeatures: [FontFeature.tabularFigures()],
          fontSize: 8,
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
                      ? Theme.of(context).primaryColor.withAlpha(40)
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
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(children: dayOfWeekCells),
    );
  }

  Widget buildTableRow(int row) {
    List<Widget> tableCells = [];

    // period column
    tableCells.add(
      Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Visibility(
            visible: widget.shouldShowPeriodTime,
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                textAlign: TextAlign.center,
                PERIOD_TIME_MAP[row]?[0] ?? "",
                style: TextStyle(
                  fontFeatures: const [FontFeature.tabularFigures()],
                  fontSize: 8,
                  overflow: TextOverflow.clip,
                  color: Colors.grey.shade400,
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                textAlign: TextAlign.center,
                PERIOD_MAP[row] ?? "",
                style: const TextStyle(
                  fontFeatures: [FontFeature.tabularFigures()],
                  fontSize: 8,
                  overflow: TextOverflow.clip,
                ),
              ),
            ),
          ),
          Visibility(
            visible: widget.shouldShowPeriodTime,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                textAlign: TextAlign.center,
                PERIOD_TIME_MAP[row]?[1] ?? "",
                style: TextStyle(
                  fontFeatures: const [FontFeature.tabularFigures()],
                  fontSize: 8,
                  overflow: TextOverflow.clip,
                  color: Colors.grey.shade400,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    // main columns
    for (int c = 0; c < widget.timetable.cells[0].length; c++) {
      if (widget.showSaturday || c != 5) {
        tableCells.add(buildTableCell(row, c));
      }
    }

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        child: Row(children: tableCells),
      ),
    );
  }

  Widget buildTableCell(int row, int col) {
    return Expanded(
      child: Container(
        color:
            ((DateTime.now().weekday - 1) == col && widget.shouldEmphasizeToday)
                ? Theme.of(context).primaryColor.withAlpha(40)
                : null,
        width: double.infinity,
        height: double.infinity,
        child: widget.timetable.cells[row][col] == null
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
                    onLongPress: () async {
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
                  widget.timetable.cells[row][col]?.customColorInt ??
                      Colors.white70.value,
                ),
                onPressed: () async {
                  await widget.timetable.cells[row][col]!
                      .showClassDetailDialog(context);
                  setState(() {});
                },
                onLongPress: widget.isEditMode
                    ? () async {
                        await widget.timetable.showNewClassCellDialog(
                          row,
                          col,
                          context,
                          classCell: widget.timetable.cells[row][col]!,
                        );
                        setState(() {});
                      }
                    : () async {
                        print(widget.timetable.cells[row][col]);
                        Fluttertoast.showToast(
                          msg: widget.timetable.cells[row][col]?.room ?? "",
                        );
                      },
                child: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: buildLimitedText(
                    widget.shouldShowCellText
                        ? widget.timetable.cells[row][col]?.name ?? ""
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
