import 'package:flutter/material.dart';
import '../services/lg_service.dart';
import '../widgets/action_card.dart';

class HomeScreen extends StatefulWidget {
  final LGService lgService;

  const HomeScreen({super.key, required this.lgService});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;
  String _statusMessage = '';

  Future<void> _executeAction(String actionName, Future<void> Function() action) async {
    setState(() {
      _isLoading = true;
      _statusMessage = '';
    });
    
    try {
      await action();
      if (mounted) {
        setState(() {
          _statusMessage = '$actionName completed successfully!';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = 'Error: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A0E27), Color(0xFF1A1F3A), Color(0xFF252B4A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text(
              'Liquid Galaxy Control',
              style: TextStyle(
                color: Color(0xFFF1F5F9), 
                fontSize: 19,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
            backgroundColor: const Color(0xFF1A1F3A).withOpacity(0.8),
            foregroundColor: const Color(0xFFE2E8F0),
            elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.wifi,
              color: widget.lgService.isConnected ? Colors.green : Colors.grey,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.pushNamed(context, '/settings');
              // Refresh state when returning from settings
              if (mounted) {
                setState(() {});
              }
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Connection Status Banner
          Container(
            color: widget.lgService.isConnected 
                ? const Color(0xFF1A4D2E) 
                : const Color(0xFF4A1A1A),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  widget.lgService.isConnected ? Icons.check_circle : Icons.error,
                  color: widget.lgService.isConnected 
                      ? const Color(0xFF4ADE80) 
                      : const Color(0xFFEF4444),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.lgService.isConnected ? 'Connected to LG Master' : 'Not Connected',
                  style: TextStyle(
                    color: widget.lgService.isConnected 
                        ? const Color(0xFF86EFAC) 
                        : const Color(0xFFFCA5A5),
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // Status Message Area (dark background)
          if (_statusMessage.isNotEmpty)
            Container(
              color: const Color(0xFF1A1F3A),
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              child: Text(
                _statusMessage,
                style: const TextStyle(
                  color: Color(0xFFE2E8F0),
                  fontSize: 13,
                ),
              ),
            ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Card 1: Show LG Logo - Dark blue gradient
                  ActionCard(
                    icon: Icons.image,
                    title: 'Show LG Logo',
                    description: 'Displays on LEFT screen (LG3)',
                    gradientColors: const [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                    isEnabled: !_isLoading && widget.lgService.isConnected,
                    onTap: () => _executeAction('Show LG Logo', widget.lgService.showLogoOnLeftScreen),
                  ),
                  const SizedBox(height: 14),

                  // Card 2: Send 3D Pyramid - Dark purple gradient
                  ActionCard(
                    icon: Icons.change_history,
                    title: 'Send 3D Pyramid',
                    description: 'a colored pyramid at Bangalore',
                    gradientColors: const [Color(0xFF6B21A8), Color(0xFFA855F7)],
                    isEnabled: !_isLoading && widget.lgService.isConnected,
                    onTap: () => _executeAction('Send 3D Pyramid', widget.lgService.sendPyramidKml),
                  ),
                  const SizedBox(height: 14),

                  // Card 3: Fly to Bangalore - Dark green gradient
                  ActionCard(
                    icon: Icons.flight,
                    title: 'Fly to Bangalore',
                    description: 'Navigate to 12.9716, 77.5946',
                    gradientColors: const [Color(0xFF15803D), Color(0xFF22C55E)],
                    isEnabled: !_isLoading && widget.lgService.isConnected,
                    onTap: () => _executeAction('Fly to Bangalore', widget.lgService.flyToHomeCity),
                  ),
                  const SizedBox(height: 24),

                  // Section Header
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14, left: 4),
                    child: Text(
                      'Clear Operations',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF94A3B8),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  // Card 4: Clear All Logos - Dark orange gradient
                  ActionCard(
                    icon: Icons.hide_image,
                    title: 'Clear All Logos',
                    description: 'Removes logos from all screens',
                    gradientColors: const [Color(0xFFC2410C), Color(0xFFFB923C)],
                    isEnabled: !_isLoading && widget.lgService.isConnected,
                    onTap: () => _executeAction('Clear All Logos', widget.lgService.clearAllLogos),
                  ),
                  const SizedBox(height: 14),

                  // Card 5: Clear All KMLs - Dark red gradient
                  ActionCard(
                    icon: Icons.delete_sweep,
                    title: 'Clear All KMLs',
                    description: 'Removes all KML files and exits tours',
                    gradientColors: const [Color(0xFFB91C1C), Color(0xFFEF4444)],
                    isEnabled: !_isLoading && widget.lgService.isConnected,
                    onTap: () => _executeAction('Clear All KMLs', widget.lgService.clearAllKmls),
                  ),
                  const SizedBox(height: 24),

                  // How it works link
                  InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: const Color(0xFF1A1F3A),
                          title: const Text(
                            'How it works',
                            style: TextStyle(color: Color(0xFFF1F5F9)),
                          ),
                          content: const Text(
                            'This app connects to your Liquid Galaxy rig via SSH and sends commands to:\n\n'
                            '• Display logos on slave screens\n'
                            '• Send KML files for 3D visualization\n'
                            '• Navigate the camera (FlyTo)\n'
                            '• Clear content from screens\n\n'
                            'Make sure your LG rig is connected and configured in Settings.',
                            style: TextStyle(color: Color(0xFFE2E8F0)),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                'Got it',
                                style: TextStyle(color: Color(0xFF3B82F6)),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, size: 16, color: const Color(0xFF94A3B8)),
                          const SizedBox(width: 6),
                          Text(
                            'How it works',
                            style: TextStyle(
                              color: const Color(0xFF94A3B8),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Loading indicator
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
        ),
      ),
    );
  }
}
