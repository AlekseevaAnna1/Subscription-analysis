import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/subscription.dart';

class SubscriptionItem extends StatefulWidget {
  final Subscription subscription;
  final Function(Subscription) onUpdate;
  final Function(String) onArchive;

  const SubscriptionItem({
    Key? key,
    required this.subscription,
    required this.onUpdate,
    required this.onArchive,
  }) : super(key: key);

  @override
  _SubscriptionItemState createState() => _SubscriptionItemState();
}

class _SubscriptionItemState extends State<SubscriptionItem> {
  bool isExpanded = false;
  bool isEditing = false;

  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late TextEditingController _notifyDaysController;
  late DateTime _nextPaymentDate;
  late BillingCycle _billingCycle;
  late SubscriptionCategory _selectedCategory;
  late bool _notificationsEnabled;
  late bool _autoRenewal;

  // Список категорий для UI
  final List<String> _categoryList = [
    'Музыка',
    'Видео',
    'Книги',
    'Соцсети',
    'Игры',
    'Образование',
    'Другое',
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.subscription.name);
    _amountController = TextEditingController(
      text: (widget.subscription.currentAmount / 100).toStringAsFixed(2),
    );
    _notifyDaysController = TextEditingController(
      text: widget.subscription.notifyDays.toString(),
    );
    _nextPaymentDate = widget.subscription.nextPaymentDate;
    _billingCycle = widget.subscription.billingCycle;
    _selectedCategory = widget.subscription.category;
    _notificationsEnabled = widget.subscription.notificationsEnabled;
    _autoRenewal = widget.subscription.autoRenewal;
  }

  void _toggleExpanded() {
    setState(() {
      isExpanded = !isExpanded;
      if (!isExpanded) {
        isEditing = false; // При сворачивании выходим из режима редактирования
      }
    });
  }

  void _startEditing() {
    setState(() {
      isEditing = true;
    });
  }

  void _cancelEditing() {
    setState(() {
      isEditing = false;
      _initializeControllers(); // Сброс всех изменений к исходным значениям
    });
  }

  void _saveChanges() {
    final newAmount = (double.tryParse(_amountController.text) ?? 0) * 100;
    final newNotifyDays = int.tryParse(_notifyDaysController.text);

    final updatedSubscription = widget.subscription.copyWith(
      name: _nameController.text,
      nextPaymentDate: _nextPaymentDate,
      currentAmount: newAmount.round(),
      notifyDays: newNotifyDays ?? widget.subscription.notifyDays,
      billingCycle: _billingCycle,
      category: _selectedCategory,
      notificationsEnabled: _notificationsEnabled,
      autoRenewal: _autoRenewal,
    );

    widget.onUpdate(updatedSubscription);

    setState(() {
      isEditing = false;
    });
  }

  void _archiveSubscription() {
    widget.onArchive(widget.subscription.id);
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _nextPaymentDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _nextPaymentDate) {
      setState(() {
        _nextPaymentDate = picked;
      });
    }
  }

  // Преобразование enum категории в строку для UI
  String _categoryToString(SubscriptionCategory category) {
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
    }
  }

  // Преобразование строки в enum категории
  SubscriptionCategory _stringToCategory(String category) {
    switch (category) {
      case 'Музыка':
        return SubscriptionCategory.music;
      case 'Видео':
        return SubscriptionCategory.video;
      case 'Книги':
        return SubscriptionCategory.books;
      case 'Игры':
        return SubscriptionCategory.games;
      case 'Образование':
        return SubscriptionCategory.education;
      case 'Соцсети':
        return SubscriptionCategory.social;
      case 'Другое':
        return SubscriptionCategory.other;
      default:
        return SubscriptionCategory.other;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHeaderRow(),
            if (isExpanded) _buildExpandedContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: widget.subscription.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            widget.subscription.icon,
            color: widget.subscription.color,
            size: 24,
          ),
        ),
        SizedBox(width: 12),
        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.subscription.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Следующее списание: ${widget.subscription.formattedNextPayment}',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),

        Text(
          widget.subscription.formattedAmount,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),

        IconButton(
          icon: Icon(
            isExpanded ? Icons.expand_less : Icons.expand_more,
            color: Colors.grey[600],
          ),
          onPressed: _toggleExpanded,
        ),
      ],
    );
  }

  Widget _buildExpandedContent() {
    return Padding(
      padding: EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [if (isEditing) _buildEditForm() else _buildDetails()],
      ),
    );
  }

  Widget _buildDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow(
          'Дата подключения:',
          DateFormat('dd.MM.yyyy').format(widget.subscription.connectedDate),
        ),
        _buildDetailRow('Периодичность:', widget.subscription.billingCycleText),
        _buildDetailRow(
          'Категория:',
          _categoryToString(widget.subscription.category),
        ),
        _buildDetailRow(
          'Уведомления:',
          widget.subscription.notificationsEnabled ? 'Включены' : 'Выключены',
        ),
        _buildDetailRow(
          'Автопродление:',
          widget.subscription.autoRenewal ? 'Включено' : 'Выключено',
        ),
        _buildDetailRow(
          'Оповещать за:',
          '${widget.subscription.notifyDays} дней',
        ),
        _buildDetailRow(
          'До списания:',
          '${widget.subscription.daysUntilPayment} дней',
        ),
        _buildDetailRow(
          'Статус:',
          widget.subscription.isOverdue ? 'Просрочена' : 'Активна',
        ),

        if (widget.subscription.priceHistory.isNotEmpty) ...[
          SizedBox(height: 16),
          Text(
            'История платежей:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          ...widget.subscription.priceHistory
              .map((history) => _buildPriceHistoryItem(history))
              .toList(),
        ],

        SizedBox(height: 16),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _startEditing,
              icon: Icon(Icons.edit, size: 18),
              label: Text('Редактировать'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
            SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: _archiveSubscription,
              icon: Icon(Icons.archive, size: 18),
              label: Text('В архив'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceHistoryItem(PriceHistory history) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '${(history.amount / 100).toStringAsFixed(2)} руб.',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          SizedBox(width: 8),
          Text(
            '${DateFormat('dd.MM.yyyy').format(history.startDate)} - ${history.endDate != null ? DateFormat('dd.MM.yyyy').format(history.endDate!) : 'настоящее время'}',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Название подписки',
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 12),

        // Выбор категории
        DropdownButtonFormField<String>(
          value: _categoryToString(_selectedCategory),
          decoration: InputDecoration(
            labelText: 'Категория',
            border: OutlineInputBorder(),
          ),
          items: _categoryList.map((category) {
            return DropdownMenuItem(value: category, child: Text(category));
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategory = _stringToCategory(value ?? 'Другое');
            });
          },
        ),
        SizedBox(height: 12),

        // Поле даты следующего списания
        TextFormField(
          controller: TextEditingController(
            text: DateFormat('dd.MM.yyyy').format(_nextPaymentDate),
          ),
          readOnly: true,
          onTap: _selectDate,
          decoration: InputDecoration(
            labelText: 'Дата следующего списания',
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.calendar_today),
          ),
        ),
        SizedBox(height: 12),

        // Поле стоимости
        TextFormField(
          controller: _amountController,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Стоимость',
            border: OutlineInputBorder(),
            suffixText: 'руб.',
          ),
        ),
        SizedBox(height: 12),

        // Периодичность
        DropdownButtonFormField<BillingCycle>(
          value: _billingCycle,
          decoration: InputDecoration(
            labelText: 'Периодичность',
            border: OutlineInputBorder(),
          ),
          items: [
            DropdownMenuItem(
              value: BillingCycle.monthly,
              child: Text('Ежемесячно'),
            ),
            DropdownMenuItem(
              value: BillingCycle.quarterly,
              child: Text('Ежеквартально'),
            ),
            DropdownMenuItem(
              value: BillingCycle.yearly,
              child: Text('Ежегодно'),
            ),
          ],
          onChanged: (value) {
            setState(() {
              _billingCycle = value ?? BillingCycle.monthly;
            });
          },
        ),
        SizedBox(height: 12),

        // Поле дней для оповещения
        TextFormField(
          controller: _notifyDaysController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Оповещать за (дней)',
            border: OutlineInputBorder(),
            hintText: '3',
          ),
        ),
        SizedBox(height: 12),

        // Чекбокс для уведомлений
        Row(
          children: [
            Checkbox(
              value: _notificationsEnabled,
              onChanged: (bool? value) {
                setState(() {
                  _notificationsEnabled = value ?? true;
                });
              },
            ),
            Text('Включить уведомления'),
          ],
        ),

        // Чекбокс для автопродления
        Row(
          children: [
            Checkbox(
              value: _autoRenewal,
              onChanged: (bool? value) {
                setState(() {
                  _autoRenewal = value ?? false;
                });
              },
            ),
            Text('Автопродление'),
          ],
        ),
        SizedBox(height: 16),

        Row(
          children: [
            ElevatedButton(
              onPressed: _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: Text('Сохранить'),
            ),
            SizedBox(width: 12),
            OutlinedButton(onPressed: _cancelEditing, child: Text('Отмена')),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _notifyDaysController.dispose();
    super.dispose();
  }
}
