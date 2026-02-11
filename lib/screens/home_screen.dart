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
  bool _showSettings = false; // 설정 표시 여부

  final List<String> _difficultyOptions = ['쉬움', '보통', '어려움'];
  final List<int> _questionCountOptions = [10, 15, 20];

  int get _difficultyLevel {
    return _difficultyOptions.indexOf(_selectedDifficulty) + 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 배경
          Positioned.fill(
            child: Image.asset(
              'assets/images/pixel_background_home.png',
              fit: BoxFit.cover,
            ),
          ),

          // ✨ 알파벳 & 별 애니메이션
          const FloatingMagicLayer(),

          // 기존 UI (타이틀 + 버튼)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 타이틀
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    // decoration: BoxDecoration(
                    //   color: Colors.black.withValues(alpha: 0.7),
                    //   borderRadius: BorderRadius.circular(12),
                    //   border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
                    // ),
                    child: Text(
                      'WORD QUEST',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.pressStart2p(
                        fontSize: 34,
                        color: const Color(0xFFFFD700),//(0xFF4CAF50),
                        shadows: [
                          Shadow(
                            blurRadius: 8,
                            color: const Color(0xFFFFD700).withValues(alpha: 0.5),
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
                        '게임시작',
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

                  const SizedBox(height: 16),

                  // 설정 버튼
                  SizedBox(
                    height: 64,
                    child: ElevatedButton.icon(
                      icon: Icon(_showSettings ? Icons.settings : Icons.settings_outlined, size: 32),
                      label: Text(
                        '설정',
                        style: GoogleFonts.notoSans(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        foregroundColor: Colors.white,
                        elevation: 8,
                        shadowColor: Colors.black.withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _showSettings = !_showSettings;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 설정 카드 (토글 가능)
                  if (_showSettings)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white, // #FFFFFF - 흰색 배경
                      borderRadius: BorderRadius.circular(14), // 둥근 모서리
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15), // 약한 그림자
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Column(
                        children: [
                          // 난이도 설정
                          _SettingRow(
                            title: '난이도',
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF8E1), // 연한 아이보리
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButton<String>(
                                value: _selectedDifficulty,
                                underline: Container(),
                                dropdownColor: Colors.white,
                                style: GoogleFonts.notoSans(
                                  fontSize: 16,
                                  color: const Color(0xFF5B3A1D), // 진한 갈색
                                  fontWeight: FontWeight.bold,
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

                          Divider(height: 32, color: Colors.grey.shade300),

                          // 문항 수 설정
                          _SettingRow(
                            title: '문항 수',
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF8E1), // 연한 아이보리
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButton<int>(
                                value: _selectedQuestionCount,
                                underline: Container(),
                                dropdownColor: Colors.white,
                                style: GoogleFonts.notoSans(
                                  fontSize: 16,
                                  color: const Color(0xFF5B3A1D), // 진한 갈색
                                  fontWeight: FontWeight.bold,
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
                        child: InkWell(
                          onTap: () => _startReview(context),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFDF6D8), // #fdf6d8 - 연한 베이지
                              border: Border.all(
                                color: const Color(0xFF5B3A1D), // #5b3a1d - 진한 갈색
                                width: 3,
                              ),
                              borderRadius: BorderRadius.zero, // 픽셀 스타일 - 각진 모서리
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.menu_book,
                                  color: Color(0xFF5B3A1D),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '복습하기',
                                  style: GoogleFonts.notoSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF5B3A1D),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () => _showStats(context),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFDF6D8), // #fdf6d8 - 연한 베이지
                              border: Border.all(
                                color: const Color(0xFF5B3A1D), // #5b3a1d - 진한 갈색
                                width: 3,
                              ),
                              borderRadius: BorderRadius.zero, // 픽셀 스타일 - 각진 모서리
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.bar_chart,
                                  color: Color(0xFF5B3A1D),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '학습 통계',
                                  style: GoogleFonts.notoSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF5B3A1D),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
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
            fontWeight: FontWeight.bold,
            color: const Color(0xFF5B3A1D), // 진한 갈색
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

class FloatingMagicLayer extends StatelessWidget {
  const FloatingMagicLayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 40,
      left: 0,
      right: 0,
      child: SizedBox(
        height: 140,
        child: Stack(
          children: const [
            FloatingLetter(text: 'SPELL', left: 60, delay: 0,color: Colors.purpleAccent),
            FloatingLetter(text: 'QUIZ', left: 160, delay: 1,color: Colors.cyanAccent),
            FloatingLetter(text: 'ATTACK', left: 280, delay: 2,color: Colors.redAccent),

            FloatingLetter(text: 'POWER', left: 550, delay: 0,color: Colors.yellowAccent),
            FloatingLetter(text: 'LEVEL', left: 670, delay: 1,color: Colors.greenAccent),
            FloatingLetter(text: 'UP!', left: 770, delay: 2,color:Colors.redAccent),

            FloatingStar(left: 40, top: 30, delay: 0, size: 18),
            FloatingStar(left: 120, top: 20, delay: 1, size: 22),
            FloatingStar(left: 200, top: 40, delay: 2, size: 16),
            FloatingStar(left: 280, top: 25, delay: 3, size: 20),
            FloatingStar(left: 340, top: 35, delay: 4, size: 18),

            FloatingStar(left: 510, top: 30, delay: 0, size: 18),
            FloatingStar(left: 570, top: 20, delay: 1, size: 22),
            FloatingStar(left: 650, top: 40, delay: 2, size: 16),
            FloatingStar(left: 720, top: 25, delay: 3, size: 20),
            FloatingStar(left: 830, top: 35, delay: 4, size: 18),
          ],
        ),
      ),
    );
  }
}

class FloatingLetter extends StatefulWidget {
  final String text;
  final double left;
  final int delay;
  final Color color;

  const FloatingLetter({
    super.key,
    required this.text,
    required this.left,
    required this.delay,
    this.color = Colors.white,
  });

  @override
  State<FloatingLetter> createState() => _FloatingLetterState();
}

class _FloatingLetterState extends State<FloatingLetter>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    animation = Tween<double>(begin: 0, end: -12)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(controller);

    Future.delayed(Duration(seconds: widget.delay), () {
      if (mounted) controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      child: Text(
        widget.text,
        style: const TextStyle(
          fontSize: 24,
          color: Colors.white,
          // fontFamily: 'Galmuri', // Removed since it might not be available, using default
          shadows: [
            Shadow(color: Colors.black, offset: Offset(2, 2)),
          ],
        ),
      ),
      builder: (context, child) {
        return Positioned(
          left: widget.left,
          top: 60 + animation.value,
          child: Opacity(
            opacity: 0.8,
              child: Text(   // 👈👈 바로 여기!!
              widget.text,
              style: TextStyle( // 👈 TextStyle 적용 위치
                fontSize: 20,
                color: widget.color, // 👈 색 여기서 먹음
                fontFamily: 'Galmuri',
                shadows: const [
                  Shadow(
                    color: Colors.black,
                    offset: Offset(2, 2),
          ),
                ],
              ),
          ),
        ),
          );      },
    );
  }
}


class FloatingStar extends StatefulWidget {
  final double left;
  final double top;
  final int delay;
  final double size;

  const FloatingStar({
    super.key,
    required this.left,
    required this.top,
    required this.delay,
    this.size = 20,
  });

  @override
  State<FloatingStar> createState() => _FloatingStarState();
}

class _FloatingStarState extends State<FloatingStar>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    Future.delayed(Duration(milliseconds: 400 * widget.delay), () {
      if (mounted) {
        controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.left,
      top: widget.top,
      child: FadeTransition(
        opacity: Tween(begin: 0.3, end: 1.0).animate(
          CurvedAnimation(parent: controller, curve: Curves.easeInOut),
        ),
        child: Icon(
          Icons.star,
          size: widget.size,
          color: Colors.yellowAccent,
          shadows: const [
            Shadow(
              color: Colors.black54,
              offset: Offset(1, 1),
            ),
          ],
        ),
      ),
    );
  }
}
