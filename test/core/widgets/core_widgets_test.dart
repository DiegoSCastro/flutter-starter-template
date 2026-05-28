import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_starter_template/core/widgets/app_button.dart';
import 'package:flutter_starter_template/core/widgets/app_empty_view.dart';
import 'package:flutter_starter_template/core/widgets/app_error_view.dart';
import 'package:flutter_starter_template/core/widgets/app_loading.dart';
import 'package:flutter_starter_template/core/widgets/app_scaffold.dart';
import 'package:flutter_starter_template/core/widgets/app_slidable.dart';
import 'package:flutter_starter_template/core/widgets/app_text_field.dart';
import 'package:flutter_starter_template/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Widget materialApp(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

void main() {
  group('AppLoading', () {
    testWidgets('renders a CircularProgressIndicator', (tester) async {
      await tester.pumpWidget(materialApp(const AppLoading()));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading...'), findsNothing);
    });

    testWidgets('shows label when provided', (tester) async {
      await tester.pumpWidget(
        materialApp(const AppLoading(label: 'Loading...')),
      );

      expect(find.text('Loading...'), findsOneWidget);
    });

    testWidgets('uses custom size', (tester) async {
      await tester.pumpWidget(materialApp(const AppLoading(size: 48)));

      final spinner = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(spinner.strokeWidth, 3);
    });
  });

  group('AppEmptyView', () {
    testWidgets('renders message and default icon', (tester) async {
      await tester.pumpWidget(
        materialApp(const AppEmptyView(message: 'Nothing here')),
      );

      expect(find.text('Nothing here'), findsOneWidget);
      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    });

    testWidgets('renders title when provided', (tester) async {
      await tester.pumpWidget(
        materialApp(const AppEmptyView(message: 'Empty', title: 'No Data')),
      );

      expect(find.text('No Data'), findsOneWidget);
      expect(find.text('Empty'), findsOneWidget);
    });

    testWidgets('renders custom icon', (tester) async {
      await tester.pumpWidget(
        materialApp(
          const AppEmptyView(message: 'Empty', icon: Icons.search_off),
        ),
      );

      expect(find.byIcon(Icons.search_off), findsOneWidget);
    });

    testWidgets('renders action widget when provided', (tester) async {
      await tester.pumpWidget(
        materialApp(
          AppEmptyView(
            message: 'Empty',
            action: ElevatedButton(onPressed: () {}, child: const Text('Add')),
          ),
        ),
      );

      expect(find.text('Add'), findsOneWidget);
    });
  });

  group('AppErrorView', () {
    testWidgets('renders message and default icon', (tester) async {
      await tester.pumpWidget(materialApp(const AppErrorView(message: 'Oops')));

      expect(find.text('Oops'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('renders title when provided', (tester) async {
      await tester.pumpWidget(
        materialApp(const AppErrorView(message: 'Oops', title: 'Error')),
      );

      expect(find.text('Error'), findsOneWidget);
      expect(find.text('Oops'), findsOneWidget);
    });

    testWidgets('renders retry button when onRetry is provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        materialApp(AppErrorView(message: 'Oops', onRetry: () {})),
      );

      expect(find.text('Retry'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('retry callback fires on tap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        materialApp(
          AppErrorView(message: 'Oops', onRetry: () => tapped = true),
        ),
      );

      await tester.tap(find.text('Retry'));
      expect(tapped, isTrue);
    });

    testWidgets('uses custom retry label', (tester) async {
      await tester.pumpWidget(
        materialApp(
          AppErrorView(
            message: 'Oops',
            onRetry: () {},
            retryLabel: 'Try Again',
          ),
        ),
      );

      expect(find.text('Try Again'), findsOneWidget);
    });
  });

  group('AppScaffold', () {
    testWidgets('renders body inside SafeArea with padding', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: AppScaffold(body: Text('Content'))),
      );

      expect(find.text('Content'), findsOneWidget);
      expect(find.byType(SafeArea), findsOneWidget);
    });

    testWidgets('renders AppBar when title is provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AppScaffold(title: 'Test Screen', body: Text('Content')),
        ),
      );

      expect(find.text('Test Screen'), findsOneWidget);
    });

    testWidgets('renders custom appBar when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AppScaffold(
            appBar: AppBar(title: const Text('Custom')),
            body: const Text('Content'),
          ),
        ),
      );

      expect(find.text('Custom'), findsOneWidget);
    });

    testWidgets('shows loading overlay when isLoading is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AppScaffold(body: Text('Content'), isLoading: true),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders floating action button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AppScaffold(
            body: const Text('Content'),
            floatingActionButton: FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.add),
            ),
          ),
        ),
      );

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });

  group('AppSlidable', () {
    testWidgets('renders child and end action', (tester) async {
      await tester.pumpWidget(
        materialApp(
          const AppSlidable(
            endActions: [AppSlidableAction.delete(onPressed: null)],
            child: ListTile(title: Text('Bookmark')),
          ),
        ),
      );

      expect(find.text('Bookmark'), findsOneWidget);
      expect(find.byType(Slidable), findsOneWidget);

      await tester.drag(find.text('Bookmark'), const Offset(-300, 0));
      await tester.pumpAndSettle();

      final action = tester.widget<SlidableAction>(find.byType(SlidableAction));
      expect(action.label, 'Delete');
      expect(action.icon, Icons.delete_outline);
    });

    testWidgets('fires action callback', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        materialApp(
          AppSlidable(
            endActions: [
              AppSlidableAction.delete(onPressed: (_) => tapped = true),
            ],
            child: const ListTile(title: Text('Bookmark')),
          ),
        ),
      );

      await tester.drag(find.text('Bookmark'), const Offset(-300, 0));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(SlidableAction));

      expect(tapped, isTrue);
    });
  });

  group('AppTextField', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(
        materialApp(const AppTextField(label: 'Username')),
      );

      expect(find.text('Username'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('renders hint text', (tester) async {
      await tester.pumpWidget(
        materialApp(const AppTextField(hint: 'Enter name')),
      );

      expect(find.text('Enter name'), findsOneWidget);
    });

    testWidgets('renders prefix icon', (tester) async {
      await tester.pumpWidget(
        materialApp(
          const AppTextField(label: 'Email', prefixIcon: Icons.email_outlined),
        ),
      );

      expect(find.byIcon(Icons.email_outlined), findsOneWidget);
    });

    testWidgets('accepts text input', (tester) async {
      await tester.pumpWidget(materialApp(const AppTextField()));

      await tester.enterText(find.byType(TextFormField), 'hello');
      expect(find.text('hello'), findsOneWidget);
    });

    testWidgets('displays error text', (tester) async {
      await tester.pumpWidget(
        materialApp(const AppTextField(errorText: 'Required field')),
      );

      expect(find.text('Required field'), findsOneWidget);
    });

    testWidgets('calls onChanged when text changes', (tester) async {
      var changedValue = '';
      await tester.pumpWidget(
        materialApp(AppTextField(onChanged: (v) => changedValue = v)),
      );

      await tester.enterText(find.byType(TextFormField), 'test');
      expect(changedValue, 'test');
    });

    testWidgets('is disabled when enabled is false', (tester) async {
      await tester.pumpWidget(materialApp(const AppTextField(enabled: false)));

      final field = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(field.enabled, isFalse);
    });
  });

  group('AppButton', () {
    group('primary variant', () {
      testWidgets('renders label', (tester) async {
        await tester.pumpWidget(
          materialApp(AppButton(label: 'Save', onPressed: () {})),
        );

        expect(find.text('Save'), findsOneWidget);
        expect(find.byType(FilledButton), findsOneWidget);
      });

      testWidgets('fires onPressed callback', (tester) async {
        var tapped = false;
        await tester.pumpWidget(
          materialApp(AppButton(label: 'Save', onPressed: () => tapped = true)),
        );

        await tester.tap(find.text('Save'));
        expect(tapped, isTrue);
      });

      testWidgets('shows CircularProgressIndicator when loading', (
        tester,
      ) async {
        await tester.pumpWidget(
          materialApp(
            const AppButton(label: 'Save', onPressed: null, isLoading: true),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('renders icon button when icon provided', (tester) async {
        await tester.pumpWidget(
          materialApp(
            AppButton(label: 'Save', onPressed: () {}, icon: Icons.save),
          ),
        );

        expect(find.byIcon(Icons.save), findsOneWidget);
        expect(find.text('Save'), findsOneWidget);
      });

      testWidgets('does nothing when onPressed is null', (tester) async {
        await tester.pumpWidget(
          materialApp(const AppButton(label: 'Save', onPressed: null)),
        );

        // Button should render but be disabled
        final button = tester.widget<FilledButton>(find.byType(FilledButton));
        expect(button.onPressed, isNull);
      });
    });

    group('tonal variant', () {
      testWidgets('renders FilledButton.tonal', (tester) async {
        await tester.pumpWidget(
          materialApp(
            AppButton(
              label: 'Cancel',
              onPressed: () {},
              variant: AppButtonVariant.tonal,
            ),
          ),
        );

        expect(find.text('Cancel'), findsOneWidget);
      });

      testWidgets('renders FilledButton.tonalIcon when icon provided', (
        tester,
      ) async {
        await tester.pumpWidget(
          materialApp(
            AppButton(
              label: 'Close',
              onPressed: () {},
              variant: AppButtonVariant.tonal,
              icon: Icons.close,
            ),
          ),
        );

        expect(find.byIcon(Icons.close), findsOneWidget);
      });
    });

    group('outlined variant', () {
      testWidgets('renders OutlinedButton', (tester) async {
        await tester.pumpWidget(
          materialApp(
            AppButton(
              label: 'Back',
              onPressed: () {},
              variant: AppButtonVariant.outlined,
            ),
          ),
        );

        expect(find.byType(OutlinedButton), findsOneWidget);
      });
    });

    group('text variant', () {
      testWidgets('renders TextButton', (tester) async {
        await tester.pumpWidget(
          materialApp(
            AppButton(
              label: 'Skip',
              onPressed: () {},
              variant: AppButtonVariant.text,
            ),
          ),
        );

        expect(find.byType(TextButton), findsOneWidget);
      });
    });

    group('size', () {
      testWidgets('small size', (tester) async {
        await tester.pumpWidget(
          materialApp(
            AppButton(
              label: 'Small',
              onPressed: () {},
              size: AppButtonSize.small,
            ),
          ),
        );

        expect(find.text('Small'), findsOneWidget);
      });

      testWidgets('large size', (tester) async {
        await tester.pumpWidget(
          materialApp(
            AppButton(
              label: 'Large',
              onPressed: () {},
              size: AppButtonSize.large,
            ),
          ),
        );

        expect(find.text('Large'), findsOneWidget);
      });
    });

    testWidgets('expand fills width', (tester) async {
      await tester.pumpWidget(
        materialApp(AppButton(label: 'Full', onPressed: () {}, expand: true)),
      );

      final button = tester.widget<SizedBox>(find.byType(SizedBox));
      expect(button.width, double.infinity);
    });
  });
}
