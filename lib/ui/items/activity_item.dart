import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:remind_me/util/color_constants.dart';
import 'package:simple_moment/simple_moment.dart';

import '../models/activity.dart';
import '../models/note.dart';

class ActivityItem extends StatefulWidget {
  final Key key;
  final Activity activity;
  final ValueChanged<bool> isSelected;
  final Function(Activity activity) onClick;

  const ActivityItem(this.activity, this.isSelected, this.onClick, this.key)
      : super(key: key);

  @override
  State<ActivityItem> createState() => ActivityItemState();
}

class ActivityItemState extends State<ActivityItem> {
  bool _isSelected = false;

  @override
  Widget build(BuildContext context) {
    return Card(
        // color: _isSelected ? ColorConstants.mole : ColorConstants.soil,
        color: _isSelected ? ColorConstants.mole : widget.activity.getDarkColor(),
        child: InkWell(
            onTap: () => widget.onClick(widget.activity),
            onLongPress: selectItem,
            child: Container(
                // height: 50,
                padding: const EdgeInsets.all(5),
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.activity.title,
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(widget.activity.runtimeType.toString()),
                      Text("Updated: " + Moment.fromMillisecondsSinceEpoch(widget.activity.updatedAt).fromNow(true) + " ago", style: TextStyle(fontSize: 12),),
                    ],
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
