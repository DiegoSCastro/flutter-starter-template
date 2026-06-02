import 'dart:io';

import 'package:analytics/analytics.dart';
import 'package:app_platform/app_platform.dart';
import 'package:app_ui/app_ui.dart';
import 'package:architecture/architecture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/build_context_extensions.dart';
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
      child: InkWell(
        onTap: onTap,
        onLongPress: () => _showItemMenu(context, bookmark),
        child: Container(
          color: selected ? context.colorScheme.secondaryContainer.withValues(alpha: 0.3) : Colors.transparent,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      bookmark.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: selected ? context.colorScheme.onSecondaryContainer : context.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  if (bookmark.isPendingSync)
                    Padding(
                      padding: const EdgeInsets.only(left: AppSpacing.sm),
                      child: Tooltip(
                        message: context.l10n.bookmarksNotYetSynced,
                        child: FaIcon(
                          FontAwesomeIcons.cloudArrowUp,
                          size: 16,
                          color: context.colorScheme.outline,
                        ),
                      ),
                    ),
                  if (selected)
                    Padding(
                      padding: const EdgeInsets.only(left: AppSpacing.sm),
                      child: FaIcon(
                        FontAwesomeIcons.check,
                        size: 16,
                        color: context.colorScheme.onSecondaryContainer,
                      ),
                    ),
                ],
              ),
              if (bookmark.description.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  bookmark.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              if (bookmark.tags.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: bookmark.tags.map((tag) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
                    decoration: BoxDecoration(
                      color: context.colorScheme.primaryContainer.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      '#$tag',
                      style: context.textTheme.labelSmall?.copyWith(
                        color: context.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  )).toList(),
                ),
              ],
              if (bookmark.imageUrls.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                _ReadOnlyMedia(imageUrls: bookmark.imageUrls),
              ],
              const SizedBox(height: AppSpacing.sm),
              AppLinkPreview(
                url: bookmark.url,
                onTap: (_) => onTap(),
                minWidth: double.infinity,
                maxWidth: double.infinity,
              ),
            ],
          ),
        ),
      ),
    ).animateStaggerItem(index);
  }
}

class _ReadOnlyMedia extends StatelessWidget {
  const _ReadOnlyMedia({required this.imageUrls});

  final List<String> imageUrls;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: imageUrls.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final path = imageUrls[index];
          return ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: path.startsWith('http')
                ? AppNetworkImage(
                    imageUrl: path,
                    fit: BoxFit.cover,
                    width: 200,
                    height: 200,
                  )
                : Image.file(
                    File(path),
                    fit: BoxFit.cover,
                    width: 200,
                    height: 200,
                  ),
          );
        },
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
            leading: const FaIcon(FontAwesomeIcons.shareNodes),
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
