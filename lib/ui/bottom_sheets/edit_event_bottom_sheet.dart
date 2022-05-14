import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:remind_me/ui/models/activity.dart';

import '../../services/date_service.dart';
import '../../services/notification_service.dart';
import '../../util/color_constants.dart';
import '../models/event.dart';
import '../models/note.dart';
import '../models/reminder.dart';

class EditEventBottomSheet {
  static Future<Event?> showBottomSheet(
      BuildContext context, Event? event, DateTime? date) async {
    int? timestamp;
    if (date != null) {
      TimeOfDay initialTime = TimeOfDay.now();
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: initialTime,
      );
      if (pickedTime != null) {
        DateTime pickedDateTime = DateTime(date.year, date.month, date.day,
            pickedTime.hour, pickedTime.minute);
        timestamp = pickedDateTime.millisecondsSinceEpoch;

        final editedEvent = await showMaterialModalBottomSheet<Event?>(
            context: context,
            builder: (_) {
              return BottomSheet(event: event, timestamp: timestamp);
            });
        return editedEvent;
      }
    } else {
      final editedEvent = await showMaterialModalBottomSheet<Event?>(
          context: context,
          builder: (_) {
            return BottomSheet(event: event);
          });
      return editedEvent;
    }
  }
}

class BottomSheet extends StatefulWidget {
  final Event? event;
  final int? timestamp;

  const BottomSheet({Key? key, this.event, this.timestamp}) : super(key: key);

  @override
  State<BottomSheet> createState() => _BottomSheetState();
}

class _BottomSheetState extends State<BottomSheet> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _textController = TextEditingController();

  late final bool _isNewEvent;
  late final Event event;

  @override
  void initState() {
    super.initState();
    _isNewEvent = widget.event == null;
    if (widget.event != null) {
      event = Event.copy(widget.event!);
      // event = widget.event!;
      _titleController.text = event.title;
      _textController.text = event.text;
    } else {
      event = Event.create();
      if (widget.timestamp != null) {
        if (event.reminders.isEmpty) {
          final newReinder =
              Reminder.create(event.id, ActivityType.event, widget.timestamp!);
          event.addReminder(newReinder);
        }
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _titleController.dispose();
    _textController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: 5),
            child: Stack(
              children: [
                Align(
                    alignment: Alignment.center,
                    child: Text(
                      _isNewEvent ? "New Event" : "Edit Event",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                    )),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                      onPressed:
                          event.reminders.isEmpty ? null : _onCheckPressed,
                      icon: Icon(Icons.check),
                      color: ColorConstants.sand),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: TextField(
              strutStyle:
                  StrutStyle.fromTextStyle(TextStyle(color: Colors.white)),
              controller: _titleController,
              style: const TextStyle(color: ColorConstants.sand),
              decoration: InputDecoration(
                  hintText: "Title",
                  fillColor: ColorConstants.soil.withOpacity(0.5),
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
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _textController,
              minLines: 3,
              maxLines: null,
              style: const TextStyle(color: ColorConstants.sand),
              decoration: InputDecoration(
                  hintText: "Description",
                  fillColor: ColorConstants.soil.withOpacity(0.5),
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
          Padding(
              padding: const EdgeInsets.all(8),
              child: InkWell(
                  onTap: () => _onReminderClicked(),
                  child: SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                              child: Center(
                                  child: Text(
                            _getReminderString(),
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ))),
                        ]),
                  )))
        ],
      ),
    );
  }

  _onReminderClicked() {
    if (event.reminders.isNotEmpty) {
      _setReminder(event.reminders[0]);
    } else {
      _setReminder(null);
    }
  }

  _setReminder(Reminder? reminder) async {
    DateTime now = DateTime.now();
    DateTime inAYear = DateTime(now.year + 1, now.month, now.day);
    DateTime? pickedDate = await showDatePicker(
      context: context,
      lastDate: inAYear,
      initialDate: now,
      firstDate: now,
    );
    if (pickedDate != null) {
      TimeOfDay initialTime = TimeOfDay.now();
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: initialTime,
      );
      if (pickedTime != null) {
        DateTime pickedDateTime = DateTime(pickedDate.year, pickedDate.month,
            pickedDate.day, pickedTime.hour, pickedTime.minute);
        setState(() {
          if (reminder == null) {
            final newReinder = Reminder.create(event.id, ActivityType.event,
                pickedDateTime.millisecondsSinceEpoch);
            event.addReminder(newReinder);
          } else {
            reminder.timestamp = pickedDateTime.millisecondsSinceEpoch;
          }
          // _newReminders.add(reminder);
        });
      }
    }
  }

  String _getReminderString() {
    if (event.reminders.isNotEmpty) {
      return event.reminders[0].getTimeAndDateString();
    }
    return "No time set";
  }

  _onCheckPressed() async {
    if (event.reminders.isEmpty) return;
    event.title = _titleController.text;
    event.text = _textController.text;
    event.updatedAt = DateService.getCurrentTimestamp();

    if (event.title == "") {
      event.title = "Untitled";
    }

    await NotificationService.cancelReminders(event.reminders);
    await NotificationService.setReminders(event);
    Navigator.pop(context, event);
  }
}
