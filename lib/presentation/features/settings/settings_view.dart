import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/services/update_service.dart';
import '../../../../data/models/app_settings.dart';
import '../../../../theme/comic_theme.dart';
import '../../../../widgets/comic_card.dart';
import '../../../../widgets/comic_button.dart';
import '../../theme/theme_provider.dart';
import '../../widgets/update_dialog.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  static const _colors = [
    Color(0xFFA18CFF),
    Color(0xFF8F99FB),
    Color(0xFFFBBF24),
    Color(0xFF60A5FA),
    Color(0xFFF472B6),
    Color(0xFF4ADE80),
    Color(0xFFFB923C),
    Color(0xFF34D399),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(context, 'APPEARANCE'),
                  ComicCard(
                    padding: EdgeInsets.zero,
                    child: Column(children: [
                      _buildSettingRow(
                        context,
                        icon: CupertinoIcons.circle_lefthalf_fill,
                        iconColor: ComicTheme.inkRed,
                        title: 'Appearance',
                        subtitle: _themeLabel(settings.themeMode),
                        onTap: () => _showThemeSheet(context, ref, settings),
                      ),
                      _buildSettingRow(
                        context,
                        icon: CupertinoIcons.paintbrush,
                        iconColor: ComicTheme.inkRed,
                        title: 'Accent Color',
                        subtitle:
                            '#${settings.primaryColorValue.toRadixString(16).toUpperCase().padLeft(8, '0').substring(2)}',
                        trailing: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Color(settings.primaryColorValue),
                            shape: BoxShape.circle,
                          ),
                        ),
                        onTap: () => _showColorSheet(context, ref, settings),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionHeader(context, 'PREFERENCES'),
                  ComicCard(
                    padding: EdgeInsets.zero,
                    child: Column(children: [
                      _buildSwitchRow(
                        context,
                        icon: CupertinoIcons.hand_raised,
                        iconColor: ComicTheme.inkRed,
                        title: 'Haptic Feedback',
                        subtitle: 'Vibration on interactions',
                        value: settings.hapticFeedback,
                        onChanged: (v) {
                          HapticFeedback.selectionClick();
                          ref
                              .read(settingsProvider.notifier)
                              .setHapticFeedback(v);
                        },
                      ),
                      _buildSwitchRow(
                        context,
                        icon: CupertinoIcons.bell,
                        iconColor: ComicTheme.inkRed,
                        title: 'Notifications',
                        subtitle: 'Get reminded about classes and tasks',
                        value: settings.notificationEnabled,
                        onChanged: (v) {
                          HapticFeedback.selectionClick();
                          ref
                              .read(settingsProvider.notifier)
                              .setNotificationEnabled(v);
                        },
                      ),
                      _buildSwitchRow(
                        context,
                        icon: CupertinoIcons.rectangle_3_offgrid,
                        iconColor: ComicTheme.inkRed,
                        title: 'Show Labels',
                        subtitle: 'Show navigation bar labels',
                        value: settings.showNavLabels,
                        onChanged: (v) {
                          HapticFeedback.selectionClick();
                          ref
                              .read(settingsProvider.notifier)
                              .setShowNavLabels(v);
                        },
                      ),
                    ]),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionHeader(context, 'ABOUT'),
                  ComicCard(
                    padding: EdgeInsets.zero,
                    child: Column(children: [
                      _buildSettingRow(
                        context,
                        icon: CupertinoIcons.book,
                        iconColor: ComicTheme.inkRed,
                        title: 'stdy4u',
                        subtitle: 'Tap for version info',
                        trailing: FutureBuilder<PackageInfo>(
                          future: PackageInfo.fromPlatform(),
                          builder: (ctx, snap) {
                            final ver = snap.data?.version ?? '1.0.0';
                            final build = snap.data?.buildNumber ?? '1';
                            return Text(
                              'v$ver+$build',
                              style: TextStyle(
                                fontSize: 11,
                              ),
                            );
                          },
                        ),
                      ),
                      _buildSettingRow(
                        context,
                        icon: CupertinoIcons.arrow_down_circle,
                        iconColor: ComicTheme.inkRed,
                        title: 'Check for Updates',
                        subtitle: 'Download the latest version',
                        onTap: () => _checkForUpdate(context),
                      ),
                      _buildSettingRow(
                        context,
                        icon: CupertinoIcons.book,
                        iconColor: ComicTheme.inkRed,
                        title: 'GitHub Repository',
                        subtitle: 'MoHamed-B-M/study4u',
                        onTap: () => launchUrl(Uri.parse(
                            'https://github.com/MoHamed-B-M/study4u')),
                      ),
                      _buildSettingRow(
                        context,
                        icon: CupertinoIcons.hand_thumbsup,
                        iconColor: ComicTheme.inkRed,
                        title: 'Submit Feedback',
                        subtitle: 'Report issues or suggest features',
                        onTap: () => launchUrl(Uri.parse(
                            'https://github.com/MoHamed-B-M/study4u/issues/new')),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: isDark ? ComicTheme.darkText.withValues(alpha: 0.6) : ComicTheme.inkBlack.withValues(alpha: 0.6),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingRow(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? ComicTheme.darkText : ComicTheme.inkBlack;
    final secondaryText = isDark
        ? ComicTheme.darkText.withValues(alpha: 0.7)
        : ComicTheme.inkBlack.withValues(alpha: 0.7);
    final tertiaryText = isDark
        ? ComicTheme.darkText.withValues(alpha: 0.5)
        : ComicTheme.inkBlack.withValues(alpha: 0.5);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: primaryText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing,
            ],
            if (onTap != null)
              Icon(
                CupertinoIcons.chevron_right,
                size: 16,
                color: tertiaryText,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchRow(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? ComicTheme.darkText : ComicTheme.inkBlack;
    final secondaryText = isDark
        ? ComicTheme.darkText.withValues(alpha: 0.7)
        : ComicTheme.inkBlack.withValues(alpha: 0.7);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: primaryText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: secondaryText,
                  ),
                ),
              ],
            ),
          ),
          CupertinoSwitch(
            value: value,
            activeTrackColor: ComicTheme.inkRed,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  String _themeLabel(String mode) {
    switch (mode) {
      case 'dark':
        return 'Dark';
      case 'light':
        return 'Light';
      default:
        return 'System Default';
    }
  }

  Future<void> _checkForUpdate(BuildContext context) async {
    final service = UpdateService();
    final update = await service.checkForUpdate();
    if (!context.mounted) return;

    if (update == null || !update.isNewer) {
      showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text('Update Check'),
          content: Text(update == null
              ? 'Could not check for updates.'
              : 'You are on the latest version!'),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('OK'),
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      );
      return;
    }

    await UpdateDialog.show(context: context, update: update);
  }

  void _showThemeSheet(
      BuildContext context, WidgetRef ref, AppSettings settings) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext modalCtx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Choose Theme',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ComicTheme.inkBlack,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ComicButton(
                    isCta: settings.themeMode == 'system',
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      ref
                          .read(settingsProvider.notifier)
                          .setThemeMode('system');
                      Navigator.of(modalCtx).pop();
                    },
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    child: const Column(children: [
                      Icon(Icons.brightness_auto, size: 18),
                      Text('System'),
                    ]),
                  ),
                  const SizedBox(width: 8),
                  ComicButton(
                    isCta: settings.themeMode == 'light',
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      ref
                          .read(settingsProvider.notifier)
                          .setThemeMode('light');
                      Navigator.of(modalCtx).pop();
                    },
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    child: const Column(children: [
                      Icon(Icons.wb_sunny, size: 18),
                      Text('Light'),
                    ]),
                  ),
                  const SizedBox(width: 8),
                  ComicButton(
                    isCta: settings.themeMode == 'dark',
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      ref
                          .read(settingsProvider.notifier)
                          .setThemeMode('dark');
                      Navigator.of(modalCtx).pop();
                    },
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    child: const Column(children: [
                      Icon(Icons.nightlight_round, size: 18),
                      Text('Dark'),
                    ]),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ComicButton(
                onPressed: () => Navigator.of(modalCtx).pop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showColorSheet(
      BuildContext context, WidgetRef ref, AppSettings settings) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext modalCtx) => CupertinoActionSheet(
        title: const Text('Pick Accent Color'),
        message: Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: _colors.map((color) {
            final isSelected = color.value == settings.primaryColorValue;
            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                ref
                    .read(settingsProvider.notifier)
                    .setPrimaryColor(color.value);
                Navigator.of(modalCtx).pop();
              },
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(color: ComicTheme.surfaceWhite, width: 3)
                      : null,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                              color: color.withValues(alpha: 0.5),
                              blurRadius: 12,
                              spreadRadius: 2)
                        ]
                      : null,
                ),
                child: isSelected
                    ? const Icon(CupertinoIcons.check_mark,
                        color: ComicTheme.surfaceWhite)
                    : null,
              ),
            );
          }).toList(),
        ),
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          isDestructiveAction: true,
          onPressed: () => Navigator.of(modalCtx).pop(),
          child: const Text('Cancel'),
        ),
      ),
    );
  }
}
