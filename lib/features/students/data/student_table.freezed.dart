// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'student_table.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StudentTable {

 String get id; String get studentId; String get fullName; String get className; String get schoolName; Gender get gender; StudentStatus get status; String get jointDate; String? get nis; String? get photoPath;
/// Create a copy of StudentTable
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StudentTableCopyWith<StudentTable> get copyWith => _$StudentTableCopyWithImpl<StudentTable>(this as StudentTable, _$identity);

  /// Serializes this StudentTable to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StudentTable&&(identical(other.id, id) || other.id == id)&&(identical(other.studentId, studentId) || other.studentId == studentId)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.className, className) || other.className == className)&&(identical(other.schoolName, schoolName) || other.schoolName == schoolName)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.status, status) || other.status == status)&&(identical(other.jointDate, jointDate) || other.jointDate == jointDate)&&(identical(other.nis, nis) || other.nis == nis)&&(identical(other.photoPath, photoPath) || other.photoPath == photoPath));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,studentId,fullName,className,schoolName,gender,status,jointDate,nis,photoPath);

@override
String toString() {
  return 'StudentTable(id: $id, studentId: $studentId, fullName: $fullName, className: $className, schoolName: $schoolName, gender: $gender, status: $status, jointDate: $jointDate, nis: $nis, photoPath: $photoPath)';
}


}

/// @nodoc
abstract mixin class $StudentTableCopyWith<$Res>  {
  factory $StudentTableCopyWith(StudentTable value, $Res Function(StudentTable) _then) = _$StudentTableCopyWithImpl;
@useResult
$Res call({
 String id, String studentId, String fullName, String className, String schoolName, Gender gender, StudentStatus status, String jointDate, String? nis, String? photoPath
});




}
/// @nodoc
class _$StudentTableCopyWithImpl<$Res>
    implements $StudentTableCopyWith<$Res> {
  _$StudentTableCopyWithImpl(this._self, this._then);

  final StudentTable _self;
  final $Res Function(StudentTable) _then;

/// Create a copy of StudentTable
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? studentId = null,Object? fullName = null,Object? className = null,Object? schoolName = null,Object? gender = null,Object? status = null,Object? jointDate = null,Object? nis = freezed,Object? photoPath = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,studentId: null == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,className: null == className ? _self.className : className // ignore: cast_nullable_to_non_nullable
as String,schoolName: null == schoolName ? _self.schoolName : schoolName // ignore: cast_nullable_to_non_nullable
as String,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as Gender,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as StudentStatus,jointDate: null == jointDate ? _self.jointDate : jointDate // ignore: cast_nullable_to_non_nullable
as String,nis: freezed == nis ? _self.nis : nis // ignore: cast_nullable_to_non_nullable
as String?,photoPath: freezed == photoPath ? _self.photoPath : photoPath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [StudentTable].
extension StudentTablePatterns on StudentTable {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StudentTable value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StudentTable() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StudentTable value)  $default,){
final _that = this;
switch (_that) {
case _StudentTable():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StudentTable value)?  $default,){
final _that = this;
switch (_that) {
case _StudentTable() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String studentId,  String fullName,  String className,  String schoolName,  Gender gender,  StudentStatus status,  String jointDate,  String? nis,  String? photoPath)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StudentTable() when $default != null:
return $default(_that.id,_that.studentId,_that.fullName,_that.className,_that.schoolName,_that.gender,_that.status,_that.jointDate,_that.nis,_that.photoPath);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String studentId,  String fullName,  String className,  String schoolName,  Gender gender,  StudentStatus status,  String jointDate,  String? nis,  String? photoPath)  $default,) {final _that = this;
switch (_that) {
case _StudentTable():
return $default(_that.id,_that.studentId,_that.fullName,_that.className,_that.schoolName,_that.gender,_that.status,_that.jointDate,_that.nis,_that.photoPath);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String studentId,  String fullName,  String className,  String schoolName,  Gender gender,  StudentStatus status,  String jointDate,  String? nis,  String? photoPath)?  $default,) {final _that = this;
switch (_that) {
case _StudentTable() when $default != null:
return $default(_that.id,_that.studentId,_that.fullName,_that.className,_that.schoolName,_that.gender,_that.status,_that.jointDate,_that.nis,_that.photoPath);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StudentTable implements StudentTable {
  const _StudentTable({required this.id, required this.studentId, required this.fullName, required this.className, required this.schoolName, required this.gender, required this.status, required this.jointDate, this.nis, this.photoPath});
  factory _StudentTable.fromJson(Map<String, dynamic> json) => _$StudentTableFromJson(json);

@override final  String id;
@override final  String studentId;
@override final  String fullName;
@override final  String className;
@override final  String schoolName;
@override final  Gender gender;
@override final  StudentStatus status;
@override final  String jointDate;
@override final  String? nis;
@override final  String? photoPath;

/// Create a copy of StudentTable
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StudentTableCopyWith<_StudentTable> get copyWith => __$StudentTableCopyWithImpl<_StudentTable>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StudentTableToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StudentTable&&(identical(other.id, id) || other.id == id)&&(identical(other.studentId, studentId) || other.studentId == studentId)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.className, className) || other.className == className)&&(identical(other.schoolName, schoolName) || other.schoolName == schoolName)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.status, status) || other.status == status)&&(identical(other.jointDate, jointDate) || other.jointDate == jointDate)&&(identical(other.nis, nis) || other.nis == nis)&&(identical(other.photoPath, photoPath) || other.photoPath == photoPath));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,studentId,fullName,className,schoolName,gender,status,jointDate,nis,photoPath);

@override
String toString() {
  return 'StudentTable(id: $id, studentId: $studentId, fullName: $fullName, className: $className, schoolName: $schoolName, gender: $gender, status: $status, jointDate: $jointDate, nis: $nis, photoPath: $photoPath)';
}


}

/// @nodoc
abstract mixin class _$StudentTableCopyWith<$Res> implements $StudentTableCopyWith<$Res> {
  factory _$StudentTableCopyWith(_StudentTable value, $Res Function(_StudentTable) _then) = __$StudentTableCopyWithImpl;
@override @useResult
$Res call({
 String id, String studentId, String fullName, String className, String schoolName, Gender gender, StudentStatus status, String jointDate, String? nis, String? photoPath
});




}
/// @nodoc
class __$StudentTableCopyWithImpl<$Res>
    implements _$StudentTableCopyWith<$Res> {
  __$StudentTableCopyWithImpl(this._self, this._then);

  final _StudentTable _self;
  final $Res Function(_StudentTable) _then;

/// Create a copy of StudentTable
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? studentId = null,Object? fullName = null,Object? className = null,Object? schoolName = null,Object? gender = null,Object? status = null,Object? jointDate = null,Object? nis = freezed,Object? photoPath = freezed,}) {
  return _then(_StudentTable(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,studentId: null == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,className: null == className ? _self.className : className // ignore: cast_nullable_to_non_nullable
as String,schoolName: null == schoolName ? _self.schoolName : schoolName // ignore: cast_nullable_to_non_nullable
as String,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as Gender,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as StudentStatus,jointDate: null == jointDate ? _self.jointDate : jointDate // ignore: cast_nullable_to_non_nullable
as String,nis: freezed == nis ? _self.nis : nis // ignore: cast_nullable_to_non_nullable
as String?,photoPath: freezed == photoPath ? _self.photoPath : photoPath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
