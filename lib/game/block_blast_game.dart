import 'grid/grid.dart';
import 'blocks/block.dart';
import 'blocks/block_shape.dart';
import 'blocks/shapes.dart';
import 'characters/character.dart';
import 'characters/characters.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../utils/audio_manager.dart';
import '../utils/character_audio_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

enum GameState {
  playing,
  paused,
  gameOver,
}

class BlockBlastGame {
  final Grid grid;
  final List<Block> blockQueue;
  final AudioManager audioManager;
  final CharacterAudioManager characterAudioManager;
  
  int _score = 0;
  int _level = 1;
  int _bestScore = 0;
  int _totalLinesCleared = 0;
  int _comboCount = 0; // Current combo chain
  int _maxCombo = 0; // Maximum combo achieved
  GameState _state = GameState.playing;
  Character? _currentCharacter;
  
  BlockBlastGame()
      : grid = Grid(),
        blockQueue = [],
        audioManager = AudioManager(),
        characterAudioManager = CharacterAudioManager() {
    _loadBestScore();
    // Initialize grid with fewer blocks for easier start
    grid.initializeWithRandomBlocks(numBlocks: 5);
    _generateNewBlocks();
  }
  
  int get score => _score;
  int get level => _level;
  int get bestScore => _bestScore;
  
