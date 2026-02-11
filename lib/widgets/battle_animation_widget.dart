import 'package:flutter/material.dart';

/// 전투 애니메이션 위젯
class BattleAnimationWidget extends StatefulWidget {
  final int currentProgress; // Current question number
  final int totalQuestions; // Total number of questions (5, 10, 15, 20)
  final bool isAttacking; // 용사가 공격 중
  final bool isTakingDamage; // 용사가 피격 중
  final int consecutiveCorrect; // Consecutive correct answers
  final int difficulty; // Quiz difficulty (1: 쉬움, 2: 보통, 3: 어려움)
  final VoidCallback? onAnimationComplete;

  const BattleAnimationWidget({
    super.key,
    required this.currentProgress,
    required this.totalQuestions, // 추가된 파라미터
    this.isAttacking = false,
    this.isTakingDamage = false,
    this.consecutiveCorrect = 0, // Default to 0
    this.difficulty = 1, // Default to easy
    this.onAnimationComplete,
  });

  @override
  State<BattleAnimationWidget> createState() => _BattleAnimationWidgetState();
}

class _BattleAnimationWidgetState extends State<BattleAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(BattleAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isAttacking && !oldWidget.isAttacking) {
      _playAttackAnimation();
    } else if (widget.isTakingDamage && !oldWidget.isTakingDamage) {
      _playDamageAnimation();
    }
  }

  void _playAttackAnimation() {
    _animationController.forward(from: 0).then((_) {
      _animationController.reverse().then((_) {
        widget.onAnimationComplete?.call();
      });
    });
  }

  void _playDamageAnimation() {
    _animationController.forward(from: 0).then((_) {
      _animationController.reverse().then((_) {
        widget.onAnimationComplete?.call();
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Stack(
        children: [
          // Progress bar track
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: _buildProgressBar(),
          ),
          
          // Warrior sprite (left side) - fixed position, same height as monster
          Positioned(
            left: 20, // Adjusted for larger sprite width
            bottom: 35, // Same height as monster (bottom: 60 → 35 to be above progress bar)
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                double offset = 0;
                if (widget.isAttacking) {
                  offset = _animationController.value * 20;
                } else if (widget.isTakingDamage) {
                  offset = -_animationController.value * 10;
                }
                
                return Transform.translate(
                  offset: Offset(offset, 0),
                  child: _buildWarriorSprite(),
                );
              },
            ),
          ),
          
          // Monster sprite (right side) - same height as warrior
          Positioned(
            right: 20,
            bottom: 35, // Same height as warrior
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                double scale = 1.0;
                if (widget.isAttacking) {
                  // Monster takes damage - shake effect
                  scale = 1.0 - (_animationController.value * 0.2);
                }
                
                return Transform.scale(
                  scale: scale,
                  child: _buildMonsterSprite(),
                );
              },
            ),
          ),
          
          // Attack effects
          if (widget.isAttacking)
            Positioned(
              right: 60,
              bottom: 80,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Opacity(
                    opacity: 1.0 - _animationController.value,
                    child: Icon(
                      Icons.flash_on,
                      color: Colors.yellow,
                      size: 40 + (_animationController.value * 20),
                    ),
                  );
                },
              ),
            ),
          
          if (widget.isTakingDamage)
            Positioned(
              left: 50 + (widget.currentProgress - 1) * 35.0,
              bottom: 80,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Opacity(
                    opacity: 1.0 - _animationController.value,
                    child: const Icon(
                      Icons.local_fire_department,
                      color: Colors.orange,
                      size: 40,
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      height: 30,
      decoration: BoxDecoration(
        color: const Color(0xFF8B6F47),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFF5C4A33), width: 3),
      ),
      child: Row(
        children: List.generate(widget.totalQuestions, (index) { // 10 → totalQuestions (동적)
          final isReached = index < widget.currentProgress;
          return Expanded(
            child: Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: isReached
                    ? const Color(0xFFFBBF24)
                    : const Color(0xFF6B7280),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 14, // 12 → 14 (크기 증가)
                    fontWeight: FontWeight.bold,
                    color: isReached ? Colors.black : Colors.white,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildWarriorSprite() {
    String assetPath;
    
    // Determine character tier based on consecutive correct answers
    String characterTier = _getCharacterTier();
    
    // 피격 중일 때는 아픈 스프라이트
    if (widget.isTakingDamage) {
      assetPath = 'assets/images/characters/${characterTier}_ill.png';
    }
    // 공격 중일 때는 공격 스프라이트
    else if (widget.isAttacking) {
      assetPath = 'assets/images/characters/${characterTier}_att.png';
    }
    // 평상시는 걷기 스프라이트
    else {
      assetPath = 'assets/images/characters/${characterTier}_walk.png';
    }
    
    return Image.asset(
      assetPath,
      width: 120,
      height: 120,
      fit: BoxFit.fill, // Changed from contain to fill for consistent size
      errorBuilder: (context, error, stackTrace) {
        // Fallback to walk sprite if image not found
        return Image.asset(
          'assets/images/characters/warrior_walk.png',
          width: 120,
          height: 120,
          fit: BoxFit.fill,
        );
      },
    );
  }
  
  /// Get character tier based on consecutive correct answers
  String _getCharacterTier() {
    if (widget.consecutiveCorrect >= 5) {
      return 'gold';
    } else if (widget.consecutiveCorrect >= 3) {
      return 'ice';
    } else {
      return 'warrior';
    }
  }

  Widget _buildMonsterSprite() {
    String assetPath;
    
    // Determine monster type based on difficulty
    String monsterType = _getMonsterType();
    
    // 용사가 공격 중일 때 (정답) 몬스터는 아픈 상태
    if (widget.isAttacking) {
      // Determine damage effect based on character tier
      String damagePrefix = _getDamagePrefix();
      assetPath = 'assets/images/characters/${damagePrefix}${monsterType}_ill.png';
    }
    // 용사가 피격 중일 때 (오답) 몬스터는 공격 상태
    else if (widget.isTakingDamage) {
      assetPath = 'assets/images/characters/${monsterType}_att.png';
    }
    // 평상시는 걷기 스프라이트
    else {
      assetPath = 'assets/images/characters/${monsterType}_walk.png';
    }
    
    return Image.asset(
      assetPath,
      width: 120,
      height: 120,
      fit: BoxFit.fill,
      errorBuilder: (context, error, stackTrace) {
        // Fallback to walk sprite if image not found
        return Image.asset(
          'assets/images/characters/slimwalk.png',
          width: 120,
          height: 120,
          fit: BoxFit.fill,
          errorBuilder: (context, error, stackTrace) {
            // Final fallback to icon
            return Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.green.shade700,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.bug_report, color: Colors.white, size: 80),
            );
          },
        );
      },
    );
  }
  
  /// Get monster type based on difficulty
  String _getMonsterType() {
    // 1: 쉬움 = slim (default)
    // 2: 보통 = gob (goblin)
    // 3: 어려움 = dra (dragon)
    if (widget.difficulty == 3) {
      return 'dra';
    } else if (widget.difficulty == 2) {
      return 'gob';
    } else {
      return 'slim';
    }
  }
  
  /// Get damage prefix based on character tier
  String _getDamagePrefix() {
    String characterTier = _getCharacterTier();
    
    // ice warrior → ice_ prefix
    if (characterTier == 'ice') {
      return 'ice_';
    }
    // gold warrior → fire_ prefix
    else if (characterTier == 'gold') {
      return 'fire_';
    }
    // warrior → no prefix
    else {
      return '';
    }
  }
}
