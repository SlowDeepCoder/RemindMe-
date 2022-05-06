import 'package:flutter/material.dart';
import 'package:remind_me/services/notification_service.dart';
import '../models/note.dart';
import '../models/reminder.dart';

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
  late final _isNewNote;
  String _reminderTime = "";
  int? _reminderTimeStamp;

  @override
  void initState() {
    super.initState();
    _isNewNote = widget.note == null;
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _textController.text = widget.note!.text;
      _reminderTimeStamp = widget.note!.reminder.timestamp;
      if (_reminderTimeStamp != null) {
        DateTime dateTime =
            DateTime.fromMillisecondsSinceEpoch(_reminderTimeStamp!);
        _reminderTime = dateTime.toString();
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
    return Scaffold(
      appBar: AppBar(
        title: Text(_isNewNote
            ? "New note"
            : "Edit note #" + (widget.note?.id.toString() ?? "")),
        actions: <Widget>[
          IconButton(
              onPressed: () => _onCheckPressed(), icon: const Icon(Icons.check))
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Title",
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _textController,
              minLines: 10,
              maxLines: 100,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                hintText: "Note",
              ),
            ),
          ),
          Padding(
              padding: const EdgeInsets.all(8),
              child: SizedBox(
                height: 50,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                      Expanded(child: InkWell(
                          onTap: _setReminderTime,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Text(
                                "Reminder",
                              ),
                              Text(_reminderTime)
                            ],
                          ))),
                      IconButton(
                          onPressed: _removeReminderTime,
                          color: Colors.red,
                          icon: const Icon(Icons.delete))
                    ]),
              ))
        ],
      ),
    );
  }

  _setReminderTime() async {
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
          _reminderTimeStamp = pickedDateTime.millisecondsSinceEpoch;
          _reminderTime = pickedDateTime.toString();
        });
      }
    }
  }

  _removeReminderTime() {
    setState(() {
      _reminderTimeStamp = null;
      _reminderTime = "";
    });
  }

  _onCheckPressed() async {
    if (_titleController.text != "" && _textController.text != "") {
      Reminder reminder;
      Note note;
      if (_isNewNote) {
        reminder = Reminder(_reminderTimeStamp, 0, TimeUnits.minute);
        note =
            Note.create(_titleController.text, _textController.text, reminder);
      } else {
        note = widget.note!;
        note.title = _titleController.text;
        note.text = _textController.text;
        note.reminder.timestamp = _reminderTimeStamp;
      }
      await NotificationService.setNotification(note);
      Navigator.pop(context, note);
    }
  }
}
