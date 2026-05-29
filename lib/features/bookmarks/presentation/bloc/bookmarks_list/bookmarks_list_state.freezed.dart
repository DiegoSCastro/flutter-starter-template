// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bookmarks_list_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BookmarksListState {

 bool get isLoading; BookmarksSyncStatus get syncStatus; List<Bookmark> get items; String get query; BookmarkSort get sort; Failure? get failure;
/// Create a copy of BookmarksListState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookmarksListStateCopyWith<BookmarksListState> get copyWith => _$BookmarksListStateCopyWithImpl<BookmarksListState>(this as BookmarksListState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BookmarksListState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.query, query) || other.query == query)&&(identical(other.sort, sort) || other.sort == sort)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,syncStatus,const DeepCollectionEquality().hash(items),query,sort,failure);

@override
String toString() {
  return 'BookmarksListState(isLoading: $isLoading, syncStatus: $syncStatus, items: $items, query: $query, sort: $sort, failure: $failure)';
}


}

/// @nodoc
abstract mixin class $BookmarksListStateCopyWith<$Res>  {
  factory $BookmarksListStateCopyWith(BookmarksListState value, $Res Function(BookmarksListState) _then) = _$BookmarksListStateCopyWithImpl;
@useResult
$Res call({
 bool isLoading, BookmarksSyncStatus syncStatus, List<Bookmark> items, String query, BookmarkSort sort, Failure? failure
});




}
/// @nodoc
class _$BookmarksListStateCopyWithImpl<$Res>
    implements $BookmarksListStateCopyWith<$Res> {
  _$BookmarksListStateCopyWithImpl(this._self, this._then);

  final BookmarksListState _self;
  final $Res Function(BookmarksListState) _then;

/// Create a copy of BookmarksListState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isLoading = null,Object? syncStatus = null,Object? items = null,Object? query = null,Object? sort = null,Object? failure = freezed,}) {
  return _then(_self.copyWith(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as BookmarksSyncStatus,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<Bookmark>,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,sort: null == sort ? _self.sort : sort // ignore: cast_nullable_to_non_nullable
as BookmarkSort,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,
  ));
}

}


/// Adds pattern-matching-related methods to [BookmarksListState].
extension BookmarksListStatePatterns on BookmarksListState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BookmarksListState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BookmarksListState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BookmarksListState value)  $default,){
final _that = this;
switch (_that) {
case _BookmarksListState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BookmarksListState value)?  $default,){
final _that = this;
switch (_that) {
case _BookmarksListState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isLoading,  BookmarksSyncStatus syncStatus,  List<Bookmark> items,  String query,  BookmarkSort sort,  Failure? failure)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BookmarksListState() when $default != null:
return $default(_that.isLoading,_that.syncStatus,_that.items,_that.query,_that.sort,_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isLoading,  BookmarksSyncStatus syncStatus,  List<Bookmark> items,  String query,  BookmarkSort sort,  Failure? failure)  $default,) {final _that = this;
switch (_that) {
case _BookmarksListState():
return $default(_that.isLoading,_that.syncStatus,_that.items,_that.query,_that.sort,_that.failure);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isLoading,  BookmarksSyncStatus syncStatus,  List<Bookmark> items,  String query,  BookmarkSort sort,  Failure? failure)?  $default,) {final _that = this;
switch (_that) {
case _BookmarksListState() when $default != null:
return $default(_that.isLoading,_that.syncStatus,_that.items,_that.query,_that.sort,_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class _BookmarksListState extends BookmarksListState {
  const _BookmarksListState({this.isLoading = false, this.syncStatus = BookmarksSyncStatus.idle, final  List<Bookmark> items = const [], this.query = '', this.sort = BookmarkSort.newest, this.failure}): _items = items,super._();
  

@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  BookmarksSyncStatus syncStatus;
 final  List<Bookmark> _items;
@override@JsonKey() List<Bookmark> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@JsonKey() final  String query;
@override@JsonKey() final  BookmarkSort sort;
@override final  Failure? failure;

/// Create a copy of BookmarksListState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookmarksListStateCopyWith<_BookmarksListState> get copyWith => __$BookmarksListStateCopyWithImpl<_BookmarksListState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BookmarksListState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.query, query) || other.query == query)&&(identical(other.sort, sort) || other.sort == sort)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,syncStatus,const DeepCollectionEquality().hash(_items),query,sort,failure);

@override
String toString() {
  return 'BookmarksListState(isLoading: $isLoading, syncStatus: $syncStatus, items: $items, query: $query, sort: $sort, failure: $failure)';
}


}

/// @nodoc
abstract mixin class _$BookmarksListStateCopyWith<$Res> implements $BookmarksListStateCopyWith<$Res> {
  factory _$BookmarksListStateCopyWith(_BookmarksListState value, $Res Function(_BookmarksListState) _then) = __$BookmarksListStateCopyWithImpl;
@override @useResult
$Res call({
 bool isLoading, BookmarksSyncStatus syncStatus, List<Bookmark> items, String query, BookmarkSort sort, Failure? failure
});




}
/// @nodoc
class __$BookmarksListStateCopyWithImpl<$Res>
    implements _$BookmarksListStateCopyWith<$Res> {
  __$BookmarksListStateCopyWithImpl(this._self, this._then);

  final _BookmarksListState _self;
  final $Res Function(_BookmarksListState) _then;

/// Create a copy of BookmarksListState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isLoading = null,Object? syncStatus = null,Object? items = null,Object? query = null,Object? sort = null,Object? failure = freezed,}) {
  return _then(_BookmarksListState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as BookmarksSyncStatus,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<Bookmark>,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,sort: null == sort ? _self.sort : sort // ignore: cast_nullable_to_non_nullable
as BookmarkSort,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,
  ));
}


}

// dart format on
