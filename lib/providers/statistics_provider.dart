import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/statistics_model.dart';
import '../models/word_proficiency_model.dart';
import '../models/difficulty_stats_model.dart';

/// 통계 데이터를 관리하는 Provider
class StatisticsProvider extends ChangeNotifier {
  StatisticsModel _statistics = StatisticsModel();
  Map<String, WordProficiencyModel> _wordProficiency = {};
  Map<int, DifficultyStatsModel> _difficultyStats = {
    1: DifficultyStatsModel(difficulty: 1),
    2: DifficultyStatsModel(difficulty: 2),
    3: DifficultyStatsModel(difficulty: 3),
  };

  StatisticsModel get statistics => _statistics;
  Map<String, WordProficiencyModel> get wordProficiency => _wordProficiency;
  Map<int, DifficultyStatsModel> get difficultyStats => _difficultyStats;

  /// 숙련도별 단어 목록 가져오기
  List<WordProficiencyModel> getWordsByProficiency(ProficiencyLevel level) {
    return _wordProficiency.values
        .where((word) => word.calculateProficiencyLevel() == level)
        .toList()
      ..sort((a, b) => b.totalAttempts.compareTo(a.totalAttempts));
  }

  /// 약한 단어 TOP N 가져오기
  List<WordProficiencyModel> getWeakWords({int limit = 5}) {
    final weakWords = _wordProficiency.values
        .where((word) => word.wrongCount > 0)
        .toList()
      ..sort((a, b) => b.wrongCount.compareTo(a.wrongCount));
    
    return weakWords.take(limit).toList();
  }

  /// 단어 숙련도 업데이트
  void updateWordProficiency({
    required String word,
    required String korean,
    required bool isCorrect,
  }) {
    final existing = _wordProficiency[word];
    
    if (existing == null) {
      _wordProficiency[word] = WordProficiencyModel(
        word: word,
        korean: korean,
        correctCount: isCorrect ? 1 : 0,
        wrongCount: isCorrect ? 0 : 1,
      );
    } else {
      _wordProficiency[word] = isCorrect 
          ? existing.addCorrect() 
          : existing.addWrong();
    }
    
    notifyListeners();
    _saveStatistics();
  }

  /// 퀴즈 결과 업데이트
  void updateQuizResult({
    required bool isCorrect,
    required int difficulty,
    double? solveTime,
  }) {
    // 전체 통계 업데이트
    _statistics = _statistics.copyWith(
      totalQuestionsAnswered: _statistics.totalQuestionsAnswered + 1,
      totalCorrect: _statistics.totalCorrect + (isCorrect ? 1 : 0),
      totalWrong: _statistics.totalWrong + (isCorrect ? 0 : 1),
      currentComboStreak: isCorrect ? _statistics.currentComboStreak + 1 : 0,
      bestComboStreak: isCorrect && _statistics.currentComboStreak + 1 > _statistics.bestComboStreak
          ? _statistics.currentComboStreak + 1
          : _statistics.bestComboStreak,
    );

    // 난이도별 통계 업데이트
    final diffStats = _difficultyStats[difficulty]!;
    final newTotalAttempts = diffStats.totalAttempts + 1;
    final newCorrectCount = diffStats.correctCount + (isCorrect ? 1 : 0);
    
    // 평균 풀이 시간 계산 (이동 평균)
    double newAvgTime = diffStats.averageSolveTime;
    if (solveTime != null) {
      newAvgTime = (diffStats.averageSolveTime * diffStats.totalAttempts + solveTime) / newTotalAttempts;
    }

    _difficultyStats[difficulty] = diffStats.copyWith(
      totalAttempts: newTotalAttempts,
      correctCount: newCorrectCount,
      averageSolveTime: newAvgTime,
    );

    notifyListeners();
    _saveStatistics();
  }

  /// 일일 정답률 업데이트 (매일 종료 시 호출)
  void updateDailyAccuracy() {
    final todayAccuracy = _statistics.overallAccuracyRate;
    final updated7Days = List<double>.from(_statistics.last7DaysAccuracy)..add(todayAccuracy);
    
    // 최근 7일만 유지
    if (updated7Days.length > 7) {
      updated7Days.removeAt(0);
    }

    _statistics = _statistics.copyWith(
      last7DaysAccuracy: updated7Days,
      lastUpdated: DateTime.now(),
    );

    notifyListeners();
    _saveStatistics();
  }

  /// 통계 불러오기
  Future<void> loadStatistics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 전체 통계
      final statsJson = prefs.getString('statistics');
      if (statsJson != null) {
        _statistics = StatisticsModel.fromJson(jsonDecode(statsJson));
      }

      // 단어 숙련도
      final wordProfJson = prefs.getString('word_proficiency');
      if (wordProfJson != null) {
        final Map<String, dynamic> wordMap = jsonDecode(wordProfJson);
        _wordProficiency = wordMap.map(
          (key, value) => MapEntry(key, WordProficiencyModel.fromJson(value)),
        );
      }

      // 난이도별 통계
      final diffStatsJson = prefs.getString('difficulty_stats');
      if (diffStatsJson != null) {
        final Map<String, dynamic> diffMap = jsonDecode(diffStatsJson);
        _difficultyStats = diffMap.map(
          (key, value) => MapEntry(int.parse(key), DifficultyStatsModel.fromJson(value)),
        );
      }

      notifyListeners();
    } catch (e) {
      debugPrint('통계 로드 실패: $e');
    }
  }

  /// 통계 저장
  Future<void> _saveStatistics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 전체 통계
      await prefs.setString('statistics', jsonEncode(_statistics.toJson()));

      // 단어 숙련도
      final wordProfMap = _wordProficiency.map(
        (key, value) => MapEntry(key, value.toJson()),
      );
      await prefs.setString('word_proficiency', jsonEncode(wordProfMap));

      // 난이도별 통계
      final diffStatsMap = _difficultyStats.map(
        (key, value) => MapEntry(key.toString(), value.toJson()),
      );
      await prefs.setString('difficulty_stats', jsonEncode(diffStatsMap));
    } catch (e) {
      debugPrint('통계 저장 실패: $e');
    }
  }

  /// 통계 초기화
  Future<void> resetStatistics() async {
    _statistics = StatisticsModel();
    _wordProficiency = {};
    _difficultyStats = {
      1: DifficultyStatsModel(difficulty: 1),
      2: DifficultyStatsModel(difficulty: 2),
      3: DifficultyStatsModel(difficulty: 3),
    };
    
    notifyListeners();
    await _saveStatistics();
  }
}
