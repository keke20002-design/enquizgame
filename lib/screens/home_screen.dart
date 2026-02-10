import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/game_provider.dart';
import '../providers/word_provider.dart';
import '../widgets/pixel_button.dart';
import '../widgets/horizontal_slide_selector.dart';
import '../widgets/blinking_button.dart';
import 'quiz_screen.dart';

/// 메인 홈 화면
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedDifficulty = 1; // 1: Easy, 2: Medium, 3: Hard
  int _selectedQuestionCount = 10; // 10, 15, or 20

  final List<String> _difficultyLabels = ['쉬움', '보통', '어려움'];
  final List<int> _questionCounts = [10, 15, 20];
  
  // 난이도별 색상 (초록/노랑/빨강)
  final List<Color> _difficultyColors = [
    const Color(0xFF4ade80), // Green - Easy
    const Color(0xFFfbbf24), // Yellow - Medium
    const Color(0xFFef4444), // Red - Hard
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/pixel_background_home.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              children: [
                // 타이틀
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'WORD QUEST',
                      style: GoogleFonts.pressStart2p(
                        fontSize: 24, // 20 → 24로 증가
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 8,
                            color: _difficultyColors[0],
                            offset: const Offset(0, 0),
                          ),
                          const Shadow(
                            color: Colors.black,
                            offset: Offset(3, 3),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // UI Section with semi-transparent background
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      // 1. 모험 시작 버튼 (가장 큰 버튼, 깜빡임) - 연두색 그라데이션
                      BlinkingButton(
                        label: '모험 시작',
                        gradientColors: const [
                          Color(0xFF8EEA8B), // 밝은 연두
                          Color(0xFF4CAF50), // 진한 초록
                        ],
                        height: 80,
                        onPressed: () => _startQuiz(context),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // 2. 난이도 선택 (가로 슬라이드) - 연초록 그라데이션
                      HorizontalSlideSelector(
                        label: '난이도',
                        options: _difficultyLabels,
                        selectedIndex: _selectedDifficulty - 1,
                        gradientColors: const [
                          Color(0xFF8EEA8B), // 밝은 연초록
                          Color(0xFF4CAF50), // 진한 초록
                        ],
                        onPrevious: () {
                          setState(() {
                            if (_selectedDifficulty > 1) _selectedDifficulty--;
                          });
                        },
                        onNext: () {
                          setState(() {
                            if (_selectedDifficulty < 3) _selectedDifficulty++;
                          });
                        },
                      ),
                      
                      const SizedBox(height: 19),
                      
                      // 3. 문항 수 선택 (가로 슬라이드) - 하늘색 그라데이션
                      HorizontalSlideSelector(
                        label: '문항 수',
                        options: _questionCounts.map((count) => '$count 문제').toList(),
                        selectedIndex: _questionCounts.indexOf(_selectedQuestionCount),
                        gradientColors: const [
                          Color(0xFF6EC6FF), // 밝은 하늘색
                          Color(0xFF1E88E5), // 진한 파랑
                        ],
                        onPrevious: () {
                          setState(() {
                            int currentIndex = _questionCounts.indexOf(_selectedQuestionCount);
                            if (currentIndex > 0) {
                              _selectedQuestionCount = _questionCounts[currentIndex - 1];
                            }
                          });
                        },
                        onNext: () {
                          setState(() {
                            int currentIndex = _questionCounts.indexOf(_selectedQuestionCount);
                            if (currentIndex < _questionCounts.length - 1) {
                              _selectedQuestionCount = _questionCounts[currentIndex + 1];
                            }
                          });
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // 4. 복습하기 버튼 - 노란색 그라데이션
                      PixelButton(
                        label: '복습하기',
                        icon: Icons.menu_book,
                        gradientColors: const [
                          Color(0xFFFFE082), // 밝은 노랑
                          Color(0xFFFBC02D), // 진한 노랑
                        ],
                        borderColor: const Color(0xFF000000),
                        height: 56,
                        onPressed: () => _startReview(context),
                      ),
                      
                      const SizedBox(height: 14),
                      
                      // 5. 통계 버튼 - 핑크/보라 그라데이션
                      PixelButton(
                        label: '학습 통계',
                        icon: Icons.bar_chart,
                        gradientColors: const [
                          Color(0xFFE1BEE7), // 밝은 핑크
                          Color(0xFFBA68C8), // 진한 보라
                        ],
                        borderColor: const Color(0xFF000000),
                        height: 56,
                        onPressed: () => _showStats(context),
                      ),
                    ],
                  ),
                ),
                
                // Bottom spacer to keep character area visible
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  void _startQuiz(BuildContext context) {
    final wordProvider = context.read<WordProvider>();
    
    // 선택한 난이도와 문항 수로 퀴즈 설정
    wordProvider.setupQuiz(
      difficulty: _selectedDifficulty,
      count: _selectedQuestionCount,
    );
    
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QuizScreen()),
    );
  }
  
  void _startReview(BuildContext context) {
    final gameProvider = context.read<GameProvider>();
    final wordProvider = context.read<WordProvider>();
    
    if (gameProvider.gameState.weakWords.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '복습할 단어가 없습니다!',
            style: GoogleFonts.pressStart2p(fontSize: 10),
          ),
          backgroundColor: const Color(0xFF6b7280),
        ),
      );
      return;
    }
    
    // 약한 단어들로 퀴즈 설정
    wordProvider.setupReviewQuiz(gameProvider.gameState.weakWords);
    
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QuizScreen()),
    );
  }
  
  void _showStats(BuildContext context) {
    final gameProvider = context.read<GameProvider>();
    final gameState = gameProvider.gameState;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1f2e),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: Colors.white, width: 3),
        ),
        title: Text(
          '학습 통계',
          style: GoogleFonts.pressStart2p(
            fontSize: 14,
            color: Colors.white,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StatRow('레벨', '${gameState.currentLevel}'),
            const SizedBox(height: 8),
            _StatRow('경험치', '${gameState.totalExp}'),
            const SizedBox(height: 8),
            _StatRow('코인', '${gameState.coins}'),
            const SizedBox(height: 16),
            _StatRow('마스터', '${gameState.masteredWords.length}개'),
            const SizedBox(height: 8),
            _StatRow('약한 단어', '${gameState.weakWords.length}개'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '확인',
              style: GoogleFonts.pressStart2p(
                fontSize: 10,
                color: const Color(0xFF4ade80),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 통계 행
class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.pressStart2p(
            fontSize: 10,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.pressStart2p(
            fontSize: 10,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
