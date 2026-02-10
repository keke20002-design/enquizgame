/// 캐릭터 데이터 모델
class CharacterModel {
  final String id;
  final String name;
  final String description;
  final int maxHp;
  final int attack;
  final String imageAsset;
  final List<String> specialAbilities;

  CharacterModel({
    required this.id,
    required this.name,
    required this.description,
    required this.maxHp,
    required this.attack,
    required this.imageAsset,
    this.specialAbilities = const [],
  });

  factory CharacterModel.fromJson(Map<String, dynamic> json) {
    return CharacterModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      maxHp: json['maxHp'] as int,
      attack: json['attack'] as int,
      imageAsset: json['imageAsset'] as String,
      specialAbilities: (json['specialAbilities'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'maxHp': maxHp,
      'attack': attack,
      'imageAsset': imageAsset,
      'specialAbilities': specialAbilities,
    };
  }
}

/// 몬스터 데이터 모델
class MonsterModel {
  final String id;
  final String name;
  final int hp;
  final int difficulty;
  final String imageAsset;
  final int rewardExp;
  final int rewardCoins;

  MonsterModel({
    required this.id,
    required this.name,
    required this.hp,
    required this.difficulty,
    required this.imageAsset,
    required this.rewardExp,
    required this.rewardCoins,
  });

  factory MonsterModel.fromJson(Map<String, dynamic> json) {
    return MonsterModel(
      id: json['id'] as String,
      name: json['name'] as String,
      hp: json['hp'] as int,
      difficulty: json['difficulty'] as int,
      imageAsset: json['imageAsset'] as String,
      rewardExp: json['rewardExp'] as int,
      rewardCoins: json['rewardCoins'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'hp': hp,
      'difficulty': difficulty,
      'imageAsset': imageAsset,
      'rewardExp': rewardExp,
      'rewardCoins': rewardCoins,
    };
  }
}
