import 'dart:convert';
import 'dart:ui';

import 'package:remind_me/ui/models/reminder.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/date_service.dart';
import '../../services/notification_service.dart';

enum SortOptions { created, updated }

class Note {
  late final String _id;
  late String _title;
  late String _text;
  late int _updatedAt;
  late final List<Reminder> _reminders;
  late final int _createdAt;

  Note.create() {
    _id = _generateId();
    _title = "";
    _text = "";
    _createdAt = DateService.getCurrentTimestamp();
    _updatedAt = _createdAt;
    _reminders = [];
  }

  Note(this._id, this._updatedAt, this._createdAt, this._title, this._text,
      this._reminders);

  String get id => _id;

  int get createdAt => _createdAt;

  int get updatedAt => _updatedAt;

  set updatedAt(int value) {
    _updatedAt = value;
  }

  String get text => _text;

  set text(String value) {
    _text = value;
  }

  String get title => _title;

  set title(String value) {
    _title = value;
  }

  List<Reminder> get reminders => _reminders;

  addReminder(Reminder reminder) {
    _reminders.add(reminder);
  }

  String _generateId() {
    return DateService.getCurrentTimestamp().toString();
  }

  //Todo: Not quite working
  bool isEqual(Note? note) {
    if (note == null) return false;
    return (note.id == id &&
        note.createdAt == createdAt &&
        note.updatedAt == updatedAt &&
        note.title == title &&
        note.text == text &&
        Reminder.isEqual(note.reminders, reminders));
  }

  factory Note.fromJson(Map<String, dynamic> parsedJson) {
    print(parsedJson);
    final encodedReminders = parsedJson["reminders"];
    final decodedReminders = json.decode(encodedReminders) as List;
    List<Reminder> reminders = [];
    for (dynamic decodedReminder in decodedReminders) {
      final recurringDays =
          json.decode(decodedReminder["recurringDays"]) as List<bool>?;
      final reminder = Reminder(
          decodedReminder["id"] as int,
          decodedReminder["isRecurring"] as bool,
          decodedReminder["timestamp"] as int,
          recurringDays,
          decodedReminder["noteId"] as String);
      reminders.add(reminder);
    }
    // decodedReminders.isEmpty ? [] : decodedReminders as List<Reminder>;
    return Note(
        parsedJson["id"],
        parsedJson["createdAt"],
        parsedJson["updatedAt"],
        parsedJson["title"],
        parsedJson["text"],
        reminders);
  }

  Map<String, dynamic> toJson() {
    String encodedReminders =
        jsonEncode(_reminders.map((value) => value.toJson()).toList())
            .toString();
    return {
      "id": id,
      "createdAt": _createdAt,
      "updatedAt": _updatedAt,
      "title": title,
      "text": text,
      "reminders": encodedReminders,
    };
  }

  static Note? getNote(List<Note> notes, String id){
    for(Note note in notes){
      if(note.id == id){
        return note;
      }
    }
    return null;
  }


  static saveNotes(List<Note> notes) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    List<String> notesEncoded =
        notes.map((note) => jsonEncode(note.toJson())).toList();
    print(notesEncoded);
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
        remindersCopy);
  }
}
