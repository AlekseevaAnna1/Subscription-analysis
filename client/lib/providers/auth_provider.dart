import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import '../models/api_response.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null && _user!.token != null;

  Future<ApiResponse> register(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await _authService.register(email, password);

    _isLoading = false;

    if (response.success) {
      // После успешной регистрации автоматически входим
      final loginResponse = await login(email, password);
      notifyListeners();
      return loginResponse;
    } else {
      _error = response.message;
      notifyListeners();
      return response;
    }
  }

  Future<ApiResponse> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await _authService.login(email, password);

    _isLoading = false;

    if (response.success) {
      _user = User(
        id: response.data?['id'] ?? 1,
        email: email,
        token: response.data?['token'] ?? 'dummy_token_here',
      );
      _error = null;
      notifyListeners();
      return response;
    } else {
      _error = response.message;
      notifyListeners();
      return response;
    }
  }

  Future<void> logout() async {
    _user = null;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}