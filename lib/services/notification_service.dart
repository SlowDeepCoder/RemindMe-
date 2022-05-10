import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../ui/models/note.dart';
import '../ui/models/reminder.dart';

class NotificationService {
  static NotificationService? _instance;
  static const String title = "New activity";
  StreamSubscription<ReceivedAction>? _actionStreamSubscription;
  bool hasBeenInitialized = false;

  NotificationService._internal();

  factory NotificationService() =>
      _instance ??= NotificationService._internal();

  initNotifications() async {
    if (!hasBeenInitialized) {
      hasBeenInitialized = await AwesomeNotifications().initialize(
          // set the icon to null if you want to use the default app icon
          null,
          [
            NotificationChannel(
                channelGroupKey: 'basic_channel_group',
                channelKey: 'basic_channel',
                channelName: 'Basic notifications',
                channelDescription: 'Notification channel for basic tests',
                defaultColor: Color(0xFF9D50DD),
                ledColor: Colors.white)
          ],
          // Channel groups are only visual and are not required
          channelGroups: [
            NotificationChannelGroup(
                channelGroupkey: 'basic_channel_group',
                channelGroupName: 'Basic group')
          ],
          debug: true);
      await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
        if (!isAllowed) {
          AwesomeNotifications().requestPermissionToSendNotifications();
        }
      });
    }
  }

  setNotificationListener(List<Note> notes, Function(Note) onClick) {
    _actionStreamSubscription ??= AwesomeNotifications()
          .actionStream
          .listen((ReceivedNotification receivedNotification) {
        if (receivedNotification.payload != null) {
          if (receivedNotification.payload!.containsKey("noteId")) {
            for (Note note in notes) {
              if (note.id == receivedNotification.payload!["noteId"]) {
                onClick(note);
                break;
              }
            }
          }
        }
      });
  }

  static void setReminders(List<Reminder> reminders) async {
    for (Reminder reminder in reminders) {
      await setReminder(reminder);
    }
  }

  static setReminder(Reminder reminder) async {
    if (!reminder.isRecurring && reminder.timestamp != null) {
      final date = DateTime.fromMillisecondsSinceEpoch(reminder.timestamp!);
      final cron = CronHelper().hourly(referenceDateTime: date);
      AwesomeNotifications().createNotification(
        schedule: NotificationAndroidCrontab(crontabExpression: cron),
        content: NotificationContent(
            id: reminder.id,
            channelKey: 'basic_channel',
            title: title,
            body: 'Simple body',
            payload: {"noteId": reminder.noteId}),
      );
    }
  }

  static cancelAllNotifications() {
    AwesomeNotifications().cancelAll();
  }

  static void cancelReminders(List<Reminder> reminders) async {
    for (Reminder reminder in reminders) {
      await cancelReminder(reminder);
    }
  }

  static cancelReminder(Reminder reminder) async {
    await AwesomeNotifications().cancel(reminder.id);
  }

  static sendTestReminder(Reminder reminder) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: reminder.id,
          channelKey: 'basic_channel',
          title: title,
          body: 'Simple body',
          payload: {"noteId": reminder.noteId}),
    );
  }
}
