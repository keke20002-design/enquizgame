import 'package:flutter/material.dart';

/// 간단한 스프라이트 애니메이션 위젯 (Image.asset 기반)
class SimpleSpriteAnimation extends StatefulWidget {
  final String assetPath;
  final int frameCount;
  final double frameWidth;
  final double frameHeight;
  final double stepTime;
  final double displayWidth;
  final double displayHeight;

  const SimpleSpriteAnimation({
    super.key,
    required this.assetPath,
    required this.frameCount,
    this.frameWidth = 64,
    this.frameHeight = 64,
    this.stepTime = 0.15,
    this.displayWidth = 64,
    this.displayHeight = 64,
  });

  @override
  State<SimpleSpriteAnimation> createState() => _SimpleSpriteAnimationState();
}

class _SimpleSpriteAnimationState extends State<SimpleSpriteAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentFrame = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: (widget.stepTime * widget.frameCount * 1000).toInt()),
      vsync: this,
    )..repeat();

    _controller.addListener(() {
      final newFrame = (_controller.value * widget.frameCount).floor() % widget.frameCount;
      if (newFrame != _currentFrame) {
        setState(() {
          _currentFrame = newFrame;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.displayWidth,
      height: widget.displayHeight,
      child: ClipRect(
        child: OverflowBox(
          alignment: Alignment.topLeft,
          child: Transform.translate(
            offset: Offset(-_currentFrame * widget.frameWidth, 0),
            child: Image.asset(
              widget.assetPath,
              width: widget.frameWidth * widget.frameCount,
              height: widget.frameHeight,
              fit: BoxFit.none,
            ),
          ),
        ),
      ),
    );
  }
}
