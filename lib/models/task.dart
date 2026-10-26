// Task model with manual Hive TypeAdapter
import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  String? note;

  @HiveField(3)
  late DateTime date;

  @HiveField(4)
  late DateTime startTime;

  @HiveField(5)
  late DateTime endTime;

  @HiveField(6)
  int reminderMinutes; // 5, 10, 15, 30

  @HiveField(7)
  String? categoryId;

  @HiveField(8)
  late int colorValue; // stored as int

  @HiveField(9)
  bool isCompleted;

  @HiveField(10)
  late DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    this.note,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.reminderMinutes = 15,
    this.categoryId,
    required this.colorValue,
    this.isCompleted = false,
    required this.createdAt,
  });
}
