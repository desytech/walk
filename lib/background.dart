import 'package:flame/components.dart';
import 'dart:ui' as ui;

import 'package:walk/game.dart';

/**
 * Background
 * This class loads and renders the game background
 */
class Background extends PositionComponent with HasGameRef<WalkGame> {
  late Sprite background;

  @override
  Future<void> onLoad() async {
    ui.Image background = await gameRef.images.load('background.jpg');
    this.background = Sprite(background);
    add(SpriteComponent(sprite: this.background, size: Vector2(gameRef.size.x * 2, gameRef.size.y), position: Vector2(-200, 0)));
  }
}