import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scomb_mobile/common/values.dart';
import 'package:scomb_mobile/ui/screen/single_page_scomb.dart';

import '../../common/db/class_cell_dao.dart';
import '../../common/timetable_model.dart';
import '../dialog/selector_dialog.dart';
import '../dialog/syllabus_search_dialog.dart';

class ClassSearchScreen extends StatefulWidget {
  @override
  State<ClassSearchScreen> createState() => _ClassSearchScreenState();
}

class _ClassSearchScreenState extends State<ClassSearchScreen> {
  var syllabusSearchStringTextFieldController = TextEditingController();
  final focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        focusNode.requestFocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text("授業検索"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Focus(
                      focusNode: focusNode,
                      child: TextFormField(
                        controller: syllabusSearchStringTextFieldController,
                      ),
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () async {
                      var syllabusUrl = await showSyllabusSearchResultDialog(
                        context,
                        syllabusSearchStringTextFieldController.text,
                        null,
                      );
                      if (syllabusUrl == "" || syllabusUrl == null) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (buildContext) {
                            return SinglePageScomb(
                              Uri.parse(syllabusUrl),
                              syllabusSearchStringTextFieldController.text,
                            );
                          },
                        ),
                      );
                      focusNode.requestFocus();
                    },
                    child: const Text("シラバス検索"),
                  ),
                ],
              ),
              OutlinedButton(
                onPressed: () async {
                  // get all timetables
                  Map<String, TimetableModel?> allTimetables =
                      await getAllTimetables(
                    onFetchFinished: (_) {},
                  );

                  // show timetable selection dialog
                  var selectedTimetableTitle = await showDialog(
                    context: context,
                    builder: (_) {
                      return SelectorDialog<TimetableModel?>(
                        allTimetables,
                        (key, value) async {},
                        description: "追加先の時間割を選択してください",
                      );
                    },
                  );
                  if (selectedTimetableTitle == null ||
                      allTimetables[selectedTimetableTitle] == null) {
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      fullscreenDialog: true,
                      builder: (buildContext) {
                        return SinglePageScomb(
                          Uri.parse(TIMETABLE_PAGE_URL
                              .replaceAll("\${yearCode}", "2022")
                              .replaceAll("\${sectionCode}", "1")
                              .replaceAll("\${departmentCode}", "F")
                              .replaceAll("\${termCode}", "2")
                              .replaceAll("\${gradeCode}", "3")),
                          "時間割検索",
                          shouldShowAddNewClassButton: true,
                          timetable: allTimetables[selectedTimetableTitle]!,
                        );
                      },
                    ),
                  );
                },
                child: const Text("時間割ページを表示"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
