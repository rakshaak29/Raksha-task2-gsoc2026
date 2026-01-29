import 'package:flutter/material.dart';
import 'services/lg_service.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  runApp(const LiquidGalaxyApp());
}

class LiquidGalaxyApp extends StatefulWidget {
  const LiquidGalaxyApp({super.key});

  @override
  State<LiquidGalaxyApp> createState() => _LiquidGalaxyAppState();
}

class _LiquidGalaxyAppState extends State<LiquidGalaxyApp> {
  // Single instance of LGService shared across the app
  final LGService _lgService = LGService();

  @override
  void dispose() {
    // Clean up connection when app closes
    _lgService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Liquid Galaxy Controller',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      // Define routes
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(lgService: _lgService),
        '/settings': (context) => SettingsScreen(lgService: _lgService),
      },
    );
  }
}
