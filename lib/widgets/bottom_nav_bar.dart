import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
// IMPORT ALL SCREENS HERE
import '../screens/home_screen.dart';
import '../screens/monitoring_screen.dart';
import '../screens/analytics_screen.dart';
import '../screens/settings_screen.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          // If user taps the current tab, do nothing
          if (index == currentIndex) return;

          Widget targetScreen;

          // SELECT THE SCREEN BASED ON INDEX
          switch (index) {
            case 0:
              targetScreen = const HomeScreen();
              break;
            case 1:
              targetScreen = const MonitoringScreen();
              break;
            case 2:
              targetScreen = const AnalyticsScreen();
              break;
            case 3:
              targetScreen = const SettingsScreen();
              break;
            default:
              targetScreen = const HomeScreen();
          }

          // NAVIGATE DIRECTLY TO THE SCREEN
          // pushAndRemoveUntil clears the back stack so the Back button closes the app
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => targetScreen),
            (route) => false,
          );
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        indicatorColor: AppColors.primaryYellow.withValues(alpha: 0.2),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.monitor_heart_outlined),
            selectedIcon: Icon(Icons.monitor_heart),
            label: 'Monitor',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}