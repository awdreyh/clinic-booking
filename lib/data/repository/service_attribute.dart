import '../../supabase_config.dart';
import '../model/service_attribute.dart';

class ServiceAttributeRepository {
  Future<List<ServiceAttribute>> fetchAttributes(int serviceId) async {
    final rows = await supabase
        .from('service_attribute')
        .select()
        .eq('service_id', serviceId)
        .order('attribute_key');
    return (rows as List)
        .map((row) =>
            ServiceAttribute.fromJson(Map<String, dynamic>.from(row)))
        .toList();
  }

  Future<ServiceAttribute> createAttribute({
    required int serviceId,
    required String key,
    required String value,
  }) async {
    final row = await supabase.from('service_attribute').insert({
      'service_id': serviceId,
      'attribute_key': key,
      'attribute_value': value,
    }).select().single();
    return ServiceAttribute.fromJson(row);
  }

  Future<ServiceAttribute> updateAttribute(ServiceAttribute attribute) async {
    final row = await supabase.from('service_attribute').update({
      'service_id': attribute.serviceId,
      'attribute_key': attribute.attributeKey,
      'attribute_value': attribute.attributeValue,
    }).eq('id', attribute.id).select().single();
    return ServiceAttribute.fromJson(row);
  }

  Future<void> deleteAttribute(int id) async {
    await supabase.from('service_attribute').delete().eq('id', id);
  }
}
