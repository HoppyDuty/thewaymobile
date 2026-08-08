/// Mirrors the `user` object returned by `/auth/*/verify`, `/auth/google/callback`,
/// and `/auth/me` (see `phase_1_api_doc.md`). Hand-written `fromJson`/`toJson`
/// (see the project plan for why: `json_serializable` and `riverpod_generator`
/// can't currently resolve together in this dependency graph).
class UserModel {
  const UserModel({
    required this.id,
    required this.uuid,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.username,
    required this.email,
    this.phone,
    this.avatarUrl,
    this.referralCode,
    required this.status,
    required this.role,
    required this.isVerified,
    this.lastLoginAt,
    required this.createdAt,
  });

  final int id;
  final String uuid;
  final String firstName;
  final String lastName;
  final String fullName;
  final String username;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final String? referralCode;
  final String status;
  final String role;
  final bool isVerified;
  final DateTime? lastLoginAt;
  final DateTime createdAt;

  bool get isAdmin => role == 'admin' || role == 'super_admin';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      uuid: json['uuid'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      fullName: json['full_name'] as String? ?? '${json['first_name']} ${json['last_name']}',
      username: json['username'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      referralCode: json['referral_code'] as String?,
      status: json['status'] as String? ?? 'active',
      role: json['role'] as String? ?? 'student',
      isVerified: json['is_verified'] as bool? ?? false,
      lastLoginAt: json['last_login_at'] != null ? DateTime.tryParse(json['last_login_at'] as String) : null,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'first_name': firstName,
        'last_name': lastName,
        'full_name': fullName,
        'username': username,
        'email': email,
        'phone': phone,
        'avatar_url': avatarUrl,
        'referral_code': referralCode,
        'status': status,
        'role': role,
        'is_verified': isVerified,
        'last_login_at': lastLoginAt?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
      };

  UserModel copyWith({
    String? firstName,
    String? lastName,
    String? fullName,
    String? phone,
    String? avatarUrl,
  }) {
    return UserModel(
      id: id,
      uuid: uuid,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      fullName: fullName ?? this.fullName,
      username: username,
      email: email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      referralCode: referralCode,
      status: status,
      role: role,
      isVerified: isVerified,
      lastLoginAt: lastLoginAt,
      createdAt: createdAt,
    );
  }
}
