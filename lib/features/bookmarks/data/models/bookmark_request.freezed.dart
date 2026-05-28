// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bookmark_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BookmarkRequest {

 String? get id; String get title; String get url; String get description; List<String> get tags; List<String> get imageUrls; String? get videoUrl;

  /// Serializes this BookmarkRequest to a JSON map.
  Map<String, dynamic> toJson();




@override
String toString() {
  return 'BookmarkRequest(id: $id, title: $title, url: $url, description: $description, tags: $tags, imageUrls: $imageUrls, videoUrl: $videoUrl)';
}


}




/// Adds pattern-matching-related methods to [BookmarkRequest].
extension BookmarkRequestPatterns on BookmarkRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BookmarkRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BookmarkRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BookmarkRequest value)  $default,){
final _that = this;
switch (_that) {
case _BookmarkRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BookmarkRequest value)?  $default,){
final _that = this;
switch (_that) {
case _BookmarkRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String title,  String url,  String description,  List<String> tags,  List<String> imageUrls,  String? videoUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BookmarkRequest() when $default != null:
return $default(_that.id,_that.title,_that.url,_that.description,_that.tags,_that.imageUrls,_that.videoUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String title,  String url,  String description,  List<String> tags,  List<String> imageUrls,  String? videoUrl)  $default,) {final _that = this;
switch (_that) {
case _BookmarkRequest():
return $default(_that.id,_that.title,_that.url,_that.description,_that.tags,_that.imageUrls,_that.videoUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String title,  String url,  String description,  List<String> tags,  List<String> imageUrls,  String? videoUrl)?  $default,) {final _that = this;
switch (_that) {
case _BookmarkRequest() when $default != null:
return $default(_that.id,_that.title,_that.url,_that.description,_that.tags,_that.imageUrls,_that.videoUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BookmarkRequest implements BookmarkRequest {
  const _BookmarkRequest({this.id, required this.title, required this.url, required this.description, required final  List<String> tags, final  List<String> imageUrls = const [], this.videoUrl}): _tags = tags,_imageUrls = imageUrls;
  factory _BookmarkRequest.fromJson(Map<String, dynamic> json) => _$BookmarkRequestFromJson(json);

@override final  String? id;
@override final  String title;
@override final  String url;
@override final  String description;
 final  List<String> _tags;
@override List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

 final  List<String> _imageUrls;
@override@JsonKey() List<String> get imageUrls {
  if (_imageUrls is EqualUnmodifiableListView) return _imageUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_imageUrls);
}

@override final  String? videoUrl;


@override
Map<String, dynamic> toJson() {
  return _$BookmarkRequestToJson(this, );
}



@override
String toString() {
  return 'BookmarkRequest(id: $id, title: $title, url: $url, description: $description, tags: $tags, imageUrls: $imageUrls, videoUrl: $videoUrl)';
}


}




// dart format on
