import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<SubscriptionNotification> _notifications = [
    SubscriptionNotification(
      id: '1',
      subscriptionName: 'КиноПоиск',
      amount: 299,
      daysLeft: 3,
      date: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
      icon: Icons.movie,
      color: Colors.red,
    ),
    SubscriptionNotification(
      id: '2',
      subscriptionName: 'Spotify',
      amount: 169,
      daysLeft: 1,
      date: DateTime.now().subtract(const Duration(hours: 5)),
      isRead: false,
      icon: Icons.music_note,
      color: Colors.green,
    ),
    SubscriptionNotification(
      id: '3',
      subscriptionName: 'Яндекс Музыка',
      amount: 199,
      daysLeft: 7,
      date: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
      icon: Icons.audiotrack,
      color: Colors.orange,
    ),
    SubscriptionNotification(
      id: '4',
      subscriptionName: 'Okko',
      amount: 399,
      daysLeft: 2,
      date: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
      icon: Icons.play_circle_fill,
      color: Colors.purple,
    ),

    SubscriptionNotification(
      id: '5',
      subscriptionName: 'Netflix',
      amount: 499,
      daysLeft: 0,
      date: DateTime(2024, 11, 15, 14, 30),
      isRead: true,
      icon: Icons.play_circle_outline,
      color: Colors.red,
    ),
    SubscriptionNotification(
      id: '6',
      subscriptionName: 'Apple Music',
      amount: 199,
      daysLeft: 0,
      date: DateTime(2024, 11, 10, 9, 15),
      isRead: true,
      icon: Icons.music_note,
      color: Colors.pink,
    ),
    SubscriptionNotification(
      id: '7',
      subscriptionName: 'YouTube Premium',
      amount: 299,
      daysLeft: 0,
      date: DateTime(2024, 10, 25, 18, 45),
      isRead: true,
      icon: Icons.video_library,
      color: Colors.red,
    ),
    SubscriptionNotification(
      id: '8',
      subscriptionName: 'Amazon Prime',
      amount: 399,
      daysLeft: 0,
      date: DateTime(2024, 10, 15, 11, 20),
      isRead: true,
      icon: Icons.shopping_basket,
      color: Colors.blue,
    ),
  ];

  Map<String, List<SubscriptionNotification>> get _groupedNotifications {
    final Map<String, List<SubscriptionNotification>> grouped = {};
    
    for (final notification in _notifications) {
      final monthKey = _getMonthKey(notification.date);
      if (!grouped.containsKey(monthKey)) {
        grouped[monthKey] = [];
      }
      grouped[monthKey]!.add(notification);
    }
    
    for (final key in grouped.keys) {
      grouped[key]!.sort((a, b) => b.date.compareTo(a.date));
    }
    
    return grouped;
  }

  String _getMonthKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final thisWeekStart = today.subtract(Duration(days: today.weekday - 1));
    
    if (date.isAfter(today)) {
      return 'Сегодня';
    } else if (date.isAfter(yesterday)) {
      return 'Вчера';
    } else if (date.isAfter(thisWeekStart)) {
      return 'На этой неделе';
    } else {
      final monthNames = [
        'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь',
        'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь'
      ];
      return '${monthNames[date.month - 1]} ${date.year}';
    }
  }

  List<String> get _sortedMonthKeys {
    final keys = _groupedNotifications.keys.toList();
    keys.sort((a, b) {
      final order = ['Сегодня', 'Вчера', 'На этой неделе'];
      final aIndex = order.indexOf(a);
      final bIndex = order.indexOf(b);
      
      if (aIndex != -1 && bIndex != -1) return aIndex.compareTo(bIndex);
      if (aIndex != -1) return -1;
      if (bIndex != -1) return 1;
      
      return _parseMonthYear(b).compareTo(_parseMonthYear(a));
    });
    
    return keys;
  }

  DateTime _parseMonthYear(String monthYear) {
    final parts = monthYear.split(' ');
    final monthNames = [
      'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь',
      'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь'
    ];
    final month = monthNames.indexOf(parts[0]) + 1;
    final year = int.parse(parts[1]);
    return DateTime(year, month);
  }

  void _markAsRead(String notificationId) {
    setState(() {
      final notification = _notifications.firstWhere(
        (n) => n.id == notificationId,
      );
      notification.isRead = true;
    });
  }

  void _openNotificationMessages(BuildContext context, SubscriptionNotification notification) {
    _markAsRead(notification.id);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationMessagesScreen(notification: notification),
      ),
    );
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'только что';
    if (difference.inMinutes < 60) return '${difference.inMinutes} мин назад';
    if (difference.inHours < 24) return '${difference.inHours} ч назад';
    if (difference.inDays < 7) return '${difference.inDays} д назад';
    return '${date.day}.${date.month}.${date.year}';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  String _formatTimeOnly(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Уведомления',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF9C27B0),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _notifications.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Нет уведомлений',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _sortedMonthKeys.length,
              itemBuilder: (context, index) {
                final monthKey = _sortedMonthKeys[index];
                final notifications = _groupedNotifications[monthKey]!;
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        monthKey,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    
                    ...notifications.map((notification) => 
                      _buildNotificationCard(notification, context)
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildNotificationCard(SubscriptionNotification notification, BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      color: notification.isRead ? Colors.white : const Color(0xFFF0F8FF),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: notification.color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(notification.icon, color: notification.color, size: 28),
        ),
        title: Text(
          notification.subscriptionName,
          style: TextStyle(
            fontSize: 16,
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.daysLeft > 0 
                ? 'Списание ${notification.amount} ₽ через ${notification.daysLeft} ${_getDayText(notification.daysLeft)}'
                : 'Списано ${notification.amount} ₽',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 2),
            Text(
              _formatTime(notification.date),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: notification.isRead
            ? null
            : Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
        onTap: () => _openNotificationMessages(context, notification),
      ),
    );
  }

  String _getDayText(int days) {
    if (days == 1) return 'день';
    if (days >= 2 && days <= 4) return 'дня';
    return 'дней';
  }
}

class NotificationMessagesScreen extends StatelessWidget {
  final SubscriptionNotification notification;

  const NotificationMessagesScreen({
    Key? key,
    required this.notification,
  }) : super(key: key);

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  String _formatTimeOnly(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getDayText(int days) {
    if (days == 1) return 'день';
    if (days >= 2 && days <= 4) return 'дня';
    return 'дней';
  }

  @override
  Widget build(BuildContext context) {
    final combinedMessage = Message(
      text: 'Напоминаем, что через ${notification.daysLeft} ${_getDayText(notification.daysLeft)} будет списано ${notification.amount} ₽ за подписку ${notification.subscriptionName}. Вы можете отменить подписку в любое время в настройках приложения.',
      time: notification.date,
      isSystem: true,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFE5E5E5),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.subscriptionName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              notification.daysLeft > 0 
                ? 'Списание ${notification.amount} ₽ через ${notification.daysLeft} ${_getDayText(notification.daysLeft)}'
                : 'Списано ${notification.amount} ₽',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF9C27B0),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildMessageBubble(combinedMessage, context),
            ),
          ),
          _buildInputField(context),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey,
                width: 0.5,
              ),
            ),
          ),
          child: Text(
            _formatDate(message.time), 
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: notification.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(notification.icon, color: notification.color, size: 24),
            ),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      notification.subscriptionName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7B1FA2),
                      ),
                    ),
                  ),
                  
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.text,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatTimeOnly(message.time), 
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInputField(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Написать сообщение...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                onSubmitted: (text) {
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: const Color(0xFF9C27B0),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: () {
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SubscriptionNotification {
  final String id;
  final String subscriptionName;
  final int amount;
  final int daysLeft;
  final DateTime date;
  bool isRead;
  final IconData icon;
  final Color color;

  SubscriptionNotification({
    required this.id,
    required this.subscriptionName,
    required this.amount,
    required this.daysLeft,
    required this.date,
    required this.isRead,
    required this.icon,
    required this.color,
  });
}

class Message {
  final String text;
  final DateTime time;
  final bool isSystem;

  Message({
    required this.text,
    required this.time,
    required this.isSystem,
  });
}