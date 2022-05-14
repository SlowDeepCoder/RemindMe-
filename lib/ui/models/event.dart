import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:remind_me/ui/models/reminder.dart';
import 'package:remind_me/util/color_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'activity.dart';
import '../../services/date_service.dart';
import '../../services/notification_service.dart';


class Event extends Activity {
  late String text;

  Event.create() {
    id = generateId();
    title = "";
    text = "";
    createdAt = DateService.getCurrentTimestamp();
    updatedAt = createdAt;
    reminders = [];
    color = ColorOptions.brown;
  }

  Event(String id, int createdAt, int updatedAt, String title, this.text,
      List<Reminder> reminders, ColorOptions color) {
    this.id = id;
    this.createdAt = createdAt;
    this.updatedAt = updatedAt;
    this.title = title;
    this.reminders = reminders;
    this.color = color;
  }


  factory Event.fromJson(Map<String, dynamic> parsedJson) {
    final encodedReminders = parsedJson["reminders"];
    final decodedReminders = json.decode(encodedReminders) as List;
    List<Reminder> reminders = [];
    for (dynamic decodedReminder in decodedReminders) {
      // final recurringDays =
      //     json.decode(decodedReminder["recurringDays"]) as List<bool>?;
      final reminder = Reminder(
          decodedReminder["id"] as int,
          ActivityType.values.byName(decodedReminder["activityType"]),
          // decodedReminder["isRecurring"] as bool,
          decodedReminder["timestamp"] as int,
          // recurringDays,
          decodedReminder["noteId"] as String,
          decodedReminder["isCompleted"] as bool?);
      reminders.add(reminder);
    }
    // decodedReminders.isEmpty ? [] : decodedReminders as List<Reminder>;
    return Event(
        parsedJson["id"],
        parsedJson["createdAt"],
        parsedJson["updatedAt"],
        parsedJson["title"],
      parsedJson["text"],
      reminders,
        ColorOptions.values.byName(parsedJson["color"])
    );
  }

  Map<String, dynamic> toJson() {
    String encodedReminders =
        jsonEncode(reminders.map((value) => value.toJson()).toList())
            .toString();
    return {
      "id": id,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
      "title": title,
      "text": text,
      "reminders": encodedReminders,
      "color": color.name,
    };
  }

  static Event? getEvent(List<Event> events, String id) {
    for (Event event in events) {
      if (event.id == id) {
        return event;
      }
    }
    return null;
  }

  static saveEvents(List<Event> notes) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    List<String> notesEncoded =
        notes.map((note) => jsonEncode(note.toJson())).toList();
    await sharedPreferences.setStringList('events', notesEncoded);
  }

  static Future<List<Event>> loadEvents() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final notesEncoded = sharedPreferences.getStringList('events');
    final List<Event> list = [];
    if (notesEncoded != null) {
      for (String string in notesEncoded) {
        final noteDecoded = jsonDecode(string);
        list.add(Event.fromJson(noteDecoded));
      }
    }
    return list;
  }


  static Event copy(Event event) {
    List<Reminder> remindersCopy = [...event.reminders];
    return Event(event.id, event.updatedAt, event.createdAt, event.title, event.text,
        remindersCopy, event.color);
  }

  @override
  String getContent() {
    return text;
  }
}
