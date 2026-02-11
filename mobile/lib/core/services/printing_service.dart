import 'dart:io';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_item.dart';
import '../../domain/entities/station.dart';
import '../../presentation/features/settings/settings_controller.dart';

part 'printing_service.g.dart';

@riverpod
PrintingService printingService(PrintingServiceRef ref) {
  return PrintingService(ref);
}

class PrintingService {
  final Ref _ref;

  PrintingService(this._ref);

  Future<void> printOrderReceipt(Order order) async {
    final settings = await _ref.read(settingsControllerProvider.future);
    final ip = settings['printerIp'] as String?;
    final port = settings['printerPort'] as int? ?? 9100;
    final paperSizeStr = settings['paperSize'] as String? ?? '80mm';

    if (ip == null || ip.isEmpty) {
      print('Printer IP not configured');
      return;
    }

    final profile = await CapabilityProfile.load();
    final generator = Generator(
      paperSizeStr == '58mm' ? PaperSize.mm58 : PaperSize.mm80,
      profile,
    );

    List<int> bytes = [];

    // Header
    bytes += generator.text(
      'POS Restaurant',
      styles: const PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
        bold: true,
      ),
    );
    bytes += generator.text('Branch: Main',
        styles: const PosStyles(align: PosAlign.center));
    bytes += generator.feed(1);

    // Order Info
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    bytes += generator.text('Order #${order.id.substring(0, 8)}',
        styles: const PosStyles(bold: true));
    bytes += generator.text('Table: ${order.tableNumber ?? "N/A"}');
    bytes += generator.text('Date: ${dateFormat.format(order.createdAt)}');
    bytes += generator.hr();

    // Items
    bytes += generator.row([
      PosColumn(text: 'Item', width: 6),
      PosColumn(text: 'Qty', width: 2),
      PosColumn(
          text: 'Price',
          width: 4,
          styles: const PosStyles(align: PosAlign.right)),
    ]);

    for (final item in order.items) {
      bytes += generator.row([
        PosColumn(text: item.product.nameEn, width: 6),
        PosColumn(text: '${item.quantity}', width: 2),
        PosColumn(
            text: (item.price * item.quantity).toStringAsFixed(2),
            width: 4,
            styles: const PosStyles(align: PosAlign.right)),
      ]);

      // Modifiers
      if (item.modifiers.isNotEmpty) {
        for (final mod in item.modifiers) {
          bytes += generator.row([
            PosColumn(
                text: ' + ${mod.nameEn}',
                width: 8,
                styles: const PosStyles(fontType: PosFontType.fontB)),
            PosColumn(
                text: (mod.price * item.quantity).toStringAsFixed(2),
                width: 4,
                styles: const PosStyles(
                    align: PosAlign.right, fontType: PosFontType.fontB)),
          ]);
        }
      }

      if (item.notes != null && item.notes!.isNotEmpty) {
        bytes += generator.text(' Note: ${item.notes}',
            styles: const PosStyles(fontType: PosFontType.fontB));
      }
    }

    bytes += generator.hr();

    // Totals
    bytes += generator.row([
      PosColumn(
          text: 'TOTAL',
          width: 6,
          styles: const PosStyles(height: PosTextSize.size2, bold: true)),
      PosColumn(
          text: order.totalAmount.toStringAsFixed(2),
          width: 6,
          styles: const PosStyles(
              align: PosAlign.right, height: PosTextSize.size2, bold: true)),
    ]);

    bytes += generator.feed(1);
    bytes += generator.text('Payment: ${order.paymentMethod}',
        styles: const PosStyles(align: PosAlign.center));
    
    // Loyalty Points (if available in order entity, skipping for now as it's not in mobile entity yet)
    
    bytes += generator.feed(2);
    bytes += generator.text('Thank you!',
        styles: const PosStyles(align: PosAlign.center, bold: true));
    bytes += generator.feed(3);
    bytes += generator.cut();

