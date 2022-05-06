import 'package:flutter/material.dart';
import 'package:remind_me/ui/models/note.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../flutter_local_notifications-9.4.1/lib/flutter_local_notifications.dart';
import '../../services/notification_service.dart';
import '../models/reminder.dart';
import 'edit_note_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  static const String routeName = "/";

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Note> notes = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {
    await _getNotes();
    await _initNotifications();
    _checkLatestNotification();
  }

  _getNotes() async {
    final notes = await Note.loadNotes();
    setState(() {
      this.notes.addAll(notes);
    });
  }

  _initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await FlutterLocalNotificationsPlugin().initialize(initializationSettings,

        onSelectNotification: _onSelectNotification);
  }

  _onSelectNotification(String? payload) async {
    if (payload != null) {
      for (Note note in notes) {
        if (note.id == payload) {
          _onNoteClicked(note);
        }
      }
    }
  }

  _checkLatestNotification() async {
    var details = await FlutterLocalNotificationsPlugin()
        .getNotificationAppLaunchDetails();
    if (details != null && details.didNotificationLaunchApp) {
      _onSelectNotification(details.payload);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("RemindMe!"),
      ),
      body: ListView.builder(
          itemCount: notes.length,
          itemBuilder: (context, index) {
            return Card(
                child: InkWell(
                    onTap: () => _onNoteClicked(notes[index]),
                    child: SizedBox(
                      height: 100,
                      child: Column(children: <Widget>[
                        Text(
                          notes[index].title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                            width: double.infinity,
                            child: Text(
                              notes[index].text,
                              textAlign: TextAlign.start,
                            ))
                      ]),
                    )));
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onFABClicked(),
        child: const Icon(Icons.add),
      ),
    );
  }

  _onNoteClicked(Note note) async {
    final editedNote = await Navigator.pushNamed(
        context, EditNoteScreen.routeName,
        arguments: note) as Note?;

    if (editedNote != null) {
      for (Note note in notes) {
        if (note.id == editedNote.id) {
          setState(() {
            note = editedNote;
          });
        }
      }
      Note.saveNotes(notes);
    }
    // final title = result != null ? result["title"] : null;
    // final text = result != null ? result["text"] : null;
    // if (title != null && text != null) {
    //   setState(() {
    //     note.title = title;
    //     note.text = text;
    //   });
    // }
  }

  _onFABClicked() async {
    final note =
        await Navigator.pushNamed(context, EditNoteScreen.routeName) as Note?;

    if (note != null) {
      setState(() {
        notes.add(note);
      });
      Note.saveNotes(notes);
    }
    //   final title = result != null ? result["title"] : null;
    //   final text = result != null ? result["text"] : null;
    //   if (title != null && text != null) {
    //     Reminder reminder = Reminder(_remindTimestamp, _reminderInterval, _recurringTimeUnit);
    //     final note = Note.create(title, text, null);
    //     setState(() {
    //       notes.add(note);
    //     });
    //   }
    //   Note.saveNotes(notes);
  }
}
