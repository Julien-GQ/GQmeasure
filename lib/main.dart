
import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'pages/sticker_editor_page.dart';
import 'pages/photo_cropper_page.dart';
import 'pages/measurement_page.dart';
import 'pages/splash_screen.dart';
import 'services/library_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LibraryManager.initialize();
  
  runApp(
    DevicePreview(
      enabled: !kReleaseMode, // Activer uniquement en mode debug
      builder: (context) => MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MultiTool App',
      theme: ThemeData(primarySwatch: Colors.blue),
      // Configuration pour Device Preview
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    StickerEditorPage(),
    PhotoCropperPage(),
    MeasurementPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.sticky_note_2), label: 'Autocollants'),
          BottomNavigationBarItem(icon: Icon(Icons.photo), label: 'Découpage'),
          BottomNavigationBarItem(icon: Icon(Icons.straighten), label: 'Cotes'),
        ],
      ),
    );
  }
}
