import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:freeway_app/data/services/google_wallet_service.dart';
import 'package:freeway_app/locatordevice/locator_device_module.dart';
import 'package:freeway_app/models/user_model.dart';
import 'package:freeway_app/pages/add_insurance.dart';
import 'package:freeway_app/providers/auth_provider.dart';
import 'package:freeway_app/utils/app_localizations_extension.dart';
import 'package:freeway_app/utils/id_card_printer.dart';
import 'package:freeway_app/utils/menu/circle_nav_bar.dart';
import 'package:freeway_app/widgets/id_card/id_card_widget.dart';
import 'package:freeway_app/widgets/theme/app_theme.dart';
import 'package:provider/provider.dart';

class IdCardPage extends StatefulWidget {
  const IdCardPage({super.key});

  @override
  State<IdCardPage> createState() => _IdCardPageState();
}

class _IdCardPageState extends State<IdCardPage> {
  int _selectedIndex = 0;
  final GlobalKey _idCardKey = GlobalKey();
  bool _isProcessingRequest = false; // Bandera para evitar múltiples llamadas

  // Servicio de Google Wallet
  final GoogleWalletService _googleWalletService = GoogleWalletService();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    // Si no hay usuario autenticado, mostrar un mensaje
    if (user == null) {
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
            style: const TextStyle(color: AppTheme.white),
          ),
        ),
        body: Center(
          child: Text(
            context.translate('common.notAuthenticated'),
            style: const TextStyle(fontSize: 18),
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
                    fontSize: 20,
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
                  fontSize: 16,
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
        child: Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Calcular el ancho disponible para la tarjeta
                  final availableWidth = constraints.maxWidth;

                  // Determinar el tamaño de la tarjeta basado en el espacio disponible
                  // Mantener la relación de aspecto original (309:430)
                  final cardWidth =
                      availableWidth > 350 ? 309.0 : availableWidth * 0.85;
                  final cardHeight = cardWidth * (450 / 309);

                  // Ya no necesitamos calcular el espacio superior
                  // porque estamos usando un Column con Expanded para centrar

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Fila superior con botones de acción y Apple Wallet
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Botón de Apple Wallet (solo en iOS)
                            if (Platform.isIOS)
                              GestureDetector(
                                onTap: () {
                                  // TODO: Implementar funcionalidad de Apple Wallet
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Adding to Apple Wallet...'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                                child: Image.asset(
                                  'assets/home/idcardicons/add_apple_wallet.png',
                                  width: 146,
                                  height: 45,
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
                                  width: 146,
                                  height: 45,
                                  fit: BoxFit.contain,
                                ),
                              ),

                            // Botones de acción (descarga e impresión)
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.download_outlined,
                                    color: AppTheme.getIconColor(context),
                                  ),
                                  onPressed: () {
                                    // Evitar múltiples llamadas mientras se procesa una solicitud
                                    if (!_isProcessingRequest) {
                                      _handleSaveIdCard(context, user);
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
                                      _handlePrintIdCard(context, user);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Espacio flexible para centrar la tarjeta verticalmente
                      Center(
                        child: SizedBox(
                          width: cardWidth,
                          height: cardHeight,
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: RepaintBoundary(
                              key: _idCardKey,
                              child: IdCardWidget(
                                user: user,
                                width: cardWidth,
                                height: cardHeight,
                                policyNumber: user.policyNumber,
                                carrier: user.carrierName,
                                state: user.policyUsaState,
                                // Ejemplo de fechas, en una implementación real vendrían de la API
                                effectiveDate: DateTime(2023, 6, 18),
                                expirationDate: DateTime(2026, 12, 18),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Texto de aviso legal en la parte inferior
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 20.0,
                        ),
                        child: Text(
                          context.translate('idCard.notProofOfCoverage'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppTheme.getTextGreyColor(context),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
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
  void _handlePrintIdCard(BuildContext context, User user) {
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
  void _handleSaveIdCard(BuildContext context, User user) {
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
}
