class OrderModel {
  final int id;
  final String clientName;
  final String pickupAddress;
  final String dropoffAddress;
  final String cargoType;
  final String weight;
  final String volume;
  final String comment;
  final String? mapUrl;
  final String distance;

  const OrderModel({
    this.id = 0,
    this.clientName = '',
    this.pickupAddress = '',
    this.dropoffAddress = '',
    this.cargoType = '',
    this.weight = '',
    this.volume = '',
    this.comment = '',
    this.mapUrl,
    this.distance = '0',
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? 0,
      clientName: json['client_name'] ?? json['first_name'] ?? '',
      pickupAddress: json['from_city'] ?? json['pickup_address'] ?? '',
      dropoffAddress: json['to_city'] ?? json['dropoff_address'] ?? '',
      cargoType: json['cargo_type'] ?? '',
      weight: json['weight_kg'] != null ? '${json['weight_kg']} kg' : '',
      volume: json['volume'] ?? '',
      comment: json['comment'] ?? json['notes'] ?? '',
      mapUrl: json['map_url'],
      distance: json['distance']?.toString() ?? '0',
    );
  }
}
