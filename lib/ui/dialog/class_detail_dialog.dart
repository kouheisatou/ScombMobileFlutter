import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scomb_mobile/common/values.dart';
import 'package:url_launcher/url_launcher.dart';

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
    return AlertDialog(
      title: Center(
        child: Column(
          children: [
            Text(
              widget.classCell.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Divider(
              height: 10,
              color: Colors.transparent,
            ),
            Text(
              "${PERIOD_MAP[widget.classCell.period]}  ${PERIOD_TIME_MAP[widget.classCell.period]}",
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
            ),
          ],
        ),
      ),
      contentTextStyle: const TextStyle(
          fontSize: 12, color: Colors.black, fontWeight: FontWeight.normal),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
            const Divider(
              height: 20,
              color: Colors.transparent,
            ),
            InkWell(
              onTap: () async {
                if (await canLaunchUrl(Uri.parse(widget.classCell.url))) {
                  await launchUrl(
                    Uri.parse(widget.classCell.url),
                    mode: LaunchMode.externalApplication,
                  );
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    "授業ページを開く ",
                    style: TextStyle(color: Colors.blue),
                  ),
                  Icon(
                    Icons.open_in_new,
                    color: Colors.blue,
                    size: 16,
                  )
                ],
              ),
            ),
            const Divider(
              height: 10,
              color: Colors.transparent,
            ),
            InkWell(
              onTap: () async {
                if (await canLaunchUrl(Uri.parse(widget.classCell.url))) {
                  await launchUrl(
                    Uri.parse(widget.classCell.url),
                    mode: LaunchMode.externalApplication,
                  );
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    "シラバスを表示 ",
                    style: TextStyle(color: Colors.blue),
                  ),
                  Icon(
                    Icons.open_in_new,
                    color: Colors.blue,
                    size: 16,
                  )
                ],
              ),
            ),
            const Divider(
              height: 20,
              color: Colors.transparent,
            ),
            TextFormField(
              initialValue: widget.classCell.note,
              maxLines: null,
              decoration: const InputDecoration(labelText: "メモ"),
              onChanged: (text) async {
                await widget.classCell.setNoteText(text);
                setState(() {});
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, widget.selectedColor);
          },
          child: const Text("閉じる"),
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
