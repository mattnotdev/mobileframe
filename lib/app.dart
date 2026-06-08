import 'package:flutter/material.dart';
import 'services/warframe_api.dart';
import 'screens/recent_orders_screen.dart';

class WarframeMarketApp extends StatelessWidget {
  final WarframeApi api;

  const WarframeMarketApp({required this.api, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Warframe Market',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3699B4),
          brightness: Brightness.dark,
          dynamicSchemeVariant: DynamicSchemeVariant.tonalSpot,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF000000),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      home: RecentOrdersScreen(api: api),
    );
  }
}