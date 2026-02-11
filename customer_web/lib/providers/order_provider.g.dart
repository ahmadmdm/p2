// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(orderStatus)
final orderStatusProvider = OrderStatusFamily._();

final class OrderStatusProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, dynamic>>,
          Map<String, dynamic>,
          FutureOr<Map<String, dynamic>>
        >
    with
        $FutureModifier<Map<String, dynamic>>,
        $FutureProvider<Map<String, dynamic>> {
  OrderStatusProvider._({
    required OrderStatusFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'orderStatusProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$orderStatusHash();

  @override
  String toString() {
    return r'orderStatusProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Map<String, dynamic>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, dynamic>> create(Ref ref) {
    final argument = this.argument as String;
    return orderStatus(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is OrderStatusProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$orderStatusHash() => r'ffd805f1c02ecc41e743ce657804cfe8928654f0';

final class OrderStatusFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Map<String, dynamic>>, String> {
  OrderStatusFamily._()
    : super(
        retry: null,
        name: r'orderStatusProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  OrderStatusProvider call(String orderId) =>
      OrderStatusProvider._(argument: orderId, from: this);

  @override
  String toString() => r'orderStatusProvider';
}
