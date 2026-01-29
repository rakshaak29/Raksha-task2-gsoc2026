/// Liquid Galaxy rig configuration constants
class LGConfiguration {
  // Screen/Slave configuration for 3-screen rig
  // Based on actual LG setup: Left=LG3, Center=LG1, Right=LG2
  static const int slaveCount = 3;
  static const int leftScreen = 3;   // slave_3 - left screen, for logo
  static const int centerScreen = 1; // master_1 - center/main view
  static const int rightScreen = 2;  // slave_2 - right screen

  // LG Master paths
  static const String kmlPath = '/var/www/html/kml';
  static const String imagePath = '/var/www/html/images';
  static const String queryFile = '/tmp/query.txt';
  
  // KMLs files for each screen - sync system reads these
  static const String kmlsFile = '/var/www/html/kmls_1.txt'; // Center screen
  
  /// Get kmls file path for a specific screen
  static String getKmlsFileForScreen(int screenNumber) {
    return '/var/www/html/kmls_$screenNumber.txt';
  }

  // Web server URL - LG uses port 81 and lg1 hostname
  static const String masterHostname = 'lg1';
  static const int webPort = 81;
  
  /// Get URL for a KML file on LG server
  static String getKmlUrl(String filename) {
    return 'http://$masterHostname:$webPort/kml/$filename';
  }

  /// Get URL for an image on LG server
  static String getImageUrl(String filename) {
    return 'http://$masterHostname:$webPort/images/$filename';
  }

  /// Get slave KML file path
  static String getSlaveKmlPath(int slaveNumber) {
    return '$kmlPath/slave_$slaveNumber.kml';
  }

  // SSH Connection defaults
  static const String defaultIp = '192.168.239.3';
  static const String defaultUsername = 'lg';
  static const String defaultPassword = 'Sahanakb2!';
  static const int defaultPort = 22;

  // Bangalore coordinates (home city)
  static const double homeLat = 12.9716;
  static const double homeLng = 77.5946;
  static const String homeCity = 'Bangalore';

  // FlyTo defaults
  static const double defaultAltitude = 0;
  static const double defaultHeading = 0;
  static const double defaultTilt = 60;
  static const double defaultRange = 25000;
}


