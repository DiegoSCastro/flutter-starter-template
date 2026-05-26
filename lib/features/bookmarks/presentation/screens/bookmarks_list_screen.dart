import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../cubit/bookmarks_list_cubit.dart';
import '../cubit/bookmarks_list_state.dart';

class BookmarksListScreen extends StatelessWidget {
  const BookmarksListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<BookmarksListCubit>()..load(),
      child: const _BookmarksListView(),
    );
  }
}

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
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.inversePrimary,
        title: const Text('Bookmarks'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/bookmarks/new'),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search title, URL, or tag',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(
            child: BlocBuilder<BookmarksListCubit, BookmarksListState>(
              builder: (context, state) {
                if (state.isLoading && state.items.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.failure != null && state.items.isEmpty) {
                  return _ErrorView(
                    message: state.failure!.message,
                    onRetry: () => context.read<BookmarksListCubit>().load(),
                  );
                }
                final visible = state.visibleItems;
                if (visible.isEmpty) {
                  return _EmptyView(
                    isFiltered: state.query.trim().isNotEmpty,
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
                          color: theme.colorScheme.errorContainer,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Icon(
                            Icons.delete,
                            color: theme.colorScheme.onErrorContainer,
                          ),
                        ),
                        confirmDismiss: (_) => _confirmDelete(context, b.title),
                        onDismissed: (_) =>
                            context.read<BookmarksListCubit>().delete(b.id),
                        child: ListTile(
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
                      );
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
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton.tonal(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.isFiltered});

  final bool isFiltered;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          isFiltered
              ? 'No bookmarks match your search.'
              : 'No bookmarks yet. Tap + to add one.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
