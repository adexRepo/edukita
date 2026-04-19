// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'student.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Student {

 String get id; String get studentId; String get classId; String? get nickName; String get fullName; String get joinAt; String? get nis; String? get birthDate; Gender? get gender; String? get mobileNo; String? get emailAddr; int? get shoeSize; int? get uniformSize; int? get pantsSize; double? get height; double? get weight; String? get photoPath; StudentStatus get status;
/// Create a copy of Student
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StudentCopyWith<Student> get copyWith => _$StudentCopyWithImpl<Student>(this as Student, _$identity);

  /// Serializes this Student to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Student&&(identical(other.id, id) || other.id == id)&&(identical(other.studentId, studentId) || other.studentId == studentId)&&(identical(other.classId, classId) || other.classId == classId)&&(identical(other.nickName, nickName) || other.nickName == nickName)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.joinAt, joinAt) || other.joinAt == joinAt)&&(identical(other.nis, nis) || other.nis == nis)&&(identical(other.birthDate, birthDate) || other.birthDate == birthDate)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.mobileNo, mobileNo) || other.mobileNo == mobileNo)&&(identical(other.emailAddr, emailAddr) || other.emailAddr == emailAddr)&&(identical(other.shoeSize, shoeSize) || other.shoeSize == shoeSize)&&(identical(other.uniformSize, uniformSize) || other.uniformSize == uniformSize)&&(identical(other.pantsSize, pantsSize) || other.pantsSize == pantsSize)&&(identical(other.height, height) || other.height == height)&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.photoPath, photoPath) || other.photoPath == photoPath)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,studentId,classId,nickName,fullName,joinAt,nis,birthDate,gender,mobileNo,emailAddr,shoeSize,uniformSize,pantsSize,height,weight,photoPath,status);

@override
String toString() {
  return 'Student(id: $id, studentId: $studentId, classId: $classId, nickName: $nickName, fullName: $fullName, joinAt: $joinAt, nis: $nis, birthDate: $birthDate, gender: $gender, mobileNo: $mobileNo, emailAddr: $emailAddr, shoeSize: $shoeSize, uniformSize: $uniformSize, pantsSize: $pantsSize, height: $height, weight: $weight, photoPath: $photoPath, status: $status)';
}


}

