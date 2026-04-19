// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'student_page_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StudentPageData {

 int get totalStudents; int get maleStudents; int get femaleStudents; int get activeStudents; List<StudentTable>? get students;
/// Create a copy of StudentPageData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StudentPageDataCopyWith<StudentPageData> get copyWith => _$StudentPageDataCopyWithImpl<StudentPageData>(this as StudentPageData, _$identity);

  /// Serializes this StudentPageData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StudentPageData&&(identical(other.totalStudents, totalStudents) || other.totalStudents == totalStudents)&&(identical(other.maleStudents, maleStudents) || other.maleStudents == maleStudents)&&(identical(other.femaleStudents, femaleStudents) || other.femaleStudents == femaleStudents)&&(identical(other.activeStudents, activeStudents) || other.activeStudents == activeStudents)&&const DeepCollectionEquality().equals(other.students, students));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalStudents,maleStudents,femaleStudents,activeStudents,const DeepCollectionEquality().hash(students));

@override
String toString() {
  return 'StudentPageData(totalStudents: $totalStudents, maleStudents: $maleStudents, femaleStudents: $femaleStudents, activeStudents: $activeStudents, students: $students)';
}


}

/// @nodoc
abstract mixin class $StudentPageDataCopyWith<$Res>  {
  factory $StudentPageDataCopyWith(StudentPageData value, $Res Function(StudentPageData) _then) = _$StudentPageDataCopyWithImpl;
@useResult
$Res call({
 int totalStudents, int maleStudents, int femaleStudents, int activeStudents, List<StudentTable>? students
});




}
/// @nodoc
class _$StudentPageDataCopyWithImpl<$Res>
    implements $StudentPageDataCopyWith<$Res> {
  _$StudentPageDataCopyWithImpl(this._self, this._then);

  final StudentPageData _self;
  final $Res Function(StudentPageData) _then;

/// Create a copy of StudentPageData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalStudents = null,Object? maleStudents = null,Object? femaleStudents = null,Object? activeStudents = null,Object? students = freezed,}) {
  return _then(_self.copyWith(
totalStudents: null == totalStudents ? _self.totalStudents : totalStudents // ignore: cast_nullable_to_non_nullable
as int,maleStudents: null == maleStudents ? _self.maleStudents : maleStudents // ignore: cast_nullable_to_non_nullable
as int,femaleStudents: null == femaleStudents ? _self.femaleStudents : femaleStudents // ignore: cast_nullable_to_non_nullable
as int,activeStudents: null == activeStudents ? _self.activeStudents : activeStudents // ignore: cast_nullable_to_non_nullable
as int,students: freezed == students ? _self.students : students // ignore: cast_nullable_to_non_nullable
as List<StudentTable>?,
  ));
}

}


/// Adds pattern-matching-related methods to [StudentPageData].
extension StudentPageDataPatterns on StudentPageData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StudentPageData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StudentPageData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StudentPageData value)  $default,){
final _that = this;
switch (_that) {
case _StudentPageData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StudentPageData value)?  $default,){
final _that = this;
switch (_that) {
case _StudentPageData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalStudents,  int maleStudents,  int femaleStudents,  int activeStudents,  List<StudentTable>? students)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StudentPageData() when $default != null:
return $default(_that.totalStudents,_that.maleStudents,_that.femaleStudents,_that.activeStudents,_that.students);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalStudents,  int maleStudents,  int femaleStudents,  int activeStudents,  List<StudentTable>? students)  $default,) {final _that = this;
switch (_that) {
case _StudentPageData():
return $default(_that.totalStudents,_that.maleStudents,_that.femaleStudents,_that.activeStudents,_that.students);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalStudents,  int maleStudents,  int femaleStudents,  int activeStudents,  List<StudentTable>? students)?  $default,) {final _that = this;
switch (_that) {
case _StudentPageData() when $default != null:
return $default(_that.totalStudents,_that.maleStudents,_that.femaleStudents,_that.activeStudents,_that.students);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StudentPageData implements StudentPageData {
  const _StudentPageData({required this.totalStudents, required this.maleStudents, required this.femaleStudents, required this.activeStudents, final  List<StudentTable>? students}): _students = students;
  factory _StudentPageData.fromJson(Map<String, dynamic> json) => _$StudentPageDataFromJson(json);

@override final  int totalStudents;
@override final  int maleStudents;
@override final  int femaleStudents;
@override final  int activeStudents;
 final  List<StudentTable>? _students;
@override List<StudentTable>? get students {
  final value = _students;
  if (value == null) return null;
  if (_students is EqualUnmodifiableListView) return _students;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of StudentPageData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StudentPageDataCopyWith<_StudentPageData> get copyWith => __$StudentPageDataCopyWithImpl<_StudentPageData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StudentPageDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StudentPageData&&(identical(other.totalStudents, totalStudents) || other.totalStudents == totalStudents)&&(identical(other.maleStudents, maleStudents) || other.maleStudents == maleStudents)&&(identical(other.femaleStudents, femaleStudents) || other.femaleStudents == femaleStudents)&&(identical(other.activeStudents, activeStudents) || other.activeStudents == activeStudents)&&const DeepCollectionEquality().equals(other._students, _students));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalStudents,maleStudents,femaleStudents,activeStudents,const DeepCollectionEquality().hash(_students));

@override
String toString() {
  return 'StudentPageData(totalStudents: $totalStudents, maleStudents: $maleStudents, femaleStudents: $femaleStudents, activeStudents: $activeStudents, students: $students)';
}


}

/// @nodoc
abstract mixin class _$StudentPageDataCopyWith<$Res> implements $StudentPageDataCopyWith<$Res> {
  factory _$StudentPageDataCopyWith(_StudentPageData value, $Res Function(_StudentPageData) _then) = __$StudentPageDataCopyWithImpl;
@override @useResult
$Res call({
 int totalStudents, int maleStudents, int femaleStudents, int activeStudents, List<StudentTable>? students
});




}
/// @nodoc
class __$StudentPageDataCopyWithImpl<$Res>
    implements _$StudentPageDataCopyWith<$Res> {
  __$StudentPageDataCopyWithImpl(this._self, this._then);

  final _StudentPageData _self;
  final $Res Function(_StudentPageData) _then;

/// Create a copy of StudentPageData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalStudents = null,Object? maleStudents = null,Object? femaleStudents = null,Object? activeStudents = null,Object? students = freezed,}) {
  return _then(_StudentPageData(
totalStudents: null == totalStudents ? _self.totalStudents : totalStudents // ignore: cast_nullable_to_non_nullable
as int,maleStudents: null == maleStudents ? _self.maleStudents : maleStudents // ignore: cast_nullable_to_non_nullable
as int,femaleStudents: null == femaleStudents ? _self.femaleStudents : femaleStudents // ignore: cast_nullable_to_non_nullable
as int,activeStudents: null == activeStudents ? _self.activeStudents : activeStudents // ignore: cast_nullable_to_non_nullable
as int,students: freezed == students ? _self._students : students // ignore: cast_nullable_to_non_nullable
as List<StudentTable>?,
  ));
}


}

// dart format on
