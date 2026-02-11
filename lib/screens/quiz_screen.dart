import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/game_provider.dart';
import '../providers/word_provider.dart';
import '../models/word_model.dart';
import '../widgets/pixel_button.dart';
import '../widgets/battle_animation_widget.dart';

/// ?�즈 ?�면
class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with SingleTickerProviderStateMixin {
  final FlutterTts _flutterTts = FlutterTts();
  List<String> _options = [];
  String? _selectedAnswer;
  bool _isAnswered = false;
  int _correctCount = 0;
  int _wrongCount = 0;
  int _consecutiveCorrect = 0; // Track consecutive correct answers
  bool _isAttacking = false;
  bool _isTakingDamage = false;
  
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // 퀴즈 시작 시 점수 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GameProvider>(context, listen: false).resetQuizScore();
    });
    
    _setupTts();
    _generateOptions();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }
  
  @override
  void dispose() {
    _flutterTts.stop();
    _animationController.dispose();
    super.dispose();
  }
  
  Future<void> _setupTts() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }
  
  void _generateOptions() {
    final wordProvider = context.read<WordProvider>();
    final currentWord = wordProvider.currentWord;
    
    if (currentWord == null) return;
    
    // ?�재 ?�어???�답
    final correctAnswer = currentWord.korean;
    
    // ?�른 ?�어?�에???�답 ?�택지 ?�성
    final otherWords = wordProvider.allWords
        .where((word) => word.english != currentWord.english)
        .toList();
    otherWords.shuffle();
    
    final wrongAnswers = otherWords
        .take(3)
        .map((word) => word.korean)
        .toList();
    
    // ?�답�??�답???�음
    _options = [correctAnswer, ...wrongAnswers];
    _options.shuffle();
    
    setState(() {});
  }
  
  Future<void> _speakWord(String word) async {
    await _flutterTts.speak(word);
  }
  
  void _checkAnswer(String selectedAnswer) {
    if (_isAnswered) return;
    
    final wordProvider = context.read<WordProvider>();
    final gameProvider = context.read<GameProvider>();
    final currentWord = wordProvider.currentWord;
    
    if (currentWord == null) return;
    
    setState(() {
      _selectedAnswer = selectedAnswer;
      _isAnswered = true;
    });
    
    final isCorrect = selectedAnswer == currentWord.korean;
    
    if (isCorrect) {
      _correctCount++;
      _consecutiveCorrect++; // Increment consecutive correct
      gameProvider.addExp(10);
      gameProvider.addCoins(5);
      gameProvider.addMasteredWord(currentWord.english);
      // Trigger attack animation
      setState(() => _isAttacking = true);
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() => _isAttacking = false);
      });
    } else {
      _wrongCount++;
      _consecutiveCorrect = 0; // Reset consecutive correct on wrong answer
      gameProvider.takeDamage(10);
      gameProvider.addWeakWord(currentWord.english);
      // Trigger damage animation
      setState(() => _isTakingDamage = true);
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() => _isTakingDamage = false);
      });
    }
    
    // 2�????�음 문제�?
    Future.delayed(const Duration(seconds: 2), () {
      if (wordProvider.hasMoreWords) {
        wordProvider.nextWord();
        setState(() {
          _selectedAnswer = null;
          _isAnswered = false;
        });
        _generateOptions();
      } else {
        _showResult();
      }
    });
  }
  
  void _showResult() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          'Quiz Complete!',
          style: GoogleFonts.pressStart2p(fontSize: 16), // 13 + 3
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Correct: $_correctCount',
              style: GoogleFonts.pressStart2p(fontSize: 13), // 10 + 3
            ),
            const SizedBox(height: 8),
            Text(
              'Wrong: $_wrongCount',
              style: GoogleFonts.pressStart2p(fontSize: 13), // 10 + 3
            ),
            const SizedBox(height: 8),
            Text(
              'Accuracy: ${(_correctCount / (_correctCount + _wrongCount) * 100).toStringAsFixed(1)}%',
              style: GoogleFonts.pressStart2p(fontSize: 13), // 10 + 3
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close quiz screen
            },
            child: Text(
              'OK',
              style: GoogleFonts.pressStart2p(fontSize: 13), // 10 + 3
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/pixel_battle_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Consumer<WordProvider>(
            builder: (context, wordProvider, child) {
              final currentWord = wordProvider.currentWord;
              
              if (currentWord == null) {
                return const Center(
                  child: Text(
                    '?�어가 ?�습?�다',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                );
              }
              
              return SingleChildScrollView(
                child: Column(
                  children: [
                    // ?�단 ?�태 �?(HP �?코인)
                    _StatusBar(),
                    
                    const SizedBox(height: 8),
                    
                    // ?�단 진행 �?
                    _ProgressBar(
                      current: wordProvider.currentWordIndex + 1,
                      total: wordProvider.currentQuizWords.length,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // ?�수 ?�시
                    _ScoreDisplay(
                      correct: _correctCount,
                      wrong: _wrongCount,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // ?�어 카드
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: _WordCard(
                        word: currentWord,
                        onSpeak: () => _speakWord(currentWord.english),
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // ?�택지
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: _options.map((option) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: PixelOptionButton(
                              option: option,
                              isSelected: _selectedAnswer == option,
                              isCorrect: option == currentWord.korean,
                              isAnswered: _isAnswered,
                              onPressed: () => _checkAnswer(option),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Battle animation widget
                    BattleAnimationWidget(
                      currentProgress: _correctCount + 1,
                      totalQuestions: wordProvider.currentQuizWords.length, // 동적 문항 수
                      isAttacking: _isAttacking,
                      isTakingDamage: _isTakingDamage,
                      consecutiveCorrect: _consecutiveCorrect, // Pass consecutive correct count
                      difficulty: wordProvider.currentDifficulty, // Pass difficulty
                    ),
                    
                    const SizedBox(height: 8),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// 진행 �?
class _ProgressBar extends StatelessWidget {
  final int current;
  final int total;

  const _ProgressBar({
    required this.current,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '문제 $current / $total',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: current / total,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}

/// ?�수 ?�시
class _ScoreDisplay extends StatelessWidget {
  final int correct;
  final int wrong;

  const _ScoreDisplay({
    required this.correct,
    required this.wrong,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ScoreBadge(
          icon: Icons.check_circle,
          color: Colors.green,
          count: correct,
        ),
        const SizedBox(width: 20),
        _ScoreBadge(
          icon: Icons.cancel,
          color: Colors.red,
          count: wrong,
        ),
      ],
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final int count;

  const _ScoreBadge({
    required this.icon,
    required this.color,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 36), // 28 → 36 (크기 증가)
          const SizedBox(width: 10),
          Text(
            '$count',
            style: GoogleFonts.pressStart2p(
              color: Colors.white,
              fontSize: 32, // 24 → 32 (크기 증가)
              fontWeight: FontWeight.bold,
              shadows: [
                const Shadow(
                  color: Colors.black,
                  offset: Offset(3, 3),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ?�어 카드
class _WordCard extends StatelessWidget {
  final WordModel word;
  final VoidCallback onSpeak;

  const _WordCard({
    required this.word,
    required this.onSpeak,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF3DB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF8B6F47),
          width: 7, //card width
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            offset: const Offset(4, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            word.english,
            style: GoogleFonts.pressStart2p(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF5C4A33),
            ),
          ),
          const SizedBox(height: 8),
          IconButton(
            icon: const Icon(
              Icons.volume_up,
              size: 32,
              color: Color(0xFF8B6F47),
            ),
            onPressed: onSpeak,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          if (word.examples.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              word.examples.first,
              style: const TextStyle(
                fontSize: 18, ///예문 사이즈
                color: Color(0xFF6B7280),
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
 


/// 상단 상태 바(HP 및 점수)
class _StatusBar extends StatelessWidget {
  const _StatusBar();

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final gameState = gameProvider.gameState;
        
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // HP 바 - 화면 절반 정도 크기
              Flexible(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.favorite, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: gameState.currentHp / gameState.maxHp,
                            backgroundColor: Colors.red.shade900,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                            minHeight: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // 점수 표시 (코인 대신)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.amber, width: 2),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 32), // 크기 증가
                    const SizedBox(width: 8),
                    Text(
                      '${gameState.coins}', // 점수로 사용
                      style: GoogleFonts.pressStart2p(
                        color: Colors.white,
                        fontSize: 28, // 크기 증가
                        fontWeight: FontWeight.bold,
                        shadows: [
                          const Shadow(
                            color: Colors.black,
                            offset: Offset(2, 2),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
