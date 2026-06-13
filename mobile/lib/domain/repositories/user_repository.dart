import '../entities/user.dart';

abstract class UserRepository {
  Future<User> create({
    required String name,
    required String email,
    required String phone,
  });
}
