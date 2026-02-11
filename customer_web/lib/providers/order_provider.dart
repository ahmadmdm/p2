import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'app_state.dart';
import '../services/api_service.dart';

part 'order_provider.g.dart';

@riverpod
Future<Map<String, dynamic>> orderStatus(Ref ref, String orderId) async {
  final token = ref.watch(tableTokenProvider);
  if (token == null) throw Exception('No table token');
  
  final dio = ref.read(dioProvider);
  final response = await dio.get('/orders/$orderId', queryParameters: {'t': token});
  return response.data;
}
