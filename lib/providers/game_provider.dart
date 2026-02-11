import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_state_model.dart';

/// 게임 상태를 관리하는 Provider
class GameProvider extends ChangeNotifier {
  GameStateModel _gameState = GameStateModel();
  
  GameStateModel get gameState => _gameState;
  
  /// 로컬 저장소에서 게임 상태 불러오기
  Future<void> loadGameState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? gameStateJson = prefs.getString('game_state');
      
      if (gameStateJson != null) {
        final Map<String, dynamic> json = jsonDecode(gameStateJson);
        _gameState = GameStateModel.fromJson(json);
        
        // 연속 플레이 일수 체크
        _checkConsecutiveDays();
        
        notifyListeners();
      }
    } catch (e) {
      debugPrint('게임 상태 로드 실패: $e');
    }
  }
  
  /// 게임 상태를 로컬 저장소에 저장
  Future<void> saveGameState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String gameStateJson = jsonEncode(_gameState.toJson());
      await prefs.setString('game_state', gameStateJson);
    } catch (e) {
      debugPrint('게임 상태 저장 실패: $e');
    }
  }
  
  /// 연속 플레이 일수 체크 및 업데이트
  void _checkConsecutiveDays() {
    final now = DateTime.now();
    final lastPlayed = _gameState.lastPlayedDate;
    
    final daysDifference = now.difference(lastPlayed).inDays;
    
    if (daysDifference == 1) {
      // 연속 플레이
      _gameState = _gameState.copyWith(
        consecutiveDays: _gameState.consecutiveDays + 1,
        lastPlayedDate: now,
      );
    } else if (daysDifference > 1) {
      // 연속 끊김
      _gameState = _gameState.copyWith(
        consecutiveDays: 1,
        lastPlayedDate: now,
      );
    } else {
      // 같은 날
      _gameState = _gameState.copyWith(lastPlayedDate: now);
    }
  }
  
  /// 경험치 추가
  void addExp(int exp) {
    final newTotalExp = _gameState.totalExp + exp;
    final newLevel = GameStateModel.calculateLevel(newTotalExp);
    
    _gameState = _gameState.copyWith(
      totalExp: newTotalExp,
      currentLevel: newLevel,
    );
    
    notifyListeners();
    saveGameState();
  }
  
  /// 코인 추가
  void addCoins(int coins) {
    _gameState = _gameState.copyWith(
      coins: _gameState.coins + coins,
    );
    
    notifyListeners();
    saveGameState();
  }
  
  /// HP 감소
  void takeDamage(int damage) {
    final newHp = (_gameState.currentHp - damage).clamp(0, _gameState.maxHp);
    
    _gameState = _gameState.copyWith(currentHp: newHp);
    
    notifyListeners();
    saveGameState();
  }
  
  /// HP 회복
  void heal(int amount) {
    final newHp = (_gameState.currentHp + amount).clamp(0, _gameState.maxHp);
    
    _gameState = _gameState.copyWith(currentHp: newHp);
    
    notifyListeners();
    saveGameState();
  }
  
  /// 단어를 마스터 목록에 추가
  void addMasteredWord(String word) {
    if (!_gameState.masteredWords.contains(word)) {
      final updatedMastered = List<String>.from(_gameState.masteredWords)..add(word);
      final updatedWeak = List<String>.from(_gameState.weakWords)..remove(word);
      
      _gameState = _gameState.copyWith(
        masteredWords: updatedMastered,
        weakWords: updatedWeak,
      );
      
      notifyListeners();
      saveGameState();
    }
  }
  
  /// 단어를 약한 목록에 추가 (복습 필요)
  void addWeakWord(String word) {
    if (!_gameState.weakWords.contains(word) && 
        !_gameState.masteredWords.contains(word)) {
      final updatedWeak = List<String>.from(_gameState.weakWords)..add(word);
      
      _gameState = _gameState.copyWith(weakWords: updatedWeak);
      
      notifyListeners();
      saveGameState();
    }
  }
  
  /// 카테고리 진행도 업데이트
  void updateCategoryProgress(String category, int progress) {
    final updatedProgress = Map<String, int>.from(_gameState.categoryProgress);
    updatedProgress[category] = progress;
    
    _gameState = _gameState.copyWith(categoryProgress: updatedProgress);
    
    notifyListeners();
    saveGameState();
  }
  
  /// 캐릭터 선택
  void selectCharacter(String characterId) {
    _gameState = _gameState.copyWith(selectedCharacterId: characterId);
    
    notifyListeners();
    saveGameState();
  }
  
  /// 퀴즈 점수 초기화 (퀴즈 시작 시 호출)
  void resetQuizScore() {
    _gameState = _gameState.copyWith(coins: 0);
    notifyListeners();
  }
  
  /// 게임 리셋
  Future<void> resetGame() async {
    _gameState = GameStateModel();
    notifyListeners();
    await saveGameState();
  }
}
