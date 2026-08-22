import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecotrack/features/auth/models/user_model.dart';
import 'package:ecotrack/features/auth/screens/auth_placeholder_screen.dart';

void main() {
  group('AuthPlaceholderScreen Tests', () {
    testWidgets('Displays user profile fields accurately',
        (WidgetTester tester) async {
      final user = UserModel(
        uid: 'eco-user-123456789',
        fullName: 'Shanilka Perera',
        email: 'shanilka@ecotrack.org',
        role: 'user',
        ecoPoints: 240,
        level: 3,
        createdAt: DateTime(2026, 8, 22),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: AuthPlaceholderScreen(user: user),
        ),
      );

      expect(find.text('EcoTrack Authenticated Area'), findsOneWidget);
      expect(find.text('Authentication Successful!'), findsOneWidget);
      expect(find.text('Shanilka Perera'), findsOneWidget);
      expect(find.text('shanilka@ecotrack.org'), findsOneWidget);
      expect(find.text('240 pts'), findsOneWidget);
      expect(find.text('Level 3'), findsOneWidget);
      expect(find.text('Sign Out'), findsOneWidget);
    });
  });
}
