import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:remind_me/services/date_service.dart';
import 'package:remind_me/managers/notification_manager.dart';
import 'package:remind_me/ui/models/activity.dart';
import 'package:remind_me/util/color_constants.dart';
import 'package:weekday_selector/weekday_selector.dart';
import '../dialogs/textfield_dialog.dart';
import '../models/checklist.dart';
import '../models/note.dart';
import '../models/reminder.dart';
import '../widgets/containers/background_container.dart';
import '../widgets/mole_image.dart';
import 'edit_activity_base_scaffold.dart';

class EditChecklistScreen extends StatefulWidget {
  static const double padding = 0;

  final Checklist? checklist;

  const EditChecklistScreen({Key? key, this.checklist}) : super(key: key);

  static const String routeName = "/editChecklist";

  @override
  State<EditChecklistScreen> createState() => _EditChecklistScreenState();
}

class _EditChecklistScreenState extends State<EditChecklistScreen> {
  final _activityScreenKey = GlobalKey<EditActivityBaseScaffoldState>();

  bool _hasBeenEdited = false;
  late final bool _isNewNote;
  late final Checklist checklist;

  @override
  void initState() {
    super.initState();

    Random().nextBool();
    _isNewNote = widget.checklist == null;
    if (widget.checklist != null) {
      checklist = Checklist.copy(widget.checklist!);
    } else {
      checklist = Checklist.create();
    }
  }

  @override
  void dispose() {
    // _textFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EditActivityBaseScaffold(
      onEdit: _onEdit,
      key: _activityScreenKey,
      activity: checklist,
      activityType: ActivityType.checklist,
      isNewActivity: _isNewNote,
      onAddActivity: _onAddChecklist,
      body:ReorderableListView.builder(
          itemCount: checklist.checklist.length + 1,
          onReorder: (startIndex, endIndex) {},
          itemBuilder: (context, index) {
            if (index >= checklist.checklist.length) {
              return ListTile(
                key: Key("add"),
                title: Text(
                  "Add new",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () async {
                  final text = await TextFieldDialog.show(context, "Checklist item", null);
                  if (text != null && text != "") {
                    setState(() {
                      checklist.checklist.add(ChecklistItem(text, false));
                    });
                    _onEdit();
                  }
                },
              );
            }
            final checklistItem = checklist.checklist[index];
            String text = checklistItem.text;
            return Material(
                key: Key(checklistItem.text),
                child: ListTile(
                  tileColor: _getColor(index, checklist.color),
                  title: Row(
                    children: [
                      Expanded(
                          child: Text(text,
                              style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  decorationThickness: 5,
                                  decoration: checklistItem.isChecked
                                      ? TextDecoration.lineThrough
                                      : null))),
                      IconButton(
                          onPressed: () async {
                            final text = await TextFieldDialog.show(
                                context, "Checklist item", checklist.checklist[index].text);
                            if (text != null && text != "") {
                              setState(() {
                                checklist.checklist[index].text = text;
                              });
                              _onEdit();
                            }
                          },
                          icon: Icon(Icons.edit),
                          color: Colors.blue),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              checklist.checklist.remove(checklistItem);
                            });
                            _onEdit();
                          },
                          icon: Icon(Icons.delete),
                          color: Colors.red)
                    ],
                  ),
                  onTap: () {
                    setState(() {
                      checklistItem.isChecked = !checklistItem.isChecked;
                    });
                    _onEdit();
                  },
                ));
          }),
      onColorChange: () {
        setState(() {});
      },
    );
  }

  Color _getColor(int index, ColorOptions colorOption){
    if(colorOption == ColorOptions.brown){
      return index % 2 == 0
          ? checklist.getColor()
          : checklist.getColor().darken(0.05);
    }
    else{
      return index % 2 == 0
          ? checklist.getColor().darken(0.1).withOpacity(0.9)
          : checklist.getColor().darken(0.25).withOpacity(0.9);
    }
  }

  Future<bool> _onAddChecklist() async {
    if(!_hasBeenEdited){
      Navigator.pop(context);
      return true;
    }
    checklist.title = _activityScreenKey.currentState != null
        ? _activityScreenKey.currentState!.titleController.text
        : "";
    checklist.updatedAt = DateService.getCurrentTimestamp();

    if (checklist.title == "") {
      checklist.title = "Untitled";
    }

    await NotificationManager.cancelReminders(checklist.reminders);
    await NotificationManager.setReminders(checklist);
    Navigator.pop(context, checklist);
    return true;
  }

  _onEdit(){
    setState(() {
      _hasBeenEdited = true;
    });
  }

}
