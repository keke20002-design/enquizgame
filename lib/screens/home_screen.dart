import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/game_provider.dart';
import '../providers/word_provider.dart';
import 'quiz_screen.dart';

/// 메인 홈 화면 - 심플한 카드 기반 UI (배경 포함)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedDifficulty = '쉬움';
  int _selectedQuestionCount = 10;

  final List<String> _difficultyOptions = ['쉬움', '보통', '어려움'];
  final List<int> _questionCountOptions = [5, 10, 20];

  int get _difficultyLevel {
    return _difficultyOptions.indexOf(_selectedDifficulty) + 1;
  }

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
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 타이틀
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
                  ),
                  child: Text(
                    'WORD QUEST',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.pressStart2p(
                      fontSize: 28,
                      color: const Color(0xFF4CAF50),
                      shadows: [
                        Shadow(
                          blurRadius: 8,
                          color: const Color(0xFF4CAF50).withValues(alpha: 0.5),
                          offset: const Offset(0, 0),
                        ),
                        const Shadow(
                          blurRadius: 4,
                          color: Colors.black,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                // 게임 시작 버튼 (가장 크고 눈에 띄게)
                SizedBox(
                  height: 64,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.play_arrow, size: 32),
                    label: Text(
                      '게임 시작',
                      style: GoogleFonts.notoSans(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      elevation: 8,
                      shadowColor: Colors.black.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => _startQuiz(context),
                  ),
                ),

                const SizedBox(height: 32),

                // 설정 카드
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // 난이도 설정
                        _SettingRow(
                          title: '난이도',
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButton<String>(
                              value: _selectedDifficulty,
                              underline: Container(),
                              dropdownColor: const Color(0xFF1a1f2e),
                              style: GoogleFonts.notoSans(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                              items: _difficultyOptions
                                  .map((difficulty) => DropdownMenuItem(
                                        value: difficulty,
                                        child: Text(difficulty),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedDifficulty = value;
                                  });
                                }
                              },
                            ),
                          ),
                        ),

                        Divider(height: 32, color: Colors.white.withValues(alpha: 0.2)),

                        // 문항 수 설정
                        _SettingRow(
                          title: '문항 수',
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButton<int>(
                              value: _selectedQuestionCount,
                              underline: Container(),
                              dropdownColor: const Color(0xFF1a1f2e),
                              style: GoogleFonts.notoSans(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                              items: _questionCountOptions
                                  .map((count) => DropdownMenuItem(
                                        value: count,
                                        child: Text('$count 문제'),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedQuestionCount = value;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // 하단 버튼 (복습하기, 학습 통계)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.menu_book),
                        label: Text(
                          '복습하기',
                          style: GoogleFonts.notoSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFFBC02D),
                          backgroundColor: Colors.black.withValues(alpha: 0.3),
                          side: const BorderSide(
                            color: Color(0xFFFBC02D),
                            width: 2,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => _startReview(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.bar_chart),
                        label: Text(
                          '학습 통계',
                          style: GoogleFonts.notoSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF9C27B0),
                          backgroundColor: Colors.black.withValues(alpha: 0.3),
                          side: const BorderSide(
                            color: Color(0xFF9C27B0),
                            width: 2,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => _showStats(context),
                      ),
                    ),
                  ],
                ),
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
      difficulty: _difficultyLevel,
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
            style: GoogleFonts.notoSans(fontSize: 14),
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
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.white, width: 2),
        ),
        title: Text(
          '학습 통계',
          style: GoogleFonts.notoSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StatRow('레벨', '${gameState.currentLevel}'),
            const SizedBox(height: 12),
            _StatRow('경험치', '${gameState.totalExp}'),
            const SizedBox(height: 12),
            _StatRow('코인', '${gameState.coins}'),
            const SizedBox(height: 20),
            _StatRow('마스터한 단어', '${gameState.masteredWords.length}개'),
            const SizedBox(height: 12),
            _StatRow('약한 단어', '${gameState.weakWords.length}개'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '확인',
              style: GoogleFonts.notoSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF4CAF50),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 설정 행 위젯
class _SettingRow extends StatelessWidget {
  final String title;
  final Widget child;

  const _SettingRow({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.notoSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        child,
      ],
    );
  }
}

/// 통계 행 위젯
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
          style: GoogleFonts.notoSans(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
