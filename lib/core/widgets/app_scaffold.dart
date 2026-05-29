import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

import 'app_loading.dart';

/// Wraps [Scaffold] with consistent app-bar styling and an optional full-screen
/// loading overlay driven by [isLoading].
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.appBar,
    this.actions,
    this.leading,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.drawer,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.safeArea = true,
    this.isLoading = false,
    this.backgroundColor,
    this.resizeToAvoidBottomInset,
  }) : assert(
         appBar == null || title == null,
         'Provide either `title` or a custom `appBar`, not both.',
       );

  final Widget body;
  final String? title;
  final PreferredSizeWidget? appBar;
  final List<Widget>? actions;
  final Widget? leading;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final EdgeInsetsGeometry padding;
  final bool safeArea;
  final bool isLoading;
  final Color? backgroundColor;
  final bool? resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(padding: padding, child: body);
    if (safeArea) content = SafeArea(child: content);

    return Scaffold(
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar:
          appBar ??
          (title != null
              ? AppBar(
                  title: Text(
                    title!,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  centerTitle: true,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  leading:
                      leading ??
                      (Navigator.of(context).canPop()
                          ? IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                              ),
                              iconSize: 20,
                              onPressed: () => Navigator.of(context).maybePop(),
                              tooltip: MaterialLocalizations.of(
                                context,
                              ).backButtonTooltip,
                            )
                          : null),
                  actions: actions,
                )
              : null),
      drawer: drawer,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      body: Stack(
        children: [
          content,
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: isLoading
                ? Stack(
                    key: const ValueKey('AppScaffoldLoading'),
                    children: [
                      // Blurred dark overlay
                      Positioned.fill(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: const ColoredBox(color: Colors.black26),
                        ),
                      ),
                      // Elevated glassmorphism loading card
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xxxxl,
                            vertical: AppSpacing.xxxl,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 24,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const AppLoading(),
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
