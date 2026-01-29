import 'package:flutter/material.dart';

abstract class StickerElement {
  void draw(Canvas canvas);
}

class ShapeElement extends StickerElement {
  Offset position;
  Color color;
  double strokeWidth;
  String shapeType; // rectangle, circle, etc.

  ShapeElement({required this.position, this.color = Colors.black, this.strokeWidth = 2, required this.shapeType});

  @override
  void draw(Canvas canvas) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    switch (shapeType) {
      case 'rectangle':
        canvas.drawRect(Rect.fromCenter(center: position, width: 100, height: 50), paint);
        break;
      case 'circle':
        canvas.drawCircle(position, 50, paint);
        break;
    }
  }
}

class ArrowElement extends StickerElement {
  Offset start;
  Offset end;
  Color color;
  double strokeWidth;
  bool doubleArrow;

  ArrowElement({required this.start, required this.end, this.color = Colors.black, this.strokeWidth = 2, this.doubleArrow = false});

  @override
  void draw(Canvas canvas) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    canvas.drawLine(start, end, paint);
    // TODO: ajouter tête de flèche et option double
  }
}

class TextElement extends StickerElement {
  Offset position;
  String text;
  Color color;

  TextElement({required this.position, required this.text, this.color = Colors.black});

  @override
  void draw(Canvas canvas) {
    final tp = TextPainter(
        text: TextSpan(text: text, style: TextStyle(color: color, fontSize: 16)),
        textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, position);
  }
}
