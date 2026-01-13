import 'dart:math';
import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_game/MemoryMatch/components/card.dart';

class MemoryMatchGame extends FlameGame with TapCallbacks{
  static const int gridSize = 4; // 4x4 grid
  static const double cardSize = 80;
  static const double cardSpacing = 10;
  late Vector2 gridOffset; // Starting position of grid
  List<CardMemory> cards = [];
  List<String> icons = ['🍎', '🍌', '🍇', '🍓', '🍊', '🍋', '🥝', '🍍']; // 8 pairs
  int flips = 0;
  int matches = 0;
  CardMemory? firstFlipped;
  bool isProcessing = false;
  late TextComponent scoreText;
  late RectangleComponent winOverlay;
  late TextComponent winText;
  late TextComponent restartText;
  bool gameWon = false;

  @override
  Color backgroundColor() => const Color(0xFF2C3E50);

  @override
  Future<void> onLoad() async {
    // Calculate grid offset to center it
    final topPadding = 64.0;
    final gridWidth = gridSize * cardSize + (gridSize - 1) * cardSpacing;
    final gridHeight = gridSize * cardSize + (gridSize - 1) * cardSpacing;
    gridOffset = Vector2(
      (size.x - gridWidth) / 2,
      (size.y - gridHeight) / 2 +30 
    );

    // Score text
    scoreText = TextComponent(
      text: 'Flips: 0 | Matches: 0/8',
      position: Vector2(size.x / 2, topPadding),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    scoreText.priority = 5;
    add(scoreText);

    setupCards();

    // Win overlay (hidden initially)
    winOverlay = RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.black.withOpacity(0),
      position: Vector2.zero(),
    );
    winOverlay.priority = 10;
    add(winOverlay);

    winText = TextComponent(
      text: '🎉 You Win! 🎉',
      position: size / 2 - Vector2(0, 50),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.yellow.withOpacity(0),
          fontSize: 48,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    winText.priority = 11;
    add(winText);

    restartText = TextComponent(
      text: 'Tap to Restart',
      position: size / 2 + Vector2(0, 30),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.white.withOpacity(0),
          fontSize: 24,
        ),
      ),
    );
    restartText.priority = 11;
    add(restartText);
  }

  void setupCards() {
    // Clear existing cards
    for (var card in cards) {
      card.removeFromParent();
    }
    cards.clear();

    final allIcons = [...icons, ...icons]; // Duplicate for pairs
    allIcons.shuffle(Random());

    for (int i = 0; i < gridSize * gridSize; i++) {
      final row = i ~/ gridSize;
      final col = i % gridSize;
      final pos = Vector2(
        gridOffset.x + col * (cardSize + cardSpacing),
        gridOffset.y + row * (cardSize + cardSpacing),
      );
      final card = CardMemory(
        position: pos,
        icon: allIcons[i],
        size: Vector2.all(cardSize),
      );
      cards.add(card);
      add(card);
    }
  }

  void handleFlip(CardMemory card) {
    if (isProcessing || card.isMatched || card.isFlipped || gameWon) return;

    flips++;
    updateScore();

    card.flip();

    if (firstFlipped == null) {
      firstFlipped = card;
    } else if (firstFlipped != card) {
      if (firstFlipped!.icon == card.icon) {
        // Match found!
        firstFlipped!.match();
        card.match();
        matches++;
        updateScore();
        firstFlipped = null;
        // Check for win
        if (matches == icons.length) {
          Future.delayed(const Duration(milliseconds: 500), showWinScreen);
        }
      } else {
        // No match - flip back after delay
        isProcessing = true;
        final first = firstFlipped;
        firstFlipped = null;
        Future.delayed(const Duration(milliseconds: 800), () {
          first?.unflip();
          card.unflip();
          isProcessing = false;
        });
      }
    }
  }

  void updateScore() {
    scoreText.text = 'Flips: $flips | Matches: $matches/8';
  }

  void showWinScreen() {
    gameWon = true;
    winOverlay.paint = Paint()..color = Colors.black.withOpacity(0.8);
    winText.text = '🎉 You Win! 🎉\nFlips: $flips';
    winText.textRenderer = TextPaint(
      style: const TextStyle(
        color: Colors.yellow,
        fontSize: 48,
        fontWeight: FontWeight.bold,
      ),
    );
    restartText.textRenderer = TextPaint(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 24,
      ),
    );
  }

  void reset() {
    // Clear all cards
    for (var card in cards) {
      card.removeFromParent();
    }
    cards.clear();

    // Reset state
    flips = 0;
    matches = 0;
    firstFlipped = null;
    isProcessing = false;
    gameWon = false;

    // Hide win screen
    winOverlay.paint = Paint()..color = Colors.black.withOpacity(0);
    winText.text = '🎉 You Win! 🎉';
    winText.textRenderer = TextPaint(
      style: TextStyle(
        color: Colors.yellow.withOpacity(0),
        fontSize: 48,
        fontWeight: FontWeight.bold,
      ),
    );
    restartText.textRenderer = TextPaint(
      style: TextStyle(
        color: Colors.white.withOpacity(0),
        fontSize: 24,
      ),
    );

    // Setup new game
    setupCards();
    updateScore();
  }

  @override 
  void onTapDown(TapDownEvent info) {  
    if (gameWon) {
      reset();
    }
  }
}