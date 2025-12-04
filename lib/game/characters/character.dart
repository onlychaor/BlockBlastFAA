enum CharacterType {
  onLineClear,
  onLevelUp,
  onScore,
  onGameOver,
}

class Character {
  final String name;
  final String imagePath;
  final CharacterType type;
  final int? minScore;
  final int? minLevel;
  final int? minLinesCleared;
  
  Character({
    required this.name,
    required this.imagePath,
    required this.type,
    this.minScore,
    this.minLevel,
    this.minLinesCleared,
  });
  
  bool shouldAppear(int score, int level, int linesCleared) {
    if (minScore != null && score < minScore!) return false;
    if (minLevel != null && level < minLevel!) return false;
    if (minLinesCleared != null && linesCleared < minLinesCleared!) return false;
    return true;
  }
}

