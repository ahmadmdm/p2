import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'app_state.dart';
import '../services/api_service.dart';

part 'menu_provider.g.dart';

@riverpod
Future<Map<String, dynamic>> menu(Ref ref) async {
  final token = ref.watch(tableTokenProvider);
  if (token == null) {
    throw Exception('No table token found');
  }
  return ref.read(apiServiceProvider.notifier).getMenu(token);
}
