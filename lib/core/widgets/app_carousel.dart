import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

final class AppCarousel extends StatefulWidget {
  const AppCarousel({
    super.key,
    required this.items,
    this.autoPlay = true,
    this.autoPlayInterval = const Duration(seconds: 4),
    this.enlargeCenterPage = true,
    this.viewportFraction = 0.85,
    this.aspectRatio = 16 / 9,
    this.showIndicators = true,
    this.onPageChanged,
    this.height,
  });

  final List<Widget> items;
  final bool autoPlay;
  final Duration autoPlayInterval;
  final bool enlargeCenterPage;
  final double viewportFraction;
  final double aspectRatio;
  final bool showIndicators;
  final ValueChanged<int>? onPageChanged;
  final double? height;

  @override
  State<AppCarousel> createState() => _AppCarouselState();
}

class _AppCarouselState extends State<AppCarousel> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CarouselSlider(
          items: widget.items,
          options: CarouselOptions(
            autoPlay: widget.autoPlay,
            autoPlayInterval: widget.autoPlayInterval,
            enlargeCenterPage: widget.enlargeCenterPage,
            viewportFraction: widget.viewportFraction,
            aspectRatio: widget.aspectRatio,
            height: widget.height,
            onPageChanged: (index, _) {
              setState(() => _current = index);
              widget.onPageChanged?.call(index);
            },
          ),
        ),
        if (widget.showIndicators && widget.items.length > 1) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.items.length, (i) {
              final isActive = i == _current;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: isActive
                      ? scheme.primary
                      : scheme.onSurface.withValues(alpha: 0.3),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}
