import '../../domain/entities/user.dart';

class UserDto {
  final String id;
  final String name;
  final String email;
  final String phone;

  const UserDto({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) => UserDto(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String,
      );

  User toDomain() => User(id: id, name: name, email: email, phone: phone);
}
