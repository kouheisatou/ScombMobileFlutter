import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.timetable.title),
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
