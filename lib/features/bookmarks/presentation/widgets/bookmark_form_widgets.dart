part of '../screens/bookmark_form_screen.dart';

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
    return AppScaffold(
      title: widget.isEditing ? 'Edit bookmark' : 'New bookmark',
      padding: EdgeInsets.zero,
      body: BlocConsumer<BookmarkFormCubit, BookmarkFormState>(
        listenWhen: (prev, curr) => prev.status != curr.status,
        listener: (context, state) {
          if (state.status == BookmarkFormStatus.submitted) {
            context.read<BookmarksListCubit>().load();
            context.pop();
          }
          if (state.status == BookmarkFormStatus.idle &&
              state.failure != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.failure!.message)));
          }
        },
        builder: (context, state) {
          if (state.status == BookmarkFormStatus.loading) {
            return const AppLoading();
          }
          if (state.status == BookmarkFormStatus.loadFailed) {
            return AppErrorView(
              message: state.failure?.message ?? 'Failed to load bookmark.',
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
                    label: 'Title',
                    textInputAction: TextInputAction.next,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Title is required'
                        : null,
                    onChanged: context.read<BookmarkFormCubit>().setTitle,
                  ).animateSlideLeft(),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _url,
                    label: 'URL',
                    hint: 'https://example.com',
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.next,
                    validator: _validateUrl,
                    onChanged: context.read<BookmarkFormCubit>().setUrl,
                  ).animateSlideLeft(delay: 50.ms),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _description,
                    label: 'Description (optional)',
                    minLines: 2,
                    maxLines: 4,
                    onChanged: context.read<BookmarkFormCubit>().setDescription,
                  ).animateSlideLeft(delay: 100.ms),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _tags,
                    label: 'Tags',
                    hint: 'comma, separated, values',
                    onChanged: context.read<BookmarkFormCubit>().setTagsFromCsv,
                  ).animateSlideLeft(delay: 150.ms),
                  const SizedBox(height: 24),
                  AppButton(
                    label: widget.isEditing ? 'Save' : 'Create',
                    isLoading: isSubmitting,
                    expand: true,
                    onPressed: () {
                      if (_formKey.currentState?.validate() != true) return;
                      context.read<BookmarkFormCubit>().submit();
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

  String? _validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) return 'URL is required';
    final uri = Uri.tryParse(value.trim());
    if (uri == null || !uri.hasScheme || !uri.isAbsolute) {
      return 'Enter a valid URL (https://…)';
    }
    return null;
  }
}
