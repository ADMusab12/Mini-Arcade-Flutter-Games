import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_game/BrickBreaker/brick_breaker_screen.dart';
import 'package:flutter_game/MemoryMatch/ui/memory_match_screen.dart';
import 'package:flutter_game/Pong/pong_game.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.blueGrey,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 2,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueGrey,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: const GameMenuScreen(),
    );
  }
}

class GameMenuScreen extends StatelessWidget {
  const GameMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Collection'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            GameCard(
              gameName: 'Pong',
              gameIcon: Icons.sports_tennis,
              color: Colors.blue[200]!,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PongGameScreen(),
                  ),
                );
              },
            ),
            GameCard(
              gameName: 'Memory Match',
              gameIcon: Icons.casino,
              color: Colors.green[200]!,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MemoryMatchScreen()),
                );
              },
            ),
            GameCard(
              gameName: 'Brick Breaker',
              gameIcon: Icons.games,
              color: Colors.orange[200]!,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BrickBreakerScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class GameCard extends StatelessWidget {
  final String gameName;
  final IconData gameIcon;
  final Color color;
  final VoidCallback onTap;

  const GameCard({
    super.key,
    required this.gameName,
    required this.gameIcon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              gameIcon,
              size: 64,
              color: Colors.black87,
            ),
            const SizedBox(height: 16),
            Text(
              gameName,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// PongGameScreen with overlay support
class PongGameScreen extends StatelessWidget {
  const PongGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget<PongGame>.controlled(
            gameFactory: PongGame.new,
            overlayBuilderMap: {
              'GameOver': (context, game) => GameOverOverlay(
                    game: game,
                    context: context,
                  ),
            },
          ),
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 32),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}

// GameOverOverlay widget
class GameOverOverlay extends StatelessWidget {
  final PongGame game;
  final BuildContext context;

  const GameOverOverlay({
    super.key,
    required this.game,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    final playerWon = game.scoreLeft >= 5;
    return Material(
      color: Colors.white70,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                playerWon ? 'YOU WIN!' : 'BOT WINS!',
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Final Score: ${game.scoreLeft} - ${game.scoreRight}',
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  game.reset();
                  game.overlays.remove('GameOver');
                },
                child: const Text(
                  'Restart Game',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Back to Menu',
                  style: TextStyle(color: Colors.black54, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}