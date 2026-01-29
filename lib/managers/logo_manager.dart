import 'package:flutter/services.dart';
import '../config/lg_configuration.dart';
import '../builders/command_builder.dart';
import '../services/ssh_service.dart';

/// Manages logo display on LG screens using ScreenOverlay KML
class LogoManager {
  final SSHService _sshService;
  
  static const String _logoFilename = 'lg_logo.png';
  static const String _logoAssetPath = 'assets/images/lg_logo.png';
  static const String _logoKmlFilename = 'logo_overlay.kml';

  LogoManager(this._sshService);

  /// Upload logo image to LG master server
  Future<void> uploadLogo() async {
    // Load logo from assets
    final ByteData data = await rootBundle.load(_logoAssetPath);
    final Uint8List bytes = data.buffer.asUint8List();

    // Upload to LG image directory
    final remotePath = '${LGConfiguration.imagePath}/$_logoFilename';
    await _sshService.uploadFile(bytes, remotePath);
  }

  /// Set up NetworkLink on left screen (LG3) to enable sync system
  Future<void> _setupLeftScreenNetworkLink() async {
    // Create master_3.kml on LG1
    final masterKml = '''<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
<Document id="master_3">
</Document>
</kml>''';
    await _sshService.uploadString(masterKml, '${LGConfiguration.kmlPath}/master_3.kml');

    // Create NetworkLink KML that LG3 will load to connect to the sync system
    final networkLinkKml = '''<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
<Folder>
  <name>Sync</name>
  <NetworkLink>
    <name>Slave 3 Sync</name>
    <flyToView>0</flyToView>
    <Link>
      <href>http://lg1:81/sync_nlc_3.php</href>
      <refreshMode>onInterval</refreshMode>
      <refreshInterval>1</refreshInterval>
    </Link>
  </NetworkLink>
</Folder>
</kml>''';
    
    // Save NetworkLink KML to LG1's web directory
    await _sshService.uploadString(networkLinkKml, '${LGConfiguration.kmlPath}/sync_slave_3.kml');

    // SSH to LG3 and load this NetworkLink into Google Earth's myplaces
    // Copy the sync KML to LG3's .googleearth folder
    await _sshService.execute(
      'sshpass -p "lg" ssh -o StrictHostKeyChecking=no lg@lg3 '
      '"mkdir -p ~/.googleearth && '
      'wget -q -O ~/.googleearth/sync_slave_3.kml http://lg1:81/kml/sync_slave_3.kml"'
    );
  }

  /// Show logo on the LEFT screen (LG3)
  /// LG3's Google Earth watches slave_3.kml every 2 seconds
  Future<void> showLogoOnLeftScreen() async {
    // Upload the logo image
    await uploadLogo();

    // Build ScreenOverlay KML for logo
    final imageUrl = LGConfiguration.getImageUrl(_logoFilename);
    final kmlContent = CommandBuilder.buildScreenOverlayKml(
      name: 'LG Logo',
      imageUrl: imageUrl,
      screenX: 0.02,
      screenY: 0.95,
      sizeX: 0.25,
    );

    // Write directly to slave_3.kml - LG3 watches this file every 2 seconds!
    final slavePath = LGConfiguration.getSlaveKmlPath(LGConfiguration.leftScreen);
    await _sshService.uploadString(kmlContent, slavePath);
  }

  /// Clear logo from a specific screen
  Future<void> clearLogoFromScreen(int slaveNumber) async {
    await _sshService.uploadString('', LGConfiguration.getSlaveKmlPath(slaveNumber));
  }

  /// Clear logos from all screens
  Future<void> clearAllLogos() async {
    // Write empty KML to all slave files
    const emptyKml = '<?xml version="1.0" encoding="UTF-8"?><kml xmlns="http://www.opengis.net/kml/2.2"><Document></Document></kml>';
    for (int i = 1; i <= LGConfiguration.slaveCount; i++) {
      await _sshService.uploadString(emptyKml, LGConfiguration.getSlaveKmlPath(i));
    }
  }
}