/// @nodoc
abstract mixin class $StudentCopyWith<$Res>  {
  factory $StudentCopyWith(Student value, $Res Function(Student) _then) = _$StudentCopyWithImpl;
@useResult
$Res call({
 String id, String studentId, String classId, String? nickName, String fullName, String joinAt, String? nis, String? birthDate, Gender? gender, String? mobileNo, String? emailAddr, int? shoeSize, int? uniformSize, int? pantsSize, double? height, double? weight, String? photoPath, StudentStatus status
});




}
/// @nodoc
class _$StudentCopyWithImpl<$Res>
    implements $StudentCopyWith<$Res> {
  _$StudentCopyWithImpl(this._self, this._then);

  final Student _self;
  final $Res Function(Student) _then;

/// Create a copy of Student
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? studentId = null,Object? classId = null,Object? nickName = freezed,Object? fullName = null,Object? joinAt = null,Object? nis = freezed,Object? birthDate = freezed,Object? gender = freezed,Object? mobileNo = freezed,Object? emailAddr = freezed,Object? shoeSize = freezed,Object? uniformSize = freezed,Object? pantsSize = freezed,Object? height = freezed,Object? weight = freezed,Object? photoPath = freezed,Object? status = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,studentId: null == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as String,classId: null == classId ? _self.classId : classId // ignore: cast_nullable_to_non_nullable
as String,nickName: freezed == nickName ? _self.nickName : nickName // ignore: cast_nullable_to_non_nullable
as String?,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,joinAt: null == joinAt ? _self.joinAt : joinAt // ignore: cast_nullable_to_non_nullable
as String,nis: freezed == nis ? _self.nis : nis // ignore: cast_nullable_to_non_nullable
as String?,birthDate: freezed == birthDate ? _self.birthDate : birthDate // ignore: cast_nullable_to_non_nullable
as String?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as Gender?,mobileNo: freezed == mobileNo ? _self.mobileNo : mobileNo // ignore: cast_nullable_to_non_nullable
as String?,emailAddr: freezed == emailAddr ? _self.emailAddr : emailAddr // ignore: cast_nullable_to_non_nullable
as String?,shoeSize: freezed == shoeSize ? _self.shoeSize : shoeSize // ignore: cast_nullable_to_non_nullable
as int?,uniformSize: freezed == uniformSize ? _self.uniformSize : uniformSize // ignore: cast_nullable_to_non_nullable
as int?,pantsSize: freezed == pantsSize ? _self.pantsSize : pantsSize // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double?,weight: freezed == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as double?,photoPath: freezed == photoPath ? _self.photoPath : photoPath // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as StudentStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [Student].
extension StudentPatterns on Student {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Student value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Student() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Student value)  $default,){
final _that = this;
switch (_that) {
case _Student():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Student value)?  $default,){
final _that = this;
switch (_that) {
case _Student() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String studentId,  String classId,  String? nickName,  String fullName,  String joinAt,  String? nis,  String? birthDate,  Gender? gender,  String? mobileNo,  String? emailAddr,  int? shoeSize,  int? uniformSize,  int? pantsSize,  double? height,  double? weight,  String? photoPath,  StudentStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Student() when $default != null:
return $default(_that.id,_that.studentId,_that.classId,_that.nickName,_that.fullName,_that.joinAt,_that.nis,_that.birthDate,_that.gender,_that.mobileNo,_that.emailAddr,_that.shoeSize,_that.uniformSize,_that.pantsSize,_that.height,_that.weight,_that.photoPath,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String studentId,  String classId,  String? nickName,  String fullName,  String joinAt,  String? nis,  String? birthDate,  Gender? gender,  String? mobileNo,  String? emailAddr,  int? shoeSize,  int? uniformSize,  int? pantsSize,  double? height,  double? weight,  String? photoPath,  StudentStatus status)  $default,) {final _that = this;
switch (_that) {
case _Student():
return $default(_that.id,_that.studentId,_that.classId,_that.nickName,_that.fullName,_that.joinAt,_that.nis,_that.birthDate,_that.gender,_that.mobileNo,_that.emailAddr,_that.shoeSize,_that.uniformSize,_that.pantsSize,_that.height,_that.weight,_that.photoPath,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String studentId,  String classId,  String? nickName,  String fullName,  String joinAt,  String? nis,  String? birthDate,  Gender? gender,  String? mobileNo,  String? emailAddr,  int? shoeSize,  int? uniformSize,  int? pantsSize,  double? height,  double? weight,  String? photoPath,  StudentStatus status)?  $default,) {final _that = this;
switch (_that) {
case _Student() when $default != null:
return $default(_that.id,_that.studentId,_that.classId,_that.nickName,_that.fullName,_that.joinAt,_that.nis,_that.birthDate,_that.gender,_that.mobileNo,_that.emailAddr,_that.shoeSize,_that.uniformSize,_that.pantsSize,_that.height,_that.weight,_that.photoPath,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Student implements Student {
  const _Student({required this.id, required this.studentId, required this.classId, this.nickName, required this.fullName, required this.joinAt, this.nis, this.birthDate, this.gender, this.mobileNo, this.emailAddr, this.shoeSize, this.uniformSize, this.pantsSize, this.height, this.weight, this.photoPath, required this.status});
  factory _Student.fromJson(Map<String, dynamic> json) => _$StudentFromJson(json);

@override final  String id;
@override final  String studentId;
@override final  String classId;
@override final  String? nickName;
@override final  String fullName;
@override final  String joinAt;
@override final  String? nis;
@override final  String? birthDate;
@override final  Gender? gender;
@override final  String? mobileNo;
@override final  String? emailAddr;
@override final  int? shoeSize;
@override final  int? uniformSize;
@override final  int? pantsSize;
@override final  double? height;
@override final  double? weight;
@override final  String? photoPath;
@override final  StudentStatus status;

/// Create a copy of Student
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StudentCopyWith<_Student> get copyWith => __$StudentCopyWithImpl<_Student>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StudentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Student&&(identical(other.id, id) || other.id == id)&&(identical(other.studentId, studentId) || other.studentId == studentId)&&(identical(other.classId, classId) || other.classId == classId)&&(identical(other.nickName, nickName) || other.nickName == nickName)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.joinAt, joinAt) || other.joinAt == joinAt)&&(identical(other.nis, nis) || other.nis == nis)&&(identical(other.birthDate, birthDate) || other.birthDate == birthDate)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.mobileNo, mobileNo) || other.mobileNo == mobileNo)&&(identical(other.emailAddr, emailAddr) || other.emailAddr == emailAddr)&&(identical(other.shoeSize, shoeSize) || other.shoeSize == shoeSize)&&(identical(other.uniformSize, uniformSize) || other.uniformSize == uniformSize)&&(identical(other.pantsSize, pantsSize) || other.pantsSize == pantsSize)&&(identical(other.height, height) || other.height == height)&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.photoPath, photoPath) || other.photoPath == photoPath)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,studentId,classId,nickName,fullName,joinAt,nis,birthDate,gender,mobileNo,emailAddr,shoeSize,uniformSize,pantsSize,height,weight,photoPath,status);

