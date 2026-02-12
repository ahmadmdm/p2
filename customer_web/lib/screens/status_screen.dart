import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:customer_web/l10n/app_localizations.dart';
import '../providers/order_provider.dart';
import '../providers/app_state.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';
import '../theme/app_theme.dart';

class StatusScreen extends ConsumerStatefulWidget {
  final String orderId;
  const StatusScreen({super.key, required this.orderId});

  @override
  ConsumerState<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends ConsumerState<StatusScreen> {
  StreamSubscription<dynamic>? _orderStatusSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final socket = ref.read(socketServiceProvider);
      await socket.joinOrder(widget.orderId);
      _orderStatusSubscription = socket.onOrderStatusUpdated((data) {
        final updatedOrderId = (data is Map) ? data['id']?.toString() : null;
        if (updatedOrderId != null && updatedOrderId != widget.orderId) {
          return;
        }
        if (!mounted) return;
        ref.invalidate(orderStatusProvider(widget.orderId));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Order status updated: ${(data is Map) ? data['status'] : ''}',
            ),
          ),
        );
      });
    });
  }

  @override
  void dispose() {
    _orderStatusSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderAsync = ref.watch(orderStatusProvider(widget.orderId));
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;

    return Container(
      decoration: AppTheme.gradientBackground(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            l10n.orderStatus,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(orderStatusProvider(widget.orderId));
          },
          child: orderAsync.when(
            data: (order) {
              final status = order['status'] as String? ?? 'PENDING';
              final items = order['items'] as List<dynamic>? ?? [];

              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        children: [
                          _statusDot(status),
                          const SizedBox(height: 8),
                          Text(
                            _localizedStatus(status, l10n).toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 24,
                              color: _getStatusColor(status),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Order #${widget.orderId.substring(0, 8)}',
                            style: TextStyle(color: Colors.brown.shade600),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...items.map((item) {
                    final productName =
                        item['product']?['name']?[locale] ??
                        item['product']?['name']?['en'] ??
                        item['product']?['name'] ??
                        'Unknown Product';
                    final modifiers = item['modifiers'] as List<dynamic>? ?? [];
                    final notes = item['notes'] as String?;

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    productName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Text(
                                  'x${item['quantity']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.secondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '\$${item['price']}',
                              style: const TextStyle(color: AppTheme.primary),
                            ),
                            if (modifiers.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              ...modifiers.map(
                                (m) => Text(
                                  '+ ${m['name']?[locale] ?? m['name']?['en'] ?? m['name'] ?? 'Modifier'}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.brown.shade600,
                                  ),
                                ),
                              ),
                            ],
                            if (notes != null && notes.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                '${l10n.notes}: $notes',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => context.go('/menu'),
                      icon: const Icon(Icons.add_shopping_cart_rounded),
                      label: Text(l10n.orderMore),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonalIcon(
                      onPressed: () async {
                        try {
                          final token = ref.read(tableTokenProvider);
                          if (token != null) {
                            await ref
                                .read(apiServiceProvider.notifier)
                                .requestBill(token);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l10n.billRequested)),
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
                      icon: const Icon(Icons.receipt_long_rounded),
                      label: Text(l10n.requestBill),
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
        ),
      ),
    );
  }

  Widget _statusDot(String status) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: _getStatusColor(status).withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(
        _statusIcon(status),
        color: _getStatusColor(status),
      ),
    );
  }

  String _localizedStatus(String status, AppLocalizations l10n) {
    switch (status.toLowerCase()) {
      case 'pending':
        return l10n.pending;
      case 'preparing':
        return l10n.preparing;
      case 'ready':
        return l10n.ready;
      case 'served':
        return l10n.served;
      case 'cancelled':
        return l10n.cancelled;
      default:
        return status;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.timelapse_rounded;
      case 'preparing':
        return Icons.soup_kitchen_rounded;
      case 'ready':
        return Icons.check_circle_rounded;
      case 'served':
        return Icons.restaurant_rounded;
      case 'cancelled':
        return Icons.cancel_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFC78A2A);
      case 'preparing':
        return const Color(0xFF2C7AAE);
      case 'ready':
        return const Color(0xFF2E8D4E);
      case 'served':
        return const Color(0xFF5A5A5A);
      case 'cancelled':
        return const Color(0xFFB33A3A);
      default:
        return Colors.black87;
    }
  }
}
