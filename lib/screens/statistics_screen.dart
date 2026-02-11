import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/statistics_provider.dart';
import '../models/word_proficiency_model.dart';
import 'dart:math' as math;

/// 학습 통계 화면
class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '학습 통계',
          style: GoogleFonts.notoSans(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: Consumer<StatisticsProvider>(
        builder: (context, statsProvider, child) {
          final stats = statsProvider.statistics;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1️⃣ 기본 성취 지표
                _buildAchievementMetrics(stats, statsProvider),
                
                const SizedBox(height: 24),
                
                // 2️⃣ 단어별 숙련도
                _buildWordProficiencySection(statsProvider),
                
                const SizedBox(height: 24),
                
                // 3️⃣ 오답 분석
                _buildErrorAnalysisSection(statsProvider),
                
                const SizedBox(height: 24),
                
                // 4️⃣ 난이도별 성과
                _buildDifficultyPerformanceSection(statsProvider),
                
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 1️⃣ 기본 성취 지표
  Widget _buildAchievementMetrics(stats, StatisticsProvider statsProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '📊 성취 지표',
          style: GoogleFonts.notoSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            // 전체 정답률
            Expanded(
              child: _MetricCard(
                icon: Icons.check_circle,
                iconColor: Colors.green,
                title: '정답률',
                value: '${(stats.overallAccuracyRate * 100).toStringAsFixed(1)}%',
                showProgress: true,
                progressValue: stats.overallAccuracyRate,
              ),
            ),
            const SizedBox(width: 12),
            // 총 푼 문제 수
            Expanded(
              child: _MetricCard(
                icon: Icons.quiz,
                iconColor: Colors.blue,
                title: '푼 문제',
                value: '${stats.totalQuestionsAnswered}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // 최고 연속 정답
            Expanded(
              child: _MetricCard(
                icon: Icons.local_fire_department,
                iconColor: Colors.orange,
                title: '최고 콤보',
                value: '${stats.bestComboStreak}',
              ),
            ),
            const SizedBox(width: 12),
            // 7일 변화
            Expanded(
              child: _MetricCard(
                icon: stats.accuracyTrend >= 0 ? Icons.trending_up : Icons.trending_down,
                iconColor: stats.accuracyTrend >= 0 ? Colors.green : Colors.red,
                title: '7일 변화',
                value: '${stats.accuracyTrend >= 0 ? '+' : ''}${(stats.accuracyTrend * 100).toStringAsFixed(1)}%',
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 2️⃣ 단어별 숙련도
  Widget _buildWordProficiencySection(StatisticsProvider statsProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '📚 단어 숙련도',
          style: GoogleFonts.notoSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                indicatorColor: const Color(0xFF4CAF50),
                tabs: const [
                  Tab(text: '숙달됨'),
                  Tab(text: '학습 중'),
                  Tab(text: '약함'),
                ],
              ),
              SizedBox(
                height: 300,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildWordList(statsProvider, ProficiencyLevel.mastered),
                    _buildWordList(statsProvider, ProficiencyLevel.learning),
                    _buildWordList(statsProvider, ProficiencyLevel.weak),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 단어 리스트
  Widget _buildWordList(StatisticsProvider statsProvider, ProficiencyLevel level) {
    final words = statsProvider.getWordsByProficiency(level);
    
    if (words.isEmpty) {
      return Center(
        child: Text(
          '아직 데이터가 없습니다',
          style: GoogleFonts.notoSans(color: Colors.grey),
        ),
      );
    }

    Color badgeColor;
    switch (level) {
      case ProficiencyLevel.mastered:
        badgeColor = Colors.green;
        break;
      case ProficiencyLevel.learning:
        badgeColor = Colors.orange;
        break;
      case ProficiencyLevel.weak:
        badgeColor = Colors.red;
        break;
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: words.length,
      itemBuilder: (context, index) {
        final word = words[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              width: 8,
              height: 40,
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            title: Text(
              word.word,
              style: GoogleFonts.notoSans(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              word.korean,
              style: GoogleFonts.notoSans(fontSize: 12),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 16),
                const SizedBox(width: 4),
                Text('${word.correctCount}', style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 12),
                Icon(Icons.cancel, color: Colors.red, size: 16),
                const SizedBox(width: 4),
                Text('${word.wrongCount}', style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 3️⃣ 오답 분석
  Widget _buildErrorAnalysisSection(StatisticsProvider statsProvider) {
    final weakWords = statsProvider.getWeakWords(limit: 5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '❌ 오답 분석',
          style: GoogleFonts.notoSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '자주 틀린 단어 TOP 5',
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (weakWords.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      '아직 오답이 없습니다! 👍',
                      style: GoogleFonts.notoSans(color: Colors.grey),
                    ),
                  ),
                )
              else
                ...weakWords.map((word) => _buildWeakWordBar(word)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: weakWords.isEmpty ? null : () {
                    // TODO: 복습하기 기능 구현
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('복습하기 기능 준비 중입니다')),
                    );
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('약한 단어 복습하기'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 약한 단어 바 차트
  Widget _buildWeakWordBar(WordProficiencyModel word) {
    final maxWrong = 10; // 최대값 기준
    final percentage = (word.wrongCount / maxWrong).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                word.word,
                style: GoogleFonts.notoSans(fontWeight: FontWeight.bold),
              ),
              Text(
                '${word.wrongCount}회',
                style: GoogleFonts.notoSans(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.red.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red.shade400),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  /// 4️⃣ 난이도별 성과
  Widget _buildDifficultyPerformanceSection(StatisticsProvider statsProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🎯 난이도별 성과',
          style: GoogleFonts.notoSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...statsProvider.difficultyStats.entries.map((entry) {
          final diffStats = entry.value;
          return _buildDifficultyBar(diffStats);
        }),
      ],
    );
  }

  /// 난이도별 바
  Widget _buildDifficultyBar(diffStats) {
    Color color;
    switch (diffStats.difficulty) {
      case 1:
        color = Colors.green;
        break;
      case 2:
        color = Colors.orange;
        break;
      case 3:
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                diffStats.difficultyName,
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                '${(diffStats.accuracyRate * 100).toStringAsFixed(1)}%',
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: diffStats.accuracyRate,
              backgroundColor: color.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 12,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '평균 풀이 시간: ${diffStats.averageSolveTime.toStringAsFixed(1)}초',
                style: GoogleFonts.notoSans(fontSize: 12, color: Colors.grey),
              ),
              Text(
                '${diffStats.totalAttempts}문제',
                style: GoogleFonts.notoSans(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 지표 카드 위젯
class _MetricCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final bool showProgress;
  final double progressValue;

  const _MetricCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    this.showProgress = false,
    this.progressValue = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          if (showProgress)
            SizedBox(
              width: 60,
              height: 60,
              child: Stack(
                children: [
                  CircularProgressIndicator(
                    value: progressValue,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                    strokeWidth: 6,
                  ),
                  Center(
                    child: Icon(icon, color: iconColor, size: 24),
                  ),
                ],
              ),
            )
          else
            Icon(icon, color: iconColor, size: 32),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.notoSans(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.notoSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
