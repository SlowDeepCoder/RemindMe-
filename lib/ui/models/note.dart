import 'dart:convert';
import 'dart:ui';

import 'package:remind_me/ui/models/reminder.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/date_service.dart';
import '../../services/notification_service.dart';

enum SortOptions { created, updated }

class Note {
  String _title;
  String _text;
  late int _updatedAt;
  Reminder _reminder;
  late final String _id;
  late final int _createdAt;

  Note.create(this._title, this._text, this._reminder) {
    _createdAt = DateService.getCurrentTimestamp();
    _updatedAt = _createdAt;
    _id = _generateId();
  }

  Note(this._id, this._updatedAt, this._createdAt, this._title, this._text,
      this._reminder);

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

  Reminder get reminder => _reminder;

  set reminder(Reminder value) {
    _reminder = value;
  }

  String _generateId() {
    return DateService.getCurrentTimestamp().toString();
  }

  factory Note.fromJson(Map<String, dynamic> parsedJson) {
    return Note(
        parsedJson["id"],
        parsedJson["createdAt"],
        parsedJson["updatedAt"],
        parsedJson["title"],
        parsedJson["text"],
        Reminder.fromJson(parsedJson["reminder"]));
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "createdAt": _createdAt,
      "updatedAt": _updatedAt,
      "title": title,
      "text": text,
      "reminder": _reminder.toJson(),
    };
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

  static List<Note> sortNotes(List<Note> notes, SortOptions sortOption, bool reverse) {
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
    if(reverse){
      notes = notes.reversed.toList();
    }
    return notes;
  }


}
