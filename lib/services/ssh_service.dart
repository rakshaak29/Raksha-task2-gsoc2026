import 'dart:convert';
import 'dart:typed_data';
import 'package:dartssh2/dartssh2.dart';
import '../config/connection_settings.dart';

/// SSH service for connecting to Liquid Galaxy master node
class SSHService {
  SSHClient? _client;

  bool get isConnected => _client != null;

  /// Connect to LG master via SSH
  Future<bool> connect(ConnectionSettings settings) async {
    try {
      // Disconnect any existing connection first
      await disconnect();
      
      final socket = await SSHSocket.connect(
        settings.host,
        settings.port,
        timeout: const Duration(seconds: 15),
      );

      print('Connecting to ${settings.host}:${settings.port} as ${settings.username}...');
      
      _client = SSHClient(
        socket,
        username: settings.username,
        onPasswordRequest: () {
          print('Password authentication requested');
          return settings.password;
        },
        // Keyboard-interactive auth - required by many Linux SSH servers
        onUserInfoRequest: (request) {
          print('Keyboard-interactive auth requested: ${request.name}');
          // Return a list of responses (password for each prompt)
          return request.prompts.map((_) => settings.password).toList();
        },
        onAuthenticated: () {
          print('SSH authenticated successfully');
        },
      );

      // Wait for authentication to complete by running a simple command
      // This also validates that the connection is working
      await _client!.run('echo "connected"');
      
      return true;
    } catch (e) {
      _client?.close();
      _client = null;
      rethrow;
    }
  }

  /// Disconnect from LG master
  Future<void> disconnect() async {
    try {
      _client?.close();
    } catch (_) {
      // Ignore close errors
    }
    _client = null;
  }

  /// Execute a shell command on LG master
  /// Commands are wrapped in bash -c to support shell features like redirection
  Future<String> execute(String command) async {
    if (_client == null) {
      throw Exception('Not connected to LG. Please connect first.');
    }

    try {
      // Wrap in bash -c to ensure shell features (like >, >>, |) work
      // Escape single quotes in the command
      final escapedCommand = command.replaceAll("'", "'\\''");
      final result = await _client!.run("bash -c '$escapedCommand'");
      // Convert the result bytes to string
      final output = String.fromCharCodes(result);
      return output;
    } catch (e) {
      throw Exception('Failed to execute command: $e');
    }
  }

  /// Ensure a directory exists on remote server
  Future<void> ensureDirectoryExists(String directoryPath) async {
    if (_client == null) {
      throw Exception('Not connected to LG. Please connect first.');
    }
    // Use mkdir -p to create directory and all parents, ignore if exists
    await _client!.run('mkdir -p "$directoryPath"');
  }

  /// Upload a file to LG master using SSH commands (no SFTP needed)
  /// For binary files, uses base64 encoding
  Future<void> uploadFile(Uint8List data, String remotePath) async {
    if (_client == null) {
      throw Exception('Not connected to LG. Please connect first.');
    }

    try {
      // Extract directory path and ensure it exists
      final lastSlash = remotePath.lastIndexOf('/');
      if (lastSlash > 0) {
        final directoryPath = remotePath.substring(0, lastSlash);
        await ensureDirectoryExists(directoryPath);
      }

      // Convert to base64 and write using echo + base64 decode
      final base64Content = base64Encode(data);
      // Split into chunks to avoid command line length limits
      const chunkSize = 4096;
      
      // First, clear the file
      await _client!.run('echo -n "" > "$remotePath"');
      
      // Write in chunks
      for (var i = 0; i < base64Content.length; i += chunkSize) {
        final end = (i + chunkSize < base64Content.length) 
            ? i + chunkSize 
            : base64Content.length;
        final chunk = base64Content.substring(i, end);
        await _client!.run('echo -n "$chunk" >> "$remotePath.b64"');
      }
      
      // Decode base64 to final file
      await _client!.run('base64 -d "$remotePath.b64" > "$remotePath" && rm "$remotePath.b64"');
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  /// Upload string content as a file using base64 encoding
  /// This reliably handles all special characters including XML
  Future<void> uploadString(String content, String remotePath) async {
    // Convert string to bytes and use uploadFile which handles base64 encoding
    final Uint8List bytes = Uint8List.fromList(utf8.encode(content));
    await uploadFile(bytes, remotePath);
  }

  /// Send a query command to LG by writing directly to /tmp/query.txt
  /// This bypasses shell redirection issues by using uploadString
  Future<void> sendQuery(String queryContent) async {
    await uploadString(queryContent, '/tmp/query.txt');
  }

  /// Append content to a file (doesn't overwrite existing content)
  Future<void> appendToFile(String content, String remotePath) async {
    if (_client == null) {
      throw Exception('Not connected to LG. Please connect first.');
    }
    // Use base64 encoding to safely pass the content, then decode and append
    final base64Content = base64Encode(utf8.encode(content));
    await _client!.run('echo "$base64Content" | base64 -d >> "$remotePath"');
  }
}


