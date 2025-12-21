import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

enum SubscriptionPeriod { weekly, monthly, quarterly, yearly }

class Subscription extends Equatable {
  final String id;
  final String name;
  final double price;
  final SubscriptionPeriod period;
  final DateTime firstBillDate;
  final List<int> reminders; // Days before renewal, e.g., [7, 1]

  Subscription({
    String? id,
    required this.name,
    required this.price,
    required this.period,
    required this.firstBillDate,
    this.reminders = const [],
  }) : id = id ?? const Uuid().v4();

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
        return 'Weekly';
      case SubscriptionPeriod.monthly:
        return 'Monthly';
      case SubscriptionPeriod.quarterly:
        return 'Quarterly';
      case SubscriptionPeriod.yearly:
        return 'Yearly';
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
