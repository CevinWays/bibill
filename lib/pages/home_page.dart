import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../cubits/subscription_cubit.dart';
import '../cubits/subscription_state.dart';
import '../models/subscription.dart';
import '../services/notification_service.dart';
import 'add_subscription_page.dart';
import 'subscription_detail_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Bibill',
          style: GoogleFonts.outfit(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.notifications_active, color: Colors.black),
          //   onPressed: () {
          //     NotificationService().showTestNotification();
          //     ScaffoldMessenger.of(context).showSnackBar(
          //       const SnackBar(content: Text('Test notification scheduled...')),
          //     );
          //   },
          // ),
          IconButton(
            icon: const Icon(Icons.sort, color: Colors.black),
            onPressed: () {
              // Sorting is automatic in Cubit for now, but we could add manual toggle here
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddSubscriptionPage()),
          );
        },
        label: Text(
          'Tambah Langganan',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
        ),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.black, // Modern look
        foregroundColor: Colors.white,
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
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.0, // Square items
                    children: [
                      _buildStatCard(
                        'Total\nLangganan',
                        totalSubs.toString(),
                        Colors.blue,
                        Icons.subscriptions,
                      ),
                      _buildStatCard(
                        'Total\nTagihan',
                        currencyFormatter.format(totalCost),
                        Colors.orange,
                        Icons.payments_rounded,
                      ),
                      _buildStatCard(
                        'Tagihan\nMinggu Ini',
                        currencyFormatter.format(weeklyCost),
                        Colors.red,
                        Icons.calendar_today,
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
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final sub = state.subscriptions[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _SubscriptionCard(subscription: sub),
                    );
                  }, childCount: state.subscriptions.length),
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
          color: Colors.white,
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
                  color: _getColorForName(subscription.name),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    subscription.name.isNotEmpty
                        ? subscription.name[0].toUpperCase()
                        : '?',
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
                      color: Colors.black,
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

  Color _getColorForName(String name) {
    if (name.isEmpty) return Colors.grey;
    final colors = [
      const Color(0xFFE91E63), // Pink
      const Color(0xFF9C27B0), // Purple
      const Color(0xFF2196F3), // Blue
      const Color(0xFF00BCD4), // Cyan
      const Color(0xFF009688), // Teal
      const Color(0xFFFF9800), // Orange
      const Color(0xFF607D8B), // Blue Grey
      const Color(0xFF3F51B5), // Indigo
    ];
    // Hash code to pick a consistent color
    return colors[name.hashCode.abs() % colors.length];
  }
}
