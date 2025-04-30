class TaskModel {
  int? id;
  String title;
  String note;
  int isCompleted;
  String date;
  String startTime;
  String endTime;
  int colorIndex;
  int remind;
  String repeat;

  TaskModel({
    this.id,
    this.title = '',
    this.note = '',
    this.isCompleted = 0,
    this.date = '',
    this.startTime = '',
    this.endTime = '',
    this.colorIndex = 0,
    this.remind = 0,
    this.repeat = '',
  });

  TaskModel.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      title = json['title'] ?? '',
      note = json['note'] ?? '',
      isCompleted = json['isCompleted'] ?? 0,
      date = json['date'] ?? '',
      startTime = json['startTime'] ?? '',
      endTime = json['endTime'] ?? '',
      colorIndex = json['colorIndex'] ?? 0,
      remind = json['remind'] ?? 0,
      repeat = json['repeat'] ?? '';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'note': note,
      'isCompleted': isCompleted,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'colorIndex': colorIndex,
      'remind': remind,
      'repeat': repeat,
    };
  }
}
