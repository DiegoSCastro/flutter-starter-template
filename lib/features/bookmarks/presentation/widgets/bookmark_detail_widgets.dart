import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/router.dart';
import '../../../../core/analytics/analytics_events.dart';
import '../../../../core/analytics/analytics_service.dart';
import '../../../../core/animation/widget_animations.dart';
import '../../../../core/build_context_extensions.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/share/share_service.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/bookmark.dart';
import '../cubit/bookmark_detail/bookmark_detail_cubit.dart';
import '../cubit/bookmark_detail/bookmark_detail_state.dart';

Future<void> _shareBookmark(Bookmark bookmark) async {
  unawaited(
    getIt<AnalyticsService>().logEvent(
      AnalyticsEvents.bookmarkShared,
      parameters: {
        AnalyticsParams.bookmarkId: bookmark.id,
        AnalyticsParams.source: AnalyticsSources.detail,
      },
    ),
  );
  final content = bookmark.description.isNotEmpty
      ? '${bookmark.title}\n${bookmark.url}\n\n${bookmark.description}'
      : '${bookmark.title}\n${bookmark.url}';
  await getIt<ShareService>().share(text: content, subject: bookmark.title);
}

class BookmarkDetailView extends StatelessWidget {
  const BookmarkDetailView({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Bookmark',
      padding: EdgeInsets.zero,
      actions: [
        BlocBuilder<BookmarkDetailCubit, BookmarkDetailState>(
          builder: (context, state) {
            if (state is! BookmarkDetailReady) return const SizedBox.shrink();
            return Row(
              children: [
                IconButton(
                  tooltip: 'Share',
                  icon: const Icon(Icons.share),
                  onPressed: () => _shareBookmark(state.bookmark),
                ),
                IconButton(
                  tooltip: 'Edit',
                  icon: const Icon(Icons.edit),
                  onPressed: () => _openEditor(context),
                ),
                IconButton(
                  tooltip: 'Delete',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _confirmAndDelete(context, state.bookmark),
                ),
              ],
            );
          },
        ),
      ],
      body: BlocBuilder<BookmarkDetailCubit, BookmarkDetailState>(
        builder: (context, state) {
          return switch (state) {
            BookmarkDetailLoading() => const AppLoading(),
            BookmarkDetailFailure(:final failure) => AppErrorView(
              message: failure.message,
              onRetry: () => context.read<BookmarkDetailCubit>().load(id),
            ),
            BookmarkDetailReady(:final bookmark) => _DetailBody(
              bookmark: bookmark,
            ),
          };
        },
      ),
    );
  }

  Future<void> _openEditor(BuildContext context) async {
    final changed = await BookmarkEditRoute(id).push<bool>(context);
    if (changed == true && context.mounted) {
      await context.read<BookmarkDetailCubit>().load(id);
    }
  }

  Future<void> _confirmAndDelete(BuildContext context, Bookmark b) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete bookmark?'),
        content: Text('"${b.title}" will be removed.'),
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
    );
    if (confirmed != true) return;
    if (!context.mounted) return;
    final ok = await context.read<BookmarkDetailCubit>().delete(b.id);
    if (!ok || !context.mounted) return;
    context.pop(true);
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.bookmark});

  final Bookmark bookmark;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            bookmark.title,
            style: context.textTheme.headlineSmall,
          ).animateSlideDown(),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _openUrl(context, bookmark),
            child: Text(
              bookmark.url,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.primary,
                decoration: TextDecoration.underline,
              ),
            ),
          ).animateFadeIn(delay: 100.ms),
          if (bookmark.description.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              bookmark.description,
              style: context.textTheme.bodyMedium,
            ).animateFadeIn(delay: 200.ms),
          ],
          const SizedBox(height: 16),
          AppLinkPreview(
            url: bookmark.url,
            maxWidth: double.infinity,
            enableAnimation: true,
          ).animateFadeIn(delay: 250.ms),
          if (bookmark.tags.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final tag in bookmark.tags)
                  Chip(label: Text(tag))
                      .animate(delay: 100.ms)
                      .fadeIn(duration: 300.ms)
                      .scale(duration: 300.ms, curve: Curves.easeOut),
              ],
            ),
          ],
          const SizedBox(height: 24),
          AppButton(
            label: 'Open URL',
            icon: Icons.open_in_new,
            expand: true,
            onPressed: () => _openUrl(context, bookmark),
          ).animateSlideUp(delay: 300.ms),
        ],
      ),
    );
  }

  Future<void> _openUrl(BuildContext context, Bookmark bookmark) async {
    final uri = Uri.tryParse(bookmark.url);
    if (uri == null) {
      _toast(context, 'Invalid URL');
      return;
    }
    unawaited(
      getIt<AnalyticsService>().logEvent(
        AnalyticsEvents.bookmarkOpened,
        parameters: {
          AnalyticsParams.bookmarkId: bookmark.id,
          AnalyticsParams.source: AnalyticsSources.detail,
        },
      ),
    );
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      _toast(context, 'Could not open URL');
    }
  }

  void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
