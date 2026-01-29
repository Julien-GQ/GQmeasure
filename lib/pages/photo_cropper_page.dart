import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class PhotoCropperPage extends StatefulWidget {
  @override
  _PhotoCropperPageState createState() => _PhotoCropperPageState();
}

class _PhotoCropperPageState extends State<PhotoCropperPage> {
  List<Offset> points = [];
  File? selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Découpage Photo'),
        actions: [
          IconButton(
            icon: Icon(Icons.photo_library),
            onPressed: _pickImage,
            tooltip: 'Choisir une image',
          ),
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: points.isEmpty ? null : () {
              setState(() => points.clear());
            },
            tooltip: 'Effacer les points',
          ),
        ],
      ),
      body: selectedImage == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_library, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Appuyez sur l\'icône photo pour charger une image',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: Icon(Icons.photo),
                    label: Text('Choisir une image'),
                  ),
                ],
              ),
            )
          : GestureDetector(
              onTapDown: (details) {
                setState(() {
                  points.add(details.localPosition);
                });
              },
              child: Stack(
                children: [
                  // Image de fond
                  Center(
                    child: Image.file(
                      selectedImage!,
                      fit: BoxFit.contain,
                    ),
                  ),
                  // Polygone de sélection
                  CustomPaint(
                    painter: PhotoCropperPainter(points),
                    child: Container(),
                  ),
                ],
              ),
            ),
      floatingActionButton: selectedImage != null && points.length > 2
          ? FloatingActionButton.extended(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Export PNG avec ${points.length} points - À implémenter'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              icon: Icon(Icons.save),
              label: Text('Exporter (${points.length} pts)'),
            )
          : null,
      bottomNavigationBar: selectedImage != null
          ? Container(
              padding: EdgeInsets.all(16),
              color: Colors.grey[200],
              child: Text(
                points.isEmpty
                    ? 'Cliquez sur l\'image pour ajouter des points de découpage'
                    : 'Points: ${points.length} - Cliquez pour ajouter d\'autres points',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
            )
          : null,
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          selectedImage = File(image.path);
          points.clear(); // Réinitialiser les points
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la sélection de l\'image: $e')),
      );
    }
  }
}

class PhotoCropperPainter extends CustomPainter {
  final List<Offset> points;
  PhotoCropperPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length > 1) {
      final paint = Paint()
        ..color = Colors.red
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;

      final path = Path()..moveTo(points[0].dx, points[0].dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }

      // Fermer le polygone si au moins 3 points
      if (points.length > 2) {
        path.close();
        
        // Remplir avec transparence
        final fillPaint = Paint()
          ..color = Colors.red.withOpacity(0.2)
          ..style = PaintingStyle.fill;
        canvas.drawPath(path, fillPaint);
      }

      canvas.drawPath(path, paint);
    }

    // Dessiner les points
    for (final point in points) {
      final pointPaint = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.fill;

      canvas.drawCircle(point, 8, pointPaint);

      // Bordure blanche
      final borderPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(point, 8, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
