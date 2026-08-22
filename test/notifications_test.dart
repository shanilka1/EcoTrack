import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecotrack/features/home/widgets/dashboard_header.dart';
import 'package:ecotrack/features/notifications/models/notification_model.dart';
import 'package:ecotrack/features/notifications/screens/notifications_screen.dart';

void main() {
  final sampleNotifications = [
    NotificationModel(
      id: 'notif-1',
      userId: 'user-123',
      title: 'Activity Logged: Tree Planting',
      message: 'Great job! You earned +30 eco points.',
      type: NotificationType.activityCompleted,
      relatedId: 'act-1',
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    NotificationModel(
      id: 'notif-2',
      userId: 'user-123',
      title: 'Challenge Completed: Zero Waste Week',
      message: 'Congratulations! You completed the challenge.',
      type: NotificationType.challengeCompleted,
      relatedId: 'chal-1',
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    NotificationModel(
      id: 'notif-3',
      userId: 'user-123',
      title: 'Badge Unlocked: Early Bird',
      message: 'You earned the Early Bird badge.',
      type: NotificationType.achievementUnlocked,
      relatedId: 'ach-1',
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  group('NotificationModel Serialization Tests', () {
    test('Converts correctly to and from Firestore map', () {
      final notif = NotificationModel(
        id: 'notif-99',
        userId: 'user-99',
        title: 'Level Up!',
        message: 'Reached Level 5',
        type: NotificationType.levelUp,
        isRead: false,
        createdAt: DateTime(2026, 8, 22, 10, 0),
      );

      final map = notif.toMap();
      final reconstructed = NotificationModel.fromMap(map, documentId: 'notif-99');

      expect(reconstructed.id, 'notif-99');
      expect(reconstructed.userId, 'user-99');
      expect(reconstructed.title, 'Level Up!');
      expect(reconstructed.message, 'Reached Level 5');
      expect(reconstructed.type, NotificationType.levelUp);
      expect(reconstructed.isRead, isFalse);
    });
  });

  group('NotificationsScreen Widget Tests', () {
    testWidgets('Renders real notifications with read/unread states',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: NotificationsScreen(
            initialNotifications: sampleNotifications,
          ),
        ),
      );

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Activity Logged: Tree Planting'), findsOneWidget);
      expect(find.text('Challenge Completed: Zero Waste Week'), findsOneWidget);
      expect(find.text('Badge Unlocked: Early Bird'), findsOneWidget);

      // Unread action icon (mark all as read)
      expect(find.byIcon(Icons.done_all_rounded), findsOneWidget);
    });

    testWidgets('Renders clean empty state when no notifications exist',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: NotificationsScreen(initialNotifications: []),
        ),
      );

      expect(find.text('No Notifications Yet'), findsOneWidget);
      expect(
        find.text(
          'When you complete activities, achieve milestones, or earn new badges, you will see your updates here.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('Renders with 0 overflow on small mobile (320x568)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: NotificationsScreen(
            initialNotifications: sampleNotifications,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('Renders with 0 overflow on tablet (800x1280)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1280);
      tester.view.devicePixelRatio = 1.0;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: NotificationsScreen(
            initialNotifications: sampleNotifications,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  group('DashboardHeader Notification Bell Badge Tests', () {
    testWidgets('Renders unread badge count when unread count > 0',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DashboardHeader(
              fullName: 'Alex River',
              unreadNotificationsCount: 3,
              onLogout: () {},
            ),
          ),
        ),
      );

      expect(find.text('3'), findsOneWidget);
      expect(find.byIcon(Icons.notifications_active_rounded), findsOneWidget);
    });

    testWidgets('Hides badge when unread count is 0',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DashboardHeader(
              fullName: 'Alex River',
              unreadNotificationsCount: 0,
              onLogout: () {},
            ),
          ),
        ),
      );

      expect(find.text('0'), findsNothing);
      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
    });
  });
}
