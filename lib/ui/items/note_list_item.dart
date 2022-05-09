import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/note.dart';

class NoteListItem extends StatefulWidget {
  final Key key;
  final Note note;
  final ValueChanged<bool> isSelected;
  final VoidCallback onClick;

  const NoteListItem(
      this.note, this.isSelected, this.onClick, this.key)
      : super(key: key);

  @override
  State<NoteListItem> createState() => NoteListItemState();
}

class NoteListItemState extends State<NoteListItem> {
  bool _isSelected = false;

  @override
  Widget build(BuildContext context) {
    return Card(
        child: InkWell(
            onTap: widget.onClick,
            onLongPress: selectItem,
            child: Container(
              color: _isSelected ? Colors.yellow : Colors.white,
              height: 100,
              child: Column(children: <Widget>[
                Text(
                  widget.note.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                    width: double.infinity,
                    child: Text(
                      widget.note.text,
                      textAlign: TextAlign.start,
                    ))
              ]),
            )));
  }

  selectItem() {
    setState(() {
      _isSelected = !_isSelected;
      widget.isSelected(_isSelected);
    });
  }

  unselectItem() {
    setState(() {
    _isSelected = false;
    });
  }
}
