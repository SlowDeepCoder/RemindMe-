import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:remind_me/ui/dialogs/pick_compation_type_dialog.dart';
import 'package:remind_me/util/color_constants.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../managers/settings_manager.dart';
import '../../util/calendar_utils.dart';
import '../dialogs/textfield_dialog.dart';

class SettingsPage extends StatefulWidget {
  final Function() onCompanionChanged;
  const SettingsPage({Key? key, required this.onCompanionChanged}) : super(key: key);

  @override
  State<SettingsPage> createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  final settingsManager = SettingsManager();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SettingsList(
      lightTheme: SettingsThemeData(
          titleTextColor: ColorConstants.sand,
          trailingTextColor: ColorConstants.sand,
          settingsTileTextColor: ColorConstants.sand,
          tileDescriptionTextColor: ColorConstants.sand,
          leadingIconsColor: ColorConstants.sand,
          settingsListBackground: Colors.transparent
      ),
      sections: [
        SettingsSection(
          title: Text('Common'),
          tiles: <SettingsTile>[
            SettingsTile.navigation(
              leading: Image.asset(settingsManager.getCompanionFaceImage(), width: 40,),
              title: Text('Companion Type'),
              value: Text(settingsManager.companionType.name),
              onPressed: (context) async {
                final companionType = await PickCompanionTypeDialog.show(context);
                if(companionType != null){
                  setState(() {
                    settingsManager.companionType = companionType;
                    widget.onCompanionChanged();
                  });
                }
              },
            ),
            SettingsTile.navigation(
              leading: Image.asset(settingsManager.getCompanionBodyImage(), width: 40,),
              title: Text('Companion Name'),
              value: Text(settingsManager.getCompanionName()),
              onPressed: (context) async {
                final text = await TextFieldDialog.show(context, "Companion name", settingsManager.getCompanionName());
                if(text != null){
                  setState(() {
                    settingsManager.setCompanionName(text);
                  });
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  AppBar getAppBar(AppBar standardAppBar) {
    return standardAppBar;
  }
}
