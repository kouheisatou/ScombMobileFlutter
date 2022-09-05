import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scomb_mobile/common/db/scomb_mobile_database.dart';
import 'package:scomb_mobile/common/db/setting_entity.dart';
import 'package:scomb_mobile/common/shared_resource.dart';
import 'package:scomb_mobile/common/utils.dart';
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
    return AlertDialog(
      title: Center(
        child: Column(
          children: [
            Text(
              widget.classCell.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Divider(
              height: 8,
              color: Colors.transparent,
            ),
            Text(
              "${PERIOD_MAP[widget.classCell.period]}  ${PERIOD_TIME_MAP[widget.classCell.period]}",
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
      contentTextStyle: const TextStyle(
          fontSize: 14, color: Colors.black, fontWeight: FontWeight.normal),
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
                InkResponse(
                  onTap: () async {
                    widget.selectedColor = await showDialog<int>(
                      context: context,
                      builder: (builder) {
                        return ColorPickerDialog();
                      },
                    );
                    setState(() {});
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            spreadRadius: 1,
                            blurRadius: 5,
                          )
                        ],
                        color: widget.selectedColor != null
                            ? Color(widget.selectedColor!)
                            : Colors.white70,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(
              height: 20,
              color: Colors.transparent,
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: widget.classCell.note == ""
                        ? const Text("メモ")
                        : Text(
                            widget.classCell.note ?? "メモ",
                          ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: InkResponse(
                    onTap: () async {
                      showDialog(
                        context: context,
                        builder: (_) {
                          return AlertDialog(
                            title: const Text("メモ"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text("閉じる"),
                              )
                            ],
                            content: TextFormField(
                              autofocus: true,
                              initialValue: widget.classCell.note,
                              maxLines: null,
                              onChanged: (text) async {
                                setState(() {
                                  widget.classCell.setNoteText(text);
                                });
                              },
                            ),
                          );
                        },
                      );
                    },
                    child: const Icon(
                      Icons.edit,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(
              height: 40,
              color: Colors.transparent,
            ),
            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (builder) {
                      return SinglePageScomb(
                        Uri.parse(widget.classCell.url),
                        widget.classCell.name,
                      );
                    },
                    fullscreenDialog: true,
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text("授業ページを開く "),
                  Spacer(),
                  Icon(
                    Icons.keyboard_arrow_right,
                    size: 16,
                  )
                ],
              ),
            ),
            OutlinedButton(
              onPressed: () async {
                var db = await AppDatabase.getDatabase();

                String syllabusUrl = "";

                if (widget.classCell.syllabusUrl != null &&
                    widget.classCell.syllabusUrl != "") {
                  syllabusUrl = widget.classCell.syllabusUrl!;
                } else {
                  var section = (await db.currentSettingDao
                          .getSetting(SettingKeys.Section))
                      ?.settingValue;
                  if (section == null) {
                    Fluttertoast.showToast(msg: "設定で学部を設定してください");
                  }

                  // encode url query
                  var queryString = await convertUrlQueryString(
                    widget.classCell.name,
                    encode: "EUC-JP",
                  );

                  syllabusUrl = SYLLABUS_SEARCH_URL
                      .replaceFirst("\${className}", queryString)
                      .replaceFirst("\${admissionYearAndSection}",
                          "$timetableYear%2F$section");

                  print(syllabusUrl);
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (builder) {
                      return SinglePageScomb(
                        Uri.parse(syllabusUrl),
                        "${widget.classCell.name} - シラバス",
                        javascript: "document.getElementById('hit_1').click();",
                      );
                    },
                    fullscreenDialog: true,
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text("シラバスを表示 "),
                  Spacer(),
                  Icon(
                    Icons.keyboard_arrow_right,
                    size: 16,
                  )
                ],
              ),
            ),
            InkWell(
              onTap: () async {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("シラバスのURL設定"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                              "授業名で自動検索しているため、異なるシラバスが開かれる場合があります。\n\n正しいシラバスのリンクを入力してください。"),
                          TextFormField(
                            initialValue: widget.classCell.syllabusUrl,
                            onChanged: (text) {
                              widget.classCell.setCustomSyllabusUrl(text);
                            },
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("閉じる"),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Container(
                width: double.infinity,
                alignment: Alignment.centerRight,
                child: const Text(
                  "違う授業のシラバスが開かれたら...",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
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
