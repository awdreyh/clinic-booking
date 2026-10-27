class User {
  const User({
    required this.id,
    required this.name,
    required this.role,
    required this.email,
    required this.phone,
    this.description,
    this.isActive = true,
    this.isMember = false,
    this.lastLogin,
    this.updatedAt,
    this.memberSince,
    this.membershipExpires,
    this.profilePicture,
    this.meta,
    this.address,
    this.createdAt,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final String? description;
  final bool isActive;
  final bool isMember;
  final DateTime? lastLogin;
  final DateTime? updatedAt;
  final DateTime? memberSince;
  final DateTime? membershipExpires;
  final String? profilePicture;
  final Map<String, dynamic>? meta;
  final String? address;
  final String role;
  final DateTime? createdAt;

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String,
        description: json['description'] as String?,
        isActive: json['is_active'] as bool? ?? true,
        isMember: json['is_member'] as bool? ?? false,
        lastLogin: _dateTime(json['last_login']),
        updatedAt: _dateTime(json['updated_at']),
        memberSince: _dateTime(json['member_since']),
        membershipExpires: _dateTime(json['membership_expires']),
        profilePicture: json['profile_picture'] as String?,
        meta: (json['meta'] as Map?)?.cast<String, dynamic>(),
        address: json['address'] as String?,
        role: json['role'] as String? ?? 'customer',
        createdAt: _dateTime(json['created_at']),
      );

  static DateTime? _dateTime(Object? value) =>
      value == null ? null : DateTime.parse(value.toString());
}
