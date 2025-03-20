class OfficeRequest {
  final String zipCode;
  final int count;

  OfficeRequest({
    required this.zipCode,
    this.count = 5,
  });

  Map<String, dynamic> toJson() {
    return {
      'zc': zipCode,
      'count': count,
    };
  }
}
