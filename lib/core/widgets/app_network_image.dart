import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../build_context_extensions.dart';
import 'app_loading.dart';

/// A wrapper around [CachedNetworkImage] that provides consistent loading
/// and error states across the app.
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholderSize = 24.0,
    this.errorIconSize = 24.0,
    this.color,
    this.colorBlendMode,
    this.borderRadius = BorderRadius.zero,
    this.placeholder,
    this.errorWidget,
  });

  /// The URL of the image to load.
  final String imageUrl;

  /// How to inscribe the image into the space allocated during layout.
  final BoxFit fit;

  /// If non-null, require the image to have this width.
  final double? width;

  /// If non-null, require the image to have this height.
  final double? height;

  /// Size of the default loading indicator.
  final double placeholderSize;

  /// Size of the default error icon.
  final double errorIconSize;

  /// If non-null, this color is blended with each image pixel using [colorBlendMode].
  final Color? color;

  /// Used to combine [color] with this image.
  final BlendMode? colorBlendMode;

  /// Optional border radius to clip the image.
  final BorderRadius borderRadius;

  /// Custom widget to display while the image is loading.
  final Widget Function(BuildContext, String)? placeholder;

  /// Custom widget to display if the image fails to load.
  final Widget Function(BuildContext, String, dynamic)? errorWidget;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return _buildErrorWidget(context, imageUrl, 'Empty URL');
    }

    final imageWidget = CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      width: width,
      height: height,
      color: color,
      colorBlendMode: colorBlendMode,
      placeholder: placeholder ?? _buildPlaceholder,
      errorWidget: errorWidget ?? _buildErrorWidget,
    );

    if (borderRadius != BorderRadius.zero) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildPlaceholder(BuildContext context, String url) {
    return Center(
      child: AppLoading(size: placeholderSize),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String url, dynamic error) {
    return Container(
      width: width,
      height: height,
      color: context.colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(
        Icons.broken_image_rounded,
        size: errorIconSize,
        color: context.colorScheme.onSurfaceVariant.withOpacity(0.5),
      ),
    );
  }
}
