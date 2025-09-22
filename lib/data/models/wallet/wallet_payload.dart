import 'package:freeway_app/data/models/auth/policy_model.dart';
import 'package:freeway_app/models/user_model.dart';

/// Modelo para la carga útil que se enviará a los servicios de wallet
class WalletPayload {
  final Applicant applicant;
  final Policy policy;
  final List<Driver> drivers;
  final List<Vehicle> vehicles;
  final SystemConfig systemConfig;

  WalletPayload({
    required this.applicant,
    required this.policy,
    required this.drivers,
    required this.vehicles,
    required this.systemConfig,
  });

  /// Crear una carga útil desde el modelo de usuario y póliza
  factory WalletPayload.fromUserAndPolicy(User user, PolicyModel policyModel) {
    return WalletPayload(
      applicant: Applicant(
        firstName: user.firstName,
        middleName: '',
        lastName: user.lastName,
        address: Address(
          street: user.street,
          streetNumber: '',
          aptNumber: '',
          city: user.city,
          state: user.state,
          zip: user.zipCode,
          zip4: '',
          county: '',
          country: '',
        ),
      ),
      policy: Policy(
        policyID: policyModel.policyId,
        policyNumber: policyModel.policyNumber,
        effectiveDate: policyModel.effectiveDate,
        term: '6', // Valor por defecto ya que no existe en PolicyModel
        carrierInfo: CarrierInfo(
          carrierName: policyModel.carrierName,
          programName: policyModel.programName,
          carrierReference: '',
          carrierPhone: '',
        ),
        expireDate: policyModel.expirationDate,
        nextPaymentDueDate: policyModel.nextPaymentDate,
      ),
      drivers: [
        Driver(
          firstName: user.firstName,
          middleName: '',
          lastName: user.lastName,
        ),
      ],
      vehicles: [], // No hay acceso a vehículos en el modelo actual
      systemConfig: SystemConfig(
        systemName: 'Triton',
        source: 'MobileApp',
        attributes: null,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Applicant': applicant.toJson(),
      'Policy': policy.toJson(),
      'Drivers': drivers.map((d) => d.toJson()).toList(),
      'Vehicles': vehicles.map((v) => v.toJson()).toList(),
      'SystemConfig': systemConfig.toJson(),
    };
  }
}

class Applicant {
  final String firstName;
  final String middleName;
  final String lastName;
  final Address address;

  Applicant({
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'FirstName': firstName,
      'MiddleName': middleName,
      'LastName': lastName,
      'Address': address.toJson(),
    };
  }
}

class Address {
  final String street;
  final String streetNumber;
  final String aptNumber;
  final String city;
  final String state;
  final String zip;
  final String zip4;
  final String county;
  final String country;

  Address({
    required this.street,
    required this.streetNumber,
    required this.aptNumber,
    required this.city,
    required this.state,
    required this.zip,
    required this.zip4,
    required this.county,
    required this.country,
  });

  Map<String, dynamic> toJson() {
    return {
      'Street': street,
      'StreetNumber': streetNumber,
      'AptNumber': aptNumber,
      'City': city,
      'State': state,
      'Zip': zip,
      'Zip4': zip4,
      'County': county,
      'Country': country,
    };
  }
}

class Policy {
  final String policyID;
  final String policyNumber;
  final String effectiveDate;
  final String term;
  final CarrierInfo carrierInfo;
  final String expireDate;
  final String? nextPaymentDueDate;

  Policy({
    required this.policyID,
    required this.policyNumber,
    required this.effectiveDate,
    required this.term,
    required this.carrierInfo,
    required this.expireDate,
    this.nextPaymentDueDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'PolicyID': policyID,
      'PolicyNumber': policyNumber,
      'EffectiveDate': effectiveDate,
      'Term': term,
      'CarrierInfo': carrierInfo.toJson(),
      'ExpireDate': expireDate,
      'NextPaymentDueDate': nextPaymentDueDate,
    };
  }
}

class CarrierInfo {
  final String carrierName;
  final String programName;
  final String carrierReference;
  final String carrierPhone;

