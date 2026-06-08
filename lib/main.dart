import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:mobileframe/services/warframe_api.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  final api = WarframeApi();

  runApp(WarframeMarketApp(api: api));
}