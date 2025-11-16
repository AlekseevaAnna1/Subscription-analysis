import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/add_subscription_modal.dart';
import '../widgets/subscription_item.dart';
import '../models/subscription.dart';

import 'profile_screen.dart';
import 'analytics_screen.dart';
import 'notifications_screen.dart';

class SubscriptionsScreen extends StatefulWidget {
  SubscriptionsScreen({Key? key}) : super(key: key);

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState(); // создает объект State для управления StatefulWidget
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  List<Subscription> subscriptions = [];// Сначала список подписок пустой
  final List<String> categories = ['Все', 'Музыка', 'Видео', 'Книги', 'Соцсети', 'Другое'];
  String selectedCategory = 'Все';

  @override
  void initState() {
    super.initState();
    _autoUpdateSubscriptionDates();
  }
  // Функция для автообновления дат подписок
  void _autoUpdateSubscriptionDates() {
    setState(() {
      subscriptions = subscriptions.map((subscription) {
        return subscription.getUpdatedSubscription();
      }).toList();
    });
  }

  // Функция для показа модального окна добавления подписки
  void _showAddSubscriptionModal() async {

    final newSubscription = await showModalBottomSheet<Subscription>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddSubscriptionModal(),
    );

    if (newSubscription != null) {
      setState(() {
        subscriptions.add(newSubscription);
      });
    }
  }

  // Функция обновления подписки
  void _updateSubscription(Subscription updatedSubscription) {
    setState(() {
      final index = subscriptions.indexWhere((sub) => sub.id == updatedSubscription.id);
      if (index != -1) {
        subscriptions[index] = updatedSubscription;
      }
    });
  }

  // Функция архивации подписки
  void _archiveSubscription(String subscriptionId) {
    setState(() {
      final index = subscriptions.indexWhere((sub) => sub.id == subscriptionId);
      if (index != -1) {
        subscriptions[index] = subscriptions[index].copyWith(
          archivedDate: DateTime.now(),
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Подписка перемещена в архив'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Фильтруем активные подписки
    final activeSubscriptions = subscriptions.where((sub) => sub.archivedDate == null).toList();
    
    // Фильтруем по выбранной категории
    final filteredSubscriptions = selectedCategory == 'Все'
        ? activeSubscriptions
        : activeSubscriptions.where((sub) => sub.category == selectedCategory).toList();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Color.fromARGB(248, 223, 218, 245),
      appBar: AppBar(
        title: Text('Мои подписки'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              // Открываем правую боковую панель
              _scaffoldKey.currentState!.openEndDrawer();
            },
          ),
        ],
      ),
      
      // Боковая выдвижная панель
      endDrawer: _buildDrawer(context),
      
      // Кнопка добавления новой подписки
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSubscriptionModal,
        backgroundColor: Colors.blue,
        child: Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      body: Column(
        children: [
          // Горизонтальная полоска с категориями
          Container(
            height: 60,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (context, index) => SizedBox(width: 12),
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = category == selectedCategory;
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = category;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Список подписок или сообщение об отсутствии
          Expanded(
            child: filteredSubscriptions.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: filteredSubscriptions.length,
                    itemBuilder: (context, index) {
                      final subscription = filteredSubscriptions[index];
                      return SubscriptionItem(
                        subscription: subscription,
                        onUpdate: _updateSubscription,
                        onArchive: _archiveSubscription,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
    // Виджет для пустого состояния
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.subscriptions,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 20),
          Text(
            'Нет активных подписок',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Нажмите на "+" чтобы добавить первую подписку',
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
  // Функция для построения боковой панели
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Заголовок боковой панели
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24),
              color: Colors.blue,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 25,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Пользователь',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'user@example.com',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            
            // Пункты меню
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                    icon: Icons.subscriptions,
                    title: 'Подписки',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.person,
                    title: 'Личный кабинет',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(
                            builder: (context) => ProfileScreen(),
                          ));
                        },
                  ),                   
                  _buildDrawerItem(
                    icon: Icons.analytics,
                    title: 'Аналитика',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(
                            builder: (context) => AnalyticsScreen(),
                          ));
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.notifications,
                    title: 'Уведомления',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(
                            builder: (context) => NotificationsScreen(),
                          ));
                    },
                  ),
                  
                  
                  // Разделитель
                  Divider(height: 24, thickness: 1),
                  
                  _buildDrawerItem(
                    icon: Icons.exit_to_app,
                    title: 'Выйти',
                    onTap: () {
                      Navigator.pop(context);
                      _showLogoutDialog(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Вспомогательная функция для создания пунктов меню
  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(
        title,
        style: TextStyle(fontSize: 16),
      ),
      onTap: onTap,
    );
  }

  // Функция для показа сообщения "Скоро будет"
  void _showComingSoonMessage(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - скоро будет доступно!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Функция для показа диалога выхода
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Выход'),
          content: Text('Вы уверены, что хотите выйти?'),
          actions: [
            TextButton(
              child: Text('Отмена'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Выйти', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _showComingSoonMessage(context, 'Выход');
              },
            ),
          ],
        );
      },
    );
  }
}

