import 'dart:convert';
import 'dart:io' show Platform;

import 'package:apple_passkit/apple_passkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:freeway_app/data/models/auth/policy_model.dart';
// Importación eliminada: apple_wallet_service.dart
import 'package:freeway_app/data/services/google_wallet_service.dart';
import 'package:freeway_app/locatordevice/locator_device_module.dart';
import 'package:freeway_app/models/user_model.dart';
import 'package:freeway_app/pages/add_insurance.dart';
import 'package:freeway_app/providers/auth_provider.dart';
import 'package:freeway_app/utils/app_localizations_extension.dart';
import 'package:freeway_app/utils/id_card_printer.dart';
import 'package:freeway_app/utils/menu/circle_nav_bar.dart';
import 'package:freeway_app/utils/responsive_font_sizes.dart';
import 'package:freeway_app/widgets/id_card/id_card_widget.dart';
import 'package:freeway_app/widgets/theme/app_theme.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class IdCardPage extends StatefulWidget {
  const IdCardPage({
    required this.policy,
    super.key,
  });

  final PolicyModel policy;

  @override
  State<IdCardPage> createState() => _IdCardPageState();
}

class _IdCardPageState extends State<IdCardPage> {
  int _selectedIndex = 0;
  final GlobalKey _idCardKey = GlobalKey();
  bool _isProcessingRequest = false; // Bandera para evitar múltiples llamadas

  // Servicios de Wallet
  final GoogleWalletService _googleWalletService = GoogleWalletService();
  // El servicio de Apple Wallet se usa en el método _handleAddToAppleWallet
  final _applePasskitPlugin = ApplePassKit();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final token = authProvider.authToken;

    final screenWidth = MediaQuery.of(context).size.width;

