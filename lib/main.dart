import 'package:flutter/material.dart';
import 'package:remind_me/ui/models/note.dart';
import 'package:remind_me/ui/screens/home_screen.dart';
import 'package:remind_me/ui/screens/edit_note_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) {
        if (child != null) {
          return MediaQuery(
              data:
                  MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
              child: child);
        } else {
          return Container();
        }
      },
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: "/",
      routes: {
        HomeScreen.routeName: (context) => const HomeScreen(),
        EditNoteScreen.routeName: (context) => EditNoteScreen(
            note: ModalRoute.of(context)!.settings.arguments as Note?)
      },
    );
  }
}
