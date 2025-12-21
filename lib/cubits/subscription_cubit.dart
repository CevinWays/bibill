import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/subscription.dart';
import 'subscription_state.dart';

class SubscriptionCubit extends Cubit<SubscriptionState> {
  SubscriptionCubit() : super(const SubscriptionState()) {
    // Optionally load initial data
    // loadSubscriptions();
  }

  void addSubscription(Subscription subscription) {
    emit(state.copyWith(status: SubscriptionStatus.loading));
    try {
      final updatedList = List<Subscription>.from(state.subscriptions)
        ..add(subscription);
      _sortSubscriptions(updatedList);
      emit(
        state.copyWith(
          status: SubscriptionStatus.success,
          subscriptions: updatedList,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: SubscriptionStatus.failure));
    }
  }

  void deleteSubscription(String id) {
    emit(state.copyWith(status: SubscriptionStatus.loading));
    try {
      final updatedList = List<Subscription>.from(state.subscriptions)
        ..removeWhere((s) => s.id == id);
      emit(
        state.copyWith(
          status: SubscriptionStatus.success,
          subscriptions: updatedList,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: SubscriptionStatus.failure));
    }
  }

  void _sortSubscriptions(List<Subscription> list) {
    list.sort((a, b) => a.nextRenewal().compareTo(b.nextRenewal()));
  }
}
