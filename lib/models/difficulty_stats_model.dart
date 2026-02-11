/// 난이도별 통계 모델
class DifficultyStatsModel {
  final int difficulty; // 1: 쉬움, 2: 보통, 3: 어려움
  final int totalAttempts;
  final int correctCount;
  final double averageSolveTime; // 평균 풀이 시간 (초)

  DifficultyStatsModel({
    required this.difficulty,
    this.totalAttempts = 0,
    this.correctCount = 0,
    this.averageSolveTime = 0.0,
  });

  /// 정답률 (0.0 ~ 1.0)
  double get accuracyRate {
    if (totalAttempts == 0) return 0.0;
    return correctCount / totalAttempts;
  }

  /// 오답 횟수
  int get wrongCount => totalAttempts - correctCount;

  /// 난이도 이름
  String get difficultyName {
    switch (difficulty) {
      case 1:
        return '쉬움';
      case 2:
        return '보통';
      case 3:
        return '어려움';
      default:
        return '알 수 없음';
    }
  }

  DifficultyStatsModel copyWith({
    int? difficulty,
    int? totalAttempts,
    int? correctCount,
    double? averageSolveTime,
  }) {
    return DifficultyStatsModel(
      difficulty: difficulty ?? this.difficulty,
      totalAttempts: totalAttempts ?? this.totalAttempts,
      correctCount: correctCount ?? this.correctCount,
      averageSolveTime: averageSolveTime ?? this.averageSolveTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'difficulty': difficulty,
      'totalAttempts': totalAttempts,
      'correctCount': correctCount,
      'averageSolveTime': averageSolveTime,
    };
  }

  factory DifficultyStatsModel.fromJson(Map<String, dynamic> json) {
    return DifficultyStatsModel(
      difficulty: json['difficulty'] as int,
      totalAttempts: json['totalAttempts'] as int? ?? 0,
      correctCount: json['correctCount'] as int? ?? 0,
      averageSolveTime: (json['averageSolveTime'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
