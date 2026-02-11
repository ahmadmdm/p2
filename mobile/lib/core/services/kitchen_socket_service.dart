import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../presentation/features/settings/settings_controller.dart';

part 'kitchen_socket_service.g.dart';

@Riverpod(keepAlive: true)
KitchenSocketService kitchenSocketService(KitchenSocketServiceRef ref) {
  return KitchenSocketService(ref);
}

class KitchenSocketService {
  IO.Socket? _socket;
  final StreamController<void> _orderUpdateController =
      StreamController.broadcast();
  final StreamController<void> _tableUpdateController =
      StreamController.broadcast();
  final Ref _ref;

  KitchenSocketService(this._ref) {
    _initSocket();
  }

  Stream<void> get onOrderUpdate => _orderUpdateController.stream;
  Stream<void> get onTableUpdate => _tableUpdateController.stream;

  void _initSocket() async {
    final settings = await _ref.read(settingsControllerProvider.future);
    final baseUrl = settings['baseUrl'] ?? 'http://localhost:3001';

    _socket = IO.io(
        baseUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect() // We connect manually
            .build());

    _socket?.connect();

    _socket?.onConnect((_) {
      print('Kitchen Socket Connected');
      _socket?.emit('joinKitchen');
    });

    _socket?.onDisconnect((_) => print('Kitchen Socket Disconnected'));

    _socket?.on('newOrder', (data) {
      print('New Order Received via Socket');
      _orderUpdateController.add(null);
    });

    _socket?.on('orderUpdated', (data) {
      print('Order Updated via Socket');
      _orderUpdateController.add(null);
    });

    _socket?.on('billRequested', (data) {
      print('Bill Requested: $data');
      // We could handle this separately if needed
      _orderUpdateController.add(null);
    });

    _socket?.on('tableUpdated', (data) {
      print('Table Updated via Socket: $data');
      _tableUpdateController.add(null);
    });
  }

  void dispose() {
    _socket?.dispose();
    _orderUpdateController.close();
    _tableUpdateController.close();
  }
}
