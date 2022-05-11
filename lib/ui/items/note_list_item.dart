import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:remind_me/util/color_constants.dart';

import '../models/note.dart';

class NoteListItem extends StatefulWidget {
  final Key key;
  final Note note;
  final ValueChanged<bool> isSelected;
  final VoidCallback onClick;

  const NoteListItem(this.note, this.isSelected, this.onClick, this.key)
      : super(key: key);

  @override
  State<NoteListItem> createState() => NoteListItemState();
}

class NoteListItemState extends State<NoteListItem> {
  bool _isSelected = false;

  @override
  Widget build(BuildContext context) {
    return Card(
        color: _isSelected ? ColorConstants.mole : ColorConstants.soil,
        child: InkWell(
            onTap: widget.onClick,
            onLongPress: selectItem,
            child: Container(
                // height: 50,
                padding: const EdgeInsets.all(5),
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    widget.note.title,
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ))));
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
