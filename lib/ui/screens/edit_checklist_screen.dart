import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:remind_me/services/date_service.dart';
import 'package:remind_me/services/notification_service.dart';
import 'package:remind_me/ui/models/activity.dart';
import 'package:remind_me/util/color_constants.dart';
import 'package:weekday_selector/weekday_selector.dart';
import '../models/checklist.dart';
import '../models/note.dart';
import '../models/reminder.dart';
import '../widgets/containers/background_container.dart';
import '../widgets/mole_image.dart';
import 'edit_activity_screen.dart';

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

  late final bool _isNewNote;
  late final Checklist checklist;

  @override
  void initState() {
    super.initState();
    _isNewNote = widget.checklist == null;
    if (widget.checklist != null) {
      checklist = Checklist.copy(widget.checklist!);
    } else {
      checklist = Checklist.create();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EditActivityBaseScaffold(
        key: _activityScreenKey,
        activity: checklist,
        activityType: ActivityType.checklist,
        isNewActivity: _isNewNote,
        onAddActivity: _onAddChecklist,
        body: Expanded(
          child: Padding(
            padding: const EdgeInsets.all(EditChecklistScreen.padding),
            child: Center(child: Text("Hej"),),
          ),
        ),);
  }


  Future<bool> _onAddChecklist() async {
    checklist.title = _activityScreenKey.currentState != null
        ? _activityScreenKey.currentState!.titleController.text
        : "";
    checklist.updatedAt = DateService.getCurrentTimestamp();

    if (checklist.title == "") {
      checklist.title = "Untitled";
    }

    await NotificationService.cancelReminders(checklist.reminders);
    await NotificationService.setReminders(checklist);
    Navigator.pop(context, checklist);
    return true;
  }
}
