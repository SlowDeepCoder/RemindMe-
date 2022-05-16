import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:remind_me/main.dart';
import 'package:remind_me/util/color_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import '../ui/models/note.dart';
import '../ui/models/reminder.dart';
import '../ui/screens/home_screen.dart';

enum CompanionType { mole, pig }

class SettingsManager {
  late String _moleName;
  late String _piggyName;
  late CalendarFormat _calendarFormat;
  late CompanionType _companionType;
  late SortOptions _sortOption;
  SharedPreferences? _sharedPreferences;
  late final GlobalKey<MyAppState> myAppGlobalKey;

  static SettingsManager? _instance;

  SettingsManager._internal() {
  }



  void setCompanionName(String name){
    switch(companionType){
      case CompanionType.mole:
        moleName = name;
        break;
      case CompanionType.pig:
        piggyName = name;
        break;
    }
  }

  String getCompanionName(){
    switch(companionType){
      case CompanionType.mole:
        return _moleName;
      case CompanionType.pig:
        return _piggyName;
    }
  }

  Color getCompanionMainColor(){
    switch(companionType){
      case CompanionType.mole:
        return ColorConstants.soil;
      case CompanionType.pig:
        return Colors.pink.shade200;
    }
  }
  Color getCompanionTextColor(){
    switch(companionType){
      case CompanionType.mole:
        return ColorConstants.sand;
      case CompanionType.pig:
        return ColorConstants.sand;
    }
  }

  String getCompanionFaceImage(){
    switch(companionType){
      case CompanionType.mole:
        return "assets/images/cute_mole_face.png";
      case CompanionType.pig:
        return "assets/images/cute_piggy_face.png";
    }
  }

  String getCompanionBackgroundImage(){
    switch(companionType){
      case CompanionType.mole:
        return "assets/images/background_mole.jpg";
      case CompanionType.pig:
        return "assets/images/background_piggy.jpg";
    }
  }

   String getCompanionBodyImage(){
    switch(companionType){
      case CompanionType.mole:
        return "assets/images/mole.png";
      case CompanionType.pig:
        return "assets/images/piggy.png";
    }
  }


  static String getCompanionFaceImagee(CompanionType companionType){
    switch(companionType){
      case CompanionType.mole:
        return "assets/images/cute_mole_face.png";
      case CompanionType.pig:
        return "assets/images/cute_piggy_face.png";
    }
  }

  factory SettingsManager() => _instance ??= SettingsManager._internal();


  void setKey(GlobalKey<MyAppState> myAppGlobalKey) {
    this.myAppGlobalKey = myAppGlobalKey;
  }

  loadSettings() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    final loadedMoleName = _sharedPreferences?.getString('moleName');
    final loadedPiggyName = _sharedPreferences?.getString('pigName');
    final loadedCompanionType = _sharedPreferences?.getString('companionType');
    final loadedCalendarFormat = _sharedPreferences?.getString('calendarFormat');
    final loadedSortOption = _sharedPreferences?.getString('sortOption');

    _moleName = loadedMoleName ?? "Moley";
    _piggyName = loadedPiggyName ?? "Piggy";

    _companionType = loadedCompanionType != null
        ? CompanionType.values.byName(loadedCompanionType)
        : CompanionType.mole;

    _calendarFormat = loadedCalendarFormat != null
        ? CalendarFormat.values.byName(loadedCalendarFormat)
        : CalendarFormat.month;

    _sortOption = loadedSortOption != null
        ? SortOptions.values.byName(loadedSortOption)
        : SortOptions.updated;
  }

  CalendarFormat get calendarFormat => _calendarFormat;

  set calendarFormat(CalendarFormat value) {
    _calendarFormat = value;
    _sharedPreferences?.setString('calendarFormat', _calendarFormat.name);
  }

  String get moleName => _moleName;

  set moleName(String value) {
    _moleName = value;
    _sharedPreferences?.setString('moleName', _moleName);
  }

  String get piggyName => _piggyName;

  set piggyName(String value) {
    _piggyName = value;
    _sharedPreferences?.setString('pigName', _piggyName);
  }

  SortOptions get sortOption => _sortOption;

  set sortOption(SortOptions value) {
    _sortOption = value;
    _sharedPreferences?.setString('sortOption', _sortOption.name);
  }

  CompanionType get companionType => _companionType;

  set companionType(CompanionType value) {
    _companionType = value;
    _sharedPreferences?.setString('companionType', _companionType.name);
    myAppGlobalKey.currentState?.update();
  }
}
