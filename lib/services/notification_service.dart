import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../ui/models/note.dart';

class NotificationService {
  static const String title = "New activity";

  static initNotifications() async {
    await AwesomeNotifications().initialize(
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

  static setNotificationListener(List<Note> notes, Function(Note) onClick) {
    AwesomeNotifications()
        .actionStream
        .listen((ReceivedNotification receivedNotification) {
      if (receivedNotification.payload != null) {
        if (receivedNotification.payload!.containsKey("id")) {
          for (Note note in notes) {
            if (note.id == receivedNotification.payload!["id"]) {
              onClick(note);
              break;
            }
          }
        }
      }
    });
  }

  static setNotification(Note note) async {
    if (note.reminder.timestamp == null) {
      AwesomeNotifications().cancel(note.reminder.id);
    } else {
      final date =
          DateTime.fromMillisecondsSinceEpoch(note.reminder.timestamp!);
      final cron = CronHelper().hourly(referenceDateTime: date);
      AwesomeNotifications().createNotification(
        schedule: NotificationAndroidCrontab(crontabExpression: cron),
        content: NotificationContent(
            id: note.reminder.id,
            channelKey: 'basic_channel',
            title: title,
            body: 'Simple body',
            payload: {"id": note.id}),
      );
    }
  }

  static cancelAllNotifications() {
    AwesomeNotifications().cancelAll();
  }

  static cancelNotification(Note note) {
    AwesomeNotifications().cancel(note.reminder.id);
  }

  static triggerTestNotification(Note note) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: note.reminder.id,
          channelKey: 'basic_channel',
          title: title,
          body: 'Simple body',
          payload: {"id": note.id}),
    );
  }
}
