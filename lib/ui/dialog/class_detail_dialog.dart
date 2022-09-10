import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scomb_mobile/common/db/scomb_mobile_database.dart';
import 'package:scomb_mobile/common/db/setting_entity.dart';
import 'package:scomb_mobile/common/scraping/syllabus_scraping.dart';
import 'package:scomb_mobile/common/shared_resource.dart';
import 'package:scomb_mobile/common/utils.dart';
import 'package:scomb_mobile/common/values.dart';
import 'package:scomb_mobile/ui/dialog/selector_dialog.dart';
import 'package:scomb_mobile/ui/screen/single_page_scomb.dart';

import '../../common/db/class_cell.dart';

class ClassDetailDialog extends StatefulWidget {
  ClassDetailDialog(this.classCell, {Key? key}) : super(key: key);

  late ClassCell classCell;

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
              widget.classCell.name ?? "",
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
              widget.classCell.room ?? "",
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
              widget.classCell.teachers ?? "",
              (value) {
                Fluttertoast.showToast(msg: value);
              },
            ),
            Visibility(
              visible: widget.classCell.numberOfCredit != null,
              child: const Divider(
                height: 20,
                color: Colors.transparent,
              ),
            ),
            Visibility(
              visible: widget.classCell.numberOfCredit != null,
              child: buildClassDetailRow(
                "単位数 : ",
                (widget.classCell.numberOfCredit ?? 0).toString(),
                (value) {
                  Fluttertoast.showToast(msg: value);
                },
              ),
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
                    await widget.classCell.showColorPickerDialog(context);
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
                        color: widget.classCell.customColorInt != null
                            ? Color(widget.classCell.customColorInt!)
                            : Colors.white70,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(
              height: 15,
              color: Colors.transparent,
            ),
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: Text(
                              widget.classCell.note ?? "",
                            ),
                          ),
                          InkResponse(
                            onTap: () async {
                              await widget.classCell
                                  .showNoteEditDialog(context);
                              setState(() {});
                            },
                            child: const Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: Icon(
                                Icons.edit,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: const Alignment(-0.85, 0),
                  child: Container(
                    color: Colors.white,
                    child: const Padding(
                      padding: EdgeInsets.only(right: 5, left: 5),
                      child: Text(
                        "メモ",
                        style: TextStyle(color: Colors.grey),
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
            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (builder) {
                      return SinglePageScomb(
                        Uri.parse(widget.classCell.url ?? ""),
                        widget.classCell.name ?? "",
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
                var syllabusUrl = "";

                if (widget.classCell.syllabusUrl == null ||
                    widget.classCell.syllabusUrl == "") {
                  // recover section setting from db
                  var section = (await db.currentSettingDao
                          .getSetting(SettingKeys.Section))
                      ?.settingValue;
                  if (section == null) {
                    Fluttertoast.showToast(msg: "設定で学部を設定してください");
                  }

                  // encode url query
                  var queryString = await convertUrlQueryString(
                    widget.classCell.name?.replaceAll(RegExp("[１-９Ａ-Ｚ]"), "") ??
                        "",
                    encode: "EUC-JP",
                  );

                  // construct syllabus url
                  var syllabusResultUrl = SYLLABUS_SEARCH_URL
                      .replaceFirst("\${className}", queryString)
                      .replaceFirst("\${admissionYearAndSection}",
                          "$timetableYear%2F$section");

                  // syllabus search result
                  var results = await fetchAllSyllabusSearchResult(
                    syllabusResultUrl,
                  );
                  results["[ URLを直接入力する ]"] = "";

                  // select same name class
                  bool noMatch = true;
                  results.forEach((key, value) {
                    if (key == widget.classCell.name) {
                      syllabusUrl = value;
                      noMatch = false;
                    }
                  });

                  // no matched name
                  if (noMatch) {
                    String? selection = await showDialog(
                      context: context,
                      builder: (_) {
                        return SelectorDialog<String>(
                          results,
                          (key, value) async {},
                          description:
                              "授業名にマッチするシラバスが見つかりませんでした。\n\n下の選択肢から正しいシラバスを選択してください。",
                        );
                      },
                    );
                    if (selection == null) {
                      return;
                    } else if (selection == "[ URLを直接入力する ]") {
                      String? customUrl =
                          await showSyllabusUrlCustomizeDialog();
                      if (customUrl == null || customUrl == "") {
                        return;
                      } else {
                        syllabusUrl = customUrl;
                      }
                    } else {
                      syllabusUrl = results[selection] ?? "";
                    }
                  }
                  widget.classCell.setCustomSyllabusUrl(syllabusUrl);
                } else {
                  syllabusUrl = widget.classCell.syllabusUrl!;
                }

                // transition
                try {
                  var uri = Uri.parse(syllabusUrl);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (builder) {
                        return SinglePageScomb(
                          uri,
                          "${widget.classCell.name} - シラバス",
                        );
                      },
                      fullscreenDialog: true,
                    ),
                  );
                } catch (e) {
                  Fluttertoast.showToast(
                    msg: "無効なURL\nURLに日本語が含まれています",
                  );
                }
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
            Container(
              width: double.infinity,
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: () {
                  showSyllabusUrlCustomizeDialog();
                },
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
            Navigator.pop(context);
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

  Future<String?> showSyllabusUrlCustomizeDialog() async {
    var controller = TextEditingController(text: widget.classCell.syllabusUrl);
    return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("シラバスのURL設定"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                  "大学のシラバス検索システムで授業名を自動検索しているため、異なるシラバスが開かれる場合があります。\n\n正しいシラバスのリンクを入力してください。"),
              Row(
                children: [
                  Flexible(
                    child: TextFormField(
                      controller: controller,
                      onChanged: (text) async {
                        await widget.classCell.setCustomSyllabusUrl(text);
                      },
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      controller.text = "";
                      await widget.classCell.setCustomSyllabusUrl("");
                    },
                    icon: const Icon(Icons.close),
                  )
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, controller.text);
              },
              child: const Text("閉じる"),
            ),
          ],
        );
      },
    );
  }
}
