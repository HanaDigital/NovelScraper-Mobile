import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:novelscraper/main.dart';
import 'package:novelscraper/stores/database_store.dart';
import 'package:provider/provider.dart';

class NotificationController {
  /// Use this method to detect when a new notification or a schedule is created
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(ReceivedNotification receivedNotification) async {
    // Your code goes here
  }

  /// Use this method to detect every time that a new notification is displayed
  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(ReceivedNotification receivedNotification) async {
    // Your code goes here
  }

  /// Use this method to detect if the user dismissed a notification
  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(ReceivedAction receivedAction) async {
    // Your code goes here
  }

  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    switch (receivedAction.buttonKeyPressed) {
      case 'download_cancel':
        final provider = Provider.of<DatabaseStore>(MyApp.rootNavigatorKey.currentContext!, listen: false);
        final novel = provider.db.novels[receivedAction.payload?["novelURL"]];
        if (novel == null) return;
        provider.cancelDownload(novel);
        break;
    }

    // Navigate into pages, avoiding to open the notification details page over another details page already opened
    // MyApp.rootNavigatorKey.currentState?.pushNamedAndRemoveUntil(
    //     '/notification-page', (route) => (route.settings.name != '/notification-page') || route.isFirst,
    //     arguments: receivedAction);
  }
}
