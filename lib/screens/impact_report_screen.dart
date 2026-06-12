import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'monitoring_screen.dart';
import 'edit_profile_screen.dart';
import '../widgets/bottom_nav_bar.dart';
import '../main.dart';

class ImpactProfileScreen extends StatelessWidget {
  const ImpactProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ValueListenableBuilder<String>(
      valueListenable: userNameNotifier,
      builder: (context, name, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFFFB800),
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // ── Gold AppBar ────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 6, 8, 14),
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
                      const Expanded(
                        child: Text(
                          'My Impact Profile',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      // Edit pencil icon in dark circle
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EditProfileScreen(),
                          ),
                        ),
                        child: Container(
                          width: 36,
                          height: 36,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.18),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            LucideIcons.edit3,
                            color: Colors.black,
                            size: 18,
                          ),
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
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── User Header ──────────────────────────
                          Row(
                            children: [
                              // Avatar circle
                              ValueListenableBuilder<String?>(
                                valueListenable: userPhotoNotifier,
                                builder: (context, photoPath, _) => Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(
                                      0xFFFFB800,
                                    ).withValues(alpha: 0.25),
                                    border: Border.all(
                                      color: const Color(0xFFFFB800),
                                      width: 2.5,
                                    ),
                                    image: photoPath != null
                                        ? DecorationImage(
                                            image: FileImage(File(photoPath)),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: photoPath == null
                                      ? Center(
                                          child: Text(
                                            _initials(name),
                                            style: const TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFFFFB800),
                                            ),
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Changemaker since 2024',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark
                                          ? Colors.white54
                                          : Colors.black45,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // ── Dark Stats Bar ───────────────────────
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 18,
                              horizontal: 12,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1A2E),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _statCol(
                                  '3',
                                  'Kits Funded',
                                  const Color(0xFFFFB800),
                                ),
                                Container(
                                  width: 1,
                                  height: 36,
                                  color: Colors.white24,
                                ),
                                _statCol(
                                  '18',
                                  'Lives Impacted',
                                  const Color(0xFF4CAF50),
                                ),
                                Container(
                                  width: 1,
                                  height: 36,
                                  color: Colors.white24,
                                ),
                                _statCol('\$180', 'Total', Colors.white),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),

                          // ── Donation History ─────────────────────
                          Text(
                            'Donation History',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 14),

                          _historyCard(
                            context: context,
                            isDark: isDark,
                            amount: '\$60',
                            kitId: 'Kit #SM7-4921',
                            date: 'April 28, 2026',
                            status: 'Installed',
                            statusColor: const Color(0xFF4CAF50),
                          ),
                          const SizedBox(height: 10),
                          _historyCard(
                            context: context,
                            isDark: isDark,
                            amount: '\$60',
                            kitId: 'Kit #SM7-3100',
                            date: 'February 10, 2026',
                            status: 'Installed',
                            statusColor: const Color(0xFF4CAF50),
                          ),
                          const SizedBox(height: 10),
                          _historyCard(
                            context: context,
                            isDark: isDark,
                            amount: '\$60',
                            kitId: 'Kit #SM7-2501',
                            date: 'December 25, 2025',
                            status: 'Shipped',
                            statusColor: const Color(0xFFFFB800),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: const BottomNavBar(currentIndex: 3),
        );
      },
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return 'U';
  }

  Widget _statCol(String value, String label, Color valueColor) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: valueColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 11),
        ),
      ],
    );
  }

  Widget _historyCard({
    required BuildContext context,
    required bool isDark,
    required String amount,
    required String kitId,
    required String date,
    required String status,
    required Color statusColor,
  }) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => MonitoringScreen(kitId: kitId)),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.07)
                : Colors.black.withOpacity(0.07),
          ),
        ),
        child: Row(
          children: [
            // Icon box
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFFFB800).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                LucideIcons.receipt,
                color: Color(0xFFFFB800),
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        amount,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      Text(
                        date,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        kitId,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.circle, size: 7, color: statusColor),
                          const SizedBox(width: 4),
                          Text(
                            '• $status',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
