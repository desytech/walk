import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:walk/game.dart';

/**
 * Counter
 * This class contains all counter arithmetic
 */
class Counter extends PositionComponent with HasGameRef<WalkGame> {
  ValueNotifier<int> score = ValueNotifier(0);
  TextComponent counter = TextComponent()..position = Vector2(30, 0);

  Counter() : super(position: Vector2(120, 0));

  void increaseScore() {
    score.value++;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    add(SpriteComponent.fromImage(gameRef.images.fromCache("star.png"))..size = Vector2.all(24));
    add(this.counter);
  }

  @override
  void update(double delta) {
    this.counter.text = "${this.score.value}";
  }
}