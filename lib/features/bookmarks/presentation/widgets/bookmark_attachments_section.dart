import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/build_context_extensions.dart';
import '../../../../core/theme/app_icon_size.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/widgets.dart';
import '../bloc/bookmark_form/bookmark_form_bloc.dart';
import '../bloc/bookmark_form/bookmark_form_state.dart';
import 'bookmark_video_attachment_preview.dart';

class BookmarkAttachmentsSection extends StatelessWidget {
  const BookmarkAttachmentsSection({super.key, required this.state});

  final BookmarkFormState state;

  @override
  Widget build(BuildContext context) {
    final videoUrl = state.videoUrl;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Attachments', style: context.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        if (state.imageUrls.isNotEmpty) ...[
          _ImageAttachmentList(paths: state.imageUrls),
          const SizedBox(height: AppSpacing.sm),
        ],
        if (videoUrl != null && videoUrl.isNotEmpty) ...[
          BookmarkVideoAttachmentPreview(videoUrl: videoUrl),
          const SizedBox(height: AppSpacing.sm),
        ],
        const _AttachmentActionButtons(),
      ],
    );
  }
}

class _ImageAttachmentList extends StatelessWidget {
  const _ImageAttachmentList({required this.paths});

  static const double _thumbnailSize = 100;

  final List<String> paths;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _thumbnailSize,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: paths.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final path = paths[index];
          return _ImageAttachmentTile(path: path);
        },
      ),
    );
  }
}

class _ImageAttachmentTile extends StatelessWidget {
  const _ImageAttachmentTile({required this.path});

  static const double _thumbnailSize = 100;

  final String path;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: path.startsWith('http')
              ? AppNetworkImage(
                  imageUrl: path,
                  fit: BoxFit.cover,
                  width: _thumbnailSize,
                  height: _thumbnailSize,
                  semanticLabel: context.l10n.bookmarkAttachedImageLabel,
                )
              : Image.file(
                  File(path),
                  fit: BoxFit.cover,
                  width: _thumbnailSize,
                  height: _thumbnailSize,
                ),
        ),
        Positioned(
          top: AppSpacing.xs,
          right: AppSpacing.xs,
          child: Semantics(
            button: true,
            label: context.l10n.bookmarkRemoveImageLabel,
            child: GestureDetector(
              onTap: () => context.read<BookmarkFormBloc>().add(
                BookmarkFormImageRemoved(path),
              ),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.xxs),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: AppIconSize.sm,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AttachmentActionButtons extends StatelessWidget {
  const _AttachmentActionButtons();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => context.read<BookmarkFormBloc>().add(
                  const BookmarkFormImagesPicked(),
                ),
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('Add Images'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => context.read<BookmarkFormBloc>().add(
                  const BookmarkFormCameraImageTaken(),
                ),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Take Photo'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => context.read<BookmarkFormBloc>().add(
                  const BookmarkFormVideoPicked(),
                ),
                icon: const Icon(Icons.video_library),
                label: const Text('Add Video'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => context.read<BookmarkFormBloc>().add(
                  const BookmarkFormCameraVideoTaken(),
                ),
                icon: const Icon(Icons.videocam),
                label: const Text('Record Video'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
