// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sign_in_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SignInResponse {

 AuthUserDto get user; String get token;

  /// Serializes this SignInResponse to a JSON map.
  Map<String, dynamic> toJson();




@override
String toString() {
  return 'SignInResponse(user: $user, token: $token)';
}


}




/// Adds pattern-matching-related methods to [SignInResponse].
extension SignInResponsePatterns on SignInResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SignInResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SignInResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SignInResponse value)  $default,){
final _that = this;
switch (_that) {
case _SignInResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SignInResponse value)?  $default,){
final _that = this;
switch (_that) {
case _SignInResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AuthUserDto user,  String token)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SignInResponse() when $default != null:
return $default(_that.user,_that.token);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AuthUserDto user,  String token)  $default,) {final _that = this;
switch (_that) {
case _SignInResponse():
return $default(_that.user,_that.token);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AuthUserDto user,  String token)?  $default,) {final _that = this;
switch (_that) {
case _SignInResponse() when $default != null:
return $default(_that.user,_that.token);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SignInResponse implements SignInResponse {
  const _SignInResponse({required this.user, required this.token});
  factory _SignInResponse.fromJson(Map<String, dynamic> json) => _$SignInResponseFromJson(json);

@override final  AuthUserDto user;
@override final  String token;


@override
Map<String, dynamic> toJson() {
  return _$SignInResponseToJson(this, );
}



@override
String toString() {
  return 'SignInResponse(user: $user, token: $token)';
}


}




// dart format on
