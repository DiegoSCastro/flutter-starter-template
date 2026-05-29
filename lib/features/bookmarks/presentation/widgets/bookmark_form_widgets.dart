import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/animation/widget_animations.dart';
import '../../../../core/build_context_extensions.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/media/video_player_service.dart';
import '../../../../core/theme/app_icon_size.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_video_player.dart';
import '../../../../core/widgets/widgets.dart';
import '../bloc/bookmark_form/bookmark_form_bloc.dart';
import '../bloc/bookmark_form/bookmark_form_state.dart';
import 'bookmark_failure_messages.dart';

class BookmarkFormView extends StatefulWidget {
  const BookmarkFormView({super.key, required this.isEditing});

  final bool isEditing;

  @override
  State<BookmarkFormView> createState() => _BookmarkFormViewState();
}

class _BookmarkFormViewState extends State<BookmarkFormView> {
  static const double _thumbnailSize = 100;
  static const double _videoPreviewHeight = 180;

  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _url = TextEditingController();
  final _description = TextEditingController();
  final _tags = TextEditingController();
  bool _hydrated = false;
  AppVideoPlayerController? _videoPlayerController;
  String? _lastVideoUrl;

  @override
  void dispose() {
    _title.dispose();
    _url.dispose();
    _description.dispose();
    _tags.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  void _hydrateFromState(BookmarkFormState state) {
    if (_hydrated) return;
    _title.text = state.title;
    _url.text = state.url;
    _description.text = state.description;
    _tags.text = state.tags.join(', ');
    _hydrated = true;
  }

  void _updateVideoController(String? videoUrl) {
    if (videoUrl == _lastVideoUrl) return;
    _lastVideoUrl = videoUrl;
    _videoPlayerController?.dispose();
    _videoPlayerController = null;

    if (videoUrl != null && videoUrl.isNotEmpty) {
      final service = getIt<VideoPlayerService>();
      final uri = Uri.tryParse(videoUrl);
      if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
        _videoPlayerController = service.network(uri);
      } else {
        _videoPlayerController = service.file(File(videoUrl));
      }
      _videoPlayerController?.initialize().then((_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: widget.isEditing
          ? context.l10n.bookmarkFormEditTitle
          : context.l10n.bookmarkFormNewTitle,
      padding: EdgeInsets.zero,
      body: BlocConsumer<BookmarkFormBloc, BookmarkFormState>(
        listenWhen: (prev, curr) => prev.status != curr.status,
        listener: (context, state) {
          if (state.status == BookmarkFormStatus.submitted) {
            context.pop(true);
          }
          if (state.status == BookmarkFormStatus.idle &&
              state.failure != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(bookmarkFailureMessage(context, state.failure!)),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == BookmarkFormStatus.loading) {
            return const AppLoading();
          }
          if (state.status == BookmarkFormStatus.loadFailed) {
            return AppErrorView(
              message: state.failure == null
                  ? context.l10n.bookmarkFormLoadFailed
                  : bookmarkFailureMessage(context, state.failure!),
            );
          }
          _hydrateFromState(state);
          _updateVideoController(state.videoUrl);
          final isSubmitting = state.status == BookmarkFormStatus.submitting;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTextField(
                    controller: _title,
                    label: context.l10n.bookmarkTitleLabel,
                    textInputAction: TextInputAction.next,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? context.l10n.bookmarkTitleRequired
                        : null,
                    onChanged: (value) => context.read<BookmarkFormBloc>().add(
                      BookmarkFormTitleChanged(value),
                    ),
                  ).animateSlideLeft(),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    controller: _url,
                    label: context.l10n.bookmarkUrlLabel,
                    hint: 'https://example.com',
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.next,
                    validator: (value) => _validateUrl(context, value),
                    onChanged: (value) => context.read<BookmarkFormBloc>().add(
                      BookmarkFormUrlChanged(value),
                    ),
                  ).animateSlideLeft(delay: 50.ms),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    controller: _description,
                    label: context.l10n.bookmarkDescriptionLabel,
                    minLines: 2,
                    maxLines: 4,
                    onChanged: (value) => context.read<BookmarkFormBloc>().add(
                      BookmarkFormDescriptionChanged(value),
                    ),
                  ).animateSlideLeft(delay: 100.ms),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    controller: _tags,
                    label: context.l10n.bookmarkTagsLabel,
                    hint: context.l10n.bookmarkTagsHint,
                    onChanged: (value) => context.read<BookmarkFormBloc>().add(
                      BookmarkFormTagsChanged(value),
                    ),
                  ).animateSlideLeft(delay: 150.ms),
                  const SizedBox(height: AppSpacing.lg),
                  _buildImageSection(
                    context,
                    state,
                  ).animateSlideLeft(delay: 175.ms),
                  const SizedBox(height: AppSpacing.xxl),
                  AppButton(
                    label: widget.isEditing
                        ? context.l10n.commonSave
                        : context.l10n.commonCreate,
                    isLoading: isSubmitting,
                    expand: true,
                    onPressed: () {
                      if (_formKey.currentState?.validate() != true) return;
                      context.read<BookmarkFormBloc>().add(
                        const BookmarkFormSubmitted(),
                      );
                    },
                  ).animateSlideUp(delay: 200.ms),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String? _validateUrl(BuildContext context, String? value) {
    if (value == null || value.trim().isEmpty) {
      return context.l10n.bookmarkUrlRequired;
    }
    final uri = Uri.tryParse(value.trim());
    if (uri == null || !uri.hasScheme || !uri.isAbsolute) {
      return context.l10n.bookmarkUrlInvalid;
    }
    return null;
  }

  Widget _buildImageSection(BuildContext context, BookmarkFormState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attachments',
          style: context.textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        if (state.imageUrls.isNotEmpty)
          SizedBox(
            height: _thumbnailSize,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: state.imageUrls.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) {
                final path = state.imageUrls[index];
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
                  ],
                );
              },
            ),
          ),
        if (state.imageUrls.isNotEmpty) const SizedBox(height: AppSpacing.sm),
        if (state.videoUrl != null && state.videoUrl!.isNotEmpty) ...[
          Text(
            'Attached Video',
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: SizedBox(
                  height: _videoPreviewHeight,
                  width: double.infinity,
                  child: _videoPlayerController != null
                      ? AppVideoPlayer(controller: _videoPlayerController!)
                      : const Center(child: CircularProgressIndicator()),
                ),
              ),
              Positioned(
                top: AppSpacing.sm,
                right: AppSpacing.sm,
                child: GestureDetector(
                  onTap: () => context.read<BookmarkFormBloc>().add(
                    const BookmarkFormVideoRemoved(),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: AppIconSize.md,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
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
