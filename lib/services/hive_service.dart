import 'dart:convert';
import 'package:hive_ce/hive_ce.dart';

class HiveService {
  static Future<Box> openBox() => Hive.openBox('warframe_market');

  static void cacheItems(Box box, List<Map<String, dynamic>> items) {
    box.put('items', jsonEncode(items));
    box.put('items_cached_at', DateTime.now().toIso8601String());
  }

  static void cacheItemDetail(Box box, String slug, Map<String, dynamic> itemJson) {
    box.put('detail_$slug', jsonEncode({
      'data': itemJson,
      'cachedAt': DateTime.now().toIso8601String(),
    }));
  }

  // items database will attempt to recache every few hours
  // realistically this period could be longer bcs the game doesn't update often
  // but it doesnt hurt i suppose
  static List<Map<String, dynamic>>? getCachedItems(Box box, {Duration ttl = const Duration(hours: 12)}) {
    final raw = box.get('items');
    final cachedAtStr = box.get('items_cached_at');
    if (raw == null || cachedAtStr == null) return null;

    final cachedAt = DateTime.parse(cachedAtStr as String);
    if (DateTime.now().difference(cachedAt) > ttl) return null;

    final decoded = jsonDecode(raw as String);
    return (decoded as List).cast<Map<String, dynamic>>();
  }

  static Map<String, dynamic>? getCachedItemDetail(Box box, String slug, {Duration ttl = const Duration(hours: 12)}) {
    final raw = box.get('detail_$slug');
    if (raw == null) return null;

    final entry = jsonDecode(raw as String) as Map<String, dynamic>;
    final cachedAt = DateTime.parse(entry['cachedAt'] as String);
    if (DateTime.now().difference(cachedAt) > ttl) return null;
    return entry['data'] as Map<String, dynamic>;
  }

  static List<Map<String, dynamic>> getFollowedItems(Box box) {
    final raw = box.get('followed', defaultValue: '[]') as String;
    return (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
  }

  static void _setFollowedItems(Box box, List<Map<String, dynamic>> items) {
    box.put('followed', jsonEncode(items));
  }

  static bool toggleFollow(Box box, Map<String, dynamic> item) {
    final list = getFollowedItems(box);
    final idx = list.indexWhere((e) => e['id'] == item['id']);
    if (idx >= 0) {
      list.removeAt(idx);
      _setFollowedItems(box, list);
      return false;
    }
    list.add(item);
    _setFollowedItems(box, list);
    return true;
  }

  static bool isFollowed(Box box, String itemId) {
    return getFollowedItems(box).any((e) => e['id'] == itemId);
  }

}