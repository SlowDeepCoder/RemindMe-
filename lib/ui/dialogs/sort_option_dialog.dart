import 'package:flutter/material.dart';
import 'package:remind_me/managers/screen_manager.dart';
import 'package:remind_me/ui/models/note.dart';

import '../models/activity.dart';

class SortOptionDialog {
  static Future<SortOptions?> show(BuildContext context, SortOptions loadedSortOption) async {
    final sortOption = await showDialog(
        context: context,
        builder: (context) {
          return SortOptionAlertDialog(sortOption:loadedSortOption);
        }) as SortOptions?;
    return sortOption;
  }
}

class SortOptionAlertDialog extends StatefulWidget {
  final SortOptions sortOption;

  const SortOptionAlertDialog({Key? key, required this.sortOption}) : super(key: key);

  @override
  State<SortOptionAlertDialog> createState() =>
      _SortOptionAlertDialogState();
}

class _SortOptionAlertDialogState extends State<SortOptionAlertDialog> {
   late SortOptions? _pickedSortOption;

  @override
  void initState() {
    super.initState();
    _pickedSortOption = widget.sortOption;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = ScreenManager().screenWidth * 0.7;
    return AlertDialog(
        title: Text("Sort by", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        content: Container(width: width,height: width, child: ListView.builder(
            itemCount: SortOptions.values.length,
            itemBuilder: (context, index){
              final sortOption = SortOptions.values[index];
          return RadioListTile<SortOptions>(
            title: Text(Activity.getNameFromSortOption(sortOption)),
            value: sortOption,
            groupValue: _pickedSortOption,
            onChanged: (SortOptions? value) {
              setState(() {
                _pickedSortOption = value;
              });
            },
          );
        }),),
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
              Navigator.pop(context, _pickedSortOption);
            },
          ),
        ]);
    ;
  }
}
