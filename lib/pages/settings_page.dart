import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../cubits/theme_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pengaturan',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Tampilan'),
          const SizedBox(height: 8),
          _buildThemeOption(context),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildThemeOption(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, currentMode) {
          return Column(
            children: [
              _buildRadioTile(
                context,
                title: 'System Default',
                value: ThemeMode.system,
                groupValue: currentMode,
                icon: Icons.brightness_auto,
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              _buildRadioTile(
                context,
                title: 'Light Theme',
                value: ThemeMode.light,
                groupValue: currentMode,
                icon: Icons.light_mode,
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              _buildRadioTile(
                context,
                title: 'Dark Theme',
                value: ThemeMode.dark,
                groupValue: currentMode,
                icon: Icons.dark_mode,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRadioTile(
    BuildContext context, {
    required String title,
    required ThemeMode value,
    required ThemeMode groupValue,
    required IconData icon,
  }) {
    return RadioListTile<ThemeMode>(
      value: value,
      groupValue: groupValue,
      onChanged: (ThemeMode? newValue) {
        if (newValue != null) {
          context.read<ThemeCubit>().updateTheme(newValue);
        }
      },
      title: Text(
        title,
        style: GoogleFonts.outfit(fontWeight: FontWeight.w500),
      ),
      secondary: Icon(icon, color: Theme.of(context).primaryColor),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      activeColor: Theme.of(context).primaryColor,
      controlAffinity: ListTileControlAffinity.trailing,
    );
  }
}
