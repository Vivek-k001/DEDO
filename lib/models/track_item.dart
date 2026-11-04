import 'package:hive/hive.dart';

part 'track_item.g.dart';

@HiveType(typeId: 5)
class TrackItem extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String status;

  @HiveField(3)
  String? note;

  @HiveField(4)
  late DateTime createdAt;

  @HiveField(5)
  late DateTime updatedAt;

  TrackItem({
    required this.id,
    required this.name,
    required this.status,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  TrackItem copyWith({
    String? id,
    String? name,
    String? status,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TrackItem(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

