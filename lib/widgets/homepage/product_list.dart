import 'package:flutter/material.dart';

class ProductList extends StatelessWidget {
  const ProductList({super.key});

  final List<ProductItem> _products = const [
    ProductItem(
      title: 'Roadside\nAssistance',
      imagePath: 'assets/home/icons/icon-roadside.png',
      backgroundColor: Color(0xFFEFF6FF),
    ),
    ProductItem(
      title: 'Motorcycle\nInsurance',
      imagePath: 'assets/home/icons/icon-motorcycle.png',
      backgroundColor: Color(0xFFF7FFF2),
    ),
    ProductItem(
      title: 'Renters\nInsurance',
      imagePath: 'assets/home/icons/icon-renters.png',
      backgroundColor: Color(0xFFFFF0DF),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(right: 16.0),
      child: Row(
        children: _products
            .map(
              (product) => Container(
                width: 160,
                margin: const EdgeInsets.only(right: 12.0),
                child: ProductCard(product: product),
              ),
            )
            .toList(),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final ProductItem product;

  const ProductCard({
    required this.product,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 70,
      decoration: BoxDecoration(
        color: product.backgroundColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          const BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: Image.asset(
                product.imagePath,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                product.title,
                style: const TextStyle(
                  fontFamily: 'Open Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 18 / 14, // line-height: 18px
                  letterSpacing: 0,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
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
