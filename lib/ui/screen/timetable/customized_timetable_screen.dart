import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scomb_mobile/ui/component/timetable.dart';

import '../../../common/db/class_cell.dart';

class CustomizedTimetableScreen extends StatefulWidget {
  CustomizedTimetableScreen(this.title, this.timetable,
      {super.key, required this.isEditMode});

  String title;
  List<List<ClassCell?>> timetable;
  bool isEditMode = false;

  @override
  State<CustomizedTimetableScreen> createState() =>
      _CustomizedTimetableScreenState();
}

class _CustomizedTimetableScreenState extends State<CustomizedTimetableScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                widget.isEditMode = !widget.isEditMode;
              });
            },
            icon: Icon(Icons.edit,
                color: widget.isEditMode ? Colors.red : Colors.grey),
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
}
