import 'package:equatable/equatable.dart';

enum SubscriptionPeriod { weekly, monthly, quarterly, yearly }

class Subscription extends Equatable {
  final String id;
  final String name;
  final double price;
  final SubscriptionPeriod period;
  final DateTime firstBillDate;
  final List<int> reminders;

  const Subscription({
    String? id,
    required this.name,
    required this.price,
    required this.period,
    required this.firstBillDate,
    this.reminders = const [],
  }) : id =
           id ??
           ''; // Empty string temporarily, will be UUID if not provided by caller or DB

  Subscription copyWith({
    String? id,
    String? name,
    double? price,
    SubscriptionPeriod? period,
    DateTime? firstBillDate,
    List<int>? reminders,
  }) {
    return Subscription(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      period: period ?? this.period,
      firstBillDate: firstBillDate ?? this.firstBillDate,
      reminders: reminders ?? this.reminders,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'period': period.index,
      'first_bill_date': firstBillDate.toIso8601String(),
      'reminders': reminders.join(','),
    };
  }

  factory Subscription.fromMap(Map<String, dynamic> map) {
    String remindersStr = map['reminders'] as String? ?? '';
    List<int> loadedReminders = [];
    if (remindersStr.isNotEmpty) {
      loadedReminders = remindersStr
          .split(',')
          .map((e) => int.parse(e))
          .toList();
    }

    return Subscription(
      id: map['id'],
      name: map['name'],
      price: (map['price'] as num).toDouble(),
      period: SubscriptionPeriod.values[map['period'] as int],
      firstBillDate: DateTime.parse(map['first_bill_date']),
      reminders: loadedReminders,
    );
  }

  /// Calculates the next renewal date based on [firstBillDate] and [period].
  /// It finds the next occurrence on or after [from].
  DateTime nextRenewal({DateTime? from}) {
    final now = from ?? DateTime.now();
    // Normalize now to start of day to avoid time issues
    final today = DateTime(now.year, now.month, now.day);

    // Normalize first bill to start of day
    DateTime current = DateTime(
      firstBillDate.year,
      firstBillDate.month,
      firstBillDate.day,
    );

    if (current.isAfter(today) || current.isAtSameMomentAs(today)) {
      return current;
    }

    while (current.isBefore(today)) {
      switch (period) {
        case SubscriptionPeriod.weekly:
          current = current.add(const Duration(days: 7));
          break;
        case SubscriptionPeriod.monthly:
          // Handle end of month logic (simple version: just add month)
          // A robust version would handle Jan 31 -> Feb 28 -> Mar 28
          // For MVP, we'll try to keep the day if possible.
          int nextMonth = current.month + 1;
          int nextYear = current.year;
          if (nextMonth > 12) {
            nextMonth = 1;
            nextYear++;
          }
          // Check days in next month
          int daysInNextMonth = DateTime(nextYear, nextMonth + 1, 0).day;
          int targetDay = firstBillDate.day;
          if (targetDay > daysInNextMonth) {
            targetDay = daysInNextMonth;
          }
          current = DateTime(nextYear, nextMonth, targetDay);
          break;
        case SubscriptionPeriod.quarterly:
          // Add 3 months
          for (int i = 0; i < 3; i++) {
            int nextMonth = current.month + 1;
            int nextYear = current.year;
            if (nextMonth > 12) {
              nextMonth = 1;
              nextYear++;
            }
            int daysInNextMonth = DateTime(nextYear, nextMonth + 1, 0).day;
            int targetDay = firstBillDate.day;
            if (targetDay > daysInNextMonth) targetDay = daysInNextMonth;
            current = DateTime(nextYear, nextMonth, targetDay);
          }
          break;
        case SubscriptionPeriod.yearly:
          current = DateTime(current.year + 1, current.month, current.day);
          break;
      }
    }
    return current;
  }

  String get periodString {
    switch (period) {
      case SubscriptionPeriod.weekly:
        return 'Mingguan';
      case SubscriptionPeriod.monthly:
        return 'Bulanan';
      case SubscriptionPeriod.quarterly:
        return 'Kuartal';
      case SubscriptionPeriod.yearly:
        return 'Tahunan';
    }
  }

  @override
  List<Object?> get props => [
    id,
    name,
    price,
    period,
    firstBillDate,
    reminders,
  ];
}