    // Si no hay usuario autenticado, mostrar un mensaje
    if (user == null || token == null) {
      return Scaffold(
        backgroundColor: AppTheme.getBackgroundHeaderColor(context),
        appBar: AppBar(
          backgroundColor: AppTheme.getBackgroundHeaderColor(context),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppTheme.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            context.translate('idCard.title'),
            style: const TextStyle(
              color: AppTheme.white,
              fontSize: 22,
            ),
          ),
        ),
        body: Center(
          child: Text(
            context.translate('common.notAuthenticated'),
            style: TextStyle(
              fontSize: responsiveFontSizes.titleMedium(context),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundHeaderColor(context),
      appBar: AppBar(
        backgroundColor: AppTheme.getBackgroundHeaderColor(context),
        leading: Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: AppTheme.white,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        leadingWidth: 56,
        title: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  context.translate('idCard.title'),
                  style: const TextStyle(
                    color: AppTheme.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Positioned(
              left: 0,
              child: Text(
                context.translate('idCard.back'),
                style: const TextStyle(
                  color: AppTheme.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.getBackgroundColor(context),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 3),
              blurRadius: 8,
              spreadRadius: -1,
              color: AppTheme.getBoxShadowColor(context),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Calcular el ancho disponible para la tarjeta
            final availableWidth = constraints.maxWidth;
            final availableHeight = constraints.maxHeight;

            // Determinar el ancho de la tarjeta basado en el espacio disponible
            final cardWidth = availableWidth * 0.85;

            return SingleChildScrollView(
              controller: ScrollController(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: availableHeight,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Fila superior con botones de acción y Apple Wallet
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 16.0,
                        ),
                        child: SizedBox(
                          width: screenWidth,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Botón de Apple Wallet (solo en iOS)
                              if (Platform.isIOS)
                                GestureDetector(
                                  onTap: () {
                                    _handleAddToAppleWallet(context, user);
                                  },
                                  child: Image.asset(
                                    'assets/home/idcardicons/add_apple_wallet.png',
                                    width: screenWidth * 0.4,
                                    height: screenWidth * 0.1,
                                    fit: BoxFit.contain,
                                  ),
                                ),

                              // Botón de Google Wallet (solo en Android)
                              if (Platform.isAndroid)
                                GestureDetector(
                                  onTap: () {
                                    if (!_isProcessingRequest) {
                                      _handleAddToGoogleWallet(context, user);
                                    }
                                  },
                                  child: Image.asset(
                                    'assets/home/idcardicons/add_google_wallet.png',
                                    width: screenWidth * 0.4,
                                    height: screenWidth * 0.1,
                                    fit: BoxFit.contain,
                                  ),
                                ),

                              // Botones de acción (descarga e impresión)
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.share_outlined,
                                      color: AppTheme.getIconColor(context),
                                    ),
                                    onPressed: () {
                                      // Evitar múltiples llamadas mientras se procesa una solicitud
                                      if (!_isProcessingRequest) {
                                        _handleSaveIdCard(
                                          context,
                                          user,
                                          widget.policy,
                                        );
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.print_outlined,
                                      color: AppTheme.getIconColor(context),
                                    ),
                                    onPressed: () {
                                      // Evitar múltiples llamadas mientras se procesa una solicitud
                                      if (!_isProcessingRequest) {
                                        _handlePrintIdCard(
                                          context,
                                          user,
                                          widget.policy,
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Espacio flexible para centrar la tarjeta verticalmente
                      Center(
                        child: SizedBox(
                          width: cardWidth,
                          child: RepaintBoundary(
                            key: _idCardKey,
                            child: IdCardWidget(
                              user: user,
                              width: cardWidth,
                              // Usar la póliza activa del usuario o crear una nueva
                              policy: widget.policy,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Transform.translate(
        offset: const Offset(0, 0),
        child: CircleNavBar(
          selectedPos: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });

            switch (index) {
              case 1:
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddInsurancePage(),
                  ),
                ).then((_) => setState(() => _selectedIndex = 0));
                break;
              case 2:
                LocatorDeviceModule.navigateToLocationView(context);
                break;
            }
          },
          tabItems: [
            TabData(
              Icons.home_outlined,
              context.translate('home.navigation.myProducts'),
            ),
            TabData(
              Icons.verified_user_outlined,
              context.translate('home.navigation.addInsurance'),
            ),
            TabData(
              Icons.location_on_outlined,
              context.translate('home.navigation.location'),
            ),
          ],
        ),
      ),
    );
  }

  // Método para manejar la impresión de la tarjeta de ID
  void _handlePrintIdCard(BuildContext context, User user, PolicyModel policy) {
    setState(() {
      _isProcessingRequest = true;
    });

    // Mostrar un indicador de progreso
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.translate('idCard.preparingForPrint')),
        duration: const Duration(seconds: 2),
      ),
    );

    // Utilizar la clase IdCardPrinter para imprimir la tarjeta
    IdCardPrinter.printIdCard(
      context,
      _idCardKey,
      user,
      policy,
      (success) {
        // Callback cuando se completa la operación
        if (mounted) {
          setState(() {
            _isProcessingRequest = false;
          });

          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.translate('idCard.printCompleted')),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.translate('idCard.printError')),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      },
    );
  }

  // Método para manejar el guardado de la tarjeta de ID
  void _handleSaveIdCard(BuildContext context, User user, PolicyModel policy) {
    // Mostrar un diálogo para elegir el formato
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(context.translate('idCard.chooseFormat')),
          content: Text(
            context.translate('idCard.chooseFormatDescription')
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _saveIdCardWithFormat(context, user, policy, false); // PDF
              },
              child: Text(context.translate('idCard.formatPDF')),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _saveIdCardWithFormat(context, user, policy, true); // Imagen
              },
              child: Text(context.translate('idCard.formatImage')),
            ),
          ],
        );
      },
    );
  }

