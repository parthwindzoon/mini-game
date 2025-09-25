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

// Enhanced Scrollable Number Learning Game using Flutter widgets
class ScrollableNumberGame extends StatefulWidget {
  const ScrollableNumberGame({super.key});

  @override
  State<ScrollableNumberGame> createState() => _ScrollableNumberGameState();
}

class _ScrollableNumberGameState extends State<ScrollableNumberGame> {
  int selectedNumber = 0;
  bool showNumberDetails = false;

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
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'NUMBER LEARNING',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Tap numbers to learn! (1-100)',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (selectedNumber > 0) ...[
                      const SizedBox(height: 15),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Text(
                          _getNumberInfo(selectedNumber),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Scrollable Grid
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(10),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: 100,
                    itemBuilder: (context, index) {
                      final number = index + 1;
                      return _NumberButton(
                        number: number,
                        isSelected: selectedNumber == number,
                        onTap: () => _onNumberTapped(number),
                      );
                    },
                  ),
                ),
              ),

              // Fun facts section
              if (selectedNumber > 0)
                Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Fun Facts about $selectedNumber',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getNumberFacts(selectedNumber),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _onNumberTapped(int number) {
    setState(() {
      selectedNumber = number;
      showNumberDetails = true;
    });

    // Here you could play number audio
    // AudioManager.playNumber(number.toString());
  }

  String _getNumberInfo(int number) {
    if (number <= 10) {
      return 'You selected $number! ${_getNumberName(number)}';
    } else if (number <= 20) {
      return 'You selected $number! This is in the teens.';
    } else if (number % 10 == 0) {
      return 'You selected $number! This is a round number (multiple of 10).';
    } else {
      return 'You selected $number! This has ${number.toString().length} digits.';
    }
  }

  String _getNumberName(int number) {
    const names = [
      '', 'One', 'Two', 'Three', 'Four', 'Five',
      'Six', 'Seven', 'Eight', 'Nine', 'Ten'
    ];
    return number <= 10 ? names[number] : number.toString();
  }

  String _getNumberFacts(int number) {
    List<String> facts = [];

    // Basic properties
    if (number % 2 == 0) {
      facts.add('Even number');
    } else {
      facts.add('Odd number');
    }

    // Special numbers
    if (number <= 10) {
      facts.add('Single digit');
    } else if (number < 100) {
      facts.add('Double digit');
    } else {
      facts.add('Triple digit');
    }

    // Special cases
    if (number == 1) facts.add('The first counting number');
    if (number == 10) facts.add('One dozen minus two');
    if (number == 12) facts.add('One dozen');
    if (number == 50) facts.add('Half of one hundred');
    if (number == 100) facts.add('One hundred - a perfect square!');

    // Multiples
    if (number % 5 == 0 && number != 5) facts.add('Multiple of 5');
    if (number % 10 == 0 && number != 10) facts.add('Multiple of 10');

    // Prime numbers (simplified list)
    List<int> primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97];
    if (primes.contains(number)) {
      facts.add('Prime number');
    }

    return facts.take(3).join(' • ');
  }
}

class _NumberButton extends StatefulWidget {
  final int number;
  final bool isSelected;
  final VoidCallback onTap;

  const _NumberButton({
    required this.number,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_NumberButton> createState() => _NumberButtonState();
}

class _NumberButtonState extends State<_NumberButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getColorForNumber(int number) {
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

    return palette[(number - 1) % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: GestureDetector(
              onTapDown: (_) {
                _animationController.forward();
              },
              onTapUp: (_) {
                _animationController.reverse();
                widget.onTap();
              },
              onTapCancel: () {
                _animationController.reverse();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? Colors.yellow.shade400
                      : _getColorForNumber(widget.number),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: widget.isSelected ? 8 : 4,
                      offset: Offset(0, widget.isSelected ? 4 : 2),
                      spreadRadius: widget.isSelected ? 1 : 0,
                    ),
                  ],
                  border: widget.isSelected
                      ? Border.all(color: Colors.white, width: 3)
                      : Border.all(
                    color: Colors.white.withOpacity(0.8),
                    width: 2,
                  ),
                ),
                child: Stack(
                  children: [
                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.3),
                            Colors.transparent,
                            Colors.black.withOpacity(0.1),
                          ],
                        ),
                      ),
                    ),
                    // Number text
                    Center(
                      child: Text(
                        widget.number.toString(),
                        style: TextStyle(
                          color: widget.isSelected ? Colors.black : Colors.white,
                          fontSize: widget.number.toString().length == 1 ? 24 :
                          widget.number.toString().length == 2 ? 20 : 16,
                          fontWeight: FontWeight.w900,
                          shadows: widget.isSelected ? [] : [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              offset: const Offset(1, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Special effects for milestone numbers
                    if (widget.number % 10 == 0)
                      Positioned(
                        top: 2,
                        right: 2,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.yellow,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    if (widget.number == 100)
                      const Positioned(
                        top: 2,
                        left: 2,
                        child: Text(
                          '🎉',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}