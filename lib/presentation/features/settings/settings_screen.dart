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
      body: ListView(
        padding: const EdgeInsets.only(top: 8),
        children: [
          _sectionHeader(context, 'APPEARANCE'),
          _settingsGroup(context, [
            _appearanceRow(context, ref, settings),
            _accentColorRow(context, ref, settings),
          ]),
          _sectionHeader(context, 'NOTIFICATIONS'),
          _settingsGroup(context, [
            _notificationRow(context, ref, settings),
          ]),
          _sectionHeader(context, 'ABOUT'),
          _settingsGroup(context, [
            _aboutRow(context),
            _checkUpdateRow(context),
            _gitHubRow(context),
          ]),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 6),
      child: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Widget _settingsGroup(BuildContext context, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            for (int i = 0; i < children.length; i++) ...[
              children[i],
              if (i < children.length - 1)
                Divider(
                  height: 1,
                  thickness: 1,
                  indent: 52,
                  endIndent: 0,
                  color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _appearanceRow(BuildContext context, WidgetRef ref, AppSettings settings) {
    final labels = {'system': 'System Default', 'light': 'Light', 'dark': 'Dark'};
    final current = labels[settings.themeMode] ?? 'System Default';
    final icons = {'system': Icons.brightness_auto, 'light': Icons.light_mode, 'dark': Icons.dark_mode};
    final tint = Theme.of(context).colorScheme.primary;

    return InkWell(
      onTap: () => _showThemeSheet(context, ref, settings),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: tint.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icons[settings.themeMode] ?? Icons.brightness_auto, size: 16, color: tint),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Appearance', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(current, style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  )),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 20,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
          ],
        ),
      ),
    );
  }

  Widget _accentColorRow(BuildContext context, WidgetRef ref, AppSettings settings) {
    final currentColor = Color(settings.primaryColorValue);
    return InkWell(
      onTap: () => _showColorSheet(context, ref, settings),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: currentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(Icons.palette_outlined, size: 16, color: currentColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Accent Color', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 12, height: 12,
                        decoration: BoxDecoration(color: currentColor, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '#${settings.primaryColorValue.toRadixString(16).toUpperCase().padLeft(8, '0').substring(2)}',
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
            Icon(Icons.chevron_right, size: 20,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
          ],
        ),
      ),
    );
  }

  Widget _notificationRow(BuildContext context, WidgetRef ref, AppSettings settings) {
    final tint = Theme.of(context).colorScheme.primary;

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        ref.read(settingsProvider.notifier).setNotificationEnabled(!settings.notificationEnabled);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: tint.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(Icons.notifications_outlined, size: 16, color: tint),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Notifications', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text('Get reminded about classes and tasks',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                    )),
                ],
              ),
            ),
            Switch(
              value: settings.notificationEnabled,
              activeColor: tint,
              onChanged: (v) {
                HapticFeedback.selectionClick();
                ref.read(settingsProvider.notifier).setNotificationEnabled(v);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _aboutRow(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(Icons.school, size: 16, color: Colors.black54),
          ),
          const SizedBox(width: 12),
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
    );
  }

  Widget _checkUpdateRow(BuildContext context) {
    final tint = Theme.of(context).colorScheme.primary;
    return InkWell(
      onTap: () => _checkForUpdate(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: tint.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(Icons.system_update_outlined, size: 16, color: tint),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Check for Updates', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text('Download the latest version',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                    )),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 20,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
          ],
        ),
      ),
    );
  }

  Widget _gitHubRow(BuildContext context) {
    final tint = Theme.of(context).colorScheme.primary;
    return InkWell(
      onTap: () => launchUrl(Uri.parse('https://github.com/MoHamed-B-M/study4u')),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: tint.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(Icons.code, size: 16, color: tint),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('GitHub Repository', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 2),
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
