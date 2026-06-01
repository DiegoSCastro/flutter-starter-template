import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/build_context_extensions.dart';
import '../../../../ui/animation/widget_animations.dart';
import '../../../../ui/theme/app_spacing.dart';
import '../../../../ui/widgets/widgets.dart';
import '../bloc/bookmark_form/bookmark_form_bloc.dart';
import '../bloc/bookmark_form/bookmark_form_state.dart';
import 'bookmark_attachments_section.dart';
import 'bookmark_failure_messages.dart';
import 'bookmark_form_fields.dart';

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
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  BookmarkFormFields(
                    titleController: _title,
                    urlController: _url,
                    descriptionController: _description,
                    tagsController: _tags,
                    validateUrl: (value) => _validateUrl(context, value),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  BookmarkAttachmentsSection(
                    state: state,
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
}
