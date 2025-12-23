import 'package:equatable/equatable.dart';
import '../models/subscription.dart';

enum SubscriptionStatus { initial, loading, success, failure }

enum SortOption { renewalDate, priceLowHigh, priceHighLow }

class SubscriptionState extends Equatable {
  final SubscriptionStatus status;
  final List<Subscription> subscriptions;
  final SortOption sortOption;
  final String? selectedCategory;
  final String searchQuery;

  const SubscriptionState({
    this.status = SubscriptionStatus.initial,
    this.subscriptions = const [],
    this.sortOption = SortOption.renewalDate,
    this.selectedCategory,
    this.searchQuery = '',
  });

  SubscriptionState copyWith({
    SubscriptionStatus? status,
    List<Subscription>? subscriptions,
    SortOption? sortOption,
    String? selectedCategory,
    String? searchQuery,
  }) {
    return SubscriptionState(
      status: status ?? this.status,
      subscriptions: subscriptions ?? this.subscriptions,
      sortOption: sortOption ?? this.sortOption,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
    status,
    subscriptions,
    sortOption,
    selectedCategory,
    searchQuery,
  ];
}
