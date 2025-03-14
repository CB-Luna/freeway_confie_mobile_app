class OfficeLocation {
  final String id;
  final String name;
  final String address;
  final String secondaryAddress;
  final String reference;
  final double latitude;
  final double longitude;
  final String openHours;
  final String closeHours;
  final double rating;
  final double distanceInMiles;
  final bool isOpen;

  OfficeLocation({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.openHours,
    required this.closeHours,
    this.secondaryAddress = '',
    this.reference = '',
    this.rating = 0.0,
    this.distanceInMiles = 0.0,
    this.isOpen = false,
  });

  factory OfficeLocation.fromJson(Map<String, dynamic> json) {
    return OfficeLocation(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      secondaryAddress: json['secondaryAddress'] ?? '',
      reference: json['reference'] ?? '',
      latitude: json['latitude'],
      longitude: json['longitude'],
      openHours: json['openHours'],
      closeHours: json['closeHours'],
      rating: json['rating'] ?? 0.0,
      distanceInMiles: json['distanceInMiles'] ?? 0.0,
      isOpen: json['isOpen'] ?? false,
    );
  }
}
