// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'modifier.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ModifierItem _$ModifierItemFromJson(Map<String, dynamic> json) {
  return _ModifierItem.fromJson(json);
}

/// @nodoc
mixin _$ModifierItem {
  String get id => throw _privateConstructorUsedError;
  String get nameEn => throw _privateConstructorUsedError;
  String get nameAr => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;

  /// Serializes this ModifierItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ModifierItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ModifierItemCopyWith<ModifierItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ModifierItemCopyWith<$Res> {
  factory $ModifierItemCopyWith(
          ModifierItem value, $Res Function(ModifierItem) then) =
      _$ModifierItemCopyWithImpl<$Res, ModifierItem>;
  @useResult
  $Res call({String id, String nameEn, String nameAr, double price});
}

/// @nodoc
class _$ModifierItemCopyWithImpl<$Res, $Val extends ModifierItem>
    implements $ModifierItemCopyWith<$Res> {
  _$ModifierItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ModifierItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nameEn = null,
    Object? nameAr = null,
    Object? price = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      nameEn: null == nameEn
          ? _value.nameEn
          : nameEn // ignore: cast_nullable_to_non_nullable
              as String,
      nameAr: null == nameAr
          ? _value.nameAr
          : nameAr // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ModifierItemImplCopyWith<$Res>
    implements $ModifierItemCopyWith<$Res> {
  factory _$$ModifierItemImplCopyWith(
          _$ModifierItemImpl value, $Res Function(_$ModifierItemImpl) then) =
      __$$ModifierItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String nameEn, String nameAr, double price});
}

/// @nodoc
class __$$ModifierItemImplCopyWithImpl<$Res>
    extends _$ModifierItemCopyWithImpl<$Res, _$ModifierItemImpl>
    implements _$$ModifierItemImplCopyWith<$Res> {
  __$$ModifierItemImplCopyWithImpl(
      _$ModifierItemImpl _value, $Res Function(_$ModifierItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of ModifierItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nameEn = null,
    Object? nameAr = null,
    Object? price = null,
  }) {
    return _then(_$ModifierItemImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      nameEn: null == nameEn
          ? _value.nameEn
          : nameEn // ignore: cast_nullable_to_non_nullable
              as String,
      nameAr: null == nameAr
          ? _value.nameAr
          : nameAr // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ModifierItemImpl implements _ModifierItem {
  const _$ModifierItemImpl(
      {required this.id,
      required this.nameEn,
      required this.nameAr,
      required this.price});

  factory _$ModifierItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$ModifierItemImplFromJson(json);

  @override
  final String id;
  @override
  final String nameEn;
  @override
  final String nameAr;
  @override
  final double price;

  @override
  String toString() {
    return 'ModifierItem(id: $id, nameEn: $nameEn, nameAr: $nameAr, price: $price)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ModifierItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nameEn, nameEn) || other.nameEn == nameEn) &&
            (identical(other.nameAr, nameAr) || other.nameAr == nameAr) &&
            (identical(other.price, price) || other.price == price));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, nameEn, nameAr, price);

  /// Create a copy of ModifierItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ModifierItemImplCopyWith<_$ModifierItemImpl> get copyWith =>
      __$$ModifierItemImplCopyWithImpl<_$ModifierItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ModifierItemImplToJson(
      this,
    );
  }
}

abstract class _ModifierItem implements ModifierItem {
  const factory _ModifierItem(
      {required final String id,
      required final String nameEn,
      required final String nameAr,
      required final double price}) = _$ModifierItemImpl;

  factory _ModifierItem.fromJson(Map<String, dynamic> json) =
      _$ModifierItemImpl.fromJson;

  @override
  String get id;
  @override
  String get nameEn;
  @override
  String get nameAr;
  @override
  double get price;

  /// Create a copy of ModifierItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ModifierItemImplCopyWith<_$ModifierItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ModifierGroup _$ModifierGroupFromJson(Map<String, dynamic> json) {
  return _ModifierGroup.fromJson(json);
}

/// @nodoc
mixin _$ModifierGroup {
  String get id => throw _privateConstructorUsedError;
  String get nameEn => throw _privateConstructorUsedError;
  String get nameAr => throw _privateConstructorUsedError;
  String get selectionType =>
      throw _privateConstructorUsedError; // SINGLE, MULTIPLE
  int get minSelection => throw _privateConstructorUsedError;
  int get maxSelection => throw _privateConstructorUsedError;
  List<ModifierItem> get items => throw _privateConstructorUsedError;

  /// Serializes this ModifierGroup to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ModifierGroup
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ModifierGroupCopyWith<ModifierGroup> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ModifierGroupCopyWith<$Res> {
  factory $ModifierGroupCopyWith(
          ModifierGroup value, $Res Function(ModifierGroup) then) =
      _$ModifierGroupCopyWithImpl<$Res, ModifierGroup>;
  @useResult
  $Res call(
      {String id,
      String nameEn,
      String nameAr,
      String selectionType,
      int minSelection,
      int maxSelection,
      List<ModifierItem> items});
}

/// @nodoc
class _$ModifierGroupCopyWithImpl<$Res, $Val extends ModifierGroup>
    implements $ModifierGroupCopyWith<$Res> {
  _$ModifierGroupCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ModifierGroup
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nameEn = null,
    Object? nameAr = null,
    Object? selectionType = null,
    Object? minSelection = null,
    Object? maxSelection = null,
    Object? items = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      nameEn: null == nameEn
          ? _value.nameEn
          : nameEn // ignore: cast_nullable_to_non_nullable
              as String,
      nameAr: null == nameAr
          ? _value.nameAr
          : nameAr // ignore: cast_nullable_to_non_nullable
              as String,
      selectionType: null == selectionType
          ? _value.selectionType
          : selectionType // ignore: cast_nullable_to_non_nullable
              as String,
      minSelection: null == minSelection
          ? _value.minSelection
          : minSelection // ignore: cast_nullable_to_non_nullable
              as int,
      maxSelection: null == maxSelection
          ? _value.maxSelection
          : maxSelection // ignore: cast_nullable_to_non_nullable
              as int,
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<ModifierItem>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ModifierGroupImplCopyWith<$Res>
    implements $ModifierGroupCopyWith<$Res> {
  factory _$$ModifierGroupImplCopyWith(
          _$ModifierGroupImpl value, $Res Function(_$ModifierGroupImpl) then) =
      __$$ModifierGroupImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String nameEn,
      String nameAr,
      String selectionType,
      int minSelection,
      int maxSelection,
      List<ModifierItem> items});
}

