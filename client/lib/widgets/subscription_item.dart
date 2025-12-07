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
  late bool _isTrial;
  late BillingCycle _billingCycle;
  late String _selectedCategory; // Добавляем переменную для категории

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.subscription.name);
    _amountController = TextEditingController(text: widget.subscription.currentAmount?.toString() ?? '');
    _notifyDaysController = TextEditingController(text: widget.subscription.notifyDays.toString());
    _nextPaymentDate = widget.subscription.nextPaymentDate;
    _isTrial = widget.subscription.isTrial;
    _billingCycle = widget.subscription.billingCycle;
    _selectedCategory = widget.subscription.category; // Инициализируем категорию
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
      _initializeControllers(); //  сброс всех изменений к исходным значениям
    });
  }

  void _saveChanges() {
    final newAmount = int.tryParse(_amountController.text);
    final newNotifyDays = int.tryParse(_notifyDaysController.text);
    
    final updatedPriceHistory = List<PriceHistory>.from(widget.subscription.priceHistory);
    
    // Обновляем историю цен если цена изменилась
    if (newAmount != null && newAmount != widget.subscription.currentAmount) {
      if (updatedPriceHistory.isNotEmpty) {
        final lastRecord = updatedPriceHistory.last;
        updatedPriceHistory[updatedPriceHistory.length - 1] = PriceHistory(
          startDate: lastRecord.startDate,
          endDate: DateTime.now(),
          amount: lastRecord.amount,
        );
      }
      
      updatedPriceHistory.add(PriceHistory(
        startDate: DateTime.now(),
        amount: newAmount,
      ));
    }

    final updatedSubscription = widget.subscription.copyWith(
      name: _nameController.text,
      nextPaymentDate: _nextPaymentDate,
      currentAmount: newAmount,
      isTrial: _isTrial,
      notifyDays: newNotifyDays ?? widget.subscription.notifyDays,
      priceHistory: updatedPriceHistory,
      billingCycle: _billingCycle,
      category: _selectedCategory, // Сохраняем выбранную категорию
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
                'Следующее списание: ${widget.subscription.getNextPaymentDateFormatted()}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        
        if (widget.subscription.currentAmount != null)
          Text(
            '${widget.subscription.currentAmount} руб.',
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
        children: [
          if (isEditing) _buildEditForm() else _buildDetails(),
        ],
      ),
    );
  }

  Widget _buildDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow('Дата подключения:', 
            DateFormat('dd.MM.yyyy').format(widget.subscription.connectedDate)),
        _buildDetailRow('Периодичность:', widget.subscription.getBillingCycleText()),
        _buildDetailRow('Категория:', widget.subscription.category),
        _buildDetailRow('Пробная подписка:', widget.subscription.isTrial ? 'Да' : 'Нет'),
        _buildDetailRow('Оповещать за:', '${widget.subscription.notifyDays} дней'),
        _buildDetailRow('До списания:', '${widget.subscription.daysUntilPayment} дней'),
        
        if (widget.subscription.priceHistory.length > 1) ...[
          SizedBox(height: 16),
          Text(
            'История изменений цены:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          ...widget.subscription.priceHistory.map((history) => 
            _buildPriceHistoryItem(history)
          ).toList(),
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
              style: TextStyle(
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
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '${history.amount} руб.',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 8),
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
          ] else ...[
            Text(
              ' - по настоящее время',
              style: TextStyle(
                fontSize: 14,
                color: Colors.green[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
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
        
        // Выбор категории при редактировании
        DropdownButtonFormField<String>(
          value: _selectedCategory,
          decoration: InputDecoration(
            labelText: 'Категория',
            border: OutlineInputBorder(),
          ),
          items: [
            'Музыка', 'Видео', 'Книги', 'Соцсети', 'Игры', 'Образование', 'Другое'
          ].map((category) {
            return DropdownMenuItem(
              value: category,
              child: Text(category),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategory = value ?? 'Другое';
            });
          },
        ),
        SizedBox(height: 12),
        
        // Поле даты
        TextFormField(
          controller: TextEditingController(
            text: DateFormat('dd.MM.yyyy').format(_nextPaymentDate),
          ),
          readOnly: true,
          onTap: _selectDate,
          decoration: InputDecoration(
            labelText: _isTrial ? 'Дата окончания пробного периода' : 'Дата следующего списания',
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.calendar_today),
          ),
        ),
        SizedBox(height: 12),
        
        // Поле стоимости с логикой для пробной подписки
        TextFormField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          enabled: !_isTrial,
          decoration: InputDecoration(
            labelText: _isTrial ? 'Стоимость (бесплатный пробный период)' : 'Стоимость',
            border: OutlineInputBorder(),
            suffixText: 'руб.',
          ),
        ),
        SizedBox(height: 12),
        
        // Периодичность (только для не пробных подписок)
        if (!_isTrial) ...[
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
        ],
        
        // Чекбокс пробной подписки
        Row(
          children: [
            Checkbox(
              value: _isTrial,
              onChanged: (value) {
                setState(() {
                  _isTrial = value ?? false;
                  if (_isTrial) {
                    _amountController.text = '0';
                  }
                });
              },
            ),
            Text('Пробная подписка'),
            SizedBox(width: 24),
            Expanded(
              child: TextFormField(
                controller: _notifyDaysController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Оповещать за (дней)',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
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
            OutlinedButton(
              onPressed: _cancelEditing,
              child: Text('Отмена'),
            ),
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