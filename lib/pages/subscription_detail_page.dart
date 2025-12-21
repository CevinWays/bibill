import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../cubits/subscription_cubit.dart';
import '../models/subscription.dart';
import 'add_subscription_page.dart';

class SubscriptionDetailPage extends StatelessWidget {
  final Subscription subscription;

  const SubscriptionDetailPage({super.key, required this.subscription});

  @override
  Widget build(BuildContext context) {
    // We listen to the Cubit to get updates if the subscription is edited
    // But since this is a new page, we might just receive the object.
    // Ideally, we should find the updated object from the state or just pop back after edit.
    // For simplicity, we will assume if we edit, we pass the data back or reload.
    // Let's rely on building the UI from the passed object, but handle "Edit" by finding it in the cubit list?
    // A better approach for Detail pages usually involves listening to a specific ID.
    // Given the MVP nature, we'll keep it simple: Pass object. If edited, we might pop this page or use BlocListener.

    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final nextRenewal = subscription.nextRenewal();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          subscription.name,
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      AddSubscriptionPage(subscription: subscription),
                ),
              ).then((_) {
                // When coming back, if we edited, this page has stale data.
                // Simplest fix: Pop this page too? Or use a BlocBuilder that looks up the ID?
                // Let's pop this page so user goes back to list.
                if (context.mounted) {
                  Navigator.pop(context);
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              showDialog(
                context: context,
                builder: (c) => AlertDialog(
                  title: const Text('Hapus Langganan?'),
                  content: const Text('Tindakan ini tidak dapat diurangi.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(c),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<SubscriptionCubit>().deleteSubscription(
                          subscription.id,
                        );
                        Navigator.pop(c); // Close dialog
                        Navigator.pop(context); // Close Detail Page
                      },
                      child: const Text(
                        'Hapus',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    subscription.name[0].toUpperCase(),
                    style: GoogleFonts.outfit(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              currencyFormatter.format(subscription.price),
              style: GoogleFonts.outfit(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              '/ ${subscription.periodString}',
              style: GoogleFonts.outfit(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            _buildDetailRow(
              'Tanggal Tagihan Berikutnya',
              DateFormat('dd MMMM yyyy').format(nextRenewal),
            ),
            const Divider(height: 32),
            _buildDetailRow(
              'Tanggal Tagihan Pertama',
              DateFormat('dd MMMM yyyy').format(subscription.firstBillDate),
            ),
            const Divider(height: 32),
            _buildDetailRow(
              'Pengingat',
              subscription.reminders.isEmpty
                  ? 'Tidak ada'
                  : subscription.reminders
                        .map((e) => '$e hari sebelum')
                        .join(', '),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(fontSize: 16, color: Colors.grey[600]),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
