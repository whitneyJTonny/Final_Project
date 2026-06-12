import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../main.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'system_details_screen.dart';
import '../widgets/bottom_nav_bar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool systemAlertsEnabled = true;
  bool lowBatteryWarningsEnabled = true;
  bool maintenanceRemindersEnabled = true;

  /// Toggles the global theme notifier and persists the choice to Hive.
  /// This does NOT call setState — it updates themeNotifier which causes
  /// MaterialApp (in main.dart) to rebuild with the new theme instantly,
  /// affecting the whole app, including the switch below via ValueListenableBuilder.
  Future<void> _toggleDarkMode(bool val) async {
    themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
    final box = await Hive.openBox('settings');
    await box.put('theme_mode', val ? 'dark' : 'light');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ───── HEADER ─────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFE65100), Color(0xFFFF9800)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Settings',
                    style: GoogleFonts.archivo(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),

                  ValueListenableBuilder<String>(
                    valueListenable: userNameNotifier,
                    builder: (_, name, __) => ValueListenableBuilder<String>(
                      valueListenable: userEmailNotifier,
                      builder: (_, email, __) => Row(
                        children: [
                          ValueListenableBuilder<String?>(
                            valueListenable: userPhotoNotifier,
                            builder: (_, photo, __) => CircleAvatar(
                              radius: 22,
                              backgroundColor: Colors.orange,
                              backgroundImage: photo != null
                                  ? FileImage(File(photo))
                                  : null,
                              child: photo == null
                                  ? Text(name.isNotEmpty ? name[0].toUpperCase() : 'U',
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name.isEmpty ? 'User' : name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                email.isEmpty ? 'Not logged in' : email,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ───── BODY ─────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _sectionTitle("APPEARANCE"),

                  // ── Dark mode switch — reacts to global themeNotifier ──
                  _card(
                    child: ValueListenableBuilder<ThemeMode>(
                      valueListenable: themeNotifier,
                      builder: (_, mode, __) => SwitchListTile(
                        secondary: Icon(
                          mode == ThemeMode.dark
                              ? Icons.dark_mode_rounded
                              : Icons.light_mode_rounded,
                          color: mode == ThemeMode.dark
                              ? Colors.deepPurpleAccent
                              : Colors.orange,
                        ),
                        title: Text(
                          mode == ThemeMode.dark ? "Dark Mode" : "Light Mode",
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          mode == ThemeMode.dark
                              ? "Switch to light theme"
                              : "Switch to dark theme",
                          style: const TextStyle(fontSize: 12),
                        ),
                        value: mode == ThemeMode.dark,
                        activeColor: Colors.deepPurpleAccent,
                        onChanged: _toggleDarkMode,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  _sectionTitle("ACCOUNT"),

                  _card(
                    child: ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text("Profile Information"),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProfileScreen(),
                        ),
                      ),
                    ),
                  ),

                  _card(
                    child: ListTile(
                      leading: const Icon(Icons.home),
                      title: const Text("System Details"),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SystemDetailsScreen(),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  _sectionTitle("NOTIFICATIONS"),

                  _card(
                    child: SwitchListTile(
                      secondary: const Icon(Icons.notifications_active_outlined),
                      title: const Text("System Alerts"),
                      value: systemAlertsEnabled,
                      onChanged: (v) => setState(() => systemAlertsEnabled = v),
                    ),
                  ),

                  _card(
                    child: SwitchListTile(
                      secondary: const Icon(Icons.battery_alert_outlined),
                      title: const Text("Low Battery Warnings"),
                      value: lowBatteryWarningsEnabled,
                      onChanged: (v) =>
                          setState(() => lowBatteryWarningsEnabled = v),
                    ),
                  ),

                  _card(
                    child: SwitchListTile(
                      secondary: const Icon(Icons.build_circle_outlined),
                      title: const Text("Maintenance Reminders"),
                      value: maintenanceRemindersEnabled,
                      onChanged: (v) =>
                          setState(() => maintenanceRemindersEnabled = v),
                    ),
                  ),

                  const SizedBox(height: 20),

                  _card(
                    child: ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text(
                        "Logout",
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                      ),
                      onTap: () => _logout(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: GoogleFonts.archivo(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  void _logout(BuildContext context) async {
    await AuthService().logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }
}
