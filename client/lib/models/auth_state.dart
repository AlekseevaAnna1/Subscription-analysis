// lib/models/auth_state.dart
import 'user.dart';

enum AuthStatus {
  unauthenticated, // Пользователь не аутентифицирован
  authenticated,    // Пользователь аутентифицирован
  loading,         // Загрузка
  error,           // Ошибка
}

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;
  final DateTime? lastUpdated;

  AuthState({
    required this.status,
    this.user,
    this.errorMessage,
    this.lastUpdated,
  });

  // Начальное состояние
  factory AuthState.initial() {
    return AuthState(
      status: AuthStatus.unauthenticated,
      user: null,
      errorMessage: null,
      lastUpdated: DateTime.now(),
    );
  }

  // Состояние загрузки
  factory AuthState.loading() {
    return AuthState(
      status: AuthStatus.loading,
      user: null,
      errorMessage: null,
      lastUpdated: DateTime.now(),
    );
  }

  // Успешная аутентификация
  factory AuthState.authenticated(User user) {
    return AuthState(
      status: AuthStatus.authenticated,
      user: user,
      errorMessage: null,
      lastUpdated: DateTime.now(),
    );
  }

  // Состояние ошибки
  factory AuthState.error(String errorMessage) {
    return AuthState(
      status: AuthStatus.error,
      user: null,
      errorMessage: errorMessage,
      lastUpdated: DateTime.now(),
    );
  }

  // Выход из системы
  factory AuthState.unauthenticated() {
    return AuthState(
      status: AuthStatus.unauthenticated,
      user: null,
      errorMessage: null,
      lastUpdated: DateTime.now(),
    );
  }

  // Копирование с обновлениями
  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
    DateTime? lastUpdated,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  String toString() {
    return 'AuthState(status: $status, user: $user, error: $errorMessage)';
  }
}