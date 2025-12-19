// widgets/add_subscription_modal.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/subscription.dart';

// Модальное окно для добавления новой подписки
class AddSubscriptionModal extends StatefulWidget {
  @override
  _AddSubscriptionModalState createState() => _AddSubscriptionModalState();
}

class _AddSubscriptionModalState extends State<AddSubscriptionModal> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _daysController = TextEditingController(text: '3');
  
  DateTime? _selectedDate;
  BillingCycle _billingCycle = BillingCycle.monthly;
  String _selectedCategory = 'Другое';
  
  // Добавляем чекбоксы для уведомлений и автопродления
  bool _notificationsEnabled = true;
  bool _autoRenewal = false;

  // Список категорий - обновлён в соответствии с enum
  final List<String> _categories = ['Музыка', 'Видео', 'Книги', 'Соцсети', 'Игры', 'Образование', 'Другое'];

  // Список периодичностей
  final List<String> _billingCycles = ['Ежемесячно', 'Ежеквартально', 'Ежегодно'];

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd.MM.yyyy').format(picked);
      });
    }
  }

  void _addSubscription() {
    if (_formKey.currentState!.validate()) {
      // Преобразуем сумму в копейки
      final amount = int.tryParse(_amountController.text);
      
      // Преобразуем строку категории в enum
      final category = _convertStringToCategory(_selectedCategory);
      
      // Преобразуем строку периодичности в enum
      final billingCycle = _convertStringToBillingCycle(_billingCycles.firstWhere(
        (cycle) => _getBillingCycleText(cycle) == _getBillingCycleTextForEnum(_billingCycle)
      ));

      final newSubscription = Subscription(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Временный ID
        name: _nameController.text,
        currentAmount: amount ?? 0,
        nextPaymentDate: _selectedDate ?? DateTime.now(),
        connectedDate: DateTime.now(),
        archivedDate: null,
        category: category,
        notifyDays: int.tryParse(_daysController.text) ?? 3,
        billingCycle: billingCycle,
        notificationsEnabled: _notificationsEnabled,
        autoRenewal: _autoRenewal,
        icon: _getIconForCategory(_selectedCategory),
        color: _getColorForCategory(_selectedCategory),
        priceHistory: [], // Пока пустая история
      );

      Navigator.of(context).pop(newSubscription);
    }
  }

  // Функция для получения иконки по категории
  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'Музыка':
        return Icons.music_note;
      case 'Видео':
        return Icons.movie;
      case 'Книги':
        return Icons.menu_book;
      case 'Соцсети':
        return Icons.chat;
      case 'Игры':
        return Icons.sports_esports;
      case 'Образование':
        return Icons.school;
      default:
        return Icons.receipt;
    }
  }

  // Функция для получения цвета по категории
  Color _getColorForCategory(String category) {
    switch (category) {
      case 'Музыка':
        return Colors.green;
      case 'Видео':
        return Colors.orange;
      case 'Книги':
        return Colors.blue;
      case 'Соцсети':
        return Colors.blue[400]!;
      case 'Игры':
        return Colors.purple;
      case 'Образование':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  // Преобразование строки категории в enum
  SubscriptionCategory _convertStringToCategory(String category) {
    switch (category) {
      case 'Музыка': return SubscriptionCategory.music;
      case 'Видео': return SubscriptionCategory.video;
      case 'Книги': return SubscriptionCategory.books;
      case 'Соцсети': return SubscriptionCategory.social;
      case 'Игры': return SubscriptionCategory.games;
      case 'Образование': return SubscriptionCategory.education;
      case 'Другое': return SubscriptionCategory.other;
      default: return SubscriptionCategory.other;
    }
  }

  // Преобразование строки периодичности в enum
  BillingCycle _convertStringToBillingCycle(String cycle) {
    switch (cycle) {
      case 'Ежемесячно': return BillingCycle.monthly;
      case 'Ежеквартально': return BillingCycle.quarterly;
      case 'Ежегодно': return BillingCycle.yearly;
      default: return BillingCycle.monthly;
    }
  }

  // Получение текста периодичности для enum
  String _getBillingCycleTextForEnum(BillingCycle cycle) {
    switch (cycle) {
      case BillingCycle.monthly: return 'Ежемесячно';
      case BillingCycle.quarterly: return 'Ежеквартально';
      case BillingCycle.yearly: return 'Ежегодно';
    }
  }

  // Получение текста периодичности для строки
  String _getBillingCycleText(String cycle) {
    return cycle; // Уже на русском
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85, // Увеличиваем высоту для новых полей
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Добавить подписку',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                
                // Название подписки
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Название подписки',
                    border: OutlineInputBorder(),
                    hintText: 'Например: Netflix, Spotify',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите название';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                
                // Выбор категории
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Категория',
                    border: OutlineInputBorder(),
                  ),
                  items: _categories.map((category) {
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
                SizedBox(height: 16),
                
                // Поле стоимости
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Стоимость',
                    border: OutlineInputBorder(),
                    suffixText: 'руб.',
                    hintText: '299',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите стоимость';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Пожалуйста, введите число';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                
                // Поле даты следующего списания
                TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  onTap: _selectDate,
                  decoration: InputDecoration(
                    labelText: 'Дата следующего списания',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, выберите дату';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                
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
                SizedBox(height: 16),
                
                // Поле дней для оповещения
                TextFormField(
                  controller: _daysController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Оповестить за (дней)',
                    border: OutlineInputBorder(),
                    suffixText: 'дней',
                    hintText: '3',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите количество дней';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Пожалуйста, введите число';
                    }
                    final days = int.parse(value);
                    if (days < 1 || days > 30) {
                      return 'Введите число от 1 до 30';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                
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
                SizedBox(height: 32),
                
                // Кнопка добавления
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _addSubscription,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Добавить подписку',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    _daysController.dispose();
    super.dispose();
  }
}