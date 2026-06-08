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
    // cached items render weird otherwise; i dont like null handling
    final name = json['name'] as String? ??
        ((json['i18n'] as Map<String, dynamic>?)?['en']
        as Map<String, dynamic>?)?['name'] as String? ??
        json['slug'] as String;
    final thumb = json['thumb'] as String? ??
        ((json['i18n'] as Map<String, dynamic>?)?['en']
        as Map<String, dynamic>?)?['thumb'] as String?;

    return Item(
      id: json['id'] as String,
      slug: json['slug'] as String,
      tags: List<String>.from(json['tags'] as List),
      name: name,
      thumb: thumb,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'slug': slug,
    'tags': tags,
    'name': name,
    'thumb': thumb,
  };
}