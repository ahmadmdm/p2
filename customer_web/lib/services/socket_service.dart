import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'socket_service.g.dart';

@Riverpod(keepAlive: true)
SocketService socketService(Ref ref) {
  final service = SocketService();
  service.init();
  ref.onDispose(() => service.dispose());
  return service;
}

class SocketService {
  io.Socket? _socket;
  final String _baseUrl = const String.fromEnvironment(
    'SOCKET_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );
  final Set<String> _joinedOrders = <String>{};
  final StreamController<dynamic> _orderStatusController =
      StreamController<dynamic>.broadcast();
  final Set<String> _recentEventKeys = <String>{};
  final Queue<String> _eventKeyQueue = Queue<String>();
  static const int _maxRecentEventKeys = 200;

  void init() {
    _socket ??= io.io(
      _baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setReconnectionAttempts(100)
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(30000)
          .enableReconnection()
          .disableAutoConnect()
          .build(),
    );

    _socket?.connect();

    _socket?.onConnect((_) {
      debugPrint('Connected to WebSocket');
      for (final orderId in _joinedOrders) {
        unawaited(joinOrder(orderId));
      }
    });

    _socket?.onDisconnect((_) {
      debugPrint('Disconnected from WebSocket');
    });

    _socket?.onReconnect((_) {
      debugPrint('WebSocket reconnected');
    });

    _socket?.onError((error) {
      debugPrint('WebSocket error: $error');
    });

    _socket?.on('orderStatusUpdated', (data) {
      if (_isDuplicateEvent(data)) {
        return;
      }
      _orderStatusController.add(data);
    });
  }

  Future<void> joinOrder(String orderId) async {
    _joinedOrders.add(orderId);
    if (_socket?.connected != true) {
      return;
    }

    final acknowledged = await _emitWithAck(
      'joinOrder',
      orderId,
      timeout: const Duration(seconds: 5),
    );

    if (!acknowledged) {
      debugPrint('joinOrder ack timeout for order: $orderId');
    }
  }

  StreamSubscription<dynamic> onOrderStatusUpdated(
    void Function(dynamic) callback,
  ) {
    return _orderStatusController.stream.listen(callback);
  }

  Future<bool> _emitWithAck(
    String event,
    dynamic payload, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final socket = _socket;
    if (socket == null || socket.connected != true) {
      return false;
    }

    final completer = Completer<bool>();
    Timer? timer;
    timer = Timer(timeout, () {
      if (!completer.isCompleted) {
        completer.complete(false);
      }
    });

    socket.emitWithAck(
      event,
      payload,
      ack: (_) {
        if (!completer.isCompleted) {
          completer.complete(true);
        }
      },
    );

    final result = await completer.future;
    timer.cancel();
    return result;
  }

  bool _isDuplicateEvent(dynamic data) {
    final key = _eventKey(data);
    if (_recentEventKeys.contains(key)) {
      return true;
    }

    _recentEventKeys.add(key);
    _eventKeyQueue.addLast(key);
    if (_eventKeyQueue.length > _maxRecentEventKeys) {
      final oldest = _eventKeyQueue.removeFirst();
      _recentEventKeys.remove(oldest);
    }
    return false;
  }

  String _eventKey(dynamic data) {
    if (data is Map) {
      final id = data['id']?.toString() ?? '';
      final status = data['status']?.toString() ?? '';
      final updatedAt =
          data['updatedAt']?.toString() ?? data['createdAt']?.toString() ?? '';
      return '$id|$status|$updatedAt';
    }
    return data.toString();
  }

  void dispose() {
    _orderStatusController.close();
    _socket?.disconnect();
    _socket?.dispose();
  }
}
