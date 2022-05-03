import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/note.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NewNoteScreen extends StatefulWidget {
  final Note? note;

  const NewNoteScreen({Key? key, this.note}) : super(key: key);

  static const String routeName = "/newNote";

  @override
  State<NewNoteScreen> createState() => _NewNoteScreenState();
}

class _NewNoteScreenState extends State<NewNoteScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _textController.text = widget.note!.text;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("New note " + (widget.note?.id ?? "")),
        actions: <Widget>[
          IconButton(
              onPressed: () => onCheckPressed(), icon: const Icon(Icons.check))
        ],
      ),
      body: Column(
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
          )
        ],
      ),
    );
  }

  onCheckPressed() async {
    tz.initializeTimeZones();
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your channel id',
      'Reminders',
      channelDescription: 'Get reminders from your notes',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await FlutterLocalNotificationsPlugin().zonedSchedule(
        0,
        _titleController.text,
        _textController.text,
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
        platformChannelSpecifics,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: _titleController.text);

    if (_titleController.text != "" && _textController.text != "") {
      Navigator.pop(context,
          {"title": _titleController.text, "text": _textController.text});
    }
  }
}
