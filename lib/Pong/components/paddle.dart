import 'package:flame/components.dart';
import 'package:flutter_game/Pong/pong_game.dart';
import 'package:flutter/material.dart';


class Paddle extends RectangleComponent with HasGameRef<PongGame>{
  double speed = 300;  // Pixels/second

  Paddle({required this.isPlayer}) : super(
    size: Vector2(10, 80),  // Use literals—no statics
    paint: Paint()..color = Colors.white,
  );

  final bool isPlayer;

  @override
  void update(double dt) {
    super.update(dt);
    // Clamp to screen bounds
    position.y = position.y.clamp(0, gameRef.size.y - height);  // Use instance height
  }

  void moveUp(double dt) => position.y -= speed * dt;
  void moveDown(double dt) => position.y += speed * dt;
}