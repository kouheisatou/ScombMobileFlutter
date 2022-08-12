import 'package:flutter/material.dart';
import 'package:scomb_mobile/common/shared_resource.dart';
import 'package:scomb_mobile/ui/screen/task_list_screen.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../common/db/task.dart';

class TaskCalendarScreen extends TaskListScreen {
  TaskCalendarScreen(super.parent, super.title, {Key? key}) : super(key: key);

  @override
  State<TaskListScreen> createState() => _TaskCalendarScreenState();
}

final today = DateTime.now();
final calendarFirstDay = DateTime(today.year - 2, today.month, today.day);
final calendarLastDay = DateTime(today.year + 2, today.month, today.day);

class _TaskCalendarScreenState extends TaskListScreenState {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Task> selectedTasks = [];

  @override
  void initState() {
    super.initState();

    _selectedDay = _focusedDay;
    selectedTasks = getTaskForDay(today);
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });

      selectedTasks = getTaskForDay(selectedDay);
    }
  }

  @override
  Widget innerBuild() {
    return Column(
      children: [
        TableCalendar<Task>(
          firstDay: calendarFirstDay,
          lastDay: calendarLastDay,
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          calendarFormat: _calendarFormat,
          startingDayOfWeek: StartingDayOfWeek.monday,
          calendarStyle: const CalendarStyle(
            // Use `CalendarStyle` to customize the UI
            outsideDaysVisible: false,
          ),
          onDaySelected: _onDaySelected,
          eventLoader: getTaskForDay,
          headerStyle: HeaderStyle(titleTextFormatter: (date, _) {
            return "${date.year}年${date.month}月";
          }),
          calendarBuilders: CalendarBuilders(
            markerBuilder: (_, date, dailyTasks) {
              List<Widget> listChildren = [];

              for (int i = 0; i < dailyTasks.length; i++) {
                if (i < 2 || dailyTasks.length == 3) {
                  listChildren.add(
                    Padding(
                      padding: const EdgeInsets.only(left: 2, right: 2),
                      child: Container(
                        height: 10,
                        width: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.grey,
                              spreadRadius: 0.6,
                              blurRadius: 0.6,
                            )
                          ],
                          border: Border.all(
                            width: 0.3,
                            color: Colors.black,
                          ),
                          color: dailyTasks[i].customColor != null
                              ? Color(dailyTasks[i].customColor!)
                              : Colors.white,
                        ),
                      ),
                    ),
                  );
                } else {
                  listChildren.add(
                    Text(
                      " +${(dailyTasks.length - i).toString()}",
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                  break;
                }
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Container(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: listChildren,
                  ),
                ),
              );
            },
            dowBuilder: (_, day) {
              late String text;
              TextStyle? style;
              switch (day.weekday) {
                case DateTime.monday:
                  text = "月";
                  break;
                case DateTime.tuesday:
                  text = "火";
                  break;
                case DateTime.wednesday:
                  text = "水";
                  break;
                case DateTime.thursday:
                  text = "木";
                  break;
                case DateTime.friday:
                  text = "金";
                  break;
                case DateTime.saturday:
                  text = "土";
                  style = const TextStyle(color: Colors.blue);
                  break;
                case DateTime.sunday:
                  text = "日";
                  style = const TextStyle(color: Colors.red);
                  break;
              }
              return Center(
                  child: Text(
                text,
                style: style,
              ));
            },
          ),
          onFormatChanged: (format) {
            if (_calendarFormat != format) {
              setState(() {
                _calendarFormat = format;
              });
            }
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
        ),
        const Divider(
          height: 1,
          color: Colors.black,
        ),
        Expanded(
          child: ListView.separated(
            itemCount: selectedTasks.length,
            separatorBuilder: (BuildContext context, int index) {
              return const Divider(
                height: 0.5,
              );
            },
            itemBuilder: (BuildContext context, int index) {
              return buildListTile(index, getTaskForDay(_selectedDay));
            },
          ),
        ),
      ],
    );
  }

  List<Task> getTaskForDay(DateTime? date) {
    List<Task> result = [];
    if (date == null) return result;

    for (var element in taskList) {
      var deadlineDate = DateTime.fromMillisecondsSinceEpoch(element.deadline);
      if (date.day == deadlineDate.day &&
          date.year == deadlineDate.year &&
          date.month == deadlineDate.month) {
        result.add(element);
      }
    }
    return result;
  }
}