@override
String toString() {
  return 'Student(id: $id, studentId: $studentId, classId: $classId, nickName: $nickName, fullName: $fullName, joinAt: $joinAt, nis: $nis, birthDate: $birthDate, gender: $gender, mobileNo: $mobileNo, emailAddr: $emailAddr, shoeSize: $shoeSize, uniformSize: $uniformSize, pantsSize: $pantsSize, height: $height, weight: $weight, photoPath: $photoPath, status: $status)';
}


}

/// @nodoc
abstract mixin class _$StudentCopyWith<$Res> implements $StudentCopyWith<$Res> {
  factory _$StudentCopyWith(_Student value, $Res Function(_Student) _then) = __$StudentCopyWithImpl;
@override @useResult
$Res call({
 String id, String studentId, String classId, String? nickName, String fullName, String joinAt, String? nis, String? birthDate, Gender? gender, String? mobileNo, String? emailAddr, int? shoeSize, int? uniformSize, int? pantsSize, double? height, double? weight, String? photoPath, StudentStatus status
});




}
/// @nodoc
class __$StudentCopyWithImpl<$Res>
    implements _$StudentCopyWith<$Res> {
  __$StudentCopyWithImpl(this._self, this._then);

  final _Student _self;
  final $Res Function(_Student) _then;

/// Create a copy of Student
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? studentId = null,Object? classId = null,Object? nickName = freezed,Object? fullName = null,Object? joinAt = null,Object? nis = freezed,Object? birthDate = freezed,Object? gender = freezed,Object? mobileNo = freezed,Object? emailAddr = freezed,Object? shoeSize = freezed,Object? uniformSize = freezed,Object? pantsSize = freezed,Object? height = freezed,Object? weight = freezed,Object? photoPath = freezed,Object? status = null,}) {
  return _then(_Student(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,studentId: null == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as String,classId: null == classId ? _self.classId : classId // ignore: cast_nullable_to_non_nullable
as String,nickName: freezed == nickName ? _self.nickName : nickName // ignore: cast_nullable_to_non_nullable
as String?,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,joinAt: null == joinAt ? _self.joinAt : joinAt // ignore: cast_nullable_to_non_nullable
as String,nis: freezed == nis ? _self.nis : nis // ignore: cast_nullable_to_non_nullable
as String?,birthDate: freezed == birthDate ? _self.birthDate : birthDate // ignore: cast_nullable_to_non_nullable
as String?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as Gender?,mobileNo: freezed == mobileNo ? _self.mobileNo : mobileNo // ignore: cast_nullable_to_non_nullable
as String?,emailAddr: freezed == emailAddr ? _self.emailAddr : emailAddr // ignore: cast_nullable_to_non_nullable
as String?,shoeSize: freezed == shoeSize ? _self.shoeSize : shoeSize // ignore: cast_nullable_to_non_nullable
as int?,uniformSize: freezed == uniformSize ? _self.uniformSize : uniformSize // ignore: cast_nullable_to_non_nullable
as int?,pantsSize: freezed == pantsSize ? _self.pantsSize : pantsSize // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double?,weight: freezed == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as double?,photoPath: freezed == photoPath ? _self.photoPath : photoPath // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as StudentStatus,
  ));
}


}

// dart format on
