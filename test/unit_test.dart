import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:remind_me/ui/models/note.dart';
import 'package:remind_me/ui/models/reminder.dart';

void main() {
  int max = 0x7fffffff;
  final randomizer = Random();
  group("Note", () {
    test(
        'Given note has 0 reminders When a new reminder is added Then note has 1 reminder',
        () async {
      final note = Note.create();
      final reminder =
          Reminder.create(note.id, ActivityType.note, randomizer.nextInt(max));
      note.addReminder(reminder);
      expect(note.reminders.length, 1);
    });
    test(
        'Given note has 0 reminders When 3 new reminders is added and then 1 random is removed Then note has 2 reminders',
        () async {
      final note = Note.create();
      final reminder1 =
          Reminder.create(note.id, ActivityType.note, randomizer.nextInt(max));
      final reminder2 =
          Reminder.create(note.id, ActivityType.note, randomizer.nextInt(max));
      final reminder3 =
          Reminder.create(note.id, ActivityType.note, randomizer.nextInt(max));
      note.addReminder(reminder1);
      note.addReminder(reminder2);
      note.addReminder(reminder3);
      final randomReminder =
          note.reminders[randomizer.nextInt(note.reminders.length)];
      note.removeReminder(randomReminder);
      expect(note.reminders.length, 2);
    });

    test(
        'Given a note has been created When trying to give it a new id Then the value should stay and an error should be thrown ',
        () async {
      final note = Note.create();
      final initialNoteId = note.id;
      bool hasIdBeenChanged = false;
      bool errorShown = false;
      try {
        note.id = note.generateId();
        hasIdBeenChanged = note.id != initialNoteId;
        // }
        // on LateError{
        //   lateErrorShown = true;
      } catch (_) {
        errorShown = true;
      }
          expect(!hasIdBeenChanged && errorShown, true);
    });
  });
}
