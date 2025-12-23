import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../models/subscription.dart';
import '../data/database_helper.dart';
import '../services/notification_service.dart';
import 'subscription_state.dart';

class SubscriptionCubit extends Cubit<SubscriptionState> {
  SubscriptionCubit() : super(const SubscriptionState()) {
    loadSubscriptions();
  }

  Future<void> loadSubscriptions() async {
    emit(state.copyWith(status: SubscriptionStatus.loading));
    try {
      final list = await DatabaseHelper.instance.readAllSubscriptions();
      _sortSubscriptions(list);
      emit(
        state.copyWith(status: SubscriptionStatus.success, subscriptions: list),
      );
    } catch (e) {
      emit(state.copyWith(status: SubscriptionStatus.failure));
    }
  }

  Future<void> addSubscription(Subscription subscription) async {
    // If ID is empty (not from copyWith/edit), generate one.
    // However, our model now defaults id to '' if not provided in const constructor?
    // Let's ensure we have an ID before saving.

    Subscription toSave = subscription;
    if (toSave.id.isEmpty) {
      toSave = subscription.copyWith(id: const Uuid().v4());
    }

    emit(state.copyWith(status: SubscriptionStatus.loading));
    try {
      await DatabaseHelper.instance.create(toSave); // Save to DB
      try {
        await NotificationService().scheduleForSubscription(toSave);
      } catch (_) {
        // Ignore notification errors to ensure data persistence
      }
      await loadSubscriptions(); // Reload from DB to ensure sync
    } catch (e) {
      emit(state.copyWith(status: SubscriptionStatus.failure));
    }
  }

  Future<void> updateSubscription(Subscription subscription) async {
    emit(state.copyWith(status: SubscriptionStatus.loading));
    try {
      await DatabaseHelper.instance.update(subscription);
      // Cancel old reminders and schedule new ones
      try {
        await NotificationService().cancelForSubscription(subscription);
        await NotificationService().scheduleForSubscription(subscription);
      } catch (_) {}
      await loadSubscriptions();
    } catch (e) {
      emit(state.copyWith(status: SubscriptionStatus.failure));
    }
  }

  Future<void> deleteSubscription(String id) async {
    emit(state.copyWith(status: SubscriptionStatus.loading));
    try {
      // We need the subscription object to cancel reminders correctly?
      // NotificationService uses ID hash. So we just need ID.
      // But we construct ID hash using ID + days. So we can re-construct it.
      // However, cancelForSubscription takes a Subscription object.
      // We should ideally fetch it first or change cancelForSubscription to take ID.
      // For now, let's just make a dummy subscription or find it in current state.

      final subscription = state.subscriptions.firstWhere(
        (s) => s.id == id,
        orElse: () => Subscription(
          name: '',
          price: 0,
          period: SubscriptionPeriod.monthly,
          firstBillDate: DateTime.now(),
        ),
      );
      if (subscription.id.isNotEmpty) {
        try {
          await NotificationService().cancelForSubscription(subscription);
        } catch (_) {}
      }

      await DatabaseHelper.instance.delete(id);
      await loadSubscriptions();
    } catch (e) {
      emit(state.copyWith(status: SubscriptionStatus.failure));
    }
  }

  void changeSortOption(SortOption option) {
    // If option is same, do nothing
    if (state.sortOption == option) return;

    // Create a new list to sort
    final sortedList = List<Subscription>.from(state.subscriptions);
    _sortSubscriptions(sortedList, option);

    emit(state.copyWith(subscriptions: sortedList, sortOption: option));
  }

  void _sortSubscriptions(List<Subscription> list, [SortOption? option]) {
    final sortOption = option ?? state.sortOption;
    switch (sortOption) {
      case SortOption.renewalDate:
        list.sort((a, b) => a.nextRenewal().compareTo(b.nextRenewal()));
        break;
      case SortOption.priceLowHigh:
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.priceHighLow:
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
    }
  }

  void selectCategory(String? category) {
    if (state.selectedCategory == category) return;
    emit(state.copyWith(selectedCategory: category));
  }

  void searchSubscriptions(String query) {
    emit(state.copyWith(searchQuery: query));
  }
}
