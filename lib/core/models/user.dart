enum UserRole { resident, supervisor, boardDirector }
abstract class UserCredentials {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final String? phoneNumber;

  UserCredentials({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.profileImageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.phoneNumber,
  });

  // Abstract methods to be implemented by subclasses
  UserRole get role;
  Map<String, dynamic> toJson();

  // Common methods
  String get fullName => '$firstName $lastName';
  String get displayName => fullName;
}