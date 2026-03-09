import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ScrollTicker extends StatefulWidget {
  final String message;
  const ScrollTicker({required this.message, super.key});

  @override
  State<ScrollTicker> createState() => _ScrollTickerState();
}

class _ScrollTickerState extends State<ScrollTicker> {
  late final ScrollController _controller;
  late final double scrollWidth;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScrolling());
  }

  void _startScrolling() {
    // Start a periodic timer for smooth scroll
    Future.doWhile(() async {
      if (!mounted || !_controller.hasClients) return false;

      final distance = _controller.position.maxScrollExtent;
      // Dynamic duration based on the text length (approx 10 pixels per second for even slower reading speed)
      final int durationSeconds = (distance / 20).ceil() > 0 ? (distance / 20).ceil() : 50;

      await _controller.animateTo(
        distance,
        duration: Duration(seconds: durationSeconds),
        curve: Curves.linear,
      );

      if (_controller.hasClients) {
        _controller.jumpTo(0);
      }

      await Future.delayed(const Duration(milliseconds: 2000));
      return true;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35.h,
      color: Colors.red.shade900,
      child: ListView(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        children: [
          Center(
            child: Text(
              widget.message,
              style: TextStyle(color: Colors.white, fontSize: 16.sp, fontStyle: FontStyle.italic),
            ),
          ),
          SizedBox(width: 100.w), // Spacing at the end
        ],
      ),
    );
  }
}
