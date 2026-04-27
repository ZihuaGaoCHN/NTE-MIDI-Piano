import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import '../../logic/midi_state.dart';
import '../../logic/locale_state.dart';
import '../../l10n/app_strings.dart';
import 'about_page.dart';

import 'package:flutter/cupertino.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      initialRoute: 'settings_home',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case 'settings_home':
            return CupertinoPageRoute(
              builder: (context) => _buildSettingsList(context),
              settings: settings,
            );
          case 'about':
            return CupertinoPageRoute(
              builder: (context) => AboutPage(
                onBack: () => Navigator.of(context).pop(),
              ),
              settings: settings,
            );
          default:
            return null;
        }
      },
    );
  }

  Widget _buildSettingsList(BuildContext context) {
    final midiState = context.watch<MidiState>();
    final localeState = context.watch<LocaleState>();

    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: EdgeInsets.only(top: Platform.isMacOS ? 28 : 0),
      child: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          Text(
            AppStrings.get(context, 'settings'),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                _buildSettingsItem(
                  context: context,
                  icon: Icons.language,
                  title: AppStrings.get(context, 'language'),
                  subtitle: _getLanguageName(context, localeState.selectedLanguage),
                  onTap: () => _showLanguageDialog(context, localeState),
                ),
                const Divider(height: 1),
                _buildSettingsItem(
                  context: context,
                  icon: Icons.piano,
                  title: AppStrings.get(context, 'midiInputDevice'),
                  subtitle: midiState.selectedDevice?.name ?? AppStrings.get(context, 'selectDevice'),
                  subtitleColor: midiState.selectedDevice == null ? Colors.grey : null,
                  onTap: () => _showDeviceDialog(context, midiState),
                ),
                const Divider(height: 1),
                _buildSettingsItem(
                  context: context,
                  icon: Icons.info_outline,
                  title: AppStrings.get(context, 'about'),
                  subtitle: '1.0.0',
                  onTap: () => Navigator.of(context).pushNamed('about'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    Color? subtitleColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: subtitleColor ?? Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: Theme.of(context).disabledColor.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }

  String _getLanguageName(BuildContext context, AppLanguage lang) {
    switch (lang) {
      case AppLanguage.system:
        return AppStrings.get(context, 'systemDefault');
      case AppLanguage.en:
        return 'English';
      case AppLanguage.zh:
        return '简体中文';
    }
  }

  void _showLanguageDialog(BuildContext context, LocaleState localeState) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(AppStrings.get(context, 'language')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<AppLanguage>(
                  title: Text(AppStrings.get(context, 'systemDefault')),
                  value: AppLanguage.system,
                  groupValue: localeState.selectedLanguage,
                  onChanged: (value) {
                    if (value != null) localeState.setLanguage(value);
                    Navigator.of(dialogContext).pop();
                  },
                ),
                RadioListTile<AppLanguage>(
                  title: const Text('English'),
                  value: AppLanguage.en,
                  groupValue: localeState.selectedLanguage,
                  onChanged: (value) {
                    if (value != null) localeState.setLanguage(value);
                    Navigator.of(dialogContext).pop();
                  },
                ),
                RadioListTile<AppLanguage>(
                  title: const Text('简体中文'),
                  value: AppLanguage.zh,
                  groupValue: localeState.selectedLanguage,
                  onChanged: (value) {
                    if (value != null) localeState.setLanguage(value);
                    Navigator.of(dialogContext).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeviceDialog(BuildContext context, MidiState midiState) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppStrings.get(context, 'selectDevice')),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => midiState.scanDevices(),
                tooltip: AppStrings.get(context, 'refreshDeviceList'),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: midiState.devices.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(AppStrings.get(context, 'noSignal'), textAlign: TextAlign.center),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: midiState.devices.length,
                    itemBuilder: (context, index) {
                      final device = midiState.devices[index];
                      return RadioListTile<MidiDevice>(
                        title: Text(device.name),
                        value: device,
                        groupValue: midiState.selectedDevice,
                        onChanged: (value) {
                          if (value != null) midiState.selectDevice(value);
                          Navigator.of(dialogContext).pop();
                        },
                      );
                    },
                  ),
          ),
        );
      },
    );
  }
}
