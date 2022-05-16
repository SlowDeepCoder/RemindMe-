import 'package:flutter/material.dart';
import 'package:remind_me/managers/screen_manager.dart';
import 'package:remind_me/managers/settings_manager.dart';
import 'package:remind_me/ui/models/activity.dart';
import 'package:remind_me/util/color_constants.dart';

class PickCompanionTypeDialog {
  static Future<CompanionType?> show(BuildContext context) async {
    final companionType = await showDialog(
        context: context,
        builder: (context) {
          return PickCompanionTypeAlertDialog();
        }) as CompanionType?;
    return companionType;
  }
}

class PickCompanionTypeAlertDialog extends StatefulWidget {
  const PickCompanionTypeAlertDialog({Key? key}) : super(key: key);

  @override
  State<PickCompanionTypeAlertDialog> createState() =>
      _PickCompanionTypeAlertDialogState();
}

class _PickCompanionTypeAlertDialogState
    extends State<PickCompanionTypeAlertDialog> {
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
    return AlertDialog(
        title: Text('Pick a companion', style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold),),
        content: Container(
            width: ScreenManager().screenWidth * .7,
            height: ScreenManager().screenWidth * .5,
            child: ListView.builder(
                itemCount: CompanionType.values.length,
                itemBuilder: (context, index) {

              return ListTile(
                  onTap: (){
                    Navigator.pop(context, CompanionType.values[index]);
                  },

                  leading: Image.asset(
                    SettingsManager.getCompanionFaceImagee(CompanionType.values[index]), width: 40,),
                  title: Text(CompanionType.values[index].name));
            })),
        // actions: <Widget>[
        //   ElevatedButton(
        //     child: Text('Cancel'),
        //     onPressed: () {
        //       Navigator.pop(context);
        //     },
        //   ),
        //   ElevatedButton(
        //       child: Text('OK'),
        //       onPressed: () {
        //         Navigator.pop(context, ColorOptions.values[_pickedIndex]);
        //       }),
        // ]
    );
  }
}
