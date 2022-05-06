import 'package:flutter/cupertino.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:remind_me/flutter_local_notifications-9.4.1/lib/flutter_local_notifications.dart';
import '../ui/models/note.dart';

class NotificationService {
  static const String title = "New activity";

  static setNotification(Note note) async {
    if (note.reminder.timestamp == null) {
      FlutterLocalNotificationsPlugin().cancel(note.reminder.id);
    } else {
      tz.initializeTimeZones();
      tz.TZDateTime scheduledDateTime =
          tz.TZDateTime.fromMillisecondsSinceEpoch(
              tz.local, note.reminder.timestamp!);
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'reminders',
        'Reminders',
        channelDescription: 'Get reminders from your notes',
        importance: Importance.max,
        priority: Priority.high,
      );
      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);
      // await FlutterLocalNotificationsPlugin().zonedSchedule(note.reminder.id,
      //     title, note.title, scheduledDateTime, platformChannelSpecifics,
      //     androidAllowWhileIdle: true,
      //     uiLocalNotificationDateInterpretation:
      //         UILocalNotificationDateInterpretation.absoluteTime,
      //     payload: note.id);
      debugPrint(scheduledDateTime.millisecondsSinceEpoch.toString());
      await FlutterLocalNotificationsPlugin().periodicallyShow(note.reminder.id, title,
          note.title, RepeatInterval.everyMinute, 1, scheduledDateTime.millisecondsSinceEpoch, platformChannelSpecifics,
          androidAllowWhileIdle: true, payload: note.id);
    }
  }

  static triggerTestNotification() {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
        'reminders',
        'Reminders',
        channelDescription: 'Get reminders from your notes',
        importance: Importance.max,
        priority: Priority.high,
      );
      const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
      DateTime date =  DateTime.now().add(const Duration(minutes: 5));
      debugPrint(date.millisecondsSinceEpoch.toString());
    FlutterLocalNotificationsPlugin().periodicallyShow(0, "Test",
        "Test message", RepeatInterval.everyMinute, 1, date.millisecondsSinceEpoch, platformChannelSpecifics,
        androidAllowWhileIdle: true);
  }
}
