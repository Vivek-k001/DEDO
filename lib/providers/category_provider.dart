import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/category.dart';
import '../services/hive_service.dart';

final categoryProvider =
    StateNotifierProvider<CategoryNotifier, List<Category>>((ref) {
  return CategoryNotifier();
});

class CategoryNotifier extends StateNotifier<List<Category>> {
  CategoryNotifier() : super([]) {
    _load();
  }

  void _load() {
    state = HiveService.categories.values.toList();
    if (state.isEmpty) _addDefaults();
  }

  void _addDefaults() {
    final defaults = [
      Category(id: const Uuid().v4(), name: 'Work', colorValue: 0xFF7C4DFF),
      Category(id: const Uuid().v4(), name: 'Personal', colorValue: 0xFF40C4FF),
      Category(id: const Uuid().v4(), name: 'Health', colorValue: 0xFF69F0AE),
      Category(id: const Uuid().v4(), name: 'Shopping', colorValue: 0xFFFFD740),
    ];
    for (final cat in defaults) {
      HiveService.categories.put(cat.id, cat);
    }
    state = defaults;
  }

  Future<void> addCategory(Category cat) async {
    await HiveService.categories.put(cat.id, cat);
    _load();
  }

  Future<void> updateCategory(Category cat) async {
    await HiveService.categories.put(cat.id, cat);
    _load();
  }

  Future<void> deleteCategory(String id) async {
    await HiveService.categories.delete(id);
    _load();
  }

  Category? findById(String id) {
    try {
      return state.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}
