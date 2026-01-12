// import 'package:flutter/material.dart';

// class NotificationsScreen extends StatefulWidget {
//   const NotificationsScreen({Key? key}) : super(key: key);

//   @override
//   State<NotificationsScreen> createState() => _NotificationsScreenState();
// }

// class _NotificationsScreenState extends State<NotificationsScreen> {
//   final List<SubscriptionNotification> _notifications = [
//     SubscriptionNotification(
//       id: '1',
//       subscriptionName: 'КиноПоиск',
//       amount: 299,
//       daysLeft: 3,
//       date: DateTime.now().subtract(const Duration(hours: 2)),
//       isRead: false,
//       icon: Icons.movie,
//       color: Colors.red,
//     ),
//     SubscriptionNotification(
//       id: '2',
//       subscriptionName: 'Spotify',
//       amount: 169,
//       daysLeft: 1,
//       date: DateTime.now().subtract(const Duration(hours: 5)),
//       isRead: false,
//       icon: Icons.music_note,
//       color: Colors.green,
//     ),
//     SubscriptionNotification(
//       id: '3',
//       subscriptionName: 'Яндекс Музыка',
//       amount: 199,
//       daysLeft: 7,
//       date: DateTime.now().subtract(const Duration(days: 1)),
//       isRead: true,
//       icon: Icons.audiotrack,
//       color: Colors.orange,
//     ),
//     SubscriptionNotification(
//       id: '4',
//       subscriptionName: 'Okko',
//       amount: 399,
//       daysLeft: 2,
//       date: DateTime.now().subtract(const Duration(days: 2)),
//       isRead: true,
//       icon: Icons.play_circle_fill,
//       color: Colors.purple,
//     ),

//     SubscriptionNotification(
//       id: '5',
//       subscriptionName: 'Netflix',
//       amount: 499,
//       daysLeft: 0,
//       date: DateTime(2024, 11, 15, 14, 30),
//       isRead: true,
//       icon: Icons.play_circle_outline,
//       color: Colors.red,
//     ),
//     SubscriptionNotification(
//       id: '6',
//       subscriptionName: 'Apple Music',
//       amount: 199,
//       daysLeft: 0,
//       date: DateTime(2024, 11, 10, 9, 15),
//       isRead: true,
//       icon: Icons.music_note,
//       color: Colors.pink,
//     ),
//     SubscriptionNotification(
//       id: '7',
//       subscriptionName: 'YouTube Premium',
//       amount: 299,
//       daysLeft: 0,
//       date: DateTime(2024, 10, 25, 18, 45),
//       isRead: true,
//       icon: Icons.video_library,
//       color: Colors.red,
//     ),
//     SubscriptionNotification(
//       id: '8',
//       subscriptionName: 'Amazon Prime',
//       amount: 399,
//       daysLeft: 0,
//       date: DateTime(2024, 10, 15, 11, 20),
//       isRead: true,
//       icon: Icons.shopping_basket,
//       color: Colors.blue,
//     ),
//   ];

//   Map<String, List<SubscriptionNotification>> get _groupedNotifications {
//     final Map<String, List<SubscriptionNotification>> grouped = {};
    
//     for (final notification in _notifications) {
//       final monthKey = _getMonthKey(notification.date);
//       if (!grouped.containsKey(monthKey)) {
//         grouped[monthKey] = [];
//       }
//       grouped[monthKey]!.add(notification);
//     }
    
//     for (final key in grouped.keys) {
//       grouped[key]!.sort((a, b) => b.date.compareTo(a.date));
//     }
    
//     return grouped;
//   }

//   String _getMonthKey(DateTime date) {
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);
//     final yesterday = today.subtract(const Duration(days: 1));
//     final thisWeekStart = today.subtract(Duration(days: today.weekday - 1));
    
//     if (date.isAfter(today)) {
//       return 'Сегодня';
//     } else if (date.isAfter(yesterday)) {
//       return 'Вчера';
//     } else if (date.isAfter(thisWeekStart)) {
//       return 'На этой неделе';
//     } else {
//       final monthNames = [
//         'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь',
//         'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь'
//       ];
//       return '${monthNames[date.month - 1]} ${date.year}';
//     }
//   }

