///  Locally is In-App Messaging package, it extends the flutter_local_notification
/// It is created by Samuel Ezedi to help developers create notification and blots out the hassle of strenuous
/// initialization, you really wouldn't not have to write a lot of code anymore

/// I invite you to clone the repo and make contributions, Thanks.

/// Copyright 2020. All rights reserved.
/// Use of this source code is governed by a BSD-style license that can be
/// found in the LICENSE file.

library locally;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Imports flutter_local_notification, our dependency package
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Locally class created
class Locally {
  /// A String title for Notification
  late String title;

  /// A String message
  late String message;

  /// Payload for Navigation
  String payload;

  /// App Icon which is required on initialization
  String appIcon;

  /// Page Route which is also required on Initialization
  MaterialPageRoute pageRoute;

  /// A context is also required
  BuildContext context;

  /// IOS Parameters, this is currently not in use but will be implemented in future releases
  bool iosRequestSoundPermission;
  bool iosRequestBadgePermission;
  bool iosRequestAlertPermission;

  /// local notification initialization
  /// initializationSettingAndroid
  /// initializationSettingIos;
  /// initializationSetting;
  FlutterLocalNotificationsPlugin localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  var initializationSettingAndroid;
  var initializationSettingIos;
  var initializationSetting;

  /// Then we create a construct of Locally
  /// which required a context, pageRoute, appIcon and a payload
  /// It also received ios Parameters which are still in dev
  /// Within the construct,
  /// localNotification settings is initialized with Flutter Local Notification
  /// Setting declared above
  Locally({
    required this.context,
    required this.pageRoute,
    required this.appIcon,
    required this.payload,
    this.iosRequestSoundPermission = false,
    this.iosRequestBadgePermission = false,
    this.iosRequestAlertPermission = false,
  }) {
    /// initializationSettingAndroid declared above is assigned
    /// to AndroidInitializationSettings.
    initializationSettingAndroid = AndroidInitializationSettings(this.appIcon);

    /// initializationSettingIos declared above is assigned
    /// to IOSInitializationSettings.
    initializationSettingIos = IOSInitializationSettings(
        requestSoundPermission: iosRequestSoundPermission,
        requestBadgePermission: iosRequestBadgePermission,
        requestAlertPermission: iosRequestAlertPermission,
        onDidReceiveLocalNotification: onDidReceiveNotification);

    /// initializationSetting declared above is here assigned
    /// to InitializationSetting, which comes from flutter_local_notification
    /// package.
    initializationSetting = InitializationSettings(
        android: initializationSettingAndroid, iOS: initializationSettingIos);

    /// localNotificationPlugin is initialized here finally
    localNotificationsPlugin.initialize(initializationSetting,
        onSelectNotification: onSelectNotification);
  }

