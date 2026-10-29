class VehicleListResponse {
  final bool? success;
  final List<VehicleModel>? vehicles;

  VehicleListResponse({
    this.success,
    this.vehicles,
  });

  factory VehicleListResponse.fromJson(Map<String, dynamic> json) {
    return VehicleListResponse(
      success: json['success'],
      vehicles: (json['vehicles'] as List?)
          ?.map((e) => VehicleModel.fromJson(e))
          .toList(),
    );
  }
}
class VehicleModel {
  final int? id;
  final String? registrationNo;
  final String? vinChassis;
  final String? engineNumber;
  final String? modelName;
  final String? variantName;
  final String? color;
  final DateTime? purchaseDate;
  final String? dealerName;
  final String? sapVehicleId;
  final bool? isPrimary;
  final DateTime? createdAt;

  VehicleModel({
    this.id,
    this.registrationNo,
    this.vinChassis,
    this.engineNumber,
    this.modelName,
    this.variantName,
    this.color,
    this.purchaseDate,
    this.dealerName,
    this.sapVehicleId,
    this.isPrimary,
    this.createdAt,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'],
      registrationNo: json['registration_no'],
      vinChassis: json['vin_chassis'],
      engineNumber: json['engine_number'],
      modelName: json['model_name'],
      variantName: json['variant_name'],
      color: json['color'],
      purchaseDate: json['purchase_date'] != null
          ? DateTime.tryParse(json['purchase_date'])
          : null,
      dealerName: json['dealer_name'],
      sapVehicleId: json['sap_vehicle_id'],
      isPrimary: json['is_primary'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }
}


