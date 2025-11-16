import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/subscription_item.dart';
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
  final TextEditingController _daysController = TextEditingController();
  
  bool _isTrial = false;
  DateTime? _selectedDate;
  BillingCycle _billingCycle = BillingCycle.monthly;
  int _billingDay = DateTime.now().day;

  // Функция для выбора даты
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

  // Функция для добавления подписки
  void _addSubscription() {
    if (_formKey.currentState!.validate()) {
      // Создаем новую подписку с уникальным ID
      final newSubscription = Subscription(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        nextPaymentDate: _selectedDate ?? DateTime.now(),
        currentAmount: int.tryParse(_amountController.text),
        icon: Icons.receipt, // Базовая иконка
        color: Colors.blue, // Базовый цвет
        category: 'Другое', // Базовая категория
        connectedDate: DateTime.now(),
        priceHistory: [
          PriceHistory(
            startDate: DateTime.now(),
            amount: int.tryParse(_amountController.text) ?? 0,
          ),
        ],
        isTrial: _isTrial,
        notifyDays: int.tryParse(_daysController.text) ?? 3,
        billingCycle: _billingCycle,
        billingDay: _billingDay,
      );

      // Закрываем модальное окно и возвращаем новую подписку
      Navigator.of(context).pop(newSubscription);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
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
                Center(
                  child: Text(
                    'Добавить подписку',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 24),
                
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Название подписки',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите название';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Стоимость',
                    border: OutlineInputBorder(),
                    suffixText: 'руб.',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите стоимость';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Пожалуйста, введите число';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                
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
                
                // День списания
                TextFormField(
                  controller: TextEditingController(text: _billingDay.toString()),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'День списания (1-31)',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    final day = int.tryParse(value);
                    if (day != null && day >= 1 && day <= 31) {
                      setState(() {
                        _billingDay = day;
                      });
                    }
                  },
                ),
                SizedBox(height: 16),
                
                Row(
                  children: [
                    Checkbox(
                      value: _isTrial,
                      onChanged: (bool? value) {
                        setState(() {
                          _isTrial = value ?? false;
                        });
                      },
                    ),
                    Text('Пробная подписка'),
                  ],
                ),
                SizedBox(height: 16),
                
                TextFormField(
                  controller: _daysController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Оповестить за (дней)',
                    border: OutlineInputBorder(),
                    suffixText: 'дней',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите количество дней';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Пожалуйста, введите число';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 32),
                
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