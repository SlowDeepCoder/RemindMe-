import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:remind_me/services/date_service.dart';
import 'package:remind_me/util/color_constants.dart';
import '../ui/models/activity.dart';
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

  static setReminders(Activity activity) async {
    final now = DateService.getCurrentTimestamp();
    for (Reminder reminder in activity.reminders) {
      if(reminder.timestamp > now) {
        await setReminder(reminder, activity);
      }
    }
  }

  static setReminder(Reminder reminder, Activity activity) async {
      final date = DateTime.fromMillisecondsSinceEpoch(reminder.timestamp);
      final cron = CronHelper().hourly(referenceDateTime: date);
      final title = activity.title;
      final text = activity.getContent();
      AwesomeNotifications().createNotification(
          schedule: NotificationCalendar.fromDate(date: date),
        // schedule: NotificationAndroidCrontab(crontabExpression: cron),
        actionButtons: [
          NotificationActionButton(
              buttonType: ActionButtonType.KeepOnTop,
              key: 'COMPLETE',
              label: 'Complete'),
          NotificationActionButton(
              buttonType: ActionButtonType.KeepOnTop,
              key: 'IGNORE',
              label: 'Ignore'),
          // NotificationActionButton(
          //     buttonType: ActionButtonType.KeepOnTop,
          //     key: 'DELAY',
          //     label: 'Delay 1 hour'),
        ],
        content: NotificationContent(
            id: reminder.id,
            channelKey: 'basic_channel',
            title: title,
            body: text,
            icon: 'resource://drawable/cute_mole_face',
            backgroundColor: ColorConstants.soil,
            color: ColorConstants.soil,
            notificationLayout: NotificationLayout.BigText,
            showWhen: true,
            payload: {"noteId": reminder.activityId}),
      );
  }

  static cancelAllNotifications() {
    AwesomeNotifications().cancelAll();
  }

  static cancelReminders(List<Reminder> reminders) async {
    for (Reminder reminder in reminders) {
      await cancelReminder(reminder);
    }
  }

  static cancelReminder(Reminder reminder) async {
    await AwesomeNotifications().cancel(reminder.id);
  }

  static sendTestReminder(Reminder reminder, Activity activity) {
    final title = activity.title;
    final text = activity.getContent();
    AwesomeNotifications().createNotification(
      actionButtons: [
        NotificationActionButton(
            buttonType: ActionButtonType.KeepOnTop,
            key: 'COMPLETE',
            label: 'Complete'),
        NotificationActionButton(
            buttonType: ActionButtonType.KeepOnTop,
            key: 'IGNORE',
            label: 'Ignore'),
        // NotificationActionButton(
        //     buttonType: ActionButtonType.KeepOnTop,
        //     key: 'DELAY',
        //     label: 'Delay 1 hour'),
      ],
      content: NotificationContent(
          id: reminder.id,
          channelKey: 'basic_channel',
          title: title,
          body: text,
          icon: 'resource://drawable/mole_siluette',
          backgroundColor: ColorConstants.soil,
          color: ColorConstants.soil,
          notificationLayout: NotificationLayout.BigText,
          showWhen: true,
          payload: {"noteId": reminder.activityId}),
    );
  }
}
