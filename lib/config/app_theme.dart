import 'package:flutter/material.dart';

/// Constantes de style de l'application
class AppTheme {
  // Couleurs principales
  static const Color navyBlue = Color(0xFF001F3F);
  static const Color softBlueGrey = Color(0xFFE8EFF5);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color darkGrey = Color(0xFF424242);
  
  // Couleurs d'accent
  static const Color accentBlue = Color(0xFF0074D9);
  static const Color successGreen = Color(0xFF2ECC40);
  static const Color errorRed = Color(0xFFFF4136);
  static const Color warningOrange = Color(0xFFFF851B);

  // Polices
  static const String primaryFont = 'Roboto';
  
  // Tailles de texte
  static const double titleSize = 24.0;
  static const double subtitleSize = 18.0;
  static const double bodySize = 16.0;
  static const double smallSize = 14.0;

  // Espacements
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // Bordures
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;

  // AppBar
  static AppBar buildAppBar({String? title, List<Widget>? actions}) {
    return AppBar(
      backgroundColor: navyBlue,
      title: title != null ? Text(title, style: TextStyle(color: Colors.white)) : null,
      centerTitle: true,
      elevation: 2,
      iconTheme: IconThemeData(color: Colors.white),
      actions: actions,
    );
  }

  // Bouton principal
  static Widget buildPrimaryButton({
    required String label,
    required VoidCallback onPressed,
    IconData? icon,
    bool enabled = true,
  }) {
    return ElevatedButton(
      onPressed: enabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: navyBlue,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: paddingLarge, vertical: paddingMedium),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
        elevation: 2,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon),
            SizedBox(width: 8),
          ],
          Text(
            label,
            style: TextStyle(fontSize: bodySize, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // Bouton secondaire
  static Widget buildSecondaryButton({
    required String label,
    required VoidCallback onPressed,
    IconData? icon,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: navyBlue,
        side: BorderSide(color: navyBlue, width: 2),
        padding: EdgeInsets.symmetric(horizontal: paddingLarge, vertical: paddingMedium),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon),
            SizedBox(width: 8),
          ],
          Text(
            label,
            style: TextStyle(fontSize: bodySize, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
