import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../app/router.dart';
import '../../../../core/extensions/build_context_extensions.dart';
import '../../../../shared/domain/bookmark_stats.dart';
import '../../../../shared/presentation/session_scope.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_state.dart';

class HomeBody extends StatelessWidget {
  const HomeBody({super.key});

  static const double _contentMaxWidth = 720;
  static const double _bottomInset = 112;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: context.l10n.homeAppBarTitle,
      padding: EdgeInsets.zero,
      backgroundColor: context.colorScheme.surface,
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  _bottomInset,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: _contentMaxWidth,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _WelcomeSection(
                          totalBookmarks: state.totalBookmarks,
                        ).animateFadeIn(delay: 100.ms),
                        const SizedBox(height: AppSpacing.lg),
                        _StatsDashboard(state: state),
                        const SizedBox(height: AppSpacing.lg),
                        _PrimaryActionPanel(
                          onPressed: () =>
                              const BookmarksListRoute().push<void>(context),
                        ).animateSlideUp(delay: 350.ms),
                        const SizedBox(height: AppSpacing.xl),
                        _RecentBookmarksSection(
                          recentItems: state.recentItems,
                          isEmpty: state.totalBookmarks == 0,
                          animationDelay: 450.ms,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _WelcomeSection extends StatelessWidget {
  const _WelcomeSection({required this.totalBookmarks});

  final int totalBookmarks;

  @override
  Widget build(BuildContext context) {
    final session = SessionScope.of(context);
    return ListenableBuilder(
      listenable: session,
      builder: (context, _) {
        final username = session.currentUser?.username ?? '';
        return Material(
          clipBehavior: Clip.antiAlias,
          color: context.colorScheme.primaryContainer.withValues(
            alpha: context.isDark ? 0.34 : 0.7,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            side: BorderSide(
              color: context.colorScheme.primary.withValues(alpha: 0.12),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: context.colorScheme.primary,
                  child: FaIcon(
                    FontAwesomeIcons.solidUser,
                    size: AppIconSize.lg,
                    color: context.colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppAnimatedText(
                        text: context.l10n.homeWelcome(username),
                        type: AppAnimatedTextType.fade,
                        textStyle: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: context.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        context.l10n.homeSignedInBody,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.onPrimaryContainer
                              .withValues(alpha: 0.78),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                _BookmarkCountBadge(count: totalBookmarks),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BookmarkCountBadge extends StatelessWidget {
  const _BookmarkCountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 48),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.surface.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            count.toString(),
            style: context.textTheme.titleMedium?.copyWith(
              color: context.colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            context.l10n.homeStatsTotal,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryActionPanel extends StatelessWidget {
  const _PrimaryActionPanel({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      clipBehavior: Clip.antiAlias,
      color: context.colorScheme.surfaceContainerHighest.withValues(
        alpha: context.isDark ? 0.28 : 0.5,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(
          color: context.colorScheme.outlineVariant.withValues(alpha: 0.36),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: context.colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: FaIcon(
                FontAwesomeIcons.solidBookmark,
                size: AppIconSize.md,
                color: context.colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                context.l10n.homeMyBookmarks,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            AppButton(
              label: context.l10n.homeMyBookmarks,
              icon: FontAwesomeIcons.arrowRight,
              variant: AppButtonVariant.tonal,
              size: AppButtonSize.small,
              onPressed: onPressed,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsDashboard extends StatelessWidget {
  const _StatsDashboard({required this.state});

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cards = [
          _StatCard(
            icon: FontAwesomeIcons.solidBookmark,
            value: state.totalBookmarks.toString(),
            label: context.l10n.homeStatsTotal,
            color: context.colorScheme.primary,
          ).animateSlideUp(delay: 180.ms),
          _StatCard(
            icon: FontAwesomeIcons.clock,
            value: state.recentBookmarks.toString(),
            label: context.l10n.homeStatsRecent,
            color: context.semanticColors.success,
          ).animateSlideUp(delay: 260.ms),
          _StatCard(
            icon: FontAwesomeIcons.tag,
            value: state.uniqueTags.toString(),
            label: context.l10n.homeStatsTags,
            color: context.semanticColors.info,
          ).animateSlideUp(delay: 340.ms),
        ];

        if (constraints.maxWidth < 420) {
          return Column(
            children: [
              for (final (index, card) in cards.indexed) ...[
                if (index > 0) const SizedBox(height: AppSpacing.sm),
                SizedBox(height: 82, child: card),
              ],
            ],
          );
        }

        return SizedBox(
          height: 92,
          child: Row(
            children: [
              for (final (index, card) in cards.indexed) ...[
                if (index > 0) const SizedBox(width: AppSpacing.sm),
                Expanded(child: card),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final FaIconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      clipBehavior: Clip.antiAlias,
      color: context.colorScheme.surfaceContainerHighest.withValues(
        alpha: context.isDark ? 0.32 : 0.48,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(
          color: context.colorScheme.outlineVariant.withValues(alpha: 0.36),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: FaIcon(
                icon,
                size: AppIconSize.md,
                color: color,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: context.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.labelMedium?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentBookmarksSection extends StatelessWidget {
  const _RecentBookmarksSection({
    required this.recentItems,
    required this.isEmpty,
    required this.animationDelay,
  });

  static const double _carouselHeight = 188;

  final List<BookmarkSummary> recentItems;
  final bool isEmpty;
  final Duration animationDelay;

  @override
  Widget build(BuildContext context) {
    if (isEmpty) {
      return Material(
        clipBehavior: Clip.antiAlias,
        color: context.colorScheme.surfaceContainerHighest.withValues(
          alpha: context.isDark ? 0.28 : 0.46,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(
            color: context.colorScheme.outlineVariant.withValues(alpha: 0.36),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Row(
            children: [
              FaIcon(
                FontAwesomeIcons.bookmark,
                color: context.colorScheme.outline,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  context.l10n.homeNoBookmarks,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ).animateFadeIn(delay: animationDelay);
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            FaIcon(
              FontAwesomeIcons.clockRotateLeft,
              size: AppIconSize.sm,
              color: context.colorScheme.primary,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                context.l10n.homeRecentBookmarks,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ).animateFadeIn(delay: animationDelay),
        const SizedBox(height: AppSpacing.md),
        AppCarousel(
          items: recentItems
              .map((b) => _BookmarkCarouselCard(bookmark: b))
              .toList(),
          showIndicators: recentItems.length > 1,
          height: _carouselHeight,
          viewportFraction: 0.92,
        ).animateFadeIn(delay: animationDelay + 200.ms),
      ],
    );
  }
}

class _BookmarkCarouselCard extends StatelessWidget {
  const _BookmarkCarouselCard({required this.bookmark});

  final BookmarkSummary bookmark;

  @override
  Widget build(BuildContext context) {
    final visibleTags = bookmark.tags.take(3).toList();
    final hiddenCount = bookmark.tags.length - visibleTags.length;

    return Material(
      clipBehavior: Clip.antiAlias,
      color: context.colorScheme.surfaceContainerHighest.withValues(
        alpha: context.isDark ? 0.32 : 0.52,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(
          color: context.colorScheme.outlineVariant.withValues(alpha: 0.36),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: () => BookmarkDetailRoute(bookmark.id).push<void>(context),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                bookmark.title,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                bookmark.url,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: Text(
                  bookmark.description.isNotEmpty
                      ? bookmark.description
                      : context.l10n.homeNoDescription,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (visibleTags.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    for (final tag in visibleTags) _RecentTag(label: tag),
                    if (hiddenCount > 0) _RecentTag(label: '+$hiddenCount'),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentTag extends StatelessWidget {
  const _RecentTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.secondaryContainer.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.textTheme.labelSmall?.copyWith(
          color: context.colorScheme.onSecondaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
