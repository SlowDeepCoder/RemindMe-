import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:remind_me/util/color_constants.dart';

import '../models/activity.dart';
import '../models/note.dart';

class ActivityItem extends StatefulWidget {
  final Key key;
  final Activity activity;
  final bool showDate;
  final String dateString;
  final Note? note;
  final Function(Note note) onActivityClicked;
  final Function(Activity activity) onActivityRemoved;
  final Function(Activity activity) onActivityChanged;

  const ActivityItem(this.activity, this.showDate, this.dateString, this.note,
      {required this.key,
      required this.onActivityClicked,
      required this.onActivityChanged,
      required this.onActivityRemoved})
      : super(key: key);

  @override
  State<ActivityItem> createState() => ActivityItemState();
}

class ActivityItemState extends State<ActivityItem> {
  @override
  Widget build(BuildContext context) {
    final noteTitle = widget.note != null ? widget.note!.title : "";
    final isCompleted = widget.activity.isCompleted;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Visibility(visible: widget.showDate, child: Text(widget.dateString)),
        Card(
            color: isCompleted == null ? ColorConstants.soil : isCompleted ? ColorConstants.soil.withGreen(100).withOpacity(0.5) : ColorConstants.soil.withRed(100).withOpacity(0.5),
            child: InkWell(
                onTap: () {
                  if (widget.note != null) {
                    widget.onActivityClicked(widget.note!);
                  }
                },
                child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(5),
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.activity.getTimeString() + " " + noteTitle,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              IconButton(
                                padding: EdgeInsets.all(4),
                                constraints: BoxConstraints(),
                                onPressed: () {
                                  setState(() {
                                    if (isCompleted == null ||
                                        isCompleted) {
                                      widget.activity.isCompleted = false;
                                      widget.onActivityChanged(widget.activity);
                                    } else {
                                      widget.activity.isCompleted = null;
                                      widget.onActivityRemoved(widget.activity);
                                    }
                                  });
                                },
                                icon: const Icon(Icons.close),
                                color: (isCompleted != null &&
                                        !isCompleted)
                                    ? Colors.red
                                    : ColorConstants.sand,
                              ),
                              IconButton(
                                padding: EdgeInsets.all(4),
                                constraints: BoxConstraints(),
                                onPressed: () {
                                  setState(() {
                                    if (isCompleted == null ||
                                        !isCompleted) {
                                      widget.activity.isCompleted = true;
                                      widget.onActivityChanged(widget.activity);
                                    } else {
                                      widget.activity.isCompleted = null;
                                      widget.onActivityRemoved(widget.activity);
                                    }
                                  });
                                },
                                icon: const Icon(Icons.check),
                                color: (isCompleted != null &&
                                        isCompleted)
                                    ? Colors.green
                                    : ColorConstants.sand,
                              )
                            ],
                          )
                        ],
                      ),
                    ))))
      ],
    );
  }
}
