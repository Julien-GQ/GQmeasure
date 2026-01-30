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
  bool _isAdjusting = true; // Démarrer directement en mode ajustement
  bool _isCropping = false;
  bool _isWorking = false; // Mode de travail après recadrage
  int? _selectedPointIndex;
  
  // Variables pour le recadrage
  double _cropLeft = 0;
  double _cropTop = 0;
  double _cropRight = 0;
  double _cropBottom = 0;
  int? _selectedCropEdge; // 0=left, 1=top, 2=right, 3=bottom
  bool _showCropHandles = true;
  
  // Variables pour le mode de travail
  Color _selectedColor = Colors.red;
  String? _selectedTool; // 'linear', 'text', 'circular'
  
  // Variables pour les cotations
  List<LinearMeasurement> _linearMeasurements = [];
  List<Offset> _tempPoints = []; // Points temporaires pendant la sélection
  int? _draggingMeasurementIndex; // Index de la cotation en cours de déplacement
  int? _selectedMeasurementIndex; // Index de la cotation sélectionnée
  
  // Gestion des noms de cotations
  int _nameCounter = 0;
  final List<String> _predefinedNames = [
    'Longueur',
    'Largeur',
    'Hauteur',
    'Épaisseur',
    'Profondeur',
    'Diamètre',
    'Rayon',
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Image avec points de redressement
        Positioned.fill(
          child: Container(
            color: AppTheme.softBlueGrey,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  onTapDown: (_isAdjusting || _isCropping || _isWorking) ? _handleTapDown : null,
                  onPanStart: (_isAdjusting || _isCropping || _isWorking) ? _handlePanStart : null,
                  onPanUpdate: (_isAdjusting || _isCropping || _isWorking) ? _handlePanUpdate : null,
                  onPanEnd: (_isAdjusting || _isCropping || _isWorking) ? _handlePanEnd : null,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(
                        widget.image,
                        fit: BoxFit.contain,
                      ),
                      if (_isWorking)
                        CustomPaint(
                          painter: MeasurementPainter(
                            linearMeasurements: _linearMeasurements,
                            tempPoints: _tempPoints,
                            selectedColor: _selectedColor,
                            selectedTool: _selectedTool,
                            selectedIndex: _selectedMeasurementIndex,
                          ),
                          size: Size(constraints.maxWidth, constraints.maxHeight),
                        ),
                      if (_isAdjusting && !_isCropping)
                        CustomPaint(
                          painter: PerspectivePointsPainter(_perspectivePoints, _selectedPointIndex),
                          size: Size(constraints.maxWidth, constraints.maxHeight),
                        ),
                      if (_isCropping && _showCropHandles)
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

        // Bandeau orangé avec boutons (en mode ajustement)
        if (_isAdjusting && !_isCropping)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFB366),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    _perspectivePoints.length < 4
                        ? 'Placez 4 points aux coins d\'un rectangle de référence (${_perspectivePoints.length}/4)'
                        : 'Ajustez les points si nécessaire',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: AppTheme.buildSecondaryButton(
                          label: 'Passer',
                          onPressed: () {
                            widget.onComplete(widget.image);
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
              ],
            ),
          ),

        // Boutons Valider/Passer (en mode recadrage)
        if (_isCropping && !_isWorking)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFB366),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    'Ajustez les bords pour recadrer l\'image',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: AppTheme.buildSecondaryButton(
                          label: 'Passer',
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
              ],
            ),
          ),

        // Bandeau d'outils (en mode travail)
        if (_isWorking)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Partie scrollable avec les outils (4/5)
                  Expanded(
                    flex: 4,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: [
                          _buildToolButton(
                            icon: Icons.straighten,
                            toolId: 'linear',
                          ),
                          SizedBox(width: 8),
                          _buildToolButton(
                            icon: Icons.text_fields,
                            toolId: 'text',
                          ),
                          SizedBox(width: 8),
                          _buildToolButton(
                            icon: Icons.radio_button_unchecked,
                            toolId: 'circular',
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Séparateur
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.grey[300],
                  ),
                  
                  // Sélecteur de couleur (1/5)
                  Expanded(
                    flex: 1,
                    child: InkWell(
                      onTap: _showColorPicker,
                      child: Container(
                        margin: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _selectedColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.grey[400]!,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Bandeau d'édition (en bas quand une cotation est sélectionnée)
        if (_selectedMeasurementIndex != null && _isWorking)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      // Nom
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Nom', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            SizedBox(height: 4),
                            GestureDetector(
                              onDoubleTap: () {
                                _showPredefinedNamesDialog();
                              },
                              child: Container(
                                height: 40,
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: TextField(
                                  controller: TextEditingController(text: _linearMeasurements[_selectedMeasurementIndex!].name)
                                    ..selection = TextSelection.fromPosition(
                                      TextPosition(offset: _linearMeasurements[_selectedMeasurementIndex!].name.length),
                                    ),
                                  decoration: InputDecoration(border: InputBorder.none),
                                  onChanged: (value) {
                                    _linearMeasurements[_selectedMeasurementIndex!].name = value;
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12),
                      // Valeur
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Valeur', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            SizedBox(height: 4),
                            Container(
                              height: 40,
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: TextField(
                                controller: TextEditingController(text: _linearMeasurements[_selectedMeasurementIndex!].value)
                                  ..selection = TextSelection.fromPosition(
                                    TextPosition(offset: _linearMeasurements[_selectedMeasurementIndex!].value.length),
                                  ),
                                decoration: InputDecoration(border: InputBorder.none),
                                onChanged: (value) {
                                  _linearMeasurements[_selectedMeasurementIndex!].value = value;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12),
                      // Couleur
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Couleur', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          InkWell(
                            onTap: () => _showColorPickerForSelected(),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: _linearMeasurements[_selectedMeasurementIndex!].color,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.grey[400]!),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              // Forcer le repaint pour appliquer les modifications
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Cotation modifiée'), duration: Duration(seconds: 1)),
                            );
                          },
                          icon: Icon(Icons.check, color: Colors.white, size: 18),
                          label: Text('Modifier', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.navyBlue,
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _linearMeasurements.removeAt(_selectedMeasurementIndex!);
                              _selectedMeasurementIndex = null;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Cotation supprimée'), duration: Duration(seconds: 1)),
                            );
                          },
                          icon: Icon(Icons.delete, color: Colors.white, size: 18),
                          label: Text('Supprimer', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String toolId,
  }) {
    final isSelected = _selectedTool == toolId;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedTool = toolId;
          _tempPoints.clear(); // Réinitialiser les points temporaires
        });
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accentBlue.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppTheme.accentBlue : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Icon(
          icon,
          size: 28,
          color: isSelected ? AppTheme.accentBlue : AppTheme.navyBlue,
        ),
      ),
    );
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Choisir une couleur'),
        content: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            Colors.red,
            Colors.blue,
            Colors.green,
            Colors.orange,
            Colors.purple,
            Colors.black,
            Colors.white,
            Colors.yellow,
            Colors.pink,
          ].map((color) {
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedColor = color;
                });
                Navigator.pop(context);
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color == _selectedColor ? AppTheme.accentBlue : Colors.grey[400]!,
                    width: color == _selectedColor ? 3 : 1,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showValueInputDialog() {
    final valueController = TextEditingController();
    final nameController = TextEditingController(text: _getNextName());
    String? selectedPredefined;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Nouvelle cotation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Nom
              DropdownButtonFormField<String>(
                value: selectedPredefined,
                decoration: InputDecoration(
                  labelText: 'Nom',
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(value: null, child: Text('Personnalisé')),
                  ..._predefinedNames.map((name) => DropdownMenuItem(
                    value: name,
                    child: Text(name),
                  )),
                ],
                onChanged: (value) {
                  setDialogState(() {
                    selectedPredefined = value;
                    if (value != null) {
                      nameController.text = value;
                    }
                  });
                },
              ),
              SizedBox(height: 12),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: selectedPredefined == null ? 'Nom personnalisé' : 'Nom sélectionné',
                  border: OutlineInputBorder(),
                ),
                readOnly: selectedPredefined != null,
              ),
              SizedBox(height: 12),
              // Valeur
              TextField(
                controller: valueController,
                autofocus: true,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: 'Valeur',
                  hintText: 'Ex: 150 cm',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty && nameController.text.isNotEmpty) {
                    _addLinearMeasurement(valueController.text, nameController.text);
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() => _tempPoints.clear());
                Navigator.pop(context);
              },
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (valueController.text.isNotEmpty && nameController.text.isNotEmpty) {
                  _addLinearMeasurement(valueController.text, nameController.text);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.navyBlue,
              ),
              child: Text('Valider', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _addLinearMeasurement(String value, String name) {
    if (_tempPoints.length == 2) {
      setState(() {
        _linearMeasurements.add(LinearMeasurement(
          point1: _tempPoints[0],
          point2: _tempPoints[1],
          value: value,
          name: name,
          color: _selectedColor,
        ));
        _tempPoints.clear();
        _nameCounter++; // Incrémenter pour le prochain nom auto
      });
    }
  }
  
  String _getNextName() {
    // Générer A, B, C... Z, AA, AB... etc
    int counter = _nameCounter;
    String name = '';
    do {
      name = String.fromCharCode(65 + (counter % 26)) + name;
      counter = (counter ~/ 26) - 1;
    } while (counter >= 0);
    return name;
  }
  
  void _showColorPickerForSelected() {
    if (_selectedMeasurementIndex == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Choisir une couleur'),
        content: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            Colors.red,
            Colors.blue,
            Colors.green,
            Colors.orange,
            Colors.purple,
            Colors.black,
            Colors.white,
            Colors.yellow,
            Colors.pink,
          ].map((color) {
            return InkWell(
              onTap: () {
                setState(() {
                  _linearMeasurements[_selectedMeasurementIndex!].color = color;
                });
                Navigator.pop(context);
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.grey[400]!,
                    width: 2,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showPredefinedNamesDialog() {
    if (_selectedMeasurementIndex == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Choisir un nom'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _predefinedNames.map((name) {
            return ListTile(
              title: Text(name),
              onTap: () {
                setState(() {
                  _linearMeasurements[_selectedMeasurementIndex!].name = name;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
        ],
      ),
    );
  }

  bool _isNearMeasurementLine(Offset point, LinearMeasurement measurement) {
    final p1 = measurement.point1;
    final p2 = measurement.point2;
    
    // Calculer l'angle et l'offset
    final dx = p2.dx - p1.dx;
    final dy = p2.dy - p1.dy;
    final angle = math.atan2(dy, dx);
    final perpAngle = angle + math.pi / 2;
    
    // Position de la ligne de cotation
    final offsetX = math.cos(perpAngle) * measurement.offset;
    final offsetY = math.sin(perpAngle) * measurement.offset;
    final lineStart = Offset(p1.dx + offsetX, p1.dy + offsetY);
    final lineEnd = Offset(p2.dx + offsetX, p2.dy + offsetY);
    
    // Distance du point à la ligne
    final distance = _distanceToLineSegment(point, lineStart, lineEnd);
    return distance < 15; // Tolérance de 15px
  }

  double _distanceToLineSegment(Offset p, Offset a, Offset b) {
    final dx = b.dx - a.dx;
    final dy = b.dy - a.dy;
    final lengthSquared = dx * dx + dy * dy;
    
    if (lengthSquared == 0) return (p - a).distance;
    
    final t = ((p.dx - a.dx) * dx + (p.dy - a.dy) * dy) / lengthSquared;
    final tClamped = t.clamp(0.0, 1.0);
    
    final projection = Offset(
      a.dx + tClamped * dx,
      a.dy + tClamped * dy,
    );
    
    return (p - projection).distance;
  }

  void _handleTapDown(TapDownDetails details) {
    if (_isCropping) {
      _detectCropEdge(details.localPosition);
    } else if (_isWorking && _selectedTool == 'linear') {
      // Vérifier si on clique sur une cotation existante pour la déplacer
      bool clickedOnMeasurement = false;
      for (int i = 0; i < _linearMeasurements.length; i++) {
        if (_isNearMeasurementLine(details.localPosition, _linearMeasurements[i])) {
          clickedOnMeasurement = true;
          break;
        }
      }
      
      // Si on n'a pas cliqué sur une cotation existante, ajouter un point
      if (!clickedOnMeasurement) {
        setState(() {
          _tempPoints.add(details.localPosition);
          _selectedMeasurementIndex = null; // Désélectionner si on crée une nouvelle cotation
        });
        
        // Ouvrir le dialogue après avoir ajouté le 2ème point
        if (_tempPoints.length == 2) {
          Future.microtask(() => _showValueInputDialog());
        }
      } else {
        // Sélectionner la cotation cliquée
        for (int i = 0; i < _linearMeasurements.length; i++) {
          if (_isNearMeasurementLine(details.localPosition, _linearMeasurements[i])) {
            setState(() {
              _selectedMeasurementIndex = i;
            });
            break;
          }
        }
      }
    } else if (_perspectivePoints.length < 4) {
      setState(() {
        _perspectivePoints.add(details.localPosition);
      });
    }
  }

  void _handlePanStart(DragStartDetails details) {
    if (_isCropping) {
      _detectCropEdge(details.localPosition);
    } else if (_isWorking && _selectedTool == 'linear') {
      // Vérifier si on clique près d'une cotation existante pour la déplacer
      for (int i = 0; i < _linearMeasurements.length; i++) {
        if (_isNearMeasurementLine(details.localPosition, _linearMeasurements[i])) {
          setState(() {
            _draggingMeasurementIndex = i;
          });
          return;
        }
      }
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
    } else if (_draggingMeasurementIndex != null) {
      // Déplacer la cotation perpendiculairement
      setState(() {
        final measurement = _linearMeasurements[_draggingMeasurementIndex!];
        final p1 = measurement.point1;
        final p2 = measurement.point2;
        
        // Calculer l'angle de la ligne
        final dx = p2.dx - p1.dx;
        final dy = p2.dy - p1.dy;
        final angle = math.atan2(dy, dx);
        final perpAngle = angle + math.pi / 2;
        
        // Projeter le mouvement sur l'axe perpendiculaire
        final dragDelta = details.localPosition - p1;
        final perpDistance = dragDelta.dx * math.cos(perpAngle) + dragDelta.dy * math.sin(perpAngle);
        
        measurement.offset = perpDistance.clamp(-100.0, 100.0);
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
      _draggingMeasurementIndex = null;
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
      
      // Passer en mode recadrage - initialiser les poignées pour encadrer l'image
      setState(() {
        _isAdjusting = false;
        _isCropping = true;
        _showCropHandles = true;
        
        // Calculer les marges initiales pour encadrer l'image
        final RenderBox? box = context.findRenderObject() as RenderBox?;
        if (box != null) {
          final screenSize = box.size;
          final imageRatio = originalImage.width / originalImage.height;
          final screenRatio = screenSize.width / screenSize.height;
          
          if (imageRatio > screenRatio) {
            // Image limitée par la largeur
            final displayHeight = screenSize.width / imageRatio;
            final offsetY = (screenSize.height - displayHeight) / 2;
            _cropTop = offsetY + 20;
            _cropBottom = offsetY + 20;
            _cropLeft = 20;
            _cropRight = 20;
          } else {
            // Image limitée par la hauteur
            final displayWidth = screenSize.height * imageRatio;
            final offsetX = (screenSize.width - displayWidth) / 2;
            _cropLeft = offsetX + 20;
            _cropRight = offsetX + 20;
            _cropTop = 20;
            _cropBottom = 20;
          }
        }
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
      setState(() {
        _showCropHandles = false;
        _isCropping = false;
        _isWorking = true;
      });
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

// Classe pour stocker une cotation linéaire
class LinearMeasurement {
  final Offset point1;
  final Offset point2;
  String value; // Modifiable
  String name; // Nom de la cotation
  Color color; // Modifiable
  double offset; // Décalage perpendiculaire (modifiable)

  LinearMeasurement({
    required this.point1,
    required this.point2,
    required this.value,
    required this.name,
    required this.color,
    this.offset = 20.0,
  });
}

// Painter pour dessiner les cotations
class MeasurementPainter extends CustomPainter {
  final List<LinearMeasurement> linearMeasurements;
  final List<Offset> tempPoints;
  final Color selectedColor;
  final String? selectedTool;
  final int? selectedIndex;

  MeasurementPainter({
    required this.linearMeasurements,
    required this.tempPoints,
    required this.selectedColor,
    this.selectedTool,
    this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Dessiner toutes les cotations linéaires enregistrées
    for (int i = 0; i < linearMeasurements.length; i++) {
      final measurement = linearMeasurements[i];
      _drawLinearMeasurement(
        canvas,
        measurement.point1,
        measurement.point2,
        measurement.value,
        measurement.color,
        measurement.offset,
        i == selectedIndex,
      );
    }

    // Dessiner les points temporaires pendant la sélection
    if (selectedTool == 'linear' && tempPoints.isNotEmpty) {
      final pointPaint = Paint()
        ..color = selectedColor
        ..style = PaintingStyle.fill;
      
      for (var point in tempPoints) {
        canvas.drawCircle(point, 6, pointPaint);
      }
      
      // Si on a 1 point, dessiner une ligne temporaire jusqu'au curseur si on voulait
      // Pour l'instant on attend juste le 2ème point
    }
  }

  void _drawLinearMeasurement(Canvas canvas, Offset p1, Offset p2, String value, Color color, double offsetDist, bool isSelected) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final arrowPaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.fill;

    // Calculer l'angle de la ligne
    final dx = p2.dx - p1.dx;
    final dy = p2.dy - p1.dy;
    final angle = math.atan2(dy, dx);

    // Décalage perpendiculaire pour la ligne de cotation (utiliser offsetDist au lieu de 20)
    final perpAngle = angle + math.pi / 2;
    final offsetX = math.cos(perpAngle) * offsetDist;
    final offsetY = math.sin(perpAngle) * offsetDist;

    final start = Offset(p1.dx + offsetX, p1.dy + offsetY);
    final end = Offset(p2.dx + offsetX, p2.dy + offsetY);

    // Dessiner la ligne principale
    canvas.drawLine(start, end, paint);

    // Dessiner les lignes de rappel (perpendiculaires)
    final tickLength = 15.0;
    final tickAngle = perpAngle;
    
    // Ligne de rappel point 1
    final tick1Start = p1;
    final tick1End = Offset(
      p1.dx + math.cos(tickAngle) * (offsetDist + tickLength),
      p1.dy + math.sin(tickAngle) * (offsetDist + tickLength),
    );
    canvas.drawLine(tick1Start, tick1End, paint);

    // Ligne de rappel point 2
    final tick2Start = p2;
    final tick2End = Offset(
      p2.dx + math.cos(tickAngle) * (offsetDist + tickLength),
      p2.dy + math.sin(tickAngle) * (offsetDist + tickLength),
    );
    canvas.drawLine(tick2Start, tick2End, paint);

    // Dessiner les flèches
    final arrowSize = 8.0;
    _drawArrow(canvas, start, angle, arrowSize, arrowPaint);
    _drawArrow(canvas, end, angle + math.pi, arrowSize, arrowPaint);

    // Dessiner le texte au centre au-dessus de la ligne
    final center = Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);
    final textPainter = TextPainter(
      text: TextSpan(
        text: value,
        style: TextStyle(
          color: Colors.black,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    
    // Positionner le texte au-dessus de la ligne
    final textOffset = Offset(
      center.dx - textPainter.width / 2,
      center.dy - textPainter.height - 5,
    );
    
    // Dessiner le rectangle blanc avec padding autour du texte
    final padding = 3.0; // Augmentez cette valeur pour agrandir le rectangle
    final backgroundRect = Rect.fromLTWH(
      textOffset.dx - padding,
      textOffset.dy - padding,
      textPainter.width + padding * 2,
      textPainter.height + padding * 2,
    );
    final backgroundPaint = Paint()
      ..color = const Color.fromARGB(255, 255, 255, 255)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(backgroundRect, Radius.circular(4)),
      backgroundPaint,
    );
    
    // Si sélectionné, dessiner un cadre coloré autour
    if (isSelected) {
      final selectionPaint = Paint()
        ..color = const Color.fromARGB(255, 0, 47, 255)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawRRect(
        RRect.fromRectAndRadius(backgroundRect, Radius.circular(4)),
        selectionPaint,
      );
    }
    
    // Dessiner le texte par-dessus
    textPainter.paint(canvas, textOffset);
  }

  void _drawArrow(Canvas canvas, Offset tip, double angle, double size, Paint paint) {
    final path = Path();
    path.moveTo(tip.dx, tip.dy);
    path.lineTo(
      tip.dx - size * math.cos(angle - math.pi / 6),
      tip.dy - size * math.sin(angle - math.pi / 6),
    );
    path.lineTo(
      tip.dx - size * math.cos(angle + math.pi / 6),
      tip.dy - size * math.sin(angle + math.pi / 6),
    );
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(MeasurementPainter oldDelegate) {
    return linearMeasurements != oldDelegate.linearMeasurements ||
           tempPoints != oldDelegate.tempPoints ||
           selectedColor != oldDelegate.selectedColor ||
           selectedTool != oldDelegate.selectedTool ||
           selectedIndex != oldDelegate.selectedIndex;
  }
}

