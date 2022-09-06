import 'package:flutter/material.dart';
import 'package:scomb_mobile/common/db/class_cell.dart';
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
  List<TimetableModel> timetables = [];

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

              var newTimetable = TimetableModel.empty(newTimetableTitle);
              var sampleClassCell = ClassCell(
                "sample",
                "何もないところをタップして追加",
                "",
                "",
                3,
                3,
                0,
                newTimetableTitle,
                null,
                null,
                0,
                0,
                null,
                "",
              );
              (await AppDatabase.getDatabase())
                  .currentClassCellDao
                  .insertClassCell(sampleClassCell);
              newTimetable.timetable[3][3] = sampleClassCell;

              setState(() {
                timetables.add(newTimetable);
              });

              Navigator.push(
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
                      timetables[index],
                      true,
                      isEditMode: false,
                      shouldEmphasizeToday: false,
                    ),
                  ),
                  Center(child: Text(timetables[index].title)),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (builder) {
                            return CustomizedTimetableScreen(
                              timetables[index],
                              isEditMode: false,
                            );
                          },
                        ),
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
      if (cell.year == 0) {
        bool timetableExist = false;
        for (var timetable in timetables) {
          if (timetable.title == cell.term) {
            timetableExist = true;
            timetable.timetable[cell.period][cell.dayOfWeek] = cell;
          }
        }

        if (!timetableExist) {
          var newTimetable = TimetableModel.empty(cell.term);
          newTimetable.timetable[cell.period][cell.dayOfWeek] = cell;
          timetables.add(newTimetable);
        }
      }
    }

    setState(() {});
  }
}
