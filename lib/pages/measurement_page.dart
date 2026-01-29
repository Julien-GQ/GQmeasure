import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'dart:math' as math;
import '../config/app_theme.dart';

class MeasurementPage extends StatefulWidget {
  @override
  _MeasurementPageState createState() => _MeasurementPageState();
}

class _MeasurementPageState extends State<MeasurementPage> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.softBlueGrey,
      appBar: AppTheme.buildAppBar(title: 'Cotation'),
      body: _selectedImage == null ? _buildImageSelectionScreen() : _buildWorkingScreen(),
    );
  }

  // Écran de sélection d'image
  Widget _buildImageSelectionScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Choisissez une source',
            style: TextStyle(
              fontSize: AppTheme.titleSize,
              fontWeight: FontWeight.bold,
              color: AppTheme.navyBlue,
            ),
          ),
          SizedBox(height: AppTheme.paddingXLarge),
          
          // Bouton Galerie
          _buildImageSourceButton(
            icon: Icons.folder_outlined,
            label: 'Galerie',
            onTap: () => _pickImage(ImageSource.gallery),
          ),
          
          SizedBox(height: AppTheme.paddingLarge),
          
          // Bouton Appareil Photo
          _buildImageSourceButton(
            icon: Icons.camera_alt_outlined,
            label: 'Appareil Photo',
            onTap: () => _pickImage(ImageSource.camera),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSourceButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        child: Container(
          width: 280,
          padding: EdgeInsets.symmetric(vertical: AppTheme.paddingLarge),
          child: Column(
            children: [
              Icon(
                icon,
                size: 64,
                color: AppTheme.navyBlue,
              ),
              SizedBox(height: AppTheme.paddingMedium),
              Text(
                label,
                style: TextStyle(
                  fontSize: AppTheme.subtitleSize,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.navyBlue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Écran de travail avec l'image
  Widget _buildWorkingScreen() {
    return PerspectiveAdjustmentScreen(
      image: _selectedImage!,
      onCancel: () {
        setState(() => _selectedImage = null);
      },
      onComplete: (File adjustedImage) {
        // TODO: Passer à la suite (ajout de cotes, etc.)
        setState(() => _selectedImage = adjustedImage);
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }
}

// Écran de redressement de perspective
class PerspectiveAdjustmentScreen extends StatefulWidget {
  final File image;
  final VoidCallback onCancel;
  final Function(File) onComplete;

  const PerspectiveAdjustmentScreen({
    Key? key,
    required this.image,
    required this.onCancel,
    required this.onComplete,
  }) : super(key: key);

  @override
  _PerspectiveAdjustmentScreenState createState() => _PerspectiveAdjustmentScreenState();
}

class _PerspectiveAdjustmentScreenState extends State<PerspectiveAdjustmentScreen> {
  List<Offset> _perspectivePoints = [];
  bool _showDialog = true;
  bool _isAdjusting = false;
  bool _isCropping = false;
  int? _selectedPointIndex;
  
  // Variables pour le recadrage
  double _cropLeft = 0;
  double _cropTop = 0;
  double _cropRight = 0;
  double _cropBottom = 0;
  int? _selectedCropEdge; // 0=left, 1=top, 2=right, 3=bottom

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Image avec points de redressement
        Positioned.fill(
          child: Container(
            color: Colors.black,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  onTapDown: (_isAdjusting || _isCropping) ? _handleTapDown : null,
                  onPanStart: (_isAdjusting || _isCropping) ? _handlePanStart : null,
                  onPanUpdate: (_isAdjusting || _isCropping) ? _handlePanUpdate : null,
                  onPanEnd: (_isAdjusting || _isCropping) ? _handlePanEnd : null,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(
                        widget.image,
                        fit: BoxFit.contain,
                      ),
                      if (_isAdjusting && !_isCropping)
                        CustomPaint(
                          painter: PerspectivePointsPainter(_perspectivePoints, _selectedPointIndex),
                          size: Size(constraints.maxWidth, constraints.maxHeight),
                        ),
                      if (_isCropping)
                        CustomPaint(
                          painter: CropHandlesPainter(
                            _cropLeft,
                            _cropTop,
                            _cropRight,
                            _cropBottom,
                            _selectedCropEdge,
                            constraints.maxWidth,
                            constraints.maxHeight,
                          ),
                          size: Size(constraints.maxWidth, constraints.maxHeight),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),

        // Dialogue de confirmation
        if (_showDialog)
          _buildConfirmationDialog(),

        // Boutons Valider/Annuler (en mode ajustement)
        if (_isAdjusting && !_isCropping)
          Positioned(
            bottom: 80,
            left: 20,
            right: 20,
            child: Row(
              children: [
                Expanded(
                  child: AppTheme.buildSecondaryButton(
                    label: 'Annuler',
                    onPressed: () {
                      setState(() {
                        _isAdjusting = false;
                        _perspectivePoints.clear();
                        _showDialog = true;
                      });
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: AppTheme.buildPrimaryButton(
                    label: 'Valider',
                    enabled: _perspectivePoints.length == 4,
                    onPressed: _perspectivePoints.length == 4 ? () async {
                      await _applyPerspectiveCorrection();
                    } : () {},
                  ),
                ),
              ],
            ),
          ),

        // Boutons Valider/Annuler (en mode recadrage)
        if (_isCropping)
          Positioned(
            bottom: 80,
            left: 20,
            right: 20,
            child: Row(
              children: [
                Expanded(
                  child: AppTheme.buildSecondaryButton(
                    label: 'Ignorer',
                    onPressed: () {
                      widget.onComplete(widget.image);
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: AppTheme.buildPrimaryButton(
                    label: 'Valider',
                    onPressed: () async {
                      await _applyCrop();
                    },
                  ),
                ),
              ],
            ),
          ),

        // Instructions
        if (_isAdjusting && !_isCropping)
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.navyBlue.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _perspectivePoints.length < 4
                    ? 'Placez les 4 coins d\'un rectangle de référence (${_perspectivePoints.length}/4)\nEx: les 4 coins de votre caisse'
                    : 'Ajustez les points si nécessaire, puis validez\nL\'image entière sera redressée',
                style: TextStyle(color: Colors.white, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
          ),

        // Bandeau recadrage
        if (_isCropping)
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.navyBlue.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Recadrage\nDéplacez les bords pour ajuster le cadre',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildConfirmationDialog() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 40),
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.crop_rotate,
                size: 48,
                color: AppTheme.navyBlue,
              ),
              SizedBox(height: 16),
              Text(
                'Redressement d\'image',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.navyBlue,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Souhaitez-vous redresser cette image pour une meilleure précision ?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: AppTheme.buildSecondaryButton(
                      label: 'Non',
                      onPressed: () {
                        widget.onComplete(widget.image);
                      },
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: AppTheme.buildPrimaryButton(
                      label: 'Oui',
                      onPressed: () {
                        setState(() {
                          _showDialog = false;
                          _isAdjusting = true;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleTapDown(TapDownDetails details) {
    if (_isCropping) {
      _detectCropEdge(details.localPosition);
    } else if (_perspectivePoints.length < 4) {
      setState(() {
        _perspectivePoints.add(details.localPosition);
      });
    }
  }

  void _handlePanStart(DragStartDetails details) {
    if (_isCropping) {
      _detectCropEdge(details.localPosition);
    } else {
      final point = details.localPosition;
      for (int i = 0; i < _perspectivePoints.length; i++) {
        if ((_perspectivePoints[i] - point).distance < 30) {
          setState(() => _selectedPointIndex = i);
          return;
        }
      }
    }
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (_isCropping && _selectedCropEdge != null) {
      setState(() {
        final RenderBox? box = context.findRenderObject() as RenderBox?;
        if (box != null) {
          final pos = details.localPosition;
          switch (_selectedCropEdge!) {
            case 0: // left
              _cropLeft = pos.dx.clamp(0, box.size.width - _cropRight - 100);
              break;
            case 1: // top
              _cropTop = pos.dy.clamp(0, box.size.height - _cropBottom - 100);
              break;
            case 2: // right
              _cropRight = (box.size.width - pos.dx).clamp(0, box.size.width - _cropLeft - 100);
              break;
            case 3: // bottom
              _cropBottom = (box.size.height - pos.dy).clamp(0, box.size.height - _cropTop - 100);
              break;
          }
        }
      });
    } else if (_selectedPointIndex != null) {
      setState(() {
        _perspectivePoints[_selectedPointIndex!] = details.localPosition;
      });
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    setState(() {
      _selectedPointIndex = null;
      _selectedCropEdge = null;
    });
  }

  void _detectCropEdge(Offset position) {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    
    final threshold = 30.0;
    
    // Vérifier la proximité avec chaque bord
    if ((position.dx - _cropLeft).abs() < threshold) {
      setState(() => _selectedCropEdge = 0); // left
    } else if ((position.dy - _cropTop).abs() < threshold) {
      setState(() => _selectedCropEdge = 1); // top
    } else if ((box.size.width - _cropRight - position.dx).abs() < threshold) {
      setState(() => _selectedCropEdge = 2); // right
    } else if ((box.size.height - _cropBottom - position.dy).abs() < threshold) {
      setState(() => _selectedCropEdge = 3); // bottom
    }
  }

  Future<void> _applyPerspectiveCorrection() async {
    try {
      // Afficher un indicateur de chargement
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Redressement en cours...'),
              ],
            ),
          ),
        ),
      );

      // Charger l'image
      final bytes = await widget.image.readAsBytes();
      final originalImage = img.decodeImage(bytes);
      
      if (originalImage == null) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de chargement de l\'image')),
        );
        return;
      }

      // Convertir les points écran vers les coordonnées image
      final RenderBox? box = context.findRenderObject() as RenderBox?;
      if (box == null) {
        Navigator.pop(context);
        return;
      }

      final screenSize = box.size;
      final imageSize = Size(originalImage.width.toDouble(), originalImage.height.toDouble());
      
      // Calculer la taille et position de l'image affichée avec BoxFit.contain
      double displayWidth, displayHeight, offsetX, offsetY;
      final screenRatio = screenSize.width / screenSize.height;
      final imageRatio = imageSize.width / imageSize.height;
      
      if (imageRatio > screenRatio) {
        // Image limitée par la largeur
        displayWidth = screenSize.width;
        displayHeight = screenSize.width / imageRatio;
        offsetX = 0;
        offsetY = (screenSize.height - displayHeight) / 2;
      } else {
        // Image limitée par la hauteur
        displayHeight = screenSize.height;
        displayWidth = screenSize.height * imageRatio;
        offsetX = (screenSize.width - displayWidth) / 2;
        offsetY = 0;
      }
      
      // Convertir les points
      List<Offset> imagePoints = _perspectivePoints.map((screenPoint) {
        double x = (screenPoint.dx - offsetX) / displayWidth * imageSize.width;
        double y = (screenPoint.dy - offsetY) / displayHeight * imageSize.height;
        return Offset(x, y);
      }).toList();

      // Calculer les dimensions du rectangle de référence
      double refWidth = ((imagePoints[1] - imagePoints[0]).distance + 
                        (imagePoints[2] - imagePoints[3]).distance) / 2;
      double refHeight = ((imagePoints[3] - imagePoints[0]).distance + 
                         (imagePoints[2] - imagePoints[1]).distance) / 2;

      // Créer la nouvelle image avec la transformation de perspective
      final transformedImage = img.Image(
        width: originalImage.width,
        height: originalImage.height,
      );

      // Appliquer la transformation de perspective à toute l'image
      for (int y = 0; y < transformedImage.height; y++) {
        for (int x = 0; x < transformedImage.width; x++) {
          final srcOffset = _applyPerspectiveTransform(
            x.toDouble(),
            y.toDouble(),
            imagePoints,
            refWidth,
            refHeight,
          );
          
          if (srcOffset != null) {
            final srcX = srcOffset.dx.round().clamp(0, originalImage.width - 1);
            final srcY = srcOffset.dy.round().clamp(0, originalImage.height - 1);
            transformedImage.setPixel(x, y, originalImage.getPixel(srcX, srcY));
          } else {
            // Pixel noir si hors de la transformation
            transformedImage.setPixel(x, y, img.ColorRgb8(0, 0, 0));
          }
        }
      }

      // Sauvegarder l'image transformée
      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/adjusted_${DateTime.now().millisecondsSinceEpoch}.png';
      final tempFile = File(tempPath);
      await tempFile.writeAsBytes(img.encodePng(transformedImage));

      Navigator.pop(context); // Fermer le dialogue de chargement
      
      // Passer en mode recadrage
      setState(() {
        _isAdjusting = false;
        _isCropping = true;
      });
      
      // Mettre à jour l'image du widget parent
      widget.onComplete(tempFile);

    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
  }

  Offset? _applyPerspectiveTransform(
    double x,
    double y,
    List<Offset> corners,
    double refWidth,
    double refHeight,
  ) {
    final p0 = corners[0];
    final p1 = corners[1];
    final p2 = corners[2];
    final p3 = corners[3];
    
    // Calculer le centre du quadrilatère de référence
    final centerX = (p0.dx + p1.dx + p2.dx + p3.dx) / 4;
    final centerY = (p0.dy + p1.dy + p2.dy + p3.dy) / 4;
    
    // Décaler x,y pour être relatif au centre du quadrilatère
    final dx = x - centerX;
    final dy = y - centerY;
    
    // Coordonnées normalisées (-0.5 à 0.5)
    final u = dx / refWidth;
    final v = dy / refHeight;
    
    // Interpolation bilinéaire pour trouver le point source
    // Interpoler le bord haut (entre p0 et p1)
    final topX = p0.dx + (u + 0.5) * (p1.dx - p0.dx);
    final topY = p0.dy + (u + 0.5) * (p1.dy - p0.dy);
    
    // Interpoler le bord bas (entre p3 et p2)
    final bottomX = p3.dx + (u + 0.5) * (p2.dx - p3.dx);
    final bottomY = p3.dy + (u + 0.5) * (p2.dy - p3.dy);
    
    // Interpoler entre haut et bas
    final srcX = topX + (v + 0.5) * (bottomX - topX);
    final srcY = topY + (v + 0.5) * (bottomY - topY);
    
    return Offset(srcX, srcY);
  }

  Future<void> _applyCrop() async {
    try {
      // Afficher un indicateur de chargement
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Recadrage en cours...'),
              ],
            ),
          ),
        ),
      );

      // Charger l'image
      final bytes = await widget.image.readAsBytes();
      final originalImage = img.decodeImage(bytes);
      
      if (originalImage == null) {
        Navigator.pop(context);
        return;
      }

      // Convertir les coordonnées écran vers image
      final RenderBox? box = context.findRenderObject() as RenderBox?;
      if (box == null) {
        Navigator.pop(context);
        return;
      }

      final screenSize = box.size;
      final imageSize = Size(originalImage.width.toDouble(), originalImage.height.toDouble());
      
      // Calculer la taille et position de l'image affichée
      double displayWidth, displayHeight, offsetX, offsetY;
      final screenRatio = screenSize.width / screenSize.height;
      final imageRatio = imageSize.width / imageSize.height;
      
      if (imageRatio > screenRatio) {
        displayWidth = screenSize.width;
        displayHeight = screenSize.width / imageRatio;
        offsetX = 0;
        offsetY = (screenSize.height - displayHeight) / 2;
      } else {
        displayHeight = screenSize.height;
        displayWidth = screenSize.height * imageRatio;
        offsetX = (screenSize.width - displayWidth) / 2;
        offsetY = 0;
      }
      
      // Convertir les marges de crop
      int left = ((_cropLeft - offsetX) / displayWidth * imageSize.width).round().clamp(0, originalImage.width);
      int top = ((_cropTop - offsetY) / displayHeight * imageSize.height).round().clamp(0, originalImage.height);
      int right = ((screenSize.width - _cropRight - offsetX) / displayWidth * imageSize.width).round().clamp(0, originalImage.width);
      int bottom = ((screenSize.height - _cropBottom - offsetY) / displayHeight * imageSize.height).round().clamp(0, originalImage.height);
      
      int cropWidth = (right - left).clamp(1, originalImage.width);
      int cropHeight = (bottom - top).clamp(1, originalImage.height);

      // Appliquer le recadrage
      final croppedImage = img.copyCrop(
        originalImage,
        x: left,
        y: top,
        width: cropWidth,
        height: cropHeight,
      );

      // Sauvegarder
      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.png';
      final tempFile = File(tempPath);
      await tempFile.writeAsBytes(img.encodePng(croppedImage));

      Navigator.pop(context); // Fermer le dialogue
      widget.onComplete(tempFile);

    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
  }
}

// Painter pour les points de perspective
class PerspectivePointsPainter extends CustomPainter {
  final List<Offset> points;
  final int? selectedIndex;

  PerspectivePointsPainter(this.points, this.selectedIndex);

  @override
  void paint(Canvas canvas, Size size) {
    // Dessiner les lignes entre les points si on a au moins 2 points
    if (points.length >= 2) {
      final linePaint = Paint()
        ..color = Colors.green.withOpacity(0.5)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      
      for (int i = 0; i < points.length - 1; i++) {
        canvas.drawLine(points[i], points[i + 1], linePaint);
      }
      
      // Fermer le quadrilatère si on a 4 points
      if (points.length == 4) {
        canvas.drawLine(points[3], points[0], linePaint);
      }
    }

    // Dessiner les points
    for (int i = 0; i < points.length; i++) {
      final isSelected = i == selectedIndex;
      
      // Cercle extérieur
      final outerPaint = Paint()
        ..color = isSelected ? Colors.blue : Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(points[i], isSelected ? 22 : 20, outerPaint);
      
      // Cercle intérieur
      final innerPaint = Paint()
        ..color = Colors.green
        ..style = PaintingStyle.fill;
      canvas.drawCircle(points[i], isSelected ? 18 : 16, innerPaint);
      
      // Numéro
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${i + 1}',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        points[i] - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(PerspectivePointsPainter oldDelegate) {
    return points != oldDelegate.points || selectedIndex != oldDelegate.selectedIndex;
  }
}

// Painter pour les poignées de recadrage
class CropHandlesPainter extends CustomPainter {
  final double left, top, right, bottom;
  final int? selectedEdge;
  final double screenWidth, screenHeight;

  CropHandlesPainter(
    this.left,
    this.top,
    this.right,
    this.bottom,
    this.selectedEdge,
    this.screenWidth,
    this.screenHeight,
  );

  @override
  void paint(Canvas canvas, Size size) {
    // Dessiner les zones grises (hors cadre)
    final overlayPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    
    // Zone gauche
    canvas.drawRect(Rect.fromLTWH(0, 0, left, screenHeight), overlayPaint);
    // Zone droite
    canvas.drawRect(Rect.fromLTWH(screenWidth - right, 0, right, screenHeight), overlayPaint);
    // Zone haut
    canvas.drawRect(Rect.fromLTWH(left, 0, screenWidth - left - right, top), overlayPaint);
    // Zone bas
    canvas.drawRect(Rect.fromLTWH(left, screenHeight - bottom, screenWidth - left - right, bottom), overlayPaint);
    
    // Dessiner les poignées
    final handleWidth = 50.0;
    final handleHeight = 6.0;
    
    // Left
    _drawHandle(canvas, left, screenHeight / 2, handleHeight, handleWidth, selectedEdge == 0);
    // Top
    _drawHandle(canvas, screenWidth / 2, top, handleWidth, handleHeight, selectedEdge == 1);
    // Right
    _drawHandle(canvas, screenWidth - right, screenHeight / 2, handleHeight, handleWidth, selectedEdge == 2);
    // Bottom
    _drawHandle(canvas, screenWidth / 2, screenHeight - bottom, handleWidth, handleHeight, selectedEdge == 3);
  }

  void _drawHandle(Canvas canvas, double cx, double cy, double width, double height, bool selected) {
    final paint = Paint()
      ..color = selected ? AppTheme.accentBlue : Colors.white
      ..style = PaintingStyle.fill;
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy), width: width, height: height),
        Radius.circular(3),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(CropHandlesPainter oldDelegate) => true;
}
