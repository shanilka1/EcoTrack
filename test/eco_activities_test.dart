import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecotrack/features/activities/models/eco_activity_model.dart';
import 'package:ecotrack/features/activities/screens/activities_screen.dart';
import 'package:ecotrack/features/activities/screens/activity_details_screen.dart';
import 'package:ecotrack/features/activities/widgets/category_filter_chips.dart';
import 'package:ecotrack/features/activities/widgets/eco_activity_card.dart';

void main() {
  final sampleActivities = [
    EcoActivityModel(
      id: 'act-1',
      title: 'Use Reusable Water Bottle',
      description: 'Avoid single-use plastic bottles by using a refillable container.',
      category: 'Waste',
      points: 15,
      environmentalBenefit: 'Saves up to 150 single-use plastic bottles per year from landfills.',
      createdAt: DateTime(2026, 8, 22),
    ),
    EcoActivityModel(
      id: 'act-2',
      title: 'Ride a Bicycle to Work',
      description: 'Choose cycling or walking over driving for short daily commutes.',
      category: 'Transport',
      points: 25,
      environmentalBenefit: 'Reduces carbon emissions by approximately 2.4 kg CO2 per trip.',
      createdAt: DateTime(2026, 8, 22),
    ),
    EcoActivityModel(
      id: 'act-3',
      title: 'Turn Off Idle Appliances',
      description: 'Unplug devices and switch off lights when not in use.',
      category: 'Energy',
      points: 10,
      environmentalBenefit: 'Reduces household electricity consumption and lowers carbon footprint.',
      createdAt: DateTime(2026, 8, 22),
    ),
  ];

  group('EcoActivityModel Domain & Serialization Tests', () {
    test('toMap and fromMap preserves all fields accurately', () {
      final activity = sampleActivities.first;
      final map = activity.toMap();

      expect(map['id'], 'act-1');
      expect(map['title'], 'Use Reusable Water Bottle');
      expect(map['category'], 'Waste');
      expect(map['points'], 15);
      expect(map['isActive'], isTrue);

      final fromMap = EcoActivityModel.fromMap(map);
      expect(fromMap.id, activity.id);
      expect(fromMap.title, activity.title);
      expect(fromMap.description, activity.description);
      expect(fromMap.category, activity.category);
      expect(fromMap.points, activity.points);
      expect(fromMap.environmentalBenefit, activity.environmentalBenefit);
    });

    test('copyWith produces updated copy with modified values', () {
      final original = sampleActivities[1];
      final updated = original.copyWith(points: 35, category: 'Mobility');

      expect(updated.id, original.id);
      expect(updated.points, 35);
      expect(updated.category, 'Mobility');
      expect(original.points, 25);
    });
  });

  group('ActivitiesScreen UI, Filtering & Search Tests', () {
    testWidgets('Renders activity list and category filter chips',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ActivitiesScreen(initialActivities: sampleActivities),
        ),
      );

      expect(find.text('Eco Activities'), findsOneWidget);
      expect(find.byType(EcoActivityCard), findsNWidgets(3));
      expect(find.text('Use Reusable Water Bottle'), findsOneWidget);
      expect(find.text('Ride a Bicycle to Work'), findsOneWidget);
      expect(find.text('Turn Off Idle Appliances'), findsOneWidget);
      expect(find.byType(CategoryFilterChips), findsOneWidget);
    });

    testWidgets('Filters activities by Category Chip selection',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ActivitiesScreen(initialActivities: sampleActivities),
        ),
      );

      // Tap 'Waste' category chip
      await tester.tap(find.widgetWithText(ChoiceChip, 'Waste'));
      await tester.pumpAndSettle();

      expect(find.byType(EcoActivityCard), findsOneWidget);
      expect(find.text('Use Reusable Water Bottle'), findsOneWidget);
      expect(find.text('Ride a Bicycle to Work'), findsNothing);
    });

    testWidgets('Filters activities by search text query',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ActivitiesScreen(initialActivities: sampleActivities),
        ),
      );

      // Type 'bicycle' into search field
      await tester.enterText(
        find.widgetWithText(TextFormField, ''),
        'bicycle',
      );
      await tester.pumpAndSettle();

      expect(find.byType(EcoActivityCard), findsOneWidget);
      expect(find.text('Ride a Bicycle to Work'), findsOneWidget);
      expect(find.text('Use Reusable Water Bottle'), findsNothing);
    });

    testWidgets('Shows empty state when no activities match search',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ActivitiesScreen(initialActivities: sampleActivities),
        ),
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, ''),
        'nonexistent habit',
      );
      await tester.pumpAndSettle();

      expect(find.byType(EcoActivityCard), findsNothing);
      expect(find.text('No matching activities found'), findsOneWidget);
      expect(find.text('Clear Filters'), findsOneWidget);
    });

    testWidgets('Shows empty state when activity list is empty from backend',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ActivitiesScreen(initialActivities: []),
        ),
      );

      expect(find.text('No active eco activities available'), findsOneWidget);
    });

    testWidgets('Renders with 0 overflow on small screen (320x568)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: ActivitiesScreen(initialActivities: sampleActivities),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(ActivitiesScreen), findsOneWidget);
    });
  });

  group('ActivityDetailsScreen Tests', () {
    testWidgets('Displays complete activity details and environmental benefit',
        (WidgetTester tester) async {
      final activity = sampleActivities.first;

      await tester.pumpWidget(
        MaterialApp(
          home: ActivityDetailsScreen(initialActivity: activity),
        ),
      );

      expect(find.text('Activity Details'), findsOneWidget);
      expect(find.text('Use Reusable Water Bottle'), findsOneWidget);
      expect(find.text('+15 pts'), findsOneWidget);
      expect(find.text('Waste'), findsOneWidget);
      expect(find.text('About This Activity'), findsOneWidget);
      expect(find.text('Environmental Impact'), findsOneWidget);
      expect(
        find.text('Saves up to 150 single-use plastic bottles per year from landfills.'),
        findsOneWidget,
      );
      expect(find.text('Complete Activity'), findsOneWidget);
    });

    testWidgets('Tapping Complete Activity triggers notification without fake auth',
        (WidgetTester tester) async {
      final activity = sampleActivities.first;

      await tester.pumpWidget(
        MaterialApp(
          home: ActivityDetailsScreen(initialActivity: activity),
        ),
      );

      await tester.tap(find.text('Complete Activity'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Activity recorded! Points (+15 pts) will be credited in the rewards step.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('Renders Activity Details with 0 overflow on small screen (320x568)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: ActivityDetailsScreen(initialActivity: sampleActivities[1]),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(ActivityDetailsScreen), findsOneWidget);
    });
  });
}
