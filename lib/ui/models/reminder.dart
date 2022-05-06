import 'dart:math';

enum TimeUnits { minute, hour, day, week, month }

class Reminder {
  late int _id;
  int? timestamp;
  int _reminderInterval;
  TimeUnits _recurringTimeUnit;

  Reminder(
      this.timestamp, this._reminderInterval, this._recurringTimeUnit) {
    _id = _generateId();
  }


  int get id => _id;

  int _generateId() {
    int id = Random().nextInt(pow(2, 31) - 1 as int);
    return id;
  }

  factory Reminder.fromJson(Map<String, dynamic> parsedJson) {
    return Reminder(
        parsedJson["remindTimestamp"],
        parsedJson["reminderInterval"],
        TimeUnits.values.byName(parsedJson["recurringReminderUnit"]));
  }

  Map<String, dynamic> toJson() {
    return {
      "remindTimestamp": timestamp,
      "reminderInterval": _reminderInterval,
      "recurringReminderUnit": _recurringTimeUnit.name,
    };
  }
}
