import 'package:zayrova/data/models/model_parse_helpers.dart';
import 'package:zayrova/domain/entities/category_entity.dart';

class CategoryModel extends Category {
  const CategoryModel({
    required super.id,
    required super.name,
    super.slug,
    super.description,
    super.imageUrl,
    super.parentId,
    super.productCount,
    super.isFeatured,
  });

  factory CategoryModel.fromJson(dynamic json) {
    // DummyJSON may return category strings or category objects.
    if (json is String) {
      return CategoryModel(id: json, name: _humanize(json), slug: json);
    }

    final map = json is Map<String, dynamic> ? json : <String, dynamic>{};
    final slug = nullableString(map['slug'] ?? map['id']);
    final name = nullableString(map['name']) ?? _humanize(slug ?? 'category');

    return CategoryModel(
      id: stringValue(map['id'] ?? slug, name),
      name: name,
      slug: slug,
      description: nullableString(map['description']),
      imageUrl: nullableString(map['imageUrl'] ?? map['url']),
      parentId: nullableString(map['parentId']),
      productCount: map.containsKey('productCount')
          ? intValue(map['productCount'])
          : null,
      isFeatured: boolValue(map['isFeatured']),
    );
  }

  Category toEntity() => this;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'imageUrl': imageUrl,
      'parentId': parentId,
      'productCount': productCount,
      'isFeatured': isFeatured,
    };
  }

  static String _humanize(String value) {
    return value
        .split('-')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }
}
