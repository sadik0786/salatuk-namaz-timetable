import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:namaz_timetable/services/localization_service.dart';
import 'package:namaz_timetable/widgets/common_app_bar.dart';
import 'package:namaz_timetable/widgets/tr_text.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  double _heading = 0.0;
  double _qiblaAngle = 0.0;
  double _distanceToKaaba = 0.0;
  bool _isLoading = true;

  StreamSubscription<CompassEvent>? _compassSub;

  @override
  void initState() {
    super.initState();
    _initCompass();
    _calculateQibla();
  }

  void _initCompass() {
    _compassSub = FlutterCompass.events?.listen((event) {
      if (!mounted) return;
      if (event.heading == null) return;

      setState(() {
        _heading = event.heading!;
      });
    });
  }

  Future<void> _calculateQibla() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() => _isLoading = false);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5),
      );

      final lat = position.latitude * math.pi / 180;
      final lon = position.longitude * math.pi / 180;

      const kaabaLat = 21.422487 * math.pi / 180;
      const kaabaLon = 39.826206 * math.pi / 180;

      final deltaLon = kaabaLon - lon;

      final angle = math.atan2(
        math.sin(deltaLon),
        math.cos(lat) * math.tan(kaabaLat) - math.sin(lat) * math.cos(deltaLon),
      );

      final bearing = (angle * 180 / math.pi + 360) % 360;

      // Distance using Haversine
      final dLat = kaabaLat - lat;
      final dLon = kaabaLon - lon;
      final a =
          math.sin(dLat / 2) * math.sin(dLat / 2) +
          math.cos(lat) * math.cos(kaabaLat) * math.sin(dLon / 2) * math.sin(dLon / 2);
      final c = 2 * math.asin(math.sqrt(a));
      final distance = 6371.0 * c; // Earth radius in km

      if (!mounted) return;

      setState(() {
        _qiblaAngle = bearing;
        _distanceToKaaba = distance;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      debugPrint("Qibla calculation error: $e");
    }
  }

  @override
  void dispose() {
    _compassSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final double needleAngle = (_qiblaAngle - _heading) * math.pi / 180;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CommonAppBar(centerTitle: false, title: "Qibla Direction".tr),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
            ],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Spacer(flex: 1),

                    // Glassmorphic Info Card
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 24.w),
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.05)
                            : Colors.black.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(24.r),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.05),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildInfoItem(
                            "Qibla Angle".tr,
                            "${_qiblaAngle.toStringAsFixed(1)}°",
                            Icons.explore,
                            theme,
                          ),
                          Container(
                            width: 1,
                            height: 40.h,
                            color: theme.dividerColor.withOpacity(0.2),
                          ),
                          _buildInfoItem(
                            "Distance".tr,
                            "${_distanceToKaaba.toStringAsFixed(0)} km",
                            Icons.location_on,
                            theme,
                          ),
                        ],
                      ),
                    ),

                    Spacer(flex: 2),

                    // Modern Compass
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer Glow
                        Container(
                          width: 320.w,
                          height: 320.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary.withOpacity(0.15),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                        ),

                        // Dial rotating with heading
                        Transform.rotate(
                          angle: -_heading * math.pi / 180,
                          child: CustomPaint(
                            size: Size(280.w, 280.w),
                            painter: ModernCompassDialPainter(theme: theme, isDark: isDark),
                          ),
                        ),

                        // Needle rotating towards Qibla
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: needleAngle),
                          duration: const Duration(milliseconds: 300),
                          builder: (context, angle, child) {
                            return Transform.rotate(angle: angle, child: child);
                          },
                          child: CustomPaint(
                            size: Size(280.w, 280.w),
                            painter: QiblaArrowPainter(theme: theme),
                          ),
                        ),
                      ],
                    ),

                    Spacer(flex: 2),

                    // Bottom info
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40.w),
                      child: TrText(
                        "Align the needle to the top of the compass to face the Qibla directly.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: isDark ? Colors.white60 : Colors.black54,
                          height: 1.5,
                        ),
                      ),
                    ),
                    Spacer(flex: 1),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildInfoItem(String title, String value, IconData icon, ThemeData theme) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16.sp, color: theme.colorScheme.primary),
            SizedBox(width: 6.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Text(
          value,
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

// ---------------- MODERN COMPASS DIAL ----------------
class ModernCompassDialPainter extends CustomPainter {
  final ThemeData theme;
  final bool isDark;

  ModernCompassDialPainter({required this.theme, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background gradient body
    final bodyPaint = Paint()
      ..shader = RadialGradient(
        colors: isDark
            ? [const Color(0xFF2C2C2C), const Color(0xFF1A1A1A)]
            : [Colors.white, const Color(0xFFF0F0F0)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;

    // Outer border ring
    final borderPaint = Paint()
      ..color = isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;

    canvas.drawCircle(center, radius, bodyPaint);
    canvas.drawCircle(center, radius - 6, borderPaint);

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Tick marks
    final tickPaint = Paint()..strokeWidth = 2;
    for (int i = 0; i < 360; i += 2) {
      final isMajor = i % 30 == 0;
      final isMedium = i % 10 == 0 && !isMajor;

      tickPaint.color = isMajor
          ? theme.colorScheme.primary
          : isDark
          ? Colors.white30
          : Colors.black26;
      tickPaint.strokeWidth = isMajor ? 3 : (isMedium ? 2 : 1);

      final lineLength = isMajor ? 14.0 : (isMedium ? 10.0 : 6.0);

      final angle = i * math.pi / 180;
      final innerRadius = radius - 18 - lineLength;
      final outerRadius = radius - 18;

      final p1 = Offset(
        center.dx + innerRadius * math.sin(angle),
        center.dy - innerRadius * math.cos(angle),
      );
      final p2 = Offset(
        center.dx + outerRadius * math.sin(angle),
        center.dy - outerRadius * math.cos(angle),
      );

      canvas.drawLine(p1, p2, tickPaint);
    }

    // N E S W labels
    const labels = ['N', 'E', 'S', 'W'];
    for (int i = 0; i < 4; i++) {
      final angle = i * math.pi / 2;
      final dx = center.dx + (radius * 0.65) * math.sin(angle);
      final dy = center.dy - (radius * 0.65) * math.cos(angle);

      final isNorth = i == 0;
      textPainter.text = TextSpan(
        text: labels[i],
        style: TextStyle(
          fontSize: isNorth ? 26.sp : 22.sp,
          fontWeight: isNorth ? FontWeight.w900 : FontWeight.bold,
          color: isNorth ? theme.colorScheme.primary : (isDark ? Colors.white70 : Colors.black87),
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(dx - textPainter.width / 2, dy - textPainter.height / 2));
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

// ---------------- MODERN QIBLA ARROW ----------------
class QiblaArrowPainter extends CustomPainter {
  final ThemeData theme;

  QiblaArrowPainter({required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final length = size.width * 0.40;

    // Center pivot
    final pivotPaintOuter = Paint()
      ..color = theme.colorScheme.primary.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    final pivotPaintInner = Paint()
      ..color = theme.colorScheme.primary
      ..style = PaintingStyle.fill;

    // Draw glowing shadow for needle
    final shadowPath = Path();
    shadowPath.moveTo(center.dx - 12, center.dy);
    shadowPath.lineTo(center.dx, center.dy - length);
    shadowPath.lineTo(center.dx + 12, center.dy);
    shadowPath.close();

    canvas.drawShadow(shadowPath, theme.colorScheme.primary, 8, true);

    // Draw needle
    final needlePaint = Paint()
      ..color = theme.colorScheme.primary
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(center.dx - 8, center.dy);
    path.lineTo(center.dx, center.dy - length - 5);
    path.lineTo(center.dx + 8, center.dy);
    path.lineTo(center.dx, center.dy - 10);
    path.close();

    canvas.drawPath(path, needlePaint);

    // Back weight of needle
    final backPaint = Paint()
      ..color = theme.colorScheme.onSurface.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    final backPath = Path();
    backPath.moveTo(center.dx - 6, center.dy);
    backPath.lineTo(center.dx, center.dy + length * 0.25);
    backPath.lineTo(center.dx + 6, center.dy);
    backPath.close();

    canvas.drawPath(backPath, backPaint);

    // Center dot
    canvas.drawCircle(center, 14, pivotPaintOuter);
    canvas.drawCircle(center, 6, pivotPaintInner);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
