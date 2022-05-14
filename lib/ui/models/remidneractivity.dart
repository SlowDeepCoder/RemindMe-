// import 'dart:convert';
// import 'dart:math';
//
// import 'package:collection/collection.dart';
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import 'note.dart';
//
// class ReminderActivity {
//   final String noteId;
//   int timestamp;
//   bool? isCompleted;
//   bool isNote;
//
//   ReminderActivity(this.noteId, this.timestamp, this.isCompleted, this.isNote);
//
//
//   String getTimeAndDateString() {
//     final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
//     final dateString = DateFormat('HH:mm, dd MMM yyyy').format(date);
//     return dateString;
//   }
//
//   String getTimeString() {
//     final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
//     final dateString = DateFormat('HH:mm').format(date);
//     return dateString;
//   }
//
//   factory ReminderActivity.fromJson(Map<String, dynamic> parsedJson) {
//     return ReminderActivity(
//       parsedJson["noteId"],
//       parsedJson["timestamp"],
//       parsedJson["isCompleted"],
//       parsedJson["isNote"],
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       "noteId": noteId,
//       "timestamp": timestamp,
//       "isCompleted": isCompleted,
//       "isNote": isNote,
//     };
//   }
//
//   bool isEqual(ReminderActivity savedActivity) {
//     if (savedActivity.noteId == noteId){
//       if(savedActivity.timestamp == timestamp){
//         return true;
//       }
//     }
//     return false;
//   }
//
//
//
//   static saveActivity(ReminderActivity activity) async {
//     final savedActivities = await ReminderActivity.loadActivities();
//
//     for (ReminderActivity savedActivity in savedActivities) {
//       if (savedActivity.isEqual(activity)) {
//         savedActivities.remove(savedActivity);
//         break;
//       }
//     }
//     savedActivities.add(activity);
//     ReminderActivity.saveActivities(savedActivities);
//   }
//
//
//   static saveActivities(List<ReminderActivity> activities) async {
//     SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
//     List<String> encodedActivities =
//     activities.map((activity) => jsonEncode(activity.toJson())).toList();
//     print(encodedActivities);
//     await sharedPreferences.setStringList('activities', encodedActivities);
//   }
//
//   static Future<List<ReminderActivity>> loadActivities() async {
//     SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
//     final encodedActivities = sharedPreferences.getStringList('activities');
//     final List<ReminderActivity> list = [];
//     if (encodedActivities != null) {
//       for (String string in encodedActivities) {
//         final decodedActivities = jsonDecode(string);
//         list.add(ReminderActivity.fromJson(decodedActivities));
//       }
//     }
//     return list;
//   }
//
//
//   static List<ReminderActivity> sortActivities(List<ReminderActivity> activities) {
//     activities.sort((a, b) {
//       return Comparable.compare(a.timestamp, b.timestamp);
//     });
//     return activities;
//   }
// }
