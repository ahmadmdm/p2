import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'reports_controller.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.reportsAndAnalytics),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(dailySalesProvider);
              ref.invalidate(topProductsProvider);
              ref.invalidate(lowStockAlertsProvider);
              ref.invalidate(salesByCategoryProvider);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDailySalesCard(context, ref),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.lowStockAlerts,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildLowStockList(context, ref),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.topProducts,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildTopProductsList(context, ref),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.salesByCategory,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildSalesByCategoryList(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesByCategoryList(BuildContext context, WidgetRef ref) {
    final salesAsync = ref.watch(salesByCategoryProvider);

    return salesAsync.when(
      data: (items) {
        if (items.isEmpty)
          return Text(AppLocalizations.of(context)!.noDataAvailable);
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return ListTile(
              leading: const Icon(Icons.category, color: Colors.blue),
              title: Text(item['categoryName'] ??
                  AppLocalizations.of(context)!.uncategorized),
              trailing: Text(AppLocalizations.of(context)!
                  .priceLabel((item['totalSales'] ?? 0).toDouble())),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) =>
          Text('${AppLocalizations.of(context)!.error}: $err'),
    );
  }

  Widget _buildDailySalesCard(BuildContext context, WidgetRef ref) {
    final salesAsync = ref.watch(dailySalesProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              AppLocalizations.of(context)!.dailySales,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            salesAsync.when(
              data: (data) => Column(
                children: [
                  Text(
                    '${AppLocalizations.of(context)!.total}: ${AppLocalizations.of(context)!.priceLabel((data['total'] ?? 0).toDouble())}',
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                  ),
                  Text(AppLocalizations.of(context)!
                      .salesCount(data['count'] ?? 0)),
                ],
              ),
              loading: () => const CircularProgressIndicator(),
              error: (err, stack) =>
                  Text('${AppLocalizations.of(context)!.error}: $err'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLowStockList(BuildContext context, WidgetRef ref) {
    final lowStockAsync = ref.watch(lowStockAlertsProvider);

    return lowStockAsync.when(
      data: (items) {
        if (items.isEmpty)
          return Text(AppLocalizations.of(context)!.noLowStockAlerts);
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return ListTile(
              leading: const Icon(Icons.warning, color: Colors.orange),
              title: Text(item['name'] ?? 'Unknown Item'),
              subtitle: Text(AppLocalizations.of(context)!.stockLevel(
                  (item['currentStock'] as num).toDouble(),
                  item['unit'].toString(),
                  (item['minLevel'] as num).toDouble())),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) =>
          Text('${AppLocalizations.of(context)!.error}: $err'),
    );
  }

  Widget _buildTopProductsList(BuildContext context, WidgetRef ref) {
    final topProductsAsync = ref.watch(topProductsProvider);

    return topProductsAsync.when(
      data: (items) {
        if (items.isEmpty)
          return Text(AppLocalizations.of(context)!.noDataAvailable);
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return ListTile(
              leading: CircleAvatar(child: Text('${index + 1}')),
              title: Text(item['name'] ?? 'Product'),
              trailing: Text(
                  AppLocalizations.of(context)!.itemsSold(item['count'] ?? 0)),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) =>
          Text('${AppLocalizations.of(context)!.error}: $err'),
    );
  }
}
