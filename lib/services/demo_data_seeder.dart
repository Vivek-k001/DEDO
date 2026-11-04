import 'package:uuid/uuid.dart';
import '../models/category.dart';
import '../models/task.dart';
import '../models/user_profile.dart';
import '../models/sticky_note.dart';
import '../models/track_list.dart';
import '../models/track_item.dart';
import 'hive_service.dart';

class DemoDataSeeder {
  static Future<void> seedShowcaseData() async {
    // 1. User Profile
    final existingProfile = HiveService.getProfile();
    final profile = existingProfile ??
        UserProfile(
          username: 'Nihal',
          joinedAt: DateTime.now().subtract(const Duration(days: 45)),
          birthday: DateTime(2001, 8, 14),
        );
    profile.username = 'Nihal';
    await HiveService.saveProfile(profile);

    // 2. Categories
    final categories = [
      Category(id: 'cat_work', name: 'Work', colorValue: 0xFF007AFF), // Blue
      Category(id: 'cat_fitness', name: 'Fitness', colorValue: 0xFF34C759), // Green
      Category(id: 'cat_study', name: 'Study', colorValue: 0xFFAF52DE), // Purple
      Category(id: 'cat_personal', name: 'Personal', colorValue: 0xFFFF9500), // Orange
      Category(id: 'cat_design', name: 'Design', colorValue: 0xFFFF2D55), // Pink
    ];
    for (final cat in categories) {
      await HiveService.categories.put(cat.id, cat);
    }

    // 3. Tasks for Today & This Week
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final tasks = [
      Task(
        id: const Uuid().v4(),
        title: 'Review DEDO UI Design System',
        note: 'Refine liquid glass shaders, specular rim highlights, and edge physics.',
        date: today,
        startTime: DateTime(today.year, today.month, today.day, 9, 0),
        endTime: DateTime(today.year, today.month, today.day, 10, 30),
        categoryId: 'cat_design',
        colorValue: 0xFFFF2D55,
        isCompleted: true,
        createdAt: now.subtract(const Duration(hours: 4)),
      ),
      Task(
        id: const Uuid().v4(),
        title: 'Morning 5K Jog & Cardio',
        note: 'Outdoor run in the park + stretching routine.',
        date: today,
        startTime: DateTime(today.year, today.month, today.day, 7, 0),
        endTime: DateTime(today.year, today.month, today.day, 8, 0),
        categoryId: 'cat_fitness',
        colorValue: 0xFF34C759,
        isCompleted: true,
        createdAt: now.subtract(const Duration(hours: 6)),
      ),
      Task(
        id: const Uuid().v4(),
        title: 'DSML Machine Learning Lab Exam',
        note: 'Practice decision trees, linear regression, and PCA in Python.',
        date: today,
        startTime: DateTime(today.year, today.month, today.day, 14, 0),
        endTime: DateTime(today.year, today.month, today.day, 16, 0),
        categoryId: 'cat_study',
        colorValue: 0xFFAF52DE,
        isCompleted: false,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      Task(
        id: const Uuid().v4(),
        title: 'Team Sync - VKR Softworks',
        note: 'Review project roadmap, upcoming sprint deliverables, and releases.',
        date: today,
        startTime: DateTime(today.year, today.month, today.day, 16, 30),
        endTime: DateTime(today.year, today.month, today.day, 17, 30),
        categoryId: 'cat_work',
        colorValue: 0xFF007AFF,
        isCompleted: false,
        createdAt: now.subtract(const Duration(hours: 1)),
      ),
      Task(
        id: const Uuid().v4(),
        title: 'Read 20 pages of Deep Work',
        note: 'Focus and productivity chapter by Cal Newport.',
        date: today,
        startTime: DateTime(today.year, today.month, today.day, 21, 0),
        endTime: DateTime(today.year, today.month, today.day, 21, 45),
        categoryId: 'cat_personal',
        colorValue: 0xFFFF9500,
        isCompleted: false,
        createdAt: now,
      ),
    ];

    for (final task in tasks) {
      await HiveService.tasks.put(task.id, task);
    }

    // 4. Sticky Notes
    final stickyNotes = [
      StickyNote(
        id: const Uuid().v4(),
        content: 'Ship Dedo v2 update with TrackList module 🚀',
        colorValue: 0xFFFFF59D, // Light yellow
        createdAt: now,
        rotationAngle: -0.04,
      ),
      StickyNote(
        id: const Uuid().v4(),
        content: 'Meeting with VKR Softworks team @ 4:30 PM',
        colorValue: 0xFFFFCC80, // Soft orange
        createdAt: now,
        rotationAngle: 0.03,
      ),
      StickyNote(
        id: const Uuid().v4(),
        content: 'Review Python scikit-learn notes for DSML lab',
        colorValue: 0xFFC8E6C9, // Mint green
        createdAt: now,
        rotationAngle: -0.02,
      ),
      StickyNote(
        id: const Uuid().v4(),
        content: 'Website live at: https://vkr-softworks.web.app/ ✨',
        colorValue: 0xFFBBDEFB, // Ice blue
        createdAt: now,
        rotationAngle: 0.05,
      ),
    ];
    for (final note in stickyNotes) {
      await HiveService.stickyNotes.put(note.id, note);
    }

    // 5. TrackList Trackers
    final tracker1Id = const Uuid().v4();
    final tracker1 = TrackList(
      id: tracker1Id,
      title: 'MCA Class Cake Collection',
      description: 'Tracking class contributions for graduation celebration',
      categoryId: 'cat_personal',
      colorValue: 0xFF007AFF,
      statusOptions: ['Not Received', 'Received'],
      defaultStatus: 'Not Received',
      completedStatus: 'Received',
      createdAt: now.subtract(const Duration(days: 2)),
      updatedAt: now,
      items: [
        TrackItem(id: const Uuid().v4(), name: 'Adil Rahman', status: 'Received', createdAt: now, updatedAt: now),
        TrackItem(id: const Uuid().v4(), name: 'Aswin Kumar', status: 'Received', createdAt: now, updatedAt: now),
        TrackItem(id: const Uuid().v4(), name: 'Devika Nair', status: 'Received', createdAt: now, updatedAt: now),
        TrackItem(id: const Uuid().v4(), name: 'Fahad Fazil', status: 'Received', createdAt: now, updatedAt: now),
        TrackItem(id: const Uuid().v4(), name: 'Gokul Krishna', status: 'Received', createdAt: now, updatedAt: now),
        TrackItem(id: const Uuid().v4(), name: 'Hiba Maryam', status: 'Received', createdAt: now, updatedAt: now),
        TrackItem(id: const Uuid().v4(), name: 'Mohammed Nihal', status: 'Received', createdAt: now, updatedAt: now),
        TrackItem(id: const Uuid().v4(), name: 'Naveen Joseph', status: 'Received', createdAt: now, updatedAt: now),
        TrackItem(id: const Uuid().v4(), name: 'Rahul Varma', status: 'Not Received', note: 'Will pay by GPay tonight', createdAt: now, updatedAt: now),
        TrackItem(id: const Uuid().v4(), name: 'Sneha Santhosh', status: 'Not Received', createdAt: now, updatedAt: now),
        TrackItem(id: const Uuid().v4(), name: 'Vishnu Prasad', status: 'Not Received', createdAt: now, updatedAt: now),
        TrackItem(id: const Uuid().v4(), name: 'Zara Thomas', status: 'Received', createdAt: now, updatedAt: now),
      ],
    );

    final tracker2Id = const Uuid().v4();
    final tracker2 = TrackList(
      id: tracker2Id,
      title: 'DSML Project Submission Checklist',
      description: 'Verification of laboratory code modules and documentation',
      categoryId: 'cat_study',
      colorValue: 0xFF34C759,
      statusOptions: ['Pending', 'Completed'],
      defaultStatus: 'Pending',
      completedStatus: 'Completed',
      createdAt: now.subtract(const Duration(days: 1)),
      updatedAt: now,
      items: [
        TrackItem(id: const Uuid().v4(), name: 'Linear Regression model', status: 'Completed', createdAt: now, updatedAt: now),
        TrackItem(id: const Uuid().v4(), name: 'K-Nearest Neighbors (KNN)', status: 'Completed', createdAt: now, updatedAt: now),
        TrackItem(id: const Uuid().v4(), name: 'Decision Tree Classifier', status: 'Completed', createdAt: now, updatedAt: now),
        TrackItem(id: const Uuid().v4(), name: 'K-Means Clustering', status: 'Pending', createdAt: now, updatedAt: now),
        TrackItem(id: const Uuid().v4(), name: 'Principal Component Analysis (PCA)', status: 'Pending', createdAt: now, updatedAt: now),
      ],
    );

    final tracker3Id = const Uuid().v4();
    final tracker3 = TrackList(
      id: tracker3Id,
      title: 'Hackathon Team Attendance',
      description: 'Morning and evening attendance check for participants',
      categoryId: 'cat_work',
      colorValue: 0xFFFF9500,
      statusOptions: ['Absent', 'Present'],
      defaultStatus: 'Absent',
      completedStatus: 'Present',
      createdAt: now.subtract(const Duration(hours: 8)),
      updatedAt: now,
      items: [
        TrackItem(id: const Uuid().v4(), name: 'Frontend Lead', status: 'Present', createdAt: now, updatedAt: now),
        TrackItem(id: const Uuid().v4(), name: 'Backend Architect', status: 'Present', createdAt: now, updatedAt: now),
        TrackItem(id: const Uuid().v4(), name: 'UI/UX Designer', status: 'Present', createdAt: now, updatedAt: now),
        TrackItem(id: const Uuid().v4(), name: 'ML Engineer', status: 'Absent', note: 'Arriving at 11 AM', createdAt: now, updatedAt: now),
      ],
    );

    await HiveService.trackLists.put(tracker1.id, tracker1);
    await HiveService.trackLists.put(tracker2.id, tracker2);
    await HiveService.trackLists.put(tracker3.id, tracker3);
  }
}

