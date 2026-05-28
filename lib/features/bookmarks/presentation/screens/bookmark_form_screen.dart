import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../cubit/bookmark_form/bookmark_form_cubit.dart';
import '../widgets/bookmark_form_widgets.dart';

class BookmarkFormScreen extends StatelessWidget {
  const BookmarkFormScreen({super.key, this.id});

  /// `null` for create, populated for edit.
  final String? id;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<BookmarkFormCubit>()..initialize(id),
      child: BookmarkFormView(isEditing: id != null),
    );
  }
}
