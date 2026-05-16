import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/app_settings.dart';
import '../../theme/theme_provider.dart';
import '../../widgets/app_card.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const _colors = [
    Color(0xFF4ADE80),
    Color(0xFF2DD4BF),
    Color(0xFFFBBF24),
    Color(0xFF60A5FA),
    Color(0xFFF472B6),
    Color(0xFFA78BFA),
    Color(0xFFFB923C),
    Color(0xFF34D399),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildThemeSection(context, ref, settings),
            const SizedBox(height: 24),
            _buildDynamicColorSection(context, ref, settings),
            const SizedBox(height: 24),
            _buildColorSection(context, ref, settings),
            const SizedBox(height: 24),
            _buildNotificationSection(context, ref, settings),
            const SizedBox(height: 24),
            _buildAboutSection(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSection(BuildContext context, WidgetRef ref, AppSettings settings) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Appearance', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildRadioTile(
            context,
            title: 'System Default',
            subtitle: 'Follow your device theme',
            icon: Icons.brightness_auto,
            value: 'system',
            groupValue: settings.themeMode,
            onChanged: (v) {
              HapticFeedback.selectionClick();
              ref.read(settingsProvider.notifier).setThemeMode(v!);
            },
          ),
          _buildRadioTile(
            context,
            title: 'Light',
            subtitle: 'Always light mode',
            icon: Icons.light_mode,
            value: 'light',
            groupValue: settings.themeMode,
            onChanged: (v) {
              HapticFeedback.selectionClick();
              ref.read(settingsProvider.notifier).setThemeMode(v!);
            },
          ),
          _buildRadioTile(
            context,
            title: 'Dark',
            subtitle: 'Always dark mode',
            icon: Icons.dark_mode,
            value: 'dark',
            groupValue: settings.themeMode,
            onChanged: (v) {
              HapticFeedback.selectionClick();
              ref.read(settingsProvider.notifier).setThemeMode(v!);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicColorSection(BuildContext context, WidgetRef ref, AppSettings settings) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Material You', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            'Use dynamic color from your device wallpaper',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SwitchListTile(
            title: const Text('Dynamic Colors'),
            subtitle: const Text('Match your system theme'),
            value: settings.useDynamicColor,
            activeColor: Theme.of(context).colorScheme.primary,
            contentPadding: EdgeInsets.zero,
            onChanged: (v) {
              HapticFeedback.selectionClick();
              ref.read(settingsProvider.notifier).setUseDynamicColor(v);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildColorSection(BuildContext context, WidgetRef ref, AppSettings settings) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Accent Color', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _colors.map((color) {
              final isSelected = color.value == settings.primaryColorValue;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  ref.read(settingsProvider.notifier).setPrimaryColor(color.value);
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: Colors.white, width: 3)
                        : null,
                    boxShadow: isSelected
                        ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 12, spreadRadius: 2)]
                        : null,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white)
                      : null,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSection(BuildContext context, WidgetRef ref, AppSettings settings) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Notifications', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Enable Notifications'),
            subtitle: const Text('Get reminded about classes and tasks'),
            value: settings.notificationEnabled,
            activeColor: Theme.of(context).colorScheme.primary,
            onChanged: (v) {
              HapticFeedback.selectionClick();
              ref.read(settingsProvider.notifier).setNotificationEnabled(v);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('About', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('stdy4u'),
            subtitle: const Text('Version 1.0.0'),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.school, color: Theme.of(context).colorScheme.primary),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'A premium student productivity tool designed with Material 3 Expressive.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildRadioTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
    required String groupValue,
    required ValueChanged<String?> onChanged,
  }) {
    return RadioListTile<String>(
      title: Text(title),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
      secondary: Icon(icon),
      value: value,
      groupValue: groupValue,
      activeColor: Theme.of(context).colorScheme.primary,
      onChanged: onChanged,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
