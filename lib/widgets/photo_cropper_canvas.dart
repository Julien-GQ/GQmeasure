import 'package:flutter/material.dart';
import 'dart:ui' as ui;

/// Widget Canvas pour le découpage de photos
/// Permet de sélectionner un polygone autour d'un objet
class PhotoCropperCanvas extends StatefulWidget {
  final ui.Image? image;
  final List<Offset> points;
  final Function(Offset) onPointAdded;
  final Function() onPointsCleared;
  final Function(int, Offset) onPointMoved;

  const PhotoCropperCanvas({
    Key? key,
    this.image,
    required this.points,
    required this.onPointAdded,
    required this.onPointsCleared,
    required this.onPointMoved,
  }) : super(key: key);

  @override
  State<PhotoCropperCanvas> createState() => _PhotoCropperCanvasState();
}

class _PhotoCropperCanvasState extends State<PhotoCropperCanvas> {
  int? _selectedPointIndex;
  final double _pointRadius = 15.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      child: CustomPaint(
        painter: _PhotoCropperPainter(
          image: widget.image,
          points: widget.points,
          selectedPointIndex: _selectedPointIndex,
        ),
        child: Container(),
      ),
    );
  }

  void _handleTapDown(TapDownDetails details) {
    final tapPosition = details.localPosition;

    // Vérifier si on a tapé sur un point existant
    for (int i = 0; i < widget.points.length; i++) {
      if ((widget.points[i] - tapPosition).distance < _pointRadius) {
        setState(() => _selectedPointIndex = i);
        return;
      }
    }

    // Sinon, ajouter un nouveau point
    widget.onPointAdded(tapPosition);
    setState(() {});
  }

  void _handlePanStart(DragStartDetails details) {
    final panPosition = details.localPosition;

    // Chercher le point le plus proche
    for (int i = 0; i < widget.points.length; i++) {
      if ((widget.points[i] - panPosition).distance < _pointRadius) {
        setState(() => _selectedPointIndex = i);
        return;
      }
    }
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (_selectedPointIndex == null) return;

    widget.onPointMoved(_selectedPointIndex!, details.localPosition);
    setState(() {});
  }

  void _handlePanEnd(DragEndDetails details) {
    setState(() => _selectedPointIndex = null);
  }
}

/// CustomPainter pour dessiner l'image et le polygone de découpage
class _PhotoCropperPainter extends CustomPainter {
  final ui.Image? image;
  final List<Offset> points;
  final int? selectedPointIndex;

  _PhotoCropperPainter({
    this.image,
    required this.points,
    this.selectedPointIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Dessiner l'image de fond si disponible
    if (image != null) {
      final srcRect = Rect.fromLTWH(0, 0, image!.width.toDouble(), image!.height.toDouble());
      final dstRect = Rect.fromLTWH(0, 0, size.width, size.height);
      canvas.drawImageRect(image!, srcRect, dstRect, Paint());
    }

    // Dessiner le polygone si au moins 2 points
    if (points.length > 1) {
      final polygonPaint = Paint()
        ..color = Colors.red.withOpacity(0.5)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;

      final path = Path()..moveTo(points[0].dx, points[0].dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      
      // Fermer le polygone si au moins 3 points
      if (points.length > 2) {
        path.close();
      }

      canvas.drawPath(path, polygonPaint);

      // Remplir le polygone avec une couleur semi-transparente
      if (points.length > 2) {
        final fillPaint = Paint()
          ..color = Colors.red.withOpacity(0.2)
          ..style = PaintingStyle.fill;
        canvas.drawPath(path, fillPaint);
      }
    }

    // Dessiner les points
    for (int i = 0; i < points.length; i++) {
      final isSelected = i == selectedPointIndex;
      final pointPaint = Paint()
        ..color = isSelected ? Colors.blue : Colors.red
        ..style = PaintingStyle.fill;

      canvas.drawCircle(points[i], isSelected ? 18 : 15, pointPaint);

      // Bordure blanche pour la visibilité
      final borderPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(points[i], isSelected ? 18 : 15, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PhotoCropperPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.image != image ||
        oldDelegate.selectedPointIndex != selectedPointIndex;
  }
}
