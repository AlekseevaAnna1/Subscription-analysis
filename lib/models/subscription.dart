import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Периодичность списаний
enum BillingCycle {
  monthly,
  yearly,
  quarterly,
}


// История цен для аналитики
class PriceHistory {
  final DateTime startDate;
  final DateTime? endDate;
  final int amount;

  PriceHistory({
    required this.startDate,
    this.endDate,
    required this.amount,
  });

// Преобразование между объектами Dart и JSON
  Map<String, dynamic> toJson() => {
        'startDate': startDate.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'amount': amount,
      };

  factory PriceHistory.fromJson(Map<String, dynamic> json) => PriceHistory(
        startDate: DateTime.parse(json['startDate']),
        endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
        amount: json['amount'],
      );
}

// Класс для самой подписки
class Subscription {
  final String id;
  final String name;
  final DateTime nextPaymentDate;
  final int? currentAmount; // Подписка мб пробная
  final IconData icon;
  final Color color;
  final String category;

  final DateTime connectedDate; // Дата подключения
  final DateTime? archivedDate; // Дата архивации
  final List<PriceHistory> priceHistory;
  final bool isTrial;
  final int notifyDays;
  final BillingCycle billingCycle;
  final int billingDay;

  Subscription({
    required this.id,
    required this.name,
    required this.nextPaymentDate,
    required this.currentAmount,
    required this.icon,
    required this.color,
    required this.category,
    required this.connectedDate,
    this.archivedDate,
    required this.priceHistory,
    this.isTrial = false,
    this.notifyDays = 3,
    required this.billingCycle,
    required this.billingDay,
  });

  Subscription copyWith({
    String? id,
    String? name,
    DateTime? nextPaymentDate,
    int? currentAmount,
    IconData? icon,
    Color? color,
    String? category,
    DateTime? connectedDate,
    DateTime? archivedDate,
    List<PriceHistory>? priceHistory,
    String? description,
    bool? isTrial,
    int? notifyDays,
    BillingCycle? billingCycle,
    int? billingDay,
  }) {
    return Subscription(
      id: id ?? this.id,
      name: name ?? this.name,
      nextPaymentDate: nextPaymentDate ?? this.nextPaymentDate,
      currentAmount: currentAmount ?? this.currentAmount,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      category: category ?? this.category,
      connectedDate: connectedDate ?? this.connectedDate,
      archivedDate: archivedDate ?? this.archivedDate,
      priceHistory: priceHistory ?? this.priceHistory,
      isTrial: isTrial ?? this.isTrial,
      notifyDays: notifyDays ?? this.notifyDays,
      billingCycle: billingCycle ?? this.billingCycle,
      billingDay: billingDay ?? this.billingDay,
    );
  }
    DateTime getNextPaymentDate() {
    switch (billingCycle) {
      case BillingCycle.monthly:
        return DateTime(
          nextPaymentDate.year,
          nextPaymentDate.month + 1,
          billingDay,
        );
      case BillingCycle.yearly:
        return DateTime(
          nextPaymentDate.year + 1,
          nextPaymentDate.month,
          billingDay,
        );
      case BillingCycle.quarterly:
        return DateTime(
          nextPaymentDate.year,
          nextPaymentDate.month + 3,
          billingDay,
        );
    }
  }

  String getNextPaymentDateFormatted() {
    return DateFormat('dd.MM.yyyy').format(nextPaymentDate);
  }

  String getBillingCycleText() {
    switch (billingCycle) {
      case BillingCycle.monthly:
        return 'Ежемесячно';
      case BillingCycle.yearly:
        return 'Ежегодно';
      case BillingCycle.quarterly:
        return 'Ежеквартально';
    }
  }
  bool get isOverdue => nextPaymentDate.isBefore(DateTime.now());

  // Автообновление даты
  Subscription getUpdatedSubscription() {
    if (isOverdue) {
      return copyWith(
        nextPaymentDate: getNextPaymentDate(),
      );
    }
    return this;
  }
  int get daysUntilPayment => nextPaymentDate.difference(DateTime.now()).inDays;
}