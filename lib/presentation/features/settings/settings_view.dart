import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toolbar_m3e/toolbar_m3e.dart';
import 'package:button_group_m3e/button_group_m3e.dart';
import 'package:m3e_card_list/m3e_card_list.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/services/update_service.dart';
import '../../../../data/models/app_settings.dart';
import '../../theme/theme_provider.dart';
import '../../theme/design_tokens.dart';
import '../../widgets/dashboard_card.dart';
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
      body: SafeArea(
        top: true,
        child: Column(
          children: [
            const SizedBox(height: 8),
            ToolbarM3E(
              titleText: 'Settings',
              subtitleText: 'STUDY4U',
              variant: ToolbarM3EVariant.surface,
              size: ToolbarM3ESize.large,
              safeArea: false,
            ),
            Expanded(
              child: Stack(
                children: [
                  const BlobBackground(),
                  CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(child: const SizedBox(height: 24)),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: DesignTokens.spacingLG,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionHeader(context, 'APPEARANCE'),
                              M3ECardList.of(
                                haptic: M3EHapticFeedback.medium,
                                splashColor: DesignTokens.primaryLavender
                                    .withValues(alpha: 0.3),
                                highlightColor: DesignTokens.primaryLavender
                                    .withValues(alpha: 0.15),
                                children: [
                                  _buildSettingRow(
                                    context,
                                    icon: CupertinoIcons.circle_lefthalf_fill,
                                    iconColor: DesignTokens.primaryLavender,
                                    title: 'Appearance',
                                    subtitle: _themeLabel(settings.themeMode),
                                    onTap: () =>
                                        _showThemeSheet(context, ref, settings),
                                  ),
                                  _buildSettingRow(
                                    context,
                                    icon: CupertinoIcons.paintbrush,
                                    iconColor: DesignTokens.secondaryBlue,
                                    title: 'Accent Color',
                                    subtitle:
                                        '#${settings.primaryColorValue.toRadixString(16).toUpperCase().padLeft(8, '0').substring(2)}',
                                    trailing: Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color:
                                            Color(settings.primaryColorValue),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    onTap: () =>
                                        _showColorSheet(context, ref, settings),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              _buildSectionHeader(context, 'PREFERENCES'),
                              M3ECardList.of(
                                haptic: M3EHapticFeedback.medium,
                                splashColor: DesignTokens.cardCreamAccent
                                    .withValues(alpha: 0.3),
                                highlightColor: DesignTokens.cardCreamAccent
                                    .withValues(alpha: 0.15),
                                children: [
                                  _buildSwitchRow(
                                    context,
                                    icon: CupertinoIcons.hand_raised,
                                    iconColor: DesignTokens.cardCreamAccent,
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
                                    iconColor: DesignTokens.cardPinkAccent,
                                    title: 'Notifications',
                                    subtitle:
                                        'Get reminded about classes and tasks',
                                    value: settings.notificationEnabled,
                                    onChanged: (v) {
                                      HapticFeedback.selectionClick();
                                      ref
                                          .read(settingsProvider.notifier)
                                          .setNotificationEnabled(v);
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              _buildSectionHeader(context, 'ABOUT'),
                              M3ECardList.of(
                                haptic: M3EHapticFeedback.medium,
                                splashColor: DesignTokens.cardGreenAccent
                                    .withValues(alpha: 0.3),
                                highlightColor: DesignTokens.cardGreenAccent
                                    .withValues(alpha: 0.15),
                                children: [
                                  _buildSettingRow(
                                    context,
                                    icon: CupertinoIcons.book,
                                    iconColor: DesignTokens.cardGreenAccent,
                                    title: 'stdy4u',
                                    subtitle: 'Tap for version info',
                                    trailing: FutureBuilder<PackageInfo>(
                                      future: PackageInfo.fromPlatform(),
                                      builder: (ctx, snap) {
                                        final ver =
                                            snap.data?.version ?? '1.0.0';
                                        final build =
                                            snap.data?.buildNumber ?? '1';
                                        return Text(
                                          'v$ver+$build',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: context.textTertiary,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  _buildSettingRow(
                                    context,
                                    icon: CupertinoIcons.arrow_down_circle,
                                    iconColor: DesignTokens.cardTealAccent,
                                    title: 'Check for Updates',
                                    subtitle: 'Download the latest version',
                                    onTap: () => _checkForUpdate(context),
                                  ),
                                  _buildSettingRow(
                                    context,
                                    icon: CupertinoIcons.book,
                                    iconColor: DesignTokens.primaryLavender,
                                    title: 'GitHub Repository',
                                    subtitle: 'MoHamed-B-M/study4u',
                                    onTap: () => launchUrl(Uri.parse(
                                        'https://github.com/MoHamed-B-M/study4u')),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ), // Expanded
          ], // SafeArea Column children
        ), // SafeArea Column
      ), // SafeArea
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: context.textTertiary,
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
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: context.textSecondary,
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
                color: context.textTertiary,
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
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          CupertinoSwitch(
            value: value,
            activeTrackColor: DesignTokens.primaryLavender,
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
    final selectedIndex = switch (settings.themeMode) {
      'light' => 1,
      'dark' => 2,
      _ => 0,
    };

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext modalCtx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Choose Theme',
                  style: Theme.of(modalCtx).textTheme.titleLarge,
                ),
                const SizedBox(height: 20),
                ButtonGroupM3E(
                  selection: true,
                  selectedIndex: selectedIndex,
                  type: ButtonGroupM3EType.connected,
                  size: ButtonGroupM3ESize.lg,
                  actions: [
                    ButtonGroupM3EAction(
                      label: const Text('System'),
                      icon: const Icon(Icons.brightness_auto),
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        ref
                            .read(settingsProvider.notifier)
                            .setThemeMode('system');
                        Navigator.of(modalCtx).pop();
                      },
                    ),
                    ButtonGroupM3EAction(
                      label: const Text('Light'),
                      icon: const Icon(Icons.wb_sunny),
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        ref
                            .read(settingsProvider.notifier)
                            .setThemeMode('light');
                        Navigator.of(modalCtx).pop();
                      },
                    ),
                    ButtonGroupM3EAction(
                      label: const Text('Dark'),
                      icon: const Icon(Icons.nightlight_round),
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        ref
                            .read(settingsProvider.notifier)
                            .setThemeMode('dark');
                        Navigator.of(modalCtx).pop();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.of(modalCtx).pop(),
                  child: const Text('Cancel'),
                ),
              ],
            ),
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
                      ? Border.all(color: DesignTokens.textWhite, width: 3)
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
                        color: DesignTokens.textWhite)
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
