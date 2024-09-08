import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  static const int maxRetries = 3; // Batas maksimum percobaan retry

  // Memeriksa dan meminta izin kamera
  static Future<bool> requestCameraPermission() async {
    PermissionStatus status = await Permission.camera.status;

    // Jika izin belum diberikan, minta izin
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }

    return status.isGranted;
  }
}
