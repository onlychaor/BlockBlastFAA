import 'package:flutter/material.dart';
import 'character.dart';

class CharacterRenderer extends StatelessWidget {
  final Character character;
  final VoidCallback? onAnimationComplete;
  
  const CharacterRenderer({
    super.key,
    required this.character,
    this.onAnimationComplete,
  });
  
  @override
  Widget build(BuildContext context) {
    // Simple placeholder - can be enhanced later
    return const SizedBox.shrink();
  }
}

