import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _TasbihScreenState extends State<TasbihScreen> with SingleTickerProviderStateMixin {
  int _counter = 0;
  int _totalCount = 0;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _loadTotalCount();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
  }

  Future<void> _loadTotalCount() async {
    final count = await SettingsService.getTasbihTotalCount();
    setState(() {
      _totalCount = count;
    });
  }

  void _incrementCounter() {
    HapticFeedback.lightImpact();
    _animationController.forward().then((_) => _animationController.reverse());
    setState(() {
      _counter++;
      _totalCount++;
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

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;
    final darkPrimaryColor = HSLColor.fromColor(
      primaryColor,
    ).withLightness((HSLColor.fromColor(primaryColor).lightness - 0.2).clamp(0.0, 1.0)).toColor();

    return Scaffold(
      appBar: CommonAppBar(
        title: 'Tasbih'.tr,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: _resetTotalCount,
            tooltip: 'Reset Total Count',
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [theme.scaffoldBackgroundColor, theme.colorScheme.primary.withOpacity(0.05)],
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 20.h),
            // Total Count Card
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: primaryColor.withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TrText(
                          'Total Count',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        Text(
                          '$_totalCount',
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                    Icon(Icons.auto_graph, color: primaryColor, size: 30.sp),
                  ],
                ),
              ),
            ),
            const Spacer(),
            // Main Counter Circle
            GestureDetector(
              onTap: _incrementCounter,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return ScaleTransition(
                    scale: _scaleAnimation,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Hyper-glow behind the button
                        Container(
                          width: 270.w,
                          height: 270.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.3),
                                blurRadius: 40,
                                spreadRadius: -5,
                              ),
                            ],
                          ),
                        ),
                        // Rotating Ring (Bead effect)
                        RotationTransition(
                          turns: AlwaysStoppedAnimation(_counter / 33),
                          child: Container(
                            width: 260.w,
                            height: 260.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: primaryColor.withOpacity(0.1), width: 8.w),
                            ),
                          ),
                        ),
                        // Main Premium Button Body
                        Container(
                          width: 230.w,
                          height: 230.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                primaryColor.withOpacity(0.9),
                                primaryColor,
                                darkPrimaryColor,
                              ],
                              stops: const [0, 0.6, 1],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                              BoxShadow(
                                color: Colors.white.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, -5),
                              ),
                            ],
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withOpacity(0.1), width: 2),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TrText(
                                  'Daily Count',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 2,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(vertical: 4.h),
                                  child: Text(
                                    '$_counter',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 80.sp,
                                      fontWeight: FontWeight.w900,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.3),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const Spacer(),
            // Premium Controls
            Padding(
              padding: EdgeInsets.only(bottom: 60.h),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 20.h),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.02),
                  borderRadius: BorderRadius.circular(40.r),
                  border: Border.all(
                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Fancy Minus
                    _buildControlButton(
                      icon: Icons.remove_circle_outline,
                      label: 'Minus',
                      onTap: _decrementCounter,
                      color: Colors.orange.shade400,
                    ),
                    SizedBox(width: 50.w),
                    // Fancy Reset
                    _buildControlButton(
                      icon: Icons.refresh_rounded,
                      label: 'Reset',
                      onTap: _resetCounter,
                      color: Colors.red.shade400,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTapDown: (_) => HapticFeedback.lightImpact(),
          onTap: onTap,
          child: Container(
            width: 65.w,
            height: 65.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color.withOpacity(0.2), color.withOpacity(0.05)],
              ),
              border: Border.all(color: color.withOpacity(0.3), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 28.sp),
          ),
        ),
        SizedBox(height: 10.h),
        TrText(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            color: color.withOpacity(0.9),
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
