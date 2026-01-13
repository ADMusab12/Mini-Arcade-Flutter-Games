import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart'; 
import 'package:flame/text.dart';  
import 'package:flutter/material.dart';
import 'package:flutter_game/Pong/components/ball.dart';
import 'package:flutter_game/Pong/components/paddle.dart';

class PongGame extends FlameGame with PanDetector{
  int scoreLeft = 0;
  int scoreRight = 0;
  TextComponent? scoreText;

  late Paddle playerPaddle;
  late Paddle aiPaddle;
  late Ball ball;
  
  bool isDragging = false;
  bool isGameOver = false;  

  @override
  Color backgroundColor() => const Color(0xFF000000);

  @override
  Future<void> onLoad() async {
    // Player paddle (left)
    playerPaddle = Paddle(isPlayer: true);
    playerPaddle.position = Vector2(50, size.y / 2 - 40);
    add(playerPaddle);

    // AI paddle (right)
    aiPaddle = Paddle(isPlayer: false);
    aiPaddle.position = Vector2(size.x - 60, size.y / 2 - 40);
    add(aiPaddle);

    // Ball
    ball = Ball();
    add(ball);

    scoreText = TextComponent(
      text: '0 - 0',
      position: Vector2(size.x / 2 - 40, 20),
      textRenderer: TextPaint(
        style: const TextStyle(color: Colors.white, fontSize: 32),
      ),
    );
    add(scoreText!);
  }

  @override
  void onPanStart(DragStartInfo info) {
    // Ignore input during game over (overlay handles restart)
    if (isGameOver) return;
    
    final touchX = info.eventPosition.global.x;
    // Only drag if touching left half of screen (player side)
    if (touchX < size.x / 2) {
      isDragging = true;
    }
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    if (isDragging && !isGameOver) {
      final touchY = info.eventPosition.global.y;
      playerPaddle.position.y = (touchY - 40).clamp(0.0, size.y - 80);
    }
  }

  @override
  void onPanEnd(DragEndInfo info) {
    isDragging = false;
  }

  @override
  void onPanCancel() {
    isDragging = false;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Skip updates if game over
    if (isGameOver) return;

    // AI Follow ball Y with slight delay for difficulty
    final targetY = ball.position.y - 40;
    if (aiPaddle.position.y < targetY - 10) {
      aiPaddle.moveDown(dt);
    } else if (aiPaddle.position.y > targetY + 10) {
      aiPaddle.moveUp(dt);
    }

    // Check if ball is moving towards player paddle
    final movingTowardsPlayer = ball.velocity.x < 0;
    // Player-paddle collision
    if (movingTowardsPlayer && ball.toRect().overlaps(playerPaddle.toRect())) {
      ball.bounce(Vector2(1, 0));
      // Push ball outside paddle immediately
      ball.position.x = playerPaddle.x + 10 + ball.radius + 2;
    }

    // Check if ball is moving towards AI paddle
    final movingTowardsAI = ball.velocity.x > 0;
    // AI-paddle collision
    if (movingTowardsAI && ball.toRect().overlaps(aiPaddle.toRect())) {
      ball.bounce(Vector2(-1, 0));
      // Push ball outside paddle immediately
      ball.position.x = aiPaddle.x - ball.radius - 2;
    }

    if (scoreText != null) {
      scoreText!.text = '$scoreLeft - $scoreRight';
    }

    // Game over at 3 points
    if (scoreLeft >= 3 || scoreRight >= 3) {
      endGame(scoreLeft >= 3);  // Renamed from showGameOver
    }
  }

  // Use overlay instead of components
  void endGame(bool playerWon) {
    isGameOver = true;
    pauseEngine();
    overlays.add('GameOver');  // Triggers Flutter overlay
  }

  // Public reset method for overlay button
  void reset() {
    // Reset scores and state
    scoreLeft = 0;
    scoreRight = 0;
    isGameOver = false;

    // Reset ball
    ball.resetBall();

    // Reset paddle positions
    playerPaddle.position = Vector2(50, size.y / 2 - 40);
    aiPaddle.position = Vector2(size.x - 60, size.y / 2 - 40);

    // Resume game
    resumeEngine();
    overlays.remove('GameOver');  // Called from button, but safe here too
  }
}