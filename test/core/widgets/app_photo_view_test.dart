import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter_starter_template/core/widgets/app_photo_view.dart';

// 1x1 transparent PNG to use for testing ImageProviders without hitting disk or network
final Uint8List kTransparentImage = Uint8List.fromList([
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49,
  0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06,
  0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44,
  0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, 0x05, 0x00, 0x01, 0x0D,
  0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42,
  0x60, 0x82,
]);

void main() {
  Widget wrapWithMaterial(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  group('AppPhotoView', () {
    testWidgets('renders PhotoView with primary provider constructor', (tester) async {
      final imageProvider = MemoryImage(kTransparentImage);

      await tester.pumpWidget(
        wrapWithMaterial(
          AppPhotoView(imageProvider: imageProvider),
        ),
      );

      // Verify PhotoView is rendered
      expect(find.byType(PhotoView), findsOneWidget);
    });

    testWidgets('factory constructors create AppPhotoView without errors', (tester) async {
      // Test Asset factory constructor
      final assetWidget = AppPhotoView.asset('assets/icons/app_icon.png');
      expect(assetWidget.imageProvider, isA<AssetImage>());

      // Test Network factory constructor
      final networkWidget = AppPhotoView.network('https://example.com/image.png');
      expect(networkWidget.imageProvider, isA<NetworkImage>());

      // Test File factory constructor
      final fileWidget = AppPhotoView.file(File('image.png'));
      expect(fileWidget.imageProvider, isA<FileImage>());
    });

    testWidgets('triggers zoom scale transition on double tap', (tester) async {
      final controller = PhotoViewController();
      final imageProvider = MemoryImage(kTransparentImage);

      await tester.pumpWidget(
        wrapWithMaterial(
          AppPhotoView(
            imageProvider: imageProvider,
            controller: controller,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initial scale is resolved based on widget constraints
      expect(controller.scale, isNotNull);
      final initialScale = controller.scale!;

      // Double tap to zoom/toggle (zooms in to 2.5x of initial scale)
      await tester.tap(find.byType(AppPhotoView));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.byType(AppPhotoView));
      await tester.pumpAndSettle();

      expect(controller.scale, equals(initialScale * 2.5));

      // Double tap again (zooms out back to initial scale)
      await tester.tap(find.byType(AppPhotoView));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.byType(AppPhotoView));
      await tester.pumpAndSettle();

      expect(controller.scale, equals(initialScale));
      
      controller.dispose();
    });

    testWidgets('renders error builder when image load fails', (tester) async {
      // MemoryImage with invalid bytes triggers an error
      final imageProvider = MemoryImage(Uint8List.fromList([0, 1, 2]));

      await tester.pumpWidget(
        wrapWithMaterial(
          AppPhotoView(imageProvider: imageProvider),
        ),
      );
      await tester.pump();

      // Let the image loading fail and trigger state change
      await tester.pump(const Duration(milliseconds: 100));

      // Verify the error text is displayed
      expect(find.text('Failed to load image'), findsOneWidget);
      expect(find.byIcon(Icons.broken_image_rounded), findsOneWidget);
    });

    testWidgets('shows fullscreen viewer and close button dismisses it', (tester) async {
      final imageProvider = MemoryImage(kTransparentImage);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  AppPhotoView.showFullScreen(
                    context,
                    imageProvider: imageProvider,
                    heroTag: 'test_tag',
                  );
                },
                child: const Text('Open Viewer'),
              );
            },
          ),
        ),
      );

      // Open fullscreen viewer
      await tester.tap(find.text('Open Viewer'));
      await tester.pumpAndSettle();

      // Screen should transition to showing PhotoView inside the full screen page
      expect(find.byType(PhotoView), findsOneWidget);
      
      // Close button should be present
      final closeButton = find.byIcon(Icons.close_rounded);
      expect(closeButton, findsOneWidget);

      // Tap close to dismiss
      await tester.tap(closeButton);
      await tester.pumpAndSettle();

      // Full screen viewer should be closed
      expect(find.byType(PhotoView), findsNothing);
    });

    testWidgets('fullscreen viewer drag-to-dismiss works', (tester) async {
      final imageProvider = MemoryImage(kTransparentImage);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  AppPhotoView.showFullScreen(
                    context,
                    imageProvider: imageProvider,
                  );
                },
                child: const Text('Open Viewer'),
              );
            },
          ),
        ),
      );

      // Open fullscreen viewer
      await tester.tap(find.text('Open Viewer'));
      await tester.pumpAndSettle();

      expect(find.byType(PhotoView), findsOneWidget);

      // Drag down vertically to dismiss
      await tester.drag(find.byType(PhotoView), const Offset(0, 300));
      await tester.pumpAndSettle();

      // Full screen viewer should be closed via drag
      expect(find.byType(PhotoView), findsNothing);
    });
  });
}
