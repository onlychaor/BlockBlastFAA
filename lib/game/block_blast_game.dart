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
  GameState _state = GameState.playing;
  Character? _currentCharacter;
  
  BlockBlastGame()
      : grid = Grid(),
        blockQueue = [],
        audioManager = AudioManager(),
        characterAudioManager = CharacterAudioManager() {
    _loadBestScore();
    // Initialize grid with random blocks at start
    grid.initializeWithRandomBlocks(numBlocks: 8);
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
  
  /// Generate new blocks for the queue
  void _generateNewBlocks() {
    blockQueue.clear();
    final shapes = BlockShapes.getShapesByLevel(_level, GameConstants.maxBlocksInQueue);
    for (var shape in shapes) {
      final color = Helpers.getRandomColor(GameConstants.blockColors);
      blockQueue.add(Block(
        shape: BlockShape(shape: shape, name: 'block'),
        color: color,
      ));
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
        // Mark cells for clearing animation first
        grid.markFullLinesForClearing();
        
        // Wait for animation then clear
        Future.delayed(GameConstants.lineClearAnimation, () {
          grid.clearFullLines();
        });
        
        _score += clearedLines * GameConstants.pointsPerLine;
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
    // Initialize grid with random blocks when resetting
    grid.initializeWithRandomBlocks(numBlocks: 8);
    _score = GameConstants.initialScore;
    _level = 1;
    _totalLinesCleared = 0;
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

