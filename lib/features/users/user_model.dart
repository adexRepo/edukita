import 'package:uuid/uuid.dart';

class User {
  User({
    String? id,
    required this.username,
    required this.password,
    required this.nickName,
    required this.fullName,
  }) : id = id ?? const Uuid().v4();

  final String id;
  final String username;
  final String password;
  final String nickName;
  final String fullName;

  User copyWith({
    String? id,
    String? username,
    String? password,
    String? nickName,
    String? fullName,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      nickName: nickName ?? this.nickName,
      fullName: fullName ?? this.fullName,
    );
  }

  factory User.fromMap(Map<String, Object?> map) {
    return User(
      id: map['id'] as String?,
      username: map['username'] as String,
      password: map['password'] as String,
      nickName: map['nick_name'] as String,
      fullName: map['full_name'] as String,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'nick_name': nickName,
      'full_name': fullName,
    };
  }

  factory User.sample() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return User(
      username: 'guest$timestamp',
      password: 'guest',
      nickName: 'Guest',
      fullName: 'Guest User',
    );
  }
}
