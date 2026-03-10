import 'dart:async';
import 'dart:ui';
import 'package:flame/game.dart';
import 'cloud_layer.dart';
import 'player_component.dart';

class FitxelGame extends FlameGame {
  final void Function()? onCharacterTapped;

  FitxelGame({this.onCharacterTapped});

  @override
  Color backgroundColor() => const Color(0x00000000); // transparent

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();

    // Add cloud layers (back to front) with different scroll speeds
    final cloudPaths = [
      'Clouds/Clouds 1/1.png',
      'Clouds/Clouds 1/2.png',
      'Clouds/Clouds 1/3.png',
      'Clouds/Clouds 1/4.png',
    ];

    for (int i = 0; i < cloudPaths.length; i++) {
      final speed = 5.0 + (i * 8.0);
      add(
        CloudLayer(imagePath: cloudPaths[i], scrollSpeed: speed, priority: i),
      );
    }

    // Add the player character on top of clouds
    add(
      PlayerComponent(
        priority: cloudPaths.length,
        onTap: onCharacterTapped,
      ),
    );
  }
}
