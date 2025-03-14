import 'package:flutter/material.dart';
import 'package:freeway_app/models/car_info.dart';

class CarListWidget extends StatelessWidget {
  final List<CarInfo> cars;
  final String? selectedVin;
  final Function(String) onCarSelect;

  const CarListWidget({
    required this.cars, required this.selectedVin, required this.onCarSelect, super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cars.length,
      itemBuilder: (context, index) {
        final car = cars[index];
        final isSelected = car.vin == selectedVin;

        return GestureDetector(
          onTap: () => onCarSelect(car.vin),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? const Color(0xFF0046B9) : Colors.transparent,
                width: 2,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${car.year} ${car.make} ${car.model}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          car.vin,
                          style: TextStyle(
                            fontSize: 14,
                            color: const Color(0xFF1A1A1A).withAlpha(128),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFF0046B9),
                      size: 24,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
