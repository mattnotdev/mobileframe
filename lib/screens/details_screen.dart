import 'package:flutter/material.dart';
import 'package:hive_ce/hive_ce.dart';
import '../models/item.dart';
import '../models/item_full.dart';
import '../models/order.dart';
import '../services/warframe_api.dart';
import '../widgets/status_dot.dart';

class DetailScreen extends StatefulWidget {
  final WarframeApi api;
  final Box box;
  final Item item; // lightweight item from search/recent list

  const DetailScreen({
    required this.api,
    required this.box,
    required this.item,
    super.key,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  ItemFull? _detail;
  List<Order> _orders = [];
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
      final results = await Future.wait([
        widget.api.getItemDetail(widget.item.slug),
        widget.api.getItemOrders(widget.item.id),
      ]);
      if (!mounted) return;
      setState(() {
        _detail = results[0] as ItemFull;
        _orders = results[1] as List<Order>;
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
        title: Text(widget.item.name),
        actions: [
          IconButton(
            onPressed: () {
              debugPrint('attempting to follow item ${widget.item.name}');
            },
            icon: Icon(Icons.star),
          ),
        ],
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
    return _DetailContent(
      detail: _detail!,
      orders: _orders,
      api: widget.api,
    );
  }
}

class _DetailContent extends StatefulWidget {
  final ItemFull detail;
  final List<Order> orders;
  final WarframeApi api;

  const _DetailContent({
    required this.detail,
    required this.orders,
    required this.api,
  });

  @override
  State<_DetailContent> createState() => _DetailContentState();
}

class _DetailContentState extends State<_DetailContent> {
  bool _showSellers = true;

  List<Order> get _filteredOrders {
    final type = _showSellers ? 'sell' : 'buy';
    return widget.orders
        .where((o) => o.type == type && o.visible)
        .toList()
      ..sort((a, b) => a.platinum.compareTo(b.platinum));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final d = widget.detail;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(0),
              child: SizedBox(
                width: 80,
                height: 80,
                child: d.icon != null
                    ? Image.network(
                  WarframeApi.imageUrl(d.icon!),
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const Icon(Icons.inventory, size: 48),
                )
                    : const Icon(Icons.inventory, size: 48),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    d.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      if (d.rarity != null)
                        _TagChip(
                          label: d.rarity!,
                          color: _rarityColor(d.rarity!)
                        ),
                      ...d.tags.map(
                        (t) => _TagChip(
                          label: t,
                          color: Colors.grey.shade700
                        )
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            if (d.maxRank != null) ...[
              _InfoChip(icon: Icons.stars, label: 'Max rank ${d.maxRank}'),
              const SizedBox(width: 12),
            ],
          ],
        ),
        if (d.description != null && d.description!.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(d.description!, style: theme.textTheme.bodyMedium),
        ],
        const SizedBox(height: 24),

        Row(
          children: [
            Expanded(
              child: _ToggleTab(
                label: 'Sell (${widget.orders.where((o) => o.type == 'sell' && o.visible).length})',
                selected: _showSellers,
                onTap: () => setState(() => _showSellers = true),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ToggleTab(
                label: 'Buy (${widget.orders.where((o) => o.type == 'buy' && o.visible).length})',
                selected: !_showSellers,
                onTap: () => setState(() => _showSellers = false),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (_filteredOrders.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text(
                'No ${_showSellers ? 'sell' : 'buy'} orders available',
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
            ),
          )
        else
          ...(_filteredOrders.length > 100
              ? _filteredOrders.sublist(0, 100)
              : _filteredOrders
          ).map((o) => _OrderRow(order: o)),
      ],
    );
  }

  Color _rarityColor(String rarity) {
    switch (rarity) {
      case 'common': return Colors.grey;
      case 'uncommon': return Colors.green;
      case 'rare': return Colors.amber;
      case 'legendary': return Colors.deepOrange;
      case 'peculiar': return Colors.purple;
      default: return Colors.grey;
    }
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final Color color;
  const _TagChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: TextStyle(fontSize: 12, color: color)),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      ],
    );
  }
}

class _ToggleTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleTab({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primary.withValues(alpha: 0.15)
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: selected ? theme.colorScheme.primary : Colors.transparent,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              color: selected ? theme.colorScheme.primary : null,
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderRow extends StatelessWidget {
  final Order order;

  const _OrderRow({required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            ClipRRect(
              child: SizedBox(
                width: 32,
                height: 32,
                child: order.user.avatar != null
                    ? Image.network(
                  WarframeApi.imageUrl(order.user.avatar!),
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const Icon(Icons.person, size: 20),
                )
                    : const Icon(Icons.person, size: 20),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(order.user.ingameName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    children: [
                      StatusDot(status: order.user.status),
                      if (order.rank != null && order.rank! > 0) ...[
                        const SizedBox(width: 8),
                        Text('Rank ${order.rank}',
                          style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Price + quantity
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${order.platinum}p',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: order.type == 'sell' ? Colors.greenAccent : Colors.redAccent,
                  ),
                ),
                if (order.quantity > 1)
                  Text('x${order.quantity}',
                    style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}