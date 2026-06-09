import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import '../models/item.dart';
import '../models/item_full.dart';
import '../models/order.dart';

// most, if not all api calls will happen here
class WarframeApi {
  static const _base = 'https://api.warframe.market/v2';
  static const _imageBase = 'https://warframe.market/static/assets/';

  final String language;
  final String platform;

  WarframeApi({this.language = 'en', this.platform = 'pc'});

  Map<String, String> get _headers => {
    'Language': language,
    'Platform': platform,
    'Accept': 'application/json',
  };

  static String imageUrl(String path) => '$_imageBase$path';

  // fetches a list of all recent orders
  Future<List<Order>> getRecentOrders() async {
    final res = await http.get(
      Uri.parse('$_base/orders/recent'),
      headers: _headers,
    ).timeout(const Duration(seconds:8));
    _checkError(res);
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final data = body['data'] as List;
    return data.map((j) => Order.fromJson(j)).toList();
  }

  // fetches all info about items in game - even untradable ones
  // realistically should probably filter them out but eeeeeeeeeeeh
  Future<List<Item>> getAllItems() async {
    final res = await http.get(
      Uri.parse('$_base/items'),
      headers: _headers,
    ).timeout(const Duration(seconds:8));
    _checkError(res);
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final data = body['data'] as List;
    return data.map((j) => Item.fromJson(j)).toList();
  }

  // detailed info about a specific item
  Future<ItemFull> getItemDetail(String slug) async {
    final res = await http.get(
      Uri.parse('$_base/items/$slug'),
      headers: _headers,
    ).timeout(const Duration(seconds:8));
    _checkError(res);
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return ItemFull.fromJson(body['data'] as Map<String, dynamic>);
  }

  // how many and what orders have been placed on an item
  Future<List<Order>> getItemOrders(String itemId) async {
    final res = await http.get(
      Uri.parse('$_base/orders/item/$itemId'),
      headers: _headers,
    ).timeout(const Duration(seconds:8));
    _checkError(res);
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final data = body['data'] as List;
    return data.map((j) => Order.fromJson(j)).toList();
  }

  // throw errors when stuff goes bad
  void _checkError(http.Response res) {
    if (res.statusCode != 200) {
      throw ApiException(res.statusCode, res.body);
    }
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (body['error'] != null) {
      throw ApiException(res.statusCode, body['error'] as String);
    }
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);
  @override
  String toString() => 'API $statusCode: $message';
}