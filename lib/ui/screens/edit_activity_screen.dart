import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:remind_me/services/date_service.dart';
import 'package:remind_me/services/notification_service.dart';
import 'package:remind_me/ui/screens/edit_note_screen.dart';
import 'package:remind_me/util/color_constants.dart';
import 'package:weekday_selector/weekday_selector.dart';
import '../models/activity.dart';
import '../models/checklist.dart';
import '../models/note.dart';
import '../models/reminder.dart';
import '../widgets/containers/background_container.dart';
import '../widgets/mole_image.dart';

class EditActivityBaseScaffold extends StatefulWidget {
  static const double padding = 0;

  final Widget body;
  final Activity activity;
  final ActivityType activityType;
  final bool isNewActivity;
  final Future<bool> Function() onAddActivity;

  const EditActivityBaseScaffold(
      {Key? key,
        required this.activity,
        required this.activityType,
      required this.body,
      required this.isNewActivity,
      required this.onAddActivity})
      : super(key: key);

  @override
  State<EditActivityBaseScaffold> createState() => EditActivityBaseScaffoldState();
}

class EditActivityBaseScaffoldState extends State<EditActivityBaseScaffold> {
  final TextEditingController titleController = TextEditingController();
  final _focusNode = FocusNode();

  final _moleImageKey = GlobalKey<MoleImageState>();

  // late final Activity activity;

  int _pageIndex = 0;
  final _pageController = PageController(
    initialPage: 0,
    keepPage: true,
  );

