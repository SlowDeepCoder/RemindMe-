import 'dart:convert';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:intl/intl.dart';

import 'activity.dart';
import 'note.dart';

extension on List {
  bool equals(List list) {
    if (length != list.length) return false;
    return every((item) => list.contains(item));
  }
}

enum ActivityType { note, checklist, event }

class Reminder {
  late int id;
  late int timestamp;
  late bool? isCompleted;
  final String activityId;
  late final ActivityType activityType;

  Reminder.create(this.activityId, this.activityType, this.timestamp) {
    id = _generateId();
    isCompleted = null;
  }

  Reminder(this.id, this.activityType,  this.timestamp, this.activityId, this.isCompleted);


  String getTimeAndDateString() {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final dateString = DateFormat('dd MMM yyyy, HH:mm').format(date);
    return dateString;
  }

  String getTimeString() {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final dateString = DateFormat('HH:mm').format(date);
    return dateString;
  }

  int _generateId() {
    int id = Random().nextInt(pow(2, 31) - 1 as int);
    return id;
  }

  factory Reminder.fromJson(Map<String, dynamic> parsedJson) {
    String encodedRecurringDays = parsedJson["recurringDays"];
    final recurringDays = json.decode(encodedRecurringDays) as List<bool>?;
    return Reminder(
      parsedJson["id"],
      ActivityType.values.byName(parsedJson["activityType"]),
      parsedJson["timestamp"],
      parsedJson["noteId"],
      parsedJson["isCompleted"],
    );
  }

  Map<String, dynamic> toJson() {
    // String encodedRecurringDays = recurringDays != null
    //     ? jsonEncode(recurringDays!.map((value) => value.toString()).toList())
    //         .toString()
    //     : jsonEncode(null);
    return {
      "id": id,
      "activityType": activityType.name,
      "timestamp": timestamp,
      "noteId": activityId,
      "isCompleted": isCompleted,
    };
  }

  static List<Reminder> getReminders(List<List<Activity>> lists) {
    List<Activity> activities = [];
    for (List<Activity> list in lists) {
      activities.addAll(list);
    }
    final reminders = _getReminders(activities);
    return reminders;
  }




  static List<Reminder> _getReminders(List<Activity> activities) {
    List<Reminder> reminders = [];
    for (Activity activity in activities) {
      reminders.addAll(activity.reminders);
    }
    sortReminders(reminders);
    return reminders;
  }

  static List<Reminder> sortReminders(List<Reminder> reminders) {
    reminders.sort((a, b) {
      return Comparable.compare(a.timestamp, b.timestamp);
    });
    return reminders;
  }

  // static bool isEqual(List<Reminder> rl1, List<Reminder> rl2) {
  //   if (rl1.length == rl2.length) {
  //     for (int i = 0; i < rl1.length; i++) {
  //       final r1 = rl1[i];
  //       final r2 = rl2[i];
  //       if (r1.id != r2.id ||
  //           r1.isRecurring != r2.isRecurring ||
  //           r1.timestamp != r2.timestamp) {
  //         Function equals = const ListEquality().equals;
  //         if (!equals(r1.recurringDays, r2.recurringDays)) {
  //           return false;
  //         }
  //       }
  //     }
  //     return true;
  //   }
  //   return false;
  // }
}
