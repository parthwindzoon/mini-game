import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../components/number_tile.dart';

class NumberLearningGame extends FlameGame with HasCollisionDetection {
  final numbers = List.generate(100, (i) => (i + 1).toString());
  late PositionComponent contentContainer;
  double scrollOffset = 0;
  double maxScrollOffset = 0;

  Vector2? lastTouchPosition;
  bool isScrolling = false;

  @override
  Color backgroundColor() => const Color(0xFF4CAF50);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Add title
    add(
      TextComponent(
        text: 'NUMBER LEARNING',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        position: Vector2(size.x / 2, 40),
        anchor: Anchor.center,
      ),
    );

    // Add subtitle
    add(
      TextComponent(
        text: 'Tap numbers to learn! Drag to scroll',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        position: Vector2(size.x / 2, 70),
        anchor: Anchor.center,
      ),
    );

    // Create scrollable content
    _setupScrollableContent();
  }

  void _setupScrollableContent() {
    // Create content container
    contentContainer = PositionComponent()
      ..position = Vector2(0, 100);

    const columns = 5;
    const padding = 20.0;
    const tileSize = 70.0;
    const spacing = 12.0;

    final containerWidth = size.x;
    final tileWidth = (containerWidth - padding * 2 - spacing * (columns - 1)) / columns;

    // Calculate total content height
    final rows = (numbers.length / columns).ceil();
    final totalContentHeight = rows * (tileSize + spacing) - spacing;
    final visibleHeight = size.y - 150; // Account for title and margins
    maxScrollOffset = (totalContentHeight - visibleHeight).clamp(0, double.infinity);

    for (int i = 0; i < numbers.length; i++) {
      final number = numbers[i];
      final col = i % columns;
      final row = i ~/ columns;
      final posX = padding + col * (tileWidth + spacing);
      final posY = row * (tileSize + spacing);

      final tile = NumberTile(
        number: number,
        position: Vector2(posX, posY),
        size: Vector2(tileWidth, tileSize),
      );

      contentContainer.add(tile);
    }

    add(contentContainer);
  }

  @override
  void onTapDown(TapDownEvent event) {
    lastTouchPosition = event.localPosition;
    isScrolling = false;
  }

  @override
  void onTapUp(TapUpEvent event) {
    lastTouchPosition = null;
    isScrolling = false;
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    lastTouchPosition = null;
    isScrolling = false;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Handle continuous touch movement for scrolling
    if (lastTouchPosition != null) {
      // This is a simple approach - in a real implementation,
      // you'd want to track finger movement more precisely
    }
  }

  // Simple scroll method that can be called
  void scroll(double deltaY) {
    scrollOffset -= deltaY;
    scrollOffset = scrollOffset.clamp(0, maxScrollOffset);
    contentContainer.position.y = 100 - scrollOffset;
  }
}

// Alternative: Wrap the game in a Flutter SingleChildScrollView
class ScrollableNumberGame extends StatelessWidget {
  const ScrollableNumberGame({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              const Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'NUMBER LEARNING',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Tap numbers to learn! (1-100)',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Scrollable Grid - This will now work!
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: 100,
                  itemBuilder: (context, index) {
                    final number = (index + 1).toString();
                    return _NumberButton(number: number);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _NumberButton extends StatefulWidget {
  final String number;

  const _NumberButton({required this.number});

  @override
  State<_NumberButton> createState() => _NumberButtonState();
}

class _NumberButtonState extends State<_NumberButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getColorForNumber(String number) {
    final palette = [
      const Color(0xFF3498DB), // Blue
      const Color(0xFFE74C3C), // Red
      const Color(0xFF2ECC71), // Green
      const Color(0xFFF39C12), // Orange
      const Color(0xFF9B59B6), // Purple
      const Color(0xFF1ABC9C), // Turquoise
      const Color(0xFFE67E22), // Carrot
      const Color(0xFFE91E63), // Pink
      const Color(0xFF34495E), // Dark Blue
      const Color(0xFF16A085), // Green Sea
    ];

    final numberValue = int.parse(number);
    return palette[(numberValue - 1) % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) {
              _animationController.forward();
            },
            onTapUp: (_) {
              _animationController.reverse();
              // Here you could play number audio
            },
            onTapCancel: () {
              _animationController.reverse();
            },
            child: Container(
              decoration: BoxDecoration(
                color: _getColorForNumber(widget.number),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.8),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  widget.number,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: widget.number.length == 1 ? 32 :
                    widget.number.length == 2 ? 26 : 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}