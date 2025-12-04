import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../game/block_blast_game.dart';
import '../game/grid/grid_renderer.dart';
import '../game/blocks/block.dart';
import '../game/blocks/block_renderer.dart';
import '../game/input/drag_controller.dart';
import '../game/characters/character_renderer.dart';
import 'effects/explosion_effect.dart';
import 'effects/text_effect.dart';
import '../utils/constants.dart';
import 'settings_screen.dart';

enum ComboEffectType {
  explosion,
  text,
}

class ComboEffect {
  final ComboEffectType type;
  final Offset position;
  final Color color;
  final String? text;
  final double fontSize;
  
  ComboEffect({
    required this.type,
    required this.position,
    required this.color,
    this.text,
    this.fontSize = 0,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late BlockBlastGame game;
  late DragController dragController;
  final GlobalKey _gridKey = GlobalKey();
  final List<ComboEffect> _activeEffects = [];
  
  // Cache for drag optimization
  int? _lastGridRow;
  int? _lastGridCol;
  bool? _lastCanPlace;
  
  // Track rotated blocks to skip animation on rotation
  final Set<String> _rotatedBlocks = {};
  
  @override
  void initState() {
    super.initState();
    game = BlockBlastGame();
    dragController = DragController();
    // Clear rotated blocks when new blocks are generated
    _rotatedBlocks.clear();
  }
  
  @override
  void dispose() {
    game.dispose();
    super.dispose();
  }
  
  // Removed block rotation - blocks now have fixed shapes
  
  void _onBlockDragStart(Block block, DragStartDetails details) {
    dragController.startDrag(block, details.globalPosition);
    // Reset cache
    _lastGridRow = null;
    _lastGridCol = null;
    _lastCanPlace = null;
    setState(() {});
  }
  
  void _onBlockDragUpdate(DragUpdateDetails details) {
    if (!dragController.isDragging) return;
    
    // Get grid position - no throttling for maximum smoothness
    final RenderBox? gridBox = _gridKey.currentContext?.findRenderObject() as RenderBox?;
    if (gridBox != null) {
      final gridLocalPosition = gridBox.globalToLocal(details.globalPosition);
      final oldRow = dragController.gridRow;
      final oldCol = dragController.gridCol;
      dragController.updateDrag(gridLocalPosition);
      
      // Only update UI if grid position actually changed
      final newRow = dragController.gridRow;
      final newCol = dragController.gridCol;
      if (oldRow != newRow || oldCol != newCol) {
        _lastGridRow = newRow;
        _lastGridCol = newCol;
        _lastCanPlace = null; // Invalidate cache when position changes
        // Direct setState for immediate response - no batching delay
        setState(() {});
      }
    } else {
      // If grid not found, still update drag position for visual feedback
      dragController.updateDrag(details.globalPosition);
      setState(() {});
    }
  }
  
  void _onBlockDragEnd(DragEndDetails details) {
    if (!dragController.isDragging) return;
    
    // Save grid position before ending drag
    final gridRow = dragController.gridRow;
    final gridCol = dragController.gridCol;
    final block = dragController.endDrag();
    
    // Clear cache
    _lastGridRow = null;
    _lastGridCol = null;
    _lastCanPlace = null;
    
    if (block != null && gridRow != null && gridCol != null) {
      // Check if block can be placed (both bounds and empty cells)
      if (gridRow >= 0 && gridCol >= 0 &&
          gridRow + block.height <= GameConstants.gridRows && 
          gridCol + block.width <= GameConstants.gridCols) {
        // Get previous cleared lines count
        final previousClearedLines = game.totalLinesCleared;
        
        // Try to place the block - this will check if cells are empty
        final placed = game.placeBlock(block, gridRow, gridCol);
        if (placed) {
          // Remove from rotated blocks when placed
          _rotatedBlocks.remove(block.id);
          // Check if lines were cleared
          final newClearedLines = game.totalLinesCleared - previousClearedLines;
          if (newClearedLines > 0) {
            _triggerComboEffects(newClearedLines);
          }
          // Clear rotated blocks when new blocks are generated
          if (game.currentBlocks.isEmpty || game.currentBlocks.length < 3) {
            _rotatedBlocks.clear();
          }
          // Direct setState for immediate feedback
          setState(() {});
          return;
        }
      }
    }
    // Direct setState for immediate feedback
    setState(() {});
  }
  
  void _triggerComboEffects(int clearedLines) {
    // Get grid center position
    final RenderBox? gridBox = _gridKey.currentContext?.findRenderObject() as RenderBox?;
    if (gridBox == null) return;
    
    final gridCenter = Offset(
      gridBox.size.width / 2,
      gridBox.size.height / 2,
    );
    
    // Determine text based on number of cleared lines with vibrant colors
    String? text1;
    String? text2;
    Color textColor;
    double fontSize1;
    double fontSize2;
    
    if (clearedLines >= 3) {
      text1 = 'BIG COMBO!';
      text2 = 'BRAINROT BONUS!';
      textColor = const Color(0xFFFF6B35); // Vibrant orange
      fontSize1 = 36;
      fontSize2 = 32;
    } else if (clearedLines >= 2) {
      text1 = 'COMBO!';
      text2 = 'EXTRA CHAOS!';
      textColor = const Color(0xFFFFD700); // Gold yellow
      fontSize1 = 34;
      fontSize2 = 30;
    } else {
      text1 = 'CLEARED!';
      textColor = const Color(0xFF4ECDC4); // Bright teal
      fontSize1 = 32;
      fontSize2 = 0;
    }
    
    // Add explosion effect at grid center
    setState(() {
      _activeEffects.add(ComboEffect(
        type: ComboEffectType.explosion,
        position: gridCenter,
        color: textColor,
        text: null,
        fontSize: 0,
      ));
      
      // Add text effects with better positioning
      if (text1 != null) {
        _activeEffects.add(ComboEffect(
          type: ComboEffectType.text,
          position: Offset(
            gridCenter.dx - (fontSize1 * text1.length * 0.3),
            gridCenter.dy - 60,
          ),
          color: textColor,
          text: text1,
          fontSize: fontSize1,
        ));
      }
      
      if (text2 != null && fontSize2 > 0) {
        _activeEffects.add(ComboEffect(
          type: ComboEffectType.text,
          position: Offset(
            gridCenter.dx - (fontSize2 * text2.length * 0.3),
            gridCenter.dy + 20,
          ),
          color: textColor,
          text: text2,
          fontSize: fontSize2,
        ));
      }
    });
    
    // Remove effects after animation
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        setState(() {
          _activeEffects.clear();
        });
      }
    });
  }
  
  void _resetGame() {
    setState(() {
      game.reset();
    });
  }
  
  Widget _buildGhostBlock() {
    if (dragController.draggedBlock == null) return const SizedBox();
    
    // Cache canPlace check to avoid recalculating on every rebuild
    final currentRow = dragController.gridRow;
    final currentCol = dragController.gridCol;
    bool canPlace;
    
    if (currentRow == _lastGridRow && currentCol == _lastGridCol && _lastCanPlace != null) {
      // Use cached value if position hasn't changed
      canPlace = _lastCanPlace!;
    } else {
      // Check if block can be placed on grid (including empty cells check)
      canPlace = dragController.canPlaceOnGrid(game.grid);
      _lastCanPlace = canPlace;
      _lastGridRow = currentRow;
      _lastGridCol = currentCol;
    }
    
    // Use RepaintBoundary and const constructors for better performance
    return RepaintBoundary(
      child: Opacity(
        opacity: canPlace ? 0.5 : 0.3,
        child: _buildGhostBlockCells(dragController.draggedBlock!, canPlace),
      ),
    );
  }
  
  Widget _buildGhostBlockCells(Block block, bool canPlace) {
    // Use BlockRenderer to ensure consistent rendering with queue blocks
    // This ensures the ghost block has the exact same shape as the block in queue
    // Use same cellSize as grid cells (40px) to ensure perfect alignment
    return BlockRenderer(
      block: block,
      cellSize: GameConstants.cellSize,
      opacity: canPlace ? 0.5 : 0.3,
    );
  }
  
  Widget _buildBlockInQueue(Block block, int shapeHash) {
    // All blocks centered evenly regardless of shape
    return FittedBox(
      fit: BoxFit.contain,
      child: BlockRenderer(
        key: ValueKey('renderer_${block.id}_$shapeHash'),
        block: block,
        cellSize: 16.0,
      ),
    );
  }
  
  
  Widget _buildScoreItem(String label, int value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: GoogleFonts.fredoka(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        )
            .animate(key: ValueKey('$label$value'))
            .scale(begin: const Offset(1.2, 1.2), end: const Offset(1, 1), duration: 300.ms)
            .then()
            .shimmer(duration: 1000.ms, color: color.withOpacity(0.5)),
      ],
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/nengo.png'),
                  fit: BoxFit.cover,
                ),
                color: Colors.blue, // Fallback color
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                AppBar(
                  title: Text(
                    'Block Blast',
                    style: GoogleFonts.fredoka(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .slideX(begin: -0.2, end: 0),
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  toolbarHeight: 48,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.settings, size: 26),
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SettingsScreen(),
                          ),
                        );
                      },
                      tooltip: 'Settings',
                    )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 200.ms)
                        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
                  ],
                ),
                Expanded(
                  child: game.state == GameState.gameOver
                      ? _buildGameOverScreen()
                      : _buildGameScreen(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildGameScreen() {
    return Column(
      children: [
        // Score, Best, Level display - centered above grid
        Container(
          margin: const EdgeInsets.only(bottom: 8, top: 20),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Score
                  _buildScoreItem('Score', game.score, Colors.yellow),
                  const SizedBox(width: 24),
                  // Best
                  _buildScoreItem('Best', game.bestScore, Colors.orange),
                  const SizedBox(width: 24),
                  // Level
                  _buildScoreItem('Level', game.level, Colors.lightBlue),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 800.ms, delay: 300.ms)
                .slideY(begin: -0.3, end: 0)
                .shimmer(duration: 2000.ms, delay: 1000.ms, color: Colors.white.withOpacity(0.3)),
          ),
        ),
        
        // Game Grid
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onPanUpdate: (details) {
              if (dragController.isDragging) {
                _onBlockDragUpdate(details);
              }
            },
            onPanEnd: (details) {
              if (dragController.isDragging) {
                _onBlockDragEnd(details);
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      key: _gridKey,
                      child: GridRenderer(
                        key: ValueKey('grid_${game.score}'),
                        grid: game.grid,
                      ),
                    ),
                    // Ghost block preview on grid
                    if (dragController.isDragging && 
                        dragController.draggedBlock != null &&
                        dragController.gridRow != null &&
                        dragController.gridCol != null &&
                        dragController.gridRow! >= 0 &&
                        dragController.gridCol! >= 0 &&
                        dragController.gridRow! + dragController.draggedBlock!.height <= GameConstants.gridRows &&
                        dragController.gridCol! + dragController.draggedBlock!.width <= GameConstants.gridCols)
                      Builder(
                        builder: (context) {
                          // Calculate ghost block position relative to grid container
                          final RenderBox? gridBox = _gridKey.currentContext?.findRenderObject() as RenderBox?;
                          if (gridBox == null) return const SizedBox.shrink();
                          
                          // Get grid container size
                          final gridSize = gridBox.size;
                          
                          // Calculate position relative to Stack center
                          // Grid is centered in Stack, so we need to offset from center
                          // Grid has padding 4px, and cells have margin 0.5px each side (1px total spacing)
                          const cellMargin = 0.5;
                          final cellSpacing = GameConstants.cellSize + (cellMargin * 2); // cellSize + 1px
                          final gridContentWidth = GameConstants.gridCols * cellSpacing;
                          final gridContentHeight = GameConstants.gridRows * cellSpacing;
                          final gridOffsetX = (gridSize.width - gridContentWidth) / 2;
                          final gridOffsetY = (gridSize.height - gridContentHeight) / 2;
                          
                          // Calculate ghost block position
                          // Position = (col * cellSpacing) + padding + offset
                          final ghostLeft = (dragController.gridCol! * cellSpacing) + 4 + gridOffsetX;
                          final ghostTop = (dragController.gridRow! * cellSpacing) + 4 + gridOffsetY;
                          
                          return Positioned(
                            left: ghostLeft,
                            top: ghostTop,
                            child: _buildGhostBlock(),
                          );
                        },
                      ),
                    // Combo effects (explosions and text)
                    ..._activeEffects.map((effect) {
                      if (effect.type == ComboEffectType.explosion) {
                        return ExplosionEffect(
                          key: ValueKey('explosion_${effect.hashCode}'),
                          position: effect.position,
                          color: effect.color,
                          onComplete: () {
                            setState(() {
                              _activeEffects.remove(effect);
                            });
                          },
                        );
                      } else {
                        return TextEffect(
                          key: ValueKey('text_${effect.hashCode}'),
                          text: effect.text ?? '',
                          color: effect.color,
                          position: effect.position,
                          fontSize: effect.fontSize,
                          onComplete: () {
                            setState(() {
                              _activeEffects.remove(effect);
                            });
                          },
                        );
                      }
                    }),
                    // Character overlay
                    if (game.currentCharacter != null)
                      Positioned(
                        top: 20,
                        child: CharacterRenderer(
                          character: game.currentCharacter!,
                          onAnimationComplete: () {
                            setState(() {
                              game.clearCharacter();
                            });
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
            
        // Block Queue
        Container(
          constraints: const BoxConstraints(maxHeight: 110),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          margin: const EdgeInsets.only(bottom: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: game.currentBlocks.take(3).toList().asMap().entries.map((entry) {
              final index = entry.key;
              final block = entry.value;
              
              // Create a unique key based on block shape to force rebuild when rotated
              final shapeHash = block.shapeMatrix.toString().hashCode;
              return GestureDetector(
                key: ValueKey('block_${block.id}_${block.width}_${block.height}_$shapeHash'),
                behavior: HitTestBehavior.opaque,
                onPanStart: (details) {
                  _onBlockDragStart(block, details);
                },
                onPanUpdate: (details) {
                  _onBlockDragUpdate(details);
                },
                onPanEnd: (details) {
                  _onBlockDragEnd(details);
                },
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: _rotatedBlocks.contains(block.id)
                        ? _buildBlockInQueue(block, shapeHash) // No animation for rotated blocks - instant update
                        : _buildBlockInQueue(block, shapeHash)
                            .animate(key: ValueKey('animate_${block.id}_$shapeHash'))
                            .fadeIn(duration: 500.ms, delay: (index * 100).ms)
                            .slideX(begin: 0.3, end: 0)
                            .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1))
                            .then()
                            .shimmer(duration: 2000.ms, delay: 500.ms, color: Colors.white.withOpacity(0.2)),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
  
  Widget _buildGameOverScreen() {
    return Stack(
      children: [
        // Enhanced background with wood texture effect
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF2A1810).withValues(alpha: 0.95),
                const Color(0xFF1A0F08).withValues(alpha: 0.98),
                const Color(0xFF2A1810).withValues(alpha: 0.95),
              ],
            ),
          ),
          child: CustomPaint(
            painter: _WoodTexturePainter(),
          ),
        ),
        // Main content
        Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Game Over Title with enhanced styling and animations
                  _AnimatedGameOverTitle(),
                  const SizedBox(height: 12),
                  // Enhanced decorative line with glow
                  _AnimatedDecorativeLine(),
                  const SizedBox(height: 40),
                  // Stats Panel with gradient and shadow
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 400),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.grey.shade900.withValues(alpha: 0.95),
                          Colors.grey.shade800.withValues(alpha: 0.95),
                          Colors.black.withValues(alpha: 0.95),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                          spreadRadius: 5,
                        ),
                        BoxShadow(
                          color: Colors.red.withValues(alpha: 0.2),
                          blurRadius: 30,
                          offset: const Offset(0, 0),
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Score
                        _buildStatRow(
                          'Score',
                          game.score.toString(),
                          Colors.yellow.shade400,
                          delay: 800.ms,
                        ),
                        const SizedBox(height: 20),
                        // Best Score
                        _buildStatRow(
                          'Best',
                          game.bestScore.toString(),
                          Colors.orange.shade400,
                          delay: 1000.ms,
                        ),
                        const SizedBox(height: 20),
                        // Level
                        _buildStatRow(
                          'Level',
                          game.level.toString(),
                          Colors.blue.shade300,
                          delay: 1200.ms,
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 800.ms)
                      .slideY(begin: 0.2, end: 0)
                      .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
                  const SizedBox(height: 40),
                  // Enhanced Play Again Button with animations
                  _AnimatedPlayAgainButton(onTap: _resetGame),
                ],
              ),
            ),
          ),
        ),
        // Character overlay on game over
        if (game.currentCharacter != null)
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: CharacterRenderer(
              character: game.currentCharacter!,
              onAnimationComplete: () {
                setState(() {
                  game.clearCharacter();
                });
              },
            ),
          ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value, Color valueColor, {Duration delay = const Duration(milliseconds: 0)}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.9),
            letterSpacing: 1,
          ),
        )
            .animate()
            .fadeIn(duration: 400.ms, delay: delay)
            .slideX(begin: -0.2, end: 0),
        _AnimatedCounter(
          value: int.tryParse(value) ?? 0,
          color: valueColor,
          delay: delay + 200.ms,
        ),
      ],
    );
  }
}

