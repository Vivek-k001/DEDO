import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';
import '../models/category.dart';
import '../models/user_profile.dart';
import '../models/sticky_note.dart';

class HiveService {
  static const String _taskBox = 'tasks';
  static const String _categoryBox = 'categories';
  static const String _profileBox = 'profile';
  static const String _settingsBox = 'settings';
  static const String _stickyNotesBox = 'sticky_notes';

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(TaskAdapter());
    Hive.registerAdapter(CategoryAdapter());
    Hive.registerAdapter(UserProfileAdapter());
    Hive.registerAdapter(StickyNoteAdapter());

    // Open boxes
    await Hive.openBox<Task>(_taskBox);
    await Hive.openBox<Category>(_categoryBox);
    await Hive.openBox<UserProfile>(_profileBox);
    await Hive.openBox(_settingsBox);
    await Hive.openBox<StickyNote>(_stickyNotesBox);
  }

  static Box<Task> get tasks => Hive.box<Task>(_taskBox);
  static Box<Category> get categories => Hive.box<Category>(_categoryBox);
  static Box<UserProfile> get profiles => Hive.box<UserProfile>(_profileBox);
  static Box get settings => Hive.box(_settingsBox);
  static Box<StickyNote> get stickyNotes => Hive.box<StickyNote>(_stickyNotesBox);

  // ─── Profile helpers ──────────────────────────────────────────────────────
  static UserProfile? getProfile() {
    return profiles.isNotEmpty ? profiles.getAt(0) : null;
  }

  static Future<void> saveProfile(UserProfile profile) async {
    if (profiles.isNotEmpty) {
      await profiles.putAt(0, profile);
    } else {
      await profiles.add(profile);
    }
  }

  // ─── Settings helpers ─────────────────────────────────────────────────────
  static bool isDarkMode() => settings.get('isDarkMode', defaultValue: false);
  static Future<void> setDarkMode(bool val) => settings.put('isDarkMode', val);

  static int getAccentColor() =>
      settings.get('accentColor', defaultValue: 0xFF007AFF);
  static Future<void> setAccentColor(int val) => settings.put('accentColor', val);
}
