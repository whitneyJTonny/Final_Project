import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

const String _androidPackageId = 'com.yourcompany.solarm7';
const String _iosAppId = '123456789';

class AppVersionScreen extends StatefulWidget {
  const AppVersionScreen({super.key});

  @override
  State<AppVersionScreen> createState() => _AppVersionScreenState();
}

class _AppVersionScreenState extends State<AppVersionScreen> {
  String _version = '1.0.0';
  String _buildNumber = '1';
  bool _isChecking = false;
  String _updateStatus = 'idle'; // idle | upToDate | updateAvailable
  final String _latestVersion = '1.0.0';

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() {
      _version = info.version;
      _buildNumber = info.buildNumber;
    });
  }

  Future<void> _checkForUpdates() async {
    setState(() {
      _isChecking = true;
      _updateStatus = 'idle';
    });
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _isChecking = false;
      _updateStatus = _version == _latestVersion
          ? 'upToDate'
          : 'updateAvailable';
    });
  }

  Future<void> _openStore() async {
    final Uri url = defaultTargetPlatform == TargetPlatform.iOS
        ? Uri.parse('https://apps.apple.com/app/id$_iosAppId')
        : Uri.parse(
            'https://play.google.com/store/apps/details?id=$_androidPackageId',
          );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Could not open the store. Try again later.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: const Color(0xFFFFB800),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Gold AppBar ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 16, 14),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.black,
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'App Version',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            // ── White/Dark body ────────────────────────────────────
            Expanded(
              child: Container(
                color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── VERSION INFO section ─────────────────
                      _sectionLabel('VERSION INFO', isDark),
                      const SizedBox(height: 10),

                      _infoCard(
                        isDark: isDark,
                        icon: Icons.sell_outlined,
                        label: 'App Version',
                        value: 'v$_version',
                      ),
                      const SizedBox(height: 10),
                      _infoCard(
                        isDark: isDark,
                        icon: Icons.pentagon_outlined,
                        label: 'Build Number',
                        value: _buildNumber,
                      ),
                      const SizedBox(height: 10),
                      _infoCard(
                        isDark: isDark,
                        icon: Icons.smartphone_outlined,
                        label: 'Platform',
                        value: defaultTargetPlatform == TargetPlatform.iOS
                            ? 'iOS'
                            : 'Android',
                      ),
                      const SizedBox(height: 24),

                      // ── Update Status Banner ─────────────────
                      if (_updateStatus != 'idle') ...[
                        _updateBanner(isDark),
                        const SizedBox(height: 20),
                      ],

                      // ── Check for Updates button ─────────────
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _isChecking ? null : _checkForUpdates,
                          icon: _isChecking
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.sync_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                          label: Text(
                            _isChecking ? 'Checking...' : 'Check for Updates',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFB800),
                            disabledBackgroundColor: const Color(
                              0xFFFFB800,
                            ).withValues(alpha: 0.6),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── What's New ───────────────────────────
                      _sectionLabel("WHAT'S NEW IN v$_version", isDark),
                      const SizedBox(height: 10),
                      _changelogCard(isDark),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String title, bool isDark) => Padding(
    padding: const EdgeInsets.only(bottom: 2),
    child: Text(
      title,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: isDark ? Colors.white38 : Colors.black38,
        letterSpacing: 1.5,
      ),
    ),
  );

  Widget _infoCard({
    required bool isDark,
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.07)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFFFB800).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFFFFB800), size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _updateBanner(bool isDark) {
    final bool upToDate = _updateStatus == 'upToDate';
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: upToDate
            ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
            : const Color(0xFFFFB800).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: upToDate
              ? const Color(0xFF4CAF50).withValues(alpha: 0.35)
              : const Color(0xFFFFB800).withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            upToDate ? Icons.check_circle_rounded : Icons.system_update_rounded,
            color: upToDate ? const Color(0xFF4CAF50) : const Color(0xFFFFB800),
            size: 26,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  upToDate ? "You're up to date!" : 'Update Available',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: upToDate
                        ? const Color(0xFF4CAF50)
                        : isDark
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  upToDate
                      ? 'Solar M7 is running smoothly on the latest version.'
                      : 'A new version v$_latestVersion is ready to install.',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
              ],
            ),
          ),
          if (!upToDate) ...[
            const SizedBox(width: 10),
            GestureDetector(
              onTap: _openStore,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB800),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Update',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _changelogCard(bool isDark) {
    final List<Map<String, String>> changelog = [
      {
        'icon': '🏠',
        'title': 'System Details',
        'desc': "View kit's status & battery real time.",
      },
      {
        'icon': '👤',
        'title': 'Profile Editing',
        'desc': 'Update your name, email & photo from the app.',
      },
      {
        'icon': '🔔',
        'title': 'Smart Notifications',
        'desc': 'Get alerts for low battery, faults & maintenance.',
      },
      {
        'icon': '⚡',
        'title': 'Energy Impact Tracking',
        'desc': 'Track your CO₂ savings and total energy generated.',
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.07)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        children: changelog.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          final bool isLast = i == changelog.length - 1;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFB800).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          item['icon']!,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title']!,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item['desc']!,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white54 : Colors.black45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.07)
                      : Colors.black.withValues(alpha: 0.06),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
