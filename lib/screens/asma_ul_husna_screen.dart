import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:namaz_timetable/data/asma_ul_husna_data.dart';

class AsmaUlHusnaScreen extends StatefulWidget {
  const AsmaUlHusnaScreen({super.key});

  @override
  State<AsmaUlHusnaScreen> createState() => _AsmaUlHusnaScreenState();
}

class _AsmaUlHusnaScreenState extends State<AsmaUlHusnaScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
  }

  Future<void> _initAudioPlayer() async {
    await _audioPlayer.setAudioContext(
      AudioContext(
        android: AudioContextAndroid(
          usageType: AndroidUsageType.media,
          audioFocus: AndroidAudioFocus.gain,
        ),
        iOS: AudioContextIOS(category: AVAudioSessionCategory.playback),
      ),
    );
    await _audioPlayer.setSource(AssetSource('sounds/asma_ul_husna.mp3'));
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _toggleAudio() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      setState(() => _isPlaying = false);
    } else {
      try {
        setState(() => _isPlaying = true);
        if (_audioPlayer.state == PlayerState.paused ||
            _audioPlayer.state == PlayerState.completed) {
          await _audioPlayer.resume();
        } else {
          await _audioPlayer.play(AssetSource('sounds/asma_ul_husna.mp3'));
        }
      } catch (e) {
        setState(() => _isPlaying = false);
        if (mounted) {
          Get.snackbar(
            'Error',
            'Could not load audio. Please check your internet connection.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
        }
      }
    }

    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) setState(() => _isPlaying = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final names = AsmaUlHusnaData.names;

    return Scaffold(
      appBar: AppBar(
        title: Text("99 Names of Allah"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
              color: theme.colorScheme.primary,
              size: 32.w,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              _toggleAudio();
            },
          ),
          SizedBox(width: 16.w),
        ],
      ),
      body: Stack(
        children: [
          // Background Watermark
          Positioned(
            right: -50.w,
            bottom: -50.w,
            child: Icon(
              Icons.mosque,
              size: 250.w,
              color: theme.primaryColor.withOpacity(isDark ? 0.03 : 0.05),
            ),
          ),
          GridView.builder(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8.w,
              mainAxisSpacing: 8.h,
              childAspectRatio: 0.85,
            ),
            itemCount: names.length,
            itemBuilder: (context, index) {
              final nameData = names[index];
              return _buildNameCard(
                context,
                nameData,
                index + 1,
                theme,
                isDark,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNameCard(
    BuildContext context,
    Map<String, String> data,
    int index,
    ThemeData theme,
    bool isDark,
  ) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        Get.snackbar(
          data['transliteration']!,
          data['meaning']!,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: theme.colorScheme.primary.withOpacity(0.9),
          colorText: Colors.white,
          margin: EdgeInsets.all(16.w),
          borderRadius: 16.r,
        );
      },
      borderRadius: BorderRadius.circular(15.r),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(15.r),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(isDark ? 0.2 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: theme.colorScheme.primary.withOpacity(0.1)),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 5.h,
              left: 5.w,
              child: Container(
                width: 20.w,
                height: 20.w,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  index.toString(),
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 8.w,
                  right: 8.w,
                  top: 16.h,
                  bottom: 4.h,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        data['arabic']!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26.sp,
                          fontFamily:
                              'Amiri', // assuming amiri is used for arabic
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        data['transliteration']!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      data['meaning']!,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.sp,
                        height: 1.1,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
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
}