// Animated Game Over Title with pulse glow effect
class _AnimatedGameOverTitle extends StatefulWidget {
  @override
  State<_AnimatedGameOverTitle> createState() => _AnimatedGameOverTitleState();
}

class _AnimatedGameOverTitleState extends State<_AnimatedGameOverTitle>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _bounceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _glowController,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer glow effect
        AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return Container(
              padding: EdgeInsets.all(20 * _glowAnimation.value),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withValues(alpha: 0.3 * _glowAnimation.value),
                    blurRadius: 40 * _glowAnimation.value,
                    spreadRadius: 20 * _glowAnimation.value,
                  ),
                ],
              ),
            );
          },
        ),
        // Glow effect behind text
        AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return Text(
              'GAME OVER',
              style: GoogleFonts.fredoka(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 6
                  ..color = Colors.red.shade400.withValues(alpha: _glowAnimation.value),
              ),
            )
                .animate()
                .fadeIn(duration: 400.ms)
                .scale(begin: const Offset(0.3, 0.3), end: const Offset(1, 1));
          },
        ),
        // Main text with bounce
        AnimatedBuilder(
          animation: _bounceAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: 0.95 + (0.05 * _bounceAnimation.value),
              child: Text(
                'GAME OVER',
                style: GoogleFonts.fredoka(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFF6B9D), // Pinkish-red
                  shadows: [
                    Shadow(
                      offset: const Offset(0, 0),
                      blurRadius: 30,
                      color: Colors.red.shade400.withValues(alpha: _glowAnimation.value * 0.9),
                    ),
                    Shadow(
                      offset: const Offset(0, 0),
                      blurRadius: 50,
                      color: Colors.red.shade600.withValues(alpha: _glowAnimation.value * 0.5),
                    ),
                    Shadow(
                      offset: const Offset(4, 4),
                      blurRadius: 12,
                      color: Colors.black.withValues(alpha: 0.8),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 200.ms)
                  .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1)),
            );
          },
        ),
      ],
    );
  }
}

