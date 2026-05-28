part of '../screens/home_screen.dart';

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: context.l10n.homeAppBarTitle,
      actions: const [_ProfileAvatarButton()],
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                _WelcomeSection(username: state.username),
                const SizedBox(height: 32),
                _StatsDashboard(state: state),
                const SizedBox(height: 32),
                AppButton(
                  label: 'My bookmarks',
                  icon: Icons.bookmark_outline,
                  onPressed: () => context.push('/bookmarks'),
                ).animateSlideUp(delay: 400.ms),
                const SizedBox(height: 40),
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
  const _WelcomeSection({required this.username});

  final String username;

  @override
  Widget build(BuildContext context) {
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
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.schedule,
            value: state.recentBookmarks.toString(),
            label: context.l10n.homeStatsRecent,
          ).animateSlideUp(delay: 300.ms),
        ),
        const SizedBox(width: 12),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 28, color: context.colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              value,
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
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

  final List<Bookmark> recentItems;
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
        const SizedBox(height: 16),
        AppCarousel(
          items: recentItems
              .map((b) => _BookmarkCarouselCard(bookmark: b))
              .toList(),
          showIndicators: recentItems.length > 1,
          height: 160,
        ).animateFadeIn(delay: animationDelay + 200.ms),
      ],
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
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final username = state.username;
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
