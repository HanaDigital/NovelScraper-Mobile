import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:novelscraper/components/bottom_navbar.dart';
import 'package:novelscraper/models/notification_controller.dart';
import 'package:novelscraper/models/novel_model.dart';
import 'package:novelscraper/stores/database_store.dart';
import 'package:novelscraper/theme.dart';
import 'package:provider/provider.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:workmanager/workmanager.dart';

final talker = TalkerFlutter.init();

@pragma('vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      switch (task) {
        case "download_novel":
          if (inputData == null) throw Exception("Input data is null");
          final novelStr = inputData["novel"];
          if (novelStr == null) throw Exception("Novel data is null");
          final novelJson = jsonDecode(novelStr);
          final novel = Novel.fromJson(novelJson);
          await novel.source.downloadNovel(novel, []);
          break;
      }
    } catch (e, st) {
      talker.handle(e, st, "Failed to execute task: $task");
      return Future.error(e);
    }
    return Future.value(true);
  });
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().initialize(
    callbackDispatcher, // The top level function, aka callbackDispatcher
    //isInDebugMode: true, // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
  );

  AwesomeNotifications().initialize(
    // set the icon to null if you want to use the default app icon
    // 'resource://drawable/res_app_icon',
    null,
    [
      NotificationChannel(
        channelGroupKey: 'download_channel_group',
        channelKey: 'download_channel',
        channelName: 'Download notifications',
        channelDescription: 'Notification channel for download progress',
        playSound: false,
        criticalAlerts: true,
      )
    ],
    // Channel groups are only visual and are not required
    channelGroups: [NotificationChannelGroup(channelGroupKey: 'basic_channel_group', channelGroupName: 'Basic group')],
    debug: true,
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  static final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  static final GlobalKey<NavigatorState> shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    // Only after at least the action method is set, the notification events are delivered
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: NotificationController.onActionReceivedMethod,
      onNotificationCreatedMethod: NotificationController.onNotificationCreatedMethod,
      onNotificationDisplayedMethod: NotificationController.onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: NotificationController.onDismissActionReceivedMethod,
    );

    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        // This is just a basic example. For real apps, you must show some
        // friendly dialog box before call the request method.
        // This is very important to not harm the user experience
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DatabaseStore(),
      child: MaterialApp.router(
        title: 'NovelScraper',
        theme: primaryTheme,
        routerConfig: bottomNavBarRouter,
      ),
    );
  }
}
