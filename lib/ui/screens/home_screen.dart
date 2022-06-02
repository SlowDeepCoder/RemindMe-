import 'package:flutter/material.dart';
import 'package:remind_me/ui/models/note.dart';
import 'package:remind_me/ui/pages/calendar_page.dart';
import 'package:remind_me/util/color_constants.dart';
import '../../managers/settings_manager.dart';
import '../models/activity.dart';
import '../bottom_sheets/edit_event_bottom_sheet.dart';
import '../models/checklist.dart';
import '../models/event.dart';
import '../models/reminder.dart';
import '../pages/notes_page.dart';
import '../pages/reminders_page.dart';
import '../pages/settings_page.dart';
import '../widgets/containers/background_container.dart';
import '../widgets/mole_image.dart';
import 'edit_checklist_screen.dart';
import 'edit_note_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  static const String routeName = "/";

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final List<Note> _notes = [];
  final List<Checklist> _checklists = [];
  final List<Event> _events = [];
  final List<Reminder> _reminders = [];

  final _notesPageKey = GlobalKey<NotesPageState>();
  final _activitiesPageKey = GlobalKey<RemindersPageState>();
  final _calendarPageKey = GlobalKey<CalendarPageState>();
  final _statisticsPageKey = GlobalKey<SettingsPageState>();
  final _moleImageKey = GlobalKey<MoleImageState>();

  bool _renderScreen = false;

  AppBar _appBar = AppBar();

  int _pageIndex = 0;
  final _pageController = PageController(
    initialPage: 0,
    keepPage: true,
  );

  Widget buildPageView() {
    final activities = Activity.getActivities([_notes, _checklists]);
    return PageView(
      controller: _pageController,
      onPageChanged: (index) {
        setState(() {
          _pageIndex = index;
          _updateAppBar();
        });
      },
      children: <Widget>[
        NotesPage(
          onSelectionChange: () {
            setState(() {
              _updateAppBar();
            });
          },
          notes: _notes,
          checklists: _checklists,
          // activities: activities,
          key: _notesPageKey,
          // onNotesChange: (List<Note> notes) {
          //   _notes.clear();
          //   _notes.addAll(notes);
          //   _saveNotes();
          // },
          onActivityClicked: _onActivityClicked,
          onDeleteActivities: _onDeleteActivities,
        ),
        RemindersPage(
          key: _activitiesPageKey,
          notes: _notes,
          checklists: _checklists,
          events: _events,
          reminders: _reminders,
          onReminderClicked: _onActivityClicked,
        ),
        CalendarPage(
          key: _calendarPageKey,
          notes: _notes,
          checklists: _checklists,
          events: _events,
          reminders: _reminders,
          onActivityClicked: _onActivityClicked,
          onAddNewEvent: _addNewEvent,
        ),
        SettingsPage(key: _statisticsPageKey, onCompanionChanged: update),
      ],
    );
  }

  AppBar getStandardAppbar() {
    return AppBar(
      title: Text("Mole Planner"),
      actions: [
        PopupMenuButton(
            // add icon, by default "3 dot" icon
            icon: Icon(Icons.add),
            itemBuilder: (context) {
              return [
                const PopupMenuItem<int>(
                  value: 0,
                  child: Text("New Note"),
                ),
                const PopupMenuItem<int>(
                  value: 1,
                  child: Text("New Checklist"),
                ),
                const PopupMenuItem<int>(
                  value: 2,
                  child: Text("New Event"),
                ),
              ];
            },
            onSelected: (value) {
              if (value == 0) {
                _addNewNote();
              } else if (value == 1) {
                _addNewChecklist();
              } else if (value == 2) {
                _addNewEvent(null);
              }
            }),
      ],
    );
  }

  void _updateAppBar() {
    switch (_pageIndex) {
      case 0:
        if (_notesPageKey.currentState != null) {
          _appBar = _notesPageKey.currentState!.getAppBar(getStandardAppbar());
        } else {
          _appBar = getStandardAppbar();
        }
        break;
      case 1:
        if (_activitiesPageKey.currentState != null) {
          _appBar =
              _activitiesPageKey.currentState!.getAppBar(getStandardAppbar());
        } else {
          _appBar = getStandardAppbar();
        }
        break;
      case 2:
        if (_calendarPageKey.currentState != null) {
          _appBar =
              _calendarPageKey.currentState!.getAppBar(getStandardAppbar());
        } else {
          _appBar = getStandardAppbar();
        }
        break;
      case 3:
        if (_statisticsPageKey.currentState != null) {
          _appBar =
              _statisticsPageKey.currentState!.getAppBar(getStandardAppbar());
        } else {
          _appBar = getStandardAppbar();
        }
    }
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {
    await _loadNotes();
    await _loadEvents();
    await _loadChecklists();
    await _loadReminders();
    _pageController.addListener(() {
      _moleImageKey.currentState?.setMoleOffset(_pageController.offset);
    });
    setState(() {
      _renderScreen = true;
      _updateAppBar();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_renderScreen) return Container();
    return WillPopScope(
        onWillPop: _onBackPressed,
        child: Scaffold(
            appBar: _appBar,
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: SettingsManager().getCompanionMainColor(),
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
                BottomNavigationBarItem(
                    icon: Icon(Icons.notes), label: 'Notes'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.alarm), label: 'Notifications'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.calendar_today), label: 'Calendar'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.settings), label: 'Settings'),
              ],
            ),
            body: BackgroundContainer(
              child: Container(
                  color: ColorConstants.soil.withOpacity(0.5),
                  child: Stack(
                    children: [
                      buildPageView(),
                      MoleImage(
                        key: _moleImageKey,
                        pages: 4,
                      )
                    ],
                  )),
            )));
  }

  _loadNotes() async {
    final notes = await Note.loadNotes();
    _notes.addAll(notes);
  }

  _loadEvents() async {
    final events = await Event.loadEvents();
    _events.addAll(events);
  }

  _loadChecklists() async {
    final events = await Checklist.loadChecklists();
    _checklists.addAll(events);
  }

  _loadReminders() async {
    List<Reminder> reminders =
        Reminder.getReminders([_notes, _events, _checklists]);
    _reminders.clear();
    setState(() {
      _reminders.addAll(reminders);
    });
  }

  _onActivityClicked(Activity activity) {
    switch (activity.runtimeType) {
      case Note:
        _openNote(activity as Note);
        break;
      case Event:
        _openEvent(activity as Event);
        break;
      case Checklist:
        _openChecklist(activity as Checklist);
        break;
    }
  }

  _addNewNote() async {
    _notesPageKey.currentState?.clearSelectedNotes();
    final note =
        await Navigator.pushNamed(context, EditNoteScreen.routeName) as Note?;

    if (note != null) {
      _notes.add(note);
      _saveNotes();
    }
  }

  _openNote(Note note) async {
    Navigator.of(context).popUntil(ModalRoute.withName(HomeScreen.routeName));
    final editedNote = await Navigator.pushNamed(
        context, EditNoteScreen.routeName,
        arguments: note) as Note?;

    if (editedNote != null) {
      for (int i = 0; i < _notes.length; i++) {
        if (_notes[i].id == editedNote.id) {
          setState(() {
            _notes.replaceRange(i, i + 1, [editedNote]);
          });
          break;
        }
      }
      _saveNotes();
    }
  }

  _addNewChecklist() async {
    _notesPageKey.currentState?.clearSelectedNotes();
    final checklist =
        await Navigator.pushNamed(context, EditChecklistScreen.routeName)
            as Checklist?;

    if (checklist != null) {
      _checklists.add(checklist);
      _saveChecklists();
    }
  }

  _openChecklist(Checklist checklist) async {
    Navigator.of(context).popUntil(ModalRoute.withName(HomeScreen.routeName));
    final editedChecklist = await Navigator.pushNamed(
            context, EditChecklistScreen.routeName, arguments: checklist)
        as Checklist?;

    if (editedChecklist != null) {
      for (int i = 0; i < _checklists.length; i++) {
        if (_checklists[i].id == editedChecklist.id) {
          setState(() {
            _checklists.replaceRange(i, i + 1, [editedChecklist]);
          });
          break;
        }
      }
      _saveChecklists();
    }
  }

  _addNewEvent(DateTime? date) async {
    final event =
        await EditEventBottomSheet.showBottomSheet(context, null, date, null);

    if (event != null) {
      _events.add(event);
      _saveEvents();
    }
  }

  _openEvent(Event event) async {
    Navigator.of(context).popUntil(ModalRoute.withName(HomeScreen.routeName));
    Event? editedEvent = await EditEventBottomSheet.showBottomSheet(
        context, event, null, () => _onDeleteEvent(event));

    if (editedEvent != null) {
      for (int i = 0; i < _events.length; i++) {
        if (_events[i].id == editedEvent.id) {
          setState(() {
            _events.replaceRange(i, i + 1, [editedEvent]);
          });
          break;
        }
      }
      _saveEvents();
    }
  }

  _saveEvents() async {
    await Event.saveEvents(_events);
    await _loadReminders();
    _updateCurrentPage();
  }

  _saveNotes() async {
    await Note.saveNotes(_notes);
    await _loadReminders();
    _updateCurrentPage();
  }

  _saveChecklists() async {
    await Checklist.saveChecklists(_checklists);
    await _loadReminders();
    _updateCurrentPage();
  }

  _updateCurrentPage() {
    if (_pageIndex == 0) {
      _notesPageKey.currentState?.update();
    } else if (_pageIndex == 1) {
      _activitiesPageKey.currentState?.update();
    } else if (_pageIndex == 2) {
      _calendarPageKey.currentState?.update();
    }
  }

  Future<bool> _onBackPressed() async {
    if (_notesPageKey.currentState!.selectedActivities.isEmpty) {
      return true;
    } else {
      _notesPageKey.currentState!.clearSelectedNotes();
      return false;
    }
  }

  _onDeleteEvent(Event event) {
    print("hej");
    event.removeAllReminders();
    _events.remove(event);
    _saveEvents();
  }

  void update() {
    setState(() {
      print("hej");
    });
  }


  static Future functionName(Map<String, String> params, {bool isDone = false}) async {
  }

  _onDeleteActivities(List<Activity> activities) async {
    for (Activity activity in activities) {
      if (activity.runtimeType == Note) {
        final note = Note.getNote(_notes, activity.id);
        if (note != null) {
          await note.removeAllReminders();
          _notes.remove(note);
          _saveNotes();
        }
      } else if (activity.runtimeType == Checklist) {
        final checklist = Checklist.getChecklist(_checklists, activity.id);
        if (checklist != null) {
          await checklist.removeAllReminders();
          _checklists.remove(checklist);
          _saveChecklists();
        }
      }
    }
  }
}
