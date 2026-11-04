import 'package:hive/hive.dart';
import 'track_item.dart';

part 'track_list.g.dart';

@HiveType(typeId: 4)
class TrackList extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  String? description;

  @HiveField(3)
  String? categoryId;

  @HiveField(4)
  late int colorValue;

  @HiveField(5)
  late List<String> statusOptions; // e.g. ['Pending', 'Completed'] or custom

  @HiveField(6)
  late String defaultStatus; // initial status for new items

  @HiveField(7)
  late String completedStatus; // status considered as "completed" for progress calc

  @HiveField(8)
  late List<TrackItem> items;

  @HiveField(9)
  late DateTime createdAt;

  @HiveField(10)
  late DateTime updatedAt;

  TrackList({
    required this.id,
    required this.title,
    this.description,
    this.categoryId,
    required this.colorValue,
    this.statusOptions = const ['Pending', 'Completed'],
    this.defaultStatus = 'Pending',
    this.completedStatus = 'Completed',
    List<TrackItem>? items,
    required this.createdAt,
    required this.updatedAt,
  }) : items = items ?? [];

  int get totalCount => items.length;

  int get completedCount =>
      items.where((it) => it.status == completedStatus).length;

  int get pendingCount => totalCount - completedCount;

  double get progressPercentage =>
      totalCount == 0 ? 0.0 : (completedCount / totalCount) * 100.0;
}

