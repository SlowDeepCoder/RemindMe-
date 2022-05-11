import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:remind_me/ui/items/note_list_item.dart';
import 'package:remind_me/ui/models/note.dart';
import '../../services/notification_service.dart';
import '../screens/edit_note_screen.dart';

class NotesPage extends StatefulWidget {
  final VoidCallback onSelectionChange;
  final Function(List<Note> notes) onNotesChange;
  final Function(Note note) onNoteClicked;
  final List<Note> notes;

  const NotesPage({
    required this.onSelectionChange,
    required this.onNotesChange,
    required this.onNoteClicked,
    required this.notes,
    Key? key,
  }) : super(key: key);

  @override
  State<NotesPage> createState() => NotesPageState();
}

class NotesPageState extends State<NotesPage> {
  List<Note> _notes = [];
  final List<Note> selectedNotes = [];
  final List<NoteListItem> _noteItems = [];
  final List<GlobalKey<NoteListItemState>> _noteItemKeys = [];

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

  // _getAppBar() {
  //   return AppBar(
  //     title: const Text("RemindMe!"),
  //     actions: _selectedNotes.isEmpty
  //         ? [
  //             PopupMenuButton(
  //                 // add icon, by default "3 dot" icon
  //                 // icon: Icon(Icons.book)
  //                 itemBuilder: (context) {
  //               return [
  //                 const PopupMenuItem<int>(
  //                   value: 0,
  //                   child: Text("Sort by: Created"),
  //                 ),
  //                 const PopupMenuItem<int>(
  //                   value: 1,
  //                   child: Text("Sort by: Edited"),
  //                 ),
  //               ];
  //             }, onSelected: (value) {
  //               if (value == 0) {
  //                 _sortNotes(SortOptions.created);
  //               } else if (value == 1) {
  //                 _sortNotes(SortOptions.updated);
  //               }
  //             }),
  //           ]
  //         : [
  //             IconButton(
  //                 onPressed: () => _clearSelectedNotes(),
  //                 icon: Icon(Icons.highlight_remove)),
  //             IconButton(
  //                 onPressed: () => _deleteSelectedNotes(),
  //                 icon: Icon(Icons.delete))
  //           ],
  //   );
  // }

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
      _noteItemKeys.add(GlobalKey<NoteListItemState>());
      _noteItems.add(NoteListItem(
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
}
