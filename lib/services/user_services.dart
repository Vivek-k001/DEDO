import 'package:get_storage/get_storage.dart';

class UserService {
  // Internal storage instance using GetStorage
  static final _box = GetStorage();

  // Get the stored username, return 'Guest' if none found
  static String get username => _box.read('username') ?? 'Guest';

  // Set the username in storage
  static set username(String name) => _box.write('username', name);

  // Check if a username is already stored
  static bool get hasUsername => _box.hasData('username');

  // Clear the stored username
  static Future<void> clearUsername() async => await _box.remove('username');
}
