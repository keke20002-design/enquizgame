import 'package:flutter/foundation.dart';

/// 단어별 숙련도 모델
class WordProficiencyModel {
  final String word;
  final String korean;
  final int correctCount;
  final int wrongCount;
  final DateTime lastAttemptDate;
  final ProficiencyLevel proficiencyLevel;

  WordProficiencyModel({
    required this.word,
    required this.korean,
    this.correctCount = 0,
    this.wrongCount = 0,
    DateTime? lastAttemptDate,
    ProficiencyLevel? proficiencyLevel,
  })  : lastAttemptDate = lastAttemptDate ?? DateTime.now(),
        proficiencyLevel = proficiencyLevel ?? ProficiencyLevel.learning;

  /// 총 시도 횟수
  int get totalAttempts => correctCount + wrongCount;

  /// 정답률 (0.0 ~ 1.0)
  double get accuracyRate {
    if (totalAttempts == 0) return 0.0;
    return correctCount / totalAttempts;
  }

  /// 숙련도 레벨 자동 계산
  ProficiencyLevel calculateProficiencyLevel() {
    // Mastered: 3회 이상 연속 정답 (정답률 100%)
    if (correctCount >= 3 && wrongCount == 0) {
      return ProficiencyLevel.mastered;
    }
    // Weak: 2회 이상 오답 또는 정답률 50% 미만
    if (wrongCount >= 2 || (totalAttempts >= 3 && accuracyRate < 0.5)) {
      return ProficiencyLevel.weak;
    }
    // Learning: 그 외
    return ProficiencyLevel.learning;
  }

  /// 정답 추가
  WordProficiencyModel addCorrect() {
    return copyWith(
      correctCount: correctCount + 1,
      lastAttemptDate: DateTime.now(),
    );
  }

  /// 오답 추가
  WordProficiencyModel addWrong() {
    return copyWith(
      wrongCount: wrongCount + 1,
      lastAttemptDate: DateTime.now(),
    );
  }

  WordProficiencyModel copyWith({
    String? word,
    String? korean,
    int? correctCount,
    int? wrongCount,
    DateTime? lastAttemptDate,
    ProficiencyLevel? proficiencyLevel,
  }) {
    return WordProficiencyModel(
      word: word ?? this.word,
      korean: korean ?? this.korean,
      correctCount: correctCount ?? this.correctCount,
      wrongCount: wrongCount ?? this.wrongCount,
      lastAttemptDate: lastAttemptDate ?? this.lastAttemptDate,
      proficiencyLevel: proficiencyLevel ?? this.proficiencyLevel,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'korean': korean,
      'correctCount': correctCount,
      'wrongCount': wrongCount,
      'lastAttemptDate': lastAttemptDate.toIso8601String(),
      'proficiencyLevel': proficiencyLevel.index,
    };
  }

  factory WordProficiencyModel.fromJson(Map<String, dynamic> json) {
    return WordProficiencyModel(
      word: json['word'] as String,
      korean: json['korean'] as String,
      correctCount: json['correctCount'] as int? ?? 0,
      wrongCount: json['wrongCount'] as int? ?? 0,
      lastAttemptDate: DateTime.parse(json['lastAttemptDate'] as String),
      proficiencyLevel: ProficiencyLevel.values[json['proficiencyLevel'] as int? ?? 1],
    );
  }
}

/// 숙련도 레벨
enum ProficiencyLevel {
  mastered, // 숙달됨 (3회 이상 연속 정답)
  learning, // 학습 중 (정답/오답 혼합)
  weak,     // 약함 (2회 이상 오답)
}
