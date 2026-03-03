import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/database_providers.dart';
import '../../services/export_service.dart';
import '../../theme/app_theme.dart';
import '../../providers/session_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _exporting = false;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SETTINGS',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.teal,
                      letterSpacing: 3,
                    ),
              ),
              const SizedBox(height: 4),
              Text('Preferences',
                  style: Theme.of(context).textTheme.headlineLarge),

              const SizedBox(height: 32),

              // ── Licence ──────────────────────────────────────────────────
              _SettingsSection(title: 'LICENCE'),
              _SettingsTile(
                icon: Icons.stars_outlined,
                label: 'Status',
                trailing: Text(
                  'FREE',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.warning,
                      ),
                ),
              ),
              _SettingsTile(
                icon: Icons.upgrade_outlined,
                label: 'Upgrade to NeuroLoad Pro',
                trailing: const Icon(Icons.chevron_right,
                    color: AppColors.textTertiary),
                onTap: () {},
              ),

              const SizedBox(height: 24),

              // ── Privacy & Data ────────────────────────────────────────────
              _SettingsSection(title: 'PRIVACY & DATA'),
              _SettingsToggle(
                icon: Icons.sync_outlined,
                label: 'Cloud Sync',
                subtitle: 'Requires Pro licence',
                value: settings.cloudSyncEnabled,
                onChanged: (v) =>
                    ref.read(settingsProvider.notifier).toggleCloudSync(),
              ),
              _SettingsToggle(
                icon: Icons.note_alt_outlined,
                label: 'Local-Only Notes',
                subtitle: 'Never sync lap notes to cloud',
                value: settings.localOnlyNotes,
                onChanged: (v) =>
                    ref.read(settingsProvider.notifier).toggleLocalOnlyNotes(),
              ),
              _SettingsTile(
                icon: Icons.download_outlined,
                label: 'Export Data',
                subtitle: 'Download sessions.csv & laps.csv',
                trailing: _exporting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.teal,
                        ),
                      )
                    : const Icon(Icons.chevron_right,
                        color: AppColors.textTertiary),
                onTap: _exporting ? null : _triggerExport,
              ),

              const SizedBox(height: 24),

              // ── Accessibility ─────────────────────────────────────────────
              _SettingsSection(title: 'ACCESSIBILITY'),
              _SettingsToggle(
                icon: Icons.contrast_outlined,
                label: 'High-Contrast Mode',
                subtitle: 'WCAG 7:1 contrast ratio',
                value: settings.highContrast,
                onChanged: (v) =>
                    ref.read(settingsProvider.notifier).toggleHighContrast(),
              ),
              _SettingsTile(
                icon: Icons.text_fields_outlined,
                label: 'Font',
                subtitle: settings.fontFamily,
                trailing: const Icon(Icons.chevron_right,
                    color: AppColors.textTertiary),
                onTap: () {},
              ),

              const SizedBox(height: 24),

              // ── About ─────────────────────────────────────────────────────
              _SettingsSection(title: 'ABOUT'),
              _SettingsTile(
                icon: Icons.policy_outlined,
                label: 'Privacy Policy',
                trailing: const Icon(Icons.open_in_new,
                    size: 14, color: AppColors.textTertiary),
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.article_outlined,
                label: 'Terms of Service',
                trailing: const Icon(Icons.open_in_new,
                    size: 14, color: AppColors.textTertiary),
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.accessibility_new_outlined,
                label: 'Accessibility Statement',
                trailing: const Icon(Icons.chevron_right,
                    color: AppColors.textTertiary),
                onTap: () {},
              ),

              const SizedBox(height: 32),

              // ── DANGER ZONE ───────────────────────────────────────────────
              _SettingsSection(
                  title: 'DANGER ZONE', labelColor: AppColors.danger),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.dangerDim.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.danger.withValues(alpha: 0.3),
                      width: 0.5),
                ),
                child: _SettingsTile(
                  icon: Icons.delete_forever_outlined,
                  label: 'Wipe All Data',
                  subtitle: 'Irreversibly deletes all local data',
                  iconColor: AppColors.danger,
                  labelColor: AppColors.danger,
                  trailing:
                      const Icon(Icons.chevron_right, color: AppColors.danger),
                  onTap: () => _confirmWipe(context),
                ),
              ),

              const SizedBox(height: 32),
              Center(
                child: Text(
                  'NeuroLoad v1.0.0',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Export ────────────────────────────────────────────────────────────────

  Future<void> _triggerExport() async {
    setState(() => _exporting = true);
    try {
      final sessionDao = ref.read(sessionDaoProvider);
      final lapDao = ref.read(lapDaoProvider);
      final sessions = await sessionDao.allCompleted();
      final laps = await lapDao.allLaps();
      await ExportService.exportAllData(
        sessions: sessions,
        laps: laps,
        sharePositionOrigin: '',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Export failed. Please try again.'),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  // ── Wipe ──────────────────────────────────────────────────────────────────

  void _confirmWipe(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Wipe All Data?'),
        content: const Text(
          'This permanently deletes all sessions, laps, and settings. '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _executeWipe();
            },
            child:
                const Text('WIPE', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }

  Future<void> _executeWipe() async {
    try {
      // 1. Wipe DB — laps first (foreign key dependency on sessions)
      final lapDao = ref.read(lapDaoProvider);
      final sessionDao = ref.read(sessionDaoProvider);
      await lapDao.deleteAll();
      await sessionDao.deleteAll();

      // 2. Clear SharedPreferences (onboarding flag etc.)
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // 3. Reset in-memory session state
      ref.read(sessionProvider.notifier).resetSession();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All data wiped successfully.'),
            backgroundColor: AppColors.teal,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Wipe failed. Please try again.'),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

// ─── Widgets ─────────────────────────────────────────────────────────────────

class _SettingsSection extends StatelessWidget {
  final String title;
  final Color? labelColor;

  const _SettingsSection({required this.title, this.labelColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: labelColor ?? AppColors.textTertiary,
              letterSpacing: 2,
            ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? labelColor;

  const _SettingsTile({
    required this.icon,
    required this.label,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 20, color: iconColor ?? AppColors.silverGray),
      title: Text(
        label,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: labelColor ?? AppColors.textPrimary,
            ),
      ),
      subtitle: subtitle != null
          ? Text(subtitle!, style: Theme.of(context).textTheme.bodySmall)
          : null,
      trailing: trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      minLeadingWidth: 28,
    );
  }
}

class _SettingsToggle extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsToggle({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _SettingsTile(
      icon: icon,
      label: label,
      subtitle: subtitle,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.teal,
      ),
    );
  }
}
