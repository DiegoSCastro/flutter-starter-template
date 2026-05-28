import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

/// A wrapper widget for [PhotoView] that simplifies image zooming,
/// supports different image sources (network, asset, file, custom provider),
/// and integrates customizable loading and error states.
class AppPhotoView extends StatefulWidget {
  const AppPhotoView({
    super.key,
    required this.imageProvider,
    this.heroTag,
    this.minScale,
    this.maxScale,
    this.initialScale,
    this.backgroundDecoration,
    this.loadingBuilder,
    this.errorBuilder,
    this.enableRotation = false,
    this.isCover = false,
    this.onTapUp,
    this.onTapDown,
    this.controller,
  });

  /// Conveniently loads a network image.
  factory AppPhotoView.network(
    String url, {
    Key? key,
    String? heroTag,
    dynamic minScale,
    dynamic maxScale,
    dynamic initialScale,
    BoxDecoration? backgroundDecoration,
    Widget Function(BuildContext, ImageChunkEvent?)? loadingBuilder,
    Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
    bool enableRotation = false,
    bool isCover = false,
    PhotoViewImageTapUpCallback? onTapUp,
    PhotoViewImageTapDownCallback? onTapDown,
    PhotoViewController? controller,
  }) {
    return AppPhotoView(
      key: key,
      imageProvider: NetworkImage(url),
      heroTag: heroTag,
      minScale: minScale,
      maxScale: maxScale,
      initialScale: initialScale,
      backgroundDecoration: backgroundDecoration,
      loadingBuilder: loadingBuilder,
      errorBuilder: errorBuilder,
      enableRotation: enableRotation,
      isCover: isCover,
      onTapUp: onTapUp,
      onTapDown: onTapDown,
      controller: controller,
    );
  }

  /// Conveniently loads an asset image.
  factory AppPhotoView.asset(
    String assetPath, {
    Key? key,
    String? heroTag,
    dynamic minScale,
    dynamic maxScale,
    dynamic initialScale,
    BoxDecoration? backgroundDecoration,
    Widget Function(BuildContext, ImageChunkEvent?)? loadingBuilder,
    Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
    bool enableRotation = false,
    bool isCover = false,
    PhotoViewImageTapUpCallback? onTapUp,
    PhotoViewImageTapDownCallback? onTapDown,
    PhotoViewController? controller,
  }) {
    return AppPhotoView(
      key: key,
      imageProvider: AssetImage(assetPath),
      heroTag: heroTag,
      minScale: minScale,
      maxScale: maxScale,
      initialScale: initialScale,
      backgroundDecoration: backgroundDecoration,
      loadingBuilder: loadingBuilder,
      errorBuilder: errorBuilder,
      enableRotation: enableRotation,
      isCover: isCover,
      onTapUp: onTapUp,
      onTapDown: onTapDown,
      controller: controller,
    );
  }

  /// Conveniently loads a file image.
  factory AppPhotoView.file(
    File file, {
    Key? key,
    String? heroTag,
    dynamic minScale,
    dynamic maxScale,
    dynamic initialScale,
    BoxDecoration? backgroundDecoration,
    Widget Function(BuildContext, ImageChunkEvent?)? loadingBuilder,
    Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
    bool enableRotation = false,
    bool isCover = false,
    PhotoViewImageTapUpCallback? onTapUp,
    PhotoViewImageTapDownCallback? onTapDown,
    PhotoViewController? controller,
  }) {
    return AppPhotoView(
      key: key,
      imageProvider: FileImage(file),
      heroTag: heroTag,
      minScale: minScale,
      maxScale: maxScale,
      initialScale: initialScale,
      backgroundDecoration: backgroundDecoration,
      loadingBuilder: loadingBuilder,
      errorBuilder: errorBuilder,
      enableRotation: enableRotation,
      isCover: isCover,
      onTapUp: onTapUp,
      onTapDown: onTapDown,
      controller: controller,
    );
  }

  final ImageProvider imageProvider;
  final String? heroTag;
  final dynamic minScale;
  final dynamic maxScale;
  final dynamic initialScale;
  final BoxDecoration? backgroundDecoration;
  final Widget Function(BuildContext, ImageChunkEvent?)? loadingBuilder;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;
  final bool enableRotation;
  final bool isCover;
  final PhotoViewImageTapUpCallback? onTapUp;
  final PhotoViewImageTapDownCallback? onTapDown;
  final PhotoViewController? controller;

