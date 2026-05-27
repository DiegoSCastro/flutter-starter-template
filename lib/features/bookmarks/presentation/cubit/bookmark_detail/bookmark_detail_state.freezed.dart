// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bookmark_detail_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BookmarkDetailState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BookmarkDetailState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'BookmarkDetailState()';
}


}

/// @nodoc
class $BookmarkDetailStateCopyWith<$Res>  {
$BookmarkDetailStateCopyWith(BookmarkDetailState _, $Res Function(BookmarkDetailState) __);
}


/// Adds pattern-matching-related methods to [BookmarkDetailState].
extension BookmarkDetailStatePatterns on BookmarkDetailState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( BookmarkDetailLoading value)?  loading,TResult Function( BookmarkDetailReady value)?  ready,TResult Function( BookmarkDetailFailure value)?  failure,required TResult orElse(),}){
final _that = this;
switch (_that) {
case BookmarkDetailLoading() when loading != null:
return loading(_that);case BookmarkDetailReady() when ready != null:
return ready(_that);case BookmarkDetailFailure() when failure != null:
return failure(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( BookmarkDetailLoading value)  loading,required TResult Function( BookmarkDetailReady value)  ready,required TResult Function( BookmarkDetailFailure value)  failure,}){
final _that = this;
switch (_that) {
case BookmarkDetailLoading():
return loading(_that);case BookmarkDetailReady():
return ready(_that);case BookmarkDetailFailure():
return failure(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( BookmarkDetailLoading value)?  loading,TResult? Function( BookmarkDetailReady value)?  ready,TResult? Function( BookmarkDetailFailure value)?  failure,}){
final _that = this;
switch (_that) {
case BookmarkDetailLoading() when loading != null:
return loading(_that);case BookmarkDetailReady() when ready != null:
return ready(_that);case BookmarkDetailFailure() when failure != null:
return failure(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  loading,TResult Function( Bookmark bookmark)?  ready,TResult Function( Failure failure)?  failure,required TResult orElse(),}) {final _that = this;
switch (_that) {
case BookmarkDetailLoading() when loading != null:
return loading();case BookmarkDetailReady() when ready != null:
return ready(_that.bookmark);case BookmarkDetailFailure() when failure != null:
return failure(_that.failure);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  loading,required TResult Function( Bookmark bookmark)  ready,required TResult Function( Failure failure)  failure,}) {final _that = this;
switch (_that) {
case BookmarkDetailLoading():
return loading();case BookmarkDetailReady():
return ready(_that.bookmark);case BookmarkDetailFailure():
return failure(_that.failure);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  loading,TResult? Function( Bookmark bookmark)?  ready,TResult? Function( Failure failure)?  failure,}) {final _that = this;
switch (_that) {
case BookmarkDetailLoading() when loading != null:
return loading();case BookmarkDetailReady() when ready != null:
return ready(_that.bookmark);case BookmarkDetailFailure() when failure != null:
return failure(_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class BookmarkDetailLoading implements BookmarkDetailState {
  const BookmarkDetailLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BookmarkDetailLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'BookmarkDetailState.loading()';
}


}




/// @nodoc


class BookmarkDetailReady implements BookmarkDetailState {
  const BookmarkDetailReady(this.bookmark);
  

 final  Bookmark bookmark;

/// Create a copy of BookmarkDetailState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookmarkDetailReadyCopyWith<BookmarkDetailReady> get copyWith => _$BookmarkDetailReadyCopyWithImpl<BookmarkDetailReady>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BookmarkDetailReady&&(identical(other.bookmark, bookmark) || other.bookmark == bookmark));
}


@override
int get hashCode => Object.hash(runtimeType,bookmark);

@override
String toString() {
  return 'BookmarkDetailState.ready(bookmark: $bookmark)';
}


}

/// @nodoc
abstract mixin class $BookmarkDetailReadyCopyWith<$Res> implements $BookmarkDetailStateCopyWith<$Res> {
  factory $BookmarkDetailReadyCopyWith(BookmarkDetailReady value, $Res Function(BookmarkDetailReady) _then) = _$BookmarkDetailReadyCopyWithImpl;
@useResult
$Res call({
 Bookmark bookmark
});




}
/// @nodoc
class _$BookmarkDetailReadyCopyWithImpl<$Res>
    implements $BookmarkDetailReadyCopyWith<$Res> {
  _$BookmarkDetailReadyCopyWithImpl(this._self, this._then);

  final BookmarkDetailReady _self;
  final $Res Function(BookmarkDetailReady) _then;

/// Create a copy of BookmarkDetailState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? bookmark = null,}) {
  return _then(BookmarkDetailReady(
null == bookmark ? _self.bookmark : bookmark // ignore: cast_nullable_to_non_nullable
as Bookmark,
  ));
}


}

/// @nodoc


class BookmarkDetailFailure implements BookmarkDetailState {
  const BookmarkDetailFailure(this.failure);
  

 final  Failure failure;

/// Create a copy of BookmarkDetailState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookmarkDetailFailureCopyWith<BookmarkDetailFailure> get copyWith => _$BookmarkDetailFailureCopyWithImpl<BookmarkDetailFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BookmarkDetailFailure&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,failure);

@override
String toString() {
  return 'BookmarkDetailState.failure(failure: $failure)';
}


}

/// @nodoc
abstract mixin class $BookmarkDetailFailureCopyWith<$Res> implements $BookmarkDetailStateCopyWith<$Res> {
  factory $BookmarkDetailFailureCopyWith(BookmarkDetailFailure value, $Res Function(BookmarkDetailFailure) _then) = _$BookmarkDetailFailureCopyWithImpl;
@useResult
$Res call({
 Failure failure
});




}
/// @nodoc
class _$BookmarkDetailFailureCopyWithImpl<$Res>
    implements $BookmarkDetailFailureCopyWith<$Res> {
  _$BookmarkDetailFailureCopyWithImpl(this._self, this._then);

  final BookmarkDetailFailure _self;
  final $Res Function(BookmarkDetailFailure) _then;

/// Create a copy of BookmarkDetailState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? failure = null,}) {
  return _then(BookmarkDetailFailure(
null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure,
  ));
}


}

// dart format on
