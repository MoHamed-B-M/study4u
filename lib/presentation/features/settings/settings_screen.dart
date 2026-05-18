import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    final primaryColor = CupertinoTheme.of(context).primaryColor;

    return CupertinoPageScaffold(
      backgroundColor: CupertinoTheme.of(context).scaffoldBackgroundColor,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoTheme.of(context).scaffoldBackgroundColor,
        border: const Border(bottom: BorderSide.none),
        middle: const Text('Settings'),
      ),
      child: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(top: 20),
          children: [
            CupertinoFormSection.insetGrouped(
              header: const Text('APPEARANCE'),
              children: [
                CupertinoFormRow(
                  prefix: _buildRowIcon(CupertinoIcons.circle_lefthalf_fill, primaryColor),
                  child: CupertinoButton(
                    onPressed: () => _showThemeSheet(context, ref, settings),
                    padding: EdgeInsets.zero,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Appearance'),
                            Text(
                              _themeLabel(settings.themeMode),
                              style: TextStyle(
                                fontSize: 13,
                                color: CupertinoColors.systemGrey2,
                              ),
                            ),
                          ],
                        ),
                        const Icon(CupertinoIcons.chevron_right, size: 16, color: CupertinoColors.systemGrey3),
                      ],
                    ),
                  ),
                ),
                CupertinoFormRow(
                  prefix: _buildRowIcon(CupertinoIcons.paintbrush, primaryColor),
                  child: CupertinoButton(
                    onPressed: () => _showColorSheet(context, ref, settings),
                    padding: EdgeInsets.zero,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Accent Color'),
                            Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Color(settings.primaryColorValue),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '#${settings.primaryColorValue.toRadixString(16).toUpperCase().padLeft(8, '0').substring(2)}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: CupertinoColors.systemGrey2,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Icon(CupertinoIcons.chevron_right, size: 16, color: CupertinoColors.systemGrey3),
                      ],
                    ),
                  ),
                ),
                CupertinoFormRow(
                  prefix: _buildRowIcon(CupertinoIcons.square_stack_3d_up, primaryColor),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Floating Navigation Bar'),
                          Text(
                            'Glassmorphism style bottom nav',
                            style: TextStyle(
                              fontSize: 13,
                              color: CupertinoColors.systemGrey2,
                            ),
                          ),
                        ],
                      ),
                      CupertinoSwitch(
                        value: settings.useFloatingNavBar,
                        onChanged: (v) {
                          HapticFeedback.selectionClick();
                          ref.read(settingsProvider.notifier).setUseFloatingNavBar(v);
                        },
                      ),
                    ],
                  ),
                ),
                CupertinoFormRow(
                  prefix: _buildRowIcon(CupertinoIcons.hand_raised, primaryColor),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Haptic Feedback'),
                          Text(
                            'Vibration on interactions',
                            style: TextStyle(
                              fontSize: 13,
                              color: CupertinoColors.systemGrey2,
                            ),
                          ),
                        ],
                      ),
                      CupertinoSwitch(
                        value: settings.hapticFeedback,
                        onChanged: (v) {
                          HapticFeedback.selectionClick();
                          ref.read(settingsProvider.notifier).setHapticFeedback(v);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            CupertinoFormSection.insetGrouped(
              header: const Text('NOTIFICATIONS'),
              children: [
                CupertinoFormRow(
                  prefix: _buildRowIcon(CupertinoIcons.bell, primaryColor),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Notifications'),
                          Text(
                            'Get reminded about classes and tasks',
                            style: TextStyle(
                              fontSize: 13,
                              color: CupertinoColors.systemGrey2,
                            ),
                          ),
                        ],
                      ),
                      CupertinoSwitch(
                        value: settings.notificationEnabled,
                        onChanged: (v) {
                          HapticFeedback.selectionClick();
                          ref.read(settingsProvider.notifier).setNotificationEnabled(v);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            CupertinoFormSection.insetGrouped(
              header: const Text('ABOUT'),
              children: [
                CupertinoFormRow(
                  prefix: _buildRowIcon(CupertinoIcons.book, primaryColor),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('stdy4u'),
                      FutureBuilder<PackageInfo>(
                        future: PackageInfo.fromPlatform(),
                        builder: (ctx, snap) {
                          final ver = snap.data?.version ?? '1.0.0';
                          final build = snap.data?.buildNumber ?? '1';
                          return Text(
                            'Version $ver+$build',
                            style: TextStyle(
                              fontSize: 13,
                              color: CupertinoColors.systemGrey2,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                CupertinoFormRow(
                  prefix: _buildRowIcon(CupertinoIcons.arrow_down_circle, primaryColor),
                  child: CupertinoButton(
                    onPressed: () => _checkForUpdate(context),
                    padding: EdgeInsets.zero,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Check for Updates'),
                            Text(
                              'Download the latest version',
                              style: TextStyle(
                                fontSize: 13,
                                color: CupertinoColors.systemGrey2,
                              ),
                            ),
                          ],
                        ),
                        const Icon(CupertinoIcons.chevron_right, size: 16, color: CupertinoColors.systemGrey3),
                      ],
                    ),
                  ),
                ),
                CupertinoFormRow(
                  prefix: _buildRowIcon(CupertinoIcons.book, primaryColor),
                  child: CupertinoButton(
                    onPressed: () => launchUrl(Uri.parse('https://github.com/MoHamed-B-M/study4u')),
                    padding: EdgeInsets.zero,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('GitHub Repository'),
                            Text(
                              'MoHamed-B-M/study4u',
                              style: TextStyle(
                                fontSize: 13,
                                color: CupertinoColors.systemGrey2,
                              ),
                            ),
                          ],
                        ),
                        const Icon(CupertinoIcons.arrow_up_right, size: 16, color: CupertinoColors.systemGrey3),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildRowIcon(IconData icon, Color tint) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: tint.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(icon, size: 16, color: tint),
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

    if (update == null) {
      showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text('Update Check'),
          content: const Text('Could not check for updates. Check your connection.'),
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

    if (!update.isNewer) {
      showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text('Update Check'),
          content: const Text('You are on the latest version!'),
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
    showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoActionSheet(
        title: const Text('Choose Theme'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              HapticFeedback.selectionClick();
              ref.read(settingsProvider.notifier).setThemeMode('system');
              Navigator.of(context).pop();
            },
            child: const Text('System Default'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              HapticFeedback.selectionClick();
              ref.read(settingsProvider.notifier).setThemeMode('light');
              Navigator.of(context).pop();
            },
            child: const Text('Light'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              HapticFeedback.selectionClick();
              ref.read(settingsProvider.notifier).setThemeMode('dark');
              Navigator.of(context).pop();
            },
            child: const Text('Dark'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _showColorSheet(BuildContext context, WidgetRef ref, AppSettings settings) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoActionSheet(
        title: const Text('Pick Accent Color'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {},
            child: Wrap(
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
                      border: isSelected ? Border.all(color: CupertinoColors.white, width: 3) : null,
                      boxShadow: isSelected
                          ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 12, spreadRadius: 2)]
                          : null,
                    ),
                    child: isSelected ? const Icon(CupertinoIcons.check_mark, color: CupertinoColors.white) : null,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ),
    );
  }
}
