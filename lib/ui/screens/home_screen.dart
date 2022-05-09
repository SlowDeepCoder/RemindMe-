import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:remind_me/ui/items/note_list_item.dart';
import 'package:remind_me/ui/models/note.dart';
import '../../services/notification_service.dart';
import '../pages/notes_page.dart';
import '../pages/reminders_page.dart';
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
  final _remindersPageKey = GlobalKey<RemindersPageState>();
  int pageIndex = 0;
  final pageController = PageController(
    initialPage: 0,
    keepPage: true,
  );

  Widget buildPageView() {
    return PageView(
      controller: pageController,
      onPageChanged: (index) {
        setState(() {
          pageIndex = index;
        });
      },
      children: <Widget>[
        NotesPage(
          onSelectionChange: () {
            setState(() {});
          },
          notes: _notes,
          key: _notesPageKey, onNotesChange: (List<Note> notes) {
            setState(() {
              _notes.clear();
              _notes.addAll(notes);
            });
            Note.saveNotes(_notes);
        },
        ),
        RemindersPage(key: _remindersPageKey),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {
    await _loadNotes();
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
            onPressed: () => _addNewNote(),
            child: const Icon(Icons.add),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: pageIndex,
            onTap: (index) {
              setState(() {
                pageIndex = index;
                pageController.animateToPage(index,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.ease);
              });
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.notes), label: 'Notes'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.alarm), label: 'Reminders'),
            ],
          ),

          // BottomAppBar(
          //   shape: CircularNotchedRectangle(),
          //   notchMargin: 5,
          //   child: Row(
          //     mainAxisSize: MainAxisSize.max,
          //     mainAxisAlignment: MainAxisAlignment.spaceAround,
          //     children: <Widget>[
          //
          //       IconButton(
          //         icon: const Icon(
          //           Icons.notes,
          //           color: Colors.blue,
          //         ),
          //         onPressed: () {},
          //       ),
          //       IconButton(
          //         icon: const Icon(
          //           Icons.alarm,
          //           color: Colors.blue,
          //         ),
          //         onPressed: () {},
          //       ),
          //     ],
          //   ),
          // ),
          body: buildPageView(),
        ));
  }

  _getAppBar() {
    return AppBar(
      title: const Text("RemindMe!"),
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
