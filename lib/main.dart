import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'utils/app_colors.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'screens/monitoring_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/maintenance_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const SolarM7App());
}

class SolarM7App extends StatelessWidget {
  const SolarM7App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Solar M7',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primaryYellow,
        scaffoldBackgroundColor: AppColors.bgLight,
        fontFamily: 'DMSans',
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryYellow,
          primary: AppColors.primaryYellow,
          secondary: AppColors.secondaryOrange,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: AppColors.bgLight,
          iconTheme: IconThemeData(color: AppColors.primaryDark),
          titleTextStyle: TextStyle(
            color: AppColors.primaryDark,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/home': (context) => const HomeScreen(),
        '/monitoring': (context) => const MonitoringScreen(),
        '/analytics': (context) => const AnalyticsScreen(),
        '/maintenance': (context) => const MaintenanceScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}