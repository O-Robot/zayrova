class Category {
  const Category({
    required this.id,
    required this.name,
    this.slug,
    this.description,
    this.imageUrl,
    this.parentId,
    this.productCount,
    this.isFeatured = false,
  });

  final String id;
  final String name;
  final String? slug;
  final String? description;
  final String? imageUrl;
  final String? parentId;
  final int? productCount;
  final bool isFeatured;
}
