import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

class Background extends PositionComponent with HasGameRef {
  late Sprite background;

  @override
  Future<void> onLoad() async {
    ui.Image background = await gameRef.images.load('background.jpg');
    this.background = Sprite(background);
    add(SpriteComponent(sprite: this.background, size: Vector2(gameRef.size.x * 2, gameRef.size.y), position: Vector2(-200, 0)));
  }
}


class FullHitBox extends PositionComponent with HasGameRef {
    Future<void> onLoad() async {
    final defaultPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke;
    add(RectangleHitbox(size: Vector2(gameRef.size.x, gameRef.size.y - 160), position: Vector2(0, 80))
      ..renderShape = true
      ..paint = defaultPaint
    );
  }
}

enum PlayerDirection {
  left,
  right,
  top,
  bottom,
  stand
}

class Player extends SpriteAnimationGroupComponent<PlayerDirection> with HasGameRef, CollisionCallbacks {
  final double _animationSpeed = 0.15;
  final double _playerSpeed = 300.0;
  List<PlayerDirection> _collisionDirectionList = [];

  late final SpriteAnimation _runDownAnimation;
  late final SpriteAnimation _runLeftAnimation;
  late final SpriteAnimation _runUpAnimation;
  late final SpriteAnimation _runRightAnimation;
  late final SpriteAnimation _standingAnimation;

  Player() : super(size: Vector2.all(42), current: PlayerDirection.stand) {
    add(RectangleHitbox());
  }
  
  @override
  Future<void> onLoad() async {
    await this._loadAnimations().then((_) => animations = {
      PlayerDirection.bottom: _runDownAnimation,
      PlayerDirection.left: _runLeftAnimation,
      PlayerDirection.right: _runRightAnimation,
      PlayerDirection.top: _runUpAnimation,
      PlayerDirection.stand: _standingAnimation
    });
  }

  Future<void> _loadAnimations() async {
    final spriteSheet = SpriteSheet(image: await gameRef.images.load("sprite_single.png"), srcSize: Vector2.all(32));
    _runDownAnimation = spriteSheet.createAnimation(row: 0, stepTime: _animationSpeed);
    _runLeftAnimation = spriteSheet.createAnimation(row: 1, stepTime: _animationSpeed);
    _runRightAnimation = spriteSheet.createAnimation(row: 2, stepTime: _animationSpeed);
    _runUpAnimation = spriteSheet.createAnimation(row: 3, stepTime: _animationSpeed);
    _standingAnimation = spriteSheet.createAnimation(row: 0, stepTime: _animationSpeed, from: 1, to: 2);
  }

  @override
  void update(double delta) {
    super.update(delta);
    movePlayer(delta);
  }

  void movePlayer(double delta) {
    switch (current!) {
      case PlayerDirection.bottom: {
        if (canPlayerMoveDown()) {
          moveDown(delta);
        }
        break;
      }
      case PlayerDirection.left:
        if (canPlayerMoveLeft()) {
          moveLeft(delta);
        }
        break;
      case PlayerDirection.right:
        if (canPlayerMoveRight()) {
          moveRight(delta);
        }
        break;
      case PlayerDirection.top:
        if (canPlayerMoveUp()) {
          moveUp(delta);
        }
        break;
      case PlayerDirection.stand:
        break;
    }
  }

  bool canPlayerMoveUp() {
    if (this._collisionDirectionList.contains(PlayerDirection.top)) return false;
    return true;
  }

  bool canPlayerMoveDown() {
    if (this._collisionDirectionList.contains(PlayerDirection.bottom)) return false;
    return true;
  }

  bool canPlayerMoveLeft() {
    if (this._collisionDirectionList.contains(PlayerDirection.left)) return false;
    return true;
  }

  bool canPlayerMoveRight() {
    if (this._collisionDirectionList.contains(PlayerDirection.right)) return false;
    return true;
  }

  void moveDown(double delta) {
    position.add(Vector2(0, delta * _playerSpeed));
  }

  void moveUp(double delta) {
    position.add(Vector2(0, delta * -_playerSpeed));
  }

  void moveLeft(double delta) {
    position.add(Vector2(delta * -_playerSpeed, 0));
  }

  void moveRight(double delta) {
    position.add(Vector2(delta * _playerSpeed, 0));
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (current! == PlayerDirection.stand) return;

    if (other is FullHitBox) {
      final screenSize = Vector2(gameRef.size.x, gameRef.size.y - 160);
      this._collisionDirectionList.clear();

      if (intersectionPoints.first.x == 0 || intersectionPoints.last.x == 0) {
        this._collisionDirectionList.add(PlayerDirection.left);
      }
      if (intersectionPoints.first.y == 80 || intersectionPoints.last.y == 80) {
        this._collisionDirectionList.add(PlayerDirection.top);
      }
      if (intersectionPoints.first.x == screenSize.x || intersectionPoints.last.x == screenSize.x) {
        this._collisionDirectionList.add(PlayerDirection.right);
      }
      if (intersectionPoints.first.y == screenSize.y + 80 || intersectionPoints.last.y == screenSize.y + 80) {
        this._collisionDirectionList.add(PlayerDirection.bottom);
      }
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    this._collisionDirectionList.clear();
  }
}


class WalkGame extends FlameGame with KeyboardEvents, HasCollisionDetection {

  final Player _player = Player();

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

  @override
  Future<void> onLoad() async {
    super.onLoad();
    _player.position = this.size / 2;
    add(Background());
    add(FullHitBox());
    add(_player);
    add(FpsTextComponent(position: Vector2.all(0)));
  }
}

class GameWrapper extends StatelessWidget {
  const GameWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: GameWidget(game: WalkGame()),
      ),
    );
  }
}


void main() {
  runApp(GameWrapper());
}