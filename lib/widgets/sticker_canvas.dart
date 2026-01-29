import 'package:flutter/material.dart';
import '../models/sticker_element.dart';

/// Widget Canvas pour l'éditeur d'autocollants
/// Gère le dessin et les interactions avec les éléments
class StickerCanvas extends StatefulWidget {
  final List<StickerElement> elements;
  final Function(StickerElement) onElementAdded;
  final Function(StickerElement) onElementRemoved;
  final Function(int, StickerElement) onElementUpdated;

  const StickerCanvas({
    Key? key,
    required this.elements,
    required this.onElementAdded,
    required this.onElementRemoved,
    required this.onElementUpdated,
  }) : super(key: key);

  @override
  State<StickerCanvas> createState() => _StickerCanvasState();
}

class _StickerCanvasState extends State<StickerCanvas> {
  int? _selectedElementIndex;
  Offset? _dragStartOffset;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      child: CustomPaint(
        painter: _StickerCanvasPainter(
          widget.elements,
          selectedIndex: _selectedElementIndex,
        ),
        child: Container(),
      ),
    );
  }

  void _handleTapDown(TapDownDetails details) {
    // Vérifier si on a cliqué sur un élément existant
    for (int i = widget.elements.length - 1; i >= 0; i--) {
      // TODO: Implémenter la détection de collision avec l'élément
      // Pour l'instant, simple détection par proximité du centre
    }
  }

  void _handlePanStart(DragStartDetails details) {
    _dragStartOffset = details.localPosition;
    
    // Chercher l'élément sous le point de départ
    // TODO: Implémenter la sélection d'élément
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (_selectedElementIndex == null || _dragStartOffset == null) return;

    // Déplacer l'élément sélectionné
    _dragStartOffset = details.localPosition;

    // TODO: Mettre à jour la position de l'élément
    setState(() {});
  }

  void _handlePanEnd(DragEndDetails details) {
    // Terminer le déplacement
    _dragStartOffset = null;
  }
}

/// CustomPainter pour dessiner les autocollants
class _StickerCanvasPainter extends CustomPainter {
  final List<StickerElement> elements;
  final int? selectedIndex;

  _StickerCanvasPainter(this.elements, {this.selectedIndex});

  @override
  void paint(Canvas canvas, Size size) {
    // Dessiner tous les éléments
    for (int i = 0; i < elements.length; i++) {
      elements[i].draw(canvas);

      // Dessiner une bordure de sélection si l'élément est sélectionné
      if (i == selectedIndex) {
        _drawSelectionBorder(canvas, elements[i]);
      }
    }
  }

  void _drawSelectionBorder(Canvas canvas, StickerElement element) {
    // TODO: Dessiner la bordure de sélection selon le type d'élément
    // Exemple simple
    canvas.drawRect(
      Rect.fromLTWH(0, 0, 50, 50),
      Paint()
        ..color = Colors.blue
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _StickerCanvasPainter oldDelegate) {
    return oldDelegate.elements != elements || oldDelegate.selectedIndex != selectedIndex;
  }
}
