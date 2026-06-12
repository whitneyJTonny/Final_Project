import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'utils/app_colors.dart';
import 'screens/splash_screen.dart';

// ─────────────────────────────
// GLOBAL NOTIFIERS (UNCHANGED)
// ─────────────────────────────
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final ValueNotifier<bool> isGuestNotifier = ValueNotifier(true);

final ValueNotifier<String> userNameNotifier = ValueNotifier('User');

final ValueNotifier<String> userEmailNotifier = ValueNotifier('');

final ValueNotifier<String> userBioNotifier = ValueNotifier(
  'Passionate about bringing clean energy to rural Africa.',
);

final ValueNotifier<String?> userImagePathNotifier = ValueNotifier<String?>(
  null,
);

final ValueNotifier<String?> userPhotoNotifier = ValueNotifier<String?>(null);

/// ─────────────────────────────
/// THEME STORAGE KEYS
/// ─────────────────────────────
const String _settingsBox = 'settings';
const String _themeKey = 'theme_mode';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  final offlineKitsBox = await Hive.openBox('offline_kits');
  if (offlineKitsBox.isEmpty) {
    await offlineKitsBox.putAll({
      'KIT-538913': {
        'kitId': 'KIT-538913',
        'date': '2026-05-25',
        'amount': 'Ush. 230,000',
        'impact': 'Powers 1 Home',
        'status': 'ACTIVE',
      },
      'KIT-229041': {
        'kitId': 'KIT-229041',
        'date': '2026-04-10',
        'amount': 'Ush. 1,150,000',
        'impact': 'Powers 5 Homes',
        'status': 'ACTIVE',
      },
    });
  }

  // ───── LOAD THEME FROM HIVE ─────
  final settings = await Hive.openBox(_settingsBox);
  final savedTheme = settings.get(_themeKey, defaultValue: 'light');

  themeNotifier.value = savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;

  try {
    final profileBox = await Hive.openBox('user_profile');

    final savedName = profileBox.get('name');
    final savedEmail = profileBox.get('email');

    if (savedName != null && savedName.toString().isNotEmpty) {
      isGuestNotifier.value = false;
      userNameNotifier.value = savedName.toString();
      userEmailNotifier.value = savedEmail?.toString() ?? '';

      userBioNotifier.value =
          profileBox.get(
                'bio',
                defaultValue:
                    'Passionate about bringing clean energy to rural Africa.',
              )
              as String;

      userImagePathNotifier.value = profileBox.get('image_path');
      userPhotoNotifier.value = profileBox.get('image_path');
    }
  } catch (e) {
    debugPrint('Hive init error: $e');
  }

  runApp(const SolarApp());
}

class SolarApp extends StatelessWidget {
  const SolarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'Solar M7',

          themeMode: mode,

          // ☀️ LIGHT THEME
          theme: ThemeData(
            brightness: Brightness.light,
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFFF5F5F5),
            primaryColor: AppColors.primaryYellow,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primaryYellow,
              brightness: Brightness.light,
            ),
            textTheme: GoogleFonts.interTextTheme(),
          ),

          // 🌙 DARK THEME
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFF121212),
            primaryColor: AppColors.primaryYellow,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primaryYellow,
              brightness: Brightness.dark,
            ),
            textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
          ),

          home: const SplashScreen(),
        );
      },
    );
  }
}
