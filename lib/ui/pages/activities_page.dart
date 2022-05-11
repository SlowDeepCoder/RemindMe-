import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../util/color_constants.dart';
import '../items/activity_item.dart';
import '../models/activity.dart';
import '../models/note.dart';
import '../models/reminder.dart';

class ActivitiesPage extends StatefulWidget {
  final List<Note> notes;
  final Function(Note? note) onActivityClicked;

  const ActivitiesPage(
      {required this.notes, required this.onActivityClicked, Key? key})
      : super(key: key);

  @override
  State<ActivitiesPage> createState() => ActivitiesPageState();
}

class ActivitiesPageState extends State<ActivitiesPage> {
  List<Activity> activities = [];

  @override
  void initState() {
    super.initState();
    print("initState ActivitiesPage");
    _loadActivities(widget.notes);
  }

  _loadActivities(List<Note> notes) async {
    final savedActivities = await Activity.loadActivities();
    final reminders = Reminder.getReminders(notes);
    int i = 0;
    for (Reminder reminder in reminders) {
      final activity = Activity(reminder.noteId, reminder.timestamp, null);

      bool isNewActivity = true;
      for (Activity savedActivity in savedActivities) {
        if (activity.isEqual(savedActivity)) {
          isNewActivity = false;
          break;
        }
      }
      if (isNewActivity) {
        i++;
        savedActivities.add(activity);
      }
    }
    print(i.toString() + " new activites added");
    activities.clear();
    setState(() {
      activities.addAll(savedActivities);
    });
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
          return ActivityItem(
            activity,
            showDate,
            dateString,
            note,
            onActivityClicked: widget.onActivityClicked,
            onActivityRemoved: (activity) => _removeSavedActivity(activity),
            key: GlobalKey<ActivityItemState>(),
            onActivityChanged: (activity) =>
                _saveActivity(activity),
          );
        });
  }

  _saveActivity(Activity activity) async {
    final savedActivities = await Activity.loadActivities();

    for (Activity savedActivity in savedActivities) {
      if (savedActivity.isEqual(activity)) {
        savedActivities.remove(savedActivity);
        break;
      }
    }
    savedActivities.add(activity);
    Activity.saveActivities(savedActivities);
  }

  _removeSavedActivity(Activity activity) {
    activities.remove(activity);
    Activity.saveActivities(activities);
  }

  setActivities(List<Note> notes) {
    _loadActivities(notes);
  }
}
