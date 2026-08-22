import 'package:flutter/material.dart';
import '../../features/activities/models/eco_activity_model.dart';
import '../../features/activities/screens/activities_screen.dart';
import '../../features/activities/screens/activity_details_screen.dart';
import '../../features/auth/models/user_model.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/splash/screens/splash_screen.dart';

/// Centralized route definitions and route generator for navigation
class AppRoutes {
  AppRoutes._();

  // Route Names
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String activities = '/activities';
  static const String activityDetails = '/activities/details';
  static const String challenges = '/challenges';
  static const String leaderboard = '/leaderboard';
  static const String rewards = '/rewards';
  static const String profile = '/profile';

  /// Generates routes dynamically based on RouteSettings
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(autoNavigate: true),
          settings: settings,
        );

      case onboarding:
        return MaterialPageRoute(
          builder: (_) => const OnboardingScreen(),
          settings: settings,
        );

      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );

      case register:
        return MaterialPageRoute(
          builder: (_) => const RegisterScreen(),
          settings: settings,
        );

      case home:
        final user = settings.arguments is UserModel
            ? settings.arguments as UserModel
            : null;
        return MaterialPageRoute(
          builder: (_) => HomeScreen(initialUser: user),
          settings: settings,
        );

      case activities:
        return MaterialPageRoute(
          builder: (_) => const ActivitiesScreen(),
          settings: settings,
        );

      case activityDetails:
        if (settings.arguments is EcoActivityModel) {
          return MaterialPageRoute(
            builder: (_) => ActivityDetailsScreen(
              initialActivity: settings.arguments as EcoActivityModel,
            ),
            settings: settings,
          );
        } else if (settings.arguments is String) {
          return MaterialPageRoute(
            builder: (_) => ActivityDetailsScreen(
              activityId: settings.arguments as String,
            ),
            settings: settings,
          );
        }
        return MaterialPageRoute(
          builder: (_) => const ActivityDetailsScreen(),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
          settings: settings,
        );
    }
  }
}
