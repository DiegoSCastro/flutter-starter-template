import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/di/injection.dart';
import '../../domain/entities/bookmark.dart';
import '../cubit/bookmark_detail_cubit.dart';
import '../cubit/bookmark_detail_state.dart';
import '../cubit/bookmarks_list_cubit.dart';

class BookmarkDetailScreen extends StatelessWidget {
  const BookmarkDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<BookmarkDetailCubit>()..load(id),
      child: _BookmarkDetailView(id: id),
    );
  }
}

class _BookmarkDetailView extends StatelessWidget {
  const _BookmarkDetailView({required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.inversePrimary,
        title: const Text('Bookmark'),
        actions: [
          BlocBuilder<BookmarkDetailCubit, BookmarkDetailState>(
            builder: (context, state) {
              if (state is! BookmarkDetailReady) return const SizedBox.shrink();
              return Row(
                children: [
                  IconButton(
                    tooltip: 'Edit',
                    icon: const Icon(Icons.edit),
                    onPressed: () => context.push('/bookmarks/$id/edit'),
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
      ),
      body: BlocBuilder<BookmarkDetailCubit, BookmarkDetailState>(
        builder: (context, state) {
          return switch (state) {
            BookmarkDetailLoading() =>
              const Center(child: CircularProgressIndicator()),
            BookmarkDetailFailure(:final failure) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(failure.message, textAlign: TextAlign.center),
                ),
              ),
            BookmarkDetailReady(:final bookmark) => _DetailBody(bookmark: bookmark),
          };
        },
      ),
    );
  }

  Future<void> _confirmAndDelete(BuildContext context, Bookmark b) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete bookmark?'),
        content: Text('"${b.title}" will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!context.mounted) return;
    final ok = await context.read<BookmarkDetailCubit>().delete(b.id);
    if (!ok || !context.mounted) return;
    await context.read<BookmarksListCubit>().load();
    if (!context.mounted) return;
    context.pop();
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.bookmark});

  final Bookmark bookmark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(bookmark.title, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _openUrl(context, bookmark.url),
            child: Text(
              bookmark.url,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          if (bookmark.description.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(bookmark.description, style: theme.textTheme.bodyMedium),
          ],
          if (bookmark.tags.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final tag in bookmark.tags) Chip(label: Text(tag)),
              ],
            ),
          ],
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _openUrl(context, bookmark.url),
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open URL'),
          ),
        ],
      ),
    );
  }

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      _toast(context, 'Invalid URL');
      return;
    }
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      _toast(context, 'Could not open URL');
    }
  }

  void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
