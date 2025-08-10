import 'package:dedo/db/db_helper.dart';
import 'package:dedo/models/task_model.dart';
import 'package:flutter/material.dart';

/// Repository for managing tasks in the database.
class TaskRepository {
  final DBHelper dbHelper;

  TaskRepository(this.dbHelper);

  /// Inserts a new task and returns the inserted row ID.
  Future<int> insertTask(TaskModel task) async {
    final db = await dbHelper.database;
    return await db.insert('tasks', task.toMap());
  }

  /// Retrieves all tasks ordered by creation date (newest first).
  Future<List<TaskModel>> getAllTasks() async {
    final db = await dbHelper.database;
    final results = await db.query('tasks', orderBy: 'createdAt DESC');
    return results.map((result) => TaskModel.fromMap(result)).toList();
  }

  /// Gets tasks filtered by category ID, ordered by creation date.
  Future<List<TaskModel>> getTasksByCategory(String categoryId) async {
    final db = await dbHelper.database;
    final results = await db.query(
      'tasks',
      where: 'categoryId = ?',
      whereArgs: [categoryId],
      orderBy: 'createdAt DESC',
    );
    return results.map((result) => TaskModel.fromMap(result)).toList();
  }

  /// Gets tasks filtered by a date range, ordered by date ascending.
  Future<List<TaskModel>> getTasksByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await dbHelper.database;
    final results = await db.query(
      'tasks',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'date ASC',
    );
    return results.map((result) => TaskModel.fromMap(result)).toList();
  }

  /// Updates an existing task identified by its ID.
  Future<int> updateTask(TaskModel task) async {
    final db = await dbHelper.database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  /// Deletes a task by ID.
  Future<int> deleteTask(int id) async {
    final db = await dbHelper.database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  /// Retrieves a single task by ID.
  Future<TaskModel?> getTaskById(int id) async {
    final db = await dbHelper.database;
    final results = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isNotEmpty) return TaskModel.fromMap(results.first);
    return null;
  }

  /// Toggles a task's completion status.
  /// Also updates 'completedAt' and 'updatedAt' timestamps.
  Future<int> toggleTaskCompletion(int id, bool isCompleted) async {
    final db = await dbHelper.database;
    final now = DateTime.now().toIso8601String();

    return await db.update(
      'tasks',
      {
        'isCompleted': isCompleted ? 1 : 0,
        'completedAt': isCompleted ? now : null,
        'updatedAt': now,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Returns a list of counts of completed tasks per day for the current week (Mon-Sun).
  Future<List<double>> getCurrentWeekCompletionStats() async {
    final db = await dbHelper.database;
    final now = DateTime.now();

    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeekDate = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    );
    final endOfWeek = startOfWeekDate.add(
      const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
    );

    debugPrint(
      'Loading week stats from ${startOfWeekDate.toIso8601String()} to ${endOfWeek.toIso8601String()}',
    );

    final results = await db.query(
      'tasks',
      where: 'isCompleted = 1 AND completedAt >= ? AND completedAt <= ?',
      whereArgs: [
        startOfWeekDate.toIso8601String(),
        endOfWeek.toIso8601String(),
      ],
    );

    List<double> dailyCounts = List.filled(7, 0);

    for (var row in results) {
      final completedAtStr = row['completedAt'] as String?;
      if (completedAtStr != null) {
        try {
          final completedAt = DateTime.parse(completedAtStr);
          final dayOfWeek = completedAt.weekday - 1; // 0=Monday ... 6=Sunday
          if (dayOfWeek >= 0 && dayOfWeek < 7) {
            dailyCounts[dayOfWeek] += 1;
          }
        } catch (e) {
          debugPrint('Error parsing completedAt date: $e');
        }
      }
    }

    debugPrint('Weekly stats: $dailyCounts');
    return dailyCounts;
  }

  /// Calculates the current consecutive day streak of completed tasks.
  Future<int> getCurrentStreak() async {
    final db = await dbHelper.database;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final results = await db.query(
      'tasks',
      where: 'isCompleted = 1 AND completedAt IS NOT NULL',
      orderBy: 'completedAt DESC',
    );

    if (results.isEmpty) return 0;

    final completionDates = <DateTime>{};

    for (var row in results) {
      final completedAtStr = row['completedAt'] as String?;
      if (completedAtStr != null) {
        try {
          final completedAt = DateTime.parse(completedAtStr);
          final dateOnly = DateTime(
            completedAt.year,
            completedAt.month,
            completedAt.day,
          );
          completionDates.add(dateOnly);
        } catch (e) {
          debugPrint('Error parsing completedAt date for streak: $e');
        }
      }
    }

    final sortedDates =
        completionDates.toList()..sort((a, b) => b.compareTo(a));

    int streak = 0;
    DateTime currentDate = today;

    if (sortedDates.isNotEmpty && !sortedDates.contains(today)) {
      currentDate = today.subtract(const Duration(days: 1));
    }

    for (final date in sortedDates) {
      if (date.isAtSameMomentAs(currentDate)) {
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else if (date.isBefore(currentDate)) {
        break;
      }
    }

    debugPrint('Current streak: $streak days');
    return streak;
  }

  /// Provides a summary of task counts: completed, pending, overdue, total.
  Future<Map<String, int>> getTaskCompletionSummary() async {
    final db = await dbHelper.database;
    final results = await db.query('tasks');

    int completed = 0;
    int pending = 0;
    int overdue = 0;
    final now = DateTime.now();

    for (var row in results) {
      final isCompleted = (row['isCompleted'] as int) == 1;
      if (isCompleted) {
        completed++;
      } else {
        pending++;
        final dueDateStr = row['date'] as String?;
        if (dueDateStr != null) {
          try {
            final dueDate = DateTime.parse(dueDateStr);
            if (dueDate.isBefore(now)) overdue++;
          } catch (e) {
            debugPrint('Error parsing due date: $e');
          }
        }
      }
    }

    return {
      'completed': completed,
      'pending': pending,
      'overdue': overdue,
      'total': results.length,
    };
  }

  /// Returns daily counts of completed tasks for the current month.
  Future<List<double>> getMonthlyCompletionStats() async {
    final db = await dbHelper.database;
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    final results = await db.query(
      'tasks',
      where: 'isCompleted = 1 AND completedAt >= ? AND completedAt <= ?',
      whereArgs: [startOfMonth.toIso8601String(), endOfMonth.toIso8601String()],
    );

    final daysInMonth = endOfMonth.day;
    List<double> dailyCounts = List.filled(daysInMonth, 0);

    for (var row in results) {
      final completedAtStr = row['completedAt'] as String?;
      if (completedAtStr != null) {
        try {
          final completedAt = DateTime.parse(completedAtStr);
          if (completedAt.month == now.month && completedAt.year == now.year) {
            final dayOfMonth = completedAt.day - 1;
            if (dayOfMonth >= 0 && dayOfMonth < dailyCounts.length) {
              dailyCounts[dayOfMonth] += 1;
            }
          }
        } catch (e) {
          debugPrint('Error parsing date for monthly stats: $e');
        }
      }
    }

    return dailyCounts;
  }

  /// Returns completion rates (%) per category.
  Future<Map<String, double>> getCategoryCompletionStats() async {
    final db = await dbHelper.database;
    final results = await db.query('tasks');

    final categoryStats = <String, Map<String, int>>{};

    for (var row in results) {
      final categoryId = row['categoryId'] as String? ?? 'Uncategorized';
      final isCompleted = (row['isCompleted'] as int) == 1;

      categoryStats.putIfAbsent(categoryId, () => {'completed': 0, 'total': 0});
      categoryStats[categoryId]!['total'] =
          categoryStats[categoryId]!['total']! + 1;

      if (isCompleted) {
        categoryStats[categoryId]!['completed'] =
            categoryStats[categoryId]!['completed']! + 1;
      }
    }

    final completionRates = <String, double>{};
    categoryStats.forEach((category, stats) {
      final total = stats['total']!;
      final completed = stats['completed']!;
      completionRates[category] = total > 0 ? (completed / total) * 100 : 0.0;
    });

    return completionRates;
  }

  /// Calculates the longest consecutive day streak of completed tasks.
  Future<int> getLongestStreak() async {
    final db = await dbHelper.database;

    final results = await db.query(
      'tasks',
      where: 'isCompleted = 1 AND completedAt IS NOT NULL',
      orderBy: 'completedAt ASC',
    );

    if (results.isEmpty) return 0;

    final completionDates = <DateTime>{};

    for (var row in results) {
      final completedAtStr = row['completedAt'] as String?;
      if (completedAtStr != null) {
        try {
          final completedAt = DateTime.parse(completedAtStr);
          final dateOnly = DateTime(
            completedAt.year,
            completedAt.month,
            completedAt.day,
          );
          completionDates.add(dateOnly);
        } catch (e) {
          debugPrint('Error parsing date for longest streak: $e');
        }
      }
    }

    final sortedDates = completionDates.toList()..sort();

    int longestStreak = 0;
    int currentStreak = 1;

    for (int i = 1; i < sortedDates.length; i++) {
      final currentDate = sortedDates[i];
      final previousDate = sortedDates[i - 1];

      if (currentDate.difference(previousDate).inDays == 1) {
        currentStreak++;
      } else {
        longestStreak =
            longestStreak > currentStreak ? longestStreak : currentStreak;
        currentStreak = 1;
      }
    }

    return longestStreak > currentStreak ? longestStreak : currentStreak;
  }
}
