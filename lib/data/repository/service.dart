import '../../supabase_config.dart';
import '../model/service.dart';

class ServiceRepository {
  Future<List<Service>> fetchServices({int? categoryId}) async {
    var query = supabase.from('service').select();
    if (categoryId != null) query = query.eq('category_id', categoryId);
    final rows = await query.order('name');
    return (rows as List)
        .map((row) => Service.fromJson(Map<String, dynamic>.from(row)))
        .toList();
  }

  Future<Service> createService({
    required String name,
    String? description,
    String? image,
    int? categoryId,
  }) async {
    final row = await supabase.from('service').insert({
      'name': name,
      'description': description,
      'image': image,
      'category_id': categoryId,
    }).select().single();
    return Service.fromJson(row);
  }

  Future<Service> updateService(Service service) async {
    final row = await supabase.from('service').update({
      'name': service.name,
      'description': service.description,
      'image': service.image,
      'category_id': service.categoryId,
    }).eq('id', service.id).select().single();
    return Service.fromJson(row);
  }

  Future<void> deleteService(int id) async {
    await supabase.from('service').delete().eq('id', id);
  }
}
