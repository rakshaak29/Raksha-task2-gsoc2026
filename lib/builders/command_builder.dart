import '../config/lg_configuration.dart';

/// Builds LG-specific shell commands
class CommandBuilder {
  /// Build FlyTo command using LookAt element
  /// Writes to /tmp/query.txt which LG monitors
  static String buildFlyToCommand({
    required double latitude,
    required double longitude,
    double altitude = LGConfiguration.defaultAltitude,
    double heading = LGConfiguration.defaultHeading,
    double tilt = LGConfiguration.defaultTilt,
    double range = LGConfiguration.defaultRange,
  }) {
    // Single-line format for reliable SSH execution
    final lookAt = 'flytoview=<LookAt><longitude>$longitude</longitude><latitude>$latitude</latitude><altitude>$altitude</altitude><heading>$heading</heading><tilt>$tilt</tilt><range>$range</range><altitudeMode>relativeToGround</altitudeMode></LookAt>';
    return 'echo "$lookAt" > ${LGConfiguration.queryFile}';
  }

  /// Build command to clear a slave's KML overlay
  static String buildClearSlaveKml(int slaveNumber) {
    return 'echo "" > ${LGConfiguration.getSlaveKmlPath(slaveNumber)}';
  }

  /// Build command to clear all slave KMLs
  static String buildClearAllSlaveKmls() {
    final commands = <String>[];
    for (int i = 1; i <= LGConfiguration.slaveCount; i++) {
      commands.add(buildClearSlaveKml(i));
    }
    return commands.join(' && ');
  }

  /// Build command to clear kmls.txt (removes loaded KMLs)
  static String buildClearKmlsFile() {
    return 'echo "" > ${LGConfiguration.kmlsFile}';
  }

  /// Build command to exit tour and reset
  static String buildExitTour() {
    return 'echo "exittour=true" > ${LGConfiguration.queryFile}';
  }

  /// Build command to add a KML to kmls.txt (legacy method)
  static String buildAddKmlToList(String kmlFilename) {
    final url = LGConfiguration.getKmlUrl(kmlFilename);
    return 'echo "$url" >> ${LGConfiguration.kmlsFile}';
  }

  /// Build command to load a KML using search= via query.txt
  /// This triggers Google Earth to load and display the KML
  static String buildLoadKmlCommand(String kmlFilename) {
    return 'echo "search=$kmlFilename" > ${LGConfiguration.queryFile}';
  }

  /// Build a ScreenOverlay KML for logo display
  static String buildScreenOverlayKml({
    required String name,
    required String imageUrl,
    double overlayX = 0,
    double overlayY = 1,
    double screenX = 0.02,
    double screenY = 0.95,
    double sizeX = 0.2,
  }) {
    return '''<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
<Document>
  <name>$name</name>
  <ScreenOverlay>
    <name>$name</name>
    <Icon>
      <href>$imageUrl</href>
    </Icon>
    <overlayXY x="$overlayX" y="$overlayY" xunits="fraction" yunits="fraction"/>
    <screenXY x="$screenX" y="$screenY" xunits="fraction" yunits="fraction"/>
    <size x="$sizeX" y="0" xunits="fraction" yunits="fraction"/>
  </ScreenOverlay>
</Document>
</kml>''';
  }
}
