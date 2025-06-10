import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'views/tracking_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Imperial Tracker',
      theme: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF0A84FF),     // Blue accent like in sci-fi displays
          secondary: Color(0xFFFF453A),   // Red for warnings/important info
          tertiary: Color(0xFF30D158),    // Green for positive indicators
          surface: Color(0xFF121212),     // Very dark background
          surfaceContainerHighest: Color(0xFF1E1E1E),     // Slightly lighter for cards
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardTheme: const CardThemeData(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)),
            side: BorderSide(
              color: Color(0xFF0A84FF),
              width: 1,
            ),
          ),
        ),
        textTheme: GoogleFonts.orbitronTextTheme(
          ThemeData.dark().textTheme,
        ),
      ),
      home: const TrackingView(title: 'IMPERIAL TRACKING SYSTEM'),
    );
  }
}


