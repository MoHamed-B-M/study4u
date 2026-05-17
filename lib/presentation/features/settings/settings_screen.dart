import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/services/update_service.dart';
import '../../../data/models/app_settings.dart';
import '../../theme/theme_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/update_dialog.dart';

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
    final labels = {'system': 'System Default', 'light': 'Light', 'dark': 'Dark'};
    final current = labels[settings.themeMode] ?? 'System Default';
    final icons = {'system': Icons.brightness_auto, 'light': Icons.light_mode, 'dark': Icons.dark_mode};

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showThemeSheet(context, ref, settings),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icons[settings.themeMode] ?? Icons.brightness_auto,
                  color: Theme.of(context).colorScheme.primary, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Appearance', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(current, style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  )),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
          ],
        ),
      ),
    );
  }

  void _showThemeSheet(BuildContext context, WidgetRef ref, AppSettings settings) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Choose Theme', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold)),
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
                Navigator.of(context).pop();
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
                Navigator.of(context).pop();
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
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSection(BuildContext context, WidgetRef ref, AppSettings settings) {
    final currentColor = Color(settings.primaryColorValue);
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showColorSheet(context, ref, settings),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: currentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.palette_outlined, color: currentColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Accent Color', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 14, height: 14,
                        decoration: BoxDecoration(color: currentColor, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Text('#${settings.primaryColorValue.toRadixString(16).toUpperCase().padLeft(8, '0').substring(2)}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
          ],
        ),
      ),
    );
  }

  void _showColorSheet(BuildContext context, WidgetRef ref, AppSettings settings) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Pick Accent Color', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: _colors.map((color) {
                final isSelected = color.value == settings.primaryColorValue;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    ref.read(settingsProvider.notifier).setPrimaryColor(color.value);
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
                      boxShadow: isSelected
                          ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 12, spreadRadius: 2)]
                          : null,
                    ),
                    child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSection(BuildContext context, WidgetRef ref, AppSettings settings) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.notifications_outlined,
                    color: Theme.of(context).colorScheme.primary, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text('Notifications', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Switch(
                value: settings.notificationEnabled,
                activeColor: Theme.of(context).colorScheme.primary,
                onChanged: (v) {
                  HapticFeedback.selectionClick();
                  ref.read(settingsProvider.notifier).setNotificationEnabled(v);
                },
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 50),
            child: Text('Get reminded about classes and tasks',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary, size: 22),
              ),
              const SizedBox(width: 16),
              Text('About', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.school, color: Colors.black54, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('stdy4u', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                    FutureBuilder<PackageInfo>(
                      future: PackageInfo.fromPlatform(),
                      builder: (ctx, snap) {
                        final ver = snap.data?.version ?? '1.0.0';
                        final build = snap.data?.buildNumber ?? '1';
                        return Text('Version $ver+$build',
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _checkForUpdate(context),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.system_update_outlined, size: 20, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Check for Updates',
                          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 14)),
                        Text('Download the latest version',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                          )),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, size: 18,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => launchUrl(Uri.parse('https://github.com/MoHamed-B-M/study4u')),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.code, size: 20, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('GitHub Repository',
                          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 14)),
                        Text('MoHamed-B-M/study4u',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                          )),
                      ],
                    ),
                  ),
                  Icon(Icons.open_in_new, size: 18,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _checkForUpdate(BuildContext context) async {
    final service = UpdateService();
    final update = await service.checkForUpdate();
    if (!context.mounted) return;

    if (update == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Could not check for updates. Check your connection.'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    if (!update.isNewer) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('You are on the latest version!'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    await UpdateDialog.show(context: context, update: update);
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
      title: Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
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
