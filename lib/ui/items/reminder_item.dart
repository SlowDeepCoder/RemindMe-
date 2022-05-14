import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:remind_me/util/color_constants.dart';

import '../models/activity.dart';
import '../models/remidneractivity.dart';
import '../models/note.dart';
import '../models/reminder.dart';

class ReminderItem extends StatefulWidget {
  final Key key;
  final Reminder reminder;
  final bool showDate;
  final String dateString;
  final Activity? activity;
  final Function(Reminder reminder, Activity activity) onReminderClicked;
  // final Function(Reminder reminder) onReminderRemoved;
  // final Function(Reminder reminder) onReminderChanged;

  const ReminderItem(this.reminder, this.showDate, this.dateString, this.activity,
      {required this.key,
      required this.onReminderClicked,
      // required this.onReminderChanged,
      // required this.onReminderRemoved
      })
      : super(key: key);

  @override
  State<ReminderItem> createState() => ReminderItemState();
}

class ReminderItemState extends State<ReminderItem> {
  @override
  Widget build(BuildContext context) {
    final noteTitle = widget.activity != null ? widget.activity!.title : "";
    final isCompleted = widget.reminder.isCompleted;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Visibility(visible: widget.showDate, child: Text(widget.dateString)),
        Card(
            color: isCompleted == null
                ? ColorConstants.soil
                : isCompleted
                    ? ColorConstants.soil.withGreen(100).withOpacity(0.5)
                    : ColorConstants.soil.withRed(100).withOpacity(0.5),
            child: InkWell(
                onTap: () {
                  if (widget.activity != null) {
                    widget.onReminderClicked(widget.reminder, widget.activity!);
                  }
                },
                child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(5),
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  widget.reminder.getTimeString(),
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  widget.reminder.activityType.name.toUpperCase(),
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  noteTitle,
                                  textAlign: TextAlign.start,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    IconButton(
                                      padding: EdgeInsets.all(4),
                                      constraints: BoxConstraints(),
                                      onPressed: () {
                                        setState(() {
                                          if (isCompleted == null ||
                                              isCompleted) {
                                            widget.reminder.isCompleted = false;
                                            // widget.onReminderChanged(
                                            //     widget.reminder)
                                            ;
                                          } else {
                                            widget.reminder.isCompleted = null;
                                            // widget.onReminderRemoved(
                                            //     widget.reminder)
                                            ;
                                          }
                                        });
                                      },
                                      icon: const Icon(Icons.close),
                                      color:
                                          (isCompleted != null && !isCompleted)
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
                                            widget.reminder.isCompleted = true;
                                            // widget.onReminderChanged(
                                            //     widget.reminder)
                                            ;
                                          } else {
                                            widget.reminder.isCompleted = null;
                                            // widget.onReminderRemoved(
                                            //     widget.reminder)
                                            ;
                                          }
                                        });
                                      },
                                      icon: const Icon(Icons.check),
                                      color:
                                          (isCompleted != null && isCompleted)
                                              ? Colors.green
                                              : ColorConstants.sand,
                                    )
                                  ],
                                )
                              ],
                            ),
                          ]),
                    ))))
      ],
    );
  }
}
