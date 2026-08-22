import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecotrack/core/routes/app_routes.dart';
import 'package:ecotrack/features/activities/models/eco_activity_model.dart';
import 'package:ecotrack/features/activities/screens/activities_screen.dart';
import 'package:ecotrack/features/activities/screens/activity_details_screen.dart';
import 'package:ecotrack/features/admin/models/admin_dashboard_stats_model.dart';
import 'package:ecotrack/features/admin/models/announcement_model.dart';
import 'package:ecotrack/features/admin/screens/admin_dashboard_screen.dart';
import 'package:ecotrack/features/admin/screens/manage_activities_screen.dart';
import 'package:ecotrack/features/admin/screens/manage_announcements_screen.dart';
import 'package:ecotrack/features/admin/screens/manage_challenges_screen.dart';
import 'package:ecotrack/features/admin/screens/manage_users_screen.dart';
import 'package:ecotrack/features/auth/models/user_model.dart';
import 'package:ecotrack/features/auth/screens/login_screen.dart';
import 'package:ecotrack/features/auth/screens/register_screen.dart';
import 'package:ecotrack/features/challenges/models/challenge_model.dart';
import 'package:ecotrack/features/challenges/models/challenge_progress_model.dart';
import 'package:ecotrack/features/challenges/screens/challenge_details_screen.dart';
import 'package:ecotrack/features/challenges/screens/challenges_screen.dart';
import 'package:ecotrack/features/home/screens/home_screen.dart';
import 'package:ecotrack/features/leaderboard/models/leaderboard_user_model.dart';
import 'package:ecotrack/features/leaderboard/screens/leaderboard_screen.dart';
import 'package:ecotrack/features/notifications/models/notification_model.dart';
import 'package:ecotrack/features/notifications/screens/notifications_screen.dart';
import 'package:ecotrack/features/onboarding/screens/onboarding_screen.dart';
import 'package:ecotrack/features/profile/screens/change_password_screen.dart';
import 'package:ecotrack/features/profile/screens/edit_profile_screen.dart';
import 'package:ecotrack/features/profile/screens/legal_info_screen.dart';
import 'package:ecotrack/features/profile/screens/profile_screen.dart';
import 'package:ecotrack/features/profile/screens/settings_screen.dart';
import 'package:ecotrack/features/progress/models/user_statistics_model.dart';
import 'package:ecotrack/features/progress/screens/progress_screen.dart';
import 'package:ecotrack/features/rewards/models/achievement_model.dart';
import 'package:ecotrack/features/rewards/screens/achievements_screen.dart';
import 'package:ecotrack/features/splash/screens/splash_screen.dart';

