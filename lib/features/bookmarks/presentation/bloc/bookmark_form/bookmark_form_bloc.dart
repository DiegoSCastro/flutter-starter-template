import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/analytics/analytics_extensions.dart';
import '../../../../../core/analytics/analytics_service.dart';
import '../../../../../core/bloc/event_completion.dart';
import '../../../../../core/error/failure.dart';
import '../../../../../core/media/image_picker_service.dart';
import '../../../../../core/permissions/permission_service.dart';
import '../../../../../core/utils/result.dart';
import '../../../domain/entities/bookmark.dart';
import '../../../domain/usecases/create_bookmark.dart';
import '../../../domain/usecases/get_bookmark.dart';
import '../../../domain/usecases/update_bookmark.dart';
import 'bookmark_form_state.dart';

part 'bookmark_form_event.dart';

@injectable
class BookmarkFormBloc extends Bloc<BookmarkFormEvent, BookmarkFormState> {
  BookmarkFormBloc(
    this._get,
    this._create,
    this._update,
    this._analytics,
    this._imagePickerService,
    this._permissionService,
  ) : super(const BookmarkFormState()) {
    on<BookmarkFormInitialized>(_onInitialized, transformer: sequential());
    on<BookmarkFormTitleChanged>(_onTitleChanged, transformer: sequential());
    on<BookmarkFormUrlChanged>(_onUrlChanged, transformer: sequential());
    on<BookmarkFormDescriptionChanged>(
      _onDescriptionChanged,
      transformer: sequential(),
    );
    on<BookmarkFormTagsChanged>(_onTagsChanged, transformer: sequential());
    on<BookmarkFormImagesPicked>(_onImagesPicked, transformer: sequential());
    on<BookmarkFormCameraImageTaken>(
      _onCameraImageTaken,
      transformer: sequential(),
    );
    on<BookmarkFormImageRemoved>(_onImageRemoved, transformer: sequential());
    on<BookmarkFormVideoPicked>(_onVideoPicked, transformer: sequential());
    on<BookmarkFormCameraVideoTaken>(
      _onCameraVideoTaken,
      transformer: sequential(),
    );
    on<BookmarkFormVideoRemoved>(_onVideoRemoved, transformer: sequential());
    on<BookmarkFormSubmitted>(_onSubmitted, transformer: sequential());
  }

  final GetBookmark _get;
  final CreateBookmark _create;
  final UpdateBookmark _update;
  final AnalyticsService _analytics;
  final ImagePickerService _imagePickerService;
  final PermissionService _permissionService;
  bool _submitInFlight = false;

  /// For create flows, pass `null`. For edit flows, fetches the existing
  /// bookmark and seeds the form.
  Future<void> initialize(String? id) {
    final completer = Completer<void>();
    add(BookmarkFormInitialized(id, completer: completer));
    return completer.future;
  }

  Future<void> setTitle(String value) {
    final completer = Completer<void>();
    add(BookmarkFormTitleChanged(value, completer: completer));
    return completer.future;
  }

  Future<void> setUrl(String value) {
    final completer = Completer<void>();
    add(BookmarkFormUrlChanged(value, completer: completer));
    return completer.future;
  }

  Future<void> setDescription(String value) {
    final completer = Completer<void>();
    add(BookmarkFormDescriptionChanged(value, completer: completer));
    return completer.future;
  }

  Future<void> setTagsFromCsv(String csv) {
    final completer = Completer<void>();
    add(BookmarkFormTagsChanged(csv, completer: completer));
    return completer.future;
  }

  Future<void> pickImages() {
    final completer = Completer<void>();
    add(BookmarkFormImagesPicked(completer: completer));
    return completer.future;
  }

  Future<void> takeImageFromCamera() {
    final completer = Completer<void>();
    add(BookmarkFormCameraImageTaken(completer: completer));
    return completer.future;
  }

  Future<void> removeImage(String path) {
    final completer = Completer<void>();
    add(BookmarkFormImageRemoved(path, completer: completer));
    return completer.future;
  }

  Future<void> pickVideo() {
    final completer = Completer<void>();
    add(BookmarkFormVideoPicked(completer: completer));
    return completer.future;
  }

  Future<void> recordVideoFromCamera() {
    final completer = Completer<void>();
    add(BookmarkFormCameraVideoTaken(completer: completer));
    return completer.future;
  }

