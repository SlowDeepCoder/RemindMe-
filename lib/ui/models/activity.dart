import 'dart:convert';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'note.dart';

class Activity {
  final String noteId;
  int timestamp;
  bool? isCompleted;

  Activity(this.noteId, this.timestamp, this.isCompleted);


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

  factory Activity.fromJson(Map<String, dynamic> parsedJson) {
    return Activity(
      parsedJson["noteId"],
      parsedJson["timestamp"],
      parsedJson["isCompleted"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "noteId": noteId,
      "timestamp": timestamp,
      "isCompleted": isCompleted,
    };
  }

  bool isEqual(Activity savedActivity) {
    if (savedActivity.noteId == noteId){
      if(savedActivity.timestamp == timestamp){
        return true;
      }
    }
    return false;
  }


  static saveActivities(List<Activity> activities) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    List<String> encodedActivities =
    activities.map((activity) => jsonEncode(activity.toJson())).toList();
    print(encodedActivities);
    await sharedPreferences.setStringList('activities', encodedActivities);
  }

  static Future<List<Activity>> loadActivities() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final encodedActivities = sharedPreferences.getStringList('activities');
    final List<Activity> list = [];
    if (encodedActivities != null) {
      for (String string in encodedActivities) {
        final decodedActivities = jsonDecode(string);
        list.add(Activity.fromJson(decodedActivities));
      }
    }
    return list;
  }
}
