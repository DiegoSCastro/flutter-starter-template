import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/animation/widget_animations.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/widgets.dart';
import '../cubit/bookmark_form/bookmark_form_cubit.dart';
import '../cubit/bookmark_form/bookmark_form_state.dart';
import '../cubit/bookmarks_list/bookmarks_list_cubit.dart';

part '../widgets/bookmark_form_widgets.dart';

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