    // Send to printer
    await _sendToNetworkPrinter(ip, port, bytes);
  }

  Future<void> printStationTickets(Order order, {String? onlyCourse}) async {
    // Group items by station
    final itemsByStation = <String, List<OrderItem>>{};
    final stations = <String, Station>{};

    for (final item in order.items) {
      if (onlyCourse != null && item.product.course != onlyCourse) continue;
      // Only print PENDING items (usually newly fired/ordered)
      if (item.status != 'PENDING') continue;

      final station = item.product.station;
      if (station != null) {
        if (!itemsByStation.containsKey(station.id)) {
          itemsByStation[station.id] = [];
          stations[station.id] = station;
        }
        itemsByStation[station.id]!.add(item);
      }
    }

    // Print for each station
    for (final stationId in itemsByStation.keys) {
      final station = stations[stationId]!;
      final items = itemsByStation[stationId]!;
      final printerIp = station.printerIp;
      final printerPort = station.printerPort;

      if (printerIp != null && printerIp.isNotEmpty) {
        try {
          await _printToStation(
              printerIp, printerPort, station.name, order, items);
        } catch (e) {
          print('Failed to print to station ${station.name}: $e');
        }
      } else {
         print('No printer IP for station ${station.name}');
      }
    }
  }

  Future<void> _printToStation(String ip, int port, String stationName,
      Order order, List<OrderItem> items) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    List<int> bytes = [];

    // Header
    bytes += generator.text('KITCHEN TICKET',
        styles: const PosStyles(
            align: PosAlign.center,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
            bold: true));
    bytes += generator.text('Station: $stationName',
        styles: const PosStyles(align: PosAlign.center, bold: true));
    bytes += generator.feed(1);

    // Order Info
    final dateFormat = DateFormat('HH:mm');
    bytes += generator.text('Order #${order.id.substring(0, 4)}',
        styles: const PosStyles(
            height: PosTextSize.size2, width: PosTextSize.size2, bold: true));
    bytes += generator.text('Table: ${order.tableNumber ?? "N/A"}',
        styles: const PosStyles(
            height: PosTextSize.size2, width: PosTextSize.size2, bold: true));
    bytes += generator.text('Time: ${dateFormat.format(order.createdAt)}');

    bytes += generator.hr();

    // Items
    for (final item in items) {
      bytes += generator.text('${item.quantity} x ${item.product.nameEn}',
          styles: const PosStyles(
              height: PosTextSize.size2, width: PosTextSize.size2, bold: true));

      if (item.modifiers.isNotEmpty) {
        for (final mod in item.modifiers) {
          bytes += generator.text('  + ${mod.nameEn}',
              styles: const PosStyles(bold: true));
        }
      }

      if (item.notes != null && item.notes!.isNotEmpty) {
        bytes += generator.text('  NOTE: ${item.notes}',
            styles: const PosStyles(reverse: true));
      }
      bytes += generator.feed(1);
    }

    bytes += generator.feed(3);
    bytes += generator.cut();

    await _sendToNetworkPrinter(ip, port, bytes);
  }

  Future<void> _sendToNetworkPrinter(
      String ip, int port, List<int> bytes) async {
    try {
      final socket =
          await Socket.connect(ip, port, timeout: const Duration(seconds: 5));
      socket.add(bytes);
      await socket.flush();
      socket.destroy();
    } catch (e) {
      print('Error printing to $ip:$port : $e');
      throw Exception('Could not connect to printer at $ip:$port');
    }
  }
  
  Future<bool> testPrinter(String ip, int port) async {
     try {
        final socket = await Socket.connect(ip, port, timeout: const Duration(seconds: 3));
        socket.destroy();
        return true;
     } catch (e) {
        return false;
     }
  }

  Future<void> printKitchenTicket(Order order, {String? onlyCourse}) async {
    await printStationTickets(order, onlyCourse: onlyCourse);
  }
}
