import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../cubits/subscription_cubit.dart';
import '../cubits/subscription_state.dart';
import '../models/subscription.dart';
import 'settings_page.dart';
import 'subscription_detail_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Bibill',
          style: GoogleFonts.outfit(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        centerTitle: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.sort, color: Theme.of(context).iconTheme.color),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Theme.of(context).cardColor,
                builder: (context) => Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Urutkan Berdasarkan',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        leading: Icon(
                          Icons.calendar_today,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        title: Text(
                          'Tanggal Pembayaran',
                          style: GoogleFonts.outfit(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        onTap: () {
                          context.read<SubscriptionCubit>().changeSortOption(
                            SortOption.renewalDate,
                          );
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.arrow_upward,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        title: Text(
                          'Harga Terendah',
                          style: GoogleFonts.outfit(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        onTap: () {
                          context.read<SubscriptionCubit>().changeSortOption(
                            SortOption.priceLowHigh,
                          );
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.arrow_downward,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        title: Text(
                          'Harga Tertinggi',
                          style: GoogleFonts.outfit(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        onTap: () {
                          context.read<SubscriptionCubit>().changeSortOption(
                            SortOption.priceHighLow,
                          );
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.settings,
              color: Theme.of(context).iconTheme.color,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<SubscriptionCubit, SubscriptionState>(
        builder: (context, state) {
          if (state.subscriptions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.subscriptions_outlined,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum Ada Langganan',
                    style: GoogleFonts.outfit(fontSize: 18, color: Colors.grey),
                  ),
                  Text(
                    'Tambahkan Langganan Pertama Anda',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            );
          }

          // Calculations
          final totalSubs = state.subscriptions.length;
          final totalCost = state.subscriptions.fold(
            0.0,
            (sum, sub) => sum + sub.price,
          );

          final now = DateTime.now();
          final endOfWeek = now.add(const Duration(days: 7));
          final weeklyCost = state.subscriptions.fold(0.0, (sum, sub) {
            final next = sub.nextRenewal();
            // Check if next renewal is within now and now+7days
            // Normalize dates to be safe (though nextRenewal usually returns date with time?)
            // subscription.dart nextRenewal returns date logic.
            // Let's compare timestamps.
            if (next.isAfter(now.subtract(const Duration(days: 1))) &&
                next.isBefore(endOfWeek)) {
              return sum + sub.price;
            }
            return sum;
          });

          final currencyFormatter = NumberFormat.compactCurrency(
            locale: 'id_ID',
            symbol: 'Rp',
            decimalDigits: 0,
          ); // Compact for grid to save space? or normal? Normal might be too long.
          // Let's use simple currency format but maybe shorten if needed.

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari langganan...',
                      hintStyle: GoogleFonts.outfit(color: Colors.grey),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Theme.of(context).primaryColor,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 0,
                      ),
                    ),
                    style: GoogleFonts.outfit(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    onChanged: (value) {
                      context.read<SubscriptionCubit>().searchSubscriptions(
                        value,
                      );
                    },
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total\nLangganan',
                          totalSubs.toString(),
                          Colors.blue,
                          Icons.subscriptions,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildStatCard(
                          'Total\nTagihan',
                          currencyFormatter.format(totalCost),
                          Colors.orange,
                          Icons.payments_rounded,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildStatCard(
                          'Tagihan\nMinggu Ini',
                          currencyFormatter.format(weeklyCost),
                          Colors.red,
                          Icons.calendar_today,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _buildFilterChip(
                        context,
                        label: 'Semua',
                        isSelected: state.selectedCategory == null,
                        onSelected: () => context
                            .read<SubscriptionCubit>()
                            .selectCategory(null),
                      ),
                      ...state.subscriptions
                          .map((s) => s.category)
                          .toSet()
                          .map(
                            (category) => _buildFilterChip(
                              context,
                              label: category,
                              isSelected: state.selectedCategory == category,
                              onSelected: () => context
                                  .read<SubscriptionCubit>()
                                  .selectCategory(category),
                            ),
                          ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final filteredSubs = state.subscriptions.where((s) {
                        final matchCategory =
                            state.selectedCategory == null ||
                            s.category == state.selectedCategory;
                        final matchSearch =
                            state.searchQuery.isEmpty ||
                            s.name.toLowerCase().contains(
                              state.searchQuery.toLowerCase(),
                            );
                        return matchCategory && matchSearch;
                      }).toList();

                      if (index >= filteredSubs.length) return null;

                      final sub = filteredSubs[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _SubscriptionCard(subscription: sub),
                      );
                    },
                    childCount: state.subscriptions.where((s) {
                      final matchCategory =
                          state.selectedCategory == null ||
                          s.category == state.selectedCategory;
                      final matchSearch =
                          state.searchQuery.isEmpty ||
                          s.name.toLowerCase().contains(
                            state.searchQuery.toLowerCase(),
                          );
                      return matchCategory && matchSearch;
                    }).length,
                  ),
                ),
              ),
              // Add some bottom padding for FAB
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 16, // Slightly smaller to fit
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 10,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onSelected,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.grey.withValues(alpha: 0.2),
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.outfit(
              color: isSelected
                  ? Colors.white
                  : Theme.of(context).textTheme.bodyLarge?.color,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  final Subscription subscription;

  const _SubscriptionCard({required this.subscription});

  @override
  Widget build(BuildContext context) {
    final nextDate = subscription.nextRenewal();
    final daysLeft =
        nextDate.difference(DateTime.now()).inDays +
        1; // +1 to include today roughly
    // Simple logic: if nextDate is today, diff is 0.

    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SubscriptionDetailPage(subscription: subscription),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: subscription.iconPath != null
                      ? Colors.transparent
                      : Colors
                            .primaries[subscription.name.length %
                                Colors.primaries.length]
                            .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: subscription.iconPath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.asset(
                          subscription.iconPath!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Center(
                        child: Text(
                          subscription.name[0].toUpperCase(),
                          style: GoogleFonts.outfit(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color:
                                Colors.primaries[subscription.name.length %
                                    Colors.primaries.length],
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subscription.name,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currencyFormatter.format(subscription.price),
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    DateFormat('dd MMM').format(nextDate),
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: daysLeft <= 3 ? Colors.red[50] : Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      daysLeft == 0
                          ? 'Hari ini'
                          : (daysLeft < 0
                                ? 'Terlambat'
                                : '$daysLeft hari lagi'),
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: daysLeft <= 3 ? Colors.red : Colors.green[700],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
