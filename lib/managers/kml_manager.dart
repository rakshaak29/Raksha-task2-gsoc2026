import 'package:flutter/services.dart';
import '../config/lg_configuration.dart';
import '../services/ssh_service.dart';

/// Manages 3D KML content on Liquid Galaxy
class KMLManager {
  final SSHService _sshService;
  
  static const String _pyramidFilename = 'pyramid.kml';
  static const String _pyramidAssetPath = 'assets/kml/pyramid.kml';

  KMLManager(this._sshService);

  /// Upload and display the 3D pyramid KML
  Future<void> sendPyramidKml() async {
    // Load KML from assets
    final String kmlContent = await rootBundle.loadString(_pyramidAssetPath);

    // Upload to LG kml directory
    final remotePath = '${LGConfiguration.kmlPath}/$_pyramidFilename';
    await _sshService.uploadString(kmlContent, remotePath);

    // Add KML URL to kmls_1.txt - APPEND to preserve existing KMLs
    final kmlUrl = LGConfiguration.getKmlUrl(_pyramidFilename);
    await _sshService.appendToFile('$kmlUrl\n', LGConfiguration.kmlsFile);

    // Wait for sync system to load the KML, then fly to Bangalore
    await Future.delayed(const Duration(milliseconds: 2000));
    
    // Build FlyTo content and send to query.txt
    final flyToContent = 'flytoview=<LookAt><longitude>${LGConfiguration.homeLng}</longitude><latitude>${LGConfiguration.homeLat}</latitude><altitude>0</altitude><heading>0</heading><tilt>60</tilt><range>5000</range><altitudeMode>relativeToGround</altitudeMode></LookAt>';
    await _sshService.sendQuery(flyToContent);
  }

  /// Upload and display a custom KML string
  Future<void> sendCustomKml(String kmlContent, String filename) async {
    final remotePath = '${LGConfiguration.kmlPath}/$filename';
    await _sshService.uploadString(kmlContent, remotePath);

    // Add KML URL to kmls_1.txt - APPEND to preserve existing KMLs
    final kmlUrl = LGConfiguration.getKmlUrl(filename);
    await _sshService.appendToFile('$kmlUrl\n', LGConfiguration.kmlsFile);
  }

  /// Clear all loaded KML files
  Future<void> clearAllKmls() async {
    // Clear kmls_1.txt to remove all loaded KMLs
    await _sshService.uploadString('', LGConfiguration.kmlsFile);

    // Delete the pyramid KML file from the server
    await _sshService.execute('rm -f ${LGConfiguration.kmlPath}/$_pyramidFilename');

    // Send exit tour command
    await _sshService.sendQuery('exittour=true');
  }
}



