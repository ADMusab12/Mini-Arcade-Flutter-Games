import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_game/Pong/pong_game.dart';

class Ball extends CircleComponent with HasGameRef<PongGame>{
  Vector2 velocity = Vector2(200, 150); 
  final Random rand = Random();
  bool hasCollidedThisFrame = false;

  Ball() : super(
    radius: 8,
    paint: Paint()..color = Colors.white,
  );

  @override
  void update(double dt) {
    super.update(dt);
    
    // Reset collision flag each frame
    hasCollidedThisFrame = false;
    
    position.add(velocity.scaled(dt));

    // Wall bounces (top/bottom)
    if (position.y <= radius || position.y >= gameRef.size.y - radius) {
      velocity.y = -velocity.y;
      position.y = position.y.clamp(radius, gameRef.size.y - radius);
    }

    // Score on side misses
    if (position.x < 0) {
      gameRef.scoreRight++;
      resetBall();
    } else if (position.x > gameRef.size.x) {
      gameRef.scoreLeft++;
      resetBall();
    }
  }

  void resetBall() {
    position = Vector2(gameRef.size.x / 2, gameRef.size.y / 2);
    velocity = Vector2(
      rand.nextBool() ? 200 : -200,
      (rand.nextDouble() - 0.5) * 300,
    );
    hasCollidedThisFrame = false;
  }

  void bounce(Vector2 normal) {
    // Prevent double-bouncing in same frame
    if (hasCollidedThisFrame) return;
    hasCollidedThisFrame = true;
    
    // Reflect velocity
    final dot = velocity.dot(normal);
    velocity -= normal * (2 * dot);
    
    // Ensure minimum speed to prevent sticking
    if (velocity.x.abs() < 150) {
      velocity.x = velocity.x.sign * 200;
    }
    
    // Add vertical variation
    velocity += Vector2(0, (rand.nextDouble() - 0.5) * 50);
  }
}