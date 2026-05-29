import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/router.dart';
import '../../../../core/analytics/analytics_extensions.dart';
import '../../../../core/analytics/analytics_service.dart';
import '../../../../core/animation/widget_animations.dart';
import '../../../../core/build_context_extensions.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/future_extensions.dart';
import '../../../../core/share/share_service.dart';
import '../../../../core/theme/app_icon_size.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/bookmark.dart';
import '../../domain/services/bookmarks_sync_controller.dart';
import '../bloc/bookmarks_list/bookmarks_list_bloc.dart';
import '../bloc/bookmarks_list/bookmarks_list_state.dart';
import 'bookmark_detail_widgets.dart';
import 'bookmark_failure_messages.dart';

Future<void> _showItemMenu(BuildContext context, Bookmark bookmark) async {
  final l10n = context.l10n;
  final result = await showModalBottomSheet<String>(
    context: context,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.share),
            title: Text(l10n.commonShare),
            onTap: () => Navigator.pop(sheetContext, 'share'),
          ),
        ],
      ),
    ),
  );
  if (result != 'share' || !context.mounted) return;
  getIt<AnalyticsService>()
      .trackBookmarkShared(
        bookmarkId: bookmark.id,
        source: AnalyticsSources.list,
      )
      .uw();
  final content = bookmark.description.isNotEmpty
      ? '${bookmark.title}\n${bookmark.url}\n\n${bookmark.description}'
      : '${bookmark.title}\n${bookmark.url}';
  await getIt<ShareService>().share(text: content, subject: bookmark.title);
}

class BookmarksListView extends StatefulWidget {
  const BookmarksListView({super.key});

  @override
  State<BookmarksListView> createState() => _BookmarksListViewState();
}

class _BookmarksListViewState extends State<BookmarksListView> {
  static const double _twoPaneMinWidth = 700;

