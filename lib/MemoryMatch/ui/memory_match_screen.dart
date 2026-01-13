
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_game/MemoryMatch/components/memory_match_game.dart';

class MemoryMatchScreen extends StatelessWidget {
  const MemoryMatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget<MemoryMatchGame>.controlled(
            gameFactory: MemoryMatchGame.new,
          ),
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 32),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}