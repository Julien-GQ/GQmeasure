import 'package:flutter/material.dart';
import 'dart:async';
import 'home_page.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _verticalController;
  late AnimationController _horizontalController;
  late Animation<Offset> _fond1Animation;
  late Animation<Offset> _fond2Animation;
  late Animation<Offset> _fond3Animation;
  late Animation<Offset> _fond4Animation;

  bool _showVertical = false;
  bool _showHorizontal = false;

  @override
  void initState() {
    super.initState();

    // Animation verticale (fond_1 et fond_2)
    _verticalController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    // Animation horizontale (fond_3 et fond_4)
    _horizontalController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    // fond_1 : du haut vers le bas
    _fond1Animation = Tween<Offset>(
      begin: Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _verticalController,
      curve: Curves.easeInOut,
    ));

    // fond_2 : du bas vers le haut
    _fond2Animation = Tween<Offset>(
      begin: Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _verticalController,
      curve: Curves.easeInOut,
    ));

    // fond_3 : de gauche vers droite
    _fond3Animation = Tween<Offset>(
      begin: Offset(-1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _horizontalController,
      curve: Curves.easeInOut,
    ));

    // fond_4 : de droite vers gauche
    _fond4Animation = Tween<Offset>(
      begin: Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _horizontalController,
      curve: Curves.easeInOut,
    ));

    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    // Attendre 0.5 seconde
    await Future.delayed(Duration(milliseconds: 500));

    // Afficher et animer fond_1 et fond_2
    setState(() => _showVertical = true);
    _verticalController.forward();

    // Attendre la fin de l'animation (1s) + pause (0.5s)
    await Future.delayed(Duration(milliseconds: 1500));

    // Afficher et animer fond_3 et fond_4
    setState(() => _showHorizontal = true);
    _horizontalController.forward();

    // Attendre la fin de l'animation (1s) + pause (1s)
    await Future.delayed(Duration(milliseconds: 2000));

    // Naviguer vers HomePage
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => HomePage()),
      );
    }
  }

  @override
  void dispose() {
    _verticalController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // fond_0 : arrière-plan fixe
          Image.asset(
            'assets/images/fond_0.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[300],
                child: Center(
                  child: Text('fond_0.png manquant'),
                ),
              );
            },
          ),

          // fond_1 : du haut
          if (_showVertical)
            SlideTransition(
              position: _fond1Animation,
              child: Image.asset(
                'assets/images/fond_1.png',
                width: double.infinity,
                fit: BoxFit.fitWidth,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.blue.withOpacity(0.3),
                    child: Center(child: Text('fond_1.png')),
                  );
                },
              ),
            ),

          // fond_2 : du bas
          if (_showVertical)
            SlideTransition(
              position: _fond2Animation,
              child: Image.asset(
                'assets/images/fond_2.png',
                width: double.infinity,
                fit: BoxFit.fitWidth,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.green.withOpacity(0.3),
                    child: Center(child: Text('fond_2.png')),
                  );
                },
              ),
            ),

          // fond_3 : de la gauche
          if (_showHorizontal)
            SlideTransition(
              position: _fond3Animation,
              child: Image.asset(
                'assets/images/fond_3.png',
                width: double.infinity,
                fit: BoxFit.fitWidth,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.orange.withOpacity(0.3),
                    child: Center(child: Text('fond_3.png')),
                  );
                },
              ),
            ),

          // fond_4 : de la droite
          if (_showHorizontal)
            SlideTransition(
              position: _fond4Animation,
              child: Image.asset(
                'assets/images/fond_4.png',
                width: double.infinity,
                fit: BoxFit.fitWidth,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.purple.withOpacity(0.3),
                    child: Center(child: Text('fond_4.png')),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
