import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';
import '../../../core/services/kitchen_socket_service.dart';
import '../../../domain/entities/restaurant_table.dart';
import 'tables_controller.dart';

import 'widgets/table_order_details_dialog.dart';

class FloorPlanScreen extends ConsumerStatefulWidget {
  const FloorPlanScreen({super.key});

  @override
  ConsumerState<FloorPlanScreen> createState() => _FloorPlanScreenState();
}

class _FloorPlanScreenState extends ConsumerState<FloorPlanScreen> {
  bool _isEditMode = false;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    final socketService = ref.read(kitchenSocketServiceProvider);
    _subscription = socketService.onTableUpdate.listen((_) {
      ref.invalidate(tablesControllerProvider);
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Keep socket service alive
    ref.watch(kitchenSocketServiceProvider);

    final tablesAsync = ref.watch(tablesControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.floorPlan),
        actions: [
          IconButton(
            icon: Icon(_isEditMode ? Icons.check : Icons.edit),
            onPressed: () {
              if (_isEditMode) {
                // Save changes
                final tables = ref.read(tablesControllerProvider).value;
                if (tables != null) {
                  ref
                      .read(tablesControllerProvider.notifier)
                      .saveLayout(tables);
                }
              }
              setState(() {
                _isEditMode = !_isEditMode;
              });
            },
          ),
          if (_isEditMode)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _addNewTable,
            ),
        ],
      ),
      body: tablesAsync.when(
        data: (tables) => _buildFloorPlan(context, tables),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text('${AppLocalizations.of(context)!.error}: $err')),
      ),
    );
  }

  Widget _buildFloorPlan(BuildContext context, List<RestaurantTable> tables) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // Grid background (optional)
            Container(color: Colors.grey[200]),

            // Tables
            ...tables.map((table) => _buildTableWidget(table)),
          ],
        );
      },
    );
  }

  Widget _buildTableWidget(RestaurantTable table) {
    return Positioned(
      left: table.x,
      top: table.y,
      child: GestureDetector(
        onPanUpdate: _isEditMode
            ? (details) {
                final newX = table.x + details.delta.dx;
                final newY = table.y + details.delta.dy;

                final updatedTable = table.copyWith(x: newX, y: newY);
                ref
                    .read(tablesControllerProvider.notifier)
                    .updateTableLocally(updatedTable);
              }
            : null,
        onTap: () {
          if (!_isEditMode) {
            showDialog(
              context: context,
              builder: (context) => TableOrderDetailsDialog(table: table),
            );
          } else {
            _showEditTableDialog(table);
          }
        },
        child: Transform.rotate(
          angle: table.rotation,
          child: Container(
            width: table.width,
            height: table.height,
            decoration: BoxDecoration(
                color: _getTableColor(table.status),
                shape: table.shape == 'circle'
                    ? BoxShape.circle
                    : BoxShape.rectangle,
                border: Border.all(color: Colors.black, width: 2),
                borderRadius: table.shape == 'rectangle'
                    ? BorderRadius.circular(8)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(2, 2),
                  )
                ]),
            child: Center(
              child: Text(
                table.tableNumber,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getTableColor(String status) {
    switch (status) {
      case 'occupied':
        return Colors.red[300]!;
      case 'reserved':
        return Colors.orange[300]!;
      case 'billed':
        return Colors.blue[300]!;
      case 'free':
      default:
        return Colors.green[300]!;
    }
  }

  void _addNewTable() {
    final newTable = RestaurantTable(
      id: const Uuid().v4(),
      tableNumber:
          'T${(ref.read(tablesControllerProvider).value?.length ?? 0) + 1}',
      x: 50,
      y: 50,
      width: 80,
      height: 80,
    );
    ref.read(tablesControllerProvider.notifier).addTableLocally(newTable);
  }

  void _showEditTableDialog(RestaurantTable table) {
    showDialog(
        context: context,
        builder: (context) {
          String tableNumber = table.tableNumber;
          String shape = table.shape;

          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.editTable),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(
                      labelText:
                          AppLocalizations.of(context)!.tableNumberInput),
                  controller: TextEditingController(text: tableNumber),
                  onChanged: (val) => tableNumber = val,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: shape,
                  items: [
                    DropdownMenuItem(
                        value: 'rectangle',
                        child: Text(AppLocalizations.of(context)!.rectangle)),
                    DropdownMenuItem(
                        value: 'circle',
                        child: Text(AppLocalizations.of(context)!.circle)),
                  ],
                  onChanged: (val) {
                    if (val != null) shape = val;
                  },
                  decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.shape),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  ref
                      .read(tablesControllerProvider.notifier)
                      .removeTableLocally(table.id);
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text(AppLocalizations.of(context)!.delete),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
              TextButton(
                onPressed: () {
                  final updated = table.copyWith(
                    tableNumber: tableNumber,
                    shape: shape,
                  );
                  ref
                      .read(tablesControllerProvider.notifier)
                      .updateTableLocally(updated);
                  Navigator.of(context).pop();
                },
                child: Text(AppLocalizations.of(context)!.save),
              ),
            ],
          );
        });
  }
}
