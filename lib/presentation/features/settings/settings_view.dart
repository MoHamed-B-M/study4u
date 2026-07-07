import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/services/sound_service.dart';
import '../../../core/services/update_service.dart';
import '../../../data/models/app_settings.dart';
import '../../../theme/comic_theme.dart';
import '../../../widgets/comic_card.dart';
import '../../../widgets/comic_button.dart';
import '../../../widgets/comic_loader.dart';
import '../../theme/theme_provider.dart';
import '../../widgets/update_dialog.dart';

class SettingsView extends ConsumerStatefulWidget {
  const SettingsView({super.key});

  @override
  ConsumerState<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends ConsumerState<SettingsView> {
  bool _checking = false;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Stack(
        children: [
          CustomScrollView(
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
                        icon: SolarIconsBold.moon,
                        iconColor: ComicTheme.inkRed,
                        title: 'Appearance',
                        subtitle: _themeLabel(settings.themeMode),
                        onTap: () => _showThemeSheet(context, ref, settings),
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
                        icon: SolarIconsBold.smartphoneVibration,
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
                        icon: SolarIconsBold.bell,
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
                        icon: SolarIconsBold.musicNote,
                        iconColor: ComicTheme.inkRed,
                        title: 'Press Sound',
                        subtitle: 'Play click sound on button press',
                        value: settings.pressSound,
                        onChanged: (v) {
                          HapticFeedback.selectionClick();
                          SoundService.pressSoundEnabled = v;
                          ref
                              .read(settingsProvider.notifier)
                              .setPressSound(v);
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
                        icon: SolarIconsBold.book,
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
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: ComicButton(
                          isCta: true,
                          onPressed: _checking ? null : () => _checkForUpdate(context),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.download_rounded, size: 18, color: ComicTheme.surfaceWhite),
                              SizedBox(width: 8),
                              Text('Check for Updates'),
                            ],
                          ),
                        ),
                      ),
                      _buildSettingRow(
                        context,
                        icon: SolarIconsBold.book,
                        iconColor: ComicTheme.inkRed,
                        title: 'GitHub Repository',
                        subtitle: 'MoHamed-B-M/study4u',
                        onTap: () => launchUrl(Uri.parse(
                            'https://github.com/MoHamed-B-M/study4u')),
                      ),
                      _buildSettingRow(
                        context,
                        icon: SolarIconsBold.like,
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
      if (_checking)
        Container(
          color: Colors.black54,
          child: Center(
            child: ComicLoader(size: 56),
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
      child: Stack(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDark ? ComicTheme.darkText.withValues(alpha: 0.6) : ComicTheme.inkBlack.withValues(alpha: 0.6),
              letterSpacing: 0.5,
            ),
          ),
          Positioned(
            bottom: -2,
            left: 0,
            right: 0,
            child: Container(height: 2, color: ComicTheme.inkRed),
          ),
        ],
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
                SolarIconsBold.arrowRight,
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
    setState(() => _checking = true);
    final started = DateTime.now();
    try {
      final service = UpdateService();
      final update = await service.checkForUpdate();
      final elapsed = DateTime.now().difference(started).inMilliseconds;
      if (elapsed < 1000) await Future.delayed(Duration(milliseconds: 1000 - elapsed));
      if (!context.mounted) return;

      if (update == null || !update.isNewer) {
        if (!context.mounted) return;
        _showComicAlert(
          context,
          'Update Check',
          update == null
              ? 'Could not check for updates.'
              : 'You are on the latest version!',
        );
        return;
      }

      await UpdateDialog.show(context: context, update: update);
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  void _showComicAlert(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? ComicTheme.darkPulp : ComicTheme.paperBg,
              border: Border.all(color: ComicTheme.inkBlack, width: 2.5),
              boxShadow: const [
                BoxShadow(
                  color: ComicTheme.inkBlack,
                  offset: Offset(4, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isDark ? ComicTheme.darkText : ComicTheme.inkBlack,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? ComicTheme.darkText.withValues(alpha: 0.7) : ComicTheme.inkBlack.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
                    decoration: BoxDecoration(
                      color: ComicTheme.inkRed,
                      border: Border.all(color: ComicTheme.inkBlack, width: 2.5),
                      boxShadow: const [
                        BoxShadow(
                          color: ComicTheme.inkBlack,
                          offset: Offset(4, 4),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        color: ComicTheme.surfaceWhite,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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

}
