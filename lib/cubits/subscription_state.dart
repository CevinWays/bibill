import 'package:equatable/equatable.dart';
import '../models/subscription.dart';

enum SubscriptionStatus { initial, loading, success, failure }

class SubscriptionState extends Equatable {
  final SubscriptionStatus status;
  final List<Subscription> subscriptions;

  const SubscriptionState({
    this.status = SubscriptionStatus.initial,
    this.subscriptions = const [],
  });

  SubscriptionState copyWith({
    SubscriptionStatus? status,
    List<Subscription>? subscriptions,
  }) {
    return SubscriptionState(
      status: status ?? this.status,
      subscriptions: subscriptions ?? this.subscriptions,
    );
  }

  @override
  List<Object> get props => [status, subscriptions];
}
