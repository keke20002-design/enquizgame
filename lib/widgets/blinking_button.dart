import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 깜빡이는 픽셀 버튼 (2프레임 애니메이션 + 도트 게임 스타일)
class BlinkingButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final List<Color>? gradientColors; // 그라데이션 색상 (선택)
  final double height;

  const BlinkingButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor = const Color(0xFF4ade80),
    this.gradientColors, // 그라데이션 색상 추가
    this.height = 80,
  });

  @override
  State<BlinkingButton> createState() => _BlinkingButtonState();
}

class _BlinkingButtonState extends State<BlinkingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final brightness = _animation.value;
        final currentColor = Color.lerp(
          widget.backgroundColor,
          Colors.white,
          1 - brightness,
        )!;

        return GestureDetector(
          onTapDown: (_) => setState(() => isPressed = true),
          onTapUp: (_) {
            setState(() => isPressed = false);
            widget.onPressed();
          },
          onTapCancel: () => setState(() => isPressed = false),
          child: Container(
            width: double.infinity,
            height: widget.height,
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              gradient: widget.gradientColors != null
                  ? LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: widget.gradientColors!.map((color) {
                        return Color.lerp(color, Colors.white, 1 - brightness)!;
                      }).toList(),
                    )
                  : null,
              color: widget.gradientColors == null ? currentColor : null,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.black,
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.6),
                  offset: isPressed ? const Offset(0, 3) : const Offset(0, 8),
                  blurRadius: 0, // 블러 없음 (픽셀 느낌)
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 도트 커서
                Text(
                  '▶',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.8),
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  widget.label,
                  style: GoogleFonts.pressStart2p(
                    fontSize: 18, // 16 → 18로 증가
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.8),
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
