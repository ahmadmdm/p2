class InventoryLog {
  final String id;
  final String ingredientId;
  final String? ingredientName;
  final String? warehouseId;
  final String? warehouseName;
  final double quantityChange;
  final double? oldQuantity;
  final double? newQuantity;
  final String reason;
  final String? notes;
  final String? referenceId;
  final DateTime createdAt;

  InventoryLog({
    required this.id,
    required this.ingredientId,
    this.ingredientName,
    this.warehouseId,
    this.warehouseName,
    required this.quantityChange,
    this.oldQuantity,
    this.newQuantity,
    required this.reason,
    this.notes,
    this.referenceId,
    required this.createdAt,
  });

  factory InventoryLog.fromJson(Map<String, dynamic> json) {
    return InventoryLog(
      id: json['id'],
      ingredientId: json['ingredient']['id'],
      ingredientName: json['ingredient']['name'],
      warehouseId: json['warehouse']?['id'],
      warehouseName: json['warehouse']?['name'],
      quantityChange: (json['quantityChange'] as num).toDouble(),
      oldQuantity: (json['oldQuantity'] as num?)?.toDouble(),
      newQuantity: (json['newQuantity'] as num?)?.toDouble(),
      reason: json['reason'],
      notes: json['notes'],
      referenceId: json['referenceId'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
