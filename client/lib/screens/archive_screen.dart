import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';
import '../providers/subscription_provider.dart';
import '../widgets/app_drawer.dart';
import '../models/subscription.dart';

class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({Key? key}) : super(key: key);

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Загружаем архивные подписки при инициализации
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<SubscriptionProvider>();
      if (!provider.hasLoaded) {
        provider.loadSubscriptions();
      }
    });
  }

  void _refreshData() async {
    final provider = context.read<SubscriptionProvider>();
    await provider.loadSubscriptions(forceRefresh: true);
    
    if (provider.error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Данные обновлены'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // TODO: Реализовать восстановление подписки в будущем
  // void _restoreSubscription(String subscriptionId) async {
  //   final provider = context.read<SubscriptionProvider>();
  //   final success = await provider.restoreFromArchive(subscriptionId);
  //   
  //   if (success) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Подписка восстановлена'),
  //         backgroundColor: Colors.green,
  //       ),
  //     );
  //   } else if (provider.error != null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(provider.error!),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   }
  // }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    key: _scaffoldKey,
    backgroundColor: const Color.fromARGB(248, 223, 218, 245),
    appBar: AppBar(
      title: const Text('Архив подписок'),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.black),
          onPressed: _refreshData,
          tooltip: 'Обновить архив',
        ),
      ],
    ),
    
    endDrawer: kIsWeb ? null : const AppDrawer(
      currentScreen: AppScreen.archive,
      isMobile: true,
    ),
    
    body: kIsWeb 
      ? Row(
          children: [
            const AppDrawer(
              currentScreen: AppScreen.archive,
              isMobile: false,
            ),
            Expanded(
              child: _buildBody(context),
            ),
          ],
        )
      : _buildBody(context),
  );
}

  Widget _buildBody(BuildContext context) {
    return Consumer<SubscriptionProvider>(
      builder: (context, provider, child) {
        // Если загрузка и нет данных
        if (provider.isLoading && !provider.hasLoaded) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Если ошибка
        if (provider.error != null && !provider.hasLoaded) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Ошибка загрузки архива',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    provider.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.loadSubscriptions(forceRefresh: true),
                  child: const Text('Повторить'),
                ),
              ],
            ),
          );
        }

        final archivedSubscriptions = provider.archivedSubscriptions;

        return Column(
          children: [
            // Статистика архива
            if (archivedSubscriptions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Всего в архиве: ${archivedSubscriptions.length}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Сумма: ${_calculateTotal(archivedSubscriptions)} ₽',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

            // Список архивных подписок
            Expanded(
              child: archivedSubscriptions.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: () async {
                        await provider.loadSubscriptions(forceRefresh: true);
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: archivedSubscriptions.length,
                        itemBuilder: (context, index) {
                          final subscription = archivedSubscriptions[index];
                          return _buildArchivedSubscriptionItem(subscription);
                        },
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.archive,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            'Архив пуст',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Здесь будут ваши завершенные подписки',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArchivedSubscriptionItem(Subscription subscription) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Верхняя строка с информацией
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: subscription.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    subscription.icon,
                    color: subscription.color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subscription.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getCategoryName(subscription.category),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // TODO: Добавить кнопку восстановления в будущем
                // IconButton(
                //   icon: const Icon(Icons.restore, color: Colors.blue),
                //   onPressed: () => _restoreSubscription(subscription.id),
                //   tooltip: 'Восстановить подписку',
                // ),
              ],
            ),
            
            // Детали подписки
            const SizedBox(height: 12),
            _buildDetailRow(
              'Дата архивации:',
              subscription.archivedDate != null
                  ? DateFormat('dd.MM.yyyy').format(subscription.archivedDate!)
                  : 'Не указана',
            ),
            _buildDetailRow(
              'Дата подключения:',
              DateFormat('dd.MM.yyyy').format(subscription.connectedDate),
            ),
            _buildDetailRow(
              'Сумма:',
              '${subscription.currentAmount} ₽ / ${subscription.billingCycleText}',
            ),
            
            // История цен если есть изменения
            if (subscription.priceHistory.length > 1) ...[
              const SizedBox(height: 8),
              Text(
                'История списаний:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 4),
              ...subscription.priceHistory.map((history) => 
                _buildPriceHistoryItem(history)
              ).toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceHistoryItem(PriceHistory history) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '${history.amount} ₽',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'с ${DateFormat('dd.MM.yyyy').format(history.startDate)}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          if (history.endDate != null) ...[
            Text(
              ' по ${DateFormat('dd.MM.yyyy').format(history.endDate!)}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getCategoryName(SubscriptionCategory category) {
    switch (category) {
      case SubscriptionCategory.music:
        return 'Музыка';
      case SubscriptionCategory.video:
        return 'Видео';
      case SubscriptionCategory.books:
        return 'Книги';
      case SubscriptionCategory.games:
        return 'Игры';
      case SubscriptionCategory.education:
        return 'Образование';
      case SubscriptionCategory.social:
        return 'Соцсети';
      case SubscriptionCategory.other:
        return 'Другое';
      default:
        return 'Неизвестно';
    }
  }

  String _calculateTotal(List<Subscription> subscriptions) {
    final total = subscriptions.fold(0.0, (sum, sub) => sum + sub.currentAmount);
    return total.toStringAsFixed(0);
  }
}