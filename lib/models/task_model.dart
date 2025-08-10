/// A data model representing a task item in the to-do application.
/// Includes title, note, time details, color coding, reminder settings,
/// completion status, and timestamps for tracking.
class TaskModel {
  int?
  id; // Optional database ID for the task (nullable for tasks not yet stored).
  final String title; // The main title of the task.
  final String note; // Additional notes or details about the task.
  final String date; // The scheduled date for the task (as a string).
  final String startTime; // Start time of the task.
  final String endTime; // End time of the task.
  final int color; // Color code to visually represent or categorize the task.
  final int remind; // Reminder time in minutes before task start.
  bool isCompleted; // Whether the task has been marked as completed.
  final String?
  categoryId; // Optional reference to a category ID (if the task is categorized).
  String? completedAt; // Timestamp when task was marked completed.
  String? updatedAt; // Timestamp of the last update.
  String? createdAt; // Timestamp when the task was created.

  /// Constructs a [TaskModel] with required and optional task properties.
  /// Defaults like empty strings and `isCompleted = false` are used to simplify task creation.
  TaskModel({
    this.id,
    required this.title,
    required this.note,
    this.date = '',
    this.startTime = '',
    this.endTime = '',
    required this.color,
    this.remind = 0,
    this.isCompleted = false,
    this.categoryId,
    this.completedAt,
    this.createdAt,
    this.updatedAt,
  });

  /// Returns a new [TaskModel] with updated fields.
  /// Useful for state updates where only some properties change.
  TaskModel copyWith({
    int? id,
    String? title,
    String? note,
    String? date,
    String? startTime,
    String? endTime,
    int? color,
    int? remind,
    bool? isCompleted,
    String? categoryId,
    String? completedAt,
    String? createdAt,
    String? updatedAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      note: note ?? this.note,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      color: color ?? this.color,
      remind: remind ?? this.remind,
      isCompleted: isCompleted ?? this.isCompleted,
      categoryId: categoryId ?? this.categoryId,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Converts the task object into a map, useful for database operations.
  /// The boolean [isCompleted] is stored as `1` or `0` for database compatibility.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'note': note,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'color': color,
      'remind': remind,
      'isCompleted': isCompleted ? 1 : 0,
      'categoryId': categoryId,
      'completedAt': completedAt,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Creates a [TaskModel] instance from a map, typically retrieved from a database.
  /// Converts `isCompleted` from `1`/`0` back to `true`/`false`.
  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'],
      title: map['title'],
      note: map['note'],
      date: map['date'],
      startTime: map['startTime'],
      endTime: map['endTime'],
      color: map['color'],
      remind: map['remind'],
      isCompleted: map['isCompleted'] == 1,
      categoryId: map['categoryId'],
      completedAt: map['completedAt'] ?? '',
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
    );
  }
}
