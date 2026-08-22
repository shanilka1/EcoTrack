import 'package:flutter/material.dart';
import 'core/constants/app_strings.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';

/// Root application widget configuring theme, routing, and global settings
class EcoTrackApp extends StatelessWidget {
  const EcoTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
