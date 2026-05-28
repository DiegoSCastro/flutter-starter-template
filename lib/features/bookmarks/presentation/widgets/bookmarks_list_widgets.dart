import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/router.dart';
import '../../../../core/analytics/analytics_events.dart';
import '../../../../core/analytics/analytics_service.dart';
import '../../../../core/animation/widget_animations.dart';
import '../../../../core/build_context_extensions.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/share/share_service.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/bookmark.dart';
import '../../domain/services/bookmarks_sync_controller.dart';
import '../cubit/bookmarks_list/bookmarks_list_cubit.dart';
import '../cubit/bookmarks_list/bookmarks_list_state.dart';

Future<void> _showItemMenu(BuildContext context, Bookmark bookmark) async {
  final result = await showModalBottomSheet<String>(
    context: context,
    builder: (_) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share'),
            onTap: () => Navigator.pop(context, 'share'),
          ),
        ],
      ),
    ),
  );
  if (result != 'share' || !context.mounted) return;
  unawaited(
    getIt<AnalyticsService>().logEvent(
      AnalyticsEvents.bookmarkShared,
      parameters: {
        AnalyticsParams.bookmarkId: bookmark.id,
        AnalyticsParams.source: AnalyticsSources.list,
      },
    ),
  );
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
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      context.read<BookmarksListCubit>().setQuery(value);
    });
  }

  Future<void> _openNew() async {
    final changed = await const BookmarkNewRoute().push<bool>(context);
    if (changed == true && mounted) {
      await context.read<BookmarksListCubit>().load();
    }
  }

  Future<void> _openDetail(Bookmark bookmark) async {
    final changed = await BookmarkDetailRoute(bookmark.id).push<bool>(context);
    if (changed == true && mounted) {
      await context.read<BookmarksListCubit>().load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Bookmarks',
      padding: EdgeInsets.zero,
      actions: [
        BlocBuilder<BookmarksListCubit, BookmarksListState>(
          buildWhen: (a, b) => a.syncStatus != b.syncStatus,
          builder: (context, state) =>
              _SyncStatusIcon(status: state.syncStatus),
        ),
      ],
      floatingActionButton: FloatingActionButton(
        onPressed: _openNew,
        child: const Icon(Icons.add),
      ).animateScale(delay: 300.ms),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: AppTextField(
              controller: _searchController,
              hint: 'Search title, URL, or tag',
              prefixIcon: Icons.search,
              onChanged: _onSearchChanged,
            ),
          ).animateSlideDown(duration: 300.ms),
          Expanded(
            child: BlocBuilder<BookmarksListCubit, BookmarksListState>(
              builder: (context, state) {
                if (state.isLoading && state.items.isEmpty) {
                  return const AppLoading();
                }
                if (state.failure != null && state.items.isEmpty) {
                  return AppErrorView(
                    message: state.failure!.message,
                    onRetry: () => context.read<BookmarksListCubit>().load(),
                  );
                }
                final visible = state.visibleItems;
                if (visible.isEmpty) {
                  final isFiltered = state.query.trim().isNotEmpty;
                  return AppEmptyView(
                    icon: isFiltered
                        ? Icons.search_off
                        : Icons.bookmark_outline,
                    title: isFiltered ? 'No matches' : 'No bookmarks yet',
                    message: isFiltered
                        ? 'No bookmarks match your search.'
                        : 'Tap + to add your first bookmark.',
                  );
                }
                return RefreshIndicator(
                  onRefresh: () => context.read<BookmarksListCubit>().load(),
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
                                context.read<BookmarksListCubit>().delete(b.id);
                              },
                            ),
                          ],
                          child: ListTile(
                            leading: b.isPendingSync
                                ? Tooltip(
                                    message: 'Not yet synced',
                                    child: Icon(
                                      Icons.cloud_off,
                                      color: context.colorScheme.outline,
                                    ),
                                  )
                                : null,
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
                            onTap: () => _openDetail(b),
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
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context, String title) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete bookmark?'),
            content: Text('"$title" will be removed.'),
            actions: [
              AppButton(
                label: 'Cancel',
                variant: AppButtonVariant.text,
                onPressed: () => Navigator.of(ctx).pop(false),
              ),
              AppButton(
                label: 'Delete',
                variant: AppButtonVariant.tonal,
                onPressed: () => Navigator.of(ctx).pop(true),
              ),
            ],
          ),
        ) ??
        false;
  }
}

class _SyncStatusIcon extends StatelessWidget {
  const _SyncStatusIcon({required this.status});

  final BookmarksSyncStatus status;

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      BookmarksSyncStatus.syncing => const Padding(
        padding: EdgeInsets.only(right: 12),
        child: SizedBox(
          width: 18,
          height: 18,
          child: Center(
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      ),
      BookmarksSyncStatus.error => IconButton(
        tooltip: 'Sync failed — tap to retry',
        icon: const Icon(Icons.cloud_off),
        onPressed: () => context.read<BookmarksListCubit>().retrySync(),
      ),
      BookmarksSyncStatus.idle => const SizedBox.shrink(),
    };
  }
}
