import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:freeway_app/locatordevice/presentation/widgets/loading_view.dart';
import 'package:freeway_app/widgets/theme/app_theme.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/home_policy_provider.dart';
import 'policy_card.dart';
import 'policy_inactive_card.dart';
import 'roadside_assist.dart';

class CardSwiperSection extends StatefulWidget {
  final dynamic user;
  final String policyNumber;

  const CardSwiperSection({
    required this.user,
    required this.policyNumber,
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
          .fetchHomePolicies(authProvider.currentUser!.customerId);
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
          return const SizedBox(
            height: 170,
            width: double.infinity,
            child: Center(
              child: LoadingView(message: 'Loading policies...'),
            ),
          );
        }

        // Añadir logs para depuración
        debugPrint('Total vehicles: ${policyProvider.vehicles.length}');
        for (var vehicle in policyProvider.vehicles) {
          debugPrint(
            'Vehicle: ${vehicle.plate}, policy_type_id: ${vehicle.policyTypeId}, provider_id: ${vehicle.providerId}',
          );
        }

        // Si hay un error, mostrar tarjetas predeterminadas
        if (policyProvider.errorMessage != null) {
          debugPrint('Error message: ${policyProvider.errorMessage}');
          return _buildDefaultCards();
        }

        // Lista de widgets de tarjetas con datos de la API
        final List<Widget> cards = [];

        // Pólizas tipo 2 (Auto Policy)
        final autoPolicies = policyProvider.getVehiclesByPolicyTypeId(2);
        debugPrint('Auto Policies (type 2): ${autoPolicies.length}');
        if (autoPolicies.isNotEmpty) {
          for (final vehicle in autoPolicies) {
            cards.add(
              PolicyCard(
                user: widget.user,
                vehicle: vehicle,
              ),
            );
          }
        }

        // Pólizas tipo 1 (Roadside Assistance)
        final roadsidePolicies = policyProvider.getVehiclesByPolicyTypeId(1);
        debugPrint('Roadside Policies (type 1): ${roadsidePolicies.length}');
        if (roadsidePolicies.isNotEmpty) {
          for (final vehicle in roadsidePolicies) {
            cards.add(
              RoadsideAssist(
                policyNumber: vehicle.plate,
                vehicle: vehicle,
              ),
            );
          }
        }

        // Pólizas tipo 3 (Inactive)
        final inactivePolicies = policyProvider.getVehiclesByPolicyTypeId(3);
        debugPrint('Inactive Policies (type 3): ${inactivePolicies.length}');
        if (inactivePolicies.isNotEmpty) {
          for (final vehicle in inactivePolicies) {
            cards.add(
              PolicyInactiveCard(
                user: widget.user,
                policyNumber: vehicle.plate,
                vehicle: vehicle,
              ),
            );
          }
        }

        // Si no hay tarjetas, mostrar una tarjeta predeterminada
        if (cards.isEmpty) {
          debugPrint('No cards found, adding default card');
          cards.add(PolicyCard(user: widget.user));
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

    // Añadir una tarjeta predeterminada
    cards.add(PolicyCard(user: widget.user));

    debugPrint('Created ${cards.length} default card');
    return _buildCardSwiper(cards);
  }

  Widget _buildCardSwiper(List<Widget> cards) {
    return Column(
      children: [
        // Carrusel de tarjetas
        SizedBox(
          height: 180,
          width: double.infinity,
          child: cards.isEmpty
              ? const Center(child: Text('No hay tarjetas disponibles'))
              : CardSwiper(
                  controller: controller,
                  cardsCount: cards.length,
                  onSwipe: (previousIndex, currentIndex, direction) {
                    setState(() {
                      this.currentIndex = (currentIndex ?? 0) % cards.length;
                    });
                    return true;
                  },
                  cardBuilder:
                      (context, index, percentThresholdX, percentThresholdY) =>
                          SizedBox(
                    width: double.infinity,
                    child: cards[index % cards.length],
                  ),
                  allowedSwipeDirection:
                      const AllowedSwipeDirection.symmetric(horizontal: true),
                  isLoop: true,
                  padding: const EdgeInsets.all(0),
                  scale: 0.0,
                  backCardOffset: const Offset(0, 0),
                  numberOfCardsDisplayed: 1,
                  duration: const Duration(milliseconds: 300),
                ),
        ),
        // Indicadores de página
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            cards.isNotEmpty ? cards.length : 0,
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
    );
  }
}
