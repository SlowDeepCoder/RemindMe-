import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:remind_me/services/date_service.dart';
import 'package:remind_me/services/notification_service.dart';
import 'package:remind_me/util/color_constants.dart';
import 'package:weekday_selector/weekday_selector.dart';
import '../models/note.dart';
import '../models/reminder.dart';
import '../widgets/containers/background_container.dart';

class EditNoteScreen extends StatefulWidget {
  final Note? note;

  const EditNoteScreen({Key? key, this.note}) : super(key: key);

  static const String routeName = "/newNote";

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _textController = TextEditingController();
  final List<Reminder> _removedReminders = [];
  final List<Reminder> _newReminders = [];
  late final bool _isNewNote;
  late final Note note;

  @override
  void initState() {
    super.initState();
    _isNewNote = widget.note == null;
    if (widget.note != null) {
      note = Note.copy(widget.note!);
      _titleController.text = note.title;
      _textController.text = note.text;
    } else {
      note = Note.create();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _titleController.dispose();
    _textController.dispose();
    // print(note.isEqual(widget.note));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isNewNote ? "New note" : "Edit note #" + (note.id)),
        actions: <Widget>[
          IconButton(
              onPressed: () => _onCheckPressed(), icon: const Icon(Icons.check))
        ],
      ),
      body: BackgroundContainer(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8),
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
              minLines: 2,
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
          Expanded(
              child: ListView.builder(
                  itemCount: note.reminders.length,
                  itemBuilder: (context, index) {
                    final reminder = note.reminders[index];

                    return Padding(
                        padding: const EdgeInsets.all(8),
                        child: SizedBox(
                          height: 50,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(
                                    child: InkWell(
                                        onTap: () => {},
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            const Text(
                                              "Reminder",
                                            ),
                                            Text(
                                                reminder.getTimeAndDateString())
                                          ],
                                        ))),
                                IconButton(
                                    onPressed: () {
                                      NotificationService.sendTestReminder(
                                          reminder, note);
                                    },
                                    color: Colors.blueAccent,
                                    icon: const Icon(
                                        Icons.notification_important_rounded)),
                                IconButton(
                                    onPressed: () {
                                      setState(() {
                                        note.reminders.remove(reminder);
                                        _removedReminders.add(reminder);
                                      });
                                    },
                                    color: Colors.red,
                                    icon: const Icon(Icons.delete))
                              ]),
                        ));
                  })),
          // Padding(
          //     padding: EdgeInsets.all(10),
          //     child: ElevatedButton(
          //       onPressed: () => {
          //         if (!_isNewNote)
          //           NotificationService.triggerTestNotification(widget.note!)
          //       },
          //       child: Text("Trigger Notification"),
          //       style:
          //           ElevatedButton.styleFrom(minimumSize: Size.fromHeight(40)),
          //     )),
          Padding(
              padding: const EdgeInsets.all(10),
              child: ElevatedButton(
                onPressed: _addNewReminder,
                child: const Text("Add reminder"),
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(40)),
              ))
        ],
      )),
    );
  }

  _addNewReminder() {
    showMaterialModalBottomSheet(
      context: context,
      builder: (_) => Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              InkWell(
                  onTap: _addSingleReminder,
                  child: const SizedBox(
                    height: 50,
                    child: Center(child: Text('Single reminder')),
                  )),
              InkWell(
                  onTap: _addRecurringReminder,
                  child: const SizedBox(
                    height: 50,
                    child: Center(child: Text('Weekly reminder')),
                  )),
              InkWell(
                  onTap: _addRecurringReminder,
                  child: const SizedBox(
                    height: 50,
                    child: Center(child: Text('Monthly reminder')),
                  )),
            ],
          )),
    );
  }

  _addSingleReminder() async {
    Navigator.of(context).pop();
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
        final reminder = Reminder.create(false, note.id,
            pickedDateTime.millisecondsSinceEpoch);
        setState(() {
          note.addReminder(reminder);
          _newReminders.add(reminder);
        });
      }
    }
  }

  _addRecurringReminder() async {
    Navigator.of(context).pop();
    final days = List.filled(7, false);
    final hasChosenDays = await showMaterialModalBottomSheet(
        context: context,
        builder: (_) => StatefulBuilder(
            builder: (_, setState) => Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                          padding: EdgeInsets.only(top: 10),
                          child: WeekdaySelector(
                            onChanged: (int day) {
                              setState(() {
                                final index = day % 7;
                                days[index] = !days[index];
                              });
                            },
                            values: days,
                          )),
                      Container(
                          padding: EdgeInsets.all(10),
                          child: ElevatedButton(
                              onPressed: () {
                                for (bool day in days) {
                                  if (day) {
                                    Navigator.of(context).pop(true);
                                    return;
                                  }
                                }
                                Navigator.of(context).pop(false);
                              },
                              child: Text("Ok")))
                    ])));

    if (hasChosenDays != null && hasChosenDays) {
      TimeOfDay initialTime = TimeOfDay.now();
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: initialTime,
      );
    }
  }

  _onCheckPressed() async {
    note.title = _titleController.text;
    note.text = _textController.text;
    note.updatedAt = DateService.getCurrentTimestamp();

    if (note.title == "") {
      note.title = "Untitled";
    }

    NotificationService.cancelReminders(_removedReminders);
    NotificationService.setReminders(_newReminders, note);
    Navigator.pop(context, note);
  }
}
