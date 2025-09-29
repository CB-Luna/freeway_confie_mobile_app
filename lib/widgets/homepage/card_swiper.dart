import 'package:flutter/material.dart';
import 'package:freeway_app/locatordevice/presentation/widgets/loading_view.dart';
import 'package:freeway_app/models/user_model.dart';
import 'package:freeway_app/pages/add_insurance.dart';
import 'package:freeway_app/pages/user_data_page.dart';
import 'package:freeway_app/utils/app_localizations_extension.dart';
import 'package:freeway_app/utils/responsive_font_sizes.dart';
import 'package:freeway_app/widgets/theme/app_theme.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/home_policy_provider.dart';
import 'policy_card.dart';
import 'policy_inactive_card.dart';

class CardSwiperSection extends StatefulWidget {
  final User user;

  const CardSwiperSection({
    required this.user,
    super.key,
  });

  @override
  State<CardSwiperSection> createState() => _CardSwiperSectionState();
}

class _CardSwiperSectionState extends State<CardSwiperSection> {
  int currentIndex = 0;
  bool _isDisposed = false;
  PageController? _pageController;
  
  // Número muy grande para simular un carrusel infinito
  static const int _infinitePageCount = 10000;
  
  // Método para obtener la página inicial que siempre comience en la primera tarjeta
  int _getInitialPage(int cardCount) {
    if (cardCount == 0) return _infinitePageCount ~/ 2;
    // Encontrar un múltiplo del número de tarjetas cerca del medio del rango
    final middle = _infinitePageCount ~/ 2;
    final remainder = middle % cardCount;
    // Ajustar para que sea múltiplo exacto (índice 0)
    return middle - remainder;
  }

  @override
  void initState() {
    super.initState();
    debugPrint('==== INICIALIZANDO CARD SWIPER ====');
    // El PageController se inicializará en _buildCardSwiper cuando sepamos cuántas tarjetas hay
    // Usar Future.microtask para programar la carga después de que se complete el build
    Future.microtask(() => _loadPolicies());
  }

