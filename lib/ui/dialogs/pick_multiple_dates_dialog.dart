import 'package:flutter/material.dart';
import 'package:remind_me/managers/screen_manager.dart';
import 'package:remind_me/ui/models/activity.dart';
import 'package:remind_me/util/color_constants.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class PickMultipleDatesDialog {
  static Future<List<DateTime>?> show(BuildContext context) async {
    final dates = await showDialog(
        context: context,
        builder: (context) {
          return PickMultipleDatesAlertDialog();
        }) as List<DateTime>?;
    return dates;
  }
}

class PickMultipleDatesAlertDialog extends StatefulWidget {
  const PickMultipleDatesAlertDialog({Key? key}) : super(key: key);

  @override
  State<PickMultipleDatesAlertDialog> createState() =>
      _PickMultipleDatesAlertDialogState();
}

class _PickMultipleDatesAlertDialogState
    extends State<PickMultipleDatesAlertDialog> {
  List<DateTime>? selectedDays;

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
        title: Text('Pick a color', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
        content: Container(
          width: 200,
          height: 300,
          child: SfDateRangePicker(
            onSelectionChanged: (args){
              selectedDays = args.value as List<DateTime>;
        },
            selectionMode: DateRangePickerSelectionMode.multiple,),
        ),
        actions: <Widget>[
          ElevatedButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          ElevatedButton(
              child: Text('OK'),
              onPressed: () {
                  Navigator.pop(context, selectedDays);
              }),
        ]);
  }
}
