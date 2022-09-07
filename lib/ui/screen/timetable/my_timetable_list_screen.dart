import 'package:flutter/material.dart';
import 'package:scomb_mobile/common/db/scomb_mobile_database.dart';
import 'package:scomb_mobile/common/timetable_model.dart';
import 'package:scomb_mobile/ui/component/timetable_component.dart';

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
    getAllTimetables();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("マイ時間割"),
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
                          Navigator.pop(context, controller.text);
                          controller.text = "";
                        },
                        child: const Text("作成"),
                      ),
                    ],
                  );
                },
              );

              if (newTimetableTitle == null) return;

              var newTimetable = TimetableModel(newTimetableTitle, true);
              (await AppDatabase.getDatabase())
                  .currentClassCellDao
                  .insertClassCell(newTimetable.header);

              setState(() {
                timetables[newTimetableTitle] = newTimetable;
              });

              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (builder) {
                    return CustomizedTimetableScreen(
                      newTimetable,
                      isEditMode: true,
                    );
                  },
                ),
              );

              setState(() {});
            },
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body: GridView.builder(
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        itemCount: timetables.length,
        itemBuilder: (context, index) {
          var currentTimetable = timetables.entries.elementAt(index).value;
          return Padding(
            padding: const EdgeInsets.all(3.0),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
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
                    ),
                  ),
                  Center(child: Text(currentTimetable.title)),
                  InkWell(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (builder) {
                            return CustomizedTimetableScreen(
                              currentTimetable,
                              isEditMode: false,
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
                                    await currentTimetable.removeAllCell();
                                    setState(() {
                                      timetables.remove(currentTimetable.title);
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
      ),
    );
  }

  Future<void> getAllTimetables() async {
    var db = await AppDatabase.getDatabase();
    var allCells = await db.currentClassCellDao.getAllClasses();

    for (var cell in allCells) {
      // if my timetable, year is 0
      if (cell.isUserClassCell) {
        if (timetables[cell.timetableTitle] == null) {
          timetables[cell.timetableTitle] = TimetableModel(
            cell.timetableTitle,
            true,
          );
        }
        if (cell.period >= 0 && cell.dayOfWeek >= 0) {
          timetables[cell.timetableTitle]!.timetable[cell.period]
              [cell.dayOfWeek] = cell;
        }
      }
    }

    timetables.forEach((key, value) {
      print(value);
    });

    setState(() {});
  }
}
