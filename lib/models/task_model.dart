class TaskModel {
  int? id;
  final String title;
  final String note;
  final String date;
  final String startTime;
  final String endTime;
  final int colorIndex;
  final int remind;
  final String repeat;
  bool isCompleted;
  final String? categoryId;

  TaskModel({
    this.id,
    required this.title,
    required this.note,
    this.date = '',
    this.startTime = '',
    this.endTime = '',
    this.colorIndex = 0,
    this.remind = 0,
    this.repeat = '',
    this.isCompleted = false,
    this.categoryId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'note': note,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'colorIndex': colorIndex,
      'remind': remind,
      'repeat': repeat,
      'isCompleted': isCompleted ? 1 : 0,
      'categoryId': categoryId,
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'],
      title: map['title'],
      note: map['note'],
      date: map['date'],
      startTime: map['startTime'],
      endTime: map['endTime'],
      colorIndex: map['colorIndex'],
      remind: map['remind'],
      repeat: map['repeat'],
      isCompleted: map['isCompleted'] == 1,
      categoryId: map['categoryId'],
    );
  }
}
