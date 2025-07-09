import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:freeway_app/locatordevice/presentation/widgets/loading_view.dart';
import 'package:freeway_app/models/user_model.dart';
import 'package:freeway_app/utils/app_localizations_extension.dart';
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
  final CardSwiperController controller = CardSwiperController();
  int currentIndex = 0;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    // Usar Future.microtask para programar la carga después de que se complete el build
    Future.microtask(() => _loadPolicies());
  }

  Future<void> _loadPolicies() async {
    if (_isDisposed) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      final policyProvider =
          Provider.of<HomePolicyProvider>(context, listen: false);
      await policyProvider
          .fetchHomePolicies(authProvider.currentUser!.policies);
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
    controller.dispose();
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

  Widget _buildCardSwiper(List<Widget> cards) {
    return Column(
      children: [
        // Carrusel de tarjetas
        SizedBox(
          width: double.infinity,
          child: cards.isEmpty
              ? Center(child: Text(context.translate('home.noCardsAvailable')))
              : cards.length == 1
                  // Si solo hay una tarjeta, mostrarla directamente sin efecto de swipe
                  ? cards[0]
                  // Si hay múltiples tarjetas, usar el CardSwiper
                  : CardSwiper(
                      controller: controller,
                      cardsCount: cards.length,
                      onSwipe: (previousIndex, currentIndex, direction) {
                        setState(() {
                          this.currentIndex =
                              (currentIndex ?? 0) % cards.length;
                        });
                        return true;
                      },
                      cardBuilder: (
                        context,
                        index,
                        percentThresholdX,
                        percentThresholdY,
                      ) =>
                          SizedBox(
                        width: double.infinity,
                        child: cards[index % cards.length],
                      ),
                      allowedSwipeDirection:
                          const AllowedSwipeDirection.symmetric(
                        horizontal: true,
                      ),
                      isLoop: true,
                      padding: const EdgeInsets.all(0),
                      scale: 0.0,
                      backCardOffset: const Offset(0, 0),
                      numberOfCardsDisplayed: 1,
                      duration: const Duration(milliseconds: 300),
                    ),
        ),
        // Indicadores de página - solo mostrarlos si hay más de una tarjeta
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
