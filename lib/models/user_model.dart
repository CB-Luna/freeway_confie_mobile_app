class User {
  final String username;
  final String fullName;
  final String policyNumber;
  final String? policyUsaState;
  final DateTime nextPayment;
  final String policyType;
  final int customerId; // Añadido para poder hacer la llamada a la API
  final String? email; // Añadido para información de contacto
  final String? phone; // Añadido para información de contacto
  final String? avatar; // URL de la imagen de avatar del usuario
  final String?
      languageCode; // Código de idioma del usuario (ej: 'en_US', 'es_MX')
  final String street;
  final String zipCode;
  final String city;
  final String state;
  final String? carrierName;

  User({
    required this.username,
    required this.fullName,
    required this.policyNumber,
    required this.nextPayment,
    required this.policyType,
    required this.customerId,
    required this.street,
    required this.zipCode,
    required this.city,
    required this.state,
    this.policyUsaState,
    this.email,
    this.phone,
    this.avatar,
    this.languageCode,
    this.carrierName,
  });
}
