import 'package:flutter/material.dart';
import 'package:flutter_starter_template/core/platform/media/video_player_service.dart';
import 'package:flutter_starter_template/ui/widgets/app_video_player.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:video_player/video_player.dart';

class MockAppVideoPlayerController extends Mock
    implements AppVideoPlayerController {}

class MockVideoPlayerController extends Mock implements VideoPlayerController {}

void main() {
  Widget wrapWithMaterial(Widget child) {
    return MaterialApp(
      home: Scaffold(body: child),
    );
  }

  group('AppVideoPlayer', () {
    late MockAppVideoPlayerController mockController;
    late MockVideoPlayerController mockRawController;
    late ValueNotifier<VideoPlayerValue> valueNotifier;

    setUp(() {
      mockController = MockAppVideoPlayerController();
      mockRawController = MockVideoPlayerController();
      valueNotifier = ValueNotifier<VideoPlayerValue>(
        const VideoPlayerValue(
          duration: Duration(seconds: 60),
          isInitialized: false,
        ),
      );

      when(() => mockController.valueListenable).thenReturn(valueNotifier);
      when(() => mockController.value).thenReturn(valueNotifier.value);
      when(() => mockController.rawController).thenReturn(mockRawController);
    });

    testWidgets('renders placeholder when rawController is null', (
      tester,
    ) async {
      when(() => mockController.rawController).thenReturn(null);

      await tester.pumpWidget(
        wrapWithMaterial(AppVideoPlayer(controller: mockController)),
      );

      expect(find.text('Mock Video Player View'), findsOneWidget);
      expect(find.byIcon(Icons.video_library), findsOneWidget);
    });

    testWidgets('renders error view when video fails to load', (
      tester,
    ) async {
      // Update state to have error
      const errorValue = VideoPlayerValue(
        duration: Duration.zero,
        errorDescription: 'Invalid video file format',
      );
      when(() => mockController.value).thenReturn(errorValue);

      await tester.pumpWidget(
        wrapWithMaterial(AppVideoPlayer(controller: mockController)),
      );

      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
      expect(find.text('Invalid video file format'), findsOneWidget);
    });
  });
}
