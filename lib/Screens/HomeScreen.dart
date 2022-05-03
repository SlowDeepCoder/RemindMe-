import 'package:flutter/material.dart';
import 'package:remind_me/Screens/NewNoteScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  static const String routeName = "/";

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("RemindMe!"),
      ),
      body: Container(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onFABClicked(),
        child: const Icon(Icons.add),
      ),
    );
  }

  _onFABClicked(){
    Navigator.pushNamed(context, NewNoteScreen.routeName);
  }
}
