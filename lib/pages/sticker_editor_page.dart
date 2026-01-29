import 'package:flutter/material.dart';
import '../models/sticker_element.dart';

class StickerEditorPage extends StatefulWidget {
  @override
  _StickerEditorPageState createState() => _StickerEditorPageState();
}

class _StickerEditorPageState extends State<StickerEditorPage> {
  List<StickerElement> elements = [];
  Color selectedColor = Colors.red;
  double selectedStrokeWidth = 3.0;
  String selectedShape = 'rectangle';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Éditeur d\'autocollants'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline),
            onPressed: elements.isEmpty ? null : () {
              setState(() => elements.clear());
            },
            tooltip: 'Tout effacer',
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre d'outils
          Container(
            padding: EdgeInsets.all(8),
            color: Colors.grey[200],
            child: Column(
              children: [
                Row(
                  children: [
                    Text('Forme: '),
                    SizedBox(width: 8),
                    DropdownButton<String>(
                      value: selectedShape,
                      items: [
                        DropdownMenuItem(value: 'rectangle', child: Text('Rectangle')),
                        DropdownMenuItem(value: 'circle', child: Text('Cercle')),
                      ],
                      onChanged: (value) => setState(() => selectedShape = value!),
                    ),
                    SizedBox(width: 16),
                    Text('Couleur: '),
                    SizedBox(width: 8),
                    ...['red', 'blue', 'green', 'black', 'orange'].map((color) {
                      final colorValue = _getColor(color);
                      return GestureDetector(
                        onTap: () => setState(() => selectedColor = colorValue),
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 4),
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: colorValue,
                            border: Border.all(
                              color: selectedColor == colorValue ? Colors.white : Colors.grey,
                              width: selectedColor == colorValue ? 3 : 1,
                            ),
                            boxShadow: selectedColor == colorValue ? [
                              BoxShadow(color: Colors.black26, blurRadius: 4)
                            ] : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Text('Épaisseur: ${selectedStrokeWidth.toInt()}px'),
                    Expanded(
                      child: Slider(
                        value: selectedStrokeWidth,
                        min: 1,
                        max: 10,
                        divisions: 9,
                        onChanged: (value) => setState(() => selectedStrokeWidth = value),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Canvas
          Expanded(
            child: GestureDetector(
              onTapDown: (details) {
                setState(() {
                  elements.add(ShapeElement(
                    position: details.localPosition,
                    color: selectedColor,
                    strokeWidth: selectedStrokeWidth,
                    shapeType: selectedShape,
                  ));
                });
              },
              child: Container(
                color: Colors.white,
                child: CustomPaint(
                  painter: StickerCanvasPainter(elements),
                  child: Container(),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'text',
            mini: true,
            onPressed: () => _addTextElement(),
            child: Icon(Icons.text_fields),
            tooltip: 'Ajouter texte',
          ),
          SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'export',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Export PNG - À implémenter')),
              );
            },
            child: Icon(Icons.save),
            tooltip: 'Exporter PNG',
          ),
        ],
      ),
    );
  }

  Color _getColor(String name) {
    switch (name) {
      case 'red': return Colors.red;
      case 'blue': return Colors.blue;
      case 'green': return Colors.green;
      case 'black': return Colors.black;
      case 'orange': return Colors.orange;
      default: return Colors.black;
    }
  }

  void _addTextElement() {
    showDialog(
      context: context,
      builder: (context) {
        String text = '';
        return AlertDialog(
          title: Text('Ajouter du texte'),
          content: TextField(
            autofocus: true,
            decoration: InputDecoration(hintText: 'Entrez votre texte'),
            onChanged: (value) => text = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                if (text.isNotEmpty) {
                  setState(() {
                    elements.add(TextElement(
                      position: Offset(100, 100),
                      text: text,
                      color: selectedColor,
                    ));
                  });
                }
                Navigator.pop(context);
              },
              child: Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }
}

class StickerCanvasPainter extends CustomPainter {
  final List<StickerElement> elements;
  StickerCanvasPainter(this.elements);

  @override
  void paint(Canvas canvas, Size size) {
    for (var e in elements) {
      e.draw(canvas);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
