import 'package:flutter/material.dart';
import 'sticker_editor_page.dart';
import 'photo_cropper_page.dart';
import 'measurement_page.dart';

class HomePage extends StatelessWidget {
  // Couleur bleu navy
  static const Color navyBlue = Color.fromARGB(255, 1, 18, 36);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: AppBar(
          backgroundColor: navyBlue,
          elevation: 0,
          centerTitle: true,
          flexibleSpace: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Image.asset(
                'assets/images/logo_transparent_blanc.png',
                height: 76, // Hauteur ajustée à la barre (80 - padding)
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Text(
                    'LOGO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Bouton Création
              _buildNavButton(
                context,
                label: 'Création',
                icon: Icons.edit,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => StickerEditorPage()),
                  );
                },
              ),
              
              SizedBox(height: 24),

              // Bouton Découpe
              _buildNavButton(
                context,
                label: 'Découpe',
                icon: Icons.content_cut,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => PhotoCropperPage()),
                  );
                },
              ),

              SizedBox(height: 24),

              // Bouton Cotation
              _buildNavButton(
                context,
                label: 'Cotation',
                icon: Icons.straighten,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => MeasurementPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: navyBlue,
      borderRadius: BorderRadius.circular(16),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 32,
              ),
              SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
