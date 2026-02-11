import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:csv/csv.dart';
import '../models/word_model.dart';

/// 단어 데이터를 관리하는 Provider
class WordProvider extends ChangeNotifier {
  List<WordModel> _allWords = [];
  List<WordModel> _currentQuizWords = [];
  int _currentWordIndex = 0;
  
  
  List<WordModel> get allWords => _allWords;
  List<WordModel> get currentQuizWords => _currentQuizWords;
  int get currentWordIndex => _currentWordIndex;
  
  // Get current quiz difficulty (from first word in quiz)
  int get currentDifficulty {
    if (_currentQuizWords.isEmpty) return 1;
    return _currentQuizWords.first.difficulty;
  }
  
  WordModel? get currentWord {
    if (_currentQuizWords.isEmpty || _currentWordIndex >= _currentQuizWords.length) {
      return null;
    }
    return _currentQuizWords[_currentWordIndex];
  }
  
  bool get hasMoreWords => _currentWordIndex < _currentQuizWords.length - 1;
  
  /// CSV 파일에서 단어 데이터 로드
  Future<void> loadWords() async {
    try {
      final String csvString = await rootBundle.loadString('assets/data/words.csv');
      final List<List<dynamic>> csvData = const CsvToListConverter().convert(csvString);
      
      // 첫 번째 행은 헤더이므로 건너뜀
      _allWords = csvData.skip(1).map((row) {
        return WordModel(
          english: row[0].toString(),
          korean: row[1].toString(),
          category: row[2].toString(),
          difficulty: int.parse(row[3].toString()),
          examples: [
            row[4].toString(),
            row[5].toString(),
          ],
        );
      }).toList();
      
      debugPrint('단어 로드 성공: ${_allWords.length}개');
      notifyListeners();
    } catch (e) {
      debugPrint('단어 데이터 로드 실패: $e');
      // 개발용 샘플 데이터
      _loadSampleWords();
    }
  }
  
  /// 개발용 샘플 단어 데이터
  void _loadSampleWords() {
    _allWords = [
      WordModel(
        english: 'apple',
        korean: '사과',
        category: 'fruits',
        difficulty: 1,
        examples: ['I eat an apple.', 'The apple is red.'],
      ),
      WordModel(
        english: 'banana',
        korean: '바나나',
        category: 'fruits',
        difficulty: 1,
        examples: ['I like bananas.', 'Bananas are yellow.'],
      ),
      WordModel(
        english: 'cat',
        korean: '고양이',
        category: 'animals',
        difficulty: 1,
        examples: ['I have a cat.', 'The cat is cute.'],
      ),
      WordModel(
        english: 'dog',
        korean: '개',
        category: 'animals',
        difficulty: 1,
        examples: ['My dog is big.', 'Dogs are friendly.'],
      ),
      WordModel(
        english: 'elephant',
        korean: '코끼리',
        category: 'animals',
        difficulty: 2,
        examples: ['Elephants are large.', 'I saw an elephant at the zoo.'],
      ),
      WordModel(
        english: 'beautiful',
        korean: '아름다운',
        category: 'adjectives',
        difficulty: 2,
        examples: ['She is beautiful.', 'What a beautiful day!'],
      ),
      WordModel(
        english: 'difficult',
        korean: '어려운',
        category: 'adjectives',
        difficulty: 3,
        examples: ['This is difficult.', 'Math is difficult for me.'],
      ),
      WordModel(
        english: 'adventure',
        korean: '모험',
        category: 'nouns',
        difficulty: 3,
        examples: ['I love adventure.', 'This is a great adventure!'],
      ),
      // 추가 단어들 (난이도 1)
      WordModel(
        english: 'book',
        korean: '책',
        category: 'objects',
        difficulty: 1,
        examples: ['I read a book.', 'This book is interesting.'],
      ),
      WordModel(
        english: 'car',
        korean: '자동차',
        category: 'objects',
        difficulty: 1,
        examples: ['My car is fast.', 'I drive a car.'],
      ),
      WordModel(
        english: 'house',
        korean: '집',
        category: 'objects',
        difficulty: 1,
        examples: ['I live in a house.', 'My house is big.'],
      ),
      WordModel(
        english: 'tree',
        korean: '나무',
        category: 'nature',
        difficulty: 1,
        examples: ['The tree is tall.', 'I climb a tree.'],
      ),
      WordModel(
        english: 'water',
        korean: '물',
        category: 'nature',
        difficulty: 1,
        examples: ['I drink water.', 'Water is important.'],
      ),
      WordModel(
        english: 'sun',
        korean: '태양',
        category: 'nature',
        difficulty: 1,
        examples: ['The sun is bright.', 'I see the sun.'],
      ),
      // 추가 단어들 (난이도 2)
      WordModel(
        english: 'computer',
        korean: '컴퓨터',
        category: 'objects',
        difficulty: 2,
        examples: ['I use a computer.', 'My computer is new.'],
      ),
      WordModel(
        english: 'mountain',
        korean: '산',
        category: 'nature',
        difficulty: 2,
        examples: ['The mountain is high.', 'I climb mountains.'],
      ),
      WordModel(
        english: 'ocean',
        korean: '바다',
        category: 'nature',
        difficulty: 2,
        examples: ['The ocean is blue.', 'I swim in the ocean.'],
      ),
      WordModel(
        english: 'happy',
        korean: '행복한',
        category: 'adjectives',
        difficulty: 2,
        examples: ['I am happy.', 'She looks happy.'],
      ),
      WordModel(
        english: 'friend',
        korean: '친구',
        category: 'people',
        difficulty: 2,
        examples: ['He is my friend.', 'I play with my friends.'],
      ),
      WordModel(
        english: 'school',
        korean: '학교',
        category: 'places',
        difficulty: 2,
        examples: ['I go to school.', 'My school is big.'],
      ),
      WordModel(
        english: 'music',
        korean: '음악',
        category: 'arts',
        difficulty: 2,
        examples: ['I like music.', 'Music is fun.'],
      ),
      WordModel(
        english: 'family',
        korean: '가족',
        category: 'people',
        difficulty: 2,
        examples: ['I love my family.', 'My family is kind.'],
      ),
      // 추가 단어들 (난이도 3)
      WordModel(
        english: 'important',
        korean: '중요한',
        category: 'adjectives',
        difficulty: 3,
        examples: ['This is important.', 'Education is important.'],
      ),
      WordModel(
        english: 'knowledge',
        korean: '지식',
        category: 'nouns',
        difficulty: 3,
        examples: ['Knowledge is power.', 'I gain knowledge from books.'],
      ),
      WordModel(
        english: 'wonderful',
        korean: '멋진',
        category: 'adjectives',
        difficulty: 3,
        examples: ['What a wonderful day!', 'This is wonderful.'],
      ),
    ];
    
    notifyListeners();
  }
  
