import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:remind_me/services/notification_service.dart';
import 'package:remind_me/ui/models/note.dart';
import 'package:remind_me/ui/screens/home_screen.dart';
import 'package:remind_me/ui/screens/edit_note_screen.dart';

void main() async {
  runApp(const MyApp());
  NotificationService.triggerTestNotification();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: "/",
      routes: {
        HomeScreen.routeName: (context) => const HomeScreen(),
        EditNoteScreen.routeName: (context) => EditNoteScreen(
            note: ModalRoute.of(context)!.settings.arguments != null
                ? ModalRoute.of(context)!.settings.arguments as Note
                : null)
      },
    );
  }
}
