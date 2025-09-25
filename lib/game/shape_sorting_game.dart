import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class ShapeSortingGame extends FlameGame with HasCollisionDetection, DragCallbacks {
  late List<ShapeTarget> targets;
  late List<DraggableShape> shapes;
  int score = 0;
  late TextComponent scoreText;
  late TextComponent instructionText;
  DraggableShape? draggedShape;

  @override
  Color backgroundColor() => const Color(0xFF87CEEB);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Add instruction text
    instructionText = TextComponent(
      text: 'Drag shapes to matching targets!',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(size.x / 2, 60),
      anchor: Anchor.center,
    );
    add(instructionText);

    // Add score text
    scoreText = TextComponent(
      text: 'Score: $score',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(size.x - 20, 30),
      anchor: Anchor.topRight,
    );
    add(scoreText);

    // Create targets
    targets = [];
    final targetSize = 80.0;
    final targetY = size.y - 150;

    final shapeTypes = [ShapeType.circle, ShapeType.square, ShapeType.triangle];
    for (int i = 0; i < shapeTypes.length; i++) {
      final target = ShapeTarget(
        shapeType: shapeTypes[i],
        size: Vector2.all(targetSize),
        position: Vector2(50 + i * (targetSize + 30), targetY),
      );
      targets.add(target);
      add(target);
    }

    // Create draggable shapes
    shapes = [];
    _createNewShapes();
  }

  void _createNewShapes() {
    // Clear existing shapes
    for (final shape in shapes) {
      shape.removeFromParent();
    }
    shapes.clear();

    final shapeTypes = [ShapeType.circle, ShapeType.square, ShapeType.triangle];
    final random = Random();

    for (int i = 0; i < 6; i++) {
      final shapeType = shapeTypes[random.nextInt(shapeTypes.length)];
      final shape = DraggableShape(
        shapeType: shapeType,
        size: Vector2.all(50),
        position: Vector2(
          50 + (i % 3) * 80,
          150 + (i ~/ 3) * 80,
        ),
        game: this,
      );
      shapes.add(shape);
      add(shape);
    }
  }

  @override
  void onDragStart(DragStartEvent event) {
    final point = event.localPosition;
    // Find which shape was touched
    for (final shape in shapes) {
      if (shape.containsPoint(point)) {
        draggedShape = shape;
        shape.onDragStart();
        break;
      }
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (draggedShape != null) {
      draggedShape!.position += event.localDelta;
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    if (draggedShape != null) {
      draggedShape!.onDragEnd();
      draggedShape = null;
    }
  }

  void checkMatch(DraggableShape shape, ShapeTarget target) {
    if (shape.shapeType == target.shapeType) {
      // Correct match!
      score += 10;
      scoreText.text = 'Score: $score';

      // Remove the shape
      shape.removeFromParent();
      shapes.remove(shape);

      // Show success feedback
      final successText = TextComponent(
        text: 'Great! +10',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.green,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        position: target.position + Vector2(0, -50),
        anchor: Anchor.center,
      );
      add(successText);

      // Remove success text after delay
      Future.delayed(const Duration(seconds: 1), () {
        successText.removeFromParent();
      });

      // Check if all shapes are sorted
      if (shapes.isEmpty) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _createNewShapes();
        });
      }
    } else {
      // Wrong match - return shape to original position
      shape.returnToOriginalPosition();
    }
  }
}

enum ShapeType { circle, square, triangle }

class ShapeTarget extends PositionComponent {
  final ShapeType shapeType;

  ShapeTarget({
    required this.shapeType,
    required Vector2 size,
    required Vector2 position,
  }) : super(size: size, position: position, anchor: Anchor.center);

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final center = size / 2;

    switch (shapeType) {
      case ShapeType.circle:
        canvas.drawCircle(center.toOffset(), size.x / 2 - 5, paint);
        break;
      case ShapeType.square:
        canvas.drawRect(
          Rect.fromCenter(
            center: center.toOffset(),
            width: size.x - 10,
            height: size.y - 10,
          ),
          paint,
        );
        break;
      case ShapeType.triangle:
        final path = Path();
        path.moveTo(center.x, 5);
        path.lineTo(5, size.y - 5);
        path.lineTo(size.x - 5, size.y - 5);
        path.close();
        canvas.drawPath(path, paint);
        break;
    }
  }
}

class DraggableShape extends PositionComponent {
  final ShapeType shapeType;
  final ShapeSortingGame game;
  late Vector2 originalPosition;
  bool isDragging = false;

  DraggableShape({
    required this.shapeType,
    required this.game,
    required Vector2 size,
    required Vector2 position,
  }) : super(size: size, position: position, anchor: Anchor.center) {
    originalPosition = position.clone();
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = _getShapeColor()
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = size / 2;

    // Add shadow if being dragged
    if (isDragging) {
      final shadowPaint = Paint()
        ..color = Colors.black26
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.save();
      canvas.translate(2, 2);
      _drawShape(canvas, shadowPaint, center);
      canvas.restore();
    }

    // Draw main shape
    _drawShape(canvas, paint, center);
    _drawShape(canvas, strokePaint, center);
  }

  void _drawShape(Canvas canvas, Paint paint, Vector2 center) {
    switch (shapeType) {
      case ShapeType.circle:
        canvas.drawCircle(center.toOffset(), size.x / 2 - 2, paint);
        break;
      case ShapeType.square:
        final rect = Rect.fromCenter(
          center: center.toOffset(),
          width: size.x - 4,
          height: size.y - 4,
        );
        canvas.drawRect(rect, paint);
        break;
      case ShapeType.triangle:
        final path = Path();
        path.moveTo(center.x, 2);
        path.lineTo(2, size.y - 2);
        path.lineTo(size.x - 2, size.y - 2);
        path.close();
        canvas.drawPath(path, paint);
        break;
    }
  }

  Color _getShapeColor() {
    switch (shapeType) {
      case ShapeType.circle:
        return Colors.red;
      case ShapeType.square:
        return Colors.blue;
      case ShapeType.triangle:
        return Colors.green;
    }
  }

  void onDragStart() {
    isDragging = true;
    priority = 1; // Bring to front when dragging
  }

  void onDragEnd() {
    isDragging = false;
    priority = 0;

    // Check if dropped on any target
    bool matched = false;
    for (final target in game.targets) {
      if (_isOverlapping(target)) {
        game.checkMatch(this, target);
        matched = true;
        break;
      }
    }

    if (!matched) {
      returnToOriginalPosition();
    }
  }

  bool _isOverlapping(ShapeTarget target) {
    final distance = position.distanceTo(target.position);
    return distance < (size.x / 2 + target.size.x / 2);
  }

  void returnToOriginalPosition() {
    // Return shape to original position
    position = originalPosition.clone();
  }

  bool containsPoint(Vector2 point) {
    final localPoint = point - position;
    return localPoint.x.abs() <= size.x / 2 && localPoint.y.abs() <= size.y / 2;
  }
}