  /// 난이도별 단어 필터링
  List<WordModel> getWordsByDifficulty(int difficulty) {
    return _allWords.where((word) => word.difficulty == difficulty).toList();
  }
  
  /// 카테고리별 단어 필터링
  List<WordModel> getWordsByCategory(String category) {
    return _allWords.where((word) => word.category == category).toList();
  }
  
  /// 퀴즈용 단어 설정 (랜덤하게 섞음)
  void setupQuiz({int? difficulty, String? category, int count = 10}) {
    List<WordModel> filteredWords = _allWords;
    
    debugPrint('=== setupQuiz 호출 ===');
    debugPrint('전체 단어 수: ${_allWords.length}');
    debugPrint('요청 난이도: $difficulty');
    debugPrint('요청 문항 수: $count');
    
    if (difficulty != null) {
      filteredWords = filteredWords.where((word) => word.difficulty == difficulty).toList();
      debugPrint('난이도 $difficulty 단어 수: ${filteredWords.length}');
    }
    
    if (category != null) {
      filteredWords = filteredWords.where((word) => word.category == category).toList();
      debugPrint('카테고리 $category 단어 수: ${filteredWords.length}');
    }
    
    filteredWords.shuffle();
    _currentQuizWords = filteredWords.take(count).toList();
    _currentWordIndex = 0;
    
    debugPrint('최종 퀴즈 단어 수: ${_currentQuizWords.length}');
    debugPrint('퀴즈 단어 목록: ${_currentQuizWords.map((w) => w.english).join(", ")}');
    
    notifyListeners();
  }
  
  /// 다음 단어로 이동
  void nextWord() {
    if (hasMoreWords) {
      _currentWordIndex++;
      notifyListeners();
    }
  }
  
  /// 퀴즈 리셋
  void resetQuiz() {
    _currentQuizWords = [];
    _currentWordIndex = 0;
    notifyListeners();
  }
  
  /// 모든 카테고리 목록 가져오기
  List<String> getAllCategories() {
    return _allWords.map((word) => word.category).toSet().toList();
  }
  
  /// 특정 단어들로 복습 퀴즈 설정
  void setupReviewQuiz(List<String> wordList) {
    _currentQuizWords = _allWords
        .where((word) => wordList.contains(word.english))
        .toList();
    _currentQuizWords.shuffle();
    _currentWordIndex = 0;
    
    notifyListeners();
  }
}
