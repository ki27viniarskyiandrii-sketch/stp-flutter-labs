/// Профіль користувача з GET /users/{id}.
class UserProfile {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? image;
  final String? city;
  final String? companyTitle;

  const UserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.image,
    this.city,
    this.companyTitle,
  });

  String get fullName => '$firstName $lastName';

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final address = json['address'] as Map<String, dynamic>?;
    final company = json['company'] as Map<String, dynamic>?;
    return UserProfile(
      id: json['id'] as int,
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      image: json['image'] as String?,
      city: address?['city'] as String?,
      companyTitle: company?['title'] as String?,
    );
  }
}