  @override
  void initState() {
    super.initState();
    // activity = widget.activity;
    titleController.text = widget.activity.title;

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        titleController.selection = TextSelection(
            baseOffset: 0, extentOffset: titleController.text.length);
      }
    });
    _pageController.addListener(() {
      _moleImageKey.currentState?.setMoleOffset(_pageController.offset);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
    titleController.dispose();
    _focusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: widget.onAddActivity,
        //     () async {
        //   await widget.onAddActivity;
        //   return true;
        // },
        child: Scaffold(
          appBar: AppBar(
            titleSpacing: 0,
            title: TextField(
              focusNode: _focusNode,
              keyboardType: TextInputType.text,
              autofocus: widget.isNewActivity && titleController.text == "",
              strutStyle:
                  StrutStyle.fromTextStyle(TextStyle(color: Colors.white)),
              controller: titleController,
              style: const TextStyle(color: ColorConstants.sand),
              decoration: InputDecoration(
                  hintText: "Title",
                  isDense: true,
                  contentPadding: const EdgeInsets.fromLTRB(10, 15, 15, 0),
                  hintStyle:
                      TextStyle(color: ColorConstants.sand.withOpacity(0.5)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        width: 1.5,
                        color: ColorConstants.sand.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        width: 2, color: ColorConstants.sand.withOpacity(0.8)),
                    borderRadius: BorderRadius.circular(5),
                  )),
            ),
            actions: <Widget>[
              InkWell(
                  onTap: () {},
                  child: Container(
                      padding: EdgeInsets.all(6),
                      width: 55,
                      child: Card(
                        color: widget.activity.getColor(),
                      ))),
              PopupMenuButton(
                  // add icon, by default "3 dot" icon
                  // icon: Icon(Icons.book)
                  itemBuilder: (context) {
                return [
                  const PopupMenuItem<int>(
                    value: 0,
                    child: Text("Share note"),
                  ),
                  const PopupMenuItem<int>(
                    value: 1,
                    child: Text("Copy to clipboard"),
                  ),
                  const PopupMenuItem<int>(
                    value: 1,
                    child: Text("Delete note"),
                  ),
                ];
              }, onSelected: (value) {
                if (value == 0) {
                } else if (value == 1) {
                }
              }),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: ColorConstants.soil,
            onPressed: () =>
                _pageIndex == 0 ? widget.onAddActivity() : _addNewReminder(),
            child: Icon(_pageIndex == 0 ? Icons.check : Icons.add),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: ColorConstants.soil,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.brown.shade500,
            currentIndex: _pageIndex,
            onTap: (index) {
              final diff = (_pageIndex - index).abs();
              print(diff);
              setState(() {
                _pageIndex = index;
                _pageController.animateToPage(index,
                    duration: Duration(milliseconds: 500 * diff),
                    curve: Curves.ease);
              });
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.notes), label: 'Note'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.alarm), label: 'Notifications'),
            ],
          ),
          body: BackgroundContainer(
              child: Stack(
            children: [
              buildPageView(),
              MoleImage(
                key: _moleImageKey,
                pages: 2,
              )
            ],
          )),
        ));
  }

  Widget buildPageView() {
    final List<Reminder> visibleReminders = [];
    final now = DateTime.now();
    for (Reminder reminder in widget.activity.reminders) {
      if (reminder.timestamp > now.millisecondsSinceEpoch) {
        visibleReminders.add(reminder);
      }
    }
    return PageView(
      controller: _pageController,
      onPageChanged: (index) {
        setState(() {
          _pageIndex = index;
        });
      },
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            widget.body,
          ],
        ),
        ListView.builder(
            itemCount: visibleReminders.length,
            itemBuilder: (context, index) {
              final reminder = visibleReminders[index];

              return Padding(
                  padding: const EdgeInsets.all(EditActivityBaseScaffold.padding),
                  child: InkWell(
                      onTap: () => _onReminderClicked(reminder),
                      child: SizedBox(
                        height: 50,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Expanded(
                                  child: Container(
                                      child: Text(
                                reminder.getTimeAndDateString(),
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ))),
                              IconButton(
                                  onPressed: () {
                                    NotificationService.sendTestReminder(
                                        reminder, widget.activity);
                                  },
                                  color: Colors.blueAccent,
                                  icon: const Icon(
                                      Icons.notification_important_rounded)),
                              IconButton(
                                  onPressed: () {
                                    setState(() {
                                      widget.activity.reminders
                                          .remove(reminder);
                                      // _removedReminders.add(reminder);
                                    });
                                  },
                                  color: Colors.red,
                                  icon: const Icon(Icons.delete))
                            ]),
                      )));
            }),
        // ),
        //       ],
        //     ),
      ],
    );
  }

  _addNewReminder() {
    showMaterialModalBottomSheet(
      context: context,
      builder: (_) => Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              InkWell(
                  onTap: () => _setReminder(null),
                  child: const SizedBox(
                    height: 50,
                    child: Center(child: Text('Single Notification')),
                  )),
              InkWell(
                  onTap: _addRecurringReminder,
                  child: const SizedBox(
                    height: 50,
                    child: Center(child: Text('Multiple Notifications')),
                  )),
              InkWell(
                  onTap: _addRecurringReminder,
                  child: const SizedBox(
                    height: 50,
                    child: Center(child: Text('Weekly Notifications')),
                  )),
              InkWell(
                  onTap: _addRecurringReminder,
                  child: const SizedBox(
                    height: 50,
                    child: Center(child: Text('Monthly Notifications')),
                  )),
            ],
          )),
    );
  }

  _onReminderClicked(Reminder reminder) {
    _setReminder(reminder);
  }

  _setReminder(Reminder? reminder) async {
    String? routeName;
    if(widget.activity.runtimeType == Note) {
      routeName = EditNoteScreen.routeName;
    } else if(widget.activity.runtimeType == Checklist) {
      routeName = EditNoteScreen.routeName;
    }
    if(routeName != null) {
      Navigator.of(context)
        .popUntil(ModalRoute.withName(routeName));
    }
    DateTime now = DateTime.now();
    DateTime inAYear = DateTime(now.year + 1, now.month, now.day);
    DateTime? pickedDate = await showDatePicker(
      context: context,
      lastDate: inAYear,
      initialDate: now,
      firstDate: now,
    );
    if (pickedDate != null) {
      TimeOfDay initialTime = TimeOfDay.now();
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: initialTime,
      );
      if (pickedTime != null) {
        DateTime pickedDateTime = DateTime(pickedDate.year, pickedDate.month,
            pickedDate.day, pickedTime.hour, pickedTime.minute);
        setState(() {
          if (reminder == null) {
            final newReinder = Reminder.create(widget.activity.id,
                widget.activityType, pickedDateTime.millisecondsSinceEpoch);
            widget.activity.addReminder(newReinder);
          } else {
            reminder.timestamp = pickedDateTime.millisecondsSinceEpoch;
          }
          // _newReminders.add(reminder);
        });
      }
    }
  }

  _addRecurringReminder() async {
    Navigator.of(context).pop();
    final days = List.filled(7, false);
    final hasChosenDays = await showMaterialModalBottomSheet(
        context: context,
        builder: (_) => StatefulBuilder(
            builder: (_, setState) => Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                          padding: EdgeInsets.only(top: 10),
                          child: WeekdaySelector(
                            onChanged: (int day) {
                              setState(() {
                                final index = day % 7;
                                days[index] = !days[index];
                              });
                            },
                            values: days,
                          )),
                      Container(
                          padding: EdgeInsets.all(10),
                          child: ElevatedButton(
                              onPressed: () {
                                for (bool day in days) {
                                  if (day) {
                                    Navigator.of(context).pop(true);
                                    return;
                                  }
                                }
                                Navigator.of(context).pop(false);
                              },
                              child: Text("Ok")))
                    ])));

    if (hasChosenDays != null && hasChosenDays) {
      TimeOfDay initialTime = TimeOfDay.now();
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: initialTime,
      );
    }
  }
}
