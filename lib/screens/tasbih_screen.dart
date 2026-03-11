import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:namaz_timetable/services/localization_service.dart';
import 'package:namaz_timetable/services/settings_service.dart';
import 'package:namaz_timetable/widgets/common_app_bar.dart';
import 'package:namaz_timetable/widgets/tr_text.dart';

class TasbihScreen extends StatefulWidget {
  const TasbihScreen({super.key});

  @override
  State<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends State<TasbihScreen> with TickerProviderStateMixin {
  int _counter = 0;
  int _totalCount = 0;
  int _targetIndex = 0; // 0: 33, 1: 100, 2: 333, 3: Infinity
  final List<int?> _targets = [33, 100, 333, null];
  final List<String> _targetLabels = ['33', '100', '333', '∞'];

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late AnimationController _beadController;

  @override
  void initState() {
    super.initState();
    _loadTotalCount();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.92), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 0.92, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    _beadController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
  }

  Future<void> _loadTotalCount() async {
    final count = await SettingsService.getTasbihTotalCount();
    setState(() {
      _totalCount = count;
    });
  }

  void _incrementCounter() {
    HapticFeedback.mediumImpact();
    _animationController.forward(from: 0);
    _beadController.forward(from: 0);

    setState(() {
      _counter++;
      _totalCount++;
      
      // Auto-reset check based on target
      final target = _targets[_targetIndex];
      if (target != null && _counter > target) {
        _counter = 1; // Start new round
        HapticFeedback.heavyImpact();
      }
    });
    SettingsService.saveTasbihTotalCount(_totalCount);
  }

  void _decrementCounter() {
    if (_counter > 0) {
      HapticFeedback.mediumImpact();
      // Small pulse for minus
      _animationController.forward(from: 0.5).then((_) => _animationController.reverse());
      setState(() {
        _counter--;
        if (_totalCount > 0) _totalCount--;
      });
      SettingsService.saveTasbihTotalCount(_totalCount);
    }
  }

  void _resetCounter() {
    HapticFeedback.mediumImpact();
    setState(() {
      _counter = 0;
    });
  }

