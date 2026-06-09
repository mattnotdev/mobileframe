import 'package:flutter/material.dart';
import 'package:hive_ce/hive_ce.dart';
import '../models/item.dart';
import '../services/hive_service.dart';
import '../services/warframe_api.dart';
import 'details_screen.dart';

class FollowedScreen extends StatefulWidget {
  final WarframeApi api;
  final Box box;

  const FollowedScreen({required this.api, required this.box, super.key});

  @override
  State<FollowedScreen> createState() => _FollowedScreenState();
}

class _FollowedScreenState extends State<FollowedScreen> {
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _items = HiveService.getFollowedItems(widget.box);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Followed Items'),
        centerTitle: true,
      ),
      body: _items.isEmpty
          ? Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star_border, size: 64, color: Colors.grey.shade600),
            const SizedBox(height: 16),
            Text(
              'No followed items yet',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Star an item from its detail page to track it here',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: () async => _refresh(),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          itemCount: _items.length,
          itemBuilder: (context, index) => _FollowedTile(
            data: _items[index],
            onTap: () async {
              final item = Item(
                id: _items[index]['id'] as String,
                slug: _items[index]['slug'] as String,
                tags: [],
                name: _items[index]['name'] as String,
                thumb: _items[index]['thumb'] as String?,
              );
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailScreen(
                    api: widget.api,
                    box: widget.box,
                    item: item,
                  ),
                ),
              );
              _refresh(); // refresh in case unfollowed from detail
            },
            onUnfollow: () {
              HiveService.toggleFollow(widget.box, _items[index]);
              _refresh();
            },
          ),
        ),
      ),
    );
  }
}

class _FollowedTile extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onTap;
  final VoidCallback onUnfollow;

  const _FollowedTile({
    required this.data,
    required this.onTap,
    required this.onUnfollow,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final thumb = data['thumb'] as String?;

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: thumb != null
                      ? Image.network(
                    WarframeApi.imageUrl(thumb),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.inventory),
                  )
                      : const Icon(Icons.inventory),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  data['name'] as String? ?? 'Unknown',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.star, color: Colors.amber),
                tooltip: 'Unfollow',
                onPressed: onUnfollow,
              ),
            ],
          ),
        ),
      ),
    );
  }
}