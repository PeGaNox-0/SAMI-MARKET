import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omar_app/l10n/generated/app_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/sync_service.dart';
import '../../../data/datasources/local/app_database.dart';
import '../../../data/repositories/auth_repository.dart';

/// Language provider
final localeProvider = StateProvider<Locale>((ref) => const Locale('ar'));

/// Theme mode provider
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);
    final currentTheme = ref.watch(themeModeProvider);
    final syncCountAsync = ref.watch(pendingSyncCountProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Language
          Card(
            child: ListTile(
              leading: FaIcon(FontAwesomeIcons.language, size: 20),
              title: Text(l10n.language),
              subtitle: Text(
                currentLocale.languageCode == 'ar' ? l10n.arabic : l10n.english,
              ),
              trailing: FaIcon(FontAwesomeIcons.angleLeft, size: 20),
              onTap: () =>
                  _showLanguageDialog(context, ref, l10n, currentLocale),
            ),
          ),
          const SizedBox(height: 8),

          // Theme
          Card(
            child: ListTile(
              leading: FaIcon(FontAwesomeIcons.palette, size: 20),
              title: Text(l10n.theme),
              subtitle: Text(_getThemeName(currentTheme, l10n)),
              trailing: FaIcon(FontAwesomeIcons.angleLeft, size: 20),
              onTap: () => _showThemeDialog(context, ref, l10n, currentTheme),
            ),
          ),
          const SizedBox(height: 8),

          // Sync status
          Card(
            child: ListTile(
              leading: FaIcon(FontAwesomeIcons.arrowsRotate, size: 20),
              title: Text(l10n.syncPending),
              subtitle: syncCountAsync.when(
                data: (count) => Text(
                  count > 0 ? '$count ${l10n.syncPending}' : l10n.syncComplete,
                ),
                loading: () => Text(l10n.loading),
                error: (err, stack) => Text(l10n.error),
              ),
              trailing: IconButton(
                icon: const FaIcon(FontAwesomeIcons.rotateRight, size: 18),
                onPressed: () async {
                  final user = ref.read(currentUserProvider);
                  final syncService = ref.read(syncServiceProvider);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('جاري المزامنة الشاملة مع السحابة...'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  await syncService.syncPendingChanges();
                  if (user != null) {
                    await syncService.pullFromCloud(user.id);
                  }
                  ref.invalidate(pendingSyncCountProvider);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('اكتملت المزامنة بنجاح!'),
                        backgroundColor: AppColors.payment,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Backup
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: FaIcon(FontAwesomeIcons.download, size: 20),
                  title: Text(l10n.createBackup),
                  onTap: () => _createBackup(context, ref, l10n),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: FaIcon(FontAwesomeIcons.upload, size: 20),
                  title: Text(l10n.restoreBackup),
                  onTap: () => _restoreBackup(context, ref, l10n),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Account
          Card(
            child: ListTile(
              leading: FaIcon(FontAwesomeIcons.user, size: 20),
              title: Text(l10n.accountInfo),
              subtitle: Text(
                ref.read(authRepositoryProvider).currentUser?.email ?? '',
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Logout
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                await ref.read(authRepositoryProvider).signOut();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.debt,
                side: const BorderSide(color: AppColors.debt),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: FaIcon(FontAwesomeIcons.arrowRightFromBracket, size: 18),
              label: Text(l10n.logout),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    Locale currentLocale,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.language),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.arabic),
              trailing: currentLocale.languageCode == 'ar'
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                ref.read(localeProvider.notifier).state = const Locale('ar');
                Navigator.of(ctx).pop();
              },
            ),
            ListTile(
              title: Text(l10n.english),
              trailing: currentLocale.languageCode == 'en'
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                ref.read(localeProvider.notifier).state = const Locale('en');
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    ThemeMode currentTheme,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.theme),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.lightMode),
              trailing: currentTheme == ThemeMode.light
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                ref.read(themeModeProvider.notifier).state = ThemeMode.light;
                Navigator.of(ctx).pop();
              },
            ),
            ListTile(
              title: Text(l10n.darkMode),
              trailing: currentTheme == ThemeMode.dark
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                ref.read(themeModeProvider.notifier).state = ThemeMode.dark;
                Navigator.of(ctx).pop();
              },
            ),
            ListTile(
              title: Text(l10n.systemMode),
              trailing: currentTheme == ThemeMode.system
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                ref.read(themeModeProvider.notifier).state = ThemeMode.system;
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getThemeName(ThemeMode mode, AppLocalizations l10n) {
    switch (mode) {
      case ThemeMode.light:
        return l10n.lightMode;
      case ThemeMode.dark:
        return l10n.darkMode;
      case ThemeMode.system:
        return l10n.systemMode;
    }
  }

  Future<void> _createBackup(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    try {
      final user = ref.read(currentUserProvider);
      if (user == null) return;

      final db = ref.read(appDatabaseProvider);
      final data = await db.exportAllData(user.id);
      final jsonStr = const JsonEncoder.withIndent('  ').convert(data);

      final dir = await getApplicationDocumentsDirectory();
      final file = File(
        '${dir.path}/omar_app_backup_${DateTime.now().millisecondsSinceEpoch}.json',
      );
      await file.writeAsString(jsonStr);

      await Share.shareXFiles([XFile(file.path)], text: 'Omar App Backup');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.backupCreated),
            backgroundColor: AppColors.payment,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.error)));
      }
    }
  }

  Future<void> _restoreBackup(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.single.path == null) return;

      if (!context.mounted) return;

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.restoreBackup),
          content: Text(l10n.restoreConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(l10n.confirm),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      // Read and parse backup file
      final file = File(result.files.single.path!);
      final jsonStr = await file.readAsString();
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;

      // Validate structure
      if (!data.containsKey('customers') || !data.containsKey('transactions')) {
        throw Exception('Invalid backup file');
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.restoreSuccess),
            backgroundColor: AppColors.payment,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.error)));
      }
    }
  }
}
