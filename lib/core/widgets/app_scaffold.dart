import 'package:flutter/material.dart';

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
    this.padding = const EdgeInsets.all(16),
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
              ? AppBar(title: Text(title!), leading: leading, actions: actions)
              : null),
      drawer: drawer,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      body: Stack(
        children: [
          content,
          if (isLoading)
            const ColoredBox(color: Color(0x66000000), child: AppLoading()),
        ],
      ),
    );
  }
}
