import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scomb_mobile/common/db/scomb_mobile_database.dart';
import 'package:scomb_mobile/common/timetable_model.dart';
import 'package:scomb_mobile/ui/component/timetable_component.dart';

import '../../../common/db/class_cell.dart';
import '../../../common/db/class_cell_dao.dart';
import 'customized_timetable_screen.dart';

class MyTimetableListScreen extends StatefulWidget {
  MyTimetableListScreen({super.key});

  @override
  State<MyTimetableListScreen> createState() => _MyTimetableListScreenState();
}

class _MyTimetableListScreenState extends State<MyTimetableListScreen> {
  var controller = TextEditingController();
  Map<String, TimetableModel> timetables = {};

  @override
  void initState() {
    getAllTimetables(onFetchFinished: (result) {
      setState(() {
        timetables = result;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("履修計画一覧"),
        actions: [
          IconButton(
            onPressed: () async {
              String? newTimetableTitle = await showDialog(
                context: context,
                builder: (builder) {
                  return AlertDialog(
                    title: const Text("時間割のタイトルを入力"),
                    content: TextFormField(
                      autofocus: true,
                      controller: controller,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          controller.text = "";
                        },
                        child: const Text("キャンセル"),
                      ),
                      TextButton(
                        onPressed: () {
                          if (timetables.keys.contains(controller.text)) {
                            Fluttertoast.showToast(msg: "すでに存在します");
                          } else if (controller.text == "") {
                            Fluttertoast.showToast(msg: "タイトルが入力されていません");
                          } else {
                            Navigator.pop(context, controller.text);
                            controller.text = "";
                          }
                        },
                        child: const Text("作成"),
                      ),
                    ],
                  );
                },
              );

              if (newTimetableTitle == null) return;

              var newTimetable = TimetableModel(newTimetableTitle, true);
              var timetableHeader = ClassCell(
                "$newTimetableTitle/timetable_header",
                -1,
                -1,
                true,
                newTimetableTitle,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
              );
              (await AppDatabase.getDatabase())
                  .currentClassCellDao
                  .insertClassCell(timetableHeader);

              setState(() {
                timetables[newTimetableTitle] = newTimetable;
              });

              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (builder) {
                    return CustomizedTimetableScreen(newTimetable);
                  },
                ),
              );

              setState(() {});
            },
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body: timetables.isNotEmpty
          ? GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2),
              itemCount: timetables.length,
              itemBuilder: (context, index) {
                var currentTimetable =
                    timetables.entries.elementAt(index).value;
                return Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).primaryColor),
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TimetableComponent(
                            currentTimetable,
                            true,
                            isEditMode: false,
                            shouldEmphasizeToday: false,
                            shouldShowCellText: false,
                            shouldShowPeriodTime: false,
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: Colors.white38,
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(currentTimetable.title),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                      "${currentTimetable.getSumOfNumberOfCredit()}単位"),
                                ),
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (builder) {
                                  return CustomizedTimetableScreen(
                                    currentTimetable,
                                  );
                                },
                              ),
                            );
                            setState(() {});
                          },
                          onLongPress: () {
                            showDialog(
                              context: context,
                              builder: (_) {
                                return AlertDialog(
                                  title: const Text("削除"),
                                  content: const Text("本当に削除しますか？"),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text("キャンセル")),
                                    TextButton(
                                        onPressed: () async {
                                          await (await AppDatabase
                                                  .getDatabase())
                                              .currentClassCellDao
                                              .removeTimetable(
                                                  currentTimetable.title);
                                          setState(() {
                                            timetables
                                                .remove(currentTimetable.title);
                                          });
                                          Navigator.pop(context);
                                        },
                                        child: const Text("削除")),
                                  ],
                                );
                              },
                            );
                          },
                        )
                      ],
                    ),
                  ),
                );
              },
            )
          : SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: const [
                    Padding(
                      padding: EdgeInsets.only(right: 14, bottom: 5),
                      child: Text("↑"),
                    ),
                    Text("ここから新しい時間割を追加"),
                  ],
                ),
              ),
            ),
    );
  }
}