  /// Helper method to display this image viewer in a beautiful fullscreen overlay dialog/route.
  static Future<void> showFullScreen(
    BuildContext context, {
    required ImageProvider imageProvider,
    String? heroTag,
    bool enableRotation = false,
    List<ImageProvider>? galleryImages,
    int initialIndex = 0,
  }) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black.withValues(alpha: 0.9),
        pageBuilder: (context, _, _) => _AppPhotoViewFullScreenPage(
          imageProvider: imageProvider,
          heroTag: heroTag,
          enableRotation: enableRotation,
          galleryImages: galleryImages,
          initialIndex: initialIndex,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  State<AppPhotoView> createState() => _AppPhotoViewState();
}

class _AppPhotoViewState extends State<AppPhotoView> {
  late PhotoViewController _photoViewController;
  double? _initialScale;

  @override
  void initState() {
    super.initState();
    _photoViewController = widget.controller ?? PhotoViewController();

    // Listen to scale changes to capture the initial resolved scale factor
    _photoViewController.outputStateStream.listen((value) {
      if (mounted && _initialScale == null && value.scale != null) {
        _initialScale = value.scale;
      }
    });
  }

  @override
  void dispose() {
    // Only dispose if we created it locally
    if (widget.controller == null) {
      _photoViewController.dispose();
    }
    super.dispose();
  }

  void _handleDoubleTap() {
    final scale = _photoViewController.scale ?? 1.0;
    final baseScale = _initialScale ?? 1.0;

    // Toggle between initial scale and 2.5x zoom
    if (scale > baseScale * 1.05) {
      _photoViewController.scale = baseScale;
    } else {
      _photoViewController.scale = baseScale * 2.5;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child = PhotoView(
      imageProvider: widget.imageProvider,
      controller: _photoViewController,
      minScale:
          widget.minScale ??
          (widget.isCover
              ? PhotoViewComputedScale.covered * 0.8
              : PhotoViewComputedScale.contained),
      maxScale:
          widget.maxScale ??
          (widget.isCover
              ? PhotoViewComputedScale.covered * 4.0
              : PhotoViewComputedScale.contained * 4.0),
      initialScale:
          widget.initialScale ??
          (widget.isCover
              ? PhotoViewComputedScale.covered
              : PhotoViewComputedScale.contained),
      backgroundDecoration:
          widget.backgroundDecoration ??
          const BoxDecoration(color: Colors.transparent),
      enableRotation: widget.enableRotation,
      loadingBuilder:
          widget.loadingBuilder ??
          (context, event) => Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                value: event == null || event.expectedTotalBytes == null
                    ? null
                    : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
              ),
            ),
          ),
      errorBuilder:
          widget.errorBuilder ??
          (context, error, stackTrace) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.broken_image_rounded,
                  color: Theme.of(context).colorScheme.error,
                  size: 40,
                ),
                const SizedBox(height: 8),
                Text(
                  'Failed to load image',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ),
          ),
      onTapUp: widget.onTapUp,
      onTapDown: widget.onTapDown,
    );

    if (widget.heroTag != null) {
      child = Hero(tag: widget.heroTag!, child: child);
    }

    return GestureDetector(onDoubleTap: _handleDoubleTap, child: child);
  }
}

class _AppPhotoViewFullScreenPage extends StatefulWidget {
  const _AppPhotoViewFullScreenPage({
    required this.imageProvider,
    this.heroTag,
    this.enableRotation = false,
    this.galleryImages,
    this.initialIndex = 0,
  });

  final ImageProvider imageProvider;
  final String? heroTag;
  final bool enableRotation;
  final List<ImageProvider>? galleryImages;
  final int initialIndex;

  @override
  State<_AppPhotoViewFullScreenPage> createState() =>
      _AppPhotoViewFullScreenPageState();
}

