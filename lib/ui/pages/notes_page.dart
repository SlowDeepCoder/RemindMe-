import 'package:auto_animated/auto_animated.dart';
import 'package:flutter/material.dart';
import 'package:remind_me/ui/items/activity_item.dart';
import 'package:remind_me/ui/models/checklist.dart';
import 'package:remind_me/ui/models/note.dart';
import 'package:remind_me/util/color_constants.dart';
import '../../managers/notification_manager.dart';
import '../../managers/settings_manager.dart';
import '../dialogs/sort_option_dialog.dart';
import '../models/activity.dart';
import '../screens/edit_note_screen.dart';

class NotesPage extends StatefulWidget {
  final VoidCallback onSelectionChange;
  final Function(Activity activity) onActivityClicked;
  final Function(List<Activity> activity) onDeleteActivities;

  final List<Note> notes;
  final List<Checklist> checklists;

  // final List<Activity> activities;

  const NotesPage({
    required this.onSelectionChange,
    required this.onActivityClicked,
    required this.onDeleteActivities,
    required this.notes,
    required this.checklists,
    // required this.activities,
    Key? key,
  }) : super(key: key);

  @override
  State<NotesPage> createState() => NotesPageState();
}

class NotesPageState extends State<NotesPage> {
  final List<Activity> selectedActivities = [];
  final List<ActivityItem> _activityItems = [];
  final List<GlobalKey<ActivityItemState>> _activityItemKeys = [];

  // GlobalKey<AnimatedListState> _animatedListviewKey = GlobalKey();
  final settingsManager = SettingsManager();
  late List<Activity> _activities;

  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {
    _activities = Activity.getActivities([widget.notes, widget.checklists]);
    _sortActivities();
    await _initNotifications();
  }

  _initNotifications() async {
    await NotificationManager().initNotifications();
    NotificationManager()
        .setNotificationListeners(_activities, _onActivityClicked);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InkWell(
          onTap: () async {
            final sortOption = await SortOptionDialog.show(
                context, settingsManager.sortOption);
            if (sortOption != null) {
              setState(() {
                settingsManager.sortOption = sortOption;
              });
              _sortActivities();
            }
          },
          child: Container(
            margin: EdgeInsets.all(4),
            height: 32,
            color: settingsManager.getCompanionMainColor(),
            child: Center(
              child: Text(
                "Sort by : " + Activity.getNameFromSortOption(settingsManager.sortOption),
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ),
        Padding(
            padding: EdgeInsets.only(top: 36),
            child:
                // AnimatedList(
                //     key: _animatedListviewKey,
                //     initialItemCount: _activityItems.length,
                //     itemBuilder: (context, index, animation) {
                //       return FadeTransition(
                //         opacity: Tween<double>(
                //           begin: 0,
                //           end: 1,
                //         ).animate(animation),
                //         // And slide transition
                //         child: SlideTransition(
                //           position: Tween<Offset>(
                //             begin: Offset(0, -0.1),
                //             end: Offset.zero,
                //           ).animate(animation),
                //           // Paste you Widget
                //           child: _activityItems[index],
                //         ),
                //       );
                //     }),

                // LiveList.options(
                //   key: _animatedListviewKey,
                //     itemCount: _activityItems.length,
                //     options: const LiveOptions(
                //       // Start animation after (default zero)
                //       // delay: Duration(milliseconds: 100),
                //
                //       // Show each item through (default 250)
                //       showItemInterval: Duration(milliseconds: 50),
                //
                //       // Animation duration (default 250)
                //       showItemDuration: Duration(seconds: 1),
                //
                //       // Animations starts at 0.05 visible
                //       // item fraction in sight (default 0.025)
                //       visibleFraction: 0.05,
                //
                //       // Repeat the animation of the appearance
                //       // when scrolling in the opposite direction (default false)
                //       // To get the effect as in a showcase for ListView, set true
                //       reAnimateOnVisibility: false,
                //     ),
                //     itemBuilder: (context, index, animation) {
                //       return FadeTransition(
                //         opacity: Tween<double>(
                //           begin: 0,
                //           end: 1,
                //         ).animate(animation),
                //         // And slide transition
                //         child: SlideTransition(
                //           position: Tween<Offset>(
                //             begin: Offset(0, -0.1),
                //             end: Offset.zero,
                //           ).animate(animation),
                //           // Paste you Widget
                //           child: _activityItems[index],
                //         ),
                //       );
                //     }),
                  ListView.builder(
                      itemCount: _activityItems.length,
                      itemBuilder: (context, index) {
                        return _activityItems[index];
                      })

            //     ReorderableListView(
            //   onReorder: (int oldIndex, int newIndex) {},
            //   children: _activityItems,
            // )
    )
      ],
    );
  }

  // GlobalKey<State<StatefulWidget>> getKeyFromActivityItem(ActivityItem activityItem) {
  //   for (int i = 0; i < _activityItems.length; i++) {
  //     if (_activityItems[i] == activityItem)
  //       return _activityItemKeys[i];
  //   }
  //   return GlobalKey(activityItem.activity.id);
  // }

  _deleteSelectedNotes() {
    // for (Activity selectedActivity in selectedActivities) {
    //   widget.activities.remove(selectedActivity);
    // }
    widget.onDeleteActivities(selectedActivities);
    selectedActivities.clear();
    widget.onSelectionChange();
    _updateListView();
  }

  clearSelectedNotes() {
    for (int i = 0; i < _activityItemKeys.length; i++) {
      _activityItemKeys[i].currentState?.unselectItem();
    }
    setState(() {
      selectedActivities.clear();
    });
    widget.onSelectionChange();
  }

  _onActivityClicked(Activity activity) async {
    widget.onActivityClicked(activity);
  }

// setNotes(List<Note> notes) {
//   _notes = notes;
// }

  _sortActivities() {
    print(_activities.length);
    // final activities =
        Activity.sortActivities(_activities, settingsManager.sortOption);
    print(_activities.length);
    // _activities.clear();
    // _activities.addAll(activities);
    print(_activities.length);
    _updateListView();
  }

  void _updateListView() async {
    _activityItemKeys.clear();
    _activityItems.clear();

    for (int i = 0; i < _activities.length; i++) {
      _activityItemKeys.add(GlobalKey<ActivityItemState>());
      _activityItems.add(ActivityItem(
        _activities[i],
        (bool value) {
          setState(() {
            if (value) {
              selectedActivities.add(_activities[i]);
            } else {
              selectedActivities.remove(_activities[i]);
            }
            widget.onSelectionChange();
          });
        },
        (activity) => selectedActivities.isEmpty
            ? _onActivityClicked(activity)
            : _onNoteSelected(i),
        _activityItemKeys[i],
      ));
    }
    setState(() {
      // _animatedListviewKey = GlobalKey();
    });
    // setState(() {
    // });
  }

  _onNoteSelected(int i) {
    _activityItemKeys[i].currentState?.selectItem();
  }

  AppBar getAppBar(AppBar standardAppBar) {
    return selectedActivities.isEmpty
        ? standardAppBar
        : AppBar(
            title: const Text("Mole Planner"),
            actions: [
              IconButton(
                  onPressed: () => clearSelectedNotes(),
                  icon: Icon(Icons.highlight_remove)),
              IconButton(
                  onPressed: () => _deleteSelectedNotes(),
                  icon: Icon(Icons.delete))
            ],
          );
  }

  void update() {
    setState(() {
      _activities = Activity.getActivities([widget.notes, widget.checklists]);
      _sortActivities();
    });
  }
}
