import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../cubit/bookmark_form_cubit.dart';
import '../cubit/bookmark_form_state.dart';
import '../cubit/bookmarks_list_cubit.dart';

class BookmarkFormScreen extends StatelessWidget {
  const BookmarkFormScreen({super.key, this.id});

  /// `null` for create, populated for edit.
  final String? id;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<BookmarkFormCubit>()..initialize(id),
      child: _BookmarkFormView(isEditing: id != null),
    );
  }
}

class _BookmarkFormView extends StatefulWidget {
  const _BookmarkFormView({required this.isEditing});

  final bool isEditing;

  @override
  State<_BookmarkFormView> createState() => _BookmarkFormViewState();
}

class _BookmarkFormViewState extends State<_BookmarkFormView> {
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
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.inversePrimary,
        title: Text(widget.isEditing ? 'Edit bookmark' : 'New bookmark'),
      ),
      body: BlocConsumer<BookmarkFormCubit, BookmarkFormState>(
        listenWhen: (prev, curr) => prev.status != curr.status,
        listener: (context, state) {
          if (state.status == BookmarkFormStatus.submitted) {
            context.read<BookmarksListCubit>().load();
            context.pop();
          }
          if (state.status == BookmarkFormStatus.idle &&
              state.failure != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.failure!.message)),
            );
          }
        },
        builder: (context, state) {
          if (state.status == BookmarkFormStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == BookmarkFormStatus.loadFailed) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  state.failure?.message ?? 'Failed to load bookmark.',
                  textAlign: TextAlign.center,
                ),
              ),
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
                  TextFormField(
                    controller: _title,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Title is required'
                        : null,
                    onChanged: context.read<BookmarkFormCubit>().setTitle,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _url,
                    decoration: const InputDecoration(
                      labelText: 'URL',
                      hintText: 'https://example.com',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.next,
                    validator: _validateUrl,
                    onChanged: context.read<BookmarkFormCubit>().setUrl,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _description,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                      border: OutlineInputBorder(),
                    ),
                    minLines: 2,
                    maxLines: 4,
                    onChanged:
                        context.read<BookmarkFormCubit>().setDescription,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _tags,
                    decoration: const InputDecoration(
                      labelText: 'Tags',
                      hintText: 'comma, separated, values',
                      border: OutlineInputBorder(),
                    ),
                    onChanged:
                        context.read<BookmarkFormCubit>().setTagsFromCsv,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: isSubmitting
                        ? null
                        : () {
                            if (_formKey.currentState?.validate() != true) {
                              return;
                            }
                            context.read<BookmarkFormCubit>().submit();
                          },
                    child: isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(widget.isEditing ? 'Save' : 'Create'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String? _validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) return 'URL is required';
    final uri = Uri.tryParse(value.trim());
    if (uri == null || !uri.hasScheme || !uri.isAbsolute) {
      return 'Enter a valid URL (https://…)';
    }
    return null;
  }
}
