import 'package:flutter/material.dart';
import 'package:freeway_app/utils/app_localizations_extension.dart';
import 'package:freeway_app/widgets/theme/app_theme.dart';

class ProductList extends StatefulWidget {
  const ProductList({super.key});

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  final ScrollController _scrollController = ScrollController();
  bool _showIndicator = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // Oculta el indicador si el usuario llega al final del scroll
    if (_scrollController.position.hasContentDimensions) {
      final atEnd = _scrollController.position.pixels >=
          (_scrollController.position.maxScrollExtent - 8);
      if (atEnd && _showIndicator) {
        setState(() => _showIndicator = false);
      } else if (!atEnd && !_showIndicator) {
        setState(() => _showIndicator = true);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Obtener el ancho de la pantalla para cálculos responsive
    final screenWidth = MediaQuery.of(context).size.width;
    // Calcular el ancho ideal para las tarjetas basado en el ancho de la pantalla
    final cardWidth = screenWidth < 360 ? screenWidth * 0.4 : 140.0;

    final List<ProductItem> products = [
      ProductItem(
        title: context.translate('home.products.roadsideAssistance'),
        imagePath: 'assets/home/icons/icon-roadside.png',
        backgroundColor: AppTheme.backgroundBlueColor,
      ),
      ProductItem(
        title: context.translate('home.products.motorcycleInsurance'),
        imagePath: 'assets/home/icons/icon-motorcycle.png',
        backgroundColor: AppTheme.backgroundGreenColor,
      ),
      ProductItem(
        title: context.translate('home.products.rentersInsurance'),
        imagePath: 'assets/home/icons/icon-renters.png',
        backgroundColor: AppTheme.backgroundOrangeColor,
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
            children: products
                .map(
                  (product) => Container(
                    width: cardWidth,
                    margin: const EdgeInsets.only(right: 12.0),
                    child: ProductCard(
                      product: product,
                      cardWidth: cardWidth,
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        if (_showIndicator)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: IgnorePointer(
              child: Container(
                width: 32,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
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

  const ProductCard({
    required this.product,
    required this.cardWidth,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Calcular altura proporcional al ancho
    final cardHeight = cardWidth * 0.45;
    // Calcular tamaño del icono proporcional al ancho de la tarjeta
    final iconSize = cardWidth * 0.3;
    // Calcular tamaño de fuente basado en el ancho de la tarjeta
    final fontSize = cardWidth <= 140 ? 8.0 : 12.0;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      shadowColor: AppTheme.getBoxShadowColor(context).withValues(alpha: 0.3),
      child: Container(
        width: cardWidth,
        height: cardHeight,
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
              color: AppTheme.getBoxShadowColor(context).withValues(alpha: 0.1),
              blurRadius: 1,
              offset: const Offset(0, 1),
              spreadRadius: 0.5,
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(cardWidth * 0.075), // Padding proporcional
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: iconSize,
                height: iconSize,
                padding:
                    EdgeInsets.all(iconSize * 0.15), // Padding proporcional
                child: Image.asset(
                  product.imagePath,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(width: cardWidth * 0.06), // Espacio proporcional
              Expanded(
                child: Text(
                  product.title,
                  style: TextStyle(
                    fontFamily: 'Open Sans',
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                    color: AppTheme.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
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
