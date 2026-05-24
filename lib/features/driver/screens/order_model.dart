class OrderModel {
  final String id;
  final String clientName;
  final String clientPhone;
  final String pickupAddress;
  final String dropoffAddress;
  final String cargoType;
  final String weight;
  final String volume;
  final String comment;
  final double distance;
  final String? mapUrl;

  OrderModel({
    required this.id,
    required this.clientName,
    required this.clientPhone,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.cargoType,
    required this.weight,
    required this.volume,
    required this.comment,
    required this.distance,
    this.mapUrl,
  });

  // API dan kelgan JSON ma'lumotni modelga o'tkazish
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? '',
      clientName: json['client_name'] ?? 'Noma\'lum',
      clientPhone: json['client_phone'] ?? '',
      pickupAddress: json['pickup_address'] ?? '',
      dropoffAddress: json['dropoff_address'] ?? '',
      cargoType: json['cargo_type'] ?? '',
      weight: json['weight'] ?? '',
      volume: json['volume'] ?? '',
      comment: json['comment'] ?? '',
      distance: (json['distance'] ?? 0).toDouble(),
      mapUrl: json['map_url'],
    );
  }

  // Ma'lumotlarni serverga yuborish uchun (agar kerak bo'lsa)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_name': clientName,
      'client_phone': clientPhone,
      'pickup_address': pickupAddress,
      'dropoff_address': dropoffAddress,
      'cargo_type': cargoType,
      'weight': weight,
      'volume': volume,
      'comment': comment,
      'distance': distance,
      'map_url': mapUrl,
    };
  }
}