//   List<String> get _sortedMonthKeys {
//     final keys = _groupedNotifications.keys.toList();
//     keys.sort((a, b) {
//       final order = ['Сегодня', 'Вчера', 'На этой неделе'];
//       final aIndex = order.indexOf(a);
//       final bIndex = order.indexOf(b);
      
//       if (aIndex != -1 && bIndex != -1) return aIndex.compareTo(bIndex);
//       if (aIndex != -1) return -1;
//       if (bIndex != -1) return 1;
      
//       return _parseMonthYear(b).compareTo(_parseMonthYear(a));
//     });
    
//     return keys;
//   }

//   DateTime _parseMonthYear(String monthYear) {
//     final parts = monthYear.split(' ');
//     final monthNames = [
//       'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь',
//       'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь'
//     ];
//     final month = monthNames.indexOf(parts[0]) + 1;
//     final year = int.parse(parts[1]);
//     return DateTime(year, month);
//   }

//   void _markAsRead(String notificationId) {
//     setState(() {
//       final notification = _notifications.firstWhere(
//         (n) => n.id == notificationId,
//       );
//       notification.isRead = true;
//     });
//   }

//   void _openNotificationMessages(BuildContext context, SubscriptionNotification notification) {
//     _markAsRead(notification.id);
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => NotificationMessagesScreen(notification: notification),
//       ),
//     );
//   }

//   String _formatTime(DateTime date) {
//     final now = DateTime.now();
//     final difference = now.difference(date);

//     if (difference.inMinutes < 1) return 'только что';
//     if (difference.inMinutes < 60) return '${difference.inMinutes} мин назад';
//     if (difference.inHours < 24) return '${difference.inHours} ч назад';
//     if (difference.inDays < 7) return '${difference.inDays} д назад';
//     return '${date.day}.${date.month}.${date.year}';
//   }

//   String _formatDate(DateTime date) {
//     return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
//   }

//   String _formatTimeOnly(DateTime date) {
//     return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F5F5),
//       appBar: AppBar(
//         title: const Text(
//           'Уведомления',
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         backgroundColor: const Color(0xFF9C27B0),
//         foregroundColor: Colors.white,
//         elevation: 0,
//       ),
//       body: _notifications.isEmpty
//           ? const Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.notifications_none, size: 64, color: Colors.grey),
//                   SizedBox(height: 16),
//                   Text(
//                     'Нет уведомлений',
//                     style: TextStyle(fontSize: 18, color: Colors.grey),
//                   ),
//                 ],
//               ),
//             )
//           : ListView.builder(
//               itemCount: _sortedMonthKeys.length,
//               itemBuilder: (context, index) {
//                 final monthKey = _sortedMonthKeys[index];
//                 final notifications = _groupedNotifications[monthKey]!;
                
//                 return Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
//                       child: Text(
//                         monthKey,
//                         style: const TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.grey,
//                         ),
//                       ),
//                     ),
                    
//                     ...notifications.map((notification) => 
//                       _buildNotificationCard(notification, context)
//                     ),
//                   ],
//                 );
//               },
//             ),
//     );
//   }

//   Widget _buildNotificationCard(SubscriptionNotification notification, BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//       elevation: 2,
//       color: notification.isRead ? Colors.white : const Color(0xFFF0F8FF),
//       child: ListTile(
//         leading: Container(
//           width: 50,
//           height: 50,
//           decoration: BoxDecoration(
//             color: notification.color.withOpacity(0.2),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Icon(notification.icon, color: notification.color, size: 28),
//         ),
//         title: Text(
//           notification.subscriptionName,
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
//           ),
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 4),
//             Text(
//               notification.daysLeft > 0 
//                 ? 'Списание ${notification.amount} ₽ через ${notification.daysLeft} ${_getDayText(notification.daysLeft)}'
//                 : 'Списано ${notification.amount} ₽',
//               style: const TextStyle(fontSize: 14),
//             ),
//             const SizedBox(height: 2),
//             Text(
//               _formatTime(notification.date),
//               style: const TextStyle(fontSize: 12, color: Colors.grey),
//             ),
//           ],
//         ),
//         trailing: notification.isRead
//             ? null
//             : Container(
//                 width: 12,
//                 height: 12,
//                 decoration: const BoxDecoration(
//                   color: Colors.red,
//                   shape: BoxShape.circle,
//                 ),
//               ),
//         onTap: () => _openNotificationMessages(context, notification),
//       ),
//     );
//   }

