import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:remind_me/managers/notification_manager.dart';
import 'package:remind_me/ui/models/note.dart';
import 'package:remind_me/ui/screens/edit_activity_base_scaffold.dart';

import '../../services/date_service.dart';
import 'reminder.dart';
import '../../util/color_constants.dart';

enum ColorOptions {
  red,
  blue,
  green,
  yellow,
  brown,
  orange,
  lime,
  purple,
  white
}

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



  removeAllReminders() async{
    for(Reminder reminder in reminders){
      await NotificationManager.cancelReminder(reminder);
      reminders.remove(reminder);
    }
  }

  removeReminder(Reminder reminder) async{
    await NotificationManager.cancelReminder(reminder);
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

  Color getDarkColor() {
    return Activity.getDarkColorFromColorOption(color);
  }

  Color getColor() {
    return Activity.getColorFromColorOption(color);
  }

  static Color getDarkColorFromColorOption(ColorOptions colorOption) {
    if (colorOption == ColorOptions.brown) {
      return Activity.getColorFromColorOption(colorOption);
    } else {
      return Activity.getColorFromColorOption(colorOption).darken(0.2);
    }
  }

  static String getNameFromSortOption(SortOptions sortOption) {
    switch (sortOption) {
      case SortOptions.created:
        return "Created";
      case SortOptions.updated:
        return "Updated";
      case SortOptions.titleAcending:
        return "Title Ascending";
      case SortOptions.titleDecending:
        return "Title Descending";
      case SortOptions.color:
        return "Color";
    }
  }

  static Color getColorFromColorOption(ColorOptions colorOption) {
    switch (colorOption) {
      case ColorOptions.blue:
        return Colors.blue;
      case ColorOptions.red:
        return Colors.red.shade800;
      case ColorOptions.yellow:
        return Colors.yellow.shade700;
      case ColorOptions.green:
        return Colors.green.shade500;
      case ColorOptions.brown:
        return ColorConstants.soil;
      case ColorOptions.orange:
        return Colors.orange.shade900;
      case ColorOptions.lime:
        return Colors.lime;
      case ColorOptions.purple:
        return Colors.purple.shade300;
      case ColorOptions.white:
        return Colors.white54;
    }
  }

  String getContent();

  static List<Activity> getActivities(List<List<Activity>> lists) {
    List<Activity> activities = [];
    for (List<Activity> list in lists) {
      activities.addAll(list);
    }
    return activities;
  }

  static List<Activity> sortActivities(
      List<Activity> activities, SortOptions sortOption) {
    switch (sortOption) {
      case SortOptions.created:
        activities.sort((a, b) {
          return Comparable.compare(b.createdAt, a.createdAt);
        });
        break;
      case SortOptions.updated:
        activities.sort((a, b) {
          return Comparable.compare(b.updatedAt, a.updatedAt);
        });
        break;
      case SortOptions.titleAcending:
        activities.sort((a, b) {
          return compareAsciiUpperCase(a.title, b.title);
        });
        break;
      case SortOptions.titleDecending:
        activities.sort((a, b) {
          return compareAsciiUpperCase(b.title, a.title);
        });
        break;
      case SortOptions.color:
        activities.sort((a, b) {
          return Comparable.compare(ColorOptions.values.indexOf(a.color),
              ColorOptions.values.indexOf(b.color));
        });
        break;
    }
    return activities;
  }
}
