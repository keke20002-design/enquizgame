/// 영어 단어 데이터 모델
class WordModel {
  final String english;
  final String korean;
  final String category;
  final int difficulty; // 1: 쉬움, 2: 보통, 3: 어려움
  final List<String> examples;
  final String? imageUrl;

  WordModel({
    required this.english,
    required this.korean,
    required this.category,
    required this.difficulty,
    this.examples = const [],
    this.imageUrl,
  });

  /// JSON에서 WordModel 생성
  factory WordModel.fromJson(Map<String, dynamic> json) {
    return WordModel(
      english: json['english'] as String,
      korean: json['korean'] as String,
      category: json['category'] as String,
      difficulty: json['difficulty'] as int,
      examples: (json['examples'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      imageUrl: json['imageUrl'] as String?,
    );
  }

  /// WordModel을 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'english': english,
      'korean': korean,
      'category': category,
      'difficulty': difficulty,
      'examples': examples,
      'imageUrl': imageUrl,
    };
  }

  @override
  String toString() {
    return 'WordModel(english: $english, korean: $korean, category: $category, difficulty: $difficulty)';
  }
}