  void _resetTotalCount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: TrText('Reset Total Count?'),
        content: TrText('Are you sure you want to reset your lifetime tasbih progress?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: TrText('Cancel')),
          TextButton(
            onPressed: () {
              HapticFeedback.heavyImpact();
              setState(() {
                _totalCount = 0;
              });
              SettingsService.saveTasbihTotalCount(0);
              Navigator.pop(context);
            },
            child: TrText('Reset', style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _getDhikrText() {
    final target = _targets[_targetIndex];
    if (target == 100) {
      if (_counter <= 33) return 'SubhanAllah'.tr;
      if (_counter <= 66) return 'Alhamdulillah'.tr;
      if (_counter <= 100) return 'Allahu Akbar'.tr;
    }
    // Default or other targets
    if (_targetIndex == 0) return 'SubhanAllah'.tr; // 33 logic
    return 'SubhanAllah'.tr;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _beadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CommonAppBar(
        backgroundColor: Colors.transparent,
        title: 'Tasbih'.tr,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: _resetTotalCount,
            tooltip: 'Reset Total Count'.tr,
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                : [const Color(0xFFF8FAFC), const Color(0xFFF1F5F9)],
          ),
        ),
        child: Stack(
          children: [
            // Decorative background elements
            _buildDecorCircle(top: -50, right: -50, color: primaryColor.withOpacity(0.1)),
            _buildDecorCircle(bottom: 100, left: -100, color: primaryColor.withOpacity(0.08)),

            SafeArea(
              child: Column(
                children: [
                  SizedBox(height: 10.h),

                  // Total Count Glass Card
                  _buildTotalCountCard(theme, primaryColor, isDark),

                  SizedBox(height: 15.h),

                  // Target Selector
                  _buildTargetSelector(primaryColor, isDark),

                  const Spacer(),

                  // Main Counter Section
                  _buildCounterButton(primaryColor, isDark),

                  const Spacer(),

                  // Controls
                  _buildBottomControls(isDark),
                  
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDecorCircle({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required Color color,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }

  Widget _buildTotalCountCard(ThemeData theme, Color primaryColor, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.02),
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: Colors.white.withOpacity(isDark ? 0.1 : 0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(15.r),
              ),
              child: Icon(Icons.all_inclusive, color: primaryColor, size: 24.sp),
            ),
            SizedBox(width: 15.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TrText(
                  'Lifetime Progress',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isDark ? Colors.white60 : Colors.black54,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  '$_totalCount',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              'BEADS'.tr,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w900,
                color: primaryColor.withOpacity(0.5),
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetSelector(Color primaryColor, bool isDark) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(_targets.length, (index) {
          final isSelected = _targetIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _targetIndex = index);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected ? primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(25.r),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    _targetLabels[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : (isDark ? Colors.white38 : Colors.black38),
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCounterButton(Color primaryColor, bool isDark) {
    final target = _targets[_targetIndex] ?? 100;
    final double progress = (_counter % (target + 1)) / target;

    return GestureDetector(
      onTap: _incrementCounter,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Layer 1: Hyper Glow (Pulsing behind)
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Container(
                  width: 290.w,
                  height: 290.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.15 * (1.0 + _animationController.value)),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                );
              },
            ),

            // Layer 2: Custom Gradient Progress Ring
            SizedBox(
              width: 280.w,
              height: 280.w,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(
                  begin: 0,
                  end: _targetLabels[_targetIndex] == '∞' ? 0.05 : progress.clamp(0.0, 1.0),
                ),
                duration: const Duration(milliseconds: 300),
                builder: (context, value, child) {
                  return ShaderMask(
                    shaderCallback: (rect) {
                      return SweepGradient(
                        startAngle: -0.5 * 3.141592,
                        endAngle: 1.5 * 3.141592,
                        colors: [primaryColor, primaryColor.withBlue(255), primaryColor],
                        stops: [0.0, value, value + 0.01],
                      ).createShader(rect);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 12.w),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Layer 3: Inner Glassy Ring
            Container(
              width: 245.w,
              height: 245.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? Colors.white.withOpacity(0.02) : Colors.black.withOpacity(0.01),
                border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
              ),
            ),

            // Layer 4: Main Button Body (Premium 3D Look)
            Container(
              width: 215.w,
              height: 215.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: const Alignment(-0.3, -0.3),
                  radius: 0.8,
                  colors: isDark
                      ? [
                          primaryColor.withOpacity(0.9),
                          primaryColor,
                          primaryColor.withBlue(200).withOpacity(0.8),
                        ]
                      : [
                          primaryColor.withOpacity(0.8),
                          primaryColor,
                          primaryColor.withOpacity(0.7),
                        ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 12),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Subtle Radial Overlay
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [Colors.white.withOpacity(0.1), Colors.transparent],
                        stops: const [0.0, 1.0],
                      ),
                    ),
                  ),

                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, anim) =>
                            FadeTransition(opacity: anim, child: child),
                        child: Text(
                          _getDhikrText(),
                          key: ValueKey(_getDhikrText()),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.95),
                            fontSize: 15.sp,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '$_counter',
                        style: TextStyle(
                          fontFamily: 'Digital7',
                          color: Colors.white,
                          fontSize: 92.sp,
                          height: 1.0,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            const Shadow(
                              color: Colors.black38,
                              offset: Offset(0, 6),
                              blurRadius: 12,
                            ),
                            Shadow(
                              color: Colors.white.withOpacity(0.2),
                              offset: Offset(-1, -1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          'COUNT'.tr,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Layer 5: Dynamic Orbiting Beads
            ...List.generate(3, (index) {
              return AnimatedBuilder(
                animation: _beadController,
                builder: (context, child) {
                  // Calculate dynamic rotation based on counter and bead controller
                  final double baseRotation = (index * 2 * 3.141592 / 3);
                  final double animRotation = _beadController.value * (2 * 3.141592 / 3);
                  final double totalRotation = baseRotation + animRotation;

                  return Transform.translate(
                    offset: Offset(
                      132.w * math.cos(totalRotation),
                      132.w * math.sin(totalRotation),
                    ),
                    child: Container(
                      width: 16.w,
                      height: 16.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [Colors.white, Colors.white.withOpacity(0.7)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.6),
                            blurRadius: 8,
                            spreadRadius: 1,
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls(bool isDark) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 40.w),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.02),
        borderRadius: BorderRadius.circular(35.r),
        border: Border.all(color: Colors.white.withOpacity(isDark ? 0.05 : 0.8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionBtn(
            icon: Icons.exposure_minus_1_rounded,
            color: Colors.orangeAccent,
            onTap: _decrementCounter,
          ),
          _buildActionBtn(
            icon: Icons.restart_alt_rounded,
            color: Colors.redAccent,
            onTap: _resetCounter,
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60.w,
        height: 60.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.12),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        ),
        child: Icon(icon, color: color, size: 28.sp),
      ),
    );
  }

}