// Animated counter for stats
class _AnimatedCounter extends StatefulWidget {
  final int value;
  final Color color;
  final Duration delay;

  const _AnimatedCounter({
    required this.value,
    required this.color,
    required this.delay,
  });

  @override
  State<_AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<_AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _counterAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _counterAnimation = IntTween(begin: 0, end: widget.value).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 1.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Text(
            _counterAnimation.value.toString(),
            style: GoogleFonts.fredoka(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: widget.color,
              shadows: [
                Shadow(
                  offset: const Offset(0, 0),
                  blurRadius: 15,
                  color: widget.color.withValues(alpha: 0.7),
                ),
                Shadow(
                  offset: const Offset(2, 2),
                  blurRadius: 6,
                  color: Colors.black.withValues(alpha: 0.6),
                ),
              ],
            ),
          )
              .animate(key: ValueKey(_counterAnimation.value))
              .shimmer(
                duration: 1000.ms,
                color: widget.color.withValues(alpha: 0.5),
              ),
        );
      },
    );
  }
}

// Animated decorative line
class _AnimatedDecorativeLine extends StatefulWidget {
  @override
  State<_AnimatedDecorativeLine> createState() => _AnimatedDecorativeLineState();
}

class _AnimatedDecorativeLineState extends State<_AnimatedDecorativeLine>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          width: 250,
          height: 4,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                Colors.red.shade400.withValues(alpha: _glowAnimation.value),
                Colors.red.shade400.withValues(alpha: _glowAnimation.value),
                Colors.transparent,
              ],
            ),
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(
                color: Colors.red.shade400.withValues(alpha: 0.8 * _glowAnimation.value),
                blurRadius: 12 * _glowAnimation.value,
                spreadRadius: 3 * _glowAnimation.value,
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(duration: 600.ms, delay: 600.ms)
            .scaleX(begin: 0, end: 1);
      },
    );
  }
}

