import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/router.dart';
import '../../../../core/extensions/build_context_extensions.dart';
import '../../../../shared/domain/bookmark_stats.dart';
import '../../../../shared/presentation/session_scope.dart';
import '../../../../ui/animation/widget_animations.dart';
import '../../../../ui/theme/app_icon_size.dart';
import '../../../../ui/theme/app_radius.dart';
import '../../../../ui/theme/app_spacing.dart';
import '../../../../ui/widgets/widgets.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_state.dart';

class HomeBody extends StatelessWidget {
  const HomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: context.l10n.homeAppBarTitle,
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: AppSpacing.xxl),
                const _WelcomeSection(),
                const SizedBox(height: AppSpacing.xxxl),
                _StatsDashboard(state: state),
                const SizedBox(height: AppSpacing.xxxl),
                AppButton(
                  label: context.l10n.homeMyBookmarks,
                  icon: Icons.bookmark_outline,
                  onPressed: () =>
                      const BookmarksListRoute().push<void>(context),
                ).animateSlideUp(delay: 400.ms),
                const SizedBox(height: AppSpacing.xxxxl),
                _RecentBookmarksSection(
                  recentItems: state.recentItems,
                  isEmpty: state.totalBookmarks == 0,
                  animationDelay: 500.ms,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _WelcomeSection extends StatelessWidget {
  const _WelcomeSection();

  @override
  Widget build(BuildContext context) {
    final session = SessionScope.of(context);
    return ListenableBuilder(
      listenable: session,
      builder: (context, _) {
        final username = session.currentUser?.username ?? '';
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: AppIconSize.xxl,
              backgroundColor: context.colorScheme.primaryContainer,
              child: Icon(
                Icons.person,
                size: AppIconSize.xxl,
                color: context.colorScheme.onPrimaryContainer,
              ),
            ).animateScale(delay: 100.ms),
            const SizedBox(height: AppSpacing.lg),
            AppAnimatedText(
              text: context.l10n.homeWelcome(username),
              type: AppAnimatedTextType.typewriter,
              textStyle: context.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppAnimatedText(
              text: context.l10n.homeSignedInBody,
              type: AppAnimatedTextType.fade,
              textStyle: context.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        );
      },
    );
  }
}

class _StatsDashboard extends StatelessWidget {
  const _StatsDashboard({required this.state});

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.bookmark,
            value: state.totalBookmarks.toString(),
            label: context.l10n.homeStatsTotal,
          ).animateSlideLeft(delay: 200.ms),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _StatCard(
            icon: Icons.schedule,
            value: state.recentBookmarks.toString(),
            label: context.l10n.homeStatsRecent,
          ).animateSlideUp(delay: 300.ms),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _StatCard(
            icon: Icons.label_outline,
            value: state.uniqueTags.toString(),
            label: context.l10n.homeStatsTags,
          ).animateSlideRight(delay: 400.ms),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.xl,
          horizontal: AppSpacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: AppIconSize.xl,
              color: context.colorScheme.primary,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              value,
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: context.textTheme.labelMedium?.copyWith(
                color: context.colorScheme.onSurface.withValues(alpha: 0.7),
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

  static const double _carouselHeight = 160;

  final List<BookmarkSummary> recentItems;
  final bool isEmpty;
  final Duration animationDelay;

  @override
  Widget build(BuildContext context) {
    if (isEmpty) {
      return Text(
        context.l10n.homeNoBookmarks,
        style: context.textTheme.bodyMedium?.copyWith(
          color: context.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ).animateFadeIn(delay: animationDelay);
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            context.l10n.homeRecentBookmarks,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ).animateFadeIn(delay: animationDelay),
        const SizedBox(height: AppSpacing.lg),
        AppCarousel(
          items: recentItems
              .map((b) => _BookmarkCarouselCard(bookmark: b))
              .toList(),
          showIndicators: recentItems.length > 1,
          height: _carouselHeight,
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
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
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
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                bookmark.url,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.primary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: Text(
                  bookmark.description.isNotEmpty
                      ? bookmark.description
                      : context.l10n.homeNoDescription,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (bookmark.tags.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: bookmark.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: context.colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        tag,
                        style: context.textTheme.labelSmall?.copyWith(
                          color: context.colorScheme.onSecondaryContainer,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
