// item info, mostly game stuff
class Item {
  final String id;
  final String slug;
  final List<String> tags;
  final String name;
  final String? thumb;

  Item({
    required this.id,
    required this.slug,
    required this.tags,
    required this.name,
    this.thumb,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    final i18n = json['i18n'] as Map<String, dynamic>?; // which lang
    final en = i18n?['en'] as Map<String, dynamic>?; // only english interests us
    return Item(
      id: json['id'] as String,
      slug: json['slug'] as String,
      tags: List<String>.from(json['tags'] as List),
      name: en?['name'] as String? ?? json['slug'] as String,
      thumb: en?['thumb'] as String?,
    );
  }
}