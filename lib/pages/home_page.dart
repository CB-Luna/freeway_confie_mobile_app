import 'dart:io';

import 'package:acceptance_app/locatordevice/presentation/widgets/loading_view.dart';
import 'package:acceptance_app/utils/app_localizations_extension.dart';
import 'package:acceptance_app/utils/responsive_font_sizes.dart';
import 'package:acceptance_app/widgets/homepage/card_swiper.dart';
import 'package:acceptance_app/widgets/homepage/contact_agent.dart';
import 'package:acceptance_app/widgets/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../locatordevice/locator_device_module.dart';
import '../pages/add_insurance.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import '../utils/menu/circle_nav_bar.dart';
import '../widgets/homepage/header_section.dart';
import '../widgets/homepage/product_list.dart';
import '../widgets/homepage/roadside_help.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _userName = '';
  bool _isLoading = true;
  int _selectedIndex = 0;
  bool _isInitialized = false;
  bool _isNotificationsExpanded = false;
  final notificationsKey = GlobalKey();
  final notificationsAnchorKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
      _loadUserName();
    });
  }

  Future<void> _loadUserName() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (mounted) {
      setState(() {
        _userName = authProvider.currentUser?.fullName ?? 'Freeway User';
        _isLoading = false;
      });
    }
  }

  void _initializeData() {
    if (!_isInitialized) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      debugPrint(
        'HomePage - Inicializando datos con usuario: ${authProvider.currentUser?.fullName}',
      );

      if (authProvider.currentUser != null) {
        final customerId = authProvider.currentUser!.customerId;
        debugPrint('HomePage - Customer ID: $customerId');

        // Ya no necesitamos cargar políticas porque las tenemos en authProvider.currentUser.policies
        debugPrint(
          'HomePage - Usando políticas del usuario actual: ${authProvider.currentUser!.policies.length} pólizas disponibles',
        );

        // Cargar notificaciones
        final notificationProvider =
            Provider.of<NotificationProvider>(context, listen: false);
        debugPrint(
          'HomePage - Cargando notificaciones para customerId: $customerId',
        );
        notificationProvider.fetchNotifications(customerId);
      } else {
        debugPrint('HomePage - No hay usuario autenticado');
      }
      _isInitialized = true;
    }
  }

  // Método para calcular el offset adecuado según el dispositivo
  double _calculateOffset(BuildContext context) {
    if (Platform.isIOS) {
      // En iOS, usamos un offset fijo
      return -15;
    } else {
      // En Android, calculamos el offset basado en MediaQuery
      final mediaQuery = MediaQuery.of(context);
      final bottomPadding = mediaQuery.padding.bottom;
      final viewInsets = mediaQuery.viewInsets.bottom;
      final deviceHeight = mediaQuery.size.height;

      // Detectar si es un dispositivo con navegación por gestos
      final hasGestureNavigation = bottomPadding > 15;

      // Ajustar el offset según el tipo de navegación
      if (hasGestureNavigation) {
        // Si tiene navegación por gestos, necesitamos un offset mayor
        return -bottomPadding / 1.5;
      } else if (viewInsets > 0) {
        // Si el teclado está visible
        return -15;
      } else if (deviceHeight > 700) {
        // Para dispositivos grandes
        return -30;
      } else {
        // Para dispositivos más pequeños
        return -15;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // Verificar si el usuario está autenticado
    if (authProvider.currentUser == null) {
      debugPrint('HomePage - Usuario no autenticado, redirigiendo a login');
      // Redirigir a la pantalla de login
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/login', (route) => false);
      });
      // Mostrar un indicador de carga mientras se redirige
      return Scaffold(
        body: Center(
          child:
              LoadingView(message: context.translate('home.loadingPolicies')),
        ),
      );
    }

    final user = authProvider
        .currentUser!; // Ahora es seguro usar ! porque ya verificamos

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: SafeArea(
        child: Stack(
          children: [
            // Header fijo en la parte superior
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Transform.translate(
                offset: const Offset(0, -5),
                child: HeaderSection(
                  onNotificationTap: () {
                    debugPrint(
                      'HomePage - Navegando a la sección de notificaciones',
                    );
                    // Cambiar el estado de expansión
                    setState(() {
                      _isNotificationsExpanded = !_isNotificationsExpanded;
                    });

                    // Hacer scroll hasta el anclaje de notificaciones
                    if (notificationsAnchorKey.currentContext != null) {
                      // Usar un pequeño retraso para asegurar que el estado se actualice antes del scroll
                      Future.delayed(const Duration(milliseconds: 100), () {
                        Scrollable.ensureVisible(
                          notificationsAnchorKey.currentContext!,
                          duration: const Duration(milliseconds: 800),
                          curve: Curves
                              .easeOutQuart, // Curva más suave para un efecto más elegante
                        );
                      });
                    }
                  },
                ),
              ),
            ),

            // Contenido scrollable
            Positioned(
              top: 70, // Altura aproximada del header
              left: 0,
              right: 0,
              bottom: 70, // Espacio para el CircleNavBar
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting
                    const SizedBox(height: 5),
                    Center(
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              context.translateWithArgs(
                                'home.greeting',
                                args: [_userName],
                              ),
                              style: TextStyle(
                                fontFamily: 'Open Sans',
                                fontSize:
                                    responsiveFontSizes.titleMedium(context),
                                fontWeight: FontWeight.w700,
                                height: 24 / 20,
                                letterSpacing: 0,
                                color: AppTheme.getTitleTextColor(context),
                              ),
                            ),
                    ),
                    const SizedBox(height: 4),

                    // Card Swiper Section
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 8.0,
                      ),
                      child: CardSwiperSection(
                        user: user,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Contact Agent Card
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.0),
                      child: ContactAgent(),
                    ),

                    const SizedBox(height: 12),

                    // Roadside Help Card
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.0),
                      child: RoadsideHelp(),
                    ),
                    const SizedBox(height: 12),

                    // Add Products Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.translate('home.addProducts'),
                            style: TextStyle(
                              color: AppTheme.getSubtitleTextColor(context),
                              fontFamily: 'Open Sans',
                              fontSize: responsiveFontSizes.bodyLarge(context),
                              fontWeight: FontWeight.w600,
                              height: 22 / 14,
                              letterSpacing: 0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const ProductList(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    //TODO: Notifications Section, when the API is ready
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    //   child: NotificationsWidget(
                    //     key: notificationsKey,
                    //     isExpanded: _isNotificationsExpanded,
                    //     onClose: () {
                    //       setState(() {
                    //         _isNotificationsExpanded = false;
                    //       });
                    //     },
                    //   ),
                    // ),
                    // // Espacio adicional al final para asegurar que el último contenido sea visible
                    // const SizedBox(height: 20),
                    // Widget de anclaje para el scroll de notificaciones
                    SizedBox(
                      key: notificationsAnchorKey,
                      height:
                          0, // Quitamos la altura para que el scroll no se pase
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Navigation fijo en la parte inferior
            Positioned(
              left: 0,
              right: 0,
              // Ajustar posición según la plataforma
              bottom: _calculateOffset(context),
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
          ],
        ),
      ),
    );
  }
}
