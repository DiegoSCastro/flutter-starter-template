import 'package:flutter/widgets.dart';

import '../../../../core/build_context_extensions.dart';
import '../../../../core/error/failure.dart';

String bookmarkFailureMessage(BuildContext context, Failure failure) {
  if (failure is NotFoundFailure) return context.l10n.bookmarkNotFound;
  if (failure is ValidationFailure) return context.l10n.errorInvalidInput;
  return context.l10n.errorUnknown;
}
