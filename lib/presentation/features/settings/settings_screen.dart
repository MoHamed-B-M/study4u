import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/services/update_service.dart';
import '../../../data/models/app_settings.dart';
import '../../theme/app_theme.dart';
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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: theme.textTheme.headlineSmall),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.standardPadding),
        children: [
          const SizedBox(height: 8),
          _SectionHeader(title: 'APPEARANCE'),
          const SizedBox(height: 12),
          _SettingsCard(
            child: Column(
              children: [
                ListTile(
                  leading: _IconTile(color: cs.primary, icon: Icons.brightness_6_outlined),
                  title: const Text('Appearance'),
                  subtitle: Text(_themeLabel(settings.themeMode)),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () => _showThemeSheet(context, ref, settings),
                ),
                const Divider(height: 1, indent: 72),
                ListTile(
                  leading: _IconTile(color: cs.tertiary, icon: Icons.palette_outlined),
                  title: const Text('Accent Color'),
                  subtitle: Row(
                    children: [
                      Container(
                        width: 12, height: 12,
                        decoration: BoxDecoration(color: Color(settings.primaryColorValue), shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      Text('#${settings.primaryColorValue.toRadixString(16).toUpperCase().padLeft(8, '0').substring(2)}'),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () => _showColorSheet(context, ref, settings),
                ),
                const Divider(height: 1, indent: 72),
                _SwitchTile(
                  leadingIcon: Icons.blur_on_outlined,
                  iconColor: cs.secondary,
                  title: 'Floating Nav Bar',
                  subtitle: 'Glassmorphism style bottom nav',
                  value: settings.useFloatingNavBar,
                  onChanged: (v) {
                    HapticFeedback.selectionClick();
                    ref.read(settingsProvider.notifier).setUseFloatingNavBar(v);
                  },
                ),
                const Divider(height: 1, indent: 72),
                _SwitchTile(
                  leadingIcon: Icons.vibration_outlined,
                  iconColor: cs.error,
                  title: 'Haptic Feedback',
                  subtitle: 'Vibration on interactions',
                  value: settings.hapticFeedback,
                  onChanged: (v) {
                    HapticFeedback.selectionClick();
                    ref.read(settingsProvider.notifier).setHapticFeedback(v);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          _SectionHeader(title: 'NOTIFICATIONS'),
          const SizedBox(height: 12),
          _SettingsCard(
            child: _SwitchTile(
              leadingIcon: Icons.notifications_outlined,
              iconColor: cs.primary,
              title: 'Notifications',
              subtitle: 'Get reminded about classes and tasks',
              value: settings.notificationEnabled,
              onChanged: (v) {
                HapticFeedback.selectionClick();
                ref.read(settingsProvider.notifier).setNotificationEnabled(v);
              },
            ),
          ),
          const SizedBox(height: 28),
          _SectionHeader(title: 'ABOUT'),
          const SizedBox(height: 12),
          _SettingsCard(
            child: Column(
              children: [
                ListTile(
                  leading: _IconTile(color: cs.primary, icon: Icons.menu_book_outlined),
                  title: const Text('stdy4u'),
                  subtitle: FutureBuilder<PackageInfo>(
                    future: PackageInfo.fromPlatform(),
                    builder: (ctx, snap) {
                      final ver = snap.data?.version ?? '1.0.0';
                      final build = snap.data?.buildNumber ?? '1';
                      return Text('Version $ver+$build');
                    },
                  ),
                ),
                const Divider(height: 1, indent: 72),
                ListTile(
                  leading: _IconTile(color: cs.tertiary, icon: Icons.system_update_outlined),
                  title: const Text('Check for Updates'),
                  subtitle: const Text('Download the latest version'),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () => _checkForUpdate(context),
                ),
                const Divider(height: 1, indent: 72),
                ListTile(
                  leading: _IconTile(color: cs.secondary, icon: Icons.code_outlined),
                  title: const Text('GitHub Repository'),
                  subtitle: const Text('MoHamed-B-M/study4u'),
                  trailing: const Icon(Icons.open_in_new, size: 18),
                  onTap: () => launchUrl(Uri.parse('https://github.com/MoHamed-B-M/study4u')),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _themeLabel(String mode) {
    switch (mode) {
      case 'dark': return 'Dark';
      case 'light': return 'Light';
      default: return 'System Default';
    }
  }

  Future<void> _checkForUpdate(BuildContext context) async {
    final service = UpdateService();
    final update = await service.checkForUpdate();
    if (!context.mounted) return;

    if (update == null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Update Check'),
          content: const Text('Could not check for updates. Check your connection.'),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
        ),
      );
      return;
    }

    if (!update.isNewer) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Update Check'),
          content: const Text('You are on the latest version!'),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
        ),
      );
      return;
    }

    await UpdateDialog.show(context: context, update: update);
  }

  void _showThemeSheet(BuildContext context, WidgetRef ref, AppSettings settings) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Text('Appearance', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'system', label: Text('System'), icon: Icon(Icons.settings_brightness)),
                ButtonSegment(value: 'light', label: Text('Light'), icon: Icon(Icons.light_mode)),
                ButtonSegment(value: 'dark', label: Text('Dark'), icon: Icon(Icons.dark_mode)),
              ],
              selected: {settings.themeMode},
              onSelectionChanged: (v) {
                HapticFeedback.selectionClick();
                ref.read(settingsProvider.notifier).setThemeMode(v.first);
                Navigator.pop(ctx);
              },
              showSelectedIcon: false,
            ),
          ],
        ),
      ),
    );
  }

  void _showColorSheet(BuildContext context, WidgetRef ref, AppSettings settings) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Text('Accent Color', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16, runSpacing: 16,
              children: _colors.map((color) {
                final isSelected = color.value == settings.primaryColorValue;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    ref.read(settingsProvider.notifier).setPrimaryColor(color.value);
                    Navigator.pop(ctx);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 52, height: 52,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected ? Border.all(color: Theme.of(context).colorScheme.surface, width: 3) : null,
                      boxShadow: isSelected ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 12, spreadRadius: 2)] : null,
                    ),
                    child: isSelected ? Icon(Icons.check, color: Theme.of(context).colorScheme.surface) : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurfaceVariant, letterSpacing: 0.5)),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final Widget child;
  const _SettingsCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusCard)),
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class _IconTile extends StatelessWidget {
  final Color color;
  final IconData icon;
  const _IconTile({required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40, height: 40,
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
      child: Icon(icon, size: 20, color: color),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData leadingIcon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.leadingIcon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _IconTile(color: iconColor, icon: leadingIcon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
