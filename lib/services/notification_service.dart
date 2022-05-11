import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:remind_me/util/color_constants.dart';
import '../ui/models/note.dart';
import '../ui/models/reminder.dart';

class NotificationService {
  static NotificationService? _instance;
  static const String title = "New activity";
  StreamSubscription<ReceivedAction>? _actionStreamSubscription;

  // StreamSubscription<ReceivedNotification>? _notificationStreamSubscription;
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
                defaultColor: ColorConstants.soil,
                ledColor: ColorConstants.soil,
                importance: NotificationImportance.High)
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

  setNotificationListeners(List<Note> notes, Function(Note) onClick) {
    _actionStreamSubscription ??=
        AwesomeNotifications().actionStream.listen((ReceivedAction event) {
      print('event received!');
      final eventData = event.toMap();
      print(eventData.toString());
      if (eventData["buttonKeyPressed"] != null &&
          eventData["buttonKeyPressed"] != "") {
        if (eventData["buttonKeyPressed"] == "COMPLETE") {
          print("COMPLETE");
        }
      } else if (eventData["payload"] != null) {
        if (eventData["payload"].containsKey("noteId")) {
          for (Note note in notes) {
            if (note.id == eventData["payload"]["noteId"]) {
              onClick(note);
              break;
            }
          }
        }
      }
    });
  }

  static void setReminders(List<Reminder> reminders, Note note) async {
    for (Reminder reminder in reminders) {
      await setReminder(reminder, note);
    }
  }

  static setReminder(Reminder reminder, Note note) async {
    if (!reminder.isRecurring) {
      final date = DateTime.fromMillisecondsSinceEpoch(reminder.timestamp);
      final cron = CronHelper().hourly(referenceDateTime: date);
      AwesomeNotifications().createNotification(
        schedule: NotificationAndroidCrontab(crontabExpression: cron),
        actionButtons: [
          NotificationActionButton(
              buttonType: ActionButtonType.KeepOnTop,
              key: 'COMPLETE',
              label: 'Complete'),
          NotificationActionButton(
              buttonType: ActionButtonType.DisabledAction,
              key: 'DISMISS',
              label: 'Dismiss'),
          NotificationActionButton(
              buttonType: ActionButtonType.KeepOnTop,
              key: 'DELAY',
              label: 'Delay 1 hour'),
        ],
        content: NotificationContent(
            id: reminder.id,
            channelKey: 'basic_channel',
            title: note.title,
            body: note.text,
            icon: 'resource://drawable/cute_mole_face',
            backgroundColor: ColorConstants.soil,
            color: ColorConstants.soil,
            notificationLayout: NotificationLayout.BigText,
            showWhen: true,
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

  static sendTestReminder(Reminder reminder, Note note) {
    AwesomeNotifications().createNotification(
      actionButtons: [
        NotificationActionButton(
            buttonType: ActionButtonType.KeepOnTop,
            key: 'COMPLETE',
            label: 'Complete'),
        NotificationActionButton(
            buttonType: ActionButtonType.DisabledAction,
            key: 'DISMISS',
            label: 'Dismiss'),
        NotificationActionButton(
            buttonType: ActionButtonType.KeepOnTop,
            key: 'DELAY',
            label: 'Delay 1 hour'),
      ],
      content: NotificationContent(
          id: reminder.id,
          channelKey: 'basic_channel',
          title: note.title,
          body: note.text,
          icon: 'resource://drawable/cute_mole_face',
          backgroundColor: ColorConstants.soil,
          color: ColorConstants.soil,
          notificationLayout: NotificationLayout.BigText,
          showWhen: true,
          payload: {"noteId": reminder.noteId}),
    );
  }
}