// Animated Play Again Button
class _AnimatedPlayAgainButton extends StatefulWidget {
  final VoidCallback onTap;

  const _AnimatedPlayAgainButton({required this.onTap});

  @override
  State<_AnimatedPlayAgainButton> createState() => _AnimatedPlayAgainButtonState();
}

class _AnimatedPlayAgainButtonState extends State<_AnimatedPlayAgainButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;
  late Animation<double> _bounceAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _bounceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.elasticOut),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _isPressed ? 0.95 : (1.0 + (_bounceAnimation.value * 0.02)),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.green.shade400,
                  Colors.green.shade600,
                  Colors.green.shade700,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.7 * _glowAnimation.value),
                  blurRadius: 20 * _glowAnimation.value,
                  offset: const Offset(0, 5),
                  spreadRadius: 3 * _glowAnimation.value,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                onTapDown: (_) => setState(() => _isPressed = true),
                onTapUp: (_) => setState(() => _isPressed = false),
                onTapCancel: () => setState(() => _isPressed = false),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _controller.value * 2 * 3.14159,
                            child: Icon(
                              Icons.refresh,
                              color: Colors.white,
                              size: 26,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Play Again',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                          shadows: [
                            Shadow(
                              offset: const Offset(0, 2),
                              blurRadius: 6,
                              color: Colors.black.withValues(alpha: 0.6),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
              .animate()
              .fadeIn(duration: 800.ms, delay: 1400.ms)
              .slideY(begin: 0.3, end: 0)
              .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
        );
      },
    );
  }
}

// Wood texture painter for background
class _WoodTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw vertical wood grain lines
    for (double x = 0; x < size.width; x += 3) {
      final variation = (x * 0.1) % 20 - 10;
      paint.color = const Color(0xFF3D2518).withValues(alpha: 0.15 + (variation.abs() / 100));
      canvas.drawLine(
        Offset(x + variation, 0),
        Offset(x + variation, size.height),
        paint,
      );
    }

    // Add subtle horizontal lines for wood texture
    for (double y = 0; y < size.height; y += 40) {
      paint.color = const Color(0xFF2A1810).withValues(alpha: 0.1);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

