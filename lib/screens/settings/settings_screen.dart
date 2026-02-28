import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/loans_provider.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _getThemeLabel(ThemeModeEnum mode, AppLocalizations l10n) {
    switch (mode) {
      case ThemeModeEnum.system:
        return l10n.system;
      case ThemeModeEnum.light:
        return l10n.light;
      case ThemeModeEnum.dark:
        return l10n.dark;
    }
  }

  String _getLocaleLabel(String code, AppLocalizations l10n) {
    switch (code) {
      case 'ar':
        return l10n.arabic;
      case 'fr':
        return l10n.french;
      default:
        return code;
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final auth = context.watch<AuthProvider>();
    final l10n = AppLocalizations.of(context)!;
    final localeLabel = _getLocaleLabel(settings.locale, l10n);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          // User Profile
          _SettingsCard(
            children: [
              ListTile(
                leading: CircleAvatar(
                  radius: 28.r,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                  child: Text(
                    (auth.currentUser?.fullName ??
                            auth.currentUser?.username ??
                            'G')
                        .substring(0, 1)
                        .toUpperCase(),
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 22.sp,
                    ),
                  ),
                ),
                title: Text(
                  auth.currentUser?.fullName ??
                      auth.currentUser?.username ??
                      l10n.guestUser,
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
                ),
                subtitle: Text(
                    auth.isGuest
                        ? l10n.betaVersion
                        : '${l10n.adminUser} • ${auth.currentUser?.country ?? ""}',
                    style: TextStyle(fontSize: 13.sp)),
                trailing: auth.isGuest
                    ? null
                    : TextButton.icon(
                        onPressed: () => _changePassword(context, l10n),
                        icon: Icon(Icons.lock_outline, size: 18.sp),
                        label: Text(l10n.changePassword,
                            style: TextStyle(fontSize: 13.sp)),
                      ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          _SectionLabel(label: l10n.theme),
          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.dark_mode_rounded,
                title: l10n.theme,
                subtitle: _getThemeLabel(settings.themeMode, l10n),
                trailing: DropdownButton<ThemeModeEnum>(
                  value: settings.themeMode,
                  underline: const SizedBox(),
                  items: [
                    DropdownMenuItem(
                      value: ThemeModeEnum.system,
                      child: Text(l10n.system),
                    ),
                    DropdownMenuItem(
                      value: ThemeModeEnum.light,
                      child: Text(l10n.light),
                    ),
                    DropdownMenuItem(
                      value: ThemeModeEnum.dark,
                      child: Text(l10n.dark),
                    ),
                  ],
                  onChanged: (v) => settings.setThemeMode(v!),
                ),
              ),
              const Divider(height: 1),
              _SettingsTile(
                icon: Icons.language_rounded,
                title: l10n.language,
                subtitle: localeLabel,
                onTap: () => _showLanguageDialog(context, settings, l10n),
              ),
            ],
          ),

          const SizedBox(height: 16),
          _SectionLabel(label: l10n.profit),
          _SettingsCard(
            children: [
              Padding(
                padding: EdgeInsets.all(16.w),
                child: _DefaultProfitSettings(settings: settings),
              ),
            ],
          ),

          const SizedBox(height: 16),
          _SectionLabel(label: l10n.security),
          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.pin_outlined,
                title: l10n.pinLock,
                subtitle: settings.pinEnabled ? l10n.enabled : l10n.disabled,
                trailing: Switch(
                  value: settings.pinEnabled,
                  activeThumbColor: AppColors.primary,
                  onChanged: (v) {
                    if (v) {
                      _setupPin(context, settings, l10n);
                    } else {
                      settings.setPin('', false);
                    }
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          _SectionLabel(label: l10n.aboutApp),
          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.info_outline_rounded,
                title: l10n.version,
                subtitle: AppConstants.appVersion,
              ),
              const Divider(height: 1),
              _SettingsTile(
                icon: Icons.description_outlined,
                title: l10n.aboutApp,
                subtitle: '${l10n.appName} - ${l10n.appDescription}',
              ),
            ],
          ),

          const SizedBox(height: 24),
          // Logout
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
              ),
              onPressed: () => _logout(context, auth, l10n),
              icon: Icon(Icons.logout_rounded, size: 20.sp),
              label: Text(l10n.logout, style: TextStyle(fontSize: 16.sp)),
            ),
          ),

          const SizedBox(height: 32),
          // Developer Info
          Center(
            child: Column(
              children: [
                Text(
                  l10n.developedBy,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12.sp,
                    fontFamily: 'Cairo',
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Elmehdi Deda Salihi',
                  style: TextStyle(
                    color: AppColors.primary.withValues(alpha: 0.7),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Future<void> _logout(
      BuildContext context, AuthProvider auth, AppLocalizations l10n) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.logout),
        content: Text(l10n.confirmLogout),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(l10n.logout),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      // Clear loans data to avoid stale data visibility
      context.read<LoansProvider>().clearData();
      await auth.logout();
      // Root navigation is handled reactively by DeInakApp in main.dart
    }
  }

  Future<void> _changePassword(
      BuildContext context, AppLocalizations l10n) async {
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.changePassword),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldCtrl,
              obscureText: true,
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(labelText: l10n.currentPassword),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newCtrl,
              obscureText: true,
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(labelText: l10n.newPassword),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmCtrl,
              obscureText: true,
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(labelText: l10n.confirmPassword),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newCtrl.text != confirmCtrl.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.passwordsNotMatch)),
                );
                return;
              }
              final auth = context.read<AuthProvider>();
              final success =
                  await auth.changePassword(oldCtrl.text, newCtrl.text);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? l10n.settingsSaved
                        : (auth.errorMessage ?? l10n.settingsSaved)),
                    backgroundColor:
                        success ? AppColors.success : AppColors.error,
                  ),
                );
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(
      BuildContext context, SettingsProvider settings, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(l10n.chooseLanguage),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Text('🇲🇷', style: TextStyle(fontSize: 24.sp)),
                title: Text(l10n.arabic),
                trailing: settings.locale == 'ar'
                    ? const Icon(Icons.check_rounded, color: AppColors.primary)
                    : null,
                onTap: () {
                  settings.setLocale('ar');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Text('🇫🇷', style: TextStyle(fontSize: 24.sp)),
                title: Text(l10n.french),
                trailing: settings.locale == 'fr'
                    ? const Icon(Icons.check_rounded, color: AppColors.primary)
                    : null,
                onTap: () {
                  settings.setLocale('fr');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _setupPin(BuildContext context, SettingsProvider settings,
      AppLocalizations l10n) async {
    final pinCtrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(l10n.setupPin),
          content: TextField(
            controller: pinCtrl,
            keyboardType: TextInputType.number,
            maxLength: 6,
            obscureText: true,
            decoration: InputDecoration(
              labelText: '${l10n.enterPin} ${l10n.pinLengthHint}',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                if (pinCtrl.text.length >= 4) {
                  settings.setPin(pinCtrl.text, true);
                  Navigator.pop(context);
                }
              },
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );
  }
}

class _DefaultProfitSettings extends StatefulWidget {
  final SettingsProvider settings;
  const _DefaultProfitSettings({required this.settings});

  @override
  State<_DefaultProfitSettings> createState() => _DefaultProfitSettingsState();
}

class _DefaultProfitSettingsState extends State<_DefaultProfitSettings> {
  late TextEditingController _ctrl;
  late String _type;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
        text: widget.settings.defaultProfitValue.toString());
    _type = widget.settings.defaultProfitType;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ChoiceChip(
              label: Text(l10n.profitPercentage),
              selected: _type == AppConstants.profitTypePercentage,
              onSelected: (_) =>
                  setState(() => _type = AppConstants.profitTypePercentage),
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: Text(l10n.fixedAmount),
              selected: _type == AppConstants.profitTypeFixed,
              onSelected: (_) =>
                  setState(() => _type = AppConstants.profitTypeFixed),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                keyboardType: TextInputType.number,
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  labelText: _type == AppConstants.profitTypePercentage
                      ? l10n.defaultProfitPercentage
                      : l10n.defaultProfitAmount,
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () {
                final val = double.tryParse(_ctrl.text) ?? 10.0;
                widget.settings.setDefaultProfit(val, _type);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.settingsSaved),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              child: Text(l10n.save),
            ),
          ],
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1E293B)
            : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10.r,
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 24.sp),
      title: Text(title,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp)),
      subtitle: subtitle != null
          ? Text(subtitle!, style: TextStyle(fontSize: 12.sp))
          : null,
      trailing: trailing,
      onTap: onTap,
    );
  }
}
