import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:remind_me/ui/bottom_sheets/edit_event_bottom_sheet.dart';
import 'package:remind_me/util/color_constants.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/activity.dart';
import '../items/reminder_item.dart';
import '../models/checklist.dart';
import '../models/remidneractivity.dart';
import '../models/event.dart';
import '../models/note.dart';
import '../models/reminder.dart';

class CalendarPage extends StatefulWidget {
  final List<Note> notes;
  final List<Checklist> checklists;
  final List<Event> events;
  final List<Reminder> reminders;
  final Function(Reminder reminder, Activity activity) onReminderClicked;
  final Function(DateTime? selectedDay) onAddNewEvent;

  const CalendarPage(
      {Key? key,
      required this.notes,
      required this.events,
      required this.onAddNewEvent,
      required this.onReminderClicked,
        required this.checklists,
      required this.reminders})
      : super(key: key);

  @override
  State<CalendarPage> createState() => CalendarPageState();
}

class CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late final ValueNotifier<List<Reminder>> _selectedReminders;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _selectedReminders = ValueNotifier(_getRemindersForTheDay(_selectedDay!));
  }

  @override
  void dispose() {
    _selectedReminders.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final kToday = DateTime.now();
    final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
    final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);
    return Column(children: [
      TableCalendar(
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, calendarDay, selectedDay) {
            final text = calendarDay.day.toString();

            return Center(
              child: Text(
                text,
                style: TextStyle(color: ColorConstants.sand),
              ),
            );
          },
          dowBuilder: (context, day) {
            final text = DateFormat.E().format(day);
            return Center(
              child: Text(
                text,
                style: TextStyle(color: ColorConstants.sand),
              ),
            );
          },
        ),
        firstDay: kFirstDay,
        lastDay: kLastDay,
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        eventLoader: (day) {
          return _getRemindersForTheDay(day);
        },
        selectedDayPredicate: (day) {
          // Use `selectedDayPredicate` to determine which day is currently selected.
          // If this returns true, then `day` will be marked as selected.

          // Using `isSameDay` is recommended to disregard
          // the time-part of compared DateTime objects.
          return isSameDay(_selectedDay, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          if (!isSameDay(_selectedDay, selectedDay)) {
            // Call `setState()` when updating the selected day
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          }
          _selectedReminders.value = _getRemindersForTheDay(_selectedDay);
        },
        onFormatChanged: (format) {
          if (_calendarFormat != format) {
            // Call `setState()` when updating calendar format
            setState(() {
              _calendarFormat = format;
            });
          }
        },
        onPageChanged: (focusedDay) {
          // No need to call `setState()` here
          _focusedDay = focusedDay;
        },
      ),
      const SizedBox(height: 8.0),
      Expanded(
        child: ValueListenableBuilder<List<Reminder>>(
          valueListenable: _selectedReminders,
          builder: (context, reminders, _) {
            return ListView.builder(
              itemCount: reminders.length,
              itemBuilder: (context, index) {
                final reminder = reminders[index];
                // final note = Note.getNote(
                //     activity.isNote ? widget.notes : widget.events,
                //     activity.noteId);
                final activity = Activity.getActivity(
                    [widget.notes, widget.events], reminder.activityId);

                final date =
                    DateTime.fromMillisecondsSinceEpoch(reminder.timestamp);
                final dateString = DateFormat('dd MMM').format(date);
                return ReminderItem(
                  reminder,
                  false,
                  dateString,
                  activity,
                  onReminderClicked: widget.onReminderClicked,
                  // onReminderRemoved: widget.onRemoveReminder,
                  key: GlobalKey<ReminderItemState>(),
                  // onReminderChanged: (activity) {
                    // ReminderActivity.saveActivity(activity)
                  // },
                );
              },
            );
          },
        ),
      ),
    ]);
  }

  List<Reminder> _getRemindersForTheDay(DateTime? day) {
    if (day == null) {
      return [];
    }
    final List<Reminder> reminders = [];
    for (Reminder reminder in widget.reminders) {
      final date = DateTime.fromMillisecondsSinceEpoch(reminder.timestamp);
      if (day.year == date.year &&
          day.month == date.month &&
          day.day == date.day) {
        reminders.add(reminder);
      }
    }
    return reminders;
  }

  void update() {
    setState(() {});
  }

  AppBar getAppBar(AppBar standardAppBar) {
    return AppBar(
      title: Text("Mole Planner"),
      actions: [
        PopupMenuButton(
            // add icon, by default "3 dot" icon
            icon: Icon(Icons.add),
            itemBuilder: (context) {
              return [
                const PopupMenuItem<int>(
                  value: 0,
                  child: Text("New Note"),
                ),
                const PopupMenuItem<int>(
                  value: 1,
                  child: Text("New Checklist"),
                ),
                const PopupMenuItem<int>(
                  value: 2,
                  child: Text("New Event"),
                ),
              ];
            },
            onSelected: (value) {
              if (value == 0) {
                // _addNewNote();
              } else if (value == 1) {
              } else if (value == 2) {
                widget.onAddNewEvent(_selectedDay);
              }
            }),
      ],
    );
  }

}