  Future<void> removeVideo() {
    final completer = Completer<void>();
    add(BookmarkFormVideoRemoved(completer: completer));
    return completer.future;
  }

  /// Returns `true` if submit succeeded so the screen can pop.
  Future<bool> submit() {
    if (state.status == BookmarkFormStatus.submitting || _submitInFlight) {
      return Future<bool>.value(false);
    }
    _submitInFlight = true;
    final completer = Completer<bool>();
    add(BookmarkFormSubmitted(completer: completer));
    return completer.future.whenComplete(() => _submitInFlight = false);
  }

  Future<void> _onInitialized(
    BookmarkFormInitialized event,
    Emitter<BookmarkFormState> emit,
  ) async {
    try {
      final id = event.id;
      if (id == null) {
        emit(const BookmarkFormState());
        event.completer.completeVoidIfPending();
        return;
      }
      emit(state.copyWith(id: id, status: BookmarkFormStatus.loading));
      final result = await _get(id);
      switch (result) {
        case Ok(value: final b):
          emit(
            BookmarkFormState(
              id: b.id,
              status: BookmarkFormStatus.idle,
              title: b.title,
              url: b.url,
              description: b.description,
              tags: List.of(b.tags),
              imageUrls: List.of(b.imageUrls),
              videoUrl: b.videoUrl,
            ),
          );
        case Err(:final failure):
          emit(
            state.copyWith(
              status: BookmarkFormStatus.loadFailed,
              failure: failure,
            ),
          );
      }
      event.completer.completeVoidIfPending();
    } on Object catch (error, stackTrace) {
      event.completer.completeErrorIfPending(error, stackTrace);
      rethrow;
    }
  }

  void _onTitleChanged(
    BookmarkFormTitleChanged event,
    Emitter<BookmarkFormState> emit,
  ) {
    emit(state.copyWith(title: event.value));
    event.completer.completeVoidIfPending();
  }

  void _onUrlChanged(
    BookmarkFormUrlChanged event,
    Emitter<BookmarkFormState> emit,
  ) {
    emit(state.copyWith(url: event.value));
    event.completer.completeVoidIfPending();
  }

  void _onDescriptionChanged(
    BookmarkFormDescriptionChanged event,
    Emitter<BookmarkFormState> emit,
  ) {
    emit(state.copyWith(description: event.value));
    event.completer.completeVoidIfPending();
  }

  void _onTagsChanged(
    BookmarkFormTagsChanged event,
    Emitter<BookmarkFormState> emit,
  ) {
    final parsed = event.csv
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList(growable: false);
    emit(state.copyWith(tags: parsed));
    event.completer.completeVoidIfPending();
  }

  Future<void> _onImagesPicked(
    BookmarkFormImagesPicked event,
    Emitter<BookmarkFormState> emit,
  ) async {
    try {
      final hasPermission = await _permissionService.hasGalleryPermission();
      if (!hasPermission) {
        final requestResult = await _permissionService
            .requestGalleryPermission();
        if (!requestResult) {
          emit(
            state.copyWith(
              status: BookmarkFormStatus.idle,
              failure: const PermissionFailure(),
            ),
          );
          event.completer.completeVoidIfPending();
          return;
        }
      }

      final images = await _imagePickerService.pickMultiImage();
      if (images.isNotEmpty) {
        final newPaths = images.map((e) => e.path).toList();
        emit(state.copyWith(imageUrls: [...state.imageUrls, ...newPaths]));
      }
      event.completer.completeVoidIfPending();
    } on Object catch (error, stackTrace) {
      event.completer.completeErrorIfPending(error, stackTrace);
    }
  }

  Future<void> _onCameraImageTaken(
    BookmarkFormCameraImageTaken event,
    Emitter<BookmarkFormState> emit,
  ) async {
    try {
      final hasPermission = await _permissionService.hasCameraPermission();
      if (!hasPermission) {
        final requestResult = await _permissionService
            .requestCameraPermission();
        if (!requestResult) {
          emit(
            state.copyWith(
              status: BookmarkFormStatus.idle,
              failure: const CameraPermissionFailure(),
            ),
          );
          event.completer.completeVoidIfPending();
          return;
        }
      }

      final image = await _imagePickerService.pickImage(
        source: ImageSource.camera,
      );
      if (image != null) {
        emit(state.copyWith(imageUrls: [...state.imageUrls, image.path]));
      }
      event.completer.completeVoidIfPending();
    } on Object catch (error, stackTrace) {
      event.completer.completeErrorIfPending(error, stackTrace);
    }
  }

