import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'shifts_controller.dart';

class ShiftScreen extends ConsumerWidget {
  const ShiftScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shiftAsync = ref.watch(shiftsControllerProvider);

    return Scaffold(
      appBar:
          AppBar(title: Text(AppLocalizations.of(context)!.shiftManagement)),
      body: shiftAsync.when(
        data: (shift) {
          if (shift == null) {
            return Center(
              child: ElevatedButton(
                onPressed: () => _showOpenShiftDialog(context, ref),
                child: Text(AppLocalizations.of(context)!.openShift),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context)!.shiftId(shift.id),
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 10),
                Text(AppLocalizations.of(context)!.started(DateFormat(
                        'yyyy-MM-dd HH:mm',
                        Localizations.localeOf(context).toString())
                    .format(shift.startTime))),
                Text(AppLocalizations.of(context)!
                    .startingCashLabel(shift.startingCash)),
                const Divider(),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () =>
                          _showTransactionDialog(context, ref, 'IN'),
                      child: Text(AppLocalizations.of(context)!.payIn),
                    ),
                    ElevatedButton(
                      onPressed: () =>
                          _showTransactionDialog(context, ref, 'OUT'),
                      child: Text(AppLocalizations.of(context)!.payOut),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () =>
                        _showCloseShiftDialog(context, ref, shift.id),
                    child: Text(AppLocalizations.of(context)!.closeShift,
                        style: const TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text('${AppLocalizations.of(context)!.error}: $err')),
      ),
    );
  }

  Future<void> _showOpenShiftDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.openShift),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.startingCash),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(controller.text) ?? 0;
              ref.read(shiftsControllerProvider.notifier).openShift(amount);
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.open),
          ),
        ],
      ),
    );
  }

  Future<void> _showTransactionDialog(
      BuildContext context, WidgetRef ref, String type) async {
    final amountController = TextEditingController();
    final reasonController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(type == 'IN'
            ? AppLocalizations.of(context)!.payIn
            : AppLocalizations.of(context)!.payOut),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.amount),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.reason),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text) ?? 0;
              ref
                  .read(shiftsControllerProvider.notifier)
                  .addCashTransaction(type, amount, reasonController.text);
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      ),
    );
  }

  Future<void> _showCloseShiftDialog(
      BuildContext context, WidgetRef ref, String shiftId) async {
    final cashController = TextEditingController();
    final notesController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.closeShift),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: cashController,
              decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.endingCash),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: notesController,
              decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.notes),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(cashController.text) ?? 0;
              ref
                  .read(shiftsControllerProvider.notifier)
                  .closeShift(amount, notesController.text);
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ],
      ),
    );
  }
}
