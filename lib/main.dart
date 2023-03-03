import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'package:walk/game.dart';

/**
 * GameWrapper
 * We wrap our game into a material app
 */
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