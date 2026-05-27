import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/animation/widget_animations.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../bookmarks/domain/entities/bookmark.dart';
import '../../../bookmarks/presentation/cubit/bookmarks_list_cubit.dart';
import '../../../bookmarks/presentation/cubit/bookmarks_list_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<BookmarksListCubit>()..load(),
      child: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);
    return AppScaffold(
      title: l.homeAppBarTitle,
      actions: const [_ProfileAvatarButton()],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) {
                final username = state is AuthAuthenticated
                    ? state.user.username
                    : '';
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ).animateScale(delay: 100.ms),
                    const SizedBox(height: 16),
                    Text(
                      l.homeWelcome(username),
                      style: theme.textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ).animateSlideDown(delay: 200.ms),
                    const SizedBox(height: 8),
                    Text(
                      l.homeSignedInBody,
                      style: theme.textTheme.bodyMedium,
                    ).animateFadeIn(delay: 300.ms),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),
            AppButton(
              label: 'My bookmarks',
              icon: Icons.bookmark_outline,
              onPressed: () => context.push('/bookmarks'),
            ).animateSlideUp(delay: 400.ms),
            const SizedBox(height: 40),
            _RecentBookmarksSection(animationDelay: 500.ms),
          ],
        ),
      ),
    );
  }
}

class _RecentBookmarksSection extends StatelessWidget {
  const _RecentBookmarksSection({required this.animationDelay});

  final Duration animationDelay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);
    return BlocBuilder<BookmarksListCubit, BookmarksListState>(
      builder: (context, state) {
        if (state.isLoading && state.items.isEmpty) {
          return const SizedBox.shrink();
        }
        final recent = state.items.take(3).toList();
        if (recent.isEmpty) {
          return Text(
            l.homeNoBookmarks,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ).animateFadeIn(delay: animationDelay);
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l.homeRecentBookmarks,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ).animateFadeIn(delay: animationDelay),
            const SizedBox(height: 16),
            AppCarousel(
              items: recent
                  .map((b) => _BookmarkCarouselCard(bookmark: b))
                  .toList(),
              showIndicators: recent.length > 1,
              height: 160,
            ).animateFadeIn(delay: animationDelay + 200.ms),
          ],
        );
      },
    );
  }
}

class _BookmarkCarouselCard extends StatelessWidget {
  const _BookmarkCarouselCard({required this.bookmark});

  final Bookmark bookmark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/bookmarks/${bookmark.id}'),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                bookmark.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                bookmark.url,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  bookmark.description.isNotEmpty
                      ? bookmark.description
                      : 'No description',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (bookmark.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: bookmark.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        tag,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSecondaryContainer,
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

class _ProfileAvatarButton extends StatelessWidget {
  const _ProfileAvatarButton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final username = state is AuthAuthenticated ? state.user.username : '';
        final initial = username.isNotEmpty ? username[0].toUpperCase() : '?';
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: IconButton(
            tooltip: 'Profile',
            onPressed: () => context.push('/profile'),
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                initial,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
