import 'dart:async';
import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:win32/win32.dart';
import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

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
  List<MouseEvent> _events = [];
  int _clickCount = 0;
  double _distance = 0.0;
  Timer? _moveTimer;
  Timer? _clickTimer;
  int? _lastX;
  int? _lastY;
  bool _isClicked = false;

  @override
  void initState() {
    super.initState();
    _startMouseTracking();
  }

  void _startMouseTracking() {
    _moveTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      final pt = calloc<POINT>();
      GetCursorPos(pt);
      final x = pt.ref.x;
      final y = pt.ref.y;
      calloc.free(pt);
      if (_lastX != null && _lastY != null) {
        final dx = (x - _lastX!).abs();
        final dy = (y - _lastY!).abs();
        _distance += sqrt((dx * dx + dy * dy).toDouble());
      }
      _lastX = x;
      _lastY = y;
      _events.add(MouseEvent(DateTime.now(), x, y, 'move'));
      setState(() {});
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

  Future<void> _exportToExcel() async {
    final excel = Excel.createExcel();
    final sheet = excel['MouseEvents'];
    sheet.appendRow(['Timestamp', 'X', 'Y', 'Type']);
    for (final e in _events) {
      sheet.appendRow([
        e.timestamp.toIso8601String(),
        e.x,
        e.y,
        e.type
      ]);
    }
    final downloadsPath = '${Platform.environment['USERPROFILE']}\\Downloads';
    final downloadsDir = Directory(downloadsPath);
    if (!await downloadsDir.exists()) {
      await downloadsDir.create(recursive: true);
    }
    final file = File('$downloadsPath/mouse_events.xlsx');
    await file.writeAsBytes(excel.encode()!);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Exported to ${file.path}')),
    );
  }

  @override
  void dispose() {
    _moveTimer?.cancel();
    _clickTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_alt),
            onPressed: _exportToExcel,
            tooltip: 'Export to Excel',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Mouse movements tracked: ${_events.length}'),
            Text('Mouse clicks: $_clickCount'),
            Text('Distance moved: ${_distance.toStringAsFixed(2)} pixels'),
            const SizedBox(height: 20),
            const Text('Tracking is running in the background.'),
          ],
        ),
      ),
    );
  }
}