  final _searchController = TextEditingController();
  Timer? _debounce;
  String? _selectedId;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      context.read<BookmarksListBloc>().add(BookmarksListQueryChanged(value));
    });
  }

  void _clearSearch() {
    _debounce?.cancel();
    _searchController.clear();
    context.read<BookmarksListBloc>().add(const BookmarksListQueryChanged(''));
  }

  Future<void> _reload() {
    final bloc = context.read<BookmarksListBloc>();
    final completion = bloc.stream.firstWhere((state) => !state.isLoading);
    bloc.add(const BookmarksListLoadRequested());
    return completion.then((_) {});
  }

  Future<void> _openNew() async {
    final changed = await const BookmarkNewRoute().push<bool>(context);
    if (changed == true && mounted) {
      await _reload();
    }
  }

  Future<void> _openDetail(Bookmark bookmark) async {
    final changed = await BookmarkDetailRoute(bookmark.id).push<bool>(context);
    if (changed == true && mounted) {
      await _reload();
    }
  }

  void _onItemTap(Bookmark bookmark, {required bool twoPane}) {
    if (twoPane) {
      setState(() => _selectedId = bookmark.id);
    } else {
      _openDetail(bookmark);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: context.l10n.bookmarksAppBarTitle,
      padding: EdgeInsets.zero,
      actions: [
        BlocBuilder<BookmarksListBloc, BookmarksListState>(
          buildWhen: (a, b) => a.syncStatus != b.syncStatus,
          builder: (context, state) =>
              _SyncStatusIcon(status: state.syncStatus),
        ),
        BlocBuilder<BookmarksListBloc, BookmarksListState>(
          buildWhen: (a, b) => a.sort != b.sort,
          builder: (context, state) => _SortMenuButton(sort: state.sort),
        ),
      ],
      floatingActionButton: FloatingActionButton(
        onPressed: _openNew,
        tooltip: context.l10n.bookmarksAddTooltip,
        child: const Icon(Icons.add),
      ).animateScale(delay: 300.ms),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final twoPane = constraints.maxWidth >= _twoPaneMinWidth;
          return AppListDetailPane(
            twoPaneMinWidth: _twoPaneMinWidth,
            master: _buildMaster(twoPane: twoPane),
            detail: twoPane && _selectedId != null
                ? BookmarkDetailPane(
                    key: ValueKey(_selectedId),
                    id: _selectedId!,
                    onDeleted: () {
                      setState(() => _selectedId = null);
                      _reload().uw();
                    },
                    onEdited: _reload,
                  )
                : null,
            placeholder: const _DetailPlaceholder(),
          );
        },
      ),
    );
  }

  Widget _buildMaster({required bool twoPane}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.xs,
          ),
          child: AppTextField(
            controller: _searchController,
            hint: context.l10n.bookmarksSearchHint,
            prefixIcon: Icons.search,
            onChanged: _onSearchChanged,
            suffix: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _searchController,
              builder: (context, value, _) {
                if (value.text.isEmpty) return const SizedBox.shrink();
                return IconButton(
                  icon: const Icon(Icons.clear),
                  tooltip: context.l10n.bookmarksSearchClear,
                  onPressed: _clearSearch,
                );
              },
            ),
          ),
        ).animateSlideDown(duration: 300.ms),
        Expanded(
          child: BlocBuilder<BookmarksListBloc, BookmarksListState>(
            builder: (context, state) {
              if (state.isLoading && state.items.isEmpty) {
                return const AppSkeletonList(hasLeading: false);
              }
              if (state.failure != null && state.items.isEmpty) {
                return AppErrorView(
                  message: bookmarkFailureMessage(context, state.failure!),
                  onRetry: () => context.read<BookmarksListBloc>().add(
                    const BookmarksListLoadRequested(),
                  ),
                );
              }
              final visible = state.visibleItems;
              if (visible.isEmpty) {
                final isFiltered = state.query.trim().isNotEmpty;
                return AppEmptyView(
                  icon: isFiltered ? Icons.search_off : Icons.bookmark_outline,
                  title: isFiltered
                      ? context.l10n.bookmarksNoMatchesTitle
                      : context.l10n.bookmarksEmptyTitle,
                  message: isFiltered
                      ? context.l10n.bookmarksNoMatchesMessage
                      : context.l10n.bookmarksEmptyMessage,
                );
              }
              return RefreshIndicator(
                onRefresh: _reload,
                child: AppSlidableAutoCloseGroup(
                  child: ListView.separated(
                    itemCount: visible.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final b = visible[index];
                      return AppSlidable(
                        key: ValueKey(b.id),
                        groupTag: 'bookmarks',
                        endActions: [
                          AppSlidableAction.delete(
                            onPressed: (_) async {
                              final shouldDelete = await _confirmDelete(
                                context,
                                b.title,
                              );
                              if (!shouldDelete || !context.mounted) return;
                              if (_selectedId == b.id) {
                                setState(() => _selectedId = null);
                              }
                              context.read<BookmarksListBloc>().add(
                                BookmarksListDeleteRequested(b.id),
                              );
                            },
                          ),
                        ],
                        child: ListTile(
                          selected: twoPane && b.id == _selectedId,
                          leading: _BookmarkAvatar(bookmark: b),
                          title: Text(
                            b.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            b.url,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _onItemTap(b, twoPane: twoPane),
                          onLongPress: () => _showItemMenu(context, b),
                        ),
                      ).animateStaggerItem(index);
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<bool> _confirmDelete(BuildContext context, String title) async {
    final l10n = context.l10n;
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.bookmarkDeleteDialogTitle),
            content: Text(l10n.bookmarkDeleteDialogMessage(title)),
            actions: [
              AppButton(
                label: l10n.commonCancel,
                variant: AppButtonVariant.text,
                onPressed: () => Navigator.of(ctx).pop(false),
              ),
              AppButton(
                label: l10n.commonDelete,
                variant: AppButtonVariant.tonal,
                onPressed: () => Navigator.of(ctx).pop(true),
              ),
            ],
          ),
        ) ??
        false;
  }
}

class _DetailPlaceholder extends StatelessWidget {
  const _DetailPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.bookmark_outline,
            size: AppIconSize.xxxl,
            color: context.colorScheme.outline,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            context.l10n.bookmarksDetailPlaceholder,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Leading avatar for a bookmark row: the title's initial, overlaid with a
/// small cloud badge while the bookmark is still pending sync.
class _BookmarkAvatar extends StatelessWidget {
  const _BookmarkAvatar({required this.bookmark});

  final Bookmark bookmark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = bookmark.title.trim();
    final initial = title.isNotEmpty ? title[0].toUpperCase() : '#';
    final avatar = CircleAvatar(
      backgroundColor: theme.colorScheme.secondaryContainer,
      foregroundColor: theme.colorScheme.onSecondaryContainer,
      child: Text(initial),
    );
    if (!bookmark.isPendingSync) return avatar;
    return Tooltip(
      message: context.l10n.bookmarksNotYetSynced,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_off,
                size: 14,
                color: theme.colorScheme.outline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SortMenuButton extends StatelessWidget {
  const _SortMenuButton({required this.sort});

  final BookmarkSort sort;

  String _labelFor(BuildContext context, BookmarkSort value) => switch (value) {
    BookmarkSort.newest => context.l10n.bookmarksSortNewest,
    BookmarkSort.oldest => context.l10n.bookmarksSortOldest,
    BookmarkSort.titleAz => context.l10n.bookmarksSortTitleAz,
  };

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<BookmarkSort>(
      icon: const Icon(Icons.sort),
      tooltip: context.l10n.bookmarksSortTooltip,
      initialValue: sort,
      onSelected: (value) => context.read<BookmarksListBloc>().add(
        BookmarksListSortChanged(value),
      ),
      itemBuilder: (context) => [
        for (final value in BookmarkSort.values)
          CheckedPopupMenuItem<BookmarkSort>(
            value: value,
            checked: value == sort,
            child: Text(_labelFor(context, value)),
          ),
      ],
    );
  }
}

class _SyncStatusIcon extends StatelessWidget {
  const _SyncStatusIcon({required this.status});

  static const double _slotSize = 18;
  static const double _spinnerSize = 16;

  final BookmarksSyncStatus status;

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      BookmarksSyncStatus.syncing => const Padding(
        padding: EdgeInsets.only(right: AppSpacing.md),
        child: SizedBox(
          width: _slotSize,
          height: _slotSize,
          child: Center(
            child: SizedBox(
              width: _spinnerSize,
              height: _spinnerSize,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      ),
      BookmarksSyncStatus.error => IconButton(
        tooltip: context.l10n.bookmarksSyncFailedRetryTooltip,
        icon: const Icon(Icons.cloud_off),
        onPressed: () => context.read<BookmarksListBloc>().add(
          const BookmarksListSyncRetried(),
        ),
      ),
      BookmarksSyncStatus.idle => const SizedBox.shrink(),
    };
  }
}
