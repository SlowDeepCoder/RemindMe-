import 'package:flutter/material.dart';

import '../util/color_constants.dart';

class DateService {
  static int getCurrentTimestamp() {
    DateTime date = DateTime.now();
    return date.millisecondsSinceEpoch;
  }

  static Theme getDatePickerTheme(
      BuildContext context, Widget? child, Color color) {
    return Theme(
      data: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: color,
          brightness: Brightness.light,
        ),
        dialogBackgroundColor: ColorConstants.sand,
      ),
      child: child ?? Container(),
    );
  }
}
