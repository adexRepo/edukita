// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'student_detail_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StudentDetailData {

 String get id; String get studentNo; String get classId; String get nickName; String get fullName; String get joinAt; Gender get gender; StudentStatus get status; String get className; String get schoolName; int get age; String get birthDate; String? get nis; String? get mobileNo; String? get emailAddr; String? get shoesSize; String? get uniformSize; String? get pantsSize; String? get teachingLocationName; String get profileStatus; double? get height; double? get weight; String? get photoPath;
/// Create a copy of StudentDetailData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StudentDetailDataCopyWith<StudentDetailData> get copyWith => _$StudentDetailDataCopyWithImpl<StudentDetailData>(this as StudentDetailData, _$identity);

  /// Serializes this StudentDetailData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StudentDetailData&&(identical(other.id, id) || other.id == id)&&(identical(other.studentNo, studentNo) || other.studentNo == studentNo)&&(identical(other.classId, classId) || other.classId == classId)&&(identical(other.nickName, nickName) || other.nickName == nickName)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.joinAt, joinAt) || other.joinAt == joinAt)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.status, status) || other.status == status)&&(identical(other.className, className) || other.className == className)&&(identical(other.schoolName, schoolName) || other.schoolName == schoolName)&&(identical(other.age, age) || other.age == age)&&(identical(other.birthDate, birthDate) || other.birthDate == birthDate)&&(identical(other.nis, nis) || other.nis == nis)&&(identical(other.mobileNo, mobileNo) || other.mobileNo == mobileNo)&&(identical(other.emailAddr, emailAddr) || other.emailAddr == emailAddr)&&(identical(other.shoesSize, shoesSize) || other.shoesSize == shoesSize)&&(identical(other.uniformSize, uniformSize) || other.uniformSize == uniformSize)&&(identical(other.pantsSize, pantsSize) || other.pantsSize == pantsSize)&&(identical(other.teachingLocationName, teachingLocationName) || other.teachingLocationName == teachingLocationName)&&(identical(other.profileStatus, profileStatus) || other.profileStatus == profileStatus)&&(identical(other.height, height) || other.height == height)&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.photoPath, photoPath) || other.photoPath == photoPath));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,studentNo,classId,nickName,fullName,joinAt,gender,status,className,schoolName,age,birthDate,nis,mobileNo,emailAddr,shoesSize,uniformSize,pantsSize,teachingLocationName,profileStatus,height,weight,photoPath]);

@override
String toString() {
  return 'StudentDetailData(id: $id, studentNo: $studentNo, classId: $classId, nickName: $nickName, fullName: $fullName, joinAt: $joinAt, gender: $gender, status: $status, className: $className, schoolName: $schoolName, age: $age, birthDate: $birthDate, nis: $nis, mobileNo: $mobileNo, emailAddr: $emailAddr, shoesSize: $shoesSize, uniformSize: $uniformSize, pantsSize: $pantsSize, teachingLocationName: $teachingLocationName, profileStatus: $profileStatus, height: $height, weight: $weight, photoPath: $photoPath)';
}


}

