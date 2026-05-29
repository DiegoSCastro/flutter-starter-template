import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/analytics/analytics_extensions.dart';
import '../../../../../core/analytics/analytics_service.dart';
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
    final completion = stream.firstWhere(
      (state) =>
          state.status == BookmarkFormStatus.idle ||
          state.status == BookmarkFormStatus.loadFailed,
    );
    add(BookmarkFormInitialized(id));
    return completion.then((_) {});
  }

  Future<void> setTitle(String value) {
    add(BookmarkFormTitleChanged(value));
    return Future<void>.delayed(Duration.zero);
  }

  Future<void> setUrl(String value) {
    add(BookmarkFormUrlChanged(value));
    return Future<void>.delayed(Duration.zero);
  }

  Future<void> setDescription(String value) {
    add(BookmarkFormDescriptionChanged(value));
    return Future<void>.delayed(Duration.zero);
  }

  Future<void> setTagsFromCsv(String csv) {
    add(BookmarkFormTagsChanged(csv));
    return Future<void>.delayed(Duration.zero);
  }

  Future<void> pickImages() {
    add(const BookmarkFormImagesPicked());
    return Future<void>.delayed(Duration.zero);
  }

  Future<void> takeImageFromCamera() {
    add(const BookmarkFormCameraImageTaken());
    return Future<void>.delayed(Duration.zero);
  }

  Future<void> removeImage(String path) {
    add(BookmarkFormImageRemoved(path));
    return Future<void>.delayed(Duration.zero);
  }

  Future<void> pickVideo() {
    add(const BookmarkFormVideoPicked());
    return Future<void>.delayed(Duration.zero);
  }

  Future<void> recordVideoFromCamera() {
    add(const BookmarkFormCameraVideoTaken());
    return Future<void>.delayed(Duration.zero);
  }

  Future<void> removeVideo() {
    add(const BookmarkFormVideoRemoved());
    return Future<void>.delayed(Duration.zero);
  }

  /// Returns `true` if submit succeeded so the screen can pop.
  Future<bool> submit() {
    if (state.status == BookmarkFormStatus.submitting || _submitInFlight) {
      return Future<bool>.value(false);
    }
    _submitInFlight = true;
    final completion = stream.firstWhere(
      (state) => state.status != BookmarkFormStatus.submitting,
    );
    add(const BookmarkFormSubmitted());
    return completion
        .then((state) => state.status == BookmarkFormStatus.submitted)
        .whenComplete(() => _submitInFlight = false);
  }

  Future<void> _onInitialized(
    BookmarkFormInitialized event,
    Emitter<BookmarkFormState> emit,
  ) async {
    try {
      final id = event.id;
      if (id == null) {
        emit(const BookmarkFormState());
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
    } on Object {
      rethrow;
    }
  }

  void _onTitleChanged(
    BookmarkFormTitleChanged event,
    Emitter<BookmarkFormState> emit,
  ) {
    emit(state.copyWith(title: event.value));
  }

  void _onUrlChanged(
    BookmarkFormUrlChanged event,
    Emitter<BookmarkFormState> emit,
  ) {
    emit(state.copyWith(url: event.value));
  }

  void _onDescriptionChanged(
    BookmarkFormDescriptionChanged event,
    Emitter<BookmarkFormState> emit,
  ) {
    emit(state.copyWith(description: event.value));
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
          return;
        }
      }

      final images = await _imagePickerService.pickMultiImage();
      if (images.isNotEmpty) {
        final newPaths = images.map((e) => e.path).toList();
        emit(state.copyWith(imageUrls: [...state.imageUrls, ...newPaths]));
      }
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
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
          return;
        }
      }

      final image = await _imagePickerService.pickImage(
        source: ImageSource.camera,
      );
      if (image != null) {
        emit(state.copyWith(imageUrls: [...state.imageUrls, image.path]));
      }
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
    }
  }

  void _onImageRemoved(
    BookmarkFormImageRemoved event,
    Emitter<BookmarkFormState> emit,
  ) {
    final updated = List<String>.of(state.imageUrls)..remove(event.path);
    emit(state.copyWith(imageUrls: updated));
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
          return;
        }
      }

      final video = await _imagePickerService.pickVideo(
        source: ImageSource.gallery,
      );
      if (video != null) {
        emit(state.copyWith(videoUrl: video.path));
      }
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
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
          return;
        }
      }

      final video = await _imagePickerService.pickVideo(
        source: ImageSource.camera,
      );
      if (video != null) {
        emit(state.copyWith(videoUrl: video.path));
      }
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
    }
  }

  void _onVideoRemoved(
    BookmarkFormVideoRemoved event,
    Emitter<BookmarkFormState> emit,
  ) {
    emit(state.copyWith(videoUrl: null));
  }

  Future<void> _onSubmitted(
    BookmarkFormSubmitted event,
    Emitter<BookmarkFormState> emit,
  ) async {
    try {
      if (state.status == BookmarkFormStatus.submitting) {
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
        case Err(:final failure):
          emit(
            state.copyWith(status: BookmarkFormStatus.idle, failure: failure),
          );
      }
    } catch (_) {
      rethrow;
    }
  }
}
