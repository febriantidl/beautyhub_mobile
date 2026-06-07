// ═══════════════════════════════════════════════════════════════════
// user_model.dart
// Field mengikuti PERSIS response GET /api/me dan POST /api/login
// ═══════════════════════════════════════════════════════════════════

class UserModel {
  final int     id;
  final String  name;
  final String  email;
  final String  role;       // 'customer' atau 'mua'
  final String? phone;
  final String? avatar;
  final String? address;
  final String? gender;
  final bool    isActive;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.avatar,
    this.address,
    this.gender,
    required this.isActive,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id       : json['id'],
      name     : json['name'],
      email    : json['email'],
      role     : json['role'] ?? 'customer',
      phone    : json['phone'],
      avatar   : json['avatar'],
      address  : json['address'],
      gender   : json['gender'],
      isActive : json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id'       : id,
    'name'     : name,
    'email'    : email,
    'role'     : role,
    'phone'    : phone,
    'avatar'   : avatar,
    'address'  : address,
    'gender'   : gender,
    'is_active': isActive,
  };
}