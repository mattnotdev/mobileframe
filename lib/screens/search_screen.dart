import 'package:flutter/material.dart';
import 'package:hive_ce/hive_ce.dart';
import '../models/item.dart';
import '../services/hive_service.dart';
import '../services/warframe_api.dart';
import 'details_screen.dart';

// search screen which searches the local database for hits
// not many details are contained on the screen here, because we're
// just using the 'generic' item values
class SearchScreen extends StatefulWidget {
  final WarframeApi api;
  final Box box;

  const SearchScreen({required this.api, required this.box, super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Item> _allItems = [];
  List<Item> _filteredItems = [];
  final _searchCtrl = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
    _searchCtrl.addListener(_filter);
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_filter);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _loadItems() async {
    final cached = HiveService.getCachedItems(widget.box);
    if (cached != null) {
      setState(() {
        _allItems = cached.map((j) => Item.fromJson(j)).toList();
        _filteredItems = _allItems;
        _loading = false;
      });
      return;
    }
    try {
      final items = await widget.api.getAllItems();
      HiveService.cacheItems(
        widget.box,
        items.map((i) => i.toJson()).toList(),
      );
      setState(() {
        _allItems = items;
        _filteredItems = items;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  void _filter() {
    final query = _searchCtrl.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredItems = _allItems;
      } else {
        _filteredItems = _allItems
          .where((i) => i.name.toLowerCase().contains(query))
          .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search items...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchCtrl.text.isNotEmpty
                  ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchCtrl.clear();
                },
                )
                  : null,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(child: _buildResults()),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_filteredItems.isEmpty) {
      return Center(
        child: Text(
          _searchCtrl.text.isEmpty
            ? 'Start typing to search'
            : 'No items match "${_searchCtrl.text}"',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.grey,
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) => _SearchResultTile(
        item: _filteredItems[index],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailScreen(
              api: widget.api,
              box: widget.box,
              item: _filteredItems[index],
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  final Item item;
  final VoidCallback? onTap;

  const _SearchResultTile({required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: item.thumb != null
                      ? Image.network(
                    WarframeApi.imageUrl(item.thumb!),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.inventory),
                  )
                      : const Icon(Icons.inventory),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (item.tags.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.tags.first,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}