import 'package:equatable/equatable.dart';

class Warehouse extends Equatable {
  final String id;
  final String name;
  final String? address;
  final bool isMain;

  const Warehouse({
    required this.id,
    required this.name,
    this.address,
    this.isMain = false,
  });

  factory Warehouse.fromJson(Map<String, dynamic> json) {
    return Warehouse(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      isMain: json['isMain'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'isMain': isMain,
    };
  }

  @override
  List<Object?> get props => [id, name, address, isMain];
}
