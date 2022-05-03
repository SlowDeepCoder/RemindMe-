import 'package:flutter/material.dart';

class NewNoteScreen extends StatefulWidget {
  const NewNoteScreen({Key? key}) : super(key: key);

  static const String routeName = "/newNote";

  @override
  State<NewNoteScreen> createState() => _NewNoteScreenState();
}

class _NewNoteScreenState extends State<NewNoteScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New note"),
        actions: <Widget>[IconButton(onPressed: () => onCheckPressed(), icon: const Icon(Icons.check))],
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

  onCheckPressed(){
    if(_titleController.text != "" && _textController.text != ""){
      Navigator.pop(context);
    }
  }
}
