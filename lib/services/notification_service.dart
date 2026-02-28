import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter_timezone/flutter_timezone.dart';
import '../models/loan_model.dart';
import '../core/constants/app_constants.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz_data.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (e) {
      debugPrint('NotificationService: Could not get local timezone: $e');
    }

    const androidSettings = AndroidInitializationSettings('launcher_icon');
    const initSettings = InitializationSettings(android: androidSettings);

    try {
      await _plugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationResponse,
      );

      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        // We don't await these to avoid blocking startup if the OS dialog hangs
        androidPlugin.requestNotificationsPermission();
        androidPlugin.requestExactAlarmsPermission();

        const androidChannel = AndroidNotificationChannel(
          AppConstants.notifChannelId,
          AppConstants.notifChannelName,
          description: AppConstants.notifChannelDesc,
          importance: Importance.high,
          playSound: true,
        );

        await androidPlugin.createNotificationChannel(androidChannel);
      }
    } catch (e) {
      debugPrint('NotificationService: Initialization error: $e');
    }
  }

  void _onNotificationResponse(NotificationResponse response) {}

  Future<void> scheduleLoanNotifications({
    required LoanModel loan,
    required String warningTitle,
    required String warningBody,
    required String dueTitle,
    required String dueBody,
  }) async {
    if (loan.id == null) return;
    await cancelLoanNotifications(loan.id!);

    final dueDate = loan.dueDate;
    final now = DateTime.now();

    final warningTime = dueDate.subtract(const Duration(hours: 24));
    if (warningTime.isAfter(now)) {
      await _scheduleNotification(
        id: loan.id! * 10 + 1,
        title: warningTitle,
        body: warningBody,
        scheduledDate: warningTime,
      );
    }

    if (dueDate.isAfter(now)) {
      await _scheduleNotification(
        id: loan.id! * 10 + 2,
        title: dueTitle,
        body: dueBody,
        scheduledDate: dueDate,
      );
    }
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    try {
      final tzDate = tz.TZDateTime.from(scheduledDate, tz.local);

      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tzDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            AppConstants.notifChannelId,
            AppConstants.notifChannelName,
            channelDescription: AppConstants.notifChannelDesc,
            importance: Importance.high,
            priority: Priority.high,
            icon: 'launcher_icon',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint(
          'NotificationService: Error scheduling notification ($id): $e');
    }
  }

  Future<void> cancelLoanNotifications(int loanId) async {
    await _plugin.cancel(loanId * 10 + 1);
    await _plugin.cancel(loanId * 10 + 2);
  }

  Future<void> showInstantNotification(String title, String body) async {
    await _plugin.show(
      999,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          AppConstants.notifChannelId,
          AppConstants.notifChannelName,
          importance: Importance.high,
          priority: Priority.high,
          icon: 'launcher_icon',
        ),
      ),
    );
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
