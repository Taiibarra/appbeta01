// ignore: deprecated_member_use
import 'dart:html' as html;

/// Thin wrapper over the browser's Notification API. This can only ever
/// fire while a tab (or the installed PWA) is actually open and running —
/// browsers don't let a plain web app wake up in the background without
/// a push server, so this is a best-effort nudge, not a guaranteed alarm.
class NotificationService {
  static bool get isSupported => html.Notification.supported;

  static String get permission =>
      isSupported ? (html.Notification.permission ?? 'default') : 'denied';

  static Future<String> requestPermission() async {
    if (!isSupported) return 'denied';
    return html.Notification.requestPermission();
  }

  static void show(String title, String body) {
    if (!isSupported) return;
    if (html.Notification.permission != 'granted') return;
    html.Notification(title, body: body);
  }
}
