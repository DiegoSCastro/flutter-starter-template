import 'package:flutter/material.dart';
import 'package:flutter_starter_template/core/widgets/app_adaptive_scaffold.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const destinations = [
    AppDestination(icon: Icons.home, label: 'Home'),
    AppDestination(icon: Icons.settings, label: 'Settings'),
  ];

  Future<void> pumpAt(WidgetTester tester, double width) async {
    tester.view.physicalSize = Size(width, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: AppAdaptiveScaffold(
          destinations: destinations,
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          body: const Center(child: Text('body')),
        ),
      ),
    );
  }

  group('AppAdaptiveScaffold', () {
    testWidgets('compact width uses a bottom NavigationBar', (tester) async {
      await pumpAt(tester, 500);

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
    });

    testWidgets('medium width uses a collapsed NavigationRail', (tester) async {
      await pumpAt(tester, 700);

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
      final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
      expect(rail.extended, isFalse);
    });

    testWidgets('expanded width uses an extended NavigationRail', (
      tester,
    ) async {
      await pumpAt(tester, 1000);

      final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
      expect(rail.extended, isTrue);
    });
  });
}
