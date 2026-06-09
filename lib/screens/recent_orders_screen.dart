import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:mobileframe/services/hive_service.dart';
import '../models/item.dart';
import '../models/order.dart';
import 'details_screen.dart';
import '../widgets/status_dot.dart';
import '../services/warframe_api.dart';

class RecentOrdersScreen extends StatefulWidget {
  final WarframeApi api;
  final Box box;

  const RecentOrdersScreen({required this.api, required this.box, super.key});

  @override
  State<RecentOrdersScreen> createState() => _RecentOrdersScreenState();
}

// recent orders page
class _RecentOrdersScreenState extends State<RecentOrdersScreen> {
  List<Order>? _orders;
  Map<String, Item> _itemMap = {};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      // no reason to cache recent items; wouldnt be recent would it
      final orders = await widget.api.getRecentOrders();
      List<Item> items;

      final cached = HiveService.getCachedItems(widget.box);
      if (cached != null) {
        items = cached.map((j) => Item.fromJson(j)).toList();
      } else {
        items = await widget.api.getAllItems();
        HiveService.cacheItems(
          widget.box,
          items.map((i) => i.toJson()).toList()
        );
      }

      final map = <String, Item>{};
      for (final item in items) {
        map[item.id] = item;
      }

      if (!mounted) return;
      setState(() {
        _orders = orders;
        _itemMap = map;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recent Orders'),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.redAccent)),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    final orders = _orders!;
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          final item = _itemMap[order.itemId];
          return _OrderCard(
            order: order,
            item: item,
            onTap: item != null
                ? () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DetailScreen(
                  api: widget.api,
                  box: widget.box,
                  item: item,
                ),
              ),
            )
                : null,
          );
        },
      ),
    );
  }
}

// cards for specific orders
class _OrderCard extends StatelessWidget {
  final Order order;
  final Item? item;
  final VoidCallback? onTap;

  const _OrderCard({required this.order, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSell = order.type == 'sell';
    final chipColor = isSell ? Colors.green : Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: item?.thumb != null
                      ? Image.network(
                    WarframeApi.imageUrl(item!.thumb!),
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const Icon(Icons.inventory),
                  )
                      : const Icon(Icons.inventory),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item?.name ?? 'Unknown Item',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          isSell ? 'WTS' : 'WTB',
                          style: TextStyle(
                            color: chipColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${order.platinum}p',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        if (order.quantity > 1) ...[
                          const SizedBox(width: 8),
                          Text(
                            'x${order.quantity}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    order.user.ingameName,
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  StatusDot(status: order.user.status),
                ],
              ),
            ],
          ),
        ),
      )
    );
  }
}

// moved to separate widget

// class _StatusDot extends StatelessWidget {}