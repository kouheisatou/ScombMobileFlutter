import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scomb_mobile/common/timetable_model.dart';
import 'package:scomb_mobile/ui/component/timetable_component.dart';

class CustomizedTimetableScreen extends StatefulWidget {
  CustomizedTimetableScreen(this.timetable,
      {super.key, required this.isEditMode});

  TimetableModel timetable;
  bool isEditMode = false;

  @override
  State<CustomizedTimetableScreen> createState() =>
      _CustomizedTimetableScreenState();
}

class _CustomizedTimetableScreenState extends State<CustomizedTimetableScreen> {
  @override
  void initState() {
    showModeToast();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.timetable.title + (widget.isEditMode ? "（編集中）" : ""),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                widget.isEditMode = !widget.isEditMode;
              });
              showModeToast();
            },
            icon: Icon(
              Icons.edit,
              color: widget.isEditMode ? Colors.amber.shade100 : Colors.white,
            ),
          ),
        ],
      ),
      body: TimetableComponent(
        widget.timetable,
        true,
        isEditMode: widget.isEditMode,
      ),
    );
  }

  void showModeToast() {
    if (widget.isEditMode) {
      Fluttertoast.showToast(
        msg: "[編集モード]\n画面をタップして授業を追加\n長押しで削除",
      );
    } else {
      Fluttertoast.showToast(
        msg: "[表示モード]",
      );
    }
  }
}