  CarrierInfo({
    required this.carrierName,
    required this.programName,
    required this.carrierReference,
    required this.carrierPhone,
  });

  Map<String, dynamic> toJson() {
    return {
      'CarrierName': carrierName,
      'ProgramName': programName,
      'CarrierReference': carrierReference,
      'CarrierPhone': carrierPhone,
    };
  }
}

class Driver {
  final String firstName;
  final String middleName;
  final String lastName;

  Driver({
    required this.firstName,
    required this.middleName,
    required this.lastName,
  });

  Map<String, dynamic> toJson() {
    return {
      'FirstName': firstName,
      'MiddleName': middleName,
      'LastName': lastName,
    };
  }
}

class Vehicle {
  final int year;
  final String make;
  final String model;
  final String vin;

  Vehicle({
    required this.year,
    required this.make,
    required this.model,
    required this.vin,
  });

  Map<String, dynamic> toJson() {
    return {
      'Year': year,
      'Make': make,
      'Model': model,
      'Vin': vin,
    };
  }
}

class SystemConfig {
  final String systemName;
  final String source;
  final dynamic attributes;

  SystemConfig({
    required this.systemName,
    required this.source,
    this.attributes,
  });

  Map<String, dynamic> toJson() {
    return {
      'SystemName': systemName,
      'Source': source,
      'Attributes': attributes,
    };
  }
}

/// Modelo para la respuesta de los servicios de wallet
class WalletResponse {
  final int passId;
  final int requestId;
  final String passType;
  final dynamic passData;

  WalletResponse({
    required this.passId,
    required this.requestId,
    required this.passType,
    required this.passData,
  });

  factory WalletResponse.fromJson(Map<String, dynamic> json) {
    return WalletResponse(
      passId: json['passId'],
      requestId: json['requestId'],
      passType: json['passType'],
      passData: json['passData'],
    );
  }
}

/// Modelo específico para la respuesta de Apple Wallet
class AppleWalletResponse extends WalletResponse {
  final ApplePassData applePassData;

  AppleWalletResponse({
    required super.passId,
    required super.requestId,
    required super.passType,
    required this.applePassData,
  }) : super(
          passData: applePassData,
        );

  factory AppleWalletResponse.fromJson(Map<String, dynamic> json) {
    return AppleWalletResponse(
      passId: json['passId'],
      requestId: json['requestId'],
      passType: json['passType'],
      applePassData: ApplePassData.fromJson(json['passData']),
    );
  }
}

class ApplePassData {
  final String fileContents;
  final String contentType;
  final String? fileDownloadName;
  final dynamic lastModified;
  final dynamic entityTag;
  final bool enableRangeProcessing;

  ApplePassData({
    required this.fileContents,
    required this.contentType,
    required this.enableRangeProcessing,
    this.fileDownloadName,
    this.lastModified,
    this.entityTag,
  });

  factory ApplePassData.fromJson(Map<String, dynamic> json) {
    return ApplePassData(
      fileContents: json['fileContents'],
      contentType: json['contentType'],
      fileDownloadName: json['fileDownloadName'],
      lastModified: json['lastModified'],
      entityTag: json['entityTag'],
      enableRangeProcessing: json['enableRangeProcessing'] ?? false,
    );
  }
}

/// Modelo específico para la respuesta de Google Wallet
class GoogleWalletResponse extends WalletResponse {
  final String googlePassUrl;

  GoogleWalletResponse({
    required super.passId,
    required super.requestId,
    required super.passType,
    required this.googlePassUrl,
  }) : super(
          passData: googlePassUrl,
        );

  factory GoogleWalletResponse.fromJson(Map<String, dynamic> json) {
    return GoogleWalletResponse(
      passId: json['passId'],
      requestId: json['requestId'],
      passType: json['passType'],
      googlePassUrl: json['passData'],
    );
  }
}
