class ItemFull {
  final String id;
  final String slug;
  final List<String> tags;
  final String? rarity;
  final int? maxRank;
  final int tradingTax;
  final bool tradable;
  final String name;
  final String? description;
  final String? icon;
  final String? thumb;
  final String? wikiLink;

  ItemFull({
    required this.id,
    required this.slug,
    required this.tags,
    this.rarity,
    this.maxRank,
    required this.tradingTax,
    required this.tradable,
    required this.name,
    this.description,
    this.icon,
    this.thumb,
    this.wikiLink,
  });

  factory ItemFull.fromJson(Map<String, dynamic> json) {
    final i18n = json['i18n'] as Map<String, dynamic>?;
    final en = i18n?['en'] as Map<String, dynamic>?;
    return ItemFull(
      id: json['id'] as String,
      slug: json['slug'] as String,
      tags: List<String>.from(json['tags'] as List),
      rarity: json['rarity'] as String?,
      maxRank: json['maxRank'] as int?,
      tradingTax: json['tradingTax'] as int? ?? 0,
      tradable: json['tradable'] as bool? ?? true,
      name: en?['name'] as String? ?? json['slug'] as String,
      description: en?['description'] as String?,
      icon: en?['icon'] as String?,
      thumb: en?['thumb'] as String?,
      wikiLink: en?['wikiLink'] as String?,
    );
  }
}