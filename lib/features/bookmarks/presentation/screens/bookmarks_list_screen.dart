import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/animation/widget_animations.dart';
import '../../../../core/build_context_extensions.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/sync/bookmarks_sync_service.dart';
import '../cubit/bookmarks_list_cubit.dart';
import '../cubit/bookmarks_list_state.dart';

part '../widgets/bookmarks_list_widgets.dart';

class BookmarksListScreen extends StatelessWidget {
  const BookmarksListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<BookmarksListCubit>()..load(),
      child: const _BookmarksListView(),
    );
  }
}
