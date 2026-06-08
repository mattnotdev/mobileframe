import 'dart:convert';
import 'package:hive_ce/hive_ce.dart';

class HiveService {
  static Future<Box> openBox() => Hive.openBox('warframe_market');

  static void cacheItems(Box box, List<Map<String, dynamic>> items) {
    box.put('items', jsonEncode(items));
    box.put('items_cached_at', DateTime.now().toIso8601String());
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
}