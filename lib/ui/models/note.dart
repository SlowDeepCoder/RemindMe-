import 'dart:convert';
import 'dart:ui';

import 'package:remind_me/ui/models/reminder.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/notification_service.dart';

class Note {
  String _title;
  String _text;
  Reminder _reminder;
  late final String _id;

  Note(this._id, this._title, this._text, this._reminder);

  String get id => _id;

  Note.create(this._title, this._text, this._reminder) {
    _id = _generateId();
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
    final now = DateTime.now();
    return now.millisecondsSinceEpoch.toString();
  }

  factory Note.fromJson(Map<String, dynamic> parsedJson) {
    return Note(parsedJson["id"], parsedJson["title"], parsedJson["text"],
        Reminder.fromJson(parsedJson["reminder"]));
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": text,
      "text": title,
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
}
