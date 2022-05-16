import 'package:flutter/material.dart';

class TextFieldDialog {
  static Future<String?> show(BuildContext context, String title, String? oldText) async {
    final text = await showDialog(
        context: context,
        builder: (context) {
          return TextFieldAlertDialog(oldText: oldText, title:title);
        }) as String?;
    return text;
  }
}

class TextFieldAlertDialog extends StatefulWidget {
  final String title;
  final String? oldText;

  const TextFieldAlertDialog({Key? key, required this.title, this.oldText}) : super(key: key);

  @override
  State<TextFieldAlertDialog> createState() =>
      _TextFieldAlertDialogState();
}

class _TextFieldAlertDialogState extends State<TextFieldAlertDialog> {
  final TextEditingController _textFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.oldText != null) {
      _textFieldController.text = widget.oldText!;
    }
  }

  @override
  void dispose() {
    _textFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text(widget.title),
        content: TextField(
          autofocus: true,
          onChanged: (value) {},
          controller: _textFieldController,
          decoration: InputDecoration(hintText: "Text"),
        ),
        actions: <Widget>[
          ElevatedButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          ElevatedButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.pop(context, _textFieldController.text);
            },
          ),
        ]);
    ;
  }
}