  void _onImageRemoved(
    BookmarkFormImageRemoved event,
    Emitter<BookmarkFormState> emit,
  ) {
    final updated = List<String>.of(state.imageUrls)..remove(event.path);
    emit(state.copyWith(imageUrls: updated));
    event.completer.completeVoidIfPending();
  }

  Future<void> _onVideoPicked(
    BookmarkFormVideoPicked event,
    Emitter<BookmarkFormState> emit,
  ) async {
    try {
      final hasPermission = await _permissionService.hasGalleryPermission();
      if (!hasPermission) {
        final requestResult = await _permissionService
            .requestGalleryPermission();
        if (!requestResult) {
          emit(
            state.copyWith(
              status: BookmarkFormStatus.idle,
              failure: const PermissionFailure(),
            ),
          );
          event.completer.completeVoidIfPending();
          return;
        }
      }

      final video = await _imagePickerService.pickVideo(
        source: ImageSource.gallery,
      );
      if (video != null) {
        emit(state.copyWith(videoUrl: video.path));
      }
      event.completer.completeVoidIfPending();
    } on Object catch (error, stackTrace) {
      event.completer.completeErrorIfPending(error, stackTrace);
    }
  }

  Future<void> _onCameraVideoTaken(
    BookmarkFormCameraVideoTaken event,
    Emitter<BookmarkFormState> emit,
  ) async {
    try {
      final hasPermission = await _permissionService.hasCameraPermission();
      if (!hasPermission) {
        final requestResult = await _permissionService
            .requestCameraPermission();
        if (!requestResult) {
          emit(
            state.copyWith(
              status: BookmarkFormStatus.idle,
              failure: const CameraPermissionFailure(),
            ),
          );
          event.completer.completeVoidIfPending();
          return;
        }
      }

      final video = await _imagePickerService.pickVideo(
        source: ImageSource.camera,
      );
      if (video != null) {
        emit(state.copyWith(videoUrl: video.path));
      }
      event.completer.completeVoidIfPending();
    } on Object catch (error, stackTrace) {
      event.completer.completeErrorIfPending(error, stackTrace);
    }
  }

  void _onVideoRemoved(
    BookmarkFormVideoRemoved event,
    Emitter<BookmarkFormState> emit,
  ) {
    emit(state.copyWith(videoUrl: null));
    event.completer.completeVoidIfPending();
  }

  Future<void> _onSubmitted(
    BookmarkFormSubmitted event,
    Emitter<BookmarkFormState> emit,
  ) async {
    try {
      if (state.status == BookmarkFormStatus.submitting) {
        event.completer.completeValueIfPending(false);
        return;
      }
      emit(
        state.copyWith(status: BookmarkFormStatus.submitting, failure: null),
      );

      final input = BookmarkInput(
        title: state.title.trim(),
        url: state.url.trim(),
        description: state.description.trim(),
        tags: state.tags,
        imageUrls: state.imageUrls,
        videoUrl: state.videoUrl,
      );
      final isEditing = state.id != null;
      final result = !isEditing
          ? await _create(input)
          : await _update((id: state.id!, input: input));

      switch (result) {
        case Ok(value: final bookmark):
          final trackChange = isEditing
              ? _analytics.trackBookmarkUpdated
              : _analytics.trackBookmarkCreated;
          unawaited(
            trackChange(
              bookmarkId: bookmark.id,
              tagCount: bookmark.tags.length,
              hasDescription: bookmark.description.isNotEmpty,
            ),
          );
          emit(state.copyWith(status: BookmarkFormStatus.submitted));
          event.completer.completeValueIfPending(true);
        case Err(:final failure):
          emit(
            state.copyWith(status: BookmarkFormStatus.idle, failure: failure),
          );
          event.completer.completeValueIfPending(false);
      }
    } catch (error, stackTrace) {
      event.completer.completeErrorIfPending(error, stackTrace);
      rethrow;
    }
  }
}