  // Método auxiliar para guardar la tarjeta en el formato seleccionado
  void _saveIdCardWithFormat(BuildContext context, User user, PolicyModel policy, bool asImage) {
    setState(() {
      _isProcessingRequest = true;
    });

    // Mostrar un indicador de progreso
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.translate('idCard.preparingForDownload')),
        duration: const Duration(seconds: 2),
      ),
    );

    // Utilizar la clase IdCardPrinter para guardar la tarjeta
    IdCardPrinter.saveIdCard(
      context,
      _idCardKey,
      user,
      policy,
      (success) {
        // Callback cuando se completa la operación
        if (mounted) {
          setState(() {
            _isProcessingRequest = false;
          });

          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.translate('idCard.downloadCompleted')),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.translate('idCard.downloadCancelled')),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      },
      asImage: asImage,
    );
  }

  // Método para manejar la adición a Google Wallet
  void _handleAddToGoogleWallet(BuildContext context, User user) {
    setState(() {
      _isProcessingRequest = true;
    });

    // Mostrar un indicador de progreso
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.translate('idCard.addedToGoogleWallet')),
        duration: const Duration(seconds: 2),
      ),
    );

    // Usar el servicio de Google Wallet
    _googleWalletService.addInsuranceCardToGoogleWallet(
      context: context,
      user: user,
      policy: widget.policy,
      onSuccess: () {
        if (mounted) {
          setState(() {
            _isProcessingRequest = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.translate('idCard.addedToGoogleWallet')),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      onCanceled: () {
        if (mounted) {
          setState(() {
            _isProcessingRequest = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.translate('idCard.cancelToGoogleWallet')),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _isProcessingRequest = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $error'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
    );
  }

  // Constantes para la configuración del pase
  static const String teamIdentifier =
      'RMQ3LJU296'; // Team ID real de la cuenta de desarrollador
  static const String passTypeIdentifier =
      'pass.com.test.confieapp'; // Debe ser un Pass Type ID válido registrado en tu cuenta

  void _handleAddToAppleWallet(BuildContext context, User user) async {
    setState(() {
      _isProcessingRequest = true;
    });

    // Mostrar un indicador de progreso
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.translate('idCard.addingToAppleWallet')),
        duration: const Duration(seconds: 2),
      ),
    );

    try {
      // Para iOS Simulator, necesitamos usar una IP especial o la IP local real
      // En este caso, usaremos el archivo estático para pruebas

      // Comentamos la creación de datos para el pase dinámico ya que no los usaremos por ahora
      // Esta estructura servirá como referencia para cuando implementemos la conexión al servidor
      /* 
      final Map<String, dynamic> passData = {
        "passType": "generic", // Tipo de pase: generic, boardingPass, eventTicket, etc.
        "serialNumber": "user-${user.customerId}",
        "description": "Freeway Insurance Card",
        "organizationName": "Freeway Insurance",
        "teamIdentifier": "A1B2C3D4E5", // Debe coincidir con tu certificado
        "passTypeIdentifier": "pass.com.freeway.insurance", // Debe coincidir con tu certificado
        "data": {
          "headerFields": [
            {
              "key": "policy",
              "label": "POLICY",
              "value": user.policyNumber ?? "N/A"
            }
          ],
          "primaryFields": [
            {
              "key": "name",
              "label": "INSURED",
              "value": user.fullName
            }
          ],
          "secondaryFields": [
            {
              "key": "carrier",
              "label": "CARRIER",
              "value": user.carrierName != null ? user.carrierName : "Freeway Insurance"
            },
            {
              "key": "state",
              "label": "STATE",
              "value": user.state
            }
          ],
          "auxiliaryFields": [
            {
              "key": "expiration",
              "label": "EXPIRATION",
              "value": user.nextPayment.toString().split(' ')[0]
            }
          ],
          "backFields": [
            {
              "key": "terms",
              "label": "TERMS AND CONDITIONS",
              "value": "This is a digital representation of your insurance card. Not a proof of coverage."
            }
          ]
        }
      };
      */

      // Para pruebas en simulador, podemos usar dos enfoques:
      // 1. Conectarnos al servidor local y obtener el pase dinámicamente
      // 2. Usar el archivo estático como fallback

      try {
        // Intentar conectar con el servidor de producción
        debugPrint(
          'Intentando conectar con el servidor en https://cbl.virtalus.cbluna-dev.com/generate-pass',
        );

        // Crear los datos para el pase dinámico según la estructura que espera el servidor
        final Map<String, dynamic> passData = {
          'passType':
              'generic', // Usamos la nueva plantilla genérica sin icono de avión
          'serialNumber': 'user-${user.customerId}',
          'description': 'Freeway Insurance Card',
          'organizationName': 'Freeway Insurance',
          'teamIdentifier':
              teamIdentifier, // Team ID real de la cuenta de desarrollador
          'passTypeIdentifier':
              passTypeIdentifier, // Debe coincidir con tu certificado
          'data': {
            'headerFields': [],
            'primaryFields': [
              {
                'key': 'name',
                'label': 'NAMED INSURED',
                'value': widget.policy.insuredName,
              }
            ],
            'secondaryFields': [
              {
                'key': 'carrier',
                'label': 'CARRIER',
                'value': widget.policy.carrierName,
              },
              {
                'key': 'policy',
                'label': 'POLICY NUMBER',
                'value': widget.policy.policyNumber,
              }
            ],
            'auxiliaryFields': [
              {
                'key': 'state',
                'label': 'STATE',
                'value': user.state,
              },
              {
                'key': 'effectiveDate',
                'label': 'EFFECTIVE DATE',
                'value': widget.policy.effectiveDate.isNotEmpty
                    ? widget.policy.effectiveDate
                    : DateTime.now().toString().split(' ')[0],
              },
              {
                'key': 'expiration',
                'label': 'EXPIRATION DATE',
                'value': widget.policy.expirationDate,
              }
            ],
            'backFields': [
              {
                'key': 'terms',
                'label': 'TERMS AND CONDITIONS',
                'value':
                    'This is a digital representation of your insurance card. Not a proof of coverage.',
              }
            ],
            // Colores personalizados para el pase - Usando colores que coincidan con la segunda imagen
            'foregroundColor': 'rgb(0, 71, 187)', // Azul para el texto
            'backgroundColor': 'rgb(255, 255, 255)', // Fondo blanco
            'labelColor': 'rgb(128, 128, 128)', // Gris para las etiquetas
          },
        };

        Uint8List pkPassData;

        try {
          // Usar el endpoint de producción en lugar del servidor local
          const String serverUrl =
              'https://cbl.virtalus.cbluna-dev.com/generate-pass';

          debugPrint('Conectando con el servidor en: $serverUrl');
          debugPrint('Datos del pase: ${jsonEncode(passData)}');

          // Hacer la llamada POST al servidor local
          final response = await http.post(
            Uri.parse(serverUrl),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode(passData),
          );

          debugPrint(
            'Respuesta del servidor: ${response.statusCode}, ${response.reasonPhrase}',
          );

          if (response.statusCode == 200) {
            // Convertir la respuesta a Uint8List
            pkPassData = response.bodyBytes;
            debugPrint('Archivo .pkpass recibido correctamente del servidor');
          } else {
            // Si hay un error, usar el archivo estático como fallback
            debugPrint(
              'Error al obtener el archivo .pkpass del servidor: ${response.statusCode}',
            );
            debugPrint('Usando archivo estático como fallback');
            pkPassData = await getFlightPass();
          }
        } catch (serverError) {
          // Si hay un error de conexión, usar el archivo estático como fallback
          debugPrint('Error de conexión con el servidor: $serverError');
          debugPrint('Usando archivo estático como fallback');
          pkPassData = await getFlightPass();
        }

        // Añadir el pase a Apple Wallet
        await _applePasskitPlugin.addPass(pkPassData);

        if (!context.mounted) return;
        setState(() {
          _isProcessingRequest = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.translate('idCard.addedToAppleWallet')),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } catch (serverError) {
        debugPrint('Error al conectar con el servidor local: $serverError');

        // Mostrar error
        if (mounted) {
          setState(() {
            _isProcessingRequest = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $serverError'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error general al añadir pase a Apple Wallet: $e');

      if (mounted) {
        setState(() {
          _isProcessingRequest = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<Uint8List> getFlightPass() async {
    final pkPass = await rootBundle.load('assets/Coupon.pkpass');
    return pkPass.buffer
        .asUint8List(pkPass.offsetInBytes, pkPass.lengthInBytes);
  }
}
