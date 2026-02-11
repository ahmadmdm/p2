import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_state.g.dart';

@riverpod
class TableToken extends _$TableToken {
  @override
  String? build() => null;

  void setToken(String token) {
    state = token;
  }
}

@riverpod
class ActiveOrderId extends _$ActiveOrderId {
  @override
  String? build() => null;

  void setId(String? id) {
    state = id;
  }
}
