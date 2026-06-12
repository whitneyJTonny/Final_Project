import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeService {
  static final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(
    ThemeMode.light,
  );

  static const String _boxName = 'settings';
  static const String _key = 'themeMode';

  /// LOAD THEME ON APP START
  static Future<void> init() async {
    final box = await Hive.openBox(_boxName);

    final saved = box.get(_key, defaultValue: 'light');

    themeNotifier.value = saved == 'dark' ? ThemeMode.dark : ThemeMode.light;
  }

  /// SWITCH THEME (INSTANT + SAVE)
  static Future<void> toggle(bool isDark) async {
    final box = await Hive.openBox(_boxName);

    themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;

    await box.put(_key, isDark ? 'dark' : 'light');
  }
}
