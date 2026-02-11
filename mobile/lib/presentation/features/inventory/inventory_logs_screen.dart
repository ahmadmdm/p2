import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'inventory_controller.dart';

class InventoryLogsScreen extends ConsumerWidget {
  final String? ingredientId;
  const InventoryLogsScreen({super.key, this.ingredientId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(inventoryLogsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(ingredientId != null
            ? AppLocalizations.of(context)!.ingredientLogs
            : AppLocalizations.of(context)!.inventoryLogs),
      ),
      body: logsAsync.when(
        data: (allLogs) {
          final logs = ingredientId != null
              ? allLogs.where((l) => l.ingredientId == ingredientId).toList()
              : allLogs;

          if (logs.isEmpty) {
            return Center(
                child: Text(AppLocalizations.of(context)!.noLogsFound));
          }
          return ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text(log.ingredientName ??
                      AppLocalizations.of(context)!.unknownIngredient),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          '${log.reason} - ${DateFormat('yyyy-MM-dd HH:mm').format(log.createdAt)}'),
                      if (log.notes != null && log.notes!.isNotEmpty)
                        Text(
                            '${AppLocalizations.of(context)!.notesDescription}: ${log.notes}',
                            style:
                                const TextStyle(fontStyle: FontStyle.italic)),
                      if (log.warehouseName != null)
                        Text(AppLocalizations.of(context)!
                            .warehouseLabel(log.warehouseName!)),
                    ],
                  ),
                  trailing: Text(
                    '${log.quantityChange > 0 ? '+' : ''}${log.quantityChange}',
                    style: TextStyle(
                      color: log.quantityChange > 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) =>
            Center(child: Text('${AppLocalizations.of(context)!.error}: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ref.refresh(inventoryLogsProvider),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
