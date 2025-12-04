import 'block_shape.dart';
import 'dart:math';

class Block {
  final String id;
  final BlockShape shape;
  final int color;
  
  Block({
    required this.shape,
    required this.color,
    String? id,
  }) : id = id ?? _generateId();
  
  static String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() + 
           Random().nextInt(1000).toString();
  }
  
  int get width => shape.shape[0].length;
  int get height => shape.shape.length;
  
  List<List<bool>> get shapeMatrix => shape.shape;
  
  int get cellCount {
    int count = 0;
    for (var row in shapeMatrix) {
      for (var cell in row) {
        if (cell) count++;
      }
    }
    return count;
  }
  
  Block copy() {
    return Block(
      shape: BlockShape(
        shape: shapeMatrix.map((row) => List<bool>.from(row)).toList(),
        name: shape.name,
      ),
      color: color,
      id: id,
    );
  }
  
  Block rotate() {
    // Rotate 90 degrees clockwise
    final rows = shapeMatrix.length;
    final cols = shapeMatrix[0].length;
    final rotated = List.generate(
      cols,
      (i) => List.generate(rows, (j) => shapeMatrix[rows - 1 - j][i]),
    );
    
    return Block(
      shape: BlockShape(
        shape: rotated,
        name: shape.name,
      ),
      color: color,
      id: id,
    );
  }
}

