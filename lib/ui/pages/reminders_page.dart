import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/activity.dart';
import '../../util/color_constants.dart';
import '../items/reminder_item.dart';
import '../models/checklist.dart';
import '../models/remidneractivity.dart';
import '../models/event.dart';
import '../models/note.dart';
import '../models/reminder.dart';

class RemindersPage extends StatefulWidget {
  final List<Note> notes;
  final List<Checklist> checklists;
  final List<Event> events;
  final List<Reminder> reminders;
  final Function(Reminder reminder, Activity activity) onReminderClicked;

  const RemindersPage({required this.notes,
    required this.events,
    required this.reminders,
    required this.checklists,
    required this.onReminderClicked,
    Key? key})
      : super(key: key);

  @override
  State<RemindersPage> createState() => RemindersPageState();
}

class RemindersPageState extends State<RemindersPage> {
  // List<Activity> activities = [];

  // @override
  // void initState() {
  //   super.initState();
  //   print("initState ActivitiesPage");
  //   // _loadActivities(widget.notes);
  // }

  // _loadActivities(List<Note> notes) async {
  //   final savedActivities = await Activity.loadActivities();
  //   final reminders = Reminder.getReminders(notes);
  //   int i = 0;
  //   for (Reminder reminder in reminders) {
  //     final activity = Activity(reminder.noteId, reminder.timestamp, null);
  //
  //     bool isNewActivity = true;
  //     for (Activity savedActivity in savedActivities) {
  //       if (activity.isEqual(savedActivity)) {
  //         isNewActivity = false;
  //         break;
  //       }
  //     }
  //     if (isNewActivity) {
  //       i++;
  //       savedActivities.add(activity);
  //     }
  //   }
  //   print(i.toString() + " new activites added");
  //   activities.clear();
  //   setState(() {
  //     activities.addAll(savedActivities);
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    List<String> dateStrings = [];
    return ListView.builder(
        itemCount: widget.reminders.length,
        itemBuilder: (context, index) {
          final reminder = widget.reminders[index];
          final date = DateTime.fromMillisecondsSinceEpoch(reminder.timestamp);
          final dateString = DateFormat('dd MMM').format(date);
          bool showDate = !dateStrings.contains(dateString);
          if (showDate) {
            dateStrings.add(dateString);
          }
          // final note = Note.getNote(activity.isNote ? widget.notes : widget.events, activity.noteId);
          final activity = Activity.getActivity(
              [widget.notes, widget.events], reminder.activityId);
          // (activity.isNote ? widget.notes : widget.events, activity.noteId);
          return ReminderItem(
            reminder,
            showDate,
            dateString,
            activity,
            onReminderClicked: widget.onReminderClicked,
            key: GlobalKey<ReminderItemState>(),
          );
        });
  }

  void update() {
    setState(() {});
  }

  AppBar getAppBar(AppBar standardAppBar) {
    return standardAppBar;
  }
}
