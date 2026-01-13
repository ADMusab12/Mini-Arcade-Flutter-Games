import 'package:flutter/material.dart';
import 'package:flutter_game/BrickBreaker/particle.dart';

class BrickBreakerPainter extends CustomPainter {
   final double paddleX;
  final double paddleY;
  final double paddleWidth;
  final double paddleHeight;
  final double ballX;
  final double ballY;
  final double ballRadius;
  final List<List<bool>> bricks;
  final List<BrickParticle> particles;
  final Size size;

  const BrickBreakerPainter({
    required this.paddleX,
    required this.paddleY,
    required this.paddleWidth,
    required this.paddleHeight,
    required this.ballX,
    required this.ballY,
    required this.ballRadius,
    required this.bricks,
    required this.particles,
    required this.size,
  });

  static const double brickWidth = 40;
  static const double brickHeight = 20;
  static const int numRows = 5;
  static const int numCols = 10;
  static const double brickPadding = 2;
  static const double brickTopOffset = 200.0;

  @override
  void paint(Canvas canvas, Size canvasSize) {
    // Background gradient
    final gradient = LinearGradient(
      colors: [const Color(0xFF16213e), const Color(0xFF0f3460)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    final bg = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height), bg);

    // Draw bricks
    final brickPaint = Paint()..style = PaintingStyle.fill;

    for (int row = 0; row < numRows; row++) {
      for (int col = 0; col < numCols; col++) {
        if (!bricks[row][col]) continue;

        final x = col * (brickWidth + brickPadding);
        final y = row * (brickHeight + brickPadding) + brickTopOffset;

        brickPaint.color =
            Colors.primaries[row % Colors.primaries.length].withOpacity(0.85);

        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, brickWidth, brickHeight),
            const Radius.circular(6),
          ),
          brickPaint,
        );
      }
    }

    // Draw paddle
    final paddlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(paddleX, paddleY, paddleWidth, paddleHeight),
        const Radius.circular(6),
      ),
      paddlePaint,
    );

    // Ball glow
    final glowPaint = Paint()
      ..color = Colors.yellow.withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawCircle(Offset(ballX, ballY), ballRadius * 2, glowPaint);

    // Ball
    final ballPaint = Paint()..color = Colors.yellow;
    canvas.drawCircle(Offset(ballX, ballY), ballRadius, ballPaint);

    // Draw particles
    for (final p in particles) {
      final pp = Paint()
        ..color = Colors.orange.withOpacity(p.life)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(p.x, p.y), 2, pp);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}