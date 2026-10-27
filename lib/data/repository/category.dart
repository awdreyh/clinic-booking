import '../../supabase_config.dart';
import '../model/category.dart';

class CategoryRepository {
  Future<List<Category>> fetchCategories() async {
    final rows = await supabase.from('category').select().order('name');
    return (rows as List)
        .map((row) => Category.fromJson(Map<String, dynamic>.from(row)))
        .toList();
  }

  Future<Category> createCategory({
    required String name,
    String? description,
    int? parentId,
  }) async {
    final row = await supabase.from('category').insert({
      'name': name,
      'description': description,
      'parent_id': parentId,
    }).select().single();
    return Category.fromJson(row);
  }

  Future<Category> updateCategory(Category category) async {
    final row = await supabase.from('category').update({
      'name': category.name,
      'description': category.description,
      'parent_id': category.parentId,
    }).eq('id', category.id).select().single();
    return Category.fromJson(row);
  }

  Future<void> deleteCategory(int id) async {
    await supabase.from('category').delete().eq('id', id);
  }
}
