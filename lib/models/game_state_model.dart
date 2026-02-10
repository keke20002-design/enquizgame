/// 게임 상태 모델
class GameStateModel {
  final int currentLevel;
  final int totalExp;
  final int coins;
  final int currentHp;
  final int maxHp;
  final String selectedCharacterId;
  final List<String> masteredWords; // 마스터한 단어들
  final List<String> weakWords; // 약한 단어들 (복습 필요)
  final Map<String, int> categoryProgress; // 카테고리별 진행도
  final DateTime lastPlayedDate;
  final int consecutiveDays; // 연속 플레이 일수

  GameStateModel({
    this.currentLevel = 1,
    this.totalExp = 0,
    this.coins = 0,
    this.currentHp = 100,
    this.maxHp = 100,
    this.selectedCharacterId = 'warrior',
    this.masteredWords = const [],
    this.weakWords = const [],
    this.categoryProgress = const {},
    DateTime? lastPlayedDate,
    this.consecutiveDays = 0,
  }) : lastPlayedDate = lastPlayedDate ?? DateTime.now();

  /// 경험치로부터 레벨 계산
  static int calculateLevel(int exp) {
    return (exp / 100).floor() + 1;
  }

  /// 다음 레벨까지 필요한 경험치
  int get expToNextLevel {
    return (currentLevel * 100) - totalExp;
  }

  /// 현재 레벨의 진행도 (0.0 ~ 1.0)
  double get levelProgress {
    int currentLevelExp = totalExp % 100;
    return currentLevelExp / 100.0;
  }

  GameStateModel copyWith({
    int? currentLevel,
    int? totalExp,
    int? coins,
    int? currentHp,
    int? maxHp,
    String? selectedCharacterId,
    List<String>? masteredWords,
    List<String>? weakWords,
    Map<String, int>? categoryProgress,
    DateTime? lastPlayedDate,
    int? consecutiveDays,
  }) {
    return GameStateModel(
      currentLevel: currentLevel ?? this.currentLevel,
      totalExp: totalExp ?? this.totalExp,
      coins: coins ?? this.coins,
      currentHp: currentHp ?? this.currentHp,
      maxHp: maxHp ?? this.maxHp,
      selectedCharacterId: selectedCharacterId ?? this.selectedCharacterId,
      masteredWords: masteredWords ?? this.masteredWords,
      weakWords: weakWords ?? this.weakWords,
      categoryProgress: categoryProgress ?? this.categoryProgress,
      lastPlayedDate: lastPlayedDate ?? this.lastPlayedDate,
      consecutiveDays: consecutiveDays ?? this.consecutiveDays,
    );
  }

  factory GameStateModel.fromJson(Map<String, dynamic> json) {
    return GameStateModel(
      currentLevel: json['currentLevel'] as int? ?? 1,
      totalExp: json['totalExp'] as int? ?? 0,
      coins: json['coins'] as int? ?? 0,
      currentHp: json['currentHp'] as int? ?? 100,
      maxHp: json['maxHp'] as int? ?? 100,
      selectedCharacterId: json['selectedCharacterId'] as String? ?? 'warrior',
      masteredWords: (json['masteredWords'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      weakWords: (json['weakWords'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      categoryProgress: (json['categoryProgress'] as Map<String, dynamic>?)
              ?.map((key, value) => MapEntry(key, value as int)) ??
          {},
      lastPlayedDate: json['lastPlayedDate'] != null
          ? DateTime.parse(json['lastPlayedDate'] as String)
          : DateTime.now(),
      consecutiveDays: json['consecutiveDays'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentLevel': currentLevel,
      'totalExp': totalExp,
      'coins': coins,
      'currentHp': currentHp,
      'maxHp': maxHp,
      'selectedCharacterId': selectedCharacterId,
      'masteredWords': masteredWords,
      'weakWords': weakWords,
      'categoryProgress': categoryProgress,
      'lastPlayedDate': lastPlayedDate.toIso8601String(),
      'consecutiveDays': consecutiveDays,
    };
  }
}
