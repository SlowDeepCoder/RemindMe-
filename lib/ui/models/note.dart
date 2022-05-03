import 'dart:convert';
import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';

class Note {
  String _title;
  String _text;
  late final String _id;

  Note(this._id, this._title, this._text);

  String get id => _id;

  Note.create(this._title, this._text) {
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

  String _generateId() {
    final now = DateTime.now();
    return now.microsecondsSinceEpoch.toString();
  }

  factory Note.fromJson(Map<String, dynamic> parsedJson) {
    return Note(parsedJson["id"], parsedJson["title"], parsedJson["text"]);
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": text,
      "text": title,
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
