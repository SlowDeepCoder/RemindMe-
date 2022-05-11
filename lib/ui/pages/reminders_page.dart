import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../util/color_constants.dart';
import '../models/activity.dart';
import '../models/note.dart';
import '../models/reminder.dart';

class RemindersPage extends StatefulWidget {
  final List<Note> notes;
  final Function(Note? note) onReminderClicked;

  const RemindersPage(
      {required this.notes, required this.onReminderClicked, Key? key})
      : super(key: key);

  @override
  State<RemindersPage> createState() => RemindersPageState();
}

class RemindersPageState extends State<RemindersPage> {
  List<Activity> activities = [];

  @override
  void initState() {
    super.initState();
    final reminders = Reminder.getReminders(widget.notes);
    for (Reminder reminder in reminders) {
      final activity = Activity(reminder.noteId, reminder.timestamp, null);
      activities.add(activity);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> dateStrings = [];
    return ListView.builder(
        itemCount: activities.length,
        itemBuilder: (context, index) {
          final activity = activities[index];
          final date = DateTime.fromMillisecondsSinceEpoch(activity.timestamp);
          final dateString = DateFormat('dd MMM').format(date);
          bool showDate = !dateStrings.contains(dateString);
          if (showDate) {
            dateStrings.add(dateString);
          }
          final note = Note.getNote(widget.notes, activity.noteId);
          final noteTitle = note != null ? note.title : "";
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Visibility(visible: showDate, child: Text(dateString)),
              Card(
                  color: ColorConstants.soil,
                  child: InkWell(
                      onTap: () => widget.onReminderClicked(note),
                      child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(5),
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  activity.getTimeString() + " " + noteTitle,
                                  textAlign: TextAlign.start,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    IconButton(
                                      padding: EdgeInsets.all(4),
                                      constraints: BoxConstraints(),
                                      onPressed: () {
                                        setState(() {
                                          if(activity.isCompleted == null || activity.isCompleted! ){
                                            activity.isCompleted = false;
                                          }
                                          else{
                                            activity.isCompleted = null;
                                          }
                                        });
                                      },
                                      icon: const Icon(Icons.close),
                                      color: (activity.isCompleted != null &&
                                              !activity.isCompleted!)
                                          ? Colors.red
                                          : ColorConstants.sand,
                                    ),
                                    IconButton(
                                      padding: EdgeInsets.all(4),
                                      constraints: BoxConstraints(),
                                      onPressed: () {
                                        setState(() {
                                          if(activity.isCompleted == null|| !activity.isCompleted! ){
                                            activity.isCompleted = true;
                                          }
                                          else{
                                            activity.isCompleted = null;
                                          }
                                        });
                                      },
                                      icon: const Icon(Icons.check),
                                      color: (activity.isCompleted != null &&
                                          activity.isCompleted!)
                                          ? Colors.green
                                          : ColorConstants.sand,
                                    )
                                  ],
                                )
                              ],
                            ),
                          ))))
            ],
          );
        });
  }

  setActivities(List<Note> notes) {
    final reminders = Reminder.getReminders(notes);
    activities.clear();
    for (Reminder reminder in reminders) {
      final activity = Activity(reminder.noteId, reminder.timestamp, null);
      activities.add(activity);
    }
    setState(() {});
  }
}
