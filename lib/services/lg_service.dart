import '../config/connection_settings.dart';
import '../config/lg_configuration.dart';
import '../builders/command_builder.dart';
import '../managers/logo_manager.dart';
import '../managers/kml_manager.dart';
import 'ssh_service.dart';

class LGService {
  final SSHService _sshService;
  late final LogoManager _logoManager;
  late final KMLManager _kmlManager;

  bool get isConnected => _sshService.isConnected;

  LGService() : _sshService = SSHService() {
    _logoManager = LogoManager(_sshService);
    _kmlManager = KMLManager(_sshService);
  }


  Future<bool> connect(ConnectionSettings settings) async {
    return await _sshService.connect(settings);
  }

  Future<void> disconnect() async {
    await _sshService.disconnect();
  }

  Future<bool> testConnection() async {
    try {
      await _sshService.execute('echo "test"');
      return true;
    } catch (e) {
      return false;
    }
  }

  
  Future<void> showLogoOnLeftScreen() async {
    await _logoManager.showLogoOnLeftScreen();
  }

 

  /// Send the 3D colored pyramid KML to LG
  Future<void> sendPyramidKml() async {
    await _kmlManager.sendPyramidKml();
  }


  /// Navigate to Bangalore with smooth camera movement
  Future<void> flyToHomeCity() async {
    await flyTo(
      latitude: LGConfiguration.homeLat,
      longitude: LGConfiguration.homeLng,
      range: LGConfiguration.defaultRange,
      tilt: LGConfiguration.defaultTilt,
    );
  }

  /// Navigate to any coordinates
  Future<void> flyTo({
    required double latitude,
    required double longitude,
    double altitude = 0,
    double heading = 0,
    double tilt = 60,
    double range = 25000,
  }) async {
    final command = CommandBuilder.buildFlyToCommand(
      latitude: latitude,
      longitude: longitude,
      altitude: altitude,
      heading: heading,
      tilt: tilt,
      range: range,
    );
    await _sshService.execute(command);
  }


  /// Clear logos from all slave screens
  Future<void> clearAllLogos() async {
    await _logoManager.clearAllLogos();
  }


  /// Clear all loaded KML files and exit any tours
  Future<void> clearAllKmls() async {
    await _kmlManager.clearAllKmls();
  }


  /// Clear everything (logos + KMLs)
  Future<void> clearAll() async {
    await clearAllLogos();
    await clearAllKmls();
  }
}