  Future<void> _loadPolicies() async {
    if (_isDisposed) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      final policyProvider =
          Provider.of<HomePolicyProvider>(context, listen: false);
      await policyProvider.fetchHomePolicies(
        authProvider.currentUser!.hasPolicies
            ? authProvider.currentUser!.policies
            : [],
      );
      if (!_isDisposed) {
        setState(() {
          // Actualizar el estado después de cargar las políticas
        });
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomePolicyProvider>(
      builder: (context, policyProvider, child) {
        if (policyProvider.isLoading) {
          return SizedBox(
            width: double.infinity,
            child: Center(
              child: LoadingView(
                message: context.translate('home.loadingPolicies'),
              ),
            ),
          );
        }

        // Añadir logs para depuración
        debugPrint('Total policies: ${policyProvider.policies.length}');
        for (var policy in policyProvider.policies) {
          debugPrint(
            'Policy: ${policy.policyNumber}, line_of_business: ${policy.lineOfBusiness}, carrier: ${policy.carrierName}',
          );
        }

        // Si hay un error, mostrar tarjetas predeterminadas
        if (policyProvider.errorMessage != null) {
          debugPrint('Error message: ${policyProvider.errorMessage}');
          return _buildDefaultCards();
        }

        // Lista de widgets de tarjetas con datos de la API
        final List<Widget> cards = [];

        // Pólizas Activas (Active)
        final activePolicies = policyProvider.getPoliciesByType('Active');
        debugPrint('Active Policies (type 1): ${activePolicies.length}');
        if (activePolicies.isNotEmpty) {
          for (final policy in activePolicies) {
            cards.add(
              PolicyCard(
                user: widget.user,
                policy: policy,
              ),
            );
          }
        }

        // Pólizas Inactivas (Inactive)
        final inactivePolicies = policyProvider.getPoliciesByType('Inactive');
        debugPrint('Inactive Policies (type 2): ${inactivePolicies.length}');
        if (inactivePolicies.isNotEmpty) {
          for (final policy in inactivePolicies) {
            cards.add(
              PolicyInactiveCard(
                user: widget.user,
                policyNumber: policy.policyNumber,
                policy: policy,
              ),
            );
          }
        }

        debugPrint('Total cards created: ${cards.length}');
        return _buildCardSwiper(cards);
      },
    );
  }

  Widget _buildDefaultCards() {
    debugPrint('Building default card due to error');

    // Tarjeta predeterminada en caso de error
    final List<Widget> cards = [];

    debugPrint('Created ${cards.length} default card');
    return _buildCardSwiper(cards);
  }

  Widget _buildEmptyCards(BuildContext context, bool isSmallScreen) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: AppTheme.getCardColor(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: isSmallScreen ? 45 : 65,
              height: isSmallScreen ? 45 : 65,
              child: Image.asset(
                'assets/home/animations/empty_wallet.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 6),
            SizedBox(
              width: isSmallScreen ? 200 : 250,
              child: Text(
                context.translate('home.noPolicyTitle'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.getPrimaryColor(context),
                  fontSize: responsiveFontSizes.bodyMedium(context),
                ),
              ),
            ),
            const SizedBox(height: 6),
            // Texto informativo con el nuevo mensaje
            SizedBox(
              width: isSmallScreen ? 300 : 350,
              child: Text(
                context.translate('home.noPolicyFound'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.getTextGreyColor(context),
                  fontSize: responsiveFontSizes.bodySmall(context),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Botones de acción
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Botón para actualizar perfil
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UserDataPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.getGreenColor(context),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      context.translate('home.updateProfile'),
                      style: TextStyle(
                        fontSize: responsiveFontSizes.button(context),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Botón para añadir seguro
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddInsurancePage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.getPrimaryColor(context),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      context.translate('home.addInsurance'),
                      style: TextStyle(
                        fontSize: responsiveFontSizes.button(context),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardSwiper(List<Widget> cards) {
    return Column(
      children: [
        // Carrusel de tarjetas
        SizedBox(
          width: double.infinity,
          child: cards.isEmpty
              ? _buildEmptyCards(
                  context,
                  MediaQuery.of(context).size.width < 600,
                )
              : cards.length == 1
                  // Si solo hay una tarjeta, mostrarla directamente sin efecto de swipe
                  ? cards[0]
                  // Si hay múltiples tarjetas, usar PageView para navegación bidireccional intuitiva con carrusel infinito
                  : SizedBox(
                      // Definir una altura explícita para el PageView
                      height: 220, // Altura aproximada de una tarjeta de póliza
                      child: Builder(
                        builder: (context) {
                          // Inicializar el PageController si aún no existe
                          if (_pageController == null) {
                            final initialPage = _getInitialPage(cards.length);
                            _pageController = PageController(
                              initialPage: initialPage,
                            );
                            debugPrint('PageController inicializado con página: $initialPage');
                            debugPrint('Total de tarjetas: ${cards.length}');
                            debugPrint('Índice inicial calculado: ${initialPage % cards.length}');
                          }
                          
                          return PageView.builder(
                            controller: _pageController!,
                            // Usar un número muy grande para simular infinito
                            itemCount: _infinitePageCount,
                            onPageChanged: (virtualIndex) {
                              final int newActualIndex = virtualIndex % cards.length;
                              debugPrint('\n==== PAGE CHANGED ====');
                              debugPrint('Índice virtual: $virtualIndex');
                              debugPrint('Total de tarjetas: ${cards.length}');
                              debugPrint('Índice real calculado: $newActualIndex');
                              debugPrint('Índice anterior: $currentIndex');
                              setState(() {
                                // Calcular el índice real usando módulo
                                currentIndex = newActualIndex;
                              });
                              debugPrint('Nuevo índice actual: $currentIndex');
                            },
                            itemBuilder: (context, virtualIndex) {
                              // Calcular el índice real de la tarjeta usando módulo
                              final int actualIndex = virtualIndex % cards.length;
                              debugPrint('Building card - Virtual index: $virtualIndex, Actual index: $actualIndex');
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 5.0,
                                ),
                                child: cards[actualIndex],
                              );
                            },
                          );
                        },
                      ),
                    ),
        ),
        // // Indicadores de página - solo mostrarlos si hay más de una tarjeta
        if (cards.length > 1) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              cards.length,
              (index) => Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: currentIndex == index
                      ? AppTheme.getIndicatorCurrentIndexCardColor(context)
                      : AppTheme.getIndicatorIndexCardColor(context),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
