part of '../screens/bookmarks_list_screen.dart';

class _BookmarksListView extends StatefulWidget {
  const _BookmarksListView();

  @override
  State<_BookmarksListView> createState() => _BookmarksListViewState();
}

class _BookmarksListViewState extends State<_BookmarksListView> {
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
        onPressed: () => context.push('/bookmarks/new'),
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
                  child: ListView.separated(
                    itemCount: visible.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final b = visible[index];
                      return Dismissible(
                        key: ValueKey(b.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: context.colorScheme.errorContainer,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Icon(
                            Icons.delete,
                            color: context.colorScheme.onErrorContainer,
                          ),
                        ),
                        confirmDismiss: (_) => _confirmDelete(context, b.title),
                        onDismissed: (_) =>
                            context.read<BookmarksListCubit>().delete(b.id),
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
                          onTap: () => context.push('/bookmarks/${b.id}'),
                        ),
                      ).animateStaggerItem(index);
                    },
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
        onPressed: () => getIt<BookmarksSyncService>().sync(),
      ),
      BookmarksSyncStatus.idle => const SizedBox.shrink(),
    };
  }
}
