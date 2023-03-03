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
    add(RectangleHitbox(size: Vector2(gameRef.size.x, gameRef.size.y - 160), position: Vector2(0, 80)));
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

  double next(int min, int max) => (min + _random.nextInt(max - min)).toDouble();

  void addRandomDiamond() {
    add(Star(position: Vector2(next(0, (this.size.x.toInt() - 64)), next(80, this.size.y.toInt() - 64 - 80))));
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    this._player = Player();
    await images.load('star.png');
    _player.position = this.size / 2;
    add(Background());
    add(FullHitBox());
    add(this.counter);
    add(_player);
    addRandomDiamond();
    add(FpsTextComponent(position: Vector2.all(0)));
  }
}