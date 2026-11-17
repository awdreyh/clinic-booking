import '../../supabase_config.dart';
import '../model/service_attribute.dart';

class ServiceAttributeRepository {
  Future<List<ServiceAttribute>> fetchAttributes(int serviceId) async {
    final rows = await supabase
        .from('service_attribute')
        .select()
        .eq('service_id', serviceId)
        .order('duration', nullsFirst: false)
        .order('sessions', nullsFirst: false);
    return (rows as List)
        .map((row) => ServiceAttribute.fromJson(
              Map<String, dynamic>.from(row),
            ))
        .toList();
  }

  Future<ServiceAttribute> createAttribute({
    required int serviceId,
    int? duration,
    int? sessions,
    required double price,
    double? membershipPrice,
  }) async {
    _validateTier(duration: duration, sessions: sessions);
    final row = await supabase.from('service_attribute').insert({
      'service_id': serviceId,
      'duration': duration,
      'sessions': sessions,
      'price': price,
      'membership_price': membershipPrice,
    }).select().single();
    return ServiceAttribute.fromJson(Map<String, dynamic>.from(row));
  }

  Future<ServiceAttribute> updateAttribute(ServiceAttribute attribute) async {
    _validateTier(duration: attribute.duration, sessions: attribute.sessions);
    final row = await supabase.from('service_attribute').update({
      'service_id': attribute.serviceId,
      'duration': attribute.duration,
      'sessions': attribute.sessions,
      'price': attribute.price,
      'membership_price': attribute.membershipPrice,
    }).eq('id', attribute.id).select().single();
    return ServiceAttribute.fromJson(Map<String, dynamic>.from(row));
  }

  Future<void> deleteAttribute(int id) async {
    await supabase.from('service_attribute').delete().eq('id', id);
  }

  void _validateTier({int? duration, int? sessions}) {
    if (duration != null && sessions != null) {
      throw ArgumentError('A service tier cannot have both duration and sessions.');
    }
  }
}
