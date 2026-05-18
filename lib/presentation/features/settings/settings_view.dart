import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    return CupertinoPageScaffold(
      backgroundColor: DesignTokens.background,
      child: Stack(
        children: [
          const BlobBackground(),
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      DesignTokens.spacingLG,
                      DesignTokens.spacingMD,
                      DesignTokens.spacingLG,
                      0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'STUDY4U',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: DesignTokens.textTertiary,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Settings',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: DesignTokens.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: const SizedBox(height: 24)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DesignTokens.spacingLG,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader('APPEARANCE'),
                        _buildSettingsCard([
                          _buildSettingRow(
                            icon: CupertinoIcons.circle_lefthalf_fill,
                            iconColor: DesignTokens.primaryLavender,
                            title: 'Appearance',
                            subtitle: _themeLabel(settings.themeMode),
                            onTap: () => _showThemeSheet(context, ref, settings),
                          ),
                          _buildDivider(),
                          _buildSettingRow(
                            icon: CupertinoIcons.paintbrush,
                            iconColor: DesignTokens.secondaryBlue,
                            title: 'Accent Color',
                            subtitle: '#${settings.primaryColorValue.toRadixString(16).toUpperCase().padLeft(8, '0').substring(2)}',
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
                        const SizedBox(height: 24),
                        _buildSectionHeader('PREFERENCES'),
                        _buildSettingsCard([
                          _buildSwitchRow(
                            icon: CupertinoIcons.hand_raised,
                            iconColor: DesignTokens.cardCreamAccent,
                            title: 'Haptic Feedback',
                            subtitle: 'Vibration on interactions',
                            value: settings.hapticFeedback,
                            onChanged: (v) {
                              HapticFeedback.selectionClick();
                              ref.read(settingsProvider.notifier).setHapticFeedback(v);
                            },
                          ),
                          _buildDivider(),
                          _buildSwitchRow(
                            icon: CupertinoIcons.bell,
                            iconColor: DesignTokens.cardPinkAccent,
                            title: 'Notifications',
                            subtitle: 'Get reminded about classes and tasks',
                            value: settings.notificationEnabled,
                            onChanged: (v) {
                              HapticFeedback.selectionClick();
                              ref.read(settingsProvider.notifier).setNotificationEnabled(v);
                            },
                          ),
                        ]),
                        const SizedBox(height: 24),
                        _buildSectionHeader('ABOUT'),
                        _buildSettingsCard([
                          _buildSettingRow(
                            icon: CupertinoIcons.book,
                            iconColor: DesignTokens.cardGreenAccent,
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
                                    color: DesignTokens.textTertiary,
                                  ),
                                );
                              },
                            ),
                          ),
                          _buildDivider(),
                          _buildSettingRow(
                            icon: CupertinoIcons.arrow_down_circle,
                            iconColor: DesignTokens.cardTealAccent,
                            title: 'Check for Updates',
                            subtitle: 'Download the latest version',
                            onTap: () => _checkForUpdate(context),
                          ),
                          _buildDivider(),
                          _buildSettingRow(
                            icon: CupertinoIcons.book,
                            iconColor: DesignTokens.primaryLavender,
                            title: 'GitHub Repository',
                            subtitle: 'MoHamed-B-M/study4u',
                            onTap: () => launchUrl(Uri.parse('https://github.com/MoHamed-B-M/study4u')),
                          ),
                        ]),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: DesignTokens.textTertiary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return DashboardCard(
      backgroundColor: DesignTokens.surface,
      borderRadius: DesignTokens.radiusLG,
      padding: EdgeInsets.zero,
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingRow({
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
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: DesignTokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: DesignTokens.textSecondary,
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
              const Icon(
                CupertinoIcons.chevron_right,
                size: 16,
                color: DesignTokens.textTertiary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchRow({
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
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: DesignTokens.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: DesignTokens.textSecondary,
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

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.only(left: 64),
      color: DesignTokens.surfaceVariant,
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

  void _showThemeSheet(BuildContext context, WidgetRef ref, AppSettings settings) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext modalCtx) => CupertinoActionSheet(
        title: const Text('Choose Theme'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              HapticFeedback.selectionClick();
              ref.read(settingsProvider.notifier).setThemeMode('system');
              Navigator.of(modalCtx).pop();
            },
            child: const Text('System Default'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              HapticFeedback.selectionClick();
              ref.read(settingsProvider.notifier).setThemeMode('light');
              Navigator.of(modalCtx).pop();
            },
            child: const Text('Light'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              HapticFeedback.selectionClick();
              ref.read(settingsProvider.notifier).setThemeMode('dark');
              Navigator.of(modalCtx).pop();
            },
            child: const Text('Dark'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          isDestructiveAction: true,
          onPressed: () => Navigator.of(modalCtx).pop(),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _showColorSheet(BuildContext context, WidgetRef ref, AppSettings settings) {
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
                ref.read(settingsProvider.notifier).setPrimaryColor(color.value);
                Navigator.of(modalCtx).pop();
              },
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: isSelected ? Border.all(color: DesignTokens.textWhite, width: 3) : null,
                  boxShadow: isSelected
                      ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 12, spreadRadius: 2)]
                      : null,
                ),
                child: isSelected ? const Icon(CupertinoIcons.check_mark, color: DesignTokens.textWhite) : null,
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
