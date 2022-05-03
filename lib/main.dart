import 'package:flutter/material.dart';

import 'Screens/HomeScreen.dart';
import 'Screens/NewNoteScreen.dart';

void main() {
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
      routes: {HomeScreen.routeName: (context) => const HomeScreen(),
        NewNoteScreen.routeName: (context) => const NewNoteScreen()},
    );
  }
}
