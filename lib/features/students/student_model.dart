import 'package:uuid/uuid.dart';

class Student {
  Student({
    String? id,
    required this.studentNo,
    required this.classId,
    this.nickName,
    required this.fullName,
    required this.joinAt,
    this.nis,
    this.birthDate,
    this.gender,
    this.mobileNo,
    this.emailAddr,
    this.shoeSize,
    this.uniformSize,
    this.pantsSize,
    this.height,
    this.weight,
    this.photoPath,
  }) : id = id ?? const Uuid().v4();

  final String id;
  final String studentNo;
  final String classId;
  final String? nickName;
  final String fullName;
  final String joinAt;
  final String? nis;
  final String? birthDate;
  final String? gender;
  final String? mobileNo;
  final String? emailAddr;
  final int? shoeSize;
  final int? uniformSize;
  final int? pantsSize;
  final double? height;
  final double? weight;
  final String? photoPath;

  Student copyWith({
    String? id,
    String? studentNo,
    String? classId,
    String? nickName,
    String? fullName,
    String? joinAt,
    String? nis,
    String? birthDate,
    String? gender,
    String? mobileNo,
    String? emailAddr,
    int? shoeSize,
    int? uniformSize,
    int? pantsSize,
    double? height,
    double? weight,
    String? photoPath,
  }) {
    return Student(
      id: id ?? this.id,
      studentNo: studentNo ?? this.studentNo,
      classId: classId ?? this.classId,
      nickName: nickName ?? this.nickName,
      fullName: fullName ?? this.fullName,
      joinAt: joinAt ?? this.joinAt,
      nis: nis ?? this.nis,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      mobileNo: mobileNo ?? this.mobileNo,
      emailAddr: emailAddr ?? this.emailAddr,
      shoeSize: shoeSize ?? this.shoeSize,
      uniformSize: uniformSize ?? this.uniformSize,
      pantsSize: pantsSize ?? this.pantsSize,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      photoPath: photoPath ?? this.photoPath,
    );
  }

  factory Student.fromMap(Map<String, Object?> map) {
    return Student(
      id: map['id']?.toString(),
      studentNo: map['student_no'] as String,
      classId: map['class_id'] as String,
      nickName: map['nick_name'] as String?,
      fullName: map['full_name'] as String,
      joinAt: map['join_at'] as String,
      nis: map['nis'] as String?,
      birthDate: map['birth_date'] as String?,
      gender: map['gender'] as String?,
      mobileNo: map['mobile_no'] as String?,
      emailAddr: map['email_addr'] as String?,
      shoeSize: map['shoe_size'] as int?,
      uniformSize: map['uniform_size'] as int?,
      pantsSize: map['pants_size'] as int?,
      height: map['height'] == null ? null : (map['height'] as num).toDouble(),
      weight: map['weight'] == null ? null : (map['weight'] as num).toDouble(),
      photoPath: map['photo_path'] as String?,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'student_no': studentNo,
      'class_id': classId,
      'nick_name': nickName,
      'full_name': fullName,
      'join_at': joinAt,
      'nis': nis,
      'birth_date': birthDate,
      'gender': gender,
      'mobile_no': mobileNo,
      'email_addr': emailAddr,
      'shoe_size': shoeSize,
      'uniform_size': uniformSize,
      'pants_size': pantsSize,
      'height': height,
      'weight': weight,
      'photo_path': photoPath,
    };
  }

  factory Student.sample({required String classId}) {
    return Student(
      studentNo: 'JKTM10001',
      classId: classId,
      nickName: 'Budi',
      fullName: 'Budi Santoso',
      joinAt: DateTime.now().toIso8601String(),
      nis: '123456789',
      birthDate: DateTime(2014, 6, 15).toIso8601String(),
      gender: 'M',
      mobileNo: '081234567890',
      emailAddr: 'budi@example.com',
      shoeSize: 37,
      uniformSize: 12,
      pantsSize: 12,
      height: 135.0,
      weight: 32.0,
      photoPath: null,
    );
  }
}
