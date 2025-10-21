// filename: model/user.dart
import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  String username;

  @HiveField(1)
  String passwordHash;

  @HiveField(2)
  String role; // 'admin' or 'customer'

  User({
    required this.username,
    required this.passwordHash,
    required this.role,
  });
}
