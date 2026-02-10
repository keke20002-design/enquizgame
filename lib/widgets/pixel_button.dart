import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 픽셀 아트 스타일 버튼 위젯 (도트 게임 스타일)
class PixelButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final Color backgroundColor;
  final Color borderColor;
  final List<Color>? gradientColors; // 그라데이션 색상 (선택)
  final VoidCallback onPressed;
  final double height;

  const PixelButton({
    super.key,
    required this.label,
    this.icon,
    this.backgroundColor = const Color(0xFF8B6F47),
    this.borderColor = const Color(0xFF000000),
    this.gradientColors, // 그라데이션 색상 추가
    required this.onPressed,
    this.height = 60,
  });

  @override
  State<PixelButton> createState() => _PixelButtonState();
}

class _PixelButtonState extends State<PixelButton> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
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
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          gradient: widget.gradientColors != null
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: widget.gradientColors!,
                )
              : null,
          color: widget.gradientColors == null ? widget.backgroundColor : null,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.borderColor,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              offset: isPressed ? const Offset(0, 2) : const Offset(0, 6),
              blurRadius: 0, // 블러 없음 (픽셀 느낌)
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.icon != null) ...[
              Icon(widget.icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              widget.label,
              style: GoogleFonts.pressStart2p(
                fontSize: 18, // 12 → 14로 증가
                color: Colors.white,
               //fontFamily: 'Galmuri', // 도트 폰트
                fontWeight: FontWeight.bold,
                shadows: [
                  const Shadow(
                    color: Colors.black,
                    offset: Offset(2, 2),
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

/// 픽셀 아트 스타일 옵션 버튼 (퀴즈용)
class PixelOptionButton extends StatelessWidget {
  final String option;
  final bool isSelected;
  final bool isCorrect;
  final bool isAnswered;
  final VoidCallback onPressed;

  const PixelOptionButton({
    super.key,
    required this.option,
    required this.isSelected,
    required this.isCorrect,
    required this.isAnswered,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = const Color(0xFF6B7280); // Gray
    Color borderColor = const Color(0xFF4B5563);
    
    if (isAnswered) {
      if (isSelected) {
        if (isCorrect) {
          backgroundColor = const Color(0xFF10B981); // Green
          borderColor = const Color(0xFF059669);
        } else {
          backgroundColor = const Color(0xFFEF4444); // Red
          borderColor = const Color(0xFFDC2626);
        }
      } else if (isCorrect) {
        backgroundColor = const Color(0xFF10B981); // Green
        borderColor = const Color(0xFF059669);
      }
    }
    
    return SizedBox(
      width: double.infinity,
      height: 45,
      child: Stack(
        children: [
          // Shadow
          Positioned(
            left: 3,
            top: 3,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: borderColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          // Main button
          Positioned(
            left: 0,
            top: 0,
            right: 3,
            bottom: 3,
            child: Material(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(4),
              child: InkWell(
                onTap: isAnswered ? null : onPressed,
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: borderColor,
                      width: 3,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      option,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
