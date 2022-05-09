import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:remind_me/ui/items/note_list_item.dart';
import 'package:remind_me/ui/models/note.dart';
import '../../services/notification_service.dart';
import 'edit_note_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  static const String routeName = "/";

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Note> _notes = [];
  final List<Note> _selectedNotes = [];
  final List<NoteListItem> _noteItems = [];
  final List<GlobalKey<NoteListItemState>> _noteItemKeys = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {
    await _loadNotes();
    await _initNotifications();
    // _checkLatestNotification();
    _updateListView();
  }

  _loadNotes() async {
    final notes = await Note.loadNotes();
    _notes.addAll(notes);
  }

  _initNotifications() async {
    await NotificationService.initNotifications();
    NotificationService.setNotificationListener(_notes, _onNoteClicked);
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
          bottomNavigationBar: BottomAppBar(
            shape: CircularNotchedRectangle(),
            notchMargin: 5,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.menu,
                    color: Colors.blue,
                  ),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(
                    Icons.search,
                    color: Colors.blue,
                  ),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(
                    Icons.print,
                    color: Colors.blue,
                  ),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(
                    Icons.people,
                    color: Colors.blue,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          body: Stack(children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.arrow_drop_down), Text("Sort by: created")]),
            Container(
               margin: EdgeInsets.only(top:25), child:
            ListView.builder(
                itemCount: _noteItems.length,
                itemBuilder: (context, index) {
                  return _noteItems[index];
                }))
          ]),
        ));
  }

  _getAppBar() {
    return AppBar(
      title: Text(_selectedNotes.isEmpty
          ? "RemindMe!"
          : _selectedNotes.length.toString()),
      actions: _selectedNotes.isEmpty
          ? null
          : <Widget>[
              IconButton(
                  onPressed: () => _clearSelectedNotes(),
                  icon: Icon(Icons.highlight_remove)),
              IconButton(
                  onPressed: () => _deleteSelectedNotes(),
                  icon: Icon(Icons.delete))
            ],
    );
  }

  _deleteSelectedNotes() {
    for (Note selectedNote in _selectedNotes) {
      _notes.remove(selectedNote);
    }
    _selectedNotes.clear();
    _updateListView();
    Note.saveNotes(_notes);
  }

  _clearSelectedNotes() {
    for (int i = 0; i < _noteItemKeys.length; i++) {
      _noteItemKeys[i].currentState?.unselectItem();
    }
    setState(() {
      _selectedNotes.clear();
    });
  }

  _onNoteClicked(Note note) async {
    final editedNote = await Navigator.pushNamed(
        context, EditNoteScreen.routeName,
        arguments: note) as Note?;

    if (editedNote != null) {
      for (Note note in _notes) {
        if (note.id == editedNote.id) {
          note = editedNote;
        }
      }
      _notes = Note.sortNotes(_notes, SortOptions.updated, true);
      Note.saveNotes(_notes);
      _updateListView();
    }
  }

  _addNewNote() async {
    _clearSelectedNotes();
    final note =
        await Navigator.pushNamed(context, EditNoteScreen.routeName) as Note?;

    if (note != null) {
      _notes.add(note);
      _notes = Note.sortNotes(_notes, SortOptions.updated, true);
      Note.saveNotes(_notes);
      _updateListView();
    }
  }

  void _updateListView() {
    _noteItemKeys.clear();
    _noteItems.clear();
    for (int i = 0; i < _notes.length; i++) {
      _noteItemKeys.add(GlobalKey<NoteListItemState>());
      _noteItems.add(NoteListItem(
        _notes[i],
        (bool value) {
          setState(() {
            if (value) {
              _selectedNotes.add(_notes[i]);
            } else {
              _selectedNotes.remove(_notes[i]);
            }
          });
        },
        () => _selectedNotes.isEmpty
            ? _onNoteClicked(_notes[i])
            : _onNoteSelected(i),
        _noteItemKeys[i],
      ));
    }
    setState(() {});
  }

  _onNoteSelected(int i) {
    _noteItemKeys[i].currentState?.selectItem();
  }

  Future<bool> _onBackPressed() async {
    if (_selectedNotes.isEmpty) {
      return true;
    } else {
      _clearSelectedNotes();
      return false;
    }
  }
}
