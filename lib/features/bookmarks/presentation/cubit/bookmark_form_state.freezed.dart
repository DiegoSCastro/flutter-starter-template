// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bookmark_form_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BookmarkFormState {

 String? get id; BookmarkFormStatus get status; String get title; String get url; String get description; List<String> get tags; Failure? get failure;
/// Create a copy of BookmarkFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookmarkFormStateCopyWith<BookmarkFormState> get copyWith => _$BookmarkFormStateCopyWithImpl<BookmarkFormState>(this as BookmarkFormState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BookmarkFormState&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.title, title) || other.title == title)&&(identical(other.url, url) || other.url == url)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,id,status,title,url,description,const DeepCollectionEquality().hash(tags),failure);

@override
String toString() {
  return 'BookmarkFormState(id: $id, status: $status, title: $title, url: $url, description: $description, tags: $tags, failure: $failure)';
}


}

/// @nodoc
abstract mixin class $BookmarkFormStateCopyWith<$Res>  {
  factory $BookmarkFormStateCopyWith(BookmarkFormState value, $Res Function(BookmarkFormState) _then) = _$BookmarkFormStateCopyWithImpl;
@useResult
$Res call({
 String? id, BookmarkFormStatus status, String title, String url, String description, List<String> tags, Failure? failure
});




}
/// @nodoc
class _$BookmarkFormStateCopyWithImpl<$Res>
    implements $BookmarkFormStateCopyWith<$Res> {
  _$BookmarkFormStateCopyWithImpl(this._self, this._then);

  final BookmarkFormState _self;
  final $Res Function(BookmarkFormState) _then;

/// Create a copy of BookmarkFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? status = null,Object? title = null,Object? url = null,Object? description = null,Object? tags = null,Object? failure = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BookmarkFormStatus,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,
  ));
}

}


/// Adds pattern-matching-related methods to [BookmarkFormState].
extension BookmarkFormStatePatterns on BookmarkFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BookmarkFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BookmarkFormState() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BookmarkFormState value)  $default,){
final _that = this;
switch (_that) {
case _BookmarkFormState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BookmarkFormState value)?  $default,){
final _that = this;
switch (_that) {
case _BookmarkFormState() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  BookmarkFormStatus status,  String title,  String url,  String description,  List<String> tags,  Failure? failure)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BookmarkFormState() when $default != null:
return $default(_that.id,_that.status,_that.title,_that.url,_that.description,_that.tags,_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  BookmarkFormStatus status,  String title,  String url,  String description,  List<String> tags,  Failure? failure)  $default,) {final _that = this;
switch (_that) {
case _BookmarkFormState():
return $default(_that.id,_that.status,_that.title,_that.url,_that.description,_that.tags,_that.failure);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  BookmarkFormStatus status,  String title,  String url,  String description,  List<String> tags,  Failure? failure)?  $default,) {final _that = this;
switch (_that) {
case _BookmarkFormState() when $default != null:
return $default(_that.id,_that.status,_that.title,_that.url,_that.description,_that.tags,_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class _BookmarkFormState implements BookmarkFormState {
  const _BookmarkFormState({this.id, this.status = BookmarkFormStatus.idle, this.title = '', this.url = '', this.description = '', final  List<String> tags = const [], this.failure}): _tags = tags;
  

@override final  String? id;
@override@JsonKey() final  BookmarkFormStatus status;
@override@JsonKey() final  String title;
@override@JsonKey() final  String url;
@override@JsonKey() final  String description;
 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

@override final  Failure? failure;

/// Create a copy of BookmarkFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookmarkFormStateCopyWith<_BookmarkFormState> get copyWith => __$BookmarkFormStateCopyWithImpl<_BookmarkFormState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BookmarkFormState&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.title, title) || other.title == title)&&(identical(other.url, url) || other.url == url)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,id,status,title,url,description,const DeepCollectionEquality().hash(_tags),failure);

@override
String toString() {
  return 'BookmarkFormState(id: $id, status: $status, title: $title, url: $url, description: $description, tags: $tags, failure: $failure)';
}


}

/// @nodoc
abstract mixin class _$BookmarkFormStateCopyWith<$Res> implements $BookmarkFormStateCopyWith<$Res> {
  factory _$BookmarkFormStateCopyWith(_BookmarkFormState value, $Res Function(_BookmarkFormState) _then) = __$BookmarkFormStateCopyWithImpl;
@override @useResult
$Res call({
 String? id, BookmarkFormStatus status, String title, String url, String description, List<String> tags, Failure? failure
});




}
/// @nodoc
class __$BookmarkFormStateCopyWithImpl<$Res>
    implements _$BookmarkFormStateCopyWith<$Res> {
  __$BookmarkFormStateCopyWithImpl(this._self, this._then);

  final _BookmarkFormState _self;
  final $Res Function(_BookmarkFormState) _then;

/// Create a copy of BookmarkFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? status = null,Object? title = null,Object? url = null,Object? description = null,Object? tags = null,Object? failure = freezed,}) {
  return _then(_BookmarkFormState(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BookmarkFormStatus,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,
  ));
}


}

// dart format on
