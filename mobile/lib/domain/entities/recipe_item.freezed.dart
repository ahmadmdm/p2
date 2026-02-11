// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recipe_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RecipeItem _$RecipeItemFromJson(Map<String, dynamic> json) {
  return _RecipeItem.fromJson(json);
}

/// @nodoc
mixin _$RecipeItem {
  String get id => throw _privateConstructorUsedError;
  String? get productId => throw _privateConstructorUsedError;
  String? get modifierItemId => throw _privateConstructorUsedError;
  Ingredient get ingredient => throw _privateConstructorUsedError;
  double get quantity => throw _privateConstructorUsedError;

  /// Serializes this RecipeItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RecipeItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecipeItemCopyWith<RecipeItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecipeItemCopyWith<$Res> {
  factory $RecipeItemCopyWith(
          RecipeItem value, $Res Function(RecipeItem) then) =
      _$RecipeItemCopyWithImpl<$Res, RecipeItem>;
  @useResult
  $Res call(
      {String id,
      String? productId,
      String? modifierItemId,
      Ingredient ingredient,
      double quantity});

  $IngredientCopyWith<$Res> get ingredient;
}

/// @nodoc
class _$RecipeItemCopyWithImpl<$Res, $Val extends RecipeItem>
    implements $RecipeItemCopyWith<$Res> {
  _$RecipeItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RecipeItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? productId = freezed,
    Object? modifierItemId = freezed,
    Object? ingredient = null,
    Object? quantity = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      productId: freezed == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String?,
      modifierItemId: freezed == modifierItemId
          ? _value.modifierItemId
          : modifierItemId // ignore: cast_nullable_to_non_nullable
              as String?,
      ingredient: null == ingredient
          ? _value.ingredient
          : ingredient // ignore: cast_nullable_to_non_nullable
              as Ingredient,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }

  /// Create a copy of RecipeItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $IngredientCopyWith<$Res> get ingredient {
    return $IngredientCopyWith<$Res>(_value.ingredient, (value) {
      return _then(_value.copyWith(ingredient: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$RecipeItemImplCopyWith<$Res>
    implements $RecipeItemCopyWith<$Res> {
  factory _$$RecipeItemImplCopyWith(
          _$RecipeItemImpl value, $Res Function(_$RecipeItemImpl) then) =
      __$$RecipeItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String? productId,
      String? modifierItemId,
      Ingredient ingredient,
      double quantity});

  @override
  $IngredientCopyWith<$Res> get ingredient;
}

/// @nodoc
class __$$RecipeItemImplCopyWithImpl<$Res>
    extends _$RecipeItemCopyWithImpl<$Res, _$RecipeItemImpl>
    implements _$$RecipeItemImplCopyWith<$Res> {
  __$$RecipeItemImplCopyWithImpl(
      _$RecipeItemImpl _value, $Res Function(_$RecipeItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of RecipeItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? productId = freezed,
    Object? modifierItemId = freezed,
    Object? ingredient = null,
    Object? quantity = null,
  }) {
    return _then(_$RecipeItemImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      productId: freezed == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String?,
      modifierItemId: freezed == modifierItemId
          ? _value.modifierItemId
          : modifierItemId // ignore: cast_nullable_to_non_nullable
              as String?,
      ingredient: null == ingredient
          ? _value.ingredient
          : ingredient // ignore: cast_nullable_to_non_nullable
              as Ingredient,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RecipeItemImpl implements _RecipeItem {
  const _$RecipeItemImpl(
      {required this.id,
      this.productId,
      this.modifierItemId,
      required this.ingredient,
      required this.quantity});

  factory _$RecipeItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecipeItemImplFromJson(json);

  @override
  final String id;
  @override
  final String? productId;
  @override
  final String? modifierItemId;
  @override
  final Ingredient ingredient;
  @override
  final double quantity;

  @override
  String toString() {
    return 'RecipeItem(id: $id, productId: $productId, modifierItemId: $modifierItemId, ingredient: $ingredient, quantity: $quantity)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecipeItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.modifierItemId, modifierItemId) ||
                other.modifierItemId == modifierItemId) &&
            (identical(other.ingredient, ingredient) ||
                other.ingredient == ingredient) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, productId, modifierItemId, ingredient, quantity);

  /// Create a copy of RecipeItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecipeItemImplCopyWith<_$RecipeItemImpl> get copyWith =>
      __$$RecipeItemImplCopyWithImpl<_$RecipeItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RecipeItemImplToJson(
      this,
    );
  }
}

abstract class _RecipeItem implements RecipeItem {
  const factory _RecipeItem(
      {required final String id,
      final String? productId,
      final String? modifierItemId,
      required final Ingredient ingredient,
      required final double quantity}) = _$RecipeItemImpl;

  factory _RecipeItem.fromJson(Map<String, dynamic> json) =
      _$RecipeItemImpl.fromJson;

  @override
  String get id;
  @override
  String? get productId;
  @override
  String? get modifierItemId;
  @override
  Ingredient get ingredient;
  @override
  double get quantity;

  /// Create a copy of RecipeItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecipeItemImplCopyWith<_$RecipeItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
