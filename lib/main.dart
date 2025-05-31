import 'dart:async';
import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';
import 'dart:io';
import 'package:excel/excel.dart' hide Border;
import 'package:flutter/material.dart';
import 'package:win32/win32.dart';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      home: const MyHomePage(title: 'IMPERIAL TRACKING SYSTEM'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class MouseEvent {
  final DateTime timestamp;
  final int x;
  final int y;
  final String type; // 'move' or 'click'
  MouseEvent(this.timestamp, this.x, this.y, this.type);
}

class _MyHomePageState extends State<MyHomePage> {
  final List<MouseEvent> _events = [];
  int _clickCount = 0;
  double _distance = 0.0;
  Timer? _moveTimer;
  Timer? _clickTimer;
  Timer? _clockTimer;
  int? _lastX;
  int? _lastY;
  bool _isClicked = false;
  String _currentTime = DateTime.now().toString().substring(0, 19);
  User? _user;
  bool _isSigningIn = false;

  @override
  void initState() {
    super.initState();
    _startMouseTracking();
    _startClock();
    _checkAuth();
  }
  
  void _startClock() {
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _currentTime = DateTime.now().toString().substring(0, 19);
      });
    });
  }

  void _startMouseTracking() {
    _moveTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      final pt = calloc<POINT>();
      GetCursorPos(pt);
      final x = pt.ref.x;
      final y = pt.ref.y;
      calloc.free(pt);
      
      // Only log movement if the mouse position has actually changed
      if (_lastX != null && _lastY != null) {
        if (x != _lastX || y != _lastY) {
          final dx = (x - _lastX!).abs();
          final dy = (y - _lastY!).abs();
          _distance += sqrt((dx * dx + dy * dy).toDouble());
          _events.add(MouseEvent(DateTime.now(), x, y, 'move'));
          setState(() {});
        }
      } else {
        // First time initialization - record the initial position
        _events.add(MouseEvent(DateTime.now(), x, y, 'move'));
        setState(() {});
      }
      _lastX = x;
      _lastY = y;
    });
    _clickTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      bool isButtonPressed = (GetAsyncKeyState(VK_LBUTTON) & 0x8000) != 0;
      
      if (isButtonPressed && !_isClicked) {
        // Button was just pressed, record the click
        final pt = calloc<POINT>();
        GetCursorPos(pt);
        final x = pt.ref.x;
        final y = pt.ref.y;
        calloc.free(pt);
        _events.add(MouseEvent(DateTime.now(), x, y, 'click'));
        _clickCount++;
        setState(() {});
        _isClicked = true;
      } else if (!isButtonPressed && _isClicked) {
        // Button was released
        _isClicked = false;
      }
    });
  }

  Future<void> _checkAuth() async {
    setState(() => _isSigningIn = true);
    try {
      // Anonymous sign-in for demo; replace with email/password or Google if needed
      final userCred = await FirebaseAuth.instance.signInAnonymously();
      setState(() {
        _user = userCred.user;
        _isSigningIn = false;
      });
    } catch (e) {
      setState(() => _isSigningIn = false);
      // Handle error (show dialog/snackbar if needed)
    }
  }

  Future<void> _uploadEventsToFirestore() async {
    if (_user == null) return;
    final batch = FirebaseFirestore.instance.batch();
    final userEvents = FirebaseFirestore.instance
        .collection('users')
        .doc(_user!.uid)
        .collection('mouse_events');
    for (final e in _events) {
      final doc = userEvents.doc();
      batch.set(doc, {
        'timestamp': e.timestamp.toIso8601String(),
        'x': e.x,
        'y': e.y,
        'type': e.type,
      });
    }
    await batch.commit();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Events uploaded to Firestore!')),
    );
  }  Future<void> _exportToExcel() async {
    final excel = Excel.createExcel();
    final sheet = excel['MouseEvents'];
    
    // Set cell values directly using updateCell instead of appendRow
    sheet.updateCell(CellIndex.indexByString('A1'), TextCellValue('Timestamp'));
    sheet.updateCell(CellIndex.indexByString('B1'), TextCellValue('X'));
    sheet.updateCell(CellIndex.indexByString('C1'), TextCellValue('Y'));
    sheet.updateCell(CellIndex.indexByString('D1'), TextCellValue('Type'));
    
    for (int i = 0; i < _events.length; i++) {
      final e = _events[i];
      final row = i + 2; // Start from row 2 (1-indexed)
      sheet.updateCell(CellIndex.indexByString('A$row'), TextCellValue(e.timestamp.toIso8601String()));
      sheet.updateCell(CellIndex.indexByString('B$row'), IntCellValue(e.x));
      sheet.updateCell(CellIndex.indexByString('C$row'), IntCellValue(e.y));
      sheet.updateCell(CellIndex.indexByString('D$row'), TextCellValue(e.type));
    }
    final downloadsPath = '${Platform.environment['USERPROFILE']}\\Downloads';
    final downloadsDir = Directory(downloadsPath);
    if (!await downloadsDir.exists()) {
      await downloadsDir.create(recursive: true);
    }
    final file = File('$downloadsPath/mouse_events.xlsx');
    await file.writeAsBytes(excel.encode()!);
    
    // Check if the widget is still mounted before using the context
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Exported to ${file.path}')),
    );
  }

  @override
  void dispose() {
    _moveTimer?.cancel();
    _clickTimer?.cancel();
    _clockTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: GlowText(
          widget.title,
          glowColor: Theme.of(context).colorScheme.primary.withAlpha(128),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_upload),
            onPressed: _user == null || _isSigningIn ? null : _uploadEventsToFirestore,
            tooltip: _user == null ? 'Sign in to upload' : 'Upload to Firestore',
            color: Theme.of(context).colorScheme.tertiary,
          ),
          IconButton(
            icon: const Icon(Icons.save_alt),
            onPressed: _exportToExcel,
            tooltip: 'Export to Excel',
            color: Theme.of(context).colorScheme.tertiary,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0), // Reduced padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Header section
              Container(
                padding: const EdgeInsets.all(10), // Reduced padding
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withAlpha(179),
                  borderRadius: BorderRadius.circular(12), // Slightly smaller radius
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 1.5, // Slightly thinner border
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'IMPERIAL TRACKING PROTOCOL',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14, // Smaller font
                      ),
                    ),
                    Text(
                      _currentTime,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12, // Smaller font
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6), // Further reduced spacing
              
              // Main dashboard grid
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 1.8, // Increased to make cards shorter
                  mainAxisSpacing: 12, // Reduced from 16
                  crossAxisSpacing: 16,
                  children: [
                    // Mouse movements card
                    _buildDashboardCard(
                      context,
                      icon: Icons.mouse,
                      title: 'MOVEMENTS TRACKED',
                      value: '${_events.length}',
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    // Mouse clicks card
                    _buildDashboardCard(
                      context,
                      icon: Icons.touch_app,
                      title: 'CLICK INTERACTIONS',
                      value: '$_clickCount',
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    // Distance moved card
                    _buildDashboardCard(
                      context,
                      icon: Icons.timeline,
                      title: 'DISTANCE MOVED',
                      value: '${_distance.toStringAsFixed(2)} px',
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    // Status card
                    _buildDashboardCard(
                      context,
                      icon: Icons.radar,
                      title: 'SYSTEM STATUS',
                      value: 'ACTIVE',
                      color: Colors.amber,
                      additionalContent: Column(
                        children: [
                          const SizedBox(height: 4), // Reduced from 8
                          LinearProgressIndicator(
                            value: null, // Indeterminate
                            backgroundColor: Colors.black26,
                            color: Colors.amber,
                          ),
                          const SizedBox(height: 4), // Reduced from 8
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Last Movement:',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Theme.of(context).colorScheme.onSurface.withAlpha(179),
                                ),
                              ),
                              Text(
                                _events.isNotEmpty 
                                  ? '${_events.last.x}, ${_events.last.y}'
                                  : 'No data',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Theme.of(context).colorScheme.onSurface.withAlpha(179),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6), // Further reduced spacing
              
              // Footer with status message
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10), // Reduced padding
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withAlpha(179),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'TRACKING SYSTEM OPERATIONAL - IMPERIAL AUTHORIZATION LEVEL 5',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11, // Smaller font
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildDashboardCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    Widget? additionalContent,
  }) {
    return Card(
      color: Theme.of(context).colorScheme.surface.withAlpha(179),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: color, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16), // Reduced vertical padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13, // Reduced from 14
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10), // Reduced space from Spacer
            Center(
              child: GlowText(
                value,
                glowColor: color.withAlpha(128),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            if (additionalContent != null) ...[
              const SizedBox(height: 5), // Reduced space from Spacer
              additionalContent,
            ],
          ],
        ),
      ),
    );
  }
}
