/// SSH connection settings model
class ConnectionSettings {
  final String host;
  final int port;
  final String username;
  final String password;

  const ConnectionSettings({
    required this.host,
    required this.port,
    required this.username,
    required this.password,
  });

  /// Default settings for your LG rig
  factory ConnectionSettings.defaultSettings() {
    return const ConnectionSettings(
      host: '192.168.239.3',
      port: 22,
      username: 'lg',
      password: 'Sahanakb2!',
    );
  }

  /// Create from JSON map
  factory ConnectionSettings.fromJson(Map<String, dynamic> json) {
    return ConnectionSettings(
      host: json['host'] as String,
      port: json['port'] as int,
      username: json['username'] as String,
      password: json['password'] as String,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'host': host,
      'port': port,
      'username': username,
      'password': password,
    };
  }

  /// Copy with modifications
  ConnectionSettings copyWith({
    String? host,
    int? port,
    String? username,
    String? password,
  }) {
    return ConnectionSettings(
      host: host ?? this.host,
      port: port ?? this.port,
      username: username ?? this.username,
      password: password ?? this.password,
    );
  }
}
