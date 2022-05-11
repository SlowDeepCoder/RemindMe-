import 'dart:convert';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:intl/intl.dart';

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
}
