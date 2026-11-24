import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../services/api_service.dart';

/// Стан входу: завантаження, помилка, поточний користувач.
class AuthProvider extends ChangeNotifier {
  AuthProvider(this._api);

  final ApiService _api;

  bool _isLoading = false;
  String? _errorMessage;
  User? _user;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get user => _user;
  bool get isLoggedIn => _user != null;

  /// Повертає true, якщо вхід успішний.
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _user = await _api.login(email.trim(), password);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _api.logout();
    _user = null;
    notifyListeners();
  }
}
