// ignore_for_file: file_names, depend_on_referenced_packages

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:io';
import 'package:news/cubits/NewsByIdCubit.dart';
import 'package:news/cubits/appLocalizationCubit.dart';
import 'package:news/cubits/settingCubit.dart';
import 'package:news/cubits/Auth/authCubit.dart';
import 'package:news/app/app.dart';
import 'package:news/app/routes.dart';
import 'package:news/utils/uiUtils.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
FirebaseMessaging messaging = FirebaseMessaging.instance;

backgroundMessage(NotificationResponse notificationResponse) {
  debugPrint('notification(${notificationResponse.id}) action tapped: ${notificationResponse.actionId} with payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    debugPrint('notification action tapped with input: ${notificationResponse.input}');
  }
  if (notificationResponse.payload!.isNotEmpty) debugPrint("payload is ${notificationResponse.payload}");
}

class PushNotificationService {
  late BuildContext context;

  PushNotificationService({required this.context});
  Future<dynamic> notificationHandler(RemoteMessage message) async {
    if (context.read<SettingsCubit>().state.settingsModel!.notification) {
      var data = message.data;
      var notif = message.notification;
      if (data['type'] == "default" || data['type'] == "category") {
        var title = data['title'].toString();
        var body = data['message'].toString();
        var image = data['image'];
        var payload = data["news_id"];
        var lanId = data["language_id"];

        if (lanId == context.read<AppLocalizationCubit>().state.id) {
          //show only if Current language is Same as Notification Language
          if (payload == null) {
            payload = "";
          } else {
            payload = payload;
          }
          (image != null && image != "") ? generateImageNotification(title, body, image, payload) : generateSimpleNotification(title, body, payload);
        }
      } else {
        //Direct Firebase Notification
        if (notif != null) {
          RemoteNotification notification = notif;
          String title = notif.title.toString();
          String msg = notif.body.toString();

          if (Platform.isIOS) {
            (notification.apple!.imageUrl != null) ? generateImageNotification(title, msg, notification.apple!.imageUrl!, 'item x') : generateSimpleNotification(title, msg, 'item x');
          }
          if (Platform.isAndroid) {
            (notification.android!.imageUrl != null) ? generateImageNotification(title, msg, notification.android!.imageUrl!, 'item x') : generateSimpleNotification(title, msg, 'item x');
          }
        }
      }
    }
  }

  Future initialise() async {
    messaging.getToken();
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('notification_icon'); //'@mipmap/ic_launcher'
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: false,
      requestSoundPermission: true,
    );
    //for android 13 - notification permission
    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestPermission();

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) {
        switch (notificationResponse.notificationResponseType) {
          case NotificationResponseType.selectedNotification:
            selectNotificationPayload(notificationResponse.payload!);
            break;
          case NotificationResponseType.selectedNotificationAction:
            debugPrint("notification-action-id--->${notificationResponse.actionId}==${notificationResponse.payload}");
            break;
        }
      },
      onDidReceiveBackgroundNotificationResponse: backgroundMessage,
    );

    _startForegroundService();
    FirebaseMessaging.onBackgroundMessage((message) => notificationHandler(message));
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      await notificationHandler(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      var data = message.data;
      if (data['type'] == "default" || data['type'] == "category") {
        var payload = data["news_id"];
        var lanId = data["language_id"];

        if (lanId == context.read<AppLocalizationCubit>().state.id) {
          //show only if Current language is Same as Notification Language
          if (payload == null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyApp()),
            );
          } else {
            context.read<NewsByIdCubit>().getNewsById(newsId: payload, langId: context.read<AppLocalizationCubit>().state.id, userId: context.read<AuthCubit>().getUserId()).then((value) {
              UiUtils.rootNavigatorKey.currentState!.pushNamed(Routes.newsDetails, arguments: {"model": value[0], "isFromBreak": false, "fromShowMore": false});
            });
          }
        }
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MyApp()),
        );
      }
    });
  }

  Future<void> _startForegroundService() async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('com.news.wrteam', 'news', channelDescription: 'your channel description', importance: Importance.max, priority: Priority.high, ticker: 'ticker');
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.startForegroundService(1, 'plain title', 'plain body', notificationDetails: androidNotificationDetails, payload: 'item x');
  }

  selectNotificationPayload(String? payload) async {
    if (payload != null && payload != "") {
      context.read<NewsByIdCubit>().getNewsById(newsId: payload, langId: context.read<AppLocalizationCubit>().state.id, userId: context.read<AuthCubit>().getUserId()).then((value) {
        UiUtils.rootNavigatorKey.currentState!.pushNamed(Routes.newsDetails, arguments: {"model": value[0], "isFromBreak": false, "fromShowMore": false});
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MyApp()),
      );
    }
  }
}

Future<String> _downloadAndSaveImage(String url, String fileName) async {
  if (url.isNotEmpty && url != "null") {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final Response response = await get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  } else {
    return "";
  }
}

Future<void> generateImageNotification(String title, String msg, String image, String type) async {
  var largeIconPath = await _downloadAndSaveImage(image, Platform.isAndroid ? 'largeIcon' : 'largeIcon.jpg');
  var bigPicturePath = await _downloadAndSaveImage(image, Platform.isAndroid ? 'bigPicture' : 'bigPicture.jpg');
  var bigPictureStyleInformation =
      BigPictureStyleInformation(FilePathAndroidBitmap(bigPicturePath), hideExpandedLargeIcon: true, contentTitle: title, htmlFormatContentTitle: true, summaryText: msg, htmlFormatSummaryText: true);
  var androidPlatformChannelSpecifics = AndroidNotificationDetails('big text channel id', 'big text channel name',
      channelDescription: 'big text channel description', largeIcon: FilePathAndroidBitmap(largeIconPath), styleInformation: bigPictureStyleInformation);
  final DarwinNotificationDetails darwinNotificationDetails =
      DarwinNotificationDetails(categoryIdentifier: "", presentAlert: true, presentSound: true, subtitle: msg, attachments: <DarwinNotificationAttachment>[
    DarwinNotificationAttachment(
      bigPicturePath,
      hideThumbnail: false,
    )
  ]);
  var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics, iOS: darwinNotificationDetails);
  await flutterLocalNotificationsPlugin.show(1, title, msg, platformChannelSpecifics, payload: type);
}

Future<void> generateSimpleNotification(String title, String msg, String type) async {
  var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
    'com.news.wrteam', //your package name
    'news',
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
  );
  DarwinNotificationDetails darwinNotificationDetails = DarwinNotificationDetails(categoryIdentifier: "", presentAlert: true, subtitle: msg, presentSound: true);
  var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics, iOS: darwinNotificationDetails);
  await flutterLocalNotificationsPlugin.show(1, title, msg, platformChannelSpecifics, payload: 'item x');
}
