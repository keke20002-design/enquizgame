/// 전체 통계 모델
class StatisticsModel {
  final int totalQuestionsAnswered;
  final int totalCorrect;
  final int totalWrong;
  final int bestComboStreak;
  final int currentComboStreak;
  final List<double> last7DaysAccuracy; // 최근 7일 정답률
  final DateTime lastUpdated;

  StatisticsModel({
    this.totalQuestionsAnswered = 0,
    this.totalCorrect = 0,
    this.totalWrong = 0,
    this.bestComboStreak = 0,
    this.currentComboStreak = 0,
    List<double>? last7DaysAccuracy,
    DateTime? lastUpdated,
  })  : last7DaysAccuracy = last7DaysAccuracy ?? [],
        lastUpdated = lastUpdated ?? DateTime.now();

  /// 전체 정답률 (0.0 ~ 1.0)
  double get overallAccuracyRate {
    if (totalQuestionsAnswered == 0) return 0.0;
    return totalCorrect / totalQuestionsAnswered;
  }

  /// 최근 7일 정답률 평균
  double get recent7DaysAverage {
    if (last7DaysAccuracy.isEmpty) return 0.0;
    return last7DaysAccuracy.reduce((a, b) => a + b) / last7DaysAccuracy.length;
  }

  /// 7일 정답률 변화 (상승/하락)
  /// 양수: 상승, 음수: 하락, 0: 변화 없음
  double get accuracyTrend {
    if (last7DaysAccuracy.length < 2) return 0.0;
    final recent = last7DaysAccuracy.sublist(last7DaysAccuracy.length - 3);
    final older = last7DaysAccuracy.sublist(0, last7DaysAccuracy.length - 3);
    
    final recentAvg = recent.reduce((a, b) => a + b) / recent.length;
    final olderAvg = older.reduce((a, b) => a + b) / older.length;
    
    return recentAvg - olderAvg;
  }

  StatisticsModel copyWith({
    int? totalQuestionsAnswered,
    int? totalCorrect,
    int? totalWrong,
    int? bestComboStreak,
    int? currentComboStreak,
    List<double>? last7DaysAccuracy,
    DateTime? lastUpdated,
  }) {
    return StatisticsModel(
      totalQuestionsAnswered: totalQuestionsAnswered ?? this.totalQuestionsAnswered,
      totalCorrect: totalCorrect ?? this.totalCorrect,
      totalWrong: totalWrong ?? this.totalWrong,
      bestComboStreak: bestComboStreak ?? this.bestComboStreak,
      currentComboStreak: currentComboStreak ?? this.currentComboStreak,
      last7DaysAccuracy: last7DaysAccuracy ?? this.last7DaysAccuracy,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalQuestionsAnswered': totalQuestionsAnswered,
      'totalCorrect': totalCorrect,
      'totalWrong': totalWrong,
      'bestComboStreak': bestComboStreak,
      'currentComboStreak': currentComboStreak,
      'last7DaysAccuracy': last7DaysAccuracy,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory StatisticsModel.fromJson(Map<String, dynamic> json) {
    return StatisticsModel(
      totalQuestionsAnswered: json['totalQuestionsAnswered'] as int? ?? 0,
      totalCorrect: json['totalCorrect'] as int? ?? 0,
      totalWrong: json['totalWrong'] as int? ?? 0,
      bestComboStreak: json['bestComboStreak'] as int? ?? 0,
      currentComboStreak: json['currentComboStreak'] as int? ?? 0,
      last7DaysAccuracy: (json['last7DaysAccuracy'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : DateTime.now(),
    );
  }
}