/// @nodoc
class __$$ModifierGroupImplCopyWithImpl<$Res>
    extends _$ModifierGroupCopyWithImpl<$Res, _$ModifierGroupImpl>
    implements _$$ModifierGroupImplCopyWith<$Res> {
  __$$ModifierGroupImplCopyWithImpl(
      _$ModifierGroupImpl _value, $Res Function(_$ModifierGroupImpl) _then)
      : super(_value, _then);

  /// Create a copy of ModifierGroup
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nameEn = null,
    Object? nameAr = null,
    Object? selectionType = null,
    Object? minSelection = null,
    Object? maxSelection = null,
    Object? items = null,
  }) {
    return _then(_$ModifierGroupImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      nameEn: null == nameEn
          ? _value.nameEn
          : nameEn // ignore: cast_nullable_to_non_nullable
              as String,
      nameAr: null == nameAr
          ? _value.nameAr
          : nameAr // ignore: cast_nullable_to_non_nullable
              as String,
      selectionType: null == selectionType
          ? _value.selectionType
          : selectionType // ignore: cast_nullable_to_non_nullable
              as String,
      minSelection: null == minSelection
          ? _value.minSelection
          : minSelection // ignore: cast_nullable_to_non_nullable
              as int,
      maxSelection: null == maxSelection
          ? _value.maxSelection
          : maxSelection // ignore: cast_nullable_to_non_nullable
              as int,
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<ModifierItem>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ModifierGroupImpl implements _ModifierGroup {
  const _$ModifierGroupImpl(
      {required this.id,
      required this.nameEn,
      required this.nameAr,
      this.selectionType = 'SINGLE',
      this.minSelection = 0,
      this.maxSelection = 1,
      final List<ModifierItem> items = const []})
      : _items = items;

  factory _$ModifierGroupImpl.fromJson(Map<String, dynamic> json) =>
      _$$ModifierGroupImplFromJson(json);

  @override
  final String id;
  @override
  final String nameEn;
  @override
  final String nameAr;
  @override
  @JsonKey()
  final String selectionType;
// SINGLE, MULTIPLE
  @override
  @JsonKey()
  final int minSelection;
  @override
  @JsonKey()
  final int maxSelection;
  final List<ModifierItem> _items;
  @override
  @JsonKey()
  List<ModifierItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  String toString() {
    return 'ModifierGroup(id: $id, nameEn: $nameEn, nameAr: $nameAr, selectionType: $selectionType, minSelection: $minSelection, maxSelection: $maxSelection, items: $items)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ModifierGroupImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nameEn, nameEn) || other.nameEn == nameEn) &&
            (identical(other.nameAr, nameAr) || other.nameAr == nameAr) &&
            (identical(other.selectionType, selectionType) ||
                other.selectionType == selectionType) &&
            (identical(other.minSelection, minSelection) ||
                other.minSelection == minSelection) &&
            (identical(other.maxSelection, maxSelection) ||
                other.maxSelection == maxSelection) &&
            const DeepCollectionEquality().equals(other._items, _items));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      nameEn,
      nameAr,
      selectionType,
      minSelection,
      maxSelection,
      const DeepCollectionEquality().hash(_items));

  /// Create a copy of ModifierGroup
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ModifierGroupImplCopyWith<_$ModifierGroupImpl> get copyWith =>
      __$$ModifierGroupImplCopyWithImpl<_$ModifierGroupImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ModifierGroupImplToJson(
      this,
    );
  }
}

abstract class _ModifierGroup implements ModifierGroup {
  const factory _ModifierGroup(
      {required final String id,
      required final String nameEn,
      required final String nameAr,
      final String selectionType,
      final int minSelection,
      final int maxSelection,
      final List<ModifierItem> items}) = _$ModifierGroupImpl;

  factory _ModifierGroup.fromJson(Map<String, dynamic> json) =
      _$ModifierGroupImpl.fromJson;

  @override
  String get id;
  @override
  String get nameEn;
  @override
  String get nameAr;
  @override
  String get selectionType; // SINGLE, MULTIPLE
  @override
  int get minSelection;
  @override
  int get maxSelection;
  @override
  List<ModifierItem> get items;

  /// Create a copy of ModifierGroup
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ModifierGroupImplCopyWith<_$ModifierGroupImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
