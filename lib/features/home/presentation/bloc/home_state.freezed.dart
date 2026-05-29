// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HomeState {

 int get totalBookmarks; int get recentBookmarks; int get uniqueTags; List<Bookmark> get recentItems; bool get isLoading; Failure? get failure;
/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeStateCopyWith<HomeState> get copyWith => _$HomeStateCopyWithImpl<HomeState>(this as HomeState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeState&&(identical(other.totalBookmarks, totalBookmarks) || other.totalBookmarks == totalBookmarks)&&(identical(other.recentBookmarks, recentBookmarks) || other.recentBookmarks == recentBookmarks)&&(identical(other.uniqueTags, uniqueTags) || other.uniqueTags == uniqueTags)&&const DeepCollectionEquality().equals(other.recentItems, recentItems)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,totalBookmarks,recentBookmarks,uniqueTags,const DeepCollectionEquality().hash(recentItems),isLoading,failure);

@override
String toString() {
  return 'HomeState(totalBookmarks: $totalBookmarks, recentBookmarks: $recentBookmarks, uniqueTags: $uniqueTags, recentItems: $recentItems, isLoading: $isLoading, failure: $failure)';
}


}

/// @nodoc
abstract mixin class $HomeStateCopyWith<$Res>  {
  factory $HomeStateCopyWith(HomeState value, $Res Function(HomeState) _then) = _$HomeStateCopyWithImpl;
@useResult
$Res call({
 int totalBookmarks, int recentBookmarks, int uniqueTags, List<Bookmark> recentItems, bool isLoading, Failure? failure
});




}
/// @nodoc
class _$HomeStateCopyWithImpl<$Res>
    implements $HomeStateCopyWith<$Res> {
  _$HomeStateCopyWithImpl(this._self, this._then);

  final HomeState _self;
  final $Res Function(HomeState) _then;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalBookmarks = null,Object? recentBookmarks = null,Object? uniqueTags = null,Object? recentItems = null,Object? isLoading = null,Object? failure = freezed,}) {
  return _then(_self.copyWith(
totalBookmarks: null == totalBookmarks ? _self.totalBookmarks : totalBookmarks // ignore: cast_nullable_to_non_nullable
as int,recentBookmarks: null == recentBookmarks ? _self.recentBookmarks : recentBookmarks // ignore: cast_nullable_to_non_nullable
as int,uniqueTags: null == uniqueTags ? _self.uniqueTags : uniqueTags // ignore: cast_nullable_to_non_nullable
as int,recentItems: null == recentItems ? _self.recentItems : recentItems // ignore: cast_nullable_to_non_nullable
as List<Bookmark>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,
  ));
}

}


/// Adds pattern-matching-related methods to [HomeState].
extension HomeStatePatterns on HomeState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HomeState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HomeState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HomeState value)  $default,){
final _that = this;
switch (_that) {
case _HomeState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HomeState value)?  $default,){
final _that = this;
switch (_that) {
case _HomeState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalBookmarks,  int recentBookmarks,  int uniqueTags,  List<Bookmark> recentItems,  bool isLoading,  Failure? failure)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HomeState() when $default != null:
return $default(_that.totalBookmarks,_that.recentBookmarks,_that.uniqueTags,_that.recentItems,_that.isLoading,_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalBookmarks,  int recentBookmarks,  int uniqueTags,  List<Bookmark> recentItems,  bool isLoading,  Failure? failure)  $default,) {final _that = this;
switch (_that) {
case _HomeState():
return $default(_that.totalBookmarks,_that.recentBookmarks,_that.uniqueTags,_that.recentItems,_that.isLoading,_that.failure);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalBookmarks,  int recentBookmarks,  int uniqueTags,  List<Bookmark> recentItems,  bool isLoading,  Failure? failure)?  $default,) {final _that = this;
switch (_that) {
case _HomeState() when $default != null:
return $default(_that.totalBookmarks,_that.recentBookmarks,_that.uniqueTags,_that.recentItems,_that.isLoading,_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class _HomeState implements HomeState {
  const _HomeState({this.totalBookmarks = 0, this.recentBookmarks = 0, this.uniqueTags = 0, final  List<Bookmark> recentItems = const [], this.isLoading = false, this.failure}): _recentItems = recentItems;
  

@override@JsonKey() final  int totalBookmarks;
@override@JsonKey() final  int recentBookmarks;
@override@JsonKey() final  int uniqueTags;
 final  List<Bookmark> _recentItems;
@override@JsonKey() List<Bookmark> get recentItems {
  if (_recentItems is EqualUnmodifiableListView) return _recentItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recentItems);
}

@override@JsonKey() final  bool isLoading;
@override final  Failure? failure;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HomeStateCopyWith<_HomeState> get copyWith => __$HomeStateCopyWithImpl<_HomeState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HomeState&&(identical(other.totalBookmarks, totalBookmarks) || other.totalBookmarks == totalBookmarks)&&(identical(other.recentBookmarks, recentBookmarks) || other.recentBookmarks == recentBookmarks)&&(identical(other.uniqueTags, uniqueTags) || other.uniqueTags == uniqueTags)&&const DeepCollectionEquality().equals(other._recentItems, _recentItems)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,totalBookmarks,recentBookmarks,uniqueTags,const DeepCollectionEquality().hash(_recentItems),isLoading,failure);

@override
String toString() {
  return 'HomeState(totalBookmarks: $totalBookmarks, recentBookmarks: $recentBookmarks, uniqueTags: $uniqueTags, recentItems: $recentItems, isLoading: $isLoading, failure: $failure)';
}


}

/// @nodoc
abstract mixin class _$HomeStateCopyWith<$Res> implements $HomeStateCopyWith<$Res> {
  factory _$HomeStateCopyWith(_HomeState value, $Res Function(_HomeState) _then) = __$HomeStateCopyWithImpl;
@override @useResult
$Res call({
 int totalBookmarks, int recentBookmarks, int uniqueTags, List<Bookmark> recentItems, bool isLoading, Failure? failure
});




}
/// @nodoc
class __$HomeStateCopyWithImpl<$Res>
    implements _$HomeStateCopyWith<$Res> {
  __$HomeStateCopyWithImpl(this._self, this._then);

  final _HomeState _self;
  final $Res Function(_HomeState) _then;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalBookmarks = null,Object? recentBookmarks = null,Object? uniqueTags = null,Object? recentItems = null,Object? isLoading = null,Object? failure = freezed,}) {
  return _then(_HomeState(
totalBookmarks: null == totalBookmarks ? _self.totalBookmarks : totalBookmarks // ignore: cast_nullable_to_non_nullable
as int,recentBookmarks: null == recentBookmarks ? _self.recentBookmarks : recentBookmarks // ignore: cast_nullable_to_non_nullable
as int,uniqueTags: null == uniqueTags ? _self.uniqueTags : uniqueTags // ignore: cast_nullable_to_non_nullable
as int,recentItems: null == recentItems ? _self._recentItems : recentItems // ignore: cast_nullable_to_non_nullable
as List<Bookmark>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,
  ));
}


}

// dart format on
