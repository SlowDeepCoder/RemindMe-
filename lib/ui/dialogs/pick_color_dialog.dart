import 'package:flutter/material.dart';
import 'package:remind_me/managers/screen_manager.dart';
import 'package:remind_me/ui/models/activity.dart';
import 'package:remind_me/util/color_constants.dart';

class PickColorDialog {
  static Future<ColorOptions?> show(BuildContext context, ColorOptions colorOption) async {
    final color = await showDialog(
        context: context,
        builder: (context) {
          return PickColorDialogAlertDialog(colorOption: colorOption);
        }) as ColorOptions?;
    return color;
  }
}

class PickColorDialogAlertDialog extends StatefulWidget {
  final ColorOptions colorOption;
  const PickColorDialogAlertDialog({Key? key, required this.colorOption}) : super(key: key);

  @override
  State<PickColorDialogAlertDialog> createState() =>
      _PickColorDialogAlertDialogState();
}

class _PickColorDialogAlertDialogState
    extends State<PickColorDialogAlertDialog> {
  late ColorOptions colorOption;
  late int _pickedIndex;

  @override
  void initState() {
    colorOption = widget.colorOption;
    for(int i = 0; i < ColorOptions.values.length; i++){
      if(ColorOptions.values[i] == colorOption){
        _pickedIndex = i;
        break;
      }
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Activity.getDarkColorFromColorOption(ColorOptions.values[_pickedIndex]),
        title: Text('Pick a color', style: TextStyle(color: ColorConstants.sand, fontSize: 25, fontWeight: FontWeight.bold),),
        content: Container(
          color: Activity.getDarkColorFromColorOption(ColorOptions.values[_pickedIndex]),
            width: ScreenManager().screenWidth * .7,
            height: ScreenManager().screenWidth * .7,
            child: GridView.count(
              crossAxisCount: 3,
              children: List.generate(ColorOptions.values.length, (index) {
                final color = ColorOptions.values[index];
                return Container(
                    color: _pickedIndex == index ? Colors.blue : null,
                    padding: EdgeInsets.all(6),
                    width: 25,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _pickedIndex = index;
                        });
                      },
                      child: Card(
                        color: Activity.getColorFromColorOption(color),
                      ),
                    ));
              }),
            )),
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
                  Navigator.pop(context, ColorOptions.values[_pickedIndex]);

              }),
        ]);
  }
}
