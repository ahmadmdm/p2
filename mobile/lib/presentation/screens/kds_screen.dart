import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/kitchen/kitchen_controller.dart';
import '../../../domain/entities/order.dart';
import '../../../domain/entities/order_item.dart';
import '../../../domain/entities/order_status.dart';

class KdsScreen extends ConsumerStatefulWidget {
  const KdsScreen({super.key});

  @override
  ConsumerState<KdsScreen> createState() => _KdsScreenState();
}

class _KdsScreenState extends ConsumerState<KdsScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedStationId;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stationsAsync = ref.watch(stationsProvider);
    final ordersAsync =
        ref.watch(kitchenControllerProvider(_selectedStationId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kitchen Display System'),
        actions: [
          stationsAsync.when(
            data: (stations) => DropdownButton<String>(
              value: _selectedStationId,
              hint: const Text('All Stations',
                  style: TextStyle(color: Colors.white)),
              dropdownColor: Theme.of(context).primaryColor,
              iconEnabledColor: Colors.white,
              underline: Container(),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('All Stations'),
                ),
                ...stations.map((s) => DropdownMenuItem<String>(
                      value: s['id'],
                      child: Text(s['name']),
                    )),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedStationId = value;
                });
              },
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const Icon(Icons.error),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref
                .read(kitchenControllerProvider(_selectedStationId).notifier)
                .refresh(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'PENDING'),
            Tab(text: 'PREPARING'),
            Tab(text: 'READY'),
          ],
        ),
      ),
      body: ordersAsync.when(
        data: (orders) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildOrderList(orders, OrderStatus.PENDING),
              _buildOrderList(orders, OrderStatus.PREPARING),
              _buildOrderList(orders, OrderStatus.READY),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildOrderList(List<Order> orders, OrderStatus status) {
    // Filter orders that have items in this status OR are in this status overall
    // Actually, KDS usually shows orders in their "most relevant" column.
    // Let's filter by Order Status for the column, but inside show items.

    final filteredOrders = orders.where((o) => o.status == status).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: filteredOrders.length,
      itemBuilder: (context, index) {
        final order = filteredOrders[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Table: ${order.tableNumber ?? 'N/A'}',
                        style: Theme.of(context).textTheme.titleLarge),
                    Text(
                        '#${order.id.length > 4 ? order.id.substring(0, 4) : order.id}'),
                  ],
                ),
                const Divider(),
                ...order.items.map((item) => _buildOrderItem(item)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildTimeAgo(order.createdAt),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    String timeStr = '';
    if (diff.inMinutes < 1) {
      timeStr = 'Just now';
    } else if (diff.inMinutes < 60) {
      timeStr = '${diff.inMinutes}m ago';
    } else {
      timeStr = '${diff.inHours}h ago';
    }
    return Text(timeStr, style: const TextStyle(color: Colors.grey));
  }

  Widget _buildOrderItem(OrderItem item) {
    // Check if this item belongs to selected station
    // If _selectedStationId is set, and item.product.stationId != _selectedStationId, maybe dim it or hide it?
    // Current OrderItem entity in Mobile might not have nested Product->Station loaded.
    // Let's assume we show all for now.

    Color statusColor = Colors.grey;
    if (item.status == 'PENDING') statusColor = Colors.orange;
    if (item.status == 'PREPARING') statusColor = Colors.blue;
    if (item.status == 'READY') statusColor = Colors.green;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${item.quantity}x ${item.product.nameEn}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          InkWell(
            onTap: () {
              _advanceItemStatus(item);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                item.status ?? 'PENDING',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _advanceItemStatus(OrderItem item) {
    String nextStatus = 'PENDING';
    if (item.status == 'PENDING') {
      nextStatus = 'PREPARING';
    } else if (item.status == 'PREPARING')
      nextStatus = 'READY';
    else if (item.status == 'READY')
      nextStatus = 'SERVED';
    else
      return; // Already served

    ref
        .read(kitchenControllerProvider(_selectedStationId).notifier)
        .updateItemStatus(item.id, nextStatus);
  }
}
