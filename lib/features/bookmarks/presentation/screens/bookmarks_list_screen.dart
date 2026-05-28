import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../cubit/bookmarks_list/bookmarks_list_cubit.dart';
import '../widgets/bookmarks_list_widgets.dart';

class BookmarksListScreen extends StatelessWidget {
  const BookmarksListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<BookmarksListCubit>()..load(),
      child: const BookmarksListView(),
    );
  }
}
