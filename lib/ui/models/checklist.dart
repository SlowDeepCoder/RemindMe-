import 'dart:collection';
import 'dart:convert';

import 'package:remind_me/ui/models/activity.dart';
import 'package:remind_me/ui/models/reminder.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/date_service.dart';

class ChecklistItem {
  late String text;
  late bool isChecked;

  ChecklistItem(this.text, this.isChecked);


  factory ChecklistItem.fromJson(Map<String, dynamic> parsedJson) {
    return ChecklistItem(
        parsedJson["text"],
        parsedJson["isChecked"]);
  }

  Map<String, dynamic> toJson() {
    return {
      "text": text,
      "isChecked": isChecked,
    };
  }
}

class Checklist extends Activity {
  late final List<ChecklistItem> checklist;

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
      final reminder = Reminder(
          decodedReminder["id"],
          ActivityType.values.byName(decodedReminder["activityType"]),
          decodedReminder["timestamp"],
          decodedReminder["noteId"],
          decodedReminder["isCompleted"]);
      reminders.add(reminder);
    }
    final encodedChecklist = parsedJson["checklist"];
    final decodedChecklist = json.decode(encodedChecklist) as List;
    List<ChecklistItem> checklist = [];
    for (dynamic decodedChecklistItem in decodedChecklist) {
      final checklistItem = ChecklistItem(
          decodedChecklistItem["text"],
          decodedChecklistItem["isChecked"]);
      checklist.add(checklistItem);
    }
    return Checklist(
        parsedJson["id"],
        parsedJson["createdAt"],
        parsedJson["updatedAt"],
        parsedJson["title"],
        reminders,
        ColorOptions.values.byName(parsedJson["color"]),
        checklist);
  }

  Map<String, dynamic> toJson() {
    String encodedReminders =
    jsonEncode(reminders.map((value) => value.toJson()).toList())
        .toString();
    String encodedChecklists =
    jsonEncode(checklist.map((value) => value.toJson()).toList())
        .toString();
    return {
      "id": id,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
      "title": title,
      "reminders": encodedReminders,
      "color": color.name,
      "checklist": encodedChecklists,
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


  static Checklist? getChecklist(List<Checklist> checklists, String id) {
    for (Checklist checklist in checklists) {
      if (checklist.id == id) {
        return checklist;
      }
    }
    return null;
  }

  @override
  String getContent() {
    String content = "";
    return content;
  }

  static Checklist copy(Checklist checklist) {
    List<Reminder> remindersCopy = [...checklist.reminders];
    return Checklist(
        checklist.id,
        checklist.updatedAt,
        checklist.createdAt,
        checklist.title,
        remindersCopy,
        checklist.color,
        checklist.checklist);
  }
}
