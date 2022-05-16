import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:remind_me/ui/models/reminder.dart';
import 'package:remind_me/util/color_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'activity.dart';
import '../../services/date_service.dart';
import '../../managers/notification_manager.dart';

enum SortOptions { created, updated, titleAcending, titleDecending, color }

class Note extends Activity {
  late String text;

  Note.create() {
    id = generateId();
    title = "";
    text = "";
    createdAt = DateService.getCurrentTimestamp();
    updatedAt = createdAt;
    reminders = [];
    color = ColorOptions.brown;
  }

  Note(String id, int createdAt, int updatedAt, String title, this.text,
      List<Reminder> reminders, ColorOptions color) {
    this.id = id;
    this.createdAt = createdAt;
    this.updatedAt = updatedAt;
    this.title = title;
    this.reminders = reminders;
    this.color = color;
  }

  //Todo: Not quite working
  // bool isEqual(Note? note) {
  //   if (note == null) return false;
  //   return (note.id == id &&
  //       note.createdAt == createdAt &&
  //       note.updatedAt == updatedAt &&
  //       note.title == title &&
  //       note.text == text &&
  //       Reminder.isEqual(note.reminders, reminders));
  // }

  factory Note.fromJson(Map<String, dynamic> parsedJson) {
    print(parsedJson);
    final encodedReminders = parsedJson["reminders"];
    final decodedReminders = json.decode(encodedReminders) as List;
    List<Reminder> reminders = [];
    for (dynamic decodedReminder in decodedReminders) {
      // final recurringDays =
      //     json.decode(decodedReminder["recurringDays"]) as List<bool>?;
      final reminder = Reminder(
          decodedReminder["id"] as int,
          ActivityType.values.byName(decodedReminder["activityType"] as String),
          // decodedReminder["isRecurring"] as bool,
          decodedReminder["timestamp"] as int,
          // recurringDays,
          decodedReminder["noteId"] as String,
          decodedReminder["isCompleted"] as bool?);
      reminders.add(reminder);
    }
    // decodedReminders.isEmpty ? [] : decodedReminders as List<Reminder>;
    return Note(
      parsedJson["id"],
      parsedJson["createdAt"],
      parsedJson["updatedAt"],
      parsedJson["title"],
      parsedJson["text"],
      reminders,
      ColorOptions.values.byName(parsedJson["color"]),
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

  static Note? getNote(List<Note> notes, String id) {
    for (Note note in notes) {
      if (note.id == id) {
        return note;
      }
    }
    return null;
  }

  static saveNotes(List<Note> notes) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    List<String> notesEncoded =
        notes.map((note) => jsonEncode(note.toJson())).toList();
    await sharedPreferences.setStringList('notes', notesEncoded);
  }

  static Future<List<Note>> loadNotes() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final notesEncoded = sharedPreferences.getStringList('notes');
    final List<Note> list = [];
    if (notesEncoded != null) {
      for (String string in notesEncoded) {
        final noteDecoded = jsonDecode(string);
        list.add(Note.fromJson(noteDecoded));
      }
    }
    return list;
  }

  static List<Note> sortNotes(
      List<Note> notes, SortOptions sortOption, bool reverse) {
    switch (sortOption) {
      case SortOptions.created:
        notes.sort((a, b) {
          return Comparable.compare(a.createdAt, b.createdAt);
        });
        break;
      case SortOptions.updated:
        notes.sort((a, b) {
          return Comparable.compare(a.updatedAt, b.updatedAt);
        });
        break;
    }
    if (reverse) {
      notes = notes.reversed.toList();
    }
    return notes;
  }

  static Note copy(Note note) {
    List<Reminder> remindersCopy = [...note.reminders];
    return Note(note.id, note.updatedAt, note.createdAt, note.title, note.text,
        remindersCopy, note.color);
  }

  @override
  String getContent() {
    return text;
  }
}