  Future<void> _loadBestScore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _bestScore = prefs.getInt('best_score') ?? 0;
    } catch (e) {
      // Ignore errors
    }
  }
  
  Future<void> _saveBestScore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('best_score', _bestScore);
    } catch (e) {
      // Ignore errors
    }
  }
  GameState get state => _state;
  List<Block> get currentBlocks => List.unmodifiable(blockQueue);
  Character? get currentCharacter => _currentCharacter;
  int get totalLinesCleared => _totalLinesCleared;
  int get comboCount => _comboCount;
  int get maxCombo => _maxCombo;
  
  /// Check if a block can be placed anywhere on the grid
  bool _canPlaceBlockAnywhere(Block block) {
    for (int row = 0; row <= grid.rows - block.height; row++) {
      for (int col = 0; col <= grid.cols - block.width; col++) {
        if (grid.canPlaceBlock(block.shapeMatrix, row, col)) {
          return true;
        }
      }
    }
    return false;
  }
  
  /// Check if a block can create a full line when placed
  bool _canBlockCreateFullLine(Block block) {
    for (int row = 0; row <= grid.rows - block.height; row++) {
      for (int col = 0; col <= grid.cols - block.width; col++) {
        if (grid.canPlaceBlock(block.shapeMatrix, row, col)) {
          if (grid.wouldCreateFullLine(block.shapeMatrix, row, col)) {
            return true;
          }
        }
      }
    }
    return false;
  }
  
  /// Generate new blocks for the queue
  /// Ensures blocks are suitable for current grid state and at least one can break lines
  void _generateNewBlocks() {
    blockQueue.clear();
    final random = Random();
    final allShapes = BlockShapes.getAllShapes();
    
    // Get almost full rows/cols to prioritize blocks that can complete them
    final almostFullRows = grid.getAlmostFullRows();
    final almostFullCols = grid.getAlmostFullCols();
    final hasAlmostFullLines = almostFullRows.isNotEmpty || almostFullCols.isNotEmpty;
    
    // For level 1, only use very basic shapes
    List<List<List<bool>>> availableShapes;
    if (_level == 1) {
      // Level 1: Only the simplest shapes
      availableShapes = [
        BlockShapes.single,
        BlockShapes.horizontal2,
        BlockShapes.vertical2,
        BlockShapes.square2x2,
      ];
    } else if (_level <= 3) {
      // Level 2-3: Filter out 3x3 square and complex shapes
      availableShapes = allShapes.where((shape) => 
        shape != BlockShapes.square3x3 &&
        shape != BlockShapes.horizontal4 &&
        shape != BlockShapes.zShape4 &&
        shape != BlockShapes.tShape4
      ).toList();
    } else {
      // Level 4+: All shapes available
      availableShapes = allShapes;
    }
    
    int attempts = 0;
    const maxAttempts = 50;
    bool hasLineBreaker = false;
    bool hasPlaceableBlock = false;
    
    // Generate blocks with smart selection
    while (blockQueue.length < GameConstants.maxBlocksInQueue && attempts < maxAttempts) {
      attempts++;
      
      // Prefer smaller blocks that can fit in gaps
      List<List<List<bool>>> candidateShapes;
      if (hasAlmostFullLines && !hasLineBreaker) {
        // Prioritize blocks that can complete almost-full lines
        // Prefer blocks with 1-3 cells for almost-full lines
        candidateShapes = availableShapes.where((shape) {
          int cellCount = 0;
          for (var row in shape) {
            for (var cell in row) {
              if (cell) cellCount++;
            }
          }
          return cellCount >= 1 && cellCount <= 4;
        }).toList();
        if (candidateShapes.isEmpty) {
          candidateShapes = availableShapes;
        }
      } else {
        // Normal selection - prefer smaller blocks, especially for level 1
        candidateShapes = availableShapes.where((shape) {
          int cellCount = 0;
          for (var row in shape) {
            for (var cell in row) {
              if (cell) cellCount++;
            }
          }
          // Level 1: only 1-4 cells, Level 2-3: up to 5 cells, Level 4+: up to 6 cells
          if (_level == 1) {
            return cellCount <= 4;
          } else if (_level <= 3) {
            return cellCount <= 5;
          } else {
            return cellCount <= 6;
          }
        }).toList();
        if (candidateShapes.isEmpty) {
          candidateShapes = availableShapes;
        }
      }
      
      final shape = candidateShapes[random.nextInt(candidateShapes.length)];
      final color = Helpers.getRandomColor(GameConstants.blockColors);
      final block = Block(
        shape: BlockShape(shape: shape, name: 'block'),
        color: color,
      );
      
      // Check if block can be placed
      if (_canPlaceBlockAnywhere(block)) {
        hasPlaceableBlock = true;
        
        // Check if block can create full line
        if (_canBlockCreateFullLine(block)) {
          hasLineBreaker = true;
        }
        
        blockQueue.add(block);
      } else if (blockQueue.length == 0) {
        // If queue is empty and this block can't be placed, try a simple block
        final simpleShape = BlockShapes.single;
        blockQueue.add(Block(
          shape: BlockShape(shape: simpleShape, name: 'block'),
          color: color,
        ));
        hasPlaceableBlock = true;
      }
    }
    
    // Ensure at least one block can be placed
    if (!hasPlaceableBlock && blockQueue.isNotEmpty) {
      // Replace last block with a simple one
      blockQueue.removeLast();
      final simpleShape = BlockShapes.single;
      final color = Helpers.getRandomColor(GameConstants.blockColors);
      blockQueue.add(Block(
        shape: BlockShape(shape: simpleShape, name: 'block'),
        color: color,
      ));
    }
    
    // If we have almost-full lines but no line breaker, try to add one
    if (hasAlmostFullLines && !hasLineBreaker && blockQueue.length < GameConstants.maxBlocksInQueue) {
      // Try to find a small block that can complete a line
      final smallShapes = [
        BlockShapes.single,
        BlockShapes.horizontal2,
        BlockShapes.vertical2,
        BlockShapes.cornerShape,
        BlockShapes.reverseCornerShape,
      ];
      
      for (var shape in smallShapes) {
        final block = Block(
          shape: BlockShape(shape: shape, name: 'block'),
          color: Helpers.getRandomColor(GameConstants.blockColors),
        );
        if (_canBlockCreateFullLine(block)) {
          if (blockQueue.length >= GameConstants.maxBlocksInQueue) {
            blockQueue.removeLast();
          }
          blockQueue.add(block);
          break;
        }
      }
    }
  }
  
  /// Try to place a block on the grid
  bool placeBlock(Block block, int row, int col) {
    if (_state != GameState.playing) return false;
    
    if (grid.canPlaceBlock(block.shapeMatrix, row, col)) {
      grid.placeBlock(block.shapeMatrix, row, col, block.color);
      audioManager.playBlockPlace();
      
      // Remove block from queue
      blockQueue.removeWhere((b) => b.id == block.id);
      
      // Check for full lines
      final fullRows = grid.getFullRows();
      final fullCols = grid.getFullCols();
      final clearedLines = fullRows.length + fullCols.length;
      
      if (clearedLines > 0) {
        // Collect cell data for particles before clearing
        List<Map<String, dynamic>> cellsForParticles = [];
        for (int row in fullRows) {
          for (int col = 0; col < grid.cols; col++) {
            final cell = grid.getCell(row, col);
            if (cell != null && cell.isFilled && cell.color != 0) {
              cellsForParticles.add({
                'row': row,
                'col': col,
                'color': cell.color,
              });
            }
          }
        }
        for (int col in fullCols) {
          for (int row = 0; row < grid.rows; row++) {
            final cell = grid.getCell(row, col);
            if (cell != null && cell.isFilled && cell.color != 0) {
              // Avoid duplicates (cells in both row and col)
              if (!cellsForParticles.any((c) => c['row'] == row && c['col'] == col)) {
                cellsForParticles.add({
                  'row': row,
                  'col': col,
                  'color': cell.color,
                });
              }
            }
          }
        }
        
        // Mark cells for clearing briefly to trigger particles, then clear immediately
        grid.markFullLinesForClearing();
        
        // Clear immediately without waiting for animation
        grid.clearFullLines();
        
        // Increase combo count
        _comboCount++;
        if (_comboCount > _maxCombo) {
          _maxCombo = _comboCount;
        }
        
        // Calculate score with combo multiplier and bonuses
        int baseScore = clearedLines * GameConstants.pointsPerLine;
        
        // Multi-line bonus
        int multiLineBonus = 0;
        if (clearedLines >= 5) {
          multiLineBonus = GameConstants.megaLineBonus;
        } else if (clearedLines >= 4) {
          multiLineBonus = GameConstants.quadLineBonus;
        } else if (clearedLines >= 3) {
          multiLineBonus = GameConstants.tripleLineBonus;
        } else if (clearedLines >= 2) {
          multiLineBonus = GameConstants.doubleLineBonus;
        }
        
        // Combo multiplier (caps at maxComboMultiplier)
        int comboMultiplier = _comboCount.clamp(
          GameConstants.baseComboMultiplier, 
          GameConstants.maxComboMultiplier
        );
        
        // Final score calculation
        int finalScore = (baseScore + multiLineBonus) * comboMultiplier;
        _score += finalScore;
        _totalLinesCleared += clearedLines;
        
        audioManager.playLineClear();
        
        // Update best score if needed
        if (_score > _bestScore) {
          _bestScore = _score;
          _saveBestScore();
        }
        
        // Trigger character for line clear
        _triggerCharacter(CharacterType.onLineClear, clearedLines);
        
        _updateLevel();
      } else {
        // No lines cleared - reset combo
        _comboCount = 0;
        _score += block.cellCount * GameConstants.pointsPerBlock;
        // Update best score if needed
        if (_score > _bestScore) {
          _bestScore = _score;
          _saveBestScore();
        }
      }
      
      // Generate new blocks if queue is empty
      if (blockQueue.isEmpty) {
        _generateNewBlocks();
      }
      
      // Check game over
      _checkGameOver();
      
      return true;
    }
    return false;
  }
  
  /// Check if game is over
  void _checkGameOver() {
    // Check if any block can be placed
    for (var block in blockQueue) {
      for (int row = 0; row <= grid.rows - block.height; row++) {
        for (int col = 0; col <= grid.cols - block.width; col++) {
          if (grid.canPlaceBlock(block.shapeMatrix, row, col)) {
            return; // At least one block can be placed
          }
        }
      }
    }
    
    // No blocks can be placed - game over
    _state = GameState.gameOver;
    audioManager.playGameOver();
    
    // Trigger game over character
    final gameOverChar = ItalianBrainrotCharacters.getCharacterForEvent(
      type: CharacterType.onGameOver,
      score: _score,
      level: _level,
      linesCleared: _totalLinesCleared,
    );
    if (gameOverChar != null) {
      _currentCharacter = gameOverChar;
      characterAudioManager.playCharacterSound(gameOverChar);
    }
  }
  
  /// Update level based on score
  void _updateLevel() {
    final newLevel = (_score ~/ 1000) + 1;
    if (newLevel > _level) {
      _level = newLevel;
      // Regenerate blocks with new difficulty when level increases
      _generateNewBlocks();
      // Trigger character for level up
      _triggerCharacter(CharacterType.onLevelUp, _level);
    }
    
    // Also check for score-based characters
    _triggerCharacter(CharacterType.onScore, _score);
  }
  
  /// Trigger character appearance based on event
  void _triggerCharacter(CharacterType type, int value) {
    final character = ItalianBrainrotCharacters.getCharacterForEvent(
      type: type,
      score: _score,
      level: _level,
      linesCleared: _totalLinesCleared,
    );
    
    if (character != null && character.shouldAppear(_score, _level, _totalLinesCleared)) {
      _currentCharacter = character;
      characterAudioManager.playCharacterSound(character);
      
      // Clear character after animation
      Future.delayed(const Duration(seconds: 3), () {
        _currentCharacter = null;
      });
    }
  }
  
  /// Clear current character
  void clearCharacter() {
    _currentCharacter = null;
  }
  
  /// Rotate a block
  Block? rotateBlock(Block block) {
    final index = blockQueue.indexWhere((b) => b.id == block.id);
    if (index != -1) {
      blockQueue[index] = block.rotate();
      return blockQueue[index];
    }
    return null;
  }
  
  /// Pause game
  void pause() {
    if (_state == GameState.playing) {
      _state = GameState.paused;
    }
  }
  
  /// Resume game
  void resume() {
    if (_state == GameState.paused) {
      _state = GameState.playing;
    }
  }
  
  /// Reset game
  void reset() {
    // Initialize grid with fewer blocks for easier start
    grid.initializeWithRandomBlocks(numBlocks: 5);
    _score = GameConstants.initialScore;
    _level = 1;
    _totalLinesCleared = 0;
    _comboCount = 0;
    _maxCombo = 0;
    _state = GameState.playing;
    _currentCharacter = null;
    _loadBestScore(); // Reload best score
    _generateNewBlocks();
  }
  
  /// Dispose resources
  void dispose() {
    audioManager.dispose();
    characterAudioManager.dispose();
  }
}

