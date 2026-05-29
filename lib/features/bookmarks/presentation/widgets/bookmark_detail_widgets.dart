import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/router.dart';
import '../../../../core/analytics/analytics_extensions.dart';
import '../../../../core/analytics/analytics_service.dart';
import '../../../../core/animation/widget_animations.dart';
import '../../../../core/build_context_extensions.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/media/video_player_service.dart';
import '../../../../core/share/share_service.dart';
import '../../../../core/widgets/app_video_player.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/bookmark.dart';
import '../bloc/bookmark_detail/bookmark_detail_bloc.dart';
import '../bloc/bookmark_detail/bookmark_detail_state.dart';
import 'bookmark_failure_messages.dart';

Future<void> _shareBookmark(Bookmark bookmark) async {
  unawaited(
    getIt<AnalyticsService>().trackBookmarkShared(
      bookmarkId: bookmark.id,
      source: AnalyticsSources.detail,
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
    return BlocListener<BookmarkDetailBloc, BookmarkDetailState>(
      listenWhen: (_, state) => state is BookmarkDetailDeleted,
      listener: (context, state) => context.pop(true),
      child: AppScaffold(
        title: context.l10n.bookmarkAppBarTitle,
        padding: EdgeInsets.zero,
        actions: [
          BlocBuilder<BookmarkDetailBloc, BookmarkDetailState>(
            builder: (context, state) {
              if (state is! BookmarkDetailReady) return const SizedBox.shrink();
              return Row(
                children: [
                  IconButton(
                    tooltip: context.l10n.commonShare,
                    icon: const Icon(Icons.share),
                    onPressed: () => _shareBookmark(state.bookmark),
                  ),
                  IconButton(
                    tooltip: context.l10n.commonEdit,
                    icon: const Icon(Icons.edit),
                    onPressed: () => _openEditor(context),
                  ),
                  IconButton(
                    tooltip: context.l10n.commonDelete,
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _confirmAndDelete(context, state.bookmark),
                  ),
                ],
              );
            },
          ),
        ],
        body: BlocBuilder<BookmarkDetailBloc, BookmarkDetailState>(
          builder: (context, state) {
            return switch (state) {
              BookmarkDetailLoading() => const AppLoading(),
              BookmarkDetailFailure(:final failure) => AppErrorView(
                message: bookmarkFailureMessage(context, failure),
                onRetry: () => context.read<BookmarkDetailBloc>().load(id),
              ),
              BookmarkDetailReady(:final bookmark) ||
              BookmarkDetailDeleting(:final bookmark) => _DetailBody(
                bookmark: bookmark,
              ),
              BookmarkDetailDeleted() => const AppLoading(),
            };
          },
        ),
      ),
    );
  }

  Future<void> _openEditor(BuildContext context) async {
    final changed = await BookmarkEditRoute(id).push<bool>(context);
    if (changed == true && context.mounted) {
      await context.read<BookmarkDetailBloc>().load(id);
    }
  }

  Future<void> _confirmAndDelete(BuildContext context, Bookmark b) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.bookmarkDeleteDialogTitle),
        content: Text(l10n.bookmarkDeleteDialogMessage(b.title)),
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
    );
    if (confirmed != true) return;
    if (!context.mounted) return;
    unawaited(context.read<BookmarkDetailBloc>().delete(b.id));
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
          if (bookmark.videoUrl != null && bookmark.videoUrl!.isNotEmpty)
            _VideoSection(
              videoUrl: bookmark.videoUrl!,
            ).animateFadeIn(delay: 275.ms),
          if (bookmark.imageUrls.isNotEmpty) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: bookmark.imageUrls.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final path = bookmark.imageUrls[index];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
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
            ).animateFadeIn(delay: 300.ms),
          ],
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
            label: context.l10n.bookmarkOpenUrl,
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
      _toast(context, context.l10n.bookmarkInvalidUrl);
      return;
    }
    unawaited(
      getIt<AnalyticsService>().trackBookmarkOpened(
        bookmarkId: bookmark.id,
        source: AnalyticsSources.detail,
      ),
    );
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      _toast(context, context.l10n.bookmarkCouldNotOpenUrl);
    }
  }

  void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _VideoSection extends StatefulWidget {
  const _VideoSection({required this.videoUrl});

  final String videoUrl;

  @override
  State<_VideoSection> createState() => _VideoSectionState();
}

class _VideoSectionState extends State<_VideoSection> {
  AppVideoPlayerController? _videoPlayerController;

  @override
  void initState() {
    super.initState();
    final service = getIt<VideoPlayerService>();
    final uri = Uri.tryParse(widget.videoUrl);
    if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
      _videoPlayerController = service.network(uri);
    } else {
      _videoPlayerController = service.file(File(widget.videoUrl));
    }
    _videoPlayerController?.initialize().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _videoPlayerController;
    if (controller == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          'Attached Video',
          style: context.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: AppVideoPlayer(controller: controller),
        ),
      ],
    );
  }
}