void main() {
  final sampleUser = UserModel(
    uid: 'user-e2e-1',
    fullName: 'Alex Green',
    email: 'alex@example.com',
    ecoPoints: 340,
    level: 3,
    role: 'user',
    createdAt: DateTime(2026, 1, 1),
  );

  final sampleAdminUser = UserModel(
    uid: 'admin-e2e-1',
    fullName: 'Admin Chief',
    email: 'admin@ecotrack.org',
    ecoPoints: 1200,
    level: 6,
    role: 'admin',
    createdAt: DateTime(2026, 1, 1),
  );

  final sampleActivity = EcoActivityModel(
    id: 'act-e2e-1',
    title: 'Compost Kitchen Food Scraps',
    description: 'Collect peels and vegetables in your green bin.',
    category: 'Waste',
    points: 25,
    environmentalBenefit: 'Prevents landfill methane',
    isActive: true,
    createdAt: DateTime(2026, 1, 1),
  );

  final sampleChallenge = ChallengeModel(
    id: 'chal-e2e-1',
    title: 'Zero Waste Marathon',
    description: 'Log 5 waste reduction habits this week.',
    type: 'category_activity',
    targetCategory: 'Waste',
    target: 5,
    rewardPoints: 100,
    startDate: DateTime.now().subtract(const Duration(days: 2)),
    endDate: DateTime.now().add(const Duration(days: 5)),
    isActive: true,
    createdAt: DateTime.now(),
  );

  final sampleProgress = UserChallengeProgressModel(
    challengeId: 'chal-e2e-1',
    userId: 'user-e2e-1',
    progress: 3,
    target: 5,
    status: 'in_progress',
    startedAt: DateTime.now(),
  );

  final sampleAchievement = AchievementModel(
    id: 'ach-e2e-1',
    title: 'Compost Master',
    description: 'Complete 10 waste activities.',
    requirementType: 'category_activity_count',
    requirementValue: 10,
    isActive: true,
    createdAt: DateTime(2026, 1, 1),
  );

  final sampleNotification = NotificationModel(
    id: 'notif-e2e-1',
    userId: 'user-e2e-1',
    title: 'Points Earned!',
    message: 'You earned +25 Eco Points for Composting!',
    type: NotificationType.pointsAwarded,
    createdAt: DateTime.now(),
    isRead: false,
  );

  final sampleLeaderboard = [
    LeaderboardUserModel(
      uid: 'user-e2e-1',
      fullName: 'Alex Green',
      ecoPoints: 340,
      level: 3,
      rank: 1,
    ),
  ];

  final sampleStats = const AdminDashboardStatsModel(
    totalUsers: 142,
    totalActivities: 28,
    activeChallenges: 6,
    totalAchievements: 14,
    totalAnnouncements: 3,
  );

  final sampleUserStats = const UserStatisticsModel(
    totalEcoPoints: 340,
    level: 3,
    totalActivitiesCompleted: 12,
    completedChallengesCount: 2,
    unlockedAchievementsCount: 3,
    weeklyDailyCounts: {'Mon': 1, 'Tue': 2, 'Wed': 3, 'Thu': 2, 'Fri': 4, 'Sat': 3, 'Sun': 5},
    weeklyDailyPoints: {'Mon': 25, 'Tue': 50, 'Wed': 75, 'Thu': 50, 'Fri': 100, 'Sat': 75, 'Sun': 125},
    categoryCounts: {'Waste': 7, 'Nature': 5},
    categoryPercentages: {'Waste': 0.58, 'Nature': 0.42},
    monthlyCounts: {'Aug 2026': 12},
  );

  final sampleAnnouncement = AnnouncementModel(
    id: 'ann-e2e-1',
    title: 'Spring Tree Planting Festival',
    message: 'Join us this Saturday in planting 500 indigenous trees.',
    targetAudience: 'all',
    isActive: true,
    createdAt: DateTime.now(),
    createdBy: 'admin-e2e-1',
  );

  group('Full Application Navigation & Screen Integration Tests', () {
    testWidgets('1. Splash Screen renders properly', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SplashScreen(autoNavigate: false)));
      await tester.pump(const Duration(milliseconds: 700));
      expect(find.text('EcoTrack'), findsOneWidget);
    });

    testWidgets('2. Onboarding Screen renders Page 1 with branding', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: OnboardingScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Track Your Habits'), findsOneWidget);
    });

    testWidgets('3. Login Screen renders with email and password inputs', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Sign In'), findsWidgets);
    });

    testWidgets('4. Register Screen renders with full fields', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Create Account'), findsWidgets);
    });

    testWidgets('5. Home Dashboard renders authenticated user data and summary cards', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(initialUser: sampleUser),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Alex Green'), findsOneWidget);
      expect(find.text('340'), findsOneWidget);
      expect(find.text('Eco Enthusiast'), findsOneWidget);
    });

    testWidgets('6. Eco Activities list and details flow renders', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ActivitiesScreen(initialActivities: [sampleActivity]),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Compost Kitchen Food Scraps'), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          home: ActivityDetailsScreen(initialActivity: sampleActivity),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Activity Details'), findsOneWidget);
      expect(find.text('+25 pts'), findsOneWidget);
    });

    testWidgets('7. Challenges list and details flow renders', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChallengesScreen(
            initialChallenges: [sampleChallenge],
            initialProgressMap: {sampleChallenge.id: sampleProgress},
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Zero Waste Marathon'), findsWidgets);

      await tester.pumpWidget(
        MaterialApp(
          home: ChallengeDetailsScreen(
            initialChallenge: sampleChallenge,
            initialProgress: sampleProgress,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Zero Waste Marathon'), findsWidgets);
      expect(find.text('+100 pts'), findsOneWidget);
    });

    testWidgets('8. Achievements Screen renders badge list', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AchievementsScreen(
            initialAchievements: [sampleAchievement],
            initialUnlockedMap: const {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Compost Master'), findsOneWidget);
    });

    testWidgets('9. Leaderboard Screen renders rankings', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LeaderboardScreen(
            initialUsers: sampleLeaderboard,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Leaderboard'), findsOneWidget);
      expect(find.text('Alex Green'), findsWidgets);
    });

    testWidgets('10. Progress Screen renders KPI overview cards and statistics', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProgressScreen(
            initialStats: sampleUserStats,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('My Progress'), findsOneWidget);
      expect(find.text('340'), findsOneWidget);
    });

    testWidgets('11. Profile, Edit Profile, and Settings screens render', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProfileScreen(
            initialUser: sampleUser,
            initialStats: sampleUserStats,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Alex Green'), findsOneWidget);
      expect(find.text('alex@example.com'), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          home: EditProfileScreen(initialUser: sampleUser),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Edit Profile'), findsOneWidget);

      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsOneWidget);

      await tester.pumpWidget(
        const MaterialApp(
          home: ChangePasswordScreen(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Change Password'), findsOneWidget);

      await tester.pumpWidget(
        const MaterialApp(
          home: LegalInfoScreen(
            title: 'Privacy Policy',
            content: 'Your privacy is paramount at EcoTrack.',
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Privacy Policy'), findsWidgets);
    });

    testWidgets('12. Notifications Screen renders unread items', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: NotificationsScreen(
            initialNotifications: [sampleNotification],
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Points Earned!'), findsOneWidget);
    });

    testWidgets('13. Admin Dashboard and Management Consoles render for Admin user', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AdminDashboardScreen(
            initialStats: sampleStats,
            isVerifiedAdmin: true,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Admin Console'), findsOneWidget);
      expect(find.text('142'), findsOneWidget); // Total Users
      expect(find.text('28'), findsOneWidget); // Total Activities

      // Manage Activities Console
      await tester.pumpWidget(
        MaterialApp(
          home: ManageActivitiesScreen(
            initialActivities: [sampleActivity],
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Manage Activities'), findsOneWidget);
      expect(find.text('Compost Kitchen Food Scraps'), findsOneWidget);

      // Manage Challenges Console
      await tester.pumpWidget(
        MaterialApp(
          home: ManageChallengesScreen(
            initialChallenges: [sampleChallenge],
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Manage Challenges'), findsOneWidget);

      // Manage Users Console
      await tester.pumpWidget(
        MaterialApp(
          home: ManageUsersScreen(
            initialUsers: [sampleUser, sampleAdminUser],
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('User Directory'), findsOneWidget);
      expect(find.text('Alex Green'), findsOneWidget);
      expect(find.text('Admin Chief'), findsOneWidget);

      // Manage Announcements Console
      await tester.pumpWidget(
        MaterialApp(
          home: ManageAnnouncementsScreen(
            initialAnnouncements: [sampleAnnouncement],
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('System Announcements'), findsOneWidget);
      expect(find.text('Spring Tree Planting Festival'), findsOneWidget);
    });
  });

  group('Route Registry Completeness Tests', () {
    test('All required AppRoutes constants exist and map correctly', () {
      expect(AppRoutes.splash, '/');
      expect(AppRoutes.onboarding, '/onboarding');
      expect(AppRoutes.login, '/login');
      expect(AppRoutes.register, '/register');
      expect(AppRoutes.home, '/home');
      expect(AppRoutes.activities, '/activities');
      expect(AppRoutes.activityDetails, '/activities/details');
      expect(AppRoutes.challenges, '/challenges');
      expect(AppRoutes.challengeDetails, '/challenges/details');
      expect(AppRoutes.rewards, '/rewards');
      expect(AppRoutes.leaderboard, '/leaderboard');
      expect(AppRoutes.progress, '/progress');
      expect(AppRoutes.profile, '/profile');
      expect(AppRoutes.editProfile, '/profile/edit');
      expect(AppRoutes.settings, '/settings');
      expect(AppRoutes.changePassword, '/profile/change-password');
      expect(AppRoutes.notifications, '/notifications');
      expect(AppRoutes.adminDashboard, '/admin');
      expect(AppRoutes.adminActivities, '/admin/activities');
      expect(AppRoutes.adminChallenges, '/admin/challenges');
      expect(AppRoutes.adminAchievements, '/admin/achievements');
      expect(AppRoutes.adminUsers, '/admin/users');
      expect(AppRoutes.adminAnnouncements, '/admin/announcements');
    });
  });
}
