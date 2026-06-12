import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import '../widgets/bottom_nav_bar.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Theme.of(context).cardColor,
            elevation: 0,
            toolbarHeight: 68,
            titleSpacing: 20,
            automaticallyImplyLeading: false,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Overview',
                  style: GoogleFonts.dmSans(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Analytics',
                  style: GoogleFonts.archivo(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : AppColors.primaryDark,
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
                  Text(
                    'Global Impact Overview',
                    style: GoogleFonts.archivo(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Savanna Map Card ──
                  const _SavannaMapCard(),
                  const SizedBox(height: 16),

                  // ── Stat Cards Row ──
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.inventory_2_outlined,
                          value: '12,450',
                          label: 'Total Kits',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.attach_money_rounded,
                          value: '\$747k',
                          label: 'Total Funds',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  Text(
                    'Donation Flow',
                    style: GoogleFonts.archivo(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 14),

                  Container(
                    padding: const EdgeInsets.all(16),
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
                    child: const _DonationFlowChart(),
                  ),

                  const SizedBox(height: 110),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }
}

// ── Savanna Map Card ─────────────────────────────────────────────────────────

class _SavannaMapCard extends StatelessWidget {
  const _SavannaMapCard();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 130,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Savanna painted background
            CustomPaint(painter: _SavannaPainter()),

            // Dark overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.18),
                    Colors.black.withValues(alpha: 0.52),
                  ],
                ),
              ),
            ),

            // Map icon + label
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.55),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.map_outlined,
                      color: Color(0xFFE8C030),
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Live Deployment Map',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      shadows: [
                        const Shadow(
                          color: Colors.black45,
                          blurRadius: 6,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
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

class _SavannaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Sky gradient
    final skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: const [Color(0xFF6AB8D4), Color(0xFF9DD4E8), Color(0xFFC8E8C0)],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), skyPaint);

    // Clouds
    final cloudPaint = Paint()..color = Colors.white.withValues(alpha: 0.88);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.22, h * 0.17),
        width: 64,
        height: 22,
      ),
      cloudPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.30, h * 0.13),
        width: 50,
        height: 20,
      ),
      cloudPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.16, h * 0.16),
        width: 40,
        height: 16,
      ),
      cloudPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.70, h * 0.14),
        width: 72,
        height: 24,
      ),
      cloudPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.78, h * 0.10),
        width: 52,
        height: 22,
      ),
      cloudPaint,
    );

    // Ground
    final groundPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: const [Color(0xFF7AB84A), Color(0xFF5A8E2E)],
      ).createShader(Rect.fromLTWH(0, h * 0.58, w, h * 0.42));
    canvas.drawRect(Rect.fromLTWH(0, h * 0.58, w, h * 0.42), groundPaint);

    // Ground hill
    final hillPaint = Paint()
      ..color = const Color(0xFF5A9E3A).withValues(alpha: 0.5);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w / 2, h * 0.58),
        width: w * 1.4,
        height: h * 0.36,
      ),
      hillPaint,
    );

    // Tree helper
    void drawAcacia(double cx, double trunkTop, double trunkH, double canopyR) {
      final trunkPaint = Paint()..color = const Color(0xFF7A5A2A);
      final rr = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, trunkTop + trunkH / 2),
          width: 5,
          height: trunkH,
        ),
        const Radius.circular(2),
      );
      canvas.drawRRect(rr, trunkPaint);

      final darkPaint = Paint()..color = const Color(0xFF2A6018);
      final midPaint = Paint()..color = const Color(0xFF387520);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx, trunkTop),
          width: canopyR * 2.2,
          height: canopyR,
        ),
        darkPaint,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx - canopyR * 0.65, trunkTop + canopyR * 0.2),
          width: canopyR * 1.4,
          height: canopyR * 0.8,
        ),
        midPaint,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx + canopyR * 0.65, trunkTop + canopyR * 0.15),
          width: canopyR * 1.4,
          height: canopyR * 0.8,
        ),
        midPaint,
      );
    }

    drawAcacia(w * 0.14, h * 0.38, h * 0.22, h * 0.14);
    drawAcacia(w * 0.78, h * 0.32, h * 0.28, h * 0.17);

    // Shrubs
    final shrubPaint = Paint()..color = const Color(0xFF306418);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.36, h * 0.68),
        width: 22,
        height: 10,
      ),
      shrubPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.58, h * 0.72), width: 18, height: 8),
      shrubPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.88, h * 0.76), width: 20, height: 8),
      shrubPaint..color = const Color(0xFF3A7420),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Stat Card ────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFFAF8F2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white10 : const Color(0xFFE6E0D0),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF4EE),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF2A9D5C), size: 16),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.archivo(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : const Color(0xFF1A1A1A),
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: const Color(0xFFAAAAAA),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Donation Flow Chart ──────────────────────────────────────────────────────

class _DonationFlowChart extends StatelessWidget {
  const _DonationFlowChart();

  static const List<double> _values = [380, 620, 560, 920, 1150];
  static const List<String> _labels = ['Jan', 'Feb', 'Mar', 'Apr', 'May'];
  static const double _maxY = 1500;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 160,
      child: CustomPaint(
        painter: _ChartPainter(
            values: _values, labels: _labels, maxY: _maxY, isDark: isDark),
        size: Size.infinite,
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;
  final double maxY;
  final bool isDark;

  const _ChartPainter({
    required this.values,
    required this.labels,
    required this.maxY,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const leftPad = 36.0;
    const bottomPad = 24.0;
    const topPad = 10.0;
    final chartW = size.width - leftPad;
    final chartH = size.height - bottomPad - topPad;

    // Y-axis grid lines & labels
    final gridPaint = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.1)
          : Colors.black.withValues(alpha: 0.06)
      ..strokeWidth = 0.8;
    final labelStyle = TextStyle(
      fontSize: 11,
      color: Colors.grey[400],
      fontFamily: 'sans-serif',
    );

    for (final yVal in [0.0, 500.0, 1000.0, 1500.0]) {
      final yPos = topPad + chartH * (1 - yVal / maxY);
      canvas.drawLine(
        Offset(leftPad, yPos),
        Offset(size.width, yPos),
        gridPaint,
      );
      final tp = TextPainter(
        text: TextSpan(
          text: yVal == 0
              ? '0'
              : yVal >= 1000
              ? '${(yVal / 1000).toStringAsFixed(0)}k'
              : yVal.toStringAsFixed(0),
          style: labelStyle,
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, yPos - tp.height / 2));
    }

    // Compute point positions
    final pts = <Offset>[];
    for (var i = 0; i < values.length; i++) {
      final x = leftPad + i * chartW / (values.length - 1);
      final y = topPad + chartH * (1 - values[i] / maxY);
      pts.add(Offset(x, y));
    }

    // Build smooth curve path
    Path buildCurve() {
      final path = Path()..moveTo(pts[0].dx, pts[0].dy);
      for (var i = 0; i < pts.length - 1; i++) {
        final cp1 = Offset((pts[i].dx + pts[i + 1].dx) / 2, pts[i].dy);
        final cp2 = Offset((pts[i].dx + pts[i + 1].dx) / 2, pts[i + 1].dy);
        path.cubicTo(
          cp1.dx,
          cp1.dy,
          cp2.dx,
          cp2.dy,
          pts[i + 1].dx,
          pts[i + 1].dy,
        );
      }
      return path;
    }

    final curvePath = buildCurve();

    // Fill area under curve
    final fillPath = Path.from(curvePath)
      ..lineTo(pts.last.dx, topPad + chartH)
      ..lineTo(pts.first.dx, topPad + chartH)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFD4A017).withValues(alpha: 0.18),
          const Color(0xFFD4A017).withValues(alpha: 0.03),
        ],
      ).createShader(Rect.fromLTWH(0, topPad, size.width, chartH));
    canvas.drawPath(fillPath, fillPaint);

    // Line
    final linePaint = Paint()
      ..color = const Color(0xFFD4A017)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(curvePath, linePaint);

    // Highlight dot at Apr (index 3)
    final dotPt = pts[3];
    canvas.drawCircle(dotPt, 7, Paint()..color = const Color(0xFF888888));
    canvas.drawCircle(dotPt, 5, Paint()..color = Colors.white);

    // X-axis labels
    for (var i = 0; i < labels.length; i++) {
      final x = leftPad + i * chartW / (labels.length - 1);
      final tp = TextPainter(
        text: TextSpan(text: labels[i], style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, size.height - bottomPad + 4));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
