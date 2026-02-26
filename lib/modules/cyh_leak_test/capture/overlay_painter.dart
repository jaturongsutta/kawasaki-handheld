import 'package:flutter/material.dart';
import 'package:kmt/modules/cyh_leak_test/capture/constants.dart';

class OverlayPainter extends CustomPainter {
  final String detectedText;
  final Rect cropLogicalRect;

  OverlayPainter({
    required this.detectedText,
    required this.cropLogicalRect,
  });

  final Paint _rectPaint = Paint()
    ..color = Colors.red.withOpacity(0.9)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;

  final Paint _maskPaint = Paint()..color = Colors.black.withOpacity(0.65);

  final TextPainter _tp = TextPainter(textDirection: TextDirection.ltr);

  @override
  void paint(Canvas canvas, Size size) {
    final wRatio = size.width / SCREEN_WIDTH;
    final hRatio = size.height / SCREEN_HEIGHT;

    final rect = Rect.fromLTWH(
      cropLogicalRect.left * wRatio,
      cropLogicalRect.top * hRatio,
      cropLogicalRect.width * wRatio,
      cropLogicalRect.height * hRatio,
    );

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, rect.top), _maskPaint);
    canvas.drawRect(
      Rect.fromLTWH(0, rect.top, rect.left, rect.height),
      _maskPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(rect.right, rect.top, size.width - rect.right, rect.height),
      _maskPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, rect.bottom, size.width, size.height - rect.bottom),
      _maskPaint,
    );

    canvas.drawRect(rect, _rectPaint);

    final textOffset = Offset(20 * wRatio, 100 * hRatio);
    _tp.text = TextSpan(
      style: const TextStyle(color: Colors.red, fontSize: 16),
      text: detectedText,
    );
    _tp.layout(maxWidth: size.width - textOffset.dx - 16);
    _tp.paint(canvas, textOffset);
  }

  @override
  bool shouldRepaint(covariant OverlayPainter oldDelegate) {
    return oldDelegate.detectedText != detectedText ||
        oldDelegate.cropLogicalRect != cropLogicalRect;
  }
}
