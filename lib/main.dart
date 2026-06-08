import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:mobileframe/services/warframe_api.dart';
import 'package:mobileframe/services/hive_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  final box = await HiveService.openBox();
  final api = WarframeApi();

  runApp(WarframeMarketApp(api: api, box: box));
}