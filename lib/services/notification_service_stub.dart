/// No-op fallback used whenever the app isn't compiled for the web
/// (native builds, and the `flutter test` VM runner). Real behavior
/// lives in notification_service_web.dart.
class NotificationService {
  static bool get isSupported => false;
  static String get permission => 'denied';
  static Future<String> requestPermission() async => 'denied';
  static void show(String title, String body) {}
}
