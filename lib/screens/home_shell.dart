import 'package:flutter/material.dart';
import 'package:hive_ce/hive_ce.dart';
import '../services/warframe_api.dart';
import 'recent_orders_screen.dart';
import 'search_screen.dart';
import 'followed_screen.dart';

class HomeShell extends StatefulWidget {
  final WarframeApi api;
  final Box box;

  const HomeShell({required this.api, required this.box, super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _page = 0;
  int _followedVisits = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _page,
        children: [
          RecentOrdersScreen(api: widget.api, box: widget.box),
          SearchScreen(api: widget.api, box: widget.box),
          FollowedScreen(
            api: widget.api,
            box: widget.box,
            key: ValueKey('followed_$_followedVisits')
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _page,
        onDestinationSelected: (i) {
          if (i == 2) _followedVisits++;
          setState(() => _page = i);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.history),
            selectedIcon: Icon(Icons.history),
            label: 'Recent',
          ),
          NavigationDestination(
            icon: Icon(Icons.search),
            selectedIcon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.star),
            label: 'Followed')
        ],
      ),
    );
  }
}