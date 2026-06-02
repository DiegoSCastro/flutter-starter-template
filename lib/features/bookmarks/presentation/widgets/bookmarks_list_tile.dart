import 'package:app_ui/app_ui.dart';
import 'package:core_analytics/core_analytics.dart';
import 'package:core_domain/core_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/build_context_extensions.dart';
import '../../../../core/platform/share/share_service.dart';
import '../../domain/entities/bookmark.dart';
import '../bloc/bookmarks_list/bookmarks_list_bloc.dart';

class BookmarksListTile extends StatelessWidget {
  const BookmarksListTile({
    super.key,
    required this.bookmark,
    required this.index,
    required this.selected,
    required this.onTap,
    required this.onDeleteSelectedBookmark,
  });

  final Bookmark bookmark;
  final int index;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onDeleteSelectedBookmark;

  @override
  Widget build(BuildContext context) {
    return AppSlidable(
      key: ValueKey(bookmark.id),
      groupTag: 'bookmarks',
      endActions: [
        AppSlidableAction.delete(
          onPressed: (_) async {
            final shouldDelete = await _confirmDelete(context, bookmark.title);
            if (!shouldDelete || !context.mounted) return;
            if (selected) onDeleteSelectedBookmark();
            context.read<BookmarksListBloc>().add(
              BookmarksListDeleteRequested(bookmark.id),
            );
          },
        ),
      ],
      child: ListTile(
        selected: selected,
        leading: _BookmarkAvatar(bookmark: bookmark),
        title: Text(
          bookmark.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          bookmark.url,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
        onLongPress: () => _showItemMenu(context, bookmark),
      ),
    ).animateStaggerItem(index);
  }
}

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
