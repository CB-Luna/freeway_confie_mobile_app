import 'package:flutter/material.dart';
import 'package:freeway_app/widgets/theme/app_theme.dart';

import 'vehicle_insurance_grid.dart';

class InsuranceCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final String route;
  final double imageWidth;
  final double imageHeight;

  const InsuranceCard({
    required this.title,
    required this.imagePath,
    required this.route,
    super.key,
    this.imageWidth = 100, // valor por defecto
    this.imageHeight = 100, // valor por defecto
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      child: InkWell(
        onTap: () {
          if (title == 'Vehicle Insurance') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const VehicleInsuranceGrid(),
              ),
            );
          } else {
            Navigator.pushNamed(context, route);
          }
        },
        child: Container(
          width: 390, // Ancho ajustado
          height: 86, // Alto ajustado
          decoration: BoxDecoration(
            color: AppTheme.getCardColor(context),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppTheme.getBoxShadowColor(context), // 0.05 opacity
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  flex: 3, // Aumentado para dar más espacio al texto
                  child: Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Open Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.getTitleTextColor(context),
                    ),
                    softWrap: true, // Permite envolver el texto
                    overflow: TextOverflow.visible, // Muestra todo el texto
                  ),
                ),
                Expanded(
                  flex: 2, // Reducido para balancear con el texto
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
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
