import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kIsLoggedIn = 'isLoggedIn';
const String _kUserEmail = 'userEmail';
const String _validEmail = 'adminmasderm@test.com';
const String _validPassword = '1234';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isLoading = true;
  String _userEmail = '';
  String? _errorMessage;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String get userEmail => _userEmail;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isLoggedIn = prefs.getBool(_kIsLoggedIn) ?? false;
      _userEmail = prefs.getString(_kUserEmail) ?? '';
    } catch (_) {
      _isLoggedIn = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _errorMessage = null;

    if (email.trim().toLowerCase() == _validEmail &&
        password == _validPassword) {
      _isLoggedIn = true;
      _userEmail = email.trim().toLowerCase();
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_kIsLoggedIn, true);
        await prefs.setString(_kUserEmail, _userEmail);
      } catch (_) {}
      notifyListeners();
      return true;
    }

    _errorMessage = 'Email ou password incorretos.';
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _userEmail = '';
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kIsLoggedIn);
      await prefs.remove(_kUserEmail);
    } catch (_) {}
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
