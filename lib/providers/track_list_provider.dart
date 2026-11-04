import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/track_list.dart';
import '../models/track_item.dart';
import '../services/hive_service.dart';

final trackListProvider =
    StateNotifierProvider<TrackListNotifier, List<TrackList>>((ref) {
  return TrackListNotifier();
});

class TrackListNotifier extends StateNotifier<List<TrackList>> {
  TrackListNotifier() : super([]) {
    _load();
  }

  void _load() {
    state = HiveService.trackLists.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<void> addTrackList(TrackList trackList) async {
    await HiveService.trackLists.put(trackList.id, trackList);
    _load();
  }

  Future<void> updateTrackList(TrackList trackList) async {
    trackList.updatedAt = DateTime.now();
    await HiveService.trackLists.put(trackList.id, trackList);
    _load();
  }

  Future<void> deleteTrackList(String id) async {
    await HiveService.trackLists.delete(id);
    _load();
  }

  Future<void> addItem(String trackListId, TrackItem item) async {
    final list = HiveService.trackLists.get(trackListId);
    if (list != null) {
      list.items.add(item);
      list.updatedAt = DateTime.now();
      await list.save();
      _load();
    }
  }

  Future<void> addMultipleItems(String trackListId, List<TrackItem> items) async {
    final list = HiveService.trackLists.get(trackListId);
    if (list != null) {
      list.items.addAll(items);
      list.updatedAt = DateTime.now();
      await list.save();
      _load();
    }
  }

  Future<void> updateItem(String trackListId, TrackItem updatedItem) async {
    final list = HiveService.trackLists.get(trackListId);
    if (list != null) {
      final idx = list.items.indexWhere((it) => it.id == updatedItem.id);
      if (idx != -1) {
        list.items[idx] = updatedItem;
        list.updatedAt = DateTime.now();
        await list.save();
        _load();
      }
    }
  }

  Future<void> toggleItemStatus(String trackListId, String itemId) async {
    final list = HiveService.trackLists.get(trackListId);
    if (list != null) {
      final idx = list.items.indexWhere((it) => it.id == itemId);
      if (idx != -1) {
        final current = list.items[idx];
        // If current status is completedStatus, toggle to defaultStatus (or another non-completed status)
        // If multi-status, cycle through statusOptions
        final options = list.statusOptions;
        if (options.length == 2) {
          final nextStatus = current.status == list.completedStatus
              ? list.defaultStatus
              : list.completedStatus;
          list.items[idx] = current.copyWith(
            status: nextStatus,
            updatedAt: DateTime.now(),
          );
        } else if (options.isNotEmpty) {
          final curIdx = options.indexOf(current.status);
          final nextIdx = (curIdx + 1) % options.length;
          list.items[idx] = current.copyWith(
            status: options[nextIdx],
            updatedAt: DateTime.now(),
          );
        }
        list.updatedAt = DateTime.now();
        await list.save();
        _load();
      }
    }
  }

  Future<void> setItemStatus(
      String trackListId, String itemId, String newStatus) async {
    final list = HiveService.trackLists.get(trackListId);
    if (list != null) {
      final idx = list.items.indexWhere((it) => it.id == itemId);
      if (idx != -1) {
        list.items[idx] = list.items[idx].copyWith(
          status: newStatus,
          updatedAt: DateTime.now(),
        );
        list.updatedAt = DateTime.now();
        await list.save();
        _load();
      }
    }
  }

  Future<void> insertItemAt(String trackListId, int index, TrackItem item) async {
    final list = HiveService.trackLists.get(trackListId);
    if (list != null) {
      if (index < 0) {
        list.items.insert(0, item);
      } else if (index >= list.items.length) {
        list.items.add(item);
      } else {
        list.items.insert(index, item);
      }
      list.updatedAt = DateTime.now();
      await list.save();
      _load();
    }
  }
  Future<void> deleteItem(String trackListId, String itemId) async {
    final list = HiveService.trackLists.get(trackListId);
    if (list != null) {
      list.items.removeWhere((it) => it.id == itemId);
      list.updatedAt = DateTime.now();
      await list.save();
      _load();
    }
  }

  Future<void> reorderItems(
      String trackListId, int oldIndex, int newIndex) async {
    final list = HiveService.trackLists.get(trackListId);
    if (list != null) {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final item = list.items.removeAt(oldIndex);
      list.items.insert(newIndex, item);
      list.updatedAt = DateTime.now();
      await list.save();
      _load();
    }
  }
}

