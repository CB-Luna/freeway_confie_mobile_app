import 'package:acceptance_app/data/constants.dart';
import 'package:acceptance_app/pages/webview_page.dart';
import 'package:acceptance_app/providers/auth_provider.dart';
import 'package:acceptance_app/utils/app_localizations_extension.dart';
import 'package:acceptance_app/utils/responsive_font_sizes.dart';
import 'package:acceptance_app/widgets/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductList extends StatefulWidget {
  const ProductList({super.key});

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  final ScrollController _scrollController = ScrollController();
  bool _showRightIndicator = true; // Indicador de scroll a la derecha
  bool _showLeftIndicator = false; // Indicador de scroll a la izquierda

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // Solo procesar si el ScrollController tiene dimensiones válidas
    if (_scrollController.position.hasContentDimensions) {
      // Verificar si estamos cerca del final del scroll (derecha)
      final atEnd = _scrollController.position.pixels >=
          (_scrollController.position.maxScrollExtent - 8);

      // Verificar si estamos cerca del inicio del scroll (izquierda)
      final atStart = _scrollController.position.pixels <= 8;

      // Actualizar estado de indicador derecho
      if (atEnd && _showRightIndicator) {
        setState(() => _showRightIndicator = false);
      } else if (!atEnd && !_showRightIndicator) {
        setState(() => _showRightIndicator = true);
      }

      // Actualizar estado de indicador izquierdo
      // Solo mostrar el indicador izquierdo si no estamos al inicio
      if (!atStart && !_showLeftIndicator) {
        setState(() => _showLeftIndicator = true);
      } else if (atStart && _showLeftIndicator) {
        setState(() => _showLeftIndicator = false);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Método para manejar el tap en un producto
  Future<void> _handleProductTap(ProductItem product) async {
    // Si es el producto de seguro de motocicleta (segundo producto)
    if (product.imagePath == 'assets/home/icons/icon-motorcycle.png') {
      await _handleMotorcycleInsurance(context);
    }
    // Si es el producto de seguro de inquilinos (tercer producto)
    else if (product.imagePath == 'assets/home/icons/icon-renters.png') {
      await _handleRentersInsurance(context);
    }
  }

  // Método para manejar el seguro de motocicleta
  Future<void> _handleMotorcycleInsurance(BuildContext context) async {
    // Obtener información del usuario actual para prellenar formularios
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    // Preparar datos del usuario para pasar a los formularios
    final Map<String, String> userData = {
      'firstName': user?.fullName.split(' ').first ?? '',
      'lastName': user?.fullName.split(' ').isNotEmpty == true &&
              user!.fullName.split(' ').length > 1
          ? user.fullName.split(' ').skip(1).join(' ')
          : '',
      'email': user?.email ?? '',
      'phone': user?.phone ?? '',
      'zipCode': user?.zipCode ?? '',
    };

    // URL para el seguro de motocicleta (tomada de vehicle_insurance_grid.dart)
    final String zipCode = user?.zipCode ?? '';
    final String urlString =
        '$urlBaseEmbedSeguros/cotizacion-seguro-de-moto/?zipcode=$zipCode&first_name=${userData['firstName']}&last_name=${userData['lastName']}&email=${userData['email']}&phone=${userData['phone']}';

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebViewPage(
          url: urlString,
          title: context.translate('vehicleInsurance.motorcycle'),
          userData: userData,
          formType: 'motorcycle',
        ),
      ),
    );
  }

  // Método para manejar el seguro de inquilinos
  Future<void> _handleRentersInsurance(BuildContext context) async {
    // Obtener información del usuario actual para prellenar formularios
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    // Preparar datos del usuario para pasar a los formularios
    final Map<String, String> userData = {
      'firstName': user?.fullName.split(' ').first ?? '',
      'lastName': user?.fullName.split(' ').isNotEmpty == true &&
              user!.fullName.split(' ').length > 1
          ? user.fullName.split(' ').skip(1).join(' ')
          : '',
      'email': user?.email ?? '',
      'phone': user?.phone ?? '',
      'zipCode': user?.zipCode ?? '',
      'city': user?.city ?? '',
      'state': user?.state ?? '',
    };

    // URL para el seguro de inquilinos (tomada de property_insurance_grid.dart)
    final String zipCode = user?.zipCode ?? '';
    final String city = user?.city ?? '';
    final String state = user?.state ?? '';
    final String urlString =
        '${urlBaseEmbed}renters-insurance-quote-form/?zipcode=$zipCode&state=$state&city=$city';

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebViewPage(
          url: urlString,
          title: 'Renters Insurance',
          userData: userData,
          formType: 'renters',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Obtener el ancho de la pantalla para cálculos responsive
    final screenWidth = MediaQuery.of(context).size.width;
    // Obtener el TextScaler del dispositivo
    final textScaler = MediaQuery.of(context).textScaler.scale(1);
    // Calcular el ancho ideal para las tarjetas basado en el ancho de la pantalla
    final cardWidth = screenWidth * (textScaler > 1 ? 0.55 : 0.4);

    final List<ProductItem> products = [
      ProductItem(
        title: context.translate('home.products.motorcycleInsurance'),
        imagePath: 'assets/home/icons/icon-motorcycle.png',
        backgroundColor: AppTheme.backgroundGreenColor,
      ),
      ProductItem(
        title: context.translate('home.products.rentersInsurance'),
        imagePath: 'assets/home/icons/icon-renters.png',
        backgroundColor: AppTheme.backgroundGreenColor,
      ),
    ];

    return Stack(
      alignment: Alignment.centerRight,
      children: [
        SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(right: 16.0),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Alinea las tarjetas desde arriba
            children: products
                .map(
                  (product) => Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: ProductCard(
                      product: product,
                      cardWidth: cardWidth,
                      onProductTap: _handleProductTap,
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        // Indicador de scroll a la izquierda
        if (_showLeftIndicator)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: () {
                // Scroll hacia la izquierda al hacer tap en el indicador
                _scrollController.animateTo(
                  _scrollController.position.pixels - cardWidth,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: Container(
                width: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      AppTheme.getBackgroundColor(context)
                          .withValues(alpha: 0.5),
                      AppTheme.getBackgroundColor(context)
                          .withValues(alpha: 0.0),
                    ],
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.arrow_back_ios,
                  color: AppTheme.getPrimaryColor(context),
                  size: 35,
                ),
              ),
            ),
          ),
        // Indicador de scroll a la derecha
        if (_showRightIndicator)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: () {
                // Scroll hacia la derecha al hacer tap en el indicador
                _scrollController.animateTo(
                  _scrollController.position.pixels + cardWidth,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: Container(
                width: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                    colors: [
                      AppTheme.getBackgroundColor(context)
                          .withValues(alpha: 0.5),
                      AppTheme.getBackgroundColor(context)
                          .withValues(alpha: 0.0),
                    ],
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: AppTheme.getPrimaryColor(context),
                  size: 35,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class ProductCard extends StatelessWidget {
  final ProductItem product;
  final double cardWidth;
  final Function(ProductItem) onProductTap;

  const ProductCard({
    required this.product,
    required this.cardWidth,
    required this.onProductTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Calcular tamaño del icono proporcional al ancho de la tarjeta
    final iconSize = cardWidth * 0.25;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      shadowColor: AppTheme.getBoxShadowColor(context).withValues(alpha: 0.3),
      child: InkWell(
        onTap: () async {
          // Llamar a la función de callback con el producto seleccionado
          onProductTap(product);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: cardWidth,
          decoration: BoxDecoration(
            color: product.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                product.backgroundColor,
                product.backgroundColor.withValues(alpha: 0.85),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color:
                    AppTheme.getBoxShadowColor(context).withValues(alpha: 0.1),
                blurRadius: 1,
                offset: const Offset(0, 1),
                spreadRadius: 0.5,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: iconSize,
                  height: iconSize,
                  padding: EdgeInsets.all(iconSize * 0.15),
                  child: Image.asset(
                    product.imagePath,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(width: cardWidth * 0.06),
                Expanded(
                  child: Text(
                    product.title,
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: responsiveFontSizes.bodyTextLocation(context),
                      fontWeight: FontWeight.w600,
                      color: AppTheme.black,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProductItem {
  final String title;
  final String imagePath;
  final Color backgroundColor;

  const ProductItem({
    required this.title,
    required this.imagePath,
    required this.backgroundColor,
  });
}