//   String _getDayText(int days) {
//     if (days == 1) return 'день';
//     if (days >= 2 && days <= 4) return 'дня';
//     return 'дней';
//   }
// }

// class NotificationMessagesScreen extends StatelessWidget {
//   final SubscriptionNotification notification;

//   const NotificationMessagesScreen({
//     Key? key,
//     required this.notification,
//   }) : super(key: key);

//   String _formatDate(DateTime date) {
//     return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
//   }

//   String _formatTimeOnly(DateTime date) {
//     return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
//   }

//   String _getDayText(int days) {
//     if (days == 1) return 'день';
//     if (days >= 2 && days <= 4) return 'дня';
//     return 'дней';
//   }

//   @override
//   Widget build(BuildContext context) {
//     final combinedMessage = Message(
//       text: 'Напоминаем, что через ${notification.daysLeft} ${_getDayText(notification.daysLeft)} будет списано ${notification.amount} ₽ за подписку ${notification.subscriptionName}. Вы можете отменить подписку в любое время в настройках приложения.',
//       time: notification.date,
//       isSystem: true,
//     );

//     return Scaffold(
//       backgroundColor: const Color(0xFFE5E5E5),
//       appBar: AppBar(
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               notification.subscriptionName,
//               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//             Text(
//               notification.daysLeft > 0 
//                 ? 'Списание ${notification.amount} ₽ через ${notification.daysLeft} ${_getDayText(notification.daysLeft)}'
//                 : 'Списано ${notification.amount} ₽',
//               style: const TextStyle(fontSize: 12),
//             ),
//           ],
//         ),
//         backgroundColor: const Color(0xFF9C27B0),
//         foregroundColor: Colors.white,
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: _buildMessageBubble(combinedMessage, context),
//             ),
//           ),
//           _buildInputField(context),
//         ],
//       ),
//     );
//   }

//   Widget _buildMessageBubble(Message message, BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Container(
//           width: double.infinity,
//           padding: const EdgeInsets.symmetric(vertical: 8),
//           decoration: const BoxDecoration(
//             border: Border(
//               bottom: BorderSide(
//                 color: Colors.grey,
//                 width: 0.5,
//               ),
//             ),
//           ),
//           child: Text(
//             _formatDate(message.time), 
//             textAlign: TextAlign.center,
//             style: const TextStyle(
//               fontSize: 12,
//               color: Colors.grey,
//             ),
//           ),
//         ),
//         const SizedBox(height: 16),
        
//         Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               width: 40,
//               height: 40,
//               margin: const EdgeInsets.only(right: 12),
//               decoration: BoxDecoration(
//                 color: notification.color.withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Icon(notification.icon, color: notification.color, size: 24),
//             ),
            
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Container(
//                     margin: const EdgeInsets.only(bottom: 8),
//                     child: Text(
//                       notification.subscriptionName,
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF7B1FA2),
//                       ),
//                     ),
//                   ),
                  
