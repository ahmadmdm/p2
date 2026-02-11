// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TableToken)
final tableTokenProvider = TableTokenProvider._();

final class TableTokenProvider extends $NotifierProvider<TableToken, String?> {
  TableTokenProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tableTokenProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tableTokenHash();

  @$internal
  @override
  TableToken create() => TableToken();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$tableTokenHash() => r'9d75a815d43e10feaa77ae6f89a3ef8ce25e09a3';

abstract class _$TableToken extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(ActiveOrderId)
final activeOrderIdProvider = ActiveOrderIdProvider._();

final class ActiveOrderIdProvider
    extends $NotifierProvider<ActiveOrderId, String?> {
  ActiveOrderIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeOrderIdProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeOrderIdHash();

  @$internal
  @override
  ActiveOrderId create() => ActiveOrderId();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$activeOrderIdHash() => r'f0b0ec7cf642bc590cc3e3d3bdae67e457bd52a5';

abstract class _$ActiveOrderId extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
