import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/analytics/analytics_extensions.dart';
import '../../../../../core/analytics/analytics_service.dart';
import '../../../../../core/error/failure.dart';
import '../../../../../core/future_extensions.dart';
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
    // Load: only one initial load matters; drop concurrent re-inits.
    on<BookmarkFormInitialized>(_onInitialized, transformer: droppable());
    // Field updates are synchronous and ordering-sensitive — default
    // transformer (concurrent in registration order) is correct.
    on<BookmarkFormTitleChanged>(_onTitleChanged);
    on<BookmarkFormUrlChanged>(_onUrlChanged);
    on<BookmarkFormDescriptionChanged>(_onDescriptionChanged);
    on<BookmarkFormTagsChanged>(_onTagsChanged);
    on<BookmarkFormImageRemoved>(_onImageRemoved);
    on<BookmarkFormVideoRemoved>(_onVideoRemoved);
    // Media picks: serialize so two pickers don't open simultaneously.
    on<BookmarkFormImagesPicked>(_onImagesPicked, transformer: sequential());
    on<BookmarkFormCameraImageTaken>(
      _onCameraImageTaken,
      transformer: sequential(),
    );
    on<BookmarkFormVideoPicked>(_onVideoPicked, transformer: sequential());
    on<BookmarkFormCameraVideoTaken>(
      _onCameraVideoTaken,
      transformer: sequential(),
    );
    // Submit: drop double-taps while in flight.
    on<BookmarkFormSubmitted>(_onSubmitted, transformer: droppable());
  }

  final GetBookmark _get;
  final CreateBookmark _create;
  final UpdateBookmark _update;
  final AnalyticsService _analytics;
  final ImagePickerService _imagePickerService;
  final PermissionService _permissionService;

  Future<void> _onInitialized(
    BookmarkFormInitialized event,
    Emitter<BookmarkFormState> emit,
  ) async {
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
    // No gallery permission gate: image_picker's gallery flow uses the system
    // photo picker (PHPicker on iOS, the Android photo picker), which runs
    // out-of-process and only ever exposes the items the user selects, so it
    // needs no photo-library permission. Requesting one would add a dialog
    // that, when denied, wrongly stops the picker from ever opening.
    try {
      final images = await _imagePickerService.pickMultiImage();
      if (images.isNotEmpty) {
        final newPaths = images.map((e) => e.path).toList();
        emit(state.copyWith(imageUrls: [...state.imageUrls, ...newPaths]));
      }
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
      _emitMediaFailure(emit);
    }
  }

  Future<void> _onCameraImageTaken(
    BookmarkFormCameraImageTaken event,
    Emitter<BookmarkFormState> emit,
  ) async {
    if (!await _ensureCameraPermission(emit)) return;
    try {
      final image = await _imagePickerService.pickImage(
        source: ImageSource.camera,
      );
      if (image != null) {
        emit(state.copyWith(imageUrls: [...state.imageUrls, image.path]));
      }
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
      _emitMediaFailure(emit);
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
    // No permission gate — the system gallery picker needs none. See the note
    // in _onImagesPicked.
    try {
      final video = await _imagePickerService.pickVideo(
        source: ImageSource.gallery,
      );
      if (video != null) {
        emit(state.copyWith(videoUrl: video.path));
      }
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
      _emitMediaFailure(emit);
    }
  }

  Future<void> _onCameraVideoTaken(
    BookmarkFormCameraVideoTaken event,
    Emitter<BookmarkFormState> emit,
  ) async {
    if (!await _ensureCameraPermission(emit)) return;
    try {
      final video = await _imagePickerService.pickVideo(
        source: ImageSource.camera,
      );
      if (video != null) {
        emit(state.copyWith(videoUrl: video.path));
      }
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
      _emitMediaFailure(emit);
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
    emit(state.copyWith(status: BookmarkFormStatus.submitting, failure: null));

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
        trackChange(
          bookmarkId: bookmark.id,
          tagCount: bookmark.tags.length,
          hasDescription: bookmark.description.isNotEmpty,
        ).uw();
        emit(state.copyWith(status: BookmarkFormStatus.submitted));
      case Err(:final failure):
        emit(
          state.copyWith(status: BookmarkFormStatus.idle, failure: failure),
        );
    }
  }

  Future<bool> _ensureCameraPermission(Emitter<BookmarkFormState> emit) async {
    if (await _permissionService.hasCameraPermission()) return true;
    if (await _permissionService.requestCameraPermission()) return true;
    emit(
      state.copyWith(
        status: BookmarkFormStatus.idle,
        failure: const CameraPermissionFailure(),
      ),
    );
    return false;
  }

  void _emitMediaFailure(Emitter<BookmarkFormState> emit) {
    emit(
      state.copyWith(
        status: BookmarkFormStatus.idle,
        failure: const MediaPickFailure(),
      ),
    );
  }
}