//                   Container(
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(16),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.1),
//                           blurRadius: 4,
//                           offset: const Offset(0, 2),
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           message.text,
//                           style: const TextStyle(
//                             color: Colors.black87,
//                             fontSize: 14,
//                             height: 1.4,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           _formatTimeOnly(message.time), 
//                           style: const TextStyle(
//                             fontSize: 12,
//                             color: Colors.grey,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildInputField(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       color: Colors.white,
//       child: Row(
//         children: [
//           Expanded(
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFF5F5F5),
//                 borderRadius: BorderRadius.circular(24),
//               ),
//               child: TextField(
//                 decoration: const InputDecoration(
//                   hintText: 'Написать сообщение...',
//                   border: InputBorder.none,
//                   hintStyle: TextStyle(color: Colors.grey),
//                 ),
//                 onSubmitted: (text) {
//                 },
//               ),
//             ),
//           ),
//           const SizedBox(width: 8),
//           CircleAvatar(
//             backgroundColor: const Color(0xFF9C27B0),
//             child: IconButton(
//               icon: const Icon(Icons.send, color: Colors.white, size: 20),
//               onPressed: () {
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class SubscriptionNotification {
//   final String id;
//   final String subscriptionName;
//   final int amount;
//   final int daysLeft;
//   final DateTime date;
//   bool isRead;
//   final IconData icon;
//   final Color color;

//   SubscriptionNotification({
//     required this.id,
//     required this.subscriptionName,
//     required this.amount,
//     required this.daysLeft,
//     required this.date,
//     required this.isRead,
//     required this.icon,
//     required this.color,
//   });
// }

// class Message {
//   final String text;
//   final DateTime time;
//   final bool isSystem;

//   Message({
//     required this.text,
//     required this.time,
//     required this.isSystem,
//   });
// }
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../widgets/app_drawer.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  final List<Subscription> _subscriptions = [
    Subscription(
      id: '1',
      name: 'КиноПоиск',
      icon: Icons.movie,
      color: Colors.red,
      notifications: [
        SubscriptionNotification(
          id: '1_1',
          subscriptionId: '1',
          amount: 299,
          daysLeft: 3,
          date: DateTime.now().subtract(const Duration(hours: 2)),
          isRead: false,
          type: NotificationType.upcomingPayment,
        ),
        SubscriptionNotification(
          id: '1_2',
          subscriptionId: '1',
          amount: 299,
          daysLeft: 10,
          date: DateTime.now().subtract(const Duration(days: 7)),
          isRead: true,
          type: NotificationType.upcomingPayment,
        ),
        SubscriptionNotification(
          id: '1_3',
          subscriptionId: '1',
          amount: 299,
          daysLeft: 17,
          date: DateTime.now().subtract(const Duration(days: 14)),
          isRead: true,
          type: NotificationType.upcomingPayment,
        ),
      ],
    ),
    Subscription(
      id: '2',
      name: 'Spotify',
      icon: Icons.music_note,
      color: Colors.green,
      notifications: [
        SubscriptionNotification(
          id: '2_1',
          subscriptionId: '2',
          amount: 169,
          daysLeft: 1,
          date: DateTime.now().subtract(const Duration(hours: 5)),
          isRead: false,
          type: NotificationType.upcomingPayment,
        ),
        SubscriptionNotification(
          id: '2_2',
          subscriptionId: '2',
          amount: 169,
          daysLeft: 0,
          date: DateTime.now().subtract(const Duration(days: 30)),
          isRead: true,
          type: NotificationType.paymentCompleted,
        ),
      ],
    ),
    Subscription(
      id: '3',
      name: 'Яндекс Музыка',
      icon: Icons.audiotrack,
      color: Colors.orange,
      notifications: [
        SubscriptionNotification(
          id: '3_1',
          subscriptionId: '3',
          amount: 199,
          daysLeft: 7,
          date: DateTime.now().subtract(const Duration(days: 1)),
          isRead: true,
          type: NotificationType.upcomingPayment,
        ),
        SubscriptionNotification(
          id: '3_2',
          subscriptionId: '3',
          amount: 199,
          daysLeft: 0,
          date: DateTime.now().subtract(const Duration(days: 31)),
          isRead: true,
          type: NotificationType.paymentCompleted,
        ),
      ],
    ),
    Subscription(
      id: '4',
      name: 'Okko',
      icon: Icons.play_circle_fill,
      color: Colors.purple,
      notifications: [
        SubscriptionNotification(
          id: '4_1',
          subscriptionId: '4',
          amount: 399,
          daysLeft: 2,
          date: DateTime.now().subtract(const Duration(days: 2)),
          isRead: true,
          type: NotificationType.upcomingPayment,
        ),
      ],
    ),
    Subscription(
      id: '5',
      name: 'Netflix',
      icon: Icons.play_circle_outline,
      color: Colors.red,
      notifications: [
        SubscriptionNotification(
          id: '5_1',
          subscriptionId: '5',
          amount: 499,
          daysLeft: 0,
          date: DateTime(2024, 11, 15, 14, 30),
          isRead: true,
          type: NotificationType.paymentCompleted,
        ),
        SubscriptionNotification(
          id: '5_2',
          subscriptionId: '5',
          amount: 499,
          daysLeft: 7,
          date: DateTime(2024, 11, 8, 10, 15),
          isRead: true,
          type: NotificationType.upcomingPayment,
        ),
      ],
    ),
    Subscription(
      id: '6',
      name: 'Apple Music',
      icon: Icons.music_note,
      color: Colors.pink,
      notifications: [
        SubscriptionNotification(
          id: '6_1',
          subscriptionId: '6',
          amount: 199,
          daysLeft: 0,
          date: DateTime(2024, 11, 10, 9, 15),
          isRead: true,
          type: NotificationType.paymentCompleted,
        ),
      ],
    ),
  ];

  SubscriptionNotification _getLastNotification(Subscription subscription) {
    return subscription.notifications.first;
  }

  bool _hasUnreadNotifications(Subscription subscription) {
    return subscription.notifications.any((n) => !n.isRead);
  }

  int _getUnreadCount(Subscription subscription) {
    return subscription.notifications.where((n) => !n.isRead).length;
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

  String _getNotificationText(SubscriptionNotification notification) {
    switch (notification.type) {
      case NotificationType.upcomingPayment:
        return notification.daysLeft > 0 
          ? 'Списание ${notification.amount} ₽ через ${notification.daysLeft} ${_getDayText(notification.daysLeft)}'
          : 'Списание ${notification.amount} ₽ сегодня';
      case NotificationType.paymentCompleted:
        return 'Списано ${notification.amount} ₽';
      case NotificationType.subscriptionEnded:
        return 'Подписка завершена';
    }
  }

  String _getDayText(int days) {
    if (days == 1) return 'день';
    if (days >= 2 && days <= 4) return 'дня';
    return 'дней';
  }

  void _markAllAsRead(String subscriptionId) {
    setState(() {
      final subscription = _subscriptions.firstWhere(
        (s) => s.id == subscriptionId,
      );
      for (final notification in subscription.notifications) {
        notification.isRead = true;
      }
    });
  }

  void _openSubscriptionNotifications(BuildContext context, Subscription subscription) {
    _markAllAsRead(subscription.id);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubscriptionNotificationsScreen(subscription: subscription),
      ),
    );
  }

  List<Subscription> get _sortedSubscriptions {
    final sorted = List<Subscription>.from(_subscriptions);
    sorted.sort((a, b) {
      final aLastDate = _getLastNotification(a).date;
      final bLastDate = _getLastNotification(b).date;
      return bLastDate.compareTo(aLastDate);
    });
    return sorted;
  }

  // Функция для обновления (перезагрузки) данных
  void _refreshData() async {
    setState(() {
      // В будущем здесь будет запрос к бэкенду
      // Пока просто перерисовываем
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color.fromARGB(248, 223, 218, 245),
      appBar: AppBar(
        title: const Text('Мои уведомления'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _refreshData,
          ),
          if (!kIsWeb) IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              _scaffoldKey.currentState!.openEndDrawer();
            },
          ),
        ],
      ),
      
      endDrawer: kIsWeb ? null : const AppDrawer(
        currentScreen: AppScreen.notifications,
        isMobile: true,
      ),
      
      body: kIsWeb 
        ? Row(
            children: [
              const AppDrawer(
                currentScreen: AppScreen.notifications,
                isMobile: false,
              ),
              Expanded(
                child: _buildBody(),
              ),
            ],
          )
        : _buildBody(),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        // Счетчик уведомлений
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Непрочитанные: ${_subscriptions.where((s) => _hasUnreadNotifications(s)).length}',
                style: TextStyle(color: Colors.grey[600]),
              ),
              Text(
                'Всего: ${_subscriptions.length}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),

        // Список подписок с уведомлениями
        Expanded(
          child: _subscriptions.isEmpty
            ? _buildEmptyState()
            : RefreshIndicator(
                onRefresh: () async {
                  _refreshData();
                  return Future.delayed(const Duration(milliseconds: 500));
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _sortedSubscriptions.length,
                  itemBuilder: (context, index) {
                    final subscription = _sortedSubscriptions[index];
                    final lastNotification = _getLastNotification(subscription);
                    final hasUnread = _hasUnreadNotifications(subscription);
                    final unreadCount = _getUnreadCount(subscription);

                    return _buildSubscriptionCard(
                      subscription,
                      lastNotification,
                      hasUnread,
                      unreadCount,
                      context,
                    );
                  },
                ),
              ),
        ),
      ],
    );
  }

  Widget _buildSubscriptionCard(
    Subscription subscription,
    SubscriptionNotification lastNotification,
    bool hasUnread,
    int unreadCount,
    BuildContext context,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: subscription.color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(subscription.icon, color: subscription.color, size: 28),
        ),
        title: Text(
          subscription.name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              _getNotificationText(lastNotification),
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 2),
            Text(
              _formatTime(lastNotification.date),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: hasUnread
            ? Container(
                width: unreadCount > 1 ? 24 : 12,
                height: unreadCount > 1 ? 24 : 12,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: unreadCount > 1
                    ? Center(
                        child: Text(
                          unreadCount > 9 ? '9+' : unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : null,
              )
            : null,
        onTap: () => _openSubscriptionNotifications(context, subscription),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            'Нет уведомлений',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Здесь будут отображаться уведомления о подписках',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class SubscriptionNotificationsScreen extends StatelessWidget {
  final Subscription subscription;

  const SubscriptionNotificationsScreen({
    Key? key,
    required this.subscription,
  }) : super(key: key);

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getNotificationText(SubscriptionNotification notification) {
    switch (notification.type) {
      case NotificationType.upcomingPayment:
        return notification.daysLeft > 0 
          ? 'Списание ${notification.amount} ₽ через ${notification.daysLeft} ${_getDayText(notification.daysLeft)}'
          : 'Списание ${notification.amount} ₽ сегодня';
      case NotificationType.paymentCompleted:
        return 'Списано ${notification.amount} ₽';
      case NotificationType.subscriptionEnded:
        return 'Подписка завершена';
    }
  }

  String _getDayText(int days) {
    if (days == 1) return 'день';
    if (days >= 2 && days <= 4) return 'дня';
    return 'дней';
  }

  String _getMessageDateGroup(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date.isAfter(today)) {
      return 'Сегодня';
    } else if (date.isAfter(yesterday)) {
      return 'Вчера';
    } else {
      return _formatDate(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Сортируем уведомления по дате (новые сверху)
    final sortedNotifications = List<SubscriptionNotification>.from(
      subscription.notifications,
    )..sort((a, b) => b.date.compareTo(a.date));

    // Группируем по дате
    final Map<String, List<SubscriptionNotification>> groupedNotifications = {};
    for (final notification in sortedNotifications) {
      final dateKey = _getMessageDateGroup(notification.date);
      if (!groupedNotifications.containsKey(dateKey)) {
        groupedNotifications[dateKey] = [];
      }
      groupedNotifications[dateKey]!.add(notification);
    }

    final dateKeys = groupedNotifications.keys.toList();

    return Scaffold(
      backgroundColor: const Color.fromARGB(248, 223, 218, 245),
      appBar: AppBar(
        title: Text(
          subscription.name,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        reverse: true, // Новые сообщения снизу
        itemCount: dateKeys.length,
        itemBuilder: (context, index) {
          final dateKey = dateKeys[index];
          final notifications = groupedNotifications[dateKey]!;
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок с датой
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  dateKey,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              
              // Сообщения за эту дату
              ...notifications.map((notification) => 
                _buildMessageBubble(notification, context)
              ),
              
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMessageBubble(SubscriptionNotification notification, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Аватар подписки
          Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: subscription.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(subscription.icon, color: subscription.color, size: 24),
          ),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Имя подписки
                Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    subscription.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                
                // Пузырек сообщения
                Container(
                  padding: const EdgeInsets.all(12),
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
                        _getNotificationText(notification),
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          height: 1.4,
                          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTime(notification.date),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
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
    );
  }
}

class Subscription {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final List<SubscriptionNotification> notifications;

  Subscription({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.notifications,
  });
}

class SubscriptionNotification {
  final String id;
  final String subscriptionId;
  final int amount;
  final int daysLeft;
  final DateTime date;
  bool isRead;
  final NotificationType type;

  SubscriptionNotification({
    required this.id,
    required this.subscriptionId,
    required this.amount,
    required this.daysLeft,
    required this.date,
    required this.isRead,
    required this.type,
  });
}

enum NotificationType {
  upcomingPayment,
  paymentCompleted,
  subscriptionEnded,
}