/// @nodoc
abstract mixin class $StudentDetailDataCopyWith<$Res>  {
  factory $StudentDetailDataCopyWith(StudentDetailData value, $Res Function(StudentDetailData) _then) = _$StudentDetailDataCopyWithImpl;
@useResult
$Res call({
 String id, String studentNo, String classId, String nickName, String fullName, String joinAt, Gender gender, StudentStatus status, String className, String schoolName, int age, String birthDate, String? nis, String? mobileNo, String? emailAddr, String? shoesSize, String? uniformSize, String? pantsSize, String? teachingLocationName, String profileStatus, double? height, double? weight, String? photoPath
});




}
/// @nodoc
class _$StudentDetailDataCopyWithImpl<$Res>
    implements $StudentDetailDataCopyWith<$Res> {
  _$StudentDetailDataCopyWithImpl(this._self, this._then);

  final StudentDetailData _self;
  final $Res Function(StudentDetailData) _then;

/// Create a copy of StudentDetailData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? studentNo = null,Object? classId = null,Object? nickName = null,Object? fullName = null,Object? joinAt = null,Object? gender = null,Object? status = null,Object? className = null,Object? schoolName = null,Object? age = null,Object? birthDate = null,Object? nis = freezed,Object? mobileNo = freezed,Object? emailAddr = freezed,Object? shoesSize = freezed,Object? uniformSize = freezed,Object? pantsSize = freezed,Object? teachingLocationName = freezed,Object? profileStatus = null,Object? height = freezed,Object? weight = freezed,Object? photoPath = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,studentNo: null == studentNo ? _self.studentNo : studentNo // ignore: cast_nullable_to_non_nullable
as String,classId: null == classId ? _self.classId : classId // ignore: cast_nullable_to_non_nullable
as String,nickName: null == nickName ? _self.nickName : nickName // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,joinAt: null == joinAt ? _self.joinAt : joinAt // ignore: cast_nullable_to_non_nullable
as String,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as Gender,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as StudentStatus,className: null == className ? _self.className : className // ignore: cast_nullable_to_non_nullable
as String,schoolName: null == schoolName ? _self.schoolName : schoolName // ignore: cast_nullable_to_non_nullable
as String,age: null == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int,birthDate: null == birthDate ? _self.birthDate : birthDate // ignore: cast_nullable_to_non_nullable
as String,nis: freezed == nis ? _self.nis : nis // ignore: cast_nullable_to_non_nullable
as String?,mobileNo: freezed == mobileNo ? _self.mobileNo : mobileNo // ignore: cast_nullable_to_non_nullable
as String?,emailAddr: freezed == emailAddr ? _self.emailAddr : emailAddr // ignore: cast_nullable_to_non_nullable
as String?,shoesSize: freezed == shoesSize ? _self.shoesSize : shoesSize // ignore: cast_nullable_to_non_nullable
as String?,uniformSize: freezed == uniformSize ? _self.uniformSize : uniformSize // ignore: cast_nullable_to_non_nullable
as String?,pantsSize: freezed == pantsSize ? _self.pantsSize : pantsSize // ignore: cast_nullable_to_non_nullable
as String?,teachingLocationName: freezed == teachingLocationName ? _self.teachingLocationName : teachingLocationName // ignore: cast_nullable_to_non_nullable
as String?,profileStatus: null == profileStatus ? _self.profileStatus : profileStatus // ignore: cast_nullable_to_non_nullable
as String,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double?,weight: freezed == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as double?,photoPath: freezed == photoPath ? _self.photoPath : photoPath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [StudentDetailData].
extension StudentDetailDataPatterns on StudentDetailData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StudentDetailData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StudentDetailData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StudentDetailData value)  $default,){
final _that = this;
switch (_that) {
case _StudentDetailData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StudentDetailData value)?  $default,){
final _that = this;
switch (_that) {
case _StudentDetailData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String studentNo,  String classId,  String nickName,  String fullName,  String joinAt,  Gender gender,  StudentStatus status,  String className,  String schoolName,  int age,  String birthDate,  String? nis,  String? mobileNo,  String? emailAddr,  String? shoesSize,  String? uniformSize,  String? pantsSize,  String? teachingLocationName,  String profileStatus,  double? height,  double? weight,  String? photoPath)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StudentDetailData() when $default != null:
return $default(_that.id,_that.studentNo,_that.classId,_that.nickName,_that.fullName,_that.joinAt,_that.gender,_that.status,_that.className,_that.schoolName,_that.age,_that.birthDate,_that.nis,_that.mobileNo,_that.emailAddr,_that.shoesSize,_that.uniformSize,_that.pantsSize,_that.teachingLocationName,_that.profileStatus,_that.height,_that.weight,_that.photoPath);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String studentNo,  String classId,  String nickName,  String fullName,  String joinAt,  Gender gender,  StudentStatus status,  String className,  String schoolName,  int age,  String birthDate,  String? nis,  String? mobileNo,  String? emailAddr,  String? shoesSize,  String? uniformSize,  String? pantsSize,  String? teachingLocationName,  String profileStatus,  double? height,  double? weight,  String? photoPath)  $default,) {final _that = this;
switch (_that) {
case _StudentDetailData():
return $default(_that.id,_that.studentNo,_that.classId,_that.nickName,_that.fullName,_that.joinAt,_that.gender,_that.status,_that.className,_that.schoolName,_that.age,_that.birthDate,_that.nis,_that.mobileNo,_that.emailAddr,_that.shoesSize,_that.uniformSize,_that.pantsSize,_that.teachingLocationName,_that.profileStatus,_that.height,_that.weight,_that.photoPath);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String studentNo,  String classId,  String nickName,  String fullName,  String joinAt,  Gender gender,  StudentStatus status,  String className,  String schoolName,  int age,  String birthDate,  String? nis,  String? mobileNo,  String? emailAddr,  String? shoesSize,  String? uniformSize,  String? pantsSize,  String? teachingLocationName,  String profileStatus,  double? height,  double? weight,  String? photoPath)?  $default,) {final _that = this;
switch (_that) {
case _StudentDetailData() when $default != null:
return $default(_that.id,_that.studentNo,_that.classId,_that.nickName,_that.fullName,_that.joinAt,_that.gender,_that.status,_that.className,_that.schoolName,_that.age,_that.birthDate,_that.nis,_that.mobileNo,_that.emailAddr,_that.shoesSize,_that.uniformSize,_that.pantsSize,_that.teachingLocationName,_that.profileStatus,_that.height,_that.weight,_that.photoPath);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StudentDetailData implements StudentDetailData {
  const _StudentDetailData({required this.id, required this.studentNo, required this.classId, required this.nickName, required this.fullName, required this.joinAt, required this.gender, required this.status, required this.className, required this.schoolName, required this.age, required this.birthDate, this.nis, this.mobileNo, this.emailAddr, this.shoesSize, this.uniformSize, this.pantsSize, this.teachingLocationName, this.profileStatus = 'complete', this.height, this.weight, this.photoPath});
  factory _StudentDetailData.fromJson(Map<String, dynamic> json) => _$StudentDetailDataFromJson(json);

@override final  String id;
@override final  String studentNo;
@override final  String classId;
@override final  String nickName;
@override final  String fullName;
@override final  String joinAt;
@override final  Gender gender;
@override final  StudentStatus status;
@override final  String className;
@override final  String schoolName;
@override final  int age;
@override final  String birthDate;
@override final  String? nis;
@override final  String? mobileNo;
@override final  String? emailAddr;
@override final  String? shoesSize;
@override final  String? uniformSize;
@override final  String? pantsSize;
@override final  String? teachingLocationName;
@override@JsonKey() final  String profileStatus;
@override final  double? height;
@override final  double? weight;
@override final  String? photoPath;

/// Create a copy of StudentDetailData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StudentDetailDataCopyWith<_StudentDetailData> get copyWith => __$StudentDetailDataCopyWithImpl<_StudentDetailData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StudentDetailDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StudentDetailData&&(identical(other.id, id) || other.id == id)&&(identical(other.studentNo, studentNo) || other.studentNo == studentNo)&&(identical(other.classId, classId) || other.classId == classId)&&(identical(other.nickName, nickName) || other.nickName == nickName)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.joinAt, joinAt) || other.joinAt == joinAt)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.status, status) || other.status == status)&&(identical(other.className, className) || other.className == className)&&(identical(other.schoolName, schoolName) || other.schoolName == schoolName)&&(identical(other.age, age) || other.age == age)&&(identical(other.birthDate, birthDate) || other.birthDate == birthDate)&&(identical(other.nis, nis) || other.nis == nis)&&(identical(other.mobileNo, mobileNo) || other.mobileNo == mobileNo)&&(identical(other.emailAddr, emailAddr) || other.emailAddr == emailAddr)&&(identical(other.shoesSize, shoesSize) || other.shoesSize == shoesSize)&&(identical(other.uniformSize, uniformSize) || other.uniformSize == uniformSize)&&(identical(other.pantsSize, pantsSize) || other.pantsSize == pantsSize)&&(identical(other.teachingLocationName, teachingLocationName) || other.teachingLocationName == teachingLocationName)&&(identical(other.profileStatus, profileStatus) || other.profileStatus == profileStatus)&&(identical(other.height, height) || other.height == height)&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.photoPath, photoPath) || other.photoPath == photoPath));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,studentNo,classId,nickName,fullName,joinAt,gender,status,className,schoolName,age,birthDate,nis,mobileNo,emailAddr,shoesSize,uniformSize,pantsSize,teachingLocationName,profileStatus,height,weight,photoPath]);

@override
String toString() {
  return 'StudentDetailData(id: $id, studentNo: $studentNo, classId: $classId, nickName: $nickName, fullName: $fullName, joinAt: $joinAt, gender: $gender, status: $status, className: $className, schoolName: $schoolName, age: $age, birthDate: $birthDate, nis: $nis, mobileNo: $mobileNo, emailAddr: $emailAddr, shoesSize: $shoesSize, uniformSize: $uniformSize, pantsSize: $pantsSize, teachingLocationName: $teachingLocationName, profileStatus: $profileStatus, height: $height, weight: $weight, photoPath: $photoPath)';
}


}

/// @nodoc
abstract mixin class _$StudentDetailDataCopyWith<$Res> implements $StudentDetailDataCopyWith<$Res> {
  factory _$StudentDetailDataCopyWith(_StudentDetailData value, $Res Function(_StudentDetailData) _then) = __$StudentDetailDataCopyWithImpl;
@override @useResult
$Res call({
 String id, String studentNo, String classId, String nickName, String fullName, String joinAt, Gender gender, StudentStatus status, String className, String schoolName, int age, String birthDate, String? nis, String? mobileNo, String? emailAddr, String? shoesSize, String? uniformSize, String? pantsSize, String? teachingLocationName, String profileStatus, double? height, double? weight, String? photoPath
});




}
/// @nodoc
class __$StudentDetailDataCopyWithImpl<$Res>
    implements _$StudentDetailDataCopyWith<$Res> {
  __$StudentDetailDataCopyWithImpl(this._self, this._then);

  final _StudentDetailData _self;
  final $Res Function(_StudentDetailData) _then;

/// Create a copy of StudentDetailData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? studentNo = null,Object? classId = null,Object? nickName = null,Object? fullName = null,Object? joinAt = null,Object? gender = null,Object? status = null,Object? className = null,Object? schoolName = null,Object? age = null,Object? birthDate = null,Object? nis = freezed,Object? mobileNo = freezed,Object? emailAddr = freezed,Object? shoesSize = freezed,Object? uniformSize = freezed,Object? pantsSize = freezed,Object? teachingLocationName = freezed,Object? profileStatus = null,Object? height = freezed,Object? weight = freezed,Object? photoPath = freezed,}) {
  return _then(_StudentDetailData(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,studentNo: null == studentNo ? _self.studentNo : studentNo // ignore: cast_nullable_to_non_nullable
as String,classId: null == classId ? _self.classId : classId // ignore: cast_nullable_to_non_nullable
as String,nickName: null == nickName ? _self.nickName : nickName // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,joinAt: null == joinAt ? _self.joinAt : joinAt // ignore: cast_nullable_to_non_nullable
as String,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as Gender,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as StudentStatus,className: null == className ? _self.className : className // ignore: cast_nullable_to_non_nullable
as String,schoolName: null == schoolName ? _self.schoolName : schoolName // ignore: cast_nullable_to_non_nullable
as String,age: null == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int,birthDate: null == birthDate ? _self.birthDate : birthDate // ignore: cast_nullable_to_non_nullable
as String,nis: freezed == nis ? _self.nis : nis // ignore: cast_nullable_to_non_nullable
as String?,mobileNo: freezed == mobileNo ? _self.mobileNo : mobileNo // ignore: cast_nullable_to_non_nullable
as String?,emailAddr: freezed == emailAddr ? _self.emailAddr : emailAddr // ignore: cast_nullable_to_non_nullable
as String?,shoesSize: freezed == shoesSize ? _self.shoesSize : shoesSize // ignore: cast_nullable_to_non_nullable
as String?,uniformSize: freezed == uniformSize ? _self.uniformSize : uniformSize // ignore: cast_nullable_to_non_nullable
as String?,pantsSize: freezed == pantsSize ? _self.pantsSize : pantsSize // ignore: cast_nullable_to_non_nullable
as String?,teachingLocationName: freezed == teachingLocationName ? _self.teachingLocationName : teachingLocationName // ignore: cast_nullable_to_non_nullable
as String?,profileStatus: null == profileStatus ? _self.profileStatus : profileStatus // ignore: cast_nullable_to_non_nullable
as String,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double?,weight: freezed == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as double?,photoPath: freezed == photoPath ? _self.photoPath : photoPath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
