import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/build_context_extensions.dart';
import '../bloc/bookmark_form/bookmark_form_bloc.dart';

class BookmarkFormFields extends StatelessWidget {
  const BookmarkFormFields({
    super.key,
    required this.titleController,
    required this.urlController,
    required this.descriptionController,
    required this.tagsController,
    required this.validateUrl,
  });

  final TextEditingController titleController;
  final TextEditingController urlController;
  final TextEditingController descriptionController;
  final TextEditingController tagsController;
  final String? Function(String?) validateUrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          controller: titleController,
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
          controller: urlController,
          label: context.l10n.bookmarkUrlLabel,
          hint: 'https://example.com',
          keyboardType: TextInputType.url,
          textInputAction: TextInputAction.next,
          validator: validateUrl,
          onChanged: (value) => context.read<BookmarkFormBloc>().add(
            BookmarkFormUrlChanged(value),
          ),
        ).animateSlideLeft(delay: 50.ms),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: descriptionController,
          label: context.l10n.bookmarkDescriptionLabel,
          minLines: 2,
          maxLines: 4,
          onChanged: (value) => context.read<BookmarkFormBloc>().add(
            BookmarkFormDescriptionChanged(value),
          ),
        ).animateSlideLeft(delay: 100.ms),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: tagsController,
          label: context.l10n.bookmarkTagsLabel,
          hint: context.l10n.bookmarkTagsHint,
          onChanged: (value) => context.read<BookmarkFormBloc>().add(
            BookmarkFormTagsChanged(value),
          ),
        ).animateSlideLeft(delay: 150.ms),
      ],
    );
  }
}
