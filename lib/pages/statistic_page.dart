import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../cubits/subscription_cubit.dart';
import '../cubits/subscription_state.dart';
import '../models/subscription.dart';

class StatisticPage extends StatelessWidget {
  const StatisticPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Statistik',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: false,
      ),
      body: BlocBuilder<SubscriptionCubit, SubscriptionState>(
        builder: (context, state) {
          if (state.subscriptions.isEmpty) {
            return Center(
              child: Text(
                'Belum ada data',
                style: GoogleFonts.outfit(color: Colors.grey),
              ),
            );
          }

          // Calculate last 6 months
          final now = DateTime.now();
          // We want to show from e.g. T-5 months to T (current month)
          List<Map<String, dynamic>> monthlyData = [];

          for (int i = 5; i >= 0; i--) {
            // Find year and month
            // If i=0, we want current month.
            // If i=5, we want 5 months ago.
            // Logic: subtract 'i' months from current date.

            // To subtract months robustly:
            int targetYear = now.year;
            int targetMonth = now.month - i;
            if (targetMonth < 1) {
              targetMonth += 12;
              targetYear -= 1;
            }
            if (targetMonth < 1) {
              // Handle more than 1 year back if needed (shouldn't happen with i<12)
              // e.g. i=13, month=1-13 = -12.
              // Just handling 1 year crossover for i=5 is enough.
            }

            double total = 0.0;
            for (var sub in state.subscriptions) {
              total += sub.costInMonth(targetMonth, targetYear);
            }

            monthlyData.add({
              'month': targetMonth,
              'year': targetYear,
              'total': total,
              'label': DateFormat(
                'MMM',
              ).format(DateTime(targetYear, targetMonth)),
            });
          }

          double maxVal = 0;
          for (var d in monthlyData) {
            if (d['total'] > maxVal) maxVal = d['total'];
          }
          if (maxVal == 0) maxVal = 100; // Avoid division by zero in charts

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pengeluaran Bulanan',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  height: 300,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: maxVal * 1.2,
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          // tooltipBgColor: Colors.black, // Deprecated in newer versions? Let's check docs or use default
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              NumberFormat.compactCurrency(
                                locale: 'id_ID',
                                symbol: 'Rp',
                                decimalDigits: 0,
                              ).format(rod.toY),
                              const TextStyle(color: Colors.white),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < 0 || index >= monthlyData.length) {
                                return const SizedBox();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  monthlyData[index]['label'],
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: false,
                          ), // Clean look
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      barGroups: monthlyData.asMap().entries.map((e) {
                        final index = e.key;
                        final data = e.value;
                        final isCurrent = index == monthlyData.length - 1;
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: (data['total'] as double),
                              color: isCurrent
                                  ? Colors.deepPurple
                                  : Colors.deepPurple.withValues(alpha: 0.3),
                              width: 16,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Optional: Detailed list
                Text(
                  'Detail',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...monthlyData.reversed.map((d) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${d['label']} ${d['year']}',
                          style: GoogleFonts.outfit(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          NumberFormat.currency(
                            locale: 'id_ID',
                            symbol: 'Rp ',
                            decimalDigits: 0,
                          ).format(d['total']),
                          style: GoogleFonts.outfit(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 24),
                // Ranking Section
                Text(
                  'Peringkat Pengeluaran',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      ...() {
                        final List<Subscription> sortedSubs =
                            List<Subscription>.from(state.subscriptions);
                        sortedSubs.sort(
                          (a, b) => b.monthlyCost.compareTo(a.monthlyCost),
                        );

                        if (sortedSubs.isEmpty) {
                          return <Widget>[
                            Text(
                              'Belum ada data',
                              style: GoogleFonts.outfit(color: Colors.grey),
                            ),
                          ];
                        }

                        return sortedSubs.asMap().entries.map((entry) {
                          final index = entry.key;
                          final sub = entry.value;
                          final isLast = index == sortedSubs.length - 1;

                          return Column(
                            children: [
                              Row(
                                children: [
                                  // Rank number
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: index < 3
                                          ? Theme.of(context).primaryColor
                                          : Colors.grey[200],
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${index + 1}',
                                        style: GoogleFonts.outfit(
                                          color: index < 3
                                              ? Colors.white
                                              : Colors.grey[600],
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          sub.name,
                                          style: GoogleFonts.outfit(
                                            color: Theme.of(
                                              context,
                                            ).textTheme.bodyLarge?.color,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          '${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(sub.price)} / ${sub.periodString}',
                                          style: GoogleFonts.outfit(
                                            fontSize: 12,
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
                                        NumberFormat.compactCurrency(
                                          locale: 'id_ID',
                                          symbol: 'Rp',
                                          decimalDigits: 0,
                                        ).format(sub.monthlyCost),
                                        style: GoogleFonts.outfit(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(
                                            context,
                                          ).textTheme.bodyLarge?.color,
                                        ),
                                      ),
                                      Text(
                                        '/ bln',
                                        style: GoogleFonts.outfit(
                                          fontSize: 10,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              if (!isLast)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  child: Divider(
                                    height: 1,
                                    color: Colors.grey.withValues(alpha: 0.1),
                                  ),
                                ),
                            ],
                          );
                        }).toList();
                      }(),
                    ],
                  ),
                ),
                const SizedBox(height: 80), // Bottom padding
              ],
            ),
          );
        },
      ),
    );
  }
}
