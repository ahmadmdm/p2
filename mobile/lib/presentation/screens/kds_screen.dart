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

  String _stationIdOf(dynamic station) {
    if (station is Map<String, dynamic>) return station['id']?.toString() ?? '';
    if (station is Map) return station['id']?.toString() ?? '';
    try {
      return (station.id as Object?)?.toString() ?? '';
    } catch (_) {
      return '';
    }
  }

  String _stationNameOf(dynamic station) {
    if (station is Map<String, dynamic>) {
      return station['name']?.toString() ?? 'Unknown';
    }
    if (station is Map) return station['name']?.toString() ?? 'Unknown';
    try {
      return (station.name as Object?)?.toString() ?? 'Unknown';
    } catch (_) {
      return 'Unknown';
    }
  }

  String _orderIdOf(dynamic order) {
    if (order is Order) return order.id;
    if (order is Map<String, dynamic>) return order['id']?.toString() ?? '';
    if (order is Map) return order['id']?.toString() ?? '';
    return '';
  }

  String? _orderTableOf(dynamic order) {
    if (order is Order) return order.tableNumber;
    if (order is Map<String, dynamic>) {
      final table = order['table'];
      if (table is Map<String, dynamic>)
        return table['tableNumber']?.toString();
      return order['tableNumber']?.toString();
    }
    if (order is Map) {
      final table = order['table'];
      if (table is Map) return table['tableNumber']?.toString();
      return order['tableNumber']?.toString();
    }
    return null;
  }

  DateTime _orderCreatedAtOf(dynamic order) {
    if (order is Order) return order.createdAt;
    if (order is Map<String, dynamic>) {
      final raw = order['createdAt']?.toString();
      if (raw != null) return DateTime.tryParse(raw) ?? DateTime.now();
    }
    if (order is Map) {
      final raw = order['createdAt']?.toString();
      if (raw != null) return DateTime.tryParse(raw) ?? DateTime.now();
    }
    return DateTime.now();
  }

  List<dynamic> _orderItemsOf(dynamic order) {
    if (order is Order) return order.items;
    if (order is Map<String, dynamic>)
      return (order['items'] as List?) ?? const [];
    if (order is Map) return (order['items'] as List?) ?? const [];
    return const [];
  }

  OrderStatus _orderStatusOf(dynamic order) {
    if (order is Order) return order.status;
    if (order is Map<String, dynamic>) {
      final raw = order['status']?.toString() ?? '';
      return OrderStatus.values.firstWhere(
        (e) => e.name == raw,
        orElse: () => OrderStatus.PENDING,
      );
    }
    if (order is Map) {
      final raw = order['status']?.toString() ?? '';
      return OrderStatus.values.firstWhere(
        (e) => e.name == raw,
        orElse: () => OrderStatus.PENDING,
      );
    }
    return OrderStatus.PENDING;
  }

  String _itemIdOf(dynamic item) {
    if (item is OrderItem) return item.id;
    if (item is Map<String, dynamic>) return item['id']?.toString() ?? '';
    if (item is Map) return item['id']?.toString() ?? '';
    return '';
  }

  String _itemStatusOf(dynamic item) {
    if (item is OrderItem) return item.status ?? 'PENDING';
    if (item is Map<String, dynamic>)
      return item['status']?.toString() ?? 'PENDING';
    if (item is Map) return item['status']?.toString() ?? 'PENDING';
    return 'PENDING';
  }

  int _itemQtyOf(dynamic item) {
    if (item is OrderItem) return item.quantity;
    if (item is Map<String, dynamic>)
      return (item['quantity'] as num?)?.toInt() ?? 1;
    if (item is Map) return (item['quantity'] as num?)?.toInt() ?? 1;
    return 1;
  }

  String _itemNameOf(dynamic item) {
    if (item is OrderItem) return item.product.nameEn;
    if (item is Map<String, dynamic>) {
      final product = item['product'];
      if (product is Map<String, dynamic>) {
        final name = product['name'];
        if (name is Map<String, dynamic>)
          return name['en']?.toString() ?? 'Item';
      }
    }
    if (item is Map) {
      final product = item['product'];
      if (product is Map) {
        final name = product['name'];
        if (name is Map) return name['en']?.toString() ?? 'Item';
      }
    }
    return 'Item';
  }

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
                      value: _stationIdOf(s),
                      child: Text(_stationNameOf(s)),
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

  Widget _buildOrderList(List<dynamic> orders, OrderStatus status) {
    // Filter orders that have items in this status OR are in this status overall
    // Actually, KDS usually shows orders in their "most relevant" column.
    // Let's filter by Order Status for the column, but inside show items.

    final filteredOrders =
        orders.where((o) => _orderStatusOf(o) == status).toList();

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
                    Text('Table: ${_orderTableOf(order) ?? 'N/A'}',
                        style: Theme.of(context).textTheme.titleLarge),
                    Text(() {
                      final id = _orderIdOf(order);
                      return '#${id.length > 4 ? id.substring(0, 4) : id}';
                    }()),
                  ],
                ),
                const Divider(),
                ..._orderItemsOf(order).map((item) => _buildOrderItem(item)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildTimeAgo(_orderCreatedAtOf(order)),
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

  Widget _buildOrderItem(dynamic item) {
    // Check if this item belongs to selected station
    // If _selectedStationId is set, and item.product.stationId != _selectedStationId, maybe dim it or hide it?
    // Current OrderItem entity in Mobile might not have nested Product->Station loaded.
    // Let's assume we show all for now.

    Color statusColor = Colors.grey;
    if (_itemStatusOf(item) == 'PENDING') statusColor = Colors.orange;
    if (_itemStatusOf(item) == 'PREPARING') statusColor = Colors.blue;
    if (_itemStatusOf(item) == 'READY') statusColor = Colors.green;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${_itemQtyOf(item)}x ${_itemNameOf(item)}',
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
                _itemStatusOf(item),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _advanceItemStatus(dynamic item) {
    final currentStatus = _itemStatusOf(item);
    String nextStatus = 'PENDING';
    if (currentStatus == 'PENDING') {
      nextStatus = 'PREPARING';
    } else if (currentStatus == 'PREPARING')
      nextStatus = 'READY';
    else if (currentStatus == 'READY')
      nextStatus = 'SERVED';
    else
      return; // Already served

    ref
        .read(kitchenControllerProvider(_selectedStationId).notifier)
        .updateItemStatus(_itemIdOf(item), nextStatus);
  }
}
