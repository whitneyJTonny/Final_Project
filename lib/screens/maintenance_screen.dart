import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import '../widgets/bottom_nav_bar.dart';

class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF0),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Maintenance',
                    style: GoogleFonts.archivo(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Theme.of(context).textTheme.titleLarge?.color ?? AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'System Care Schedule',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              // Schedule Cards
              _buildScheduleCard(
                'Panel Cleaning',
                'Feb 15, 2026 • 10:00 AM',
                'Regular cleaning of solar panels to maintain optimal energy efficiency. Estimated duration: 2 hours.',
                'John Mukasa (Tech #243)',
                'Upcoming',
                AppColors.primaryYellow,
                false,
              ),
              const SizedBox(height: 15),
              _buildScheduleCard(
                'Battery Inspection',
                'Feb 8, 2026 • 2:00 PM',
                'Routine battery health check and voltage testing. All systems functioning normally.',
                'Sarah Nalongo (Tech #187)',
                'Completed',
                AppColors.successGreen,
                true,
              ),
              const SizedBox(height: 15),
              _buildScheduleCard(
                'System Diagnostic',
                'Feb 22, 2026 • 9:00 AM',
                'Comprehensive system check including inverter, wiring, and monitoring sensors.',
                'David Okello (Tech #156)',
                'Upcoming',
                AppColors.primaryYellow,
                false,
              ),
              const SizedBox(height: 15),
              _buildScheduleCard(
                'Firmware Update',
                'Jan 28, 2026 • 11:30 AM',
                'Updated monitoring system firmware to version 2.4.1 for improved performance.',
                'Remote Tech Support',
                'Completed',
                AppColors.successGreen,
                true,
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new maintenance schedule
        },
        backgroundColor: AppColors.primaryYellow,
        child: const Icon(
          Icons.add,
          color: AppColors.primaryDark,
          size: 32,
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }

  Widget _buildScheduleCard(
    String title,
    String date,
    String description,
    String technician,
    String status,
    Color borderColor,
    bool isCompleted,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border(
          left: BorderSide(color: borderColor, width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.archivo(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Text(
                          '📅 ',
                          style: TextStyle(fontSize: 12),
                        ),
                        Expanded(
                          child: Text(
                            date,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.successGreen.withValues(alpha: 0.2)
                      : AppColors.secondaryOrange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isCompleted
                        ? AppColors.successGreen
                        : AppColors.secondaryOrange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text(
                '👤 ',
                style: TextStyle(fontSize: 14),
              ),
              Expanded(
                child: Text(
                  '${isCompleted ? "Completed by" : "Assigned to"}: $technician',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}