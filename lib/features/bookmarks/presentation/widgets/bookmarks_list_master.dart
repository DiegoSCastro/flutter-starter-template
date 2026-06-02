import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/build_context_extensions.dart';
import '../../domain/entities/bookmark.dart';
import '../bloc/bookmarks_list/bookmarks_list_bloc.dart';
import '../bloc/bookmarks_list/bookmarks_list_state.dart';
import 'bookmark_failure_messages.dart';
import 'bookmarks_list_tile.dart';

class BookmarksListMaster extends StatelessWidget {
  const BookmarksListMaster({
    super.key,
    required this.searchController,
    required this.selectedId,
    required this.twoPane,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onReload,
    required this.onItemTap,
    required this.onDeletedSelected,
  });

  final TextEditingController searchController;
  final String? selectedId;
  final bool twoPane;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final Future<void> Function() onReload;
  final ValueChanged<Bookmark> onItemTap;
  final VoidCallback onDeletedSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _BookmarksSearchField(
          controller: searchController,
          onChanged: onSearchChanged,
          onClear: onClearSearch,
        ),
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
                return _BookmarksEmptyState(query: state.query);
              }
              return RefreshIndicator(
                onRefresh: onReload,
                child: AppSlidableAutoCloseGroup(
                  child: ListView.separated(
                    itemCount: visible.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final bookmark = visible[index];
                      return BookmarksListTile(
                        bookmark: bookmark,
                        index: index,
                        selected: twoPane && bookmark.id == selectedId,
                        onTap: () => onItemTap(bookmark),
                        onDeleteSelectedBookmark: onDeletedSelected,
                      );
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
}

class _BookmarksSearchField extends StatelessWidget {
  const _BookmarksSearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xs,
      ),
      child: AppTextField(
        controller: controller,
        hint: context.l10n.bookmarksSearchHint,
        prefixIcon: Icons.search,
        onChanged: onChanged,
        suffix: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) {
            if (value.text.isEmpty) return const SizedBox.shrink();
            return IconButton(
              icon: const Icon(Icons.clear),
              tooltip: context.l10n.bookmarksSearchClear,
              onPressed: onClear,
            );
          },
        ),
      ),
    ).animateSlideDown(duration: 300.ms);
  }
}

class _BookmarksEmptyState extends StatelessWidget {
  const _BookmarksEmptyState({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final isFiltered = query.trim().isNotEmpty;
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
}
