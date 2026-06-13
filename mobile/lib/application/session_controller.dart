import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kUserId = 'userId';
const _kUserName = 'userName';

class SessionController extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kUserId);
  }

  Future<void> saveSession(String userId, String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUserId, userId);
    await prefs.setString(_kUserName, name);
    state = AsyncData(userId);
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kUserId);
    await prefs.remove(_kUserName);
    state = const AsyncData(null);
  }

  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kUserName);
  }
}

final sessionControllerProvider =
    AsyncNotifierProvider<SessionController, String?>(SessionController.new);
