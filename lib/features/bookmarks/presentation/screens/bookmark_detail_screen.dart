import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/animation/widget_animations.dart';
import '../../../../core/build_context_extensions.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/bookmark.dart';
import '../cubit/bookmark_detail_cubit.dart';
import '../cubit/bookmark_detail_state.dart';
import '../cubit/bookmarks_list_cubit.dart';

part '../widgets/bookmark_detail_widgets.dart';

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
