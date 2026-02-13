import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/bottom_nav_bar.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

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
                    'Analytics',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Performance Insights',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              // Metric Cards
              _buildMetricCard(
                '📊',
                'Total Energy Generated',
                '387 kWh',
                '↗ +12% vs last month',
                true,
              ),
              const SizedBox(height: 15),
              _buildMetricCard(
                '⚡',
                'Average Daily Production',
                '12.4 kWh',
                '↗ +8% vs last week',
                true,
              ),
              const SizedBox(height: 15),
              _buildMetricCard(
                '💰',
                'Cost Savings',
                'UGX 45,300',
                '↗ This month',
                true,
              ),
              const SizedBox(height: 15),
              _buildMetricCard(
                '🌍',
                'Carbon Offset',
                '184 kg',
                '↗ CO₂ reduced this month',
                true,
              ),
              const SizedBox(height: 15),
              _buildMetricCard(
                '🎯',
                'System Efficiency',
                '94.2%',
                '↘ -1.2% vs optimal',
                false,
              ),
              const SizedBox(height: 20),
              // Monthly Comparison
              Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(25),
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
                    const Text(
                      'Monthly Comparison',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildMonthBar('Dec', 0.65, false),
                        _buildMonthBar('Jan', 0.78, false),
                        _buildMonthBar('Feb', 0.92, true),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }

  Widget _buildMetricCard(
    String icon,
    String title,
    String value,
    String change,
    bool isPositive,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
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
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primaryYellow,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Text(
                icon,
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  change,
                  style: TextStyle(
                    fontSize: 12,
                    color: isPositive
                        ? AppColors.successGreen
                        : AppColors.warningRed,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthBar(String month, double height, bool isCurrent) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              width: 50,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primaryYellow.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            Container(
              width: 50,
              height: 100 * height,
              decoration: BoxDecoration(
                color: isCurrent
                    ? AppColors.secondaryOrange
                    : AppColors.primaryYellow,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          month,
          style: TextStyle(
            fontSize: 12,
            color: isCurrent ? AppColors.primaryDark : AppColors.textSecondary,
            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}