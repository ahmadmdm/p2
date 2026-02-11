import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_mobile/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'refunds_approval_controller.dart';

class RefundsApprovalScreen extends ConsumerWidget {
  const RefundsApprovalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final refundsAsync = ref.watch(pendingRefundsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.pendingRefunds),
      ),
      body: refundsAsync.when(
        data: (refunds) {
          if (refunds.isEmpty) {
            return Center(
                child: Text(AppLocalizations.of(context)!.noPendingRefunds));
          }
          return ListView.builder(
            itemCount: refunds.length,
            itemBuilder: (context, index) {
              final refund = refunds[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(
                      AppLocalizations.of(context)!.refundLabel(refund.amount)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLocalizations.of(context)!
                          .reasonLabel(refund.reason)),
                      Text(AppLocalizations.of(context)!.dateLabel(DateFormat(
                              'MMM dd, HH:mm',
                              Localizations.localeOf(context).toString())
                          .format(refund.createdAt))),
                      // If we had order details, we could show them
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _rejectRefund(context, ref, refund.id);
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                        child: Text(AppLocalizations.of(context)!.reject),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          _approveRefund(context, ref, refund.id);
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green),
                        child: Text(AppLocalizations.of(context)!.approve),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text('${AppLocalizations.of(context)!.error}: $err')),
      ),
    );
  }

  Future<void> _approveRefund(
      BuildContext context, WidgetRef ref, String refundId) async {
    try {
      await ref
          .read(refundsActionsControllerProvider.notifier)
          .approveRefund(refundId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.refundApproved)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.error}: $e')),
        );
      }
    }
  }

  Future<void> _rejectRefund(
      BuildContext context, WidgetRef ref, String refundId) async {
    try {
      await ref
          .read(refundsActionsControllerProvider.notifier)
          .rejectRefund(refundId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.refundRejected)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.error}: $e')),
        );
      }
    }
  }
}

