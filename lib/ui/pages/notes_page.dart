import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:remind_me/ui/items/note_item.dart';
import 'package:remind_me/ui/models/checklist.dart';
import 'package:remind_me/ui/models/note.dart';
import '../../services/notification_service.dart';
import '../screens/edit_note_screen.dart';

class NotesPage extends StatefulWidget {
  final VoidCallback onSelectionChange;
  final Function(List<Note> notes) onNotesChange;
  final Function(Note note) onNoteClicked;
  final List<Note> notes;
  final List<Checklist> checklists;

  const NotesPage({
    required this.onSelectionChange,
    required this.onNotesChange,
    required this.onNoteClicked,
    required this.notes,
    required this.checklists,
    Key? key,
  }) : super(key: key);

  @override
  State<NotesPage> createState() => NotesPageState();
}

class NotesPageState extends State<NotesPage> {
  List<Note> _notes = [];
  final List<Note> selectedNotes = [];
  final List<NoteItem> _noteItems = [];
  final List<GlobalKey<NoteItemState>> _noteItemKeys = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {
    _notes = widget.notes;
    await _initNotifications();
    sortNotes(SortOptions.created);
  }

  _initNotifications() async {
    await NotificationService().initNotifications();
    NotificationService().setNotificationListeners(_notes, _onNoteClicked);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: _noteItems.length,
        itemBuilder: (context, index) {
          return _noteItems[index];
        });
  }

  deleteSelectedNotes() {
    for (Note selectedNote in selectedNotes) {
      _notes.remove(selectedNote);
    }
    selectedNotes.clear();
    _updateListView();
    widget.onNotesChange(_notes);
  }

  clearSelectedNotes() {
    for (int i = 0; i < _noteItemKeys.length; i++) {
      _noteItemKeys[i].currentState?.unselectItem();
    }
    setState(() {
      selectedNotes.clear();
    });
    widget.onSelectionChange();
  }

  _onNoteClicked(Note note) async {
    widget.onNoteClicked(note);
  }

  setNotes(List<Note> notes) {
    _notes = notes;
  }

  sortNotes(SortOptions sortOption) {
    _notes = Note.sortNotes(_notes, sortOption, true);
    _updateListView();
  }

  void _updateListView() {
    _noteItemKeys.clear();
    _noteItems.clear();
    for (int i = 0; i < _notes.length; i++) {
      _noteItemKeys.add(GlobalKey<NoteItemState>());
      _noteItems.add(NoteItem(
        _notes[i],
        (bool value) {
          setState(() {
            if (value) {
              selectedNotes.add(_notes[i]);
            } else {
              selectedNotes.remove(_notes[i]);
            }
            widget.onSelectionChange();
          });
        },
        () => selectedNotes.isEmpty
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

  AppBar getAppBar(AppBar standardAppBar) {
    return selectedNotes.isEmpty
        ? standardAppBar
        : AppBar(
            title: const Text("Mole Planner"),
            actions: [
              IconButton(
                  onPressed: () => clearSelectedNotes(),
                  icon: Icon(Icons.highlight_remove)),
              IconButton(
                  onPressed: () => deleteSelectedNotes(),
                  icon: Icon(Icons.delete))
            ],
          );
  }
}
