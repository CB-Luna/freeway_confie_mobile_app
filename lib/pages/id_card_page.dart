import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:freeway_app/data/models/auth/policy_model.dart';
import 'package:freeway_app/data/services/apple_wallet_service.dart';
import 'package:freeway_app/data/services/google_wallet_service.dart';
import 'package:freeway_app/locatordevice/locator_device_module.dart';
import 'package:freeway_app/models/user_model.dart';
import 'package:freeway_app/pages/add_insurance.dart';
import 'package:freeway_app/providers/auth_provider.dart';
import 'package:freeway_app/utils/app_localizations_extension.dart';
import 'package:freeway_app/utils/id_card_printer.dart';
import 'package:freeway_app/utils/menu/circle_nav_bar.dart';
import 'package:freeway_app/utils/menu/snackbar_help.dart';
import 'package:freeway_app/utils/responsive_font_sizes.dart';
import 'package:freeway_app/widgets/id_card/id_card_widget.dart';
import 'package:freeway_app/widgets/theme/app_theme.dart';
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
  final AppleWalletService _appleWalletService = AppleWalletService();

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
                                    if (!_isProcessingRequest) {
                                      _handleAddToAppleWallet(context, user);
                                    }
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
      bottomNavigationBar: CircleNavBar(
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
    );
  }

  // Método para manejar la impresión de la tarjeta de ID
  void _handlePrintIdCard(BuildContext context, User user, PolicyModel policy) {
    setState(() {
      _isProcessingRequest = true;
    });

    // Mostrar un indicador de progreso
    showAppSnackBar(
      context,
      context.translate('idCard.preparingForPrint'),
      const Duration(seconds: 2),
      backgroundColor: AppTheme.getBlueColor(context),
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
            showAppSnackBar(
              context,
              context.translate('idCard.printCompleted'),
              const Duration(seconds: 2),
              backgroundColor: Colors.green,
            );
          } else {
            showAppSnackBar(
              context,
              context.translate('idCard.printError'),
              const Duration(seconds: 3),
              backgroundColor: Colors.red,
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
            context.translate('idCard.chooseFormatDescription'),
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
  void _saveIdCardWithFormat(
    BuildContext context,
    User user,
    PolicyModel policy,
    bool asImage,
  ) {
    setState(() {
      _isProcessingRequest = true;
    });

    // Mostrar un indicador de progreso
    showAppSnackBar(
      context,
      context.translate('idCard.preparingForDownload'),
      const Duration(seconds: 2),
      backgroundColor: AppTheme.getBlueColor(context),
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
            showAppSnackBar(
              context,
              context.translate('idCard.downloadCompleted'),
              const Duration(seconds: 2),
              backgroundColor: Colors.green,
            );
          } else {
            showAppSnackBar(
              context,
              context.translate('idCard.downloadCancelled'),
              const Duration(seconds: 2),
              backgroundColor: Colors.red,
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

    // Mostrar mensaje de apertura
    showAppSnackBar(
      context,
      context.translate('idCard.openingGoogleWallet'),
      const Duration(seconds: 2),
      backgroundColor: AppTheme.getBlueColor(context),
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
          // No mostramos mensaje porque no sabemos si realmente lo agregó
        }
      },
      onCanceled: () {
        if (mounted) {
          setState(() {
            _isProcessingRequest = false;
          });
          // No mostramos mensaje de cancelación porque el usuario ya lo sabe
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _isProcessingRequest = false;
          });

          showAppSnackBar(
            context,
            'Error: $error',
            const Duration(seconds: 3),
            backgroundColor: Colors.red,
          );
        }
      },
    );
  }

  // Método para manejar la adición a Google Wallet
  void _handleAddToAppleWallet(BuildContext context, User user) {
    setState(() {
      _isProcessingRequest = true;
    });

    // Mostrar mensaje de apertura
    showAppSnackBar(
      context,
      context.translate('idCard.openingAppleWallet'),
      const Duration(seconds: 2),
      backgroundColor: AppTheme.getBlueColor(context),
    );

    // Usar el servicio de Apple Wallet
    _appleWalletService.addInsuranceCardToAppleWallet(
      context: context,
      user: user,
      policy: widget.policy,
      onSuccess: () {
        if (mounted) {
          setState(() {
            _isProcessingRequest = false;
          });
          // No mostramos mensaje porque no sabemos si realmente lo agregó
        }
      },
      onCanceled: () {
        if (mounted) {
          setState(() {
            _isProcessingRequest = false;
          });
          // No mostramos mensaje de cancelación porque el usuario ya lo sabe
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _isProcessingRequest = false;
          });

          showAppSnackBar(
            context,
            '$error',
            const Duration(seconds: 3),
            backgroundColor: Colors.red,
          );
        }
      },
    );
  }
}
