import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../providers/locale_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final localeNotifier = ref.read(localeProvider.notifier);
    final currentLocale = ref.watch(localeProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          _buildSection(
            title: 'Preferences',
            children: [
              _buildLanguageTile(
                l10n: l10n,
                currentLocale: currentLocale,
                onLanguageChanged: (languageCode) {
                  localeNotifier.changeLocale(languageCode);
                },
              ),
              _buildThemeTile(l10n: l10n),
            ],
          ),
          SizedBox(height: 24.h),
          _buildSection(
            title: 'About',
            children: [
              _buildVersionTile(l10n: l10n),
              _buildPrivacyTile(l10n: l10n),
              _buildTermsTile(l10n: l10n),
            ],
          ),
          SizedBox(height: 24.h),
          _buildSection(
            title: 'Storage',
            children: [
              _buildCacheTile(l10n: l10n),
              _buildDataTile(l10n: l10n),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 12.h),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageTile({
    required AppLocalizations l10n,
    required Locale currentLocale,
    required Function(String) onLanguageChanged,
  }) {
    return ListTile(
      leading: const Icon(Icons.language),
      title: Text(l10n.language),
      subtitle: Text(currentLocale.languageCode == 'en' ? 'English' : 'Русский'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        _showLanguageDialog(
          context: context,
          l10n: l10n,
          currentLanguage: currentLocale.languageCode,
          onLanguageChanged: onLanguageChanged,
        );
      },
    );
  }

  Widget _buildThemeTile({required AppLocalizations l10n}) {
    return ListTile(
      leading: const Icon(Icons.palette),
      title: Text(l10n.theme),
      subtitle: const Text('System'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Theme selection coming soon')),
        );
      },
    );
  }

  Widget _buildVersionTile({required AppLocalizations l10n}) {
    return ListTile(
      leading: const Icon(Icons.info),
      title: Text(l10n.version),
      subtitle: const Text('1.0.0'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Version info coming soon')),
        );
      },
    );
  }

  Widget _buildPrivacyTile({required AppLocalizations l10n}) {
    return ListTile(
      leading: const Icon(Icons.privacy_tip),
      title: Text(l10n.privacy),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Privacy policy coming soon')),
        );
      },
    );
  }

  Widget _buildTermsTile({required AppLocalizations l10n}) {
    return ListTile(
      leading: const Icon(Icons.description),
      title: Text(l10n.terms),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Terms of service coming soon')),
        );
      },
    );
  }

  Widget _buildCacheTile({required AppLocalizations l10n}) {
    return ListTile(
      leading: const Icon(Icons.cleaning_services),
      title: const Text('Clear Cache'),
      subtitle: const Text('Free up storage space'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cache clearing coming soon')),
        );
      },
    );
  }

  Widget _buildDataTile({required AppLocalizations l10n}) {
    return ListTile(
      leading: const Icon(Icons.storage),
      title: const Text('Data Usage'),
      subtitle: const Text('Manage mobile data'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data usage settings coming soon')),
        );
      },
    );
  }

  void _showLanguageDialog({
    required BuildContext context,
    required AppLocalizations l10n,
    required String currentLanguage,
    required Function(String) onLanguageChanged,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.language),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: currentLanguage,
              onChanged: (value) {
                if (value != null) {
                  onLanguageChanged(value);
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('Русский'),
              value: 'ru',
              groupValue: currentLanguage,
              onChanged: (value) {
                if (value != null) {
                  onLanguageChanged(value);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
