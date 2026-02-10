import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 가로 슬라이드 선택 위젯 (픽셀 스타일)
class HorizontalSlideSelector extends StatelessWidget {
  final String label;
  final List<String> options;
  final int selectedIndex;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final Color? backgroundColor;
  final List<Color>? optionColors; // 각 옵션별 색상 (난이도용)
  final List<Color>? gradientColors; // 그라데이션 색상 (선택)

  const HorizontalSlideSelector({
    super.key,
    required this.label,
    required this.options,
    required this.selectedIndex,
    required this.onPrevious,
    required this.onNext,
    this.backgroundColor,
    this.optionColors,
    this.gradientColors, // 그라데이션 색상 추가
  });

  @override
  Widget build(BuildContext context) {
    final currentColor = optionColors != null && selectedIndex < optionColors!.length
        ? optionColors![selectedIndex]
        : backgroundColor ?? const Color(0xFF6b7280);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 라벨
        Text(
          label,
          style: GoogleFonts.pressStart2p(
            fontSize: 13, // 10 → 13으로 증가
            color: Colors.white,
            shadows: [
              const Shadow(
                blurRadius: 4,
                color: Colors.black,
                offset: Offset(2, 2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        
        // 선택기
        Container(
          height: 56, // 52 → 56으로 증가
          decoration: BoxDecoration(
            gradient: gradientColors != null
                ? LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: gradientColors!,
                  )
                : null,
            color: gradientColors == null ? currentColor : null,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.black,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                offset: const Offset(0, 5),
                blurRadius: 0, // 블러 없음 (픽셀 느낌)
              ),
            ],
          ),
          child: Row(
            children: [
              // 왼쪽 화살표
              _ArrowButton(
                icon: '◀',
                onPressed: selectedIndex > 0 ? onPrevious : null,
              ),
              
              // 현재 선택값
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.2),
                    border: const Border(
                      left: BorderSide(color: Colors.black, width: 2),
                      right: BorderSide(color: Colors.black, width: 2),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      options[selectedIndex],
                      style: GoogleFonts.pressStart2p(
                        fontSize: 14, // 12 → 14로 증가
                        color: Colors.white,
                        shadows: [
                          const Shadow(
                            color: Colors.black,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
              // 오른쪽 화살표
              _ArrowButton(
                icon: '▶',
                onPressed: selectedIndex < options.length - 1 ? onNext : null,
              ),
            ],
          ),
        ),
        
        // 도트 인디케이터
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(options.length, (index) {
            final isSelected = index == selectedIndex;
            final dotColor = optionColors != null && index < optionColors!.length
                ? optionColors![index]
                : Colors.white;
            
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isSelected ? 12 : 8,
              height: isSelected ? 12 : 8,
              decoration: BoxDecoration(
                color: isSelected ? dotColor : Colors.white.withValues(alpha: 0.3),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.black,
                  width: 2,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

/// 화살표 버튼
class _ArrowButton extends StatelessWidget {
  final String icon;
  final VoidCallback? onPressed;

  const _ArrowButton({
    required this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            border: Border(
              right: icon == '◀' ? const BorderSide(color: Colors.black, width: 2) : BorderSide.none,
              left: icon == '▶' ? const BorderSide(color: Colors.black, width: 2) : BorderSide.none,
            ),
          ),
          child: Center(
            child: Text(
              icon,
              style: TextStyle(
                fontSize: 20,
                color: onPressed != null ? Colors.white : Colors.white.withValues(alpha: 0.3),
                shadows: const [
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
    );
  }
}
