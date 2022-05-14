import 'dart:convert';

import 'package:remind_me/ui/models/activity.dart';
import 'package:remind_me/ui/models/reminder.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/date_service.dart';

class Checklist extends Activity {
  late final List<Map<String, bool>> checklist;

  Checklist.create() {
    id = generateId();
    title = "";
    createdAt = DateService.getCurrentTimestamp();
    updatedAt = createdAt;
    reminders = [];
    checklist = [];
    color = ColorOptions.brown;
  }

  Checklist(String id, int createdAt, int updatedAt, String title,
      List<Reminder> reminders, ColorOptions color, this.checklist) {
    this.id = id;
    this.createdAt = createdAt;
    this.updatedAt = updatedAt;
    this.title = title;
    this.reminders = reminders;
    this.color = color;
    // this.activityType = activityType;
  }

  factory Checklist.fromJson(Map<String, dynamic> parsedJson) {
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
    return Checklist(
      parsedJson["id"],
      parsedJson["createdAt"],
      parsedJson["updatedAt"],
      parsedJson["title"],
      reminders,
      ColorOptions.values.byName(parsedJson["color"]),
      // ActivityType.values.byName(parsedJson["activityType"]),
      parsedJson["checklist"]
      ,
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
      "reminders": encodedReminders,
      // "activityType": activityType.name,
      "color": color.name,
      "checklist": checklist.toString(),
    };
  }



  static saveChecklists(List<Checklist> notes) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    List<String> notesEncoded =
    notes.map((note) => jsonEncode(note.toJson())).toList();
    await sharedPreferences.setStringList('checklists', notesEncoded);
  }

  static Future<List<Checklist>> loadChecklists() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final notesEncoded = sharedPreferences.getStringList('checklists');
    final List<Checklist> list = [];
    if (notesEncoded != null) {
      for (String string in notesEncoded) {
        final noteDecoded = jsonDecode(string);
        list.add(Checklist.fromJson(noteDecoded));
      }
    }
    return list;
  }

  @override
  String getContent() {
    // TODO: implement getContent
    throw UnimplementedError();
  }

  static Checklist copy(Checklist checklist) {
    List<Reminder> remindersCopy = [...checklist.reminders];
    return Checklist(checklist.id, checklist.updatedAt, checklist.createdAt, checklist.title,
        remindersCopy, checklist.color, checklist.checklist);
  }

}
