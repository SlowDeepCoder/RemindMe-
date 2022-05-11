import 'package:flutter/material.dart';
import 'package:remind_me/ui/models/note.dart';
import 'package:remind_me/util/color_constants.dart';
import '../pages/notes_page.dart';
import '../pages/activities_page.dart';
import '../widgets/containers/background_container.dart';
import '../widgets/mole_image.dart';
import 'edit_note_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  static const String routeName = "/";

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Note> _notes = [];

  final _notesPageKey = GlobalKey<NotesPageState>();
  final _activitiesPageKey = GlobalKey<ActivitiesPageState>();
  final _moleImageKey = GlobalKey<MoleImageState>();

  int _pageIndex = 0;
  final _pageController = PageController(
    initialPage: 0,
    keepPage: true,
  );

  Widget buildPageView() {
    return PageView(
      controller: _pageController,
      onPageChanged: (index) {
        setState(() {
          _pageIndex = index;
        });
      },
      children: <Widget>[
        NotesPage(
          onSelectionChange: () {
            setState(() {});
          },
          notes: _notes,
          key: _notesPageKey,
          onNotesChange: (List<Note> notes) {
            setState(() {
              _notes.clear();
              _notes.addAll(notes);
            });
            Note.saveNotes(_notes);
          },
          onNoteClicked: (note) => _openNote(note),
        ),
        ActivitiesPage(
          key: _activitiesPageKey,
          notes: _notes,
          onActivityClicked: (note) {
            if (note != null) {
              _openNote(note);
            }
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {
    await _loadNotes();
    _pageController.addListener(() {
      _moleImageKey.currentState?.setMoleOffset(_pageController.offset);
    });
  }

  _loadNotes() async {
    final notes = await Note.loadNotes();
    _notes.addAll(notes);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onBackPressed,
        child: Scaffold(
            appBar: _getAppBar(),
            floatingActionButton: FloatingActionButton(
              backgroundColor: ColorConstants.soil,
              onPressed: () => _addNewNote(),
              child: const Icon(Icons.add),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            bottomNavigationBar: BottomNavigationBar(
              backgroundColor: ColorConstants.soil,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.brown.shade500,
              currentIndex: _pageIndex,
              onTap: (index) {
                setState(() {
                  _pageIndex = index;
                  _pageController.animateToPage(index,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.ease);
                });
              },
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.notes), label: 'Notes'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.alarm), label: 'Reminders'),
              ],
            ),
            body: BackgroundContainer(
              child: Stack(
                children: [
                  buildPageView(),
                  MoleImage(
                    key: _moleImageKey,
                  )
                ],
              ),
            )));
  }

  _getAppBar() {
    return AppBar(
      title: const Text("Mole Planner"),
      actions: _notesPageKey.currentState == null
          ? null
          : _notesPageKey.currentState!.selectedNotes.isEmpty
              ? [
                  PopupMenuButton(
                      // add icon, by default "3 dot" icon
                      // icon: Icon(Icons.book)
                      itemBuilder: (context) {
                    return [
                      const PopupMenuItem<int>(
                        value: 0,
                        child: Text("Sort by: Created"),
                      ),
                      const PopupMenuItem<int>(
                        value: 1,
                        child: Text("Sort by: Edited"),
                      ),
                    ];
                  }, onSelected: (value) {
                    if (value == 0) {
                      _notesPageKey.currentState
                          ?.sortNotes(SortOptions.created);
                    } else if (value == 1) {
                      _notesPageKey.currentState
                          ?.sortNotes(SortOptions.updated);
                    }
                  }),
                ]
              : [
                  IconButton(
                      onPressed: () =>
                          _notesPageKey.currentState?.clearSelectedNotes(),
                      icon: Icon(Icons.highlight_remove)),
                  IconButton(
                      onPressed: () =>
                          _notesPageKey.currentState?.deleteSelectedNotes(),
                      icon: Icon(Icons.delete))
                ],
    );
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
      Note.saveNotes(_notes);
      if(_pageIndex == 0) {
        _notesPageKey.currentState?.setNotes(_notes);
        _notesPageKey.currentState?.sortNotes(SortOptions.created);
      }
      else if(_pageIndex == 1) {
        _activitiesPageKey.currentState?.setActivities(_notes);
      }
    }
  }

  _addNewNote() async {
    _notesPageKey.currentState?.clearSelectedNotes();
    final note =
        await Navigator.pushNamed(context, EditNoteScreen.routeName) as Note?;

    if (note != null) {
      _notes.add(note);
      _notesPageKey.currentState?.setNotes(_notes);
      _notesPageKey.currentState?.sortNotes(SortOptions.created);
      Note.saveNotes(_notes);
    }
  }

  Future<bool> _onBackPressed() async {
    if (_notesPageKey.currentState!.selectedNotes.isEmpty) {
      return true;
    } else {
      _notesPageKey.currentState!.clearSelectedNotes();
      return false;
    }
  }
}
