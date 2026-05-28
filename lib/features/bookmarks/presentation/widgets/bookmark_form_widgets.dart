import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/animation/widget_animations.dart';
import '../../../../core/build_context_extensions.dart';
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
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _url = TextEditingController();
  final _description = TextEditingController();
  final _tags = TextEditingController();
  bool _hydrated = false;

  @override
  void dispose() {
    _title.dispose();
    _url.dispose();
    _description.dispose();
    _tags.dispose();
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
          final isSubmitting = state.status == BookmarkFormStatus.submitting;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
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
                    onChanged: context.read<BookmarkFormBloc>().setTitle,
                  ).animateSlideLeft(),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _url,
                    label: context.l10n.bookmarkUrlLabel,
                    hint: 'https://example.com',
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.next,
                    validator: (value) => _validateUrl(context, value),
                    onChanged: context.read<BookmarkFormBloc>().setUrl,
                  ).animateSlideLeft(delay: 50.ms),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _description,
                    label: context.l10n.bookmarkDescriptionLabel,
                    minLines: 2,
                    maxLines: 4,
                    onChanged: context.read<BookmarkFormBloc>().setDescription,
                  ).animateSlideLeft(delay: 100.ms),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _tags,
                    label: context.l10n.bookmarkTagsLabel,
                    hint: context.l10n.bookmarkTagsHint,
                    onChanged: context.read<BookmarkFormBloc>().setTagsFromCsv,
                  ).animateSlideLeft(delay: 150.ms),
                  const SizedBox(height: 16),
                  _buildImageSection(context, state).animateSlideLeft(delay: 175.ms),
                  const SizedBox(height: 24),
                  AppButton(
                    label: widget.isEditing
                        ? context.l10n.commonSave
                        : context.l10n.commonCreate,
                    isLoading: isSubmitting,
                    expand: true,
                    onPressed: () {
                      if (_formKey.currentState?.validate() != true) return;
                      context.read<BookmarkFormBloc>().submit();
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
        const SizedBox(height: 8),
        if (state.imageUrls.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: state.imageUrls.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final path = state.imageUrls[index];
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: path.startsWith('http')
                          ? AppNetworkImage(
                              imageUrl: path,
                              fit: BoxFit.cover,
                              width: 100,
                              height: 100,
                            )
                          : Image.file(
                              File(path),
                              fit: BoxFit.cover,
                              width: 100,
                              height: 100,
                            ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => context
                            .read<BookmarkFormBloc>()
                            .removeImage(path),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        if (state.imageUrls.isNotEmpty) const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => context.read<BookmarkFormBloc>().pickImages(),
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('Add Images'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () =>
                    context.read<BookmarkFormBloc>().takeImageFromCamera(),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Take Photo'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
