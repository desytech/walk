import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:walk/background.dart';
import 'package:walk/counter.dart';
import 'package:walk/player.dart';
import 'package:walk/star.dart';

/**
 * FullHitBox
 * This class defines the map boundaries, we can also use ScreenHitbox
 */
class FullHitBox extends PositionComponent with HasGameRef<WalkGame> {
  Future<void> onLoad() async {
    add(RectangleHitbox(size: Vector2(gameRef.size.x, gameRef.size.y - gameRef.gameBorders * 2), position: Vector2(0, gameRef.gameBorders)));
  }
}

/**
 * WalkGame
 * This class is the entrypoint of flutter flame, contains keyboard events
 */
class WalkGame extends FlameGame with KeyboardEvents, HasCollisionDetection {

  late final Player _player;
  final Counter counter = Counter();
  final Random _random = Random();
  final double gameBorders = 80;

  @override
  KeyEventResult onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    final isKeyDown = event is RawKeyDownEvent;
    PlayerDirection? playerDirection = null;

    if (event.logicalKey == LogicalKeyboardKey.keyW) {
      playerDirection = PlayerDirection.top;
    }

    if (event.logicalKey == LogicalKeyboardKey.keyA) {
      playerDirection = PlayerDirection.left;
    }

    if (event.logicalKey == LogicalKeyboardKey.keyS) {
      playerDirection = PlayerDirection.bottom;
    }

    if (event.logicalKey == LogicalKeyboardKey.keyD) {
      playerDirection = PlayerDirection.right;
    }

    if (isKeyDown && playerDirection != null) {
      _player.current = playerDirection;
    } else {
      _player.current = PlayerDirection.stand;
    }

    return super.onKeyEvent(event, keysPressed);
  }

  double next(double min, double max) => (min + _random.nextInt(max.toInt() - min.toInt())).toDouble();

  void addRandomDiamond() {
    add(Star(position: Vector2(next(0, (this.size.x - Star.starSize)), next(this.gameBorders, this.size.y - Star.starSize - this.gameBorders))));
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();

    await images.load('star.png');

    this._player = Player();
    this._player.position = this.size / 2;

    add(Background());
    add(FullHitBox());
    add(this.counter);
    add(this._player);
    addRandomDiamond();
    add(FpsTextComponent(position: Vector2.all(0)));
  }
}