import 'package:flutter/material.dart' hide Notification;
import '../models/notification.dart';
import '../models/notification_group.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  // Состояние
  List<NotificationGroup> _notificationGroups = [];
  bool _isLoading = false;
  String? _error;
  bool _hasLoaded = false;
  int _totalUnread = 0;
  
  String? _authToken;
  NotificationService? _notificationService;

  // Геттеры для доступа к состоянию из UI
  List<NotificationGroup> get notificationGroups => _notificationGroups;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasLoaded => _hasLoaded;
  int get totalUnread => _totalUnread;
  String? get authToken => _authToken;

  // Общее количество уведомлений
  int get totalNotifications {
    return _notificationGroups.fold(
      0,
      (sum, group) => sum + group.notifications.length,
    );
  }

  // Список всех уведомлений (разгруппированный)
  List<Notification> get allNotifications {
    return _notificationGroups
        .expand((group) => group.notifications)
        .toList();
  }

  // Установка токена авторизации
  void setAuthToken(String? token) {
    _authToken = token;
    if (token != null) {
      _notificationService = NotificationService(authToken: token);
    } else {
      _notificationService = null;
    }
    _error = null; // Очищаем ошибку при установке токена
    notifyListeners();
  }

  // Безопасное получение сервиса
  NotificationService _getService() {
    if (_notificationService == null) {
      throw Exception('Сервис не инициализирован. Авторизуйтесь.');
    }
    return _notificationService!;
  }

  // 🔥 Инициализация с токеном (обновленный метод)
  void initializeWithToken(String token) {
    _authToken = token;
    _notificationService = NotificationService(authToken: token);
    _error = null;
    _hasLoaded = false; // Позволяем перезагрузить данные
    notifyListeners();
  }

  // 🔥 Ручная установка ошибки
  void setError(String error) {
    _error = error;
    notifyListeners();
  }

  // 🔥 Проверка инициализации
  bool get isInitialized => _notificationService != null && _authToken != null;

  // Загрузка группированных уведомлений
  Future<void> loadNotificationGroups({bool forceRefresh = false}) async {
    if (_isLoading || (_hasLoaded && !forceRefresh)) return;

    // Проверяем авторизацию перед загрузкой
    if (!isInitialized) {
      _error = 'Сервис не инициализирован. Авторизуйтесь.';
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final service = _getService();
      final groups = await service.getGroupedNotifications();
      _notificationGroups = groups;
      
      // Обновляем счетчик непрочитанных
      _updateUnreadCount();
      
      _hasLoaded = true;
      _error = null;
    } catch (e) {
      _error = 'Ошибка загрузки уведомлений: ${e.toString()}';
      print('Ошибка загрузки уведомлений: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Загрузка уведомлений по конкретной подписке (при переходе в "чат")
  Future<List<Notification>> loadSubscriptionNotifications(int subscriptionId) async {
    // Проверяем инициализацию
    if (!isInitialized) {
      throw Exception('Сервис не инициализирован. Авторизуйтесь.');
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final service = _getService();
      final notifications = await service.getSubscriptionNotifications(subscriptionId);
      
      // Уведомления уже отсортированы от старых к новым (новые снизу) в сервисе
      _error = null;
      return notifications;
    } catch (e) {
      _error = 'Ошибка загрузки уведомлений по подписке: ${e.toString()}';
      print('Ошибка загрузки уведомлений по подписке: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Обновление счетчика непрочитанных
  void _updateUnreadCount() {
    _totalUnread = _notificationGroups.fold(
      0,
      (sum, group) => sum + group.unreadCount,
    );
  }

  // Пометить все уведомления подписки как прочитанные (на сервере и локально)
  Future<bool> markSubscriptionAsRead(int subscriptionId) async {
    // Проверяем инициализацию
    if (!isInitialized) {
      _error = 'Сервис не инициализирован. Авторизуйтесь.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final service = _getService();
      
      // 1. Отправляем запрос на сервер
      await service.markSubscriptionNotificationsAsRead(subscriptionId);
      
      // 2. Обновляем локальное состояние
      final index = _notificationGroups.indexWhere(
        (group) => group.subscriptionId == subscriptionId,
      );
      
      if (index != -1) {
        // Создаем локальную копию с прочитанными уведомлениями
        final updatedGroup = _notificationGroups[index].createCopyWithAllRead();
        _notificationGroups[index] = updatedGroup;
        
        // 3. Обновляем счетчик
        _updateUnreadCount();
      }
      
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Ошибка пометки уведомлений как прочитанных: ${e.toString()}';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🔥 Обновить токен (если истек)
  Future<bool> refreshToken(String newToken) async {
    try {
      setAuthToken(newToken);
      return true;
    } catch (e) {
      _error = 'Ошибка обновления токена: $e';
      notifyListeners();
      return false;
    }
  }

  // Получить количество непрочитанных для подписки
  Future<int?> getSubscriptionUnreadCount(int subscriptionId) async {
    if (!isInitialized) {
      return null;
    }

    try {
      final service = _getService();
      final count = await service.getSubscriptionUnreadCount(subscriptionId);
      return count;
    } catch (e) {
      print('Ошибка получения количества непрочитанных: $e');
      return null;
    }
  }

  // 🔥 Очистка всех данных (при логауте)
  void clearData() {
    _notificationGroups = [];
    _isLoading = false;
    _error = null;
    _hasLoaded = false;
    _totalUnread = 0;
    _authToken = null;
    _notificationService = null;
    notifyListeners();
  }

  // Поиск уведомлений
  List<NotificationGroup> search(String query) {
    if (query.isEmpty) return _notificationGroups;
    
    return _notificationGroups.where((group) {
      // Ищем в названии подписки
      if (group.subscriptionName.toLowerCase().contains(query.toLowerCase())) {
        return true;
      }
      
      // Ищем в сообщениях уведомлений
      return group.notifications.any((notification) =>
        notification.message.toLowerCase().contains(query.toLowerCase()) ||
        notification.title.toLowerCase().contains(query.toLowerCase())
      );
    }).toList();
  }

  // Фильтрация по типу уведомления
  List<NotificationGroup> filterByType(String type) {
    if (type == 'Все') return _notificationGroups;
    
    return _notificationGroups.map((group) {
      final filteredNotifications = group.notifications
          .where((notification) => notification.type == type)
          .toList();
      
      if (filteredNotifications.isEmpty) return null;
      
      return group.copyWith(
        notifications: filteredNotifications,
        unreadCount: filteredNotifications
            .where((n) => !n.read)
            .length,
      );
    }).where((group) => group != null).cast<NotificationGroup>().toList();
  }

  // Очистка ошибки
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Принудительное обновление
  Future<void> refresh() async {
    if (!isInitialized) {
      _error = 'Сервис не инициализирован. Авторизуйтесь.';
      notifyListeners();
      return;
    }

    _hasLoaded = false;
    await loadNotificationGroups(forceRefresh: true);
  }

  // Получение группы по ID подписки
  NotificationGroup? getGroupBySubscriptionId(int subscriptionId) {
    try {
      return _notificationGroups.firstWhere(
        (group) => group.subscriptionId == subscriptionId,
      );
    } catch (e) {
      return null;
    }
  }

  // Получение уведомлений по ID подписки
  List<Notification> getNotificationsBySubscriptionId(int subscriptionId) {
    final group = getGroupBySubscriptionId(subscriptionId);
    if (group == null) return [];
    
    // Новые снизу
    return group.sortedNotifications;
  }

  // Проверка, есть ли непрочитанные уведомления
  bool get hasUnreadNotifications => _totalUnread > 0;

  // Получить группы с непрочитанными уведомлениями
  List<NotificationGroup> get groupsWithUnread {
    return _notificationGroups.where((group) => group.unreadCount > 0).toList();
  }

  // Получить список всех подписок с уведомлениями
  List<int> get subscriptionIdsWithNotifications {
    return _notificationGroups.map((group) => group.subscriptionId).toList();
  }

  // 🔥 Обновить состояние при изменении авторизации
  void updateAuthStatus(bool isAuthenticated, String? token) {
    if (isAuthenticated && token != null) {
      // Если токен изменился, обновляем
      if (_authToken != token) {
        initializeWithToken(token);
      }
    } else {
      // Если разлогинились, очищаем данные
      clearData();
    }
  }
}