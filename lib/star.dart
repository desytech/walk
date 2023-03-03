import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:walk/game.dart';

/**
 * Star
 * This component manage the star image
 */
class Star extends SpriteComponent with HasGameRef<WalkGame>, CollisionCallbacks {
  Star({ required position }) : super(size: Vector2.all(32), position: position) {
    add(RectangleHitbox());
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    sprite = Sprite(gameRef.images.fromCache("star.png"));
  }
}