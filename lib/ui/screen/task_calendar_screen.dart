import 'package:flutter/material.dart';
import 'package:scomb_mobile/common/shared_resource.dart';
import 'package:scomb_mobile/ui/screen/network_screen.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../common/db/task.dart';
import '../../common/scraping/surveys_scraping.dart';
import '../../common/scraping/task_scraping.dart';

class TaskCalendarScreen extends NetworkScreen {
  TaskCalendarScreen(super.parent, super.title, {Key? key}) : super(key: key);

  @override
  State<TaskCalendarScreen> createState() => _TaskCalendarScreenState();
}

final today = DateTime.now();
final calendarFirstDay = DateTime(today.year - 2, today.month, today.day);
final calendarLastDay = DateTime(today.year + 2, today.month, today.day);

class _TaskCalendarScreenState extends NetworkScreenState<TaskCalendarScreen> {
  @override
  Future<void> getFromServerAndSaveToSharedResource(savedSessionId) async {
    if (taskListInitialized) return;
    await fetchSurveys(sessionId ?? savedSessionId);
    await fetchTasks(sessionId ?? savedSessionId);
    taskList.sort((a, b) => a.deadline.compareTo(b.deadline));
    taskListInitialized = true;
  }

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late final ValueNotifier<List<Task>> _selectedEvents;

  @override
  Future<void> refreshData() {
    taskListInitialized = false;
    return super.refreshData();
  }

  @override
  void initState() {
    super.initState();

    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(getTaskForDay(_selectedDay!));
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });

      _selectedEvents.value = getTaskForDay(selectedDay);
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
                      padding: const EdgeInsets.only(left: 3, right: 3),
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
          child: ValueListenableBuilder<List<Task>>(
            valueListenable: _selectedEvents,
            builder: (context, value, _) {
              return ListView.builder(
                itemCount: value.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: ListTile(
                      onTap: () => print('${value[index]}'),
                      title: Text('${value[index]}'),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  List<Task> getTaskForDay(DateTime date) {
    List<Task> result = [];
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
