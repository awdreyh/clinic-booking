import '../../supabase_config.dart';
import '../model/service.dart';
import '../model/user.dart';

/// Queries therapist accounts from `public.user`; a therapist is a User whose
/// role is `therapist`.
class TherapistRepository {
  Future<List<User>> fetchTherapists() async {
    final rows = await supabase
        .from('user')
        .select()
        .eq('role', 'therapist')
        .eq('is_active', true)
        .order('name');
    return (rows as List)
        .map((row) => User.fromJson(Map<String, dynamic>.from(row)))
        .toList();
  }

  Future<Map<String, List<Service>>> fetchServicesByTherapist(
    List<String> therapistIds,
  ) async {
    if (therapistIds.isEmpty) return {};
    final rows = await supabase
        .from('service_therapist')
        .select('therapist_id, service(*)')
        .inFilter('therapist_id', therapistIds);

    final servicesByTherapist = <String, List<Service>>{};
    for (final rawRow in rows as List) {
      final row = Map<String, dynamic>.from(rawRow);
      final therapistId = row['therapist_id'] as String?;
      final rawService = row['service'];
      if (therapistId == null || rawService is! Map) continue;
      servicesByTherapist.putIfAbsent(therapistId, () => []).add(
            Service.fromJson(Map<String, dynamic>.from(rawService)),
          );
    }
    return servicesByTherapist;
  }
}
