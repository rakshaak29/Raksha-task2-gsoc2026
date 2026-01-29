import 'package:flutter/material.dart';
import '../services/lg_service.dart';
import '../config/connection_settings.dart';
import '../config/lg_configuration.dart';

class SettingsScreen extends StatefulWidget {
  final LGService lgService;

  const SettingsScreen({super.key, required this.lgService});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ipController = TextEditingController(text: LGConfiguration.defaultIp);
  final _usernameController = TextEditingController(text: LGConfiguration.defaultUsername);
  final _passwordController = TextEditingController(text: LGConfiguration.defaultPassword);
  final _portController = TextEditingController(text: LGConfiguration.defaultPort.toString());
  
  bool _isConnecting = false;
  bool _obscurePassword = false; // Start with password visible
  String _errorMessage = '';

  @override
  void dispose() {
    _ipController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _portController.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isConnecting = true;
      _errorMessage = '';
    });

    final settings = ConnectionSettings(
      host: _ipController.text.trim(),
      username: _usernameController.text.trim(),
      password: _passwordController.text,
      port: int.tryParse(_portController.text) ?? LGConfiguration.defaultPort,
    );

    try {
      final success = await widget.lgService.connect(settings);
      if (mounted) {
        if (success) {
          Navigator.pop(context);
        } else {
          setState(() {
            _errorMessage = 'Connection failed';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isConnecting = false);
      }
    }
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
          backgroundColor: const Color(0xFF1A1F3A).withOpacity(0.8),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFFE2E8F0)),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'LG Connection Settings',
            style: TextStyle(
              color: Color(0xFFF1F5F9), 
              fontSize: 19,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),
      body: Column(
        children: [
          // Show status banner only when not connected
          if (!widget.lgService.isConnected)
            Container(
              color: const Color(0xFF4A1A1A),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Color(0xFFFB923C), size: 24),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Not Connected',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFCA5A5),
                        ),
                      ),
                      Text(
                        'Disconnected',
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Form fields container with dark theme
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1F3A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF252B4A)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // LG Master IP
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                            child: Text(
                              'LG Master IP',
                              style: TextStyle(
                                fontSize: 11,
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: TextFormField(
                              controller: _ipController,
                              style: const TextStyle(fontSize: 14, color: Color(0xFFE2E8F0)),
                              decoration: const InputDecoration(
                                hintText: '192.168.239.3',
                                hintStyle: TextStyle(color: Color(0xFF64748B)),
                                prefixIcon: Icon(Icons.computer, size: 18, color: Color(0xFF94A3B8)),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(vertical: 8),
                              ),
                            ),
                          ),
                          Divider(height: 1, color: const Color(0xFF252B4A)),

                          // SSH Port
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                            child: Text(
                              'SSH Port',
                              style: TextStyle(
                                fontSize: 11,
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: TextFormField(
                              controller: _portController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(fontSize: 14, color: Color(0xFFE2E8F0)),
                              decoration: const InputDecoration(
                                hintText: '22',
                                hintStyle: TextStyle(color: Color(0xFF64748B)),
                                prefixIcon: Icon(Icons.tag, size: 18, color: Color(0xFF94A3B8)),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(vertical: 8),
                              ),
                            ),
                          ),
                          Divider(height: 1, color: const Color(0xFF252B4A)),

                          // Username
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                            child: Text(
                              'Username',
                              style: TextStyle(
                                fontSize: 11,
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: TextFormField(
                              controller: _usernameController,
                              style: const TextStyle(fontSize: 14, color: Color(0xFFE2E8F0)),
                              decoration: const InputDecoration(
                                hintText: 'lg',
                                hintStyle: TextStyle(color: Color(0xFF64748B)),
                                prefixIcon: Icon(Icons.person, size: 18, color: Color(0xFF94A3B8)),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(vertical: 8),
                              ),
                            ),
                          ),
                          Divider(height: 1, color: const Color(0xFF252B4A)),

                          // Password
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                            child: Text(
                              'Password',
                              style: TextStyle(
                                fontSize: 11,
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                            child: TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: const TextStyle(fontSize: 14, color: Color(0xFFE2E8F0)),
                              decoration: InputDecoration(
                                hintText: '••••••••',
                                hintStyle: const TextStyle(color: Color(0xFF64748B)),
                                prefixIcon: const Icon(Icons.lock, size: 18, color: Color(0xFF94A3B8)),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                    size: 18,
                                    color: const Color(0xFF94A3B8),
                                  ),
                                  onPressed: () {
                                    setState(() => _obscurePassword = !_obscurePassword);
                                  },
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Buttons
                    Row(
                      children: [
                        // Connect Button
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF43A047), Color(0xFF00897B)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF43A047).withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _isConnecting ? null : _connect,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: _isConnecting
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.wifi, size: 18),
                                          SizedBox(width: 8),
                                          Text('Connect', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Save Button
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: OutlinedButton(
                              onPressed: _isConnecting ? null : _save,
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF1E88E5),
                                side: const BorderSide(color: Color(0xFF1E88E5), width: 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.save, size: 18, color: Colors.blue[700]),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Save',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Error banner at bottom
          if (_errorMessage.isNotEmpty)
            Container(
              width: double.infinity,
              color: const Color(0xFFF44336),
              padding: const EdgeInsets.all(12),
              child: Text(
                _errorMessage,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
      ),
    );
  }
}
