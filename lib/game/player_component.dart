import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';

class PlayerComponent extends SpriteAnimationComponent
    with HasGameReference<FlameGame> {
  PlayerComponent({super.priority});

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();

    final image = await game.images.load(
      'Character/16x32/16x32 Idle-Sheet.png',
    );

    const frameWidth = 16.0;
    const frameHeight = 32.0;
    const idleFrameCount = 4;

    final spriteSheet = SpriteSheet(
      image: image,
      srcSize: Vector2(frameWidth, frameHeight),
    );

    final frames = <SpriteAnimationFrame>[];
    for (int c = 0; c < idleFrameCount; c++) {
      frames.add(
        SpriteAnimationFrame(
          spriteSheet.getSprite(0, c),
          0.15,
        ),
      );
    }

    animation = SpriteAnimation(frames);

    // Scale up the pixel art character (6x)
    const scaleFactor = 6.0;
    size = Vector2(frameWidth * scaleFactor, frameHeight * scaleFactor);

    // Center on screen
    anchor = Anchor.center;
    position = Vector2(game.size.x / 2, game.size.y / 2);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    // Re-center when screen resizes
    position = Vector2(size.x / 2, size.y / 2);
  }
}
