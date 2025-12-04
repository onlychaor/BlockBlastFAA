class GridCell {
  final int row;
  final int col;
  bool _isFilled = false;
  int _color = 0;
  bool _isMarkedForClearing = false;
  
  GridCell({
    required this.row,
    required this.col,
  });
  
  bool get isEmpty => !_isFilled;
  bool get isFilled => _isFilled;
  int get color => _color;
  bool get isMarkedForClearing => _isMarkedForClearing;
  bool get isClearing => _isMarkedForClearing;
  
  void fill(int color) {
    _isFilled = true;
    _color = color;
  }
  
  void clear() {
    _isFilled = false;
    _color = 0;
    _isMarkedForClearing = false;
  }
  
  void markForClearing() {
    _isMarkedForClearing = true;
  }
  
  void unmarkForClearing() {
    _isMarkedForClearing = false;
  }
}

