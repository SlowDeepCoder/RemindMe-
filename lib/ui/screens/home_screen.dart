import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:remind_me/ui/models/note.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'new_note_screen.dart';

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
    _initNotifications();
    _getNotes();
  }

  _getNotes() async {
    final notes = await Note.loadNotes();
    setState(() {
      this.notes.addAll(notes);
    });
  }

  _initNotifications() async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);
    var details =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if (details != null && details.didNotificationLaunchApp) {
      Navigator.of(context).pushNamed(NewNoteScreen.routeName);
    }
  }

  void selectNotification(String? payload) async {
    if (payload != null) {
      Navigator.pushNamed(context, NewNoteScreen.routeName);
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
    final result = await Navigator.pushNamed(context, NewNoteScreen.routeName,
        arguments: note) as Map<String, String>?;
    final title = result != null ? result["title"] : null;
    final text = result != null ? result["text"] : null;
    if (title != null && text != null) {
      setState(() {
        note.title = title;
        note.text = text;
      });
    }
    Note.saveNotes(notes);
  }

  _onFABClicked() async {
    final result = await Navigator.pushNamed(context, NewNoteScreen.routeName)
        as Map<String, String>?;
    final title = result != null ? result["title"] : null;
    final text = result != null ? result["text"] : null;
    if (title != null && text != null) {
      final note = Note.create(title, text);
      setState(() {
        notes.add(note);
      });
    }
    Note.saveNotes(notes);
  }
}
