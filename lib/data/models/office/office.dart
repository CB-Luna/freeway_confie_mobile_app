class Office {
  final int locationId;
  final int organizationId;
  final String name;
  final String streetAddress;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final String phone;
  final String languages;
  final double latitude;
  final double longitude;
  final double distance;

  Office({
    required this.locationId,
    required this.organizationId,
    required this.name,
    required this.streetAddress,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    required this.phone,
    required this.languages,
    required this.latitude,
    required this.longitude,
    required this.distance,
  });

  factory Office.fromJson(Map<String, dynamic> json) {
    return Office(
      locationId: json['location_id'] as int,
      organizationId: json['organization_id'] as int,
      name: json['name'] as String,
      streetAddress: json['street_address'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      postalCode: json['postal_code'] as String,
      country: json['country'] as String,
      phone: json['phone'] as String,
      languages: json['languages'] as String,
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      distance: json['distance'] as double,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location_id': locationId,
      'organization_id': organizationId,
      'name': name,
      'street_address': streetAddress,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      'country': country,
      'phone': phone,
      'languages': languages,
      'latitude': latitude,
      'longitude': longitude,
      'distance': distance,
    };
  }
}
