import 'package:hive/hive.dart';

part 'sticky_note.g.dart';

@HiveType(typeId: 3)
class StickyNote extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String content;

  @HiveField(2)
  late int colorValue;

  @HiveField(3)
  late DateTime createdAt;

  @HiveField(4)
  late double rotationAngle;

  StickyNote({
    required this.id,
    required this.content,
    required this.colorValue,
    required this.createdAt,
    this.rotationAngle = 0.0,
  });
}
