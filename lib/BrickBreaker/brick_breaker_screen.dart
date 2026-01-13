import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_game/BrickBreaker/brick_breaker_painter.dart';
import 'package:flutter_game/BrickBreaker/particle.dart';

class BrickBreakerScreen extends StatefulWidget {
  const BrickBreakerScreen({super.key});

  @override
  State<BrickBreakerScreen> createState() => _BrickBreakerScreenState();
}

class _BrickBreakerScreenState extends State<BrickBreakerScreen> with SingleTickerProviderStateMixin{
  late AnimationController _controller;
  double paddleX = 0;
  double paddleY = 0;
  double ballX = 0;
  double ballY = 0;
  double ballVX = 2.0;
  double ballVY = 0.0;
  int score = 0;
  int lives = 3;
  bool gameOver = false;
  bool gameWon = false;
  bool ballAttached = true;

  List<List<bool>> bricks = [];
  List<BrickParticle> particles = [];

  // Constants
  static const double paddleWidth = 80;
  static const double paddleHeight = 10;
  static const double ballRadius = 6;
  static const double brickWidth = 40;
  static const double brickHeight = 20;
  static const int numRows = 5;
  static const int numCols = 10;
  static const double brickPadding = 2;
  static const double brickTopOffset = 200.0;

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 16),
      vsync: this,
    )..addListener(_updateGame);

    _controller.repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _resetGame();
    }
  }

  void _resetGame() {
    final size = MediaQuery.of(context).size;

    paddleY = size.height * 0.85;
    paddleX = (size.width - paddleWidth) / 2;

    ballX = paddleX + paddleWidth / 2 - ballRadius;
    ballY = paddleY - paddleHeight - ballRadius;

    score = 0;
    lives = 3;
    gameOver = false;
    gameWon = false;
    ballAttached = true;
    ballVX = 0.0;
    ballVY = 0.0;
    particles.clear();

    bricks =
        List.generate(numRows, (r) => List.generate(numCols, (c) => true));

    setState(() {});
  }

  void _updateGame() {
    if (gameOver || gameWon || !mounted) return;

    final size = MediaQuery.of(context).size;
    final dt = 1 / 60.0;

    // Ball attached → stick to paddle
    if (ballAttached) {
      ballX = paddleX + paddleWidth / 2 - ballRadius;
      ballY = paddleY - paddleHeight - ballRadius;
      setState(() {});
      return;
    }

    // Move ball
    ballX += ballVX * dt * 160;
    ballY += ballVY * dt * 160;

    // Wall collisions
    if (ballX <= ballRadius || ballX >= size.width - ballRadius) {
      ballVX = -ballVX;
      ballX = ballX.clamp(ballRadius, size.width - ballRadius);
    }
    if (ballY <= ballRadius) {
      ballVY = -ballVY;
      ballY = ballRadius;
    }

    // Bottom collision
    if (ballY >= size.height - ballRadius) {
      lives--;
      if (lives <= 0) {
        gameOver = true;
        ballVX = 0;
        ballVY = 0;
      } else {
        ballAttached = true;
        ballVY = 0.0;
      }
      setState(() {});
      return;
    }

    // Paddle collision
    if (ballY + ballRadius >= paddleY - paddleHeight &&
        ballY - ballRadius <= paddleY &&
        ballX + ballRadius >= paddleX &&
        ballX - ballRadius <= paddleX + paddleWidth) {
      final hitPos = (ballX - paddleX) / paddleWidth;
      ballVX = (hitPos - 0.5) * 4;
      ballVY = -ballVY.abs();
      ballY = paddleY - paddleHeight - ballRadius;
    }

    // Brick collisions
    for (int r = 0; r < numRows; r++) {
      for (int c = 0; c < numCols; c++) {
        if (!bricks[r][c]) continue;

        final left = c * (brickWidth + brickPadding);
        final top = r * (brickHeight + brickPadding) + brickTopOffset;
        final right = left + brickWidth;
        final bottom = top + brickHeight;

        if (ballX + ballRadius >= left &&
            ballX - ballRadius <= right &&
            ballY + ballRadius >= top &&
            ballY - ballRadius <= bottom) {
          bricks[r][c] = false;
          score += 10;

          // Particles
          for (int i = 0; i < 5; i++) {
            particles.add(BrickParticle(
              x: ballX,
              y: ballY,
              vx: (Random().nextDouble() - 0.5) * 4,
              vy: (Random().nextDouble() - 0.5) * 4,
              life: 1.0,
            ));
          }

          // Bounce direction
          final overlapLeft = (ballX + ballRadius) - left;
          final overlapRight = right - (ballX - ballRadius);
          final overlapTop = (ballY + ballRadius) - top;
          final overlapBottom = bottom - (ballY - ballRadius);

          final minOverlap = min(
              min(overlapLeft, overlapRight), min(overlapTop, overlapBottom));

          if (minOverlap == overlapLeft || minOverlap == overlapRight) {
            ballVX = -ballVX;
          } else {
            ballVY = -ballVY;
          }
        }
      }
    }

    // Check win after all bricks
    if (!bricks.any((row) => row.any((b) => b))) {
      gameWon = true;
      ballVX = 0;
      ballVY = 0;
      ballAttached = true;
    }

    // Update particles
    particles.removeWhere((p) {
      p.update(dt);
      return p.life <= 0;
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      body: Stack(
        children: [
          CustomPaint(
            size: size,
            painter: BrickBreakerPainter(
              paddleX: paddleX,
              paddleY: paddleY,
              paddleWidth: paddleWidth,
              paddleHeight: paddleHeight,
              ballX: ballX,
              ballY: ballY,
              ballRadius: ballRadius,
              bricks: bricks,
              particles: particles,
              size: size,
            ),
          ),

          // Score & Lives
          Positioned(
            top: 60,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Score: $score',
                    style: const TextStyle(color: Colors.white, fontSize: 20)),
                Text('Lives: $lives',
                    style: const TextStyle(color: Colors.white, fontSize: 20)),
              ],
            ),
          ),

          // Game Over / Win Overlay
          if (gameOver || gameWon)
            Center(
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(16)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      gameWon ? "YOU WIN!" : "GAME OVER!",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      gameWon
                          ? "All bricks destroyed!"
                          : "Final Score: $score",
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 22),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: _resetGame,
                      child: const Text("Restart Game"),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Back to Main Menu",
                        style: TextStyle(color: Colors.white70, fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Paddle controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                setState(() {
                  paddleX += details.delta.dx;
                  paddleX = paddleX.clamp(0.0, size.width - paddleWidth);
                });
              },
              onTap: () {
                if (ballAttached && !gameOver && !gameWon) {
                  setState(() {
                    ballAttached = false;
                    ballVY = -3.0;
                  });
                }
              },
              child: Container(
                height: 150,
                color: Colors.transparent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}