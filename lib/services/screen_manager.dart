import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../ui/models/note.dart';
import '../ui/models/reminder.dart';

class ScreenManager {
  late double screenWidth;
  late double screenHeight;

  static ScreenManager? _instance;

  ScreenManager._internal();

  factory ScreenManager() =>
      _instance ??= ScreenManager._internal();


  setScreenWidth(double width){
    print("setting screen width");
    screenWidth = width;
  }

  setScreenHeight(double height){
    screenHeight = height;
  }
}