  /// requestPermission()
  /// for IOS developers only
  Future<bool?>? requestPermission() {
    return localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  /// onSelectNotification
  /// Obtains a string payload
  /// And perform navigation function
  Future<dynamic> onSelectNotification(String? payload) {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
    return Navigator.push(context, pageRoute);
  }

  /// onDidReceiveNotification
  /// it required for IOS initialization
  /// it takes in id, title, body and payload
  Future<dynamic> onDidReceiveNotification(
      int id, String? title, String? body, String? payload) {
    return showDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: title != null ? Text(title) : null,
        content: body != null ? Text(body) : null,
        actions: <Widget>[
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text('Ok'),
            onPressed: () async {
              await Navigator.push(context, pageRoute);
            },
          )
        ],
      ),
    );
  }

  /// The show Method return a notification to the screen
  /// it takes in a required title, message
  /// channel Name,
  /// channel ID,
  /// channel Description,
  /// importance,
  /// priority
  /// ticker
  Future show({
    int id = 0,
    required String title,
    required String message,
    String channelName = 'channel Name',
    String channelID = 'channelID',
    String channelDescription = 'channel Description',
    Importance importance = Importance.high,
    Priority priority = Priority.high,
    String ticker = 'test ticker',
  }) {
    this.title = title;
    this.message = message;

    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
        channelID, channelName, channelDescription,
        importance: importance, priority: priority, ticker: ticker);

    final iosPlatformChannelSpecifics = IOSNotificationDetails();

    final platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iosPlatformChannelSpecifics);

    return localNotificationsPlugin
        .show(id, title, message, platformChannelSpecifics, payload: payload);
  }

  /// The scheduleMethod return  a notification to the screen
  /// But with this you can schedule a messag to show at a given time
  /// it takes in a required title, message
  /// channel Name,
  /// channel ID,
  /// channel Description,
  /// importance,
  /// priority
  /// ticker
  /// and a Duration class
  Future<void> schedule({
    int id = 0,
    required String title,
    required String message,
    String channelName = 'channel Name',
    String channelID = 'channelID',
    String channelDescription = 'channel Description',
    Importance importance = Importance.high,
    Priority priority = Priority.high,
    String ticker = 'test ticker',
    required Duration duration,
    bool androidAllowWhileIdle = false,
  }) {
    final scheduledNotificationDateTime = DateTime.now().add(duration);

    final androidPlatformChannelSpecifics =
        AndroidNotificationDetails(channelID, channelName, channelDescription);
    final iOSPlatformChannelSpecifics = IOSNotificationDetails();
    final platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);
    return localNotificationsPlugin.schedule(id, title, message,
        scheduledNotificationDateTime, platformChannelSpecifics);
  }

  /// The showPeriodicallyd return  a notification to the screen
  /// But with this you can repeat a message to show at a given interval
  /// it takes in a required title, message
  /// channel Name,
  /// channel ID,
  /// channel Description,
  /// importance,
  /// priority
  /// ticker
  /// and a repeat interval
  Future<void> showPeriodically({
    int id = 0,
    required String title,
    required String message,
    String channelName = 'channel Name',
    String channelID = 'channelID',
    String channelDescription = 'channel Description',
    Importance importance = Importance.high,
    Priority priority = Priority.high,
    required RepeatInterval repeatInterval,
    String ticker = 'test ticker',
  }) {
    final androidPlatformChannelSpecifics =
        AndroidNotificationDetails(channelID, channelName, channelDescription);
    final iOSPlatformChannelSpecifics = IOSNotificationDetails();
    final platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);
    return localNotificationsPlugin.periodicallyShow(
        id, title, message, repeatInterval, platformChannelSpecifics);
  }

  /// The showDailyAtTime return a notification to the screen
  /// But with this you can decide to show a message at a given time in the day
  /// it takes in a required title, message
  /// channel Name,
  /// channel ID,
  /// channel Description,
  /// importance,
  /// priority
  /// ticker
  /// and a time
  Future<void> showDailyAtTime({
    int id = 0,
    required String title,
    required String message,
    String channelName = 'channel Name',
    String channelID = 'channelID',
    String channelDescription = 'channel Description',
    Importance importance = Importance.high,
    Priority priority = Priority.high,
    String ticker = 'test ticker',
    required Time time,
    bool suffixTime = false,
  }) {
    final androidPlatformChannelSpecifics =
        AndroidNotificationDetails(channelID, channelName, channelDescription);
    final iOSPlatformChannelSpecifics = IOSNotificationDetails();
    final platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);
    if (suffixTime) {
      return localNotificationsPlugin.showDailyAtTime(
          id,
          title,
          message +
              "${time.hour.toString()}:${time.minute.toString()}:${time.second.toString()}",
          time,
          platformChannelSpecifics);
    } else {
      return localNotificationsPlugin.showDailyAtTime(
          id, title, message, time, platformChannelSpecifics);
    }
  }

  /// The showWeeklyAtDayAndTime return a notification to the screen
  /// But with this you can decide to show a message at a given day of the week
  /// and at a given time
  /// it takes in a required title, message
  /// channel Name,
  /// channel ID,
  /// channel Description,
  /// importance,
  /// priority
  /// ticker
  /// and a time
  /// and Day
  Future showWeeklyAtDayAndTime({
    int id = 0,
    required String title,
    required String message,
    String channelName = 'channel Name',
    String channelID = 'channelID',
    String channelDescription = 'channel Description',
    Importance importance = Importance.high,
    Priority priority = Priority.high,
    String ticker = 'test ticker',
    required Time time,
    required Day day,
    bool suffixTime = false,
  }) {
    final androidPlatformChannelSpecifics =
        AndroidNotificationDetails(channelID, channelName, channelDescription);
    final iOSPlatformChannelSpecifics = IOSNotificationDetails();
    final platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);
    if (suffixTime) {
      return localNotificationsPlugin.showDailyAtTime(
          id,
          title,
          message +
              "${time.hour.toString()}:${time.minute.toString()}:${time.second.toString()}",
          time,
          platformChannelSpecifics);
    }

    return localNotificationsPlugin.showWeeklyAtDayAndTime(
        id, title, message, day, time, platformChannelSpecifics);
  }

  /// The retrievePendingNotifications return all pending
  /// notification to the screen
  ///
  Future<List<PendingNotificationRequest>> retrievePendingNotifications() {
    return localNotificationsPlugin.pendingNotificationRequests();
  }

  /// The cancel method as the name goes
  /// cancels a with a provided index id
  ///
  Future<void> cancel(int index) {
    if (index == null) {
      throw 'Error: index required';
    } else {
      return localNotificationsPlugin.cancel(index);
    }
  }

  /// The cancelAll method as the name goes
  /// cancels all pending notification
  ///
  Future<void> cancelAll() {
    return localNotificationsPlugin.cancelAll();
  }

  /// The getDetailsIfAppWasLaunchedViaNotification
  /// return details if the app was lauched by a notification
  /// payload
  ///
  Future<NotificationAppLaunchDetails?>
      getDetailsIfAppWasLaunchedViaNotification() {
    return localNotificationsPlugin.getNotificationAppLaunchDetails();
  }
}
