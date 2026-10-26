import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';
import '../services/hive_service.dart';

final profileProvider =
    StateNotifierProvider<ProfileNotifier, UserProfile?>((ref) {
  return ProfileNotifier();
});

class ProfileNotifier extends StateNotifier<UserProfile?> {
  ProfileNotifier() : super(null) {
    state = HiveService.getProfile();
  }

  Future<void> saveProfile(UserProfile profile) async {
    await HiveService.saveProfile(profile);
    state = profile;
  }

  bool get hasProfile => state != null;
}
