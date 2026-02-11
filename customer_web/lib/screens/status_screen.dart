import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/order_provider.dart';
import '../providers/app_state.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';

class StatusScreen extends ConsumerStatefulWidget {
  final String orderId;
  const StatusScreen({super.key, required this.orderId});

  @override
  ConsumerState<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends ConsumerState<StatusScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize socket connection and join order room
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final socket = ref.read(socketServiceProvider);
      socket.joinOrder(widget.orderId);
      socket.onOrderStatusUpdated((data) {
        if (mounted) {
          // Invalidate provider to trigger refresh
          ref.invalidate(orderStatusProvider(widget.orderId));

          // Optionally show a snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Order status updated: ${data['status']}')),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderAsync = ref.watch(orderStatusProvider(widget.orderId));
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.orderStatus)),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(orderStatusProvider(widget.orderId));
        },
        child: orderAsync.when(
          data: (order) {
            final status = order['status'] as String? ?? 'Pending';
            final items = order['items'] as List<dynamic>? ?? [];

            String localizedStatus;
            switch (status.toLowerCase()) {
              case 'pending':
                localizedStatus = l10n.pending;
                break;
              case 'preparing':
                localizedStatus = l10n.preparing;
                break;
              case 'ready':
                localizedStatus = l10n.ready;
                break;
              case 'served':
                localizedStatus = l10n.served;
                break;
              case 'cancelled':
                localizedStatus = l10n.cancelled;
                break;
              default:
                localizedStatus = status;
            }

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              l10n.orderStatus,
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              localizedStatus.toUpperCase(),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(status),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Order ID: #${widget.orderId.substring(0, 8)}...',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.items,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final productName =
                            item['product']?['name']?[locale] ??
                            item['product']?['name']?['en'] ??
                            item['product']?['name'] ??
                            'Unknown Product';

                        final modifiers =
                            item['modifiers'] as List<dynamic>? ?? [];
                        final notes = item['notes'] as String?;

                        return Column(
                          children: [
                            ListTile(
                              title: Text(productName),
                              trailing: Text('x${item['quantity']}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('\$${item['price']}'),
                                  if (modifiers.isNotEmpty)
                                    ...modifiers.map(
                                      (m) => Text(
                                        '+ ${m['name']?[locale] ?? m['name']?['en'] ?? m['name'] ?? 'Modifier'}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  if (notes != null && notes.isNotEmpty)
                                    Text(
                                      '${l10n.notes}: $notes',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const Divider(),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          context.go('/menu');
                        },
                        child: Text(l10n.orderMore),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.tonal(
                        onPressed: () async {
                          try {
                            final token = ref.read(tableTokenProvider);
                            if (token != null) {
                              await ref
                                  .read(apiServiceProvider.notifier)
                                  .requestBill(token);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      l10n.billRequested,
                                    ),
                                  ),
                                );
                              }
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${l10n.error}: $e')),
                              );
                            }
                          }
                        },
                        child: Text(l10n.requestBill),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'preparing':
        return Colors.blue;
      case 'ready':
        return Colors.green;
      case 'served':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.black;
    }
  }
}
