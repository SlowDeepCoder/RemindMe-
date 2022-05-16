import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:remind_me/services/date_service.dart';
import 'package:remind_me/managers/notification_manager.dart';
import 'package:remind_me/util/color_constants.dart';
import 'package:weekday_selector/weekday_selector.dart';
import '../models/note.dart';
import '../models/reminder.dart';
import '../widgets/containers/background_container.dart';
import '../widgets/mole_image.dart';
import 'edit_activity_base_scaffold.dart';


class EditNoteScreen extends StatefulWidget {
  static const double padding = 0;

  final Note? note;

  const EditNoteScreen({Key? key, this.note}) : super(key: key);

  static const String routeName = "/editNote";

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  final TextEditingController _textController = TextEditingController();
  final _activityScreenKey = GlobalKey<EditActivityBaseScaffoldState>();

  bool _hasBeenEdited = false;
  late final bool _isNewNote;
  late final Note note;

  @override
  void initState() {
    super.initState();
    _isNewNote = widget.note == null;
    if (widget.note != null) {
      note = Note.copy(widget.note!);
      _textController.text = note.text;
    } else {
      note = Note.create();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _textController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EditActivityBaseScaffold(
      onEdit:
      _onEdit,
        key: _activityScreenKey,
        activity: note,
        onColorChange: () {
          setState(() {});
        },
        activityType: ActivityType.note,
        isNewActivity: _isNewNote,
        onAddActivity: _onAddNote,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
         Expanded(
          child: Padding(
            padding: const EdgeInsets.all(EditNoteScreen.padding),
            child: TextField(
              onChanged: (text) => _onEdit(),
              keyboardType: TextInputType.multiline,
              controller: _textController,
              expands: true,
              maxLines: null,
              textAlignVertical: TextAlignVertical.top,
              style: const TextStyle(color: ColorConstants.sand),
              decoration: InputDecoration(
                  hintText: "Text",
                  // fillColor: ColorConstants.soil.withOpacity(0.5),
                  fillColor: note.getColor().darken(0.3).withOpacity(0.1),
                  filled: true,
                  hintStyle:
                      TextStyle(color: ColorConstants.sand.withOpacity(0.5)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        width: 1.5,
                        color: ColorConstants.sand.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        width: 2, color: ColorConstants.sand.withOpacity(0.8)),
                    borderRadius: BorderRadius.circular(5),
                  )),
            ),
          ),
        ) ],
        ));
  }


  Future<bool> _onAddNote() async {
    if(!_hasBeenEdited){
      Navigator.pop(context);
      return true;
    }
    note.title = _activityScreenKey.currentState != null
        ? _activityScreenKey.currentState!.titleController.text
        : "";
    note.text = _textController.text;
    note.updatedAt = DateService.getCurrentTimestamp();

    if (note.title == "") {
      note.title = "Untitled";
    }

    await NotificationManager.cancelReminders(note.reminders);
    await NotificationManager.setReminders(note);
    Navigator.pop(context, note);
    return true;
  }


  _onEdit(){
    setState(() {
    _hasBeenEdited = true;
    });
  }

}
