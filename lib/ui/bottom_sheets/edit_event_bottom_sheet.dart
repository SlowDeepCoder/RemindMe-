import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:remind_me/ui/models/activity.dart';
import 'package:remind_me/ui/screens/edit_activity_base_scaffold.dart';

import '../../services/date_service.dart';
import '../../managers/notification_manager.dart';
import '../../util/color_constants.dart';
import '../dialogs/pick_color_dialog.dart';
import '../models/event.dart';
import '../models/note.dart';
import '../models/reminder.dart';

class EditEventBottomSheet {
  static Future<Event?> showBottomSheet(BuildContext context, Event? event,
      DateTime? date, Function()? onDeleteEvent) async {
    int? timestamp;
    if (date != null) {
      TimeOfDay initialTime = TimeOfDay.now();
      TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: initialTime,
          builder: (context, child) => DateService.getDatePickerTheme(
              context,
              child,
              event != null
                  ? event.getDarkColor()
                  : Activity.getColorFromColorOption(ColorOptions.brown)));
      if (pickedTime != null) {
        DateTime pickedDateTime = DateTime(date.year, date.month, date.day,
            pickedTime.hour, pickedTime.minute);
        timestamp = pickedDateTime.millisecondsSinceEpoch;

        final editedEvent = await showMaterialModalBottomSheet<Event?>(
            context: context,
            builder: (_) {
              return BottomSheet(
                event: event,
                timestamp: timestamp,
                onDeleteEvent: onDeleteEvent,
              );
            });
        return editedEvent;
      }
    } else {
      final editedEvent = await showMaterialModalBottomSheet<Event?>(
          context: context,
          builder: (_) {
            return BottomSheet(
              event: event,
              onDeleteEvent: onDeleteEvent,
            );
          });
      return editedEvent;
    }
  }
}

class BottomSheet extends StatefulWidget {
  final Event? event;
  final int? timestamp;
  final Function()? onDeleteEvent;

  const BottomSheet(
      {Key? key, this.event, this.timestamp, required this.onDeleteEvent})
      : super(key: key);

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
      color: event.getDarkColor(),
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
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                        iconSize: 35,
                        onPressed:
                            _isNewEvent ? null : () => _onDeletePressed(event),
                        icon: Icon(Icons.delete),
                        color: Colors.red)),
                Align(
                    alignment: Alignment.center,
                    child: Text(
                      _isNewEvent ? "New Event" : "Edit Event",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                    )),
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                          onTap: () async {
                            final color = await PickColorDialog.show(context, event.color);
                            if (color != null) {
                              setState(() {
                                event.color = color;
                              });
                            }
                          },
                          child: Container(
                              padding: EdgeInsets.all(6),
                              width: 55,
                              height: 55,
                              child: Card(
                                color: event.getColor(),
                              ))),
                      IconButton(
                        iconSize: 40,
                          onPressed:
                              event.reminders.isEmpty ? null : _onCheckPressed,
                          icon: Icon(Icons.check),
                          color: Colors.green)
                    ],
                  ),
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
        builder: (context, child) => DateService.getDatePickerTheme(
            context,
            child,
            event.getDarkColor())
    );
    if (pickedDate != null) {
      TimeOfDay initialTime = TimeOfDay.now();
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: initialTime,
          builder: (context, child) => DateService.getDatePickerTheme(
            context,
            child,
            event.getDarkColor())
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

  _onDeletePressed(Event event) {
    widget.onDeleteEvent!();
    Navigator.pop(context);
  }

  _onCheckPressed() async {
    if (event.reminders.isEmpty) return;
    event.title = _titleController.text;
    event.text = _textController.text;
    event.updatedAt = DateService.getCurrentTimestamp();

    if (event.title == "") {
      event.title = "Untitled";
    }

    await NotificationManager.cancelReminders(event.reminders);
    await NotificationManager.setReminders(event);
    Navigator.pop(context, event);
  }
}
