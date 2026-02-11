import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
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
  IO.Socket? _socket;
  // TODO: Make this configurable
  final String _baseUrl = 'http://localhost:3001'; 

  void init() {
    _socket = IO.io(_baseUrl, IO.OptionBuilder()
      .setTransports(['websocket'])
      .disableAutoConnect()
      .build());
    
    _socket?.connect();
    
    _socket?.onConnect((_) {
      print('Connected to WebSocket');
    });

    _socket?.onDisconnect((_) {
      print('Disconnected from WebSocket');
    });
  }

  void joinOrder(String orderId) {
    if (_socket?.connected == true) {
      _socket?.emit('joinOrder', orderId);
    } else {
      _socket?.onConnect((_) {
        _socket?.emit('joinOrder', orderId);
      });
    }
  }

  void onOrderStatusUpdated(Function(dynamic) callback) {
    _socket?.on('orderStatusUpdated', callback);
  }
  
  void dispose() {
    _socket?.disconnect();
    _socket?.dispose();
  }
}
