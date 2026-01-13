import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_game/MemoryMatch/components/memory_match_game.dart';

class CardMemory extends PositionComponent with TapCallbacks,HasGameRef<MemoryMatchGame>{
  final String icon;
  bool isFlipped = false;
  bool isMatched = false;
  
  late RectangleComponent back;
  late TextComponent front;
  late RectangleComponent border;

  CardMemory({
    required super.position,
    required this.icon,
    required super.size,
  });

  @override
  Future<void> onLoad() async {
    anchor = Anchor.topLeft;

    // Border
    border = RectangleComponent(
      size: size,
      paint: Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    add(border);

    // Back (blue card back - initially visible)
    back = RectangleComponent(
      size: size,
      paint: Paint()..color = const Color(0xFF3498DB),
    );
    add(back);

    // Front (emoji - initially hidden)
    front = TextComponent(
      text: icon,
      position: size / 2,
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.transparent,  // Hidden initially
          fontSize: 48,
        ),
      ),
    );
    add(front);
  }

  void flip() {
    if (isFlipped || isMatched) return;
    isFlipped = true;
    
    // Hide back, show front
    back.paint.color = Colors.white;
    front.textRenderer = TextPaint(
      style: const TextStyle(
        color: Colors.black,
        fontSize: 48,
      ),
    );
  }

  void unflip() {
    if (isMatched) return;
    isFlipped = false;
    
    // Show back, hide front
    back.paint.color = const Color(0xFF3498DB);
    front.textRenderer = TextPaint(
      style: const TextStyle(
        color: Colors.transparent,
        fontSize: 48,
      ),
    );
  }

  void match() {
    isMatched = true;
    isFlipped = true;
    
    // Green background for matched cards
    back.paint.color = const Color(0xFF27AE60);
    front.textRenderer = TextPaint(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 48,
      ),
    );
    border.paint.color = const Color(0xFF27AE60);
  }

  @override
  void onTapDown(TapDownEvent event) {
    gameRef.handleFlip(this);
  }
}