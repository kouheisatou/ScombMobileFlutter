import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scomb_mobile/common/values.dart';
import 'package:scomb_mobile/ui/screen/single_page_scomb.dart';

import '../../common/db/class_cell.dart';
import 'color_picker_dialog.dart';

class ClassDetailDialog extends StatefulWidget {
  ClassDetailDialog(this.classCell, {Key? key}) : super(key: key) {
    selectedColor = classCell.customColorInt;
  }

  late ClassCell classCell;
  late int? selectedColor;

  @override
  State<ClassDetailDialog> createState() => _ClassDetailDialogState();
}

class _ClassDetailDialogState extends State<ClassDetailDialog> {
  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Center(
        child: Text(
          widget.classCell.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      children: [
        Center(
          child: Text(
            "${PERIOD_MAP[widget.classCell.period]}  ${PERIOD_TIME_MAP[widget.classCell.period]}",
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Divider(
                height: 10,
                color: Colors.transparent,
              ),
              Row(
                children: [
                  const Text("科目ID : "),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SinglePageScomb(
                              "$CLASS_PAGE_URL?idnumber=${widget.classCell.classId}",
                              widget.classCell.name,
                            ),
                            fullscreenDialog: true,
                          ),
                        );
                      },
                      child: Text(
                        widget.classCell.classId,
                        textAlign: TextAlign.right,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  )
                ],
              ),
              const Divider(
                height: 20,
                color: Colors.transparent,
              ),
              buildClassDetailRow(
                "教室 : ",
                widget.classCell.room,
                (value) {
                  Fluttertoast.showToast(msg: value);
                },
              ),
              const Divider(
                height: 20,
                color: Colors.transparent,
              ),
              buildClassDetailRow(
                "教員 : ",
                widget.classCell.teachers,
                (value) {
                  Fluttertoast.showToast(msg: value);
                },
              ),
              const Divider(
                height: 20,
                color: Colors.transparent,
              ),
              Row(
                children: [
                  const Text("色設定 : "),
                  const Spacer(),
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: widget.selectedColor != null
                            ? Color(widget.selectedColor!)
                            : Colors.white70,
                        onPrimary: Colors.black,
                        shape: const CircleBorder(),
                      ),
                      onPressed: () async {
                        widget.selectedColor = await showDialog<int>(
                          context: context,
                          builder: (builder) {
                            return ColorPickerDialog();
                          },
                        );
                        setState(() {});
                      },
                      child: const Text(""),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.pop(context, widget.selectedColor);
              },
              child: const Text("閉じる"),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildClassDetailRow(
      String title, String value, void Function(String value) onTap) {
    return Row(
      children: [
        Text(title),
        Expanded(
          child: GestureDetector(
            onTap: () {
              onTap(value);
            },
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        )
      ],
    );
  }
}