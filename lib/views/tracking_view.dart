import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_glow/flutter_glow.dart';
import '../viewmodels/tracking_viewmodel.dart';

class TrackingView extends StatefulWidget {
  final String title;
  
  const TrackingView({super.key, required this.title});

  @override
  State<TrackingView> createState() => _TrackingViewState();
}

class _TrackingViewState extends State<TrackingView> {
  final TrackingViewModel _viewModel = TrackingViewModel();
  
  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onViewModelChanged);
    _viewModel.initialize();
  }
  
  void _onViewModelChanged() {
    if (mounted) {
      setState(() {});
    }
  }
  
  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final trackingData = _viewModel.trackingData;
    
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
            onPressed: _viewModel.user == null || _viewModel.isSigningIn ? null : _uploadEvents,
            tooltip: _viewModel.user == null ? 'Sign in to upload' : 'Upload to Firestore',
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
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Header section
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withAlpha(179),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 1.5,
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
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      trackingData.currentTime,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              
              // Main dashboard grid
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 1.8,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 16,
                  children: [
                    // Mouse movements card
                    _buildDashboardCard(
                      context,
                      icon: Icons.mouse,
                      title: 'MOVEMENTS TRACKED',
                      value: '${trackingData.events.length}',
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    // Mouse clicks card
                    _buildDashboardCard(
                      context,
                      icon: Icons.touch_app,
                      title: 'CLICK INTERACTIONS',
                      value: '${trackingData.clickCount}',
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    // Distance moved card
                    _buildDashboardCard(
                      context,
                      icon: Icons.timeline,
                      title: 'DISTANCE MOVED',
                      value: '${trackingData.distance.toStringAsFixed(2)} px',
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
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: null, // Indeterminate
                            backgroundColor: Colors.black26,
                            color: Colors.amber,
                          ),
                          const SizedBox(height: 4),
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
                                trackingData.events.isNotEmpty 
                                  ? '${trackingData.events.last.x}, ${trackingData.events.last.y}'
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
              const SizedBox(height: 6),
              
              // Footer with status message
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withAlpha(179),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'TRACKING SYSTEM OPERATIONAL - IMPERIAL AUTHORIZATION LEVEL 5',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
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
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
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
              const SizedBox(height: 5),
              additionalContent,
            ],
          ],
        ),
      ),
    );
  }
  
  Future<void> _uploadEvents() async {
    final message = await _viewModel.uploadEventsToFirestore();
    if (mounted && message != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }
  
  Future<void> _exportToExcel() async {
    final message = await _viewModel.exportToExcel();
    if (mounted && message != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }
}