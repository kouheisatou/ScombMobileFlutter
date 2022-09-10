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
    super.initState();
    if (widget.isEditMode) {
      showModeToast();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
              color: widget.isEditMode ? Colors.amber.shade500 : Colors.white,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.blueGrey.shade50,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: buildNumberOfCreditRow()),
            ),
          ),
          Expanded(
            child: TimetableComponent(
              widget.timetable,
              true,
              isEditMode: widget.isEditMode,
              onUpdatedUi: () {
                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> buildNumberOfCreditRow() {
    List<Widget> list = [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          "計${widget.timetable.getSumOfNumberOfCredit()}単位",
          style: const TextStyle(color: Colors.black54),
        ),
      )
    ];
    widget.timetable.getColorAndCreditMap().forEach((key, value) {
      list.add(Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          "$value単位",
          style: TextStyle(
            shadows: [
              Shadow(
                blurRadius: 10,
                color:
                    (key == Colors.white70.value) ? Colors.white : Color(key),
              ),
            ],
            color: Colors.black26,
          ),
        ),
      ));
    });
    return list;
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
