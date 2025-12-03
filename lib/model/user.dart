import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  String username;

  @HiveField(1)
  String passwordHash;

  @HiveField(2)
  String role; 

  // New Fields
  @HiveField(3)
  String email;

  @HiveField(4)
  String phone;

  @HiveField(5)
  String age; 

  @HiveField(6)
  String location;

  User({
    required this.username,
    required this.passwordHash,
    required this.role,
    this.email = '',
    this.phone = '',
    this.age = '',
    this.location = '',
  });
}