import 'package:flutter/material.dart';
import 'package:freeway_app/locatordevice/presentation/widgets/loading_view.dart';
import 'package:freeway_app/widgets/theme/app_theme.dart';
import 'package:provider/provider.dart';

import '../locatordevice/locator_device_module.dart';
import '../pages/add_insurance.dart';
import '../providers/auth_provider.dart';
import '../providers/home_policy_provider.dart';
import '../providers/notification_provider.dart';
import '../utils/menu/circle_nav_bar.dart';
import '../widgets/homepage/card_swiper.dart';
import '../widgets/homepage/contact_agent.dart';
import '../widgets/homepage/header_section.dart';
import '../widgets/homepage/notifications.dart';
import '../widgets/homepage/product_list.dart';
import '../widgets/homepage/roadside_help.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
    });
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

        if (customerId <= 0) {
          debugPrint(
            'HomePage - ADVERTENCIA: customerId inválido: $customerId',
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: ID de cliente inválido'),
              duration: Duration(seconds: 3),
            ),
          );
          return;
        }

        // Cargar políticas
        final policyProvider =
            Provider.of<HomePolicyProvider>(context, listen: false);
        debugPrint(
          'HomePage - Cargando políticas para customerId: $customerId',
        );
        policyProvider.fetchHomePolicies(customerId);

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
      return const Scaffold(
        body: Center(
          child: LoadingView(message: 'Loading...'),
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
                      child: Text(
                        'Hello, ${user.fullName}',
                        style: TextStyle(
                          fontFamily: 'Open Sans',
                          fontSize: 20,
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
                        vertical: 12.0,
                      ),
                      child: CardSwiperSection(
                        user: user,
                        policyNumber: 'CAAAPO000380840',
                      ),
                    ),

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
                            'Add Products',
                            style: TextStyle(
                              color: AppTheme.getSubtitleTextColor(context),
                              fontFamily: 'Open Sans',
                              fontSize: 14,
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

                    // Contact Agent Card
                    const ContactAgent(),
                    const SizedBox(height: 8),

                    // Notifications Section
                    NotificationsWidget(
                      key: notificationsKey,
                      isExpanded: _isNotificationsExpanded,
                      onClose: () {
                        setState(() {
                          _isNotificationsExpanded = false;
                        });
                      },
                    ),
                    // Espacio adicional al final para asegurar que el último contenido sea visible
                    const SizedBox(height: 20),
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
              bottom: -5, // Cambiado de -10 a -5 para ajustar la posición
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
                  TabData(Icons.home_outlined, 'My Products'),
                  TabData(Icons.verified_user_outlined, '+ Add Insurance'),
                  TabData(Icons.location_on_outlined, 'Location'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
