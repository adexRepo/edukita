// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'story_student.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StoryStudent {

 String get id; String get studentId; String get story; String get createdBy; String? get createdAt;
/// Create a copy of StoryStudent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StoryStudentCopyWith<StoryStudent> get copyWith => _$StoryStudentCopyWithImpl<StoryStudent>(this as StoryStudent, _$identity);

  /// Serializes this StoryStudent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StoryStudent&&(identical(other.id, id) || other.id == id)&&(identical(other.studentId, studentId) || other.studentId == studentId)&&(identical(other.story, story) || other.story == story)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,studentId,story,createdBy,createdAt);

@override
String toString() {
  return 'StoryStudent(id: $id, studentId: $studentId, story: $story, createdBy: $createdBy, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $StoryStudentCopyWith<$Res>  {
  factory $StoryStudentCopyWith(StoryStudent value, $Res Function(StoryStudent) _then) = _$StoryStudentCopyWithImpl;
@useResult
$Res call({
 String id, String studentId, String story, String createdBy, String? createdAt
});




}
/// @nodoc
class _$StoryStudentCopyWithImpl<$Res>
    implements $StoryStudentCopyWith<$Res> {
  _$StoryStudentCopyWithImpl(this._self, this._then);

  final StoryStudent _self;
  final $Res Function(StoryStudent) _then;

/// Create a copy of StoryStudent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? studentId = null,Object? story = null,Object? createdBy = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,studentId: null == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as String,story: null == story ? _self.story : story // ignore: cast_nullable_to_non_nullable
as String,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [StoryStudent].
extension StoryStudentPatterns on StoryStudent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StoryStudent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StoryStudent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StoryStudent value)  $default,){
final _that = this;
switch (_that) {
case _StoryStudent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StoryStudent value)?  $default,){
final _that = this;
switch (_that) {
case _StoryStudent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String studentId,  String story,  String createdBy,  String? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StoryStudent() when $default != null:
return $default(_that.id,_that.studentId,_that.story,_that.createdBy,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String studentId,  String story,  String createdBy,  String? createdAt)  $default,) {final _that = this;
switch (_that) {
case _StoryStudent():
return $default(_that.id,_that.studentId,_that.story,_that.createdBy,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String studentId,  String story,  String createdBy,  String? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _StoryStudent() when $default != null:
return $default(_that.id,_that.studentId,_that.story,_that.createdBy,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StoryStudent implements StoryStudent {
  const _StoryStudent({required this.id, required this.studentId, required this.story, required this.createdBy, this.createdAt});
  factory _StoryStudent.fromJson(Map<String, dynamic> json) => _$StoryStudentFromJson(json);

@override final  String id;
@override final  String studentId;
@override final  String story;
@override final  String createdBy;
@override final  String? createdAt;

/// Create a copy of StoryStudent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StoryStudentCopyWith<_StoryStudent> get copyWith => __$StoryStudentCopyWithImpl<_StoryStudent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StoryStudentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StoryStudent&&(identical(other.id, id) || other.id == id)&&(identical(other.studentId, studentId) || other.studentId == studentId)&&(identical(other.story, story) || other.story == story)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,studentId,story,createdBy,createdAt);

@override
String toString() {
  return 'StoryStudent(id: $id, studentId: $studentId, story: $story, createdBy: $createdBy, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$StoryStudentCopyWith<$Res> implements $StoryStudentCopyWith<$Res> {
  factory _$StoryStudentCopyWith(_StoryStudent value, $Res Function(_StoryStudent) _then) = __$StoryStudentCopyWithImpl;
@override @useResult
$Res call({
 String id, String studentId, String story, String createdBy, String? createdAt
});




}
/// @nodoc
class __$StoryStudentCopyWithImpl<$Res>
    implements _$StoryStudentCopyWith<$Res> {
  __$StoryStudentCopyWithImpl(this._self, this._then);

  final _StoryStudent _self;
  final $Res Function(_StoryStudent) _then;

/// Create a copy of StoryStudent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? studentId = null,Object? story = null,Object? createdBy = null,Object? createdAt = freezed,}) {
  return _then(_StoryStudent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,studentId: null == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as String,story: null == story ? _self.story : story // ignore: cast_nullable_to_non_nullable
as String,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
