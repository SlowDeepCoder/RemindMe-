import 'dart:ui';

import 'package:flutter/material.dart';

import '../../services/date_service.dart';
import 'reminder.dart';
import '../../util/color_constants.dart';


enum ColorOptions { red, blue, green, yellow, brown }

abstract class Activity {
  late final String id;
  late String title;
  late final int createdAt;
  late int updatedAt;
  late final List<Reminder> reminders;
  // late final ActivityType activityType;
  late ColorOptions color;

  String generateId() {
    return DateService.getCurrentTimestamp().toString();
  }

  addReminder(Reminder reminder) {
    reminders.add(reminder);
  }

  removeReminder(Reminder reminder) {
    reminders.remove(reminder);
  }

  static Activity? getActivity(List<List<Activity>> lists, String id) {
    List<Activity> activities = [];
    for (List<Activity> list in lists) {
      activities.addAll(list);
    }
    final activity = _getActivity(activities, id);
    return activity;
  }

  static Activity? _getActivity(List<Activity> activities, String id) {
    for (Activity activity in activities) {
      if (activity.id == id) {
        return activity;
      }
    }
    return null;
  }

  Color getColor() {
    switch (color) {
      case ColorOptions.blue:
        return Colors.blue;
      case ColorOptions.red:
        return Colors.red.shade900;
      case ColorOptions.yellow:
        return Colors.yellow;
      case ColorOptions.green:
        return Colors.green;
      case ColorOptions.brown:
        return ColorConstants.soil;
    }
  }

  String getContent();
}
