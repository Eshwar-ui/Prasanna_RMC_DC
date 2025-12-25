import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'database_service.dart';

class AuthService {
  static final AuthService instance = AuthService._init();
  AuthService._init();

  User? _currentUser;
  User? get currentUser => _currentUser;

  Future<bool> login(String username, String password) async {
    final user = await DatabaseService.instance.getUserByUsername(username);

    if (user != null && user.password == password) {
      _currentUser = user;

      // Save login state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_user', username);
      await prefs.setBool('is_logged_in', true);

      return true;
    }
    return false;
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user');
    await prefs.setBool('is_logged_in', false);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

    if (isLoggedIn) {
      final username = prefs.getString('current_user');
      if (username != null) {
        _currentUser = await DatabaseService.instance.getUserByUsername(
          username,
        );
        return _currentUser != null;
      }
    }
    return false;
  }

  Future<User?> createUser({
    required String username,
    required String password,
    required String fullName,
    String role = 'user',
  }) async {
    try {
      final user = User(
        username: username,
        password: password,
        fullName: fullName,
        role: role,
      );
      return await DatabaseService.instance.createUser(user);
    } catch (e) {
      return null;
    }
  }
}
