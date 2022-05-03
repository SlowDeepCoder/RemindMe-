import 'dart:ui';

class Note {
  String _title;
  String _text;

  Note(this._title, this._text);

  String get text => _text;

  set text(String value) {
    _text = value;
  }

  String get title => _title;

  set title(String value) {
    _title = value;
  }
}
