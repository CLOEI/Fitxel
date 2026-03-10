import 'dart:async';
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flame/game.dart';

/// A horizontally scrolling cloud layer that tiles seamlessly.
class CloudLayer extends PositionComponent with HasGameReference<FlameGame> {
  final String imagePath;
  final double scrollSpeed;
  double _scrollOffset = 0;

  late ui.Image _image;

  CloudLayer({
    required this.imagePath,
    required this.scrollSpeed,
    super.priority,
  });

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();
    _image = await game.images.load(imagePath);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _scrollOffset += scrollSpeed * dt;

    // wrap around to prevent float overflow
    final imageWidth =
        _image.width.toDouble() * (game.size.y / _image.height.toDouble());
    if (imageWidth > 0) {
      _scrollOffset %= imageWidth;
    }
  }

  @override
  void render(ui.Canvas canvas) {
    super.render(canvas);

    final screenW = game.size.x;
    final screenH = game.size.y;
    final imgW = _image.width.toDouble();
    final imgH = _image.height.toDouble();

    // Scale image to fill screen height
    final scale = screenH / imgH;
    final scaledW = imgW * scale;

    // Draw tiled images to cover screen width
    double x = -(_scrollOffset % scaledW);
    while (x < screenW) {
      canvas.drawImageRect(
        _image,
        ui.Rect.fromLTWH(0, 0, imgW, imgH),
        ui.Rect.fromLTWH(x, 0, scaledW, screenH),
        ui.Paint(),
      );
      x += scaledW;
    }
  }
}
