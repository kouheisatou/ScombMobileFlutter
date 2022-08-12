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
        const SizedBox(height: 8.0),
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
