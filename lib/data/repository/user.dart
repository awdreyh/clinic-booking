import '../../supabase_config.dart';
import '../model/user.dart';

class UserRepository {
  Future<User?> fetchUser(String id) async {
    final row = await supabase
        .from('user')
        .select()
        .eq('id', id)
        .maybeSingle();
    return row == null ? null : User.fromJson(row);
  }

  Future<List<User>> fetchUsers({String? role}) async {
    var query = supabase.from('user').select();
    if (role != null) query = query.eq('role', role);
    final rows = await query.order('name');
    return (rows as List)
        .map((row) => User.fromJson(Map<String, dynamic>.from(row)))
        .toList();
  }

  Future<User> updateUser(User user) async {
    final row = await supabase.from('user').update({
      'name': user.name,
      'email': user.email,
      'phone': user.phone,
      'description': user.description,
      'is_active': user.isActive,
      'is_member': user.isMember,
      'last_login': user.lastLogin?.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'member_since': user.memberSince?.toIso8601String(),
      'membership_expires': user.membershipExpires?.toIso8601String(),
      'profile_picture': user.profilePicture,
      'meta': user.meta,
      'address': user.address,
      'role': user.role,
    }).eq('id', user.id).select().single();
    return User.fromJson(row);
  }
}