class _AppPhotoViewFullScreenPageState
    extends State<_AppPhotoViewFullScreenPage>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late int _currentIndex;
  bool _showUI = true;

  // Swipe-down to dismiss fields
  double _dragOffset = 0;
  bool _isDragging = false;
  late PhotoViewController _photoViewController;
  double? _initialScale;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _photoViewController = PhotoViewController();

    // Track the initial scale to dynamically determine if the image is zoomed in
    _photoViewController.outputStateStream.listen((value) {
      if (mounted && _initialScale == null && value.scale != null) {
        setState(() {
          _initialScale = value.scale;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _photoViewController.dispose();
    super.dispose();
  }

  // Check if we are at normal zoom levels before allowing swipe down dismiss
  bool get _canDismiss {
    final scale = _photoViewController.scale;
    if (scale == null) return true;
    final baseScale = _initialScale ?? 1.0;
    return scale <= baseScale * 1.01;
  }

  void _onVerticalDragStart(DragStartDetails details) {
    if (_canDismiss) {
      setState(() {
        _isDragging = true;
        _dragOffset = 0.0;
      });
    }
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (_isDragging) {
      setState(() {
        _dragOffset += details.delta.dy;
      });
    }
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (_isDragging) {
      final velocity = details.velocity.pixelsPerSecond.dy;
      if (_dragOffset > 120 || velocity > 400) {
        Navigator.of(context).pop();
      } else {
        // Snap back with animation
        setState(() {
          _isDragging = false;
          _dragOffset = 0.0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasGallery =
        widget.galleryImages != null && widget.galleryImages!.isNotEmpty;
    final totalImages = hasGallery ? widget.galleryImages!.length : 1;

    // Calculate background opacity based on drag distance
    final dragProgress = (_dragOffset.abs() / 300.0).clamp(0.0, 1.0);
    final bgOpacity = (0.95 - (dragProgress * 0.4)).clamp(0.0, 0.95);

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: bgOpacity),
      body: Stack(
        children: [
          // Main interactive component with drag gestures
          Positioned.fill(
            child: GestureDetector(
              onVerticalDragStart: _onVerticalDragStart,
              onVerticalDragUpdate: _onVerticalDragUpdate,
              onVerticalDragEnd: _onVerticalDragEnd,
              onTap: () {
                setState(() {
                  _showUI = !_showUI;
                });
              },
              child: Transform.translate(
                offset: Offset(0, _dragOffset),
                child: hasGallery
                    ? PhotoViewGallery.builder(
                        itemCount: totalImages,
                        builder: (context, index) {
                          final provider = widget.galleryImages![index];
                          final isInitial = index == widget.initialIndex;
                          return PhotoViewGalleryPageOptions(
                            imageProvider: provider,
                            heroAttributes: isInitial && widget.heroTag != null
                                ? PhotoViewHeroAttributes(tag: widget.heroTag!)
                                : null,
                            minScale: PhotoViewComputedScale.contained,
                            maxScale: PhotoViewComputedScale.contained * 4.0,
                            initialScale: PhotoViewComputedScale.contained,
                          );
                        },
                        pageController: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            _currentIndex = index;
                          });
                        },
                        loadingBuilder: (context, event) => const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        scrollPhysics: const BouncingScrollPhysics(),
                        backgroundDecoration: const BoxDecoration(
                          color: Colors.transparent,
                        ),
                      )
                    : AppPhotoView(
                        imageProvider: widget.imageProvider,
                        heroTag: widget.heroTag,
                        enableRotation: widget.enableRotation,
                        minScale: PhotoViewComputedScale.contained,
                        maxScale: PhotoViewComputedScale.contained * 4.0,
                        initialScale: PhotoViewComputedScale.contained,
                        controller: _photoViewController,
                      ),
              ),
            ),
          ),

          // Controls UI Overlay
          AnimatedOpacity(
            opacity: _showUI && !_isDragging ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 250),
            child: IgnorePointer(
              ignoring: !_showUI || _isDragging,
              child: Stack(
                children: [
                  // Top bar (Close, indicators, etc.)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top + 8,
                        bottom: 16,
                        left: 8,
                        right: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withValues(alpha: 0.85),
                            Colors.transparent,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          if (hasGallery) ...[
                            const SizedBox(width: 12),
                            Text(
                              '${_currentIndex + 1} / $totalImages',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
