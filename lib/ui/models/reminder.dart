import 'dart:convert';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:intl/intl.dart';

import 'note.dart';

extension on List {
  bool equals(List list) {
    if (length != list.length) return false;
    return every((item) => list.contains(item));
  }
}

class Reminder {
  late int _id;
  final bool isRecurring;
  int timestamp;
  List<bool>? recurringDays;
  int? hour;
  int? minute;
  final String noteId;

  Reminder.create(this.isRecurring, this.noteId,
      this.timestamp, { this.recurringDays, this.hour, this.minute}) {
    _id = _generateId();
  }

  Reminder(this._id, this.isRecurring, this.timestamp, this.recurringDays,
      this.noteId);

  int get id => _id;

  String getTimeAndDateString() {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final dateString = DateFormat('HH:mm, dd MMM yyyy').format(date);
    return dateString;
  }


  String getTimeString() {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final dateString = DateFormat('HH:mm').format(date);
    return dateString;
  }

  int _generateId() {
    int id = Random().nextInt(pow(2, 31) - 1 as int);
    return id;
  }

  factory Reminder.fromJson(Map<String, dynamic> parsedJson) {
    String encodedRecurringDays = parsedJson["recurringDays"];
    final recurringDays = json.decode(encodedRecurringDays) as List<bool>?;
    return Reminder(
      parsedJson["id"],
      parsedJson["isRecurring"],
      parsedJson["timestamp"],
      recurringDays,
      parsedJson["noteId"],
    );
  }

  Map<String, dynamic> toJson() {
    String encodedRecurringDays = recurringDays != null
        ? jsonEncode(recurringDays!.map((value) => value.toString()).toList())
            .toString()
        : jsonEncode(null);
    return {
      "id": id,
      "isRecurring": isRecurring,
      "timestamp": timestamp,
      "recurringDays": encodedRecurringDays,
      "noteId": noteId,
    };
  }

  static List<Reminder> getReminders(List<Note> notes) {
    List<Reminder> reminders = [];
    for (Note note in notes) {
      reminders.addAll(note.reminders);
    }
    sortReminders(reminders);
    return reminders;
  }

  static List<Reminder> sortReminders(List<Reminder> reminders) {
    reminders.sort((a, b) {
      return Comparable.compare(a.timestamp, b.timestamp);
    });
    return reminders;
  }

  static bool isEqual(List<Reminder> rl1, List<Reminder> rl2) {
    if (rl1.length == rl2.length) {
      for (int i = 0; i < rl1.length; i++) {
        final r1 = rl1[i];
        final r2 = rl2[i];
        if (r1.id != r2.id ||
            r1.isRecurring != r2.isRecurring ||
            r1.timestamp != r2.timestamp) {
          Function equals = const ListEquality().equals;
          if (!equals(r1.recurringDays, r2.recurringDays)) {
            return false;
          }
        }
      }
      return true;
    }
    return false;
  }
}
