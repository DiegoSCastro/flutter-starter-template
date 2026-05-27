import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/animation/widget_animations.dart';
import '../../../../core/build_context_extensions.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/widgets.dart';
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
    return AppScaffold(
      title: context.l10n.homeAppBarTitle,
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
                      backgroundColor: context.colorScheme.primaryContainer,
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: context.colorScheme.onPrimaryContainer,
                      ),
                    ).animateScale(delay: 100.ms),
                    const SizedBox(height: 16),
                    AppAnimatedText(
                      text: context.l10n.homeWelcome(username),
                      type: AppAnimatedTextType.typewriter,
                      textStyle: context.textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    AppAnimatedText(
                      text: context.l10n.homeSignedInBody,
                      type: AppAnimatedTextType.fade,
                      textStyle: context.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
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
    return BlocBuilder<BookmarksListCubit, BookmarksListState>(
      builder: (context, state) {
        if (state.isLoading && state.items.isEmpty) {
          return const SizedBox.shrink();
        }
        final recent = state.items.take(3).toList();
        if (recent.isEmpty) {
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
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                bookmark.url,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.primary,
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
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurface.withValues(alpha: 0.7),
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
                        color: context.colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(8),
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

class _ProfileAvatarButton extends StatelessWidget {
  const _ProfileAvatarButton();

  @override
  Widget build(BuildContext context) {
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
              backgroundColor: context.colorScheme.primaryContainer,
              child: Text(
                initial,
                style: context.textTheme.labelLarge?.copyWith(
                  color: context.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
