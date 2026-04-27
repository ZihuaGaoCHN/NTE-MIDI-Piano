import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/midi_state.dart';
import '../../l10n/app_strings.dart';
import '../../keyboard_sim/keyboard_injector.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _checkPermissionAndToggle(BuildContext context, MidiState state, bool value) {
    if (value && Platform.isMacOS) {
      final hasPermission = MacOsKeyboardInjector.checkAccessibilityPermission();
      if (!hasPermission) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppStrings.get(context, 'permissionTitle')),
            content: Text(AppStrings.get(context, 'permissionMessage')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppStrings.get(context, 'cancel')),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  MacOsKeyboardInjector.openAccessibilitySettings();
                },
                child: Text(AppStrings.get(context, 'openSettings')),
              ),
            ],
          ),
        );
        return;
      }
    }
    state.toggleMapping(value);
  }

  @override
  Widget build(BuildContext context) {
    final midiState = context.watch<MidiState>();
    final isDeviceSelected = midiState.selectedDevice != null;

    return Container(
      padding: EdgeInsets.only(top: Platform.isMacOS ? 28 : 0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isDeviceSelected)
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Text(
                  AppStrings.get(context, 'pleaseSelectDevice'),
                  style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                ),
              ),
            Text(
              AppStrings.get(context, 'mappingStatus'),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Transform.scale(
              scale: 2.0,
              child: Switch(
                value: midiState.isMappingEnabled,
                onChanged: isDeviceSelected
                    ? (value) => _checkPermissionAndToggle(context, midiState, value)
                    : null,
                activeColor: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 48),
            Text(
              AppStrings.get(context, 'pressedNotes'),
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              alignment: WrapAlignment.center,
              children: midiState.pressedNotes.isEmpty
                  ? [Text(AppStrings.get(context, 'none'), style: const TextStyle(color: Colors.grey))]
                  : midiState.pressedNotes.map((note) {
                      return Chip(
                        label: Text('Note $note'),
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      );
                    }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
