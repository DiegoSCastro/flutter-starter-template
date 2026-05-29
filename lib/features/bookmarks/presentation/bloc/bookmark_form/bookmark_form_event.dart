part of 'bookmark_form_bloc.dart';

sealed class BookmarkFormEvent {
  const BookmarkFormEvent();
}

final class BookmarkFormInitialized extends BookmarkFormEvent {
  const BookmarkFormInitialized(this.id, {this.completer});

  final String? id;
  final Completer<void>? completer;
}

final class BookmarkFormTitleChanged extends BookmarkFormEvent {
  const BookmarkFormTitleChanged(this.value, {this.completer});

  final String value;
  final Completer<void>? completer;
}

final class BookmarkFormUrlChanged extends BookmarkFormEvent {
  const BookmarkFormUrlChanged(this.value, {this.completer});

  final String value;
  final Completer<void>? completer;
}

final class BookmarkFormDescriptionChanged extends BookmarkFormEvent {
  const BookmarkFormDescriptionChanged(this.value, {this.completer});

  final String value;
  final Completer<void>? completer;
}

final class BookmarkFormTagsChanged extends BookmarkFormEvent {
  const BookmarkFormTagsChanged(this.csv, {this.completer});

  final String csv;
  final Completer<void>? completer;
}

final class BookmarkFormImagesPicked extends BookmarkFormEvent {
  const BookmarkFormImagesPicked({this.completer});

  final Completer<void>? completer;
}

final class BookmarkFormCameraImageTaken extends BookmarkFormEvent {
  const BookmarkFormCameraImageTaken({this.completer});

  final Completer<void>? completer;
}

final class BookmarkFormImageRemoved extends BookmarkFormEvent {
  const BookmarkFormImageRemoved(this.path, {this.completer});

  final String path;
  final Completer<void>? completer;
}

final class BookmarkFormVideoPicked extends BookmarkFormEvent {
  const BookmarkFormVideoPicked({this.completer});

  final Completer<void>? completer;
}

final class BookmarkFormCameraVideoTaken extends BookmarkFormEvent {
  const BookmarkFormCameraVideoTaken({this.completer});

  final Completer<void>? completer;
}

final class BookmarkFormVideoRemoved extends BookmarkFormEvent {
  const BookmarkFormVideoRemoved({this.completer});

  final Completer<void>? completer;
}

final class BookmarkFormSubmitted extends BookmarkFormEvent {
  const BookmarkFormSubmitted({this.completer});

  final Completer<bool>? completer;
}
