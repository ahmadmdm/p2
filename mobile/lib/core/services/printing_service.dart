import 'dart:io';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_item.dart';
import '../../domain/entities/station.dart';
import '../../presentation/features/settings/settings_controller.dart';

part 'printing_service.g.dart';

@riverpod
PrintingService printingService(Ref ref) {
  return PrintingService(ref);
}

class PrintingService {
  final Ref _ref;

  PrintingService(this._ref);

  int _normalizePort(int? port) {
    if (port == null || port <= 0 || port > 65535) return 9100;
    return port;
  }

  int _normalizeRetryCount(int? value) {
    if (value == null || value < 1) return 1;
    if (value > 5) return 5;
    return value;
  }

  int _normalizeTimeoutMs(int? value) {
    if (value == null || value < 1000) return 5000;
    if (value > 30000) return 30000;
    return value;
  }

  int _normalizeCopies(int? value) {
    if (value == null || value < 1) return 1;
    if (value > 3) return 3;
    return value;
  }

  Future<void> printOrderReceipt(Order order) async {
    final settings = await _ref.read(settingsControllerProvider.future);
    final ip = (settings['printerIp'] as String?)?.trim() ?? '';
    final port = _normalizePort(settings['printerPort'] as int?);
    final paperSizeStr = settings['paperSize'] as String? ?? '80mm';
    final retryCount =
        _normalizeRetryCount(settings['printerRetryCount'] as int?);
    final timeoutMs = _normalizeTimeoutMs(settings['printerTimeoutMs'] as int?);
    final copies = _normalizeCopies(settings['receiptCopies'] as int?);

    if (ip.isEmpty) {
      throw Exception('Printer IP is not configured');
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

    // Send requested number of copies to cashier printer.
    for (var i = 0; i < copies; i++) {
      await _sendToNetworkPrinter(
        ip,
        port,
        bytes,
        retryCount: retryCount,
        timeoutMs: timeoutMs,
      );
    }
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

    final settings = await _ref.read(settingsControllerProvider.future);
    final retryCount =
        _normalizeRetryCount(settings['printerRetryCount'] as int?);
    final timeoutMs = _normalizeTimeoutMs(settings['printerTimeoutMs'] as int?);

    // Print for each station
    for (final stationId in itemsByStation.keys) {
      final station = stations[stationId]!;
      final items = itemsByStation[stationId]!;
      final printerIp = station.printerIp?.trim();
      final printerPort = _normalizePort(station.printerPort);

      if (printerIp != null && printerIp.isNotEmpty) {
        try {
          await _printToStation(
              printerIp, printerPort, station.name, order, items,
              retryCount: retryCount, timeoutMs: timeoutMs);
        } catch (e) {
          debugPrint('Failed to print to station ${station.name}: $e');
        }
      } else {
        debugPrint('No printer IP configured for station ${station.name}');
      }
    }
  }

  Future<void> _printToStation(
    String ip,
    int port,
    String stationName,
    Order order,
    List<OrderItem> items, {
    required int retryCount,
    required int timeoutMs,
  }) async {
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

    await _sendToNetworkPrinter(
      ip,
      port,
      bytes,
      retryCount: retryCount,
      timeoutMs: timeoutMs,
    );
  }

  Future<void> _sendToNetworkPrinter(
    String ip,
    int port,
    List<int> bytes, {
    required int retryCount,
    required int timeoutMs,
  }) async {
    Object? lastError;
    for (var attempt = 1; attempt <= retryCount; attempt++) {
      Socket? socket;
      try {
        socket = await Socket.connect(
          ip,
          port,
          timeout: Duration(milliseconds: timeoutMs),
        );
        socket.add(bytes);
        await socket.flush();
        await socket.close();
        return;
      } catch (e) {
        lastError = e;
        debugPrint(
          'Print attempt $attempt/$retryCount failed for $ip:$port: $e',
        );
      } finally {
        socket?.destroy();
      }
    }
    throw Exception(
      'Could not connect to printer at $ip:$port. Last error: $lastError',
    );
  }

  Future<void> printTestReceipt({
    required String ip,
    required int port,
    required String paperSize,
    int retryCount = 1,
    int timeoutMs = 5000,
  }) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(
      paperSize == '58mm' ? PaperSize.mm58 : PaperSize.mm80,
      profile,
    );

    List<int> bytes = [];
    final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    bytes += generator.text(
      'PRINTER TEST',
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );
    bytes += generator.feed(1);
    bytes += generator.text('Connection to printer is successful.',
        styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text('Time: $now',
        styles: const PosStyles(align: PosAlign.center));
    bytes += generator.hr();
    bytes += generator.text('Sample line: 1 x Espresso      12.00');
    bytes += generator.text('Sample line: 2 x Latte         24.00');
    bytes += generator.hr();
    bytes += generator.text('TOTAL: 36.00',
        styles: const PosStyles(align: PosAlign.right, bold: true));
    bytes += generator.feed(3);
    bytes += generator.cut();

    await _sendToNetworkPrinter(
      ip.trim(),
      _normalizePort(port),
      bytes,
      retryCount: _normalizeRetryCount(retryCount),
      timeoutMs: _normalizeTimeoutMs(timeoutMs),
    );
  }

  Future<bool> testPrinter(
    String ip,
    int port, {
    int timeoutMs = 3000,
  }) async {
    Socket? socket;
    try {
      socket = await Socket.connect(
        ip.trim(),
        _normalizePort(port),
        timeout: Duration(milliseconds: _normalizeTimeoutMs(timeoutMs)),
      );
      return true;
    } catch (_) {
      return false;
    } finally {
      socket?.destroy();
    }
  }

  Future<void> printKitchenTicket(Order order, {String? onlyCourse}) async {
    await printStationTickets(order, onlyCourse: onlyCourse);
  }
}
