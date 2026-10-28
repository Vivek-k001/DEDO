import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sticky_note.dart';
import '../services/hive_service.dart';

// The 7 signature iOS weekly analytics colors (solid, vibrant sticky paper tones)
const List<Color> stickyPalette = [
  Color(0xFFFF5A52), // Mon: Soft Coral Red
  Color(0xFFFF9500), // Tue: Warm Tangerine Orange
  Color(0xFFFFCC00), // Wed: Soft Sunflower Yellow
  Color(0xFF34C759), // Thu: Apple Mint Green
  Color(0xFF30B0C7), // Fri: Cyan / Sky Blue
  Color(0xFF007AFF), // Sat: Apple Royal Blue
  Color(0xFFAF52DE), // Sun: Lilac Violet
];

final stickyNoteProvider =
    StateNotifierProvider<StickyNoteNotifier, List<StickyNote>>((ref) {
  return StickyNoteNotifier();
});

class StickyNoteNotifier extends StateNotifier<List<StickyNote>> {
  final _random = math.Random();

  StickyNoteNotifier() : super([]) {
    _loadNotes();
  }

  void _loadNotes() {
    final box = HiveService.stickyNotes;
    state = box.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<StickyNote> addNote({String content = ''}) async {
    // Pick a random color from the 7 iOS colors
    final color = stickyPalette[_random.nextInt(stickyPalette.length)];
    // Subtle physical tilt angle between -3° and +3°
    final angle = (_random.nextDouble() * 0.08) - 0.04;

    final note = StickyNote(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      colorValue: color.toARGB32(),
      createdAt: DateTime.now(),
      rotationAngle: angle,
    );

    await HiveService.stickyNotes.put(note.id, note);
    state = [note, ...state];
    return note;
  }

  Future<void> updateNoteContent(String id, String newContent) async {
    final note = HiveService.stickyNotes.get(id);
    if (note != null) {
      note.content = newContent;
      await note.save();
      state = [
        for (final n in state)
          if (n.id == id) note else n,
      ];
    }
  }

  Future<void> deleteNote(String id) async {
    await HiveService.stickyNotes.delete(id);
    state = state.where((n) => n.id != id).toList();
  }

  Future<void> reorderNotes(int oldIndex, int newIndex) async {
    if (oldIndex < 0 ||
        oldIndex >= state.length ||
        newIndex < 0 ||
        newIndex >= state.length ||
        oldIndex == newIndex) {
      return;
    }
    final updated = List<StickyNote>.from(state);
    final movedItem = updated.removeAt(oldIndex);
    updated.insert(newIndex, movedItem);
    state = updated;

    // Persist new order into Hive
    final box = HiveService.stickyNotes;
    await box.clear();
    for (final note in updated) {
      await box.put(note.id, note);
    }
  }
}
