import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../utils/app_colors.dart';
import '../widgets/bottom_nav_bar.dart';
import 'beneficiary_profile_screen.dart';

class MonitoringScreen extends StatelessWidget {
  final String? kitId;
  const MonitoringScreen({super.key, this.kitId});

  @override
  Widget build(BuildContext context) {
    final bool isDetailView = kitId != null;

    // Dynamically retrieve kit data from Hive offline_kits if available
    Map<String, dynamic>? kitData;
    if (isDetailView) {
      final box = Hive.box('offline_kits');
      final rawData = box.get(kitId);
      if (rawData != null) {
        kitData = Map<String, dynamic>.from(rawData as Map);
      }
    }
    final String status = kitData?['status'] as String? ?? 'ACTIVE';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── App Bar ──
          SliverAppBar(
            pinned: true,
            backgroundColor: Theme.of(context).cardColor,
            elevation: 0,
            expandedHeight: 0,
            toolbarHeight: 68,
            titleSpacing: 20,
            automaticallyImplyLeading: false,
            leading: isDetailView
                ? IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: AppColors.primaryDark, size: 20),
                    onPressed: () => Navigator.pop(context),
                  )
                : null,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isDetailView ? 'Kit Details' : 'Monitor',
                  style: GoogleFonts.dmSans(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  isDetailView ? kitId! : 'Track Your Impact',
                  style: GoogleFonts.archivo(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w900,
                    fontSize: 19,
                  ),
                ),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(
                height: 1,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white12
                    : Colors.grey.shade100,
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Kit Header Card ──
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1C1400), Color(0xFF2D2200)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF9800).withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF9800).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFFFF9800).withValues(alpha: 0.3),
                            ),
                          ),
                          child: const Icon(Icons.solar_power_rounded,
                              color: Color(0xFFFF9800), size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                kitId ?? 'Kit #SM7-4921',
                                style: GoogleFonts.archivo(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_rounded,
                                      color: Color(0xFFFF9800), size: 13),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Nakaseke District, Uganda',
                                    style: GoogleFonts.dmSans(
                                      color: Colors.white54,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: (status == 'ACTIVE'
                                    ? const Color(0xFF4CAF50)
                                    : const Color(0xFFFF9800))
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: (status == 'ACTIVE'
                                      ? const Color(0xFF4CAF50)
                                      : const Color(0xFFFF9800))
                                  .withValues(alpha: 0.4),
                            ),
                          ),
                          child: Text(
                            status,
                            style: GoogleFonts.dmSans(
                              color: status == 'ACTIVE'
                                  ? const Color(0xFF4CAF50)
                                  : const Color(0xFFFF9800),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Deployment Status ──
                  Text(
                    'Deployment Status',
                    style: GoogleFonts.archivo(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Step tracker
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildStep(context, 'Funded', isDone: true, isLast: false),
                        _buildStep(context, 'Processing', isDone: true, isLast: false),
                        _buildStep(context, 'Shipped', isDone: status == 'ACTIVE', isLast: false),
                        _buildStep(context, 'Installed', isDone: status == 'ACTIVE', isLast: false),
                        _buildStep(context, 'Verified', isDone: false, isLast: true),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // ── Beneficiary Button ──
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const BeneficiaryProfileScreen()),
                      ),
                      icon: const Icon(Icons.person_rounded, size: 20),
                      label: Text(
                        'View Beneficiary Profile',
                        style: GoogleFonts.archivo(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9800),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),

                  // ── Offline Kits ──
                  if (!isDetailView) ...[
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'My Funded Kits',
                          style: GoogleFonts.archivo(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : AppColors.primaryDark,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'OFFLINE',
                            style: GoogleFonts.dmSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Available without internet connection.',
                      style: GoogleFonts.dmSans(
                          fontSize: 12, color: Colors.grey.shade500),
                    ),
                    const SizedBox(height: 14),
                    ValueListenableBuilder(
                      valueListenable: Hive.box('offline_kits').listenable(),
                      builder: (context, Box box, _) {
                        final kits = box.values.toList().reversed.toList();
                        if (kits.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Text(
                                'No kits funded yet.',
                                style: GoogleFonts.dmSans(color: Colors.grey),
                              ),
                            ),
                          );
                        }
                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: kits.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final kit = Map<String, dynamic>.from(kits[index] as Map);
                            return _buildOfflineKitCard(
                              context,
                              kitId: kit['kitId'] as String,
                              date: kit['date'] as String,
                              amount: kit['amount'] as String,
                              impact: kit['impact'] as String,
                            );
                          },
                        );
                      },
                    ),
                  ],

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar:
          isDetailView ? null : const BottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildStep(BuildContext context, String title,
      {required bool isDone, required bool isLast}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone ? const Color(0xFF4CAF50) : Theme.of(context).cardColor,
                border: isDone
                    ? null
                    : Border.all(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white24
                            : Colors.grey.shade300,
                        width: 2,
                      ),
                boxShadow: isDone
                    ? [
                        BoxShadow(
                          color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: isDone
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 15)
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 36,
                decoration: BoxDecoration(
                  gradient: isDone
                      ? const LinearGradient(
                          colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        )
                      : null,
                  color: isDone
                      ? null
                      : (Theme.of(context).brightness == Brightness.dark
                          ? Colors.white24
                          : Colors.grey.shade200),
                ),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            title,
            style: GoogleFonts.dmSans(
              fontSize: 15,
              fontWeight: isDone ? FontWeight.w700 : FontWeight.w500,
              color: isDone
                  ? (Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : AppColors.primaryDark)
                  : Colors.grey.shade400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOfflineKitCard(
    BuildContext context, {
    required String kitId,
    required String date,
    required String amount,
    required String impact,
  }) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => MonitoringScreen(kitId: kitId)),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFFF9800).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.solar_power_rounded,
                  color: Color(0xFFFF9800), size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    kitId,
                    style: GoogleFonts.archivo(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$amount • $impact',
                    style: GoogleFonts.dmSans(
                        color: Colors.grey.shade500, fontSize: 12),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  date,
                  style: GoogleFonts.dmSans(
                      fontSize: 11, color: Colors.grey.shade400),
                ),
                const SizedBox(height: 5),
                const Icon(Icons.chevron_right_rounded,
                    color: Colors.grey, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
