import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage { system, en, zh }

class LocaleState extends ChangeNotifier {
  static const String _langPrefKey = 'app_language_pref';
  AppLanguage _selectedLanguage = AppLanguage.system;
  
  AppLanguage get selectedLanguage => _selectedLanguage;

  LocaleState() {
    _loadPreference();
  }

  static LocaleState of(BuildContext context, {bool listen = true}) {
    return Provider.of<LocaleState>(context, listen: listen);
  }

  Future<void> _loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final String? langStr = prefs.getString(_langPrefKey);
    if (langStr != null) {
      _selectedLanguage = AppLanguage.values.firstWhere(
        (e) => e.toString() == langStr,
        orElse: () => AppLanguage.system,
      );
      notifyListeners();
    }
  }

  Future<void> setLanguage(AppLanguage language) async {
    _selectedLanguage = language;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_langPrefKey, language.toString());
  }

  String get currentLanguageCode {
    if (_selectedLanguage == AppLanguage.zh) return 'zh';
    if (_selectedLanguage == AppLanguage.en) return 'en';
    
    // System default logic
    final sysLang = PlatformDispatcher.instance.locale.languageCode;
    if (sysLang.startsWith('zh')) {
      return 'zh';
    }
    return 'en';
  }
}
