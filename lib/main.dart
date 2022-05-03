import 'package:flutter/material.dart';
import 'package:remind_me/ui/models/note.dart';
import 'package:remind_me/ui/screens/home_screen.dart';
import 'package:remind_me/ui/screens/new_note_screen.dart';

void main() async{
  runApp(const MyApp());
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
        NewNoteScreen.routeName: (context) => NewNoteScreen(
            note: ModalRoute.of(context)!.settings.arguments != null
                ? ModalRoute.of(context)!.settings.arguments as Note
                : null)
      },
    );
  }
}
