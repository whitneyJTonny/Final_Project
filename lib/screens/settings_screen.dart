import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Manage your preferences',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              // Account Section
              _buildSectionHeader('ACCOUNT'),
              _buildSettingsItem(
                '👤',
                'Profile Information',
                onTap: () {},
              ),
              const SizedBox(height: 10),
              _buildSettingsItem(
                '🏠',
                'System Details',
                onTap: () {},
              ),
              const SizedBox(height: 25),
              // Notifications Section
              _buildSectionHeader('NOTIFICATIONS'),
              _buildToggleItem(
                '🔔',
                'System Alerts',
                systemAlertsEnabled,
                (value) {
                  setState(() {
                    systemAlertsEnabled = value;
                  });
                },
              ),
              const SizedBox(height: 10),
              _buildToggleItem(
                '⚠️',
                'Low Battery Warnings',
                lowBatteryWarningsEnabled,
                (value) {
                  setState(() {
                    lowBatteryWarningsEnabled = value;
                  });
                },
              ),
              const SizedBox(height: 10),
              _buildToggleItem(
                '🔧',
                'Maintenance Reminders',
                maintenanceRemindersEnabled,
                (value) {
                  setState(() {
                    maintenanceRemindersEnabled = value;
                  });
                },
              ),
              const SizedBox(height: 25),
              // System Section
              _buildSectionHeader('SYSTEM'),
              _buildSettingsItem(
                '📱',
                'App Version',
                trailing: const Text(
                  'v1.0.0',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _buildSettingsItem(
                '📄',
                'Terms & Privacy',
                onTap: () {},
              ),
              const SizedBox(height: 10),
              _buildSettingsItem(
                '❓',
                'Help & Support',
                onTap: () {},
              ),
              const SizedBox(height: 25),
              // Logout Button
              Container(
                decoration: BoxDecoration(
                  color: AppColors.warningRed.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: AppColors.warningRed,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      _showLogoutDialog(context);
                    },
                    borderRadius: BorderRadius.circular(15),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.warningRed,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Text(
                                '🚪',
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          const Text(
                            'Logout',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: AppColors.warningRed,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildSettingsItem(
    String icon,
    String label, {
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryYellow,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      icon,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
                trailing ??
                    const Icon(
                      Icons.chevron_right,
                      color: AppColors.textSecondary,
                      size: 24,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleItem(
    String icon,
    String label,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryYellow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                icon,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: AppColors.primaryDark,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.successGreen.withValues(alpha: 0.5),
            activeThumbColor: AppColors.successGreen,
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Logout',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: AppColors.primaryDark,
          ),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Perform logout
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warningRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Text(
              'Logout',